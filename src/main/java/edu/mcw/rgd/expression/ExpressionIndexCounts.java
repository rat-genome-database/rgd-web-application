package edu.mcw.rgd.expression;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import edu.mcw.rgd.web.RgdContext;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.TimeUnit;

/**
 * Sample counts per anatomical system for the RNA-Seq ribbon on the gene report, read from the
 * rgdws expression index rather than from GENE_EXPRESSION_VALUE_COUNTS.
 *
 * <p>One request per system and assembly, against
 * {@code /rgdws/expression/index/facets?rgdIds={gene}&tissueIds={system}&mapKey={assembly}} - the same index and the
 * same filter semantics as {@code /index/records/search?tissueIds=...}, which is where the numbers
 * on the ribbon have to agree. Facets is used rather than the records search because it answers a
 * whole column in one round trip: its {@code levels} buckets are the per-level breakdown the
 * ribbon's rows need, where the records search would cost one request per level and drag a page of
 * documents back with each total.
 *
 * <p>Two things follow from letting the index do the filtering:
 * <ul>
 *   <li>Descendant systems roll up server side. {@code tissueIds} matches a record's own tissue or
 *       any of its indexed ancestors, so passing an AGR slim term counts every tissue underneath it
 *       without this class knowing anything about the ontology.</li>
 *   <li>The levels are whatever the index holds. Nothing here declares "high/medium/low" - callers
 *       get back the buckets Elasticsearch returned, normalised, so a level that is absent from the
 *       index simply never appears.</li>
 * </ul>
 *
 * <p>Counts are restricted to one expression unit through the endpoint's {@code units} parameter,
 * which is an exact match on the indexed label - so it is case sensitive, and {@link #UNIT_TPM} is
 * spelled the way the index spells it. Without it the totals would mix TPM and the much smaller
 * FPKM set, and would no longer line up with the TPM detail table the ribbon opens.
 *
 * <p>Counts are also per assembly, because a sample aligned to several assemblies is a separate
 * record per assembly in the index: summed over assemblies a gene with three loaded assemblies
 * reports roughly three times its samples, which is why the gene report asks for one assembly at a
 * time. {@link #mapKeyCounts} says which assemblies a gene actually has records on.
 *
 * <p>The requests run in parallel over a shared pool and results are cached briefly per gene, unit
 * and assembly, since ~22 sequential HTTPS calls per assembly would otherwise land on the page
 * render. A system whose request fails or times out is dropped rather than failing the page.
 */
public class ExpressionIndexCounts {

    /** synthetic level key holding the sum of every real level - the ribbon's "All" row */
    public static final String LEVEL_ALL = "all";

    /** the unit the gene report reports in; spelled as the index stores it, since the filter is exact */
    public static final String UNIT_TPM = "TPM";

    private static final ObjectMapper MAPPER = new ObjectMapper();

    private static final String PATH_FACETS = "/rgdws/expression/index/facets";

    private static final int CONNECT_TIMEOUT_MS = 5_000;
    private static final int READ_TIMEOUT_MS = 20_000;
    /** ceiling on the whole fan-out, so one wedged system cannot hold the report page open */
    private static final int FANOUT_TIMEOUT_SEC = 30;

    // Every task here is one blocking HTTPS call, so the pool is sized for concurrency rather
    // than for cores. It was 8 when the fan-out was one request per system (~22); with an
    // assembly dimension it is one per system and assembly (~22 x 3), and 8 at a time turned
    // that into eight sequential rounds on the report render.
    private static final int POOL_SIZE = 24;
    private static final long CACHE_TTL_MS = 15 * 60 * 1000L;
    private static final int CACHE_MAX_ENTRIES = 500;

    private static final ExecutorService POOL = Executors.newFixedThreadPool(POOL_SIZE, new ThreadFactory() {
        public Thread newThread(Runnable r) {
            Thread t = new Thread(r, "expr-index-counts");
            t.setDaemon(true); // never hold the container open
            return t;
        }
    });

    private static final ConcurrentHashMap<String, CacheEntry> CACHE = new ConcurrentHashMap<String, CacheEntry>();

    /** the assembly list is one request for the whole gene, so it gets its own slot rather than
        sharing the per-system cache */
    private static final ConcurrentHashMap<String, MapKeyCacheEntry> MAPKEY_CACHE =
            new ConcurrentHashMap<String, MapKeyCacheEntry>();

    private ExpressionIndexCounts() {
    }
    /** {@link #byTissue(int, List, String)} in {@link #UNIT_TPM}, which is what the gene report shows. */
    public static LinkedHashMap<String, Map<String, Integer>> byTissue(int geneRgdId, List<String> tissueAccIds) {
        return byTissue(geneRgdId, tissueAccIds, UNIT_TPM);
    }

    /** {@link #byTissue(int, List, String, Integer)} across every assembly. */
    public static LinkedHashMap<String, Map<String, Integer>> byTissue(int geneRgdId, List<String> tissueAccIds,
                                                                      String unit) {
        return byTissue(geneRgdId, tissueAccIds, unit, null);
    }

    /**
     * Counts for one gene across the supplied systems.
     *
     * @param geneRgdId    the expressed gene
     * @param tissueAccIds system accession ids, in the order they should be rendered
     * @param unit         expression unit to count, matched exactly against the index (e.g. "TPM");
     *                     null or blank counts every unit
     * @param mapKey       assembly to count on, or null for every assembly. A sample aligned to
     *                     several assemblies is a separate record per assembly, so leaving this
     *                     null counts it once per assembly it was aligned to.
     * @return system acc id -&gt; (level -&gt; count), holding only systems that have records, in the
     *         order they were asked for. Every inner map carries {@link #LEVEL_ALL} plus one entry
     *         per level present in the index; level keys are lower case with spaces and underscores
     *         removed, so "below cutoff" and "below_cutoff" both fold to "belowcutoff".
     */
    public static LinkedHashMap<String, Map<String, Integer>> byTissue(int geneRgdId, List<String> tissueAccIds,
                                                                      String unit, Integer mapKey) {

        LinkedHashMap<Integer, LinkedHashMap<String, Map<String, Integer>>> perMapKey =
                byTissuePerMapKey(geneRgdId, tissueAccIds, unit, Collections.singletonList(mapKey));
        LinkedHashMap<String, Map<String, Integer>> counts = perMapKey.get(mapKey);
        return counts == null ? new LinkedHashMap<String, Map<String, Integer>>() : counts;
    }

    /**
     * Counts for one gene across the supplied systems, broken out per assembly.
     *
     * <p>Every (assembly, system) pair is one facets request, and they all go to the pool in a
     * single wave rather than one assembly at a time - otherwise the report render waits through
     * one round trip per assembly. The index has no level-by-assembly cross tabulation to ask for
     * instead: the {@code levels} and {@code mapKeys} facets of one response are each totalled
     * over the other dimension, and the {@code tissues} facet buckets a record by its own tissue
     * rather than by its ancestors, so it cannot stand in for the {@code tissueIds} rollup either.
     *
     * @param mapKeys assemblies to count, in any order; a null element means "every assembly" and
     *                comes back under a null key
     * @return mapKey -&gt; the same per-system map {@link #byTissue} returns, keyed in the order the
     *         assemblies were asked for. An assembly with no records for this gene is present with
     *         an empty map, so a caller can tell "asked and none" from "not asked".
     */
    public static LinkedHashMap<Integer, LinkedHashMap<String, Map<String, Integer>>> byTissuePerMapKey(
            int geneRgdId, List<String> tissueAccIds, String unit, Collection<Integer> mapKeys) {

        LinkedHashMap<Integer, LinkedHashMap<String, Map<String, Integer>>> result =
                new LinkedHashMap<Integer, LinkedHashMap<String, Map<String, Integer>>>();
        if (tissueAccIds == null || tissueAccIds.isEmpty() || mapKeys == null || mapKeys.isEmpty()) {
            return result;
        }

        final String units = (unit == null || unit.trim().isEmpty()) ? "" : unit.trim();

        // the systems to ask for, de-duplicated but still in the order the ribbon draws its columns
        List<String> systems = new ArrayList<String>();
        for (String tissueAccId : tissueAccIds) {
            if (tissueAccId != null && !tissueAccId.trim().isEmpty() && !systems.contains(tissueAccId)) {
                systems.add(tissueAccId);
            }
        }

        // Cached per assembly rather than per call: the gene report asks for every assembly at
        // once, but a one-assembly caller then hits the same entries instead of refetching.
        Map<Integer, Map<String, Future<Map<String, Integer>>>> pending =
                new LinkedHashMap<Integer, Map<String, Future<Map<String, Integer>>>>();
        for (Integer mapKey : mapKeys) {
            if (result.containsKey(mapKey) || pending.containsKey(mapKey)) {
                continue;   // the same assembly asked for twice
            }
            CacheEntry cached = CACHE.get(cacheKey(geneRgdId, units, mapKey, systems));
            if (cached != null && !cached.isStale()) {
                result.put(mapKey, copyOf(cached.counts));
                continue;
            }
            Map<String, Future<Map<String, Integer>>> futures =
                    new LinkedHashMap<String, Future<Map<String, Integer>>>();
            for (String tissueAccId : systems) {
                final int rgdId = geneRgdId;
                final String acc = tissueAccId;
                final Integer mk = mapKey;
                futures.put(acc, POOL.submit(new Callable<Map<String, Integer>>() {
                    public Map<String, Integer> call() throws Exception {
                        return levelCounts(rgdId, acc, units, mk);
                    }
                }));
            }
            pending.put(mapKey, futures);
        }

        // One deadline for the whole wave, so a wedged request cannot hold the report page open for
        // FANOUT_TIMEOUT_SEC per assembly.
        long deadline = System.currentTimeMillis() + FANOUT_TIMEOUT_SEC * 1000L;
        for (Map.Entry<Integer, Map<String, Future<Map<String, Integer>>>> perAssembly : pending.entrySet()) {
            LinkedHashMap<String, Map<String, Integer>> counts =
                    new LinkedHashMap<String, Map<String, Integer>>();
            for (Map.Entry<String, Future<Map<String, Integer>>> entry : perAssembly.getValue().entrySet()) {
                try {
                    long left = Math.max(0, deadline - System.currentTimeMillis());
                    Map<String, Integer> levels = entry.getValue().get(left, TimeUnit.MILLISECONDS);
                    if (levels != null && !levels.isEmpty()) {
                        counts.put(entry.getKey(), levels);
                    }
                } catch (Exception e) {
                    // one system short is a gap in the ribbon; a thrown exception is a blank report page
                    entry.getValue().cancel(true);
                    System.out.println("ExpressionIndexCounts: no counts for gene " + geneRgdId
                            + " / " + entry.getKey() + " / mapKey " + perAssembly.getKey() + " -- " + e);
                }
            }
            if (CACHE.size() >= CACHE_MAX_ENTRIES) {
                CACHE.clear(); // coarse, but this is a render cache, not a store
            }
            CACHE.put(cacheKey(geneRgdId, units, perAssembly.getKey(), systems), new CacheEntry(counts));
            result.put(perAssembly.getKey(), counts);
        }

        // back into the order the assemblies were asked for, which the cache hits above broke
        LinkedHashMap<Integer, LinkedHashMap<String, Map<String, Integer>>> ordered =
                new LinkedHashMap<Integer, LinkedHashMap<String, Map<String, Integer>>>();
        for (Integer mapKey : mapKeys) {
            if (result.containsKey(mapKey)) {
                ordered.put(mapKey, result.get(mapKey));
            }
        }
        return ordered;
    }

    /**
     * The assemblies this gene has expression records on, with how many records each carries.
     *
     * <p>One facets request with no system filter: its {@code mapKeys} buckets are exactly the
     * assemblies the index holds records for, so a caller does not have to guess which of the
     * species' assemblies were loaded. Returned largest bucket first, the order Elasticsearch
     * hands them back in; a caller wanting assembly order should sort by the map's own rank.
     *
     * @return mapKey -&gt; record count, empty when this gene has no records at all (or the index
     *         could not be reached, which is not distinguishable here - see {@link #byTissue})
     */
    public static LinkedHashMap<Integer, Integer> mapKeyCounts(int geneRgdId, String unit) {

        final String units = (unit == null || unit.trim().isEmpty()) ? "" : unit.trim();
        String cacheKey = "mapKeys:" + geneRgdId + ":" + units;
        MapKeyCacheEntry cached = MAPKEY_CACHE.get(cacheKey);
        if (cached != null && !cached.isStale()) {
            return new LinkedHashMap<Integer, Integer>(cached.counts);
        }

        LinkedHashMap<Integer, Integer> counts = new LinkedHashMap<Integer, Integer>();
        try {
            String url = apiBase() + PATH_FACETS
                    + "?rgdIds=" + geneRgdId
                    + (units.isEmpty() ? "" : "&units=" + enc(units));
            JsonNode buckets = MAPPER.readTree(fetch(url)).path("mapKeys");
            for (JsonNode bucket : buckets) {
                // the bucket key is the numeric mapKey, but the endpoint renders every facet
                // accession as a string, so it comes back quoted
                String acc = bucket.path("acc").asText("").trim();
                int count = bucket.path("count").asInt(0);
                if (acc.isEmpty() || count <= 0) {
                    continue;
                }
                try {
                    counts.put(Integer.valueOf(acc), count);
                } catch (NumberFormatException ignore) {
                    // not a map key anything could look a name up for, so not an assembly to offer
                }
            }
        } catch (Exception e) {
            // no assemblies reads the same as no records, which hides the section rather than
            // failing the report page
            System.out.println("ExpressionIndexCounts: no assemblies for gene " + geneRgdId + " -- " + e);
        }

        if (MAPKEY_CACHE.size() >= CACHE_MAX_ENTRIES) {
            MAPKEY_CACHE.clear();
        }
        MAPKEY_CACHE.put(cacheKey, new MapKeyCacheEntry(counts));
        return new LinkedHashMap<Integer, Integer>(counts);
    }

    /** one cache slot per gene, unit, assembly and column list */
    private static String cacheKey(int geneRgdId, String units, Integer mapKey, List<String> systems) {
        return geneRgdId + ":" + units + ":" + (mapKey == null ? "*" : mapKey) + ":" + systems.hashCode();
    }

    /**
     * One system on one assembly: ask the index for its facets under this gene and turn the
     * {@code levels} buckets into level -&gt; count. Returns an empty map when the system has no
     * records, which is what keeps it off the ribbon.
     */
    private static Map<String, Integer> levelCounts(int geneRgdId, String tissueAccId, String units,
                                                    Integer mapKey) throws Exception {

        String url = apiBase() + PATH_FACETS
                + "?rgdIds=" + geneRgdId
                + "&tissueIds=" + enc(tissueAccId)
                + (units.isEmpty() ? "" : "&units=" + enc(units))
                + (mapKey == null ? "" : "&mapKey=" + mapKey);

        JsonNode levels = MAPPER.readTree(fetch(url)).path("levels");

        Map<String, Integer> counts = new HashMap<String, Integer>();
        int total = 0;
        for (JsonNode bucket : levels) {
            String level = normalizeLevel(bucket.path("acc").asText(""));
            if (level.isEmpty()) {
                continue;
            }
            int count = bucket.path("count").asInt(0);
            Integer running = counts.get(level);
            counts.put(level, (running == null ? 0 : running) + count);
            total += count;
        }

        if (total == 0) {
            return Collections.emptyMap();
        }
        counts.put(LEVEL_ALL, total);
        return counts;
    }

    /**
     * Level keys are folded to lower case with spaces and underscores stripped, so a caller can look
     * one up without knowing which spelling the index happens to use.
     */
    public static String normalizeLevel(String level) {
        return level == null ? "" : level.trim().toLowerCase().replaceAll("[ _]", "");
    }

    /** rgdws base url; the system property lets a local rgdweb be pointed at a local rgdws */
    private static String apiBase() {
        String configured = System.getProperty("rgdws.base.url");
        if (configured != null && !configured.trim().isEmpty()) {
            return trimTrailingSlash(configured.trim());
        }
        String host = RgdContext.getAPIHostname();
        return trimTrailingSlash(host == null ? "https://rest.rgd.mcw.edu" : host);
    }

    private static String trimTrailingSlash(String s) {
        return s.endsWith("/") ? s.substring(0, s.length() - 1) : s;
    }

    private static String enc(String v) {
        return URLEncoder.encode(v == null ? "" : v, StandardCharsets.UTF_8);
    }

    private static String fetch(String url) throws Exception {
        HttpURLConnection conn = (HttpURLConnection) new URL(url).openConnection();
        try {
            conn.setRequestMethod("GET");
            conn.setRequestProperty("Accept", "application/json");
            conn.setConnectTimeout(CONNECT_TIMEOUT_MS);
            conn.setReadTimeout(READ_TIMEOUT_MS);

            int status = conn.getResponseCode();
            InputStream in = (status >= 400) ? conn.getErrorStream() : conn.getInputStream();
            String body = (in == null) ? "" : readAll(in);
            if (status >= 400) {
                throw new IllegalStateException("HTTP " + status + " from " + url
                        + (body.isEmpty() ? "" : " -- " + body.substring(0, Math.min(300, body.length()))));
            }
            return body;
        } finally {
            conn.disconnect();
        }
    }

    private static String readAll(InputStream in) throws Exception {
        ByteArrayOutputStream buffer = new ByteArrayOutputStream();
        byte[] chunk = new byte[8192];
        int read;
        while ((read = in.read(chunk)) != -1) {
            buffer.write(chunk, 0, read);
        }
        return buffer.toString(StandardCharsets.UTF_8.name());
    }

    /** hand callers their own copy, so one page cannot mutate what the next page reads */
    private static LinkedHashMap<String, Map<String, Integer>> copyOf(
            LinkedHashMap<String, Map<String, Integer>> source) {
        LinkedHashMap<String, Map<String, Integer>> copy =
                new LinkedHashMap<String, Map<String, Integer>>();
        for (Map.Entry<String, Map<String, Integer>> e : source.entrySet()) {
            copy.put(e.getKey(), new HashMap<String, Integer>(e.getValue()));
        }
        return copy;
    }

    private static class MapKeyCacheEntry {
        final LinkedHashMap<Integer, Integer> counts;
        final long stamp = System.currentTimeMillis();

        MapKeyCacheEntry(LinkedHashMap<Integer, Integer> counts) {
            this.counts = counts;
        }

        boolean isStale() {
            return System.currentTimeMillis() - stamp > CACHE_TTL_MS;
        }
    }

    private static class CacheEntry {
        final LinkedHashMap<String, Map<String, Integer>> counts;
        final long stamp = System.currentTimeMillis();

        CacheEntry(LinkedHashMap<String, Map<String, Integer>> counts) {
            this.counts = counts;
        }

        boolean isStale() {
            return System.currentTimeMillis() - stamp > CACHE_TTL_MS;
        }
    }
}
