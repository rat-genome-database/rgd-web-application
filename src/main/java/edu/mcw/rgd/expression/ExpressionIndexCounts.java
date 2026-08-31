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
 * <p>One request per system, against
 * {@code /rgdws/expression/index/facets?rgdIds={gene}&tissueIds={system}} - the same index and the
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
 * <p>The requests run in parallel over a small shared pool and results are cached briefly per gene,
 * since ~22 sequential HTTPS calls would otherwise land on the page render. A system whose request
 * fails or times out is dropped rather than failing the page.
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

    private static final int POOL_SIZE = 8;
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

    private ExpressionIndexCounts() {
    }

    /** {@link #byTissue(int, List, String)} in {@link #UNIT_TPM}, which is what the gene report shows. */
    public static LinkedHashMap<String, Map<String, Integer>> byTissue(int geneRgdId, List<String> tissueAccIds) {
        return byTissue(geneRgdId, tissueAccIds, UNIT_TPM);
    }

    /**
     * Counts for one gene across the supplied systems.
     *
     * @param geneRgdId    the expressed gene
     * @param tissueAccIds system accession ids, in the order they should be rendered
     * @param unit         expression unit to count, matched exactly against the index (e.g. "TPM");
     *                     null or blank counts every unit
     * @return system acc id -&gt; (level -&gt; count), holding only systems that have records, in the
     *         order they were asked for. Every inner map carries {@link #LEVEL_ALL} plus one entry
     *         per level present in the index; level keys are lower case with spaces and underscores
     *         removed, so "below cutoff" and "below_cutoff" both fold to "belowcutoff".
     */
    public static LinkedHashMap<String, Map<String, Integer>> byTissue(int geneRgdId, List<String> tissueAccIds,
                                                                      String unit) {

        if (tissueAccIds == null || tissueAccIds.isEmpty()) {
            return new LinkedHashMap<String, Map<String, Integer>>();
        }

        final String units = (unit == null || unit.trim().isEmpty()) ? "" : unit.trim();
        String cacheKey = geneRgdId + ":" + units + ":" + tissueAccIds.hashCode();
        CacheEntry cached = CACHE.get(cacheKey);
        if (cached != null && !cached.isStale()) {
            return copyOf(cached.counts);
        }

        // Submit every system, then collect in the caller's order: the map has to come back in the
        // order the ribbon draws its columns, not the order the responses happen to land in.
        Map<String, Future<Map<String, Integer>>> pending =
                new LinkedHashMap<String, Future<Map<String, Integer>>>();
        for (String tissueAccId : tissueAccIds) {
            if (tissueAccId == null || tissueAccId.trim().isEmpty() || pending.containsKey(tissueAccId)) {
                continue;
            }
            final int rgdId = geneRgdId;
            final String acc = tissueAccId;
            pending.put(acc, POOL.submit(new Callable<Map<String, Integer>>() {
                public Map<String, Integer> call() throws Exception {
                    return levelCounts(rgdId, acc, units);
                }
            }));
        }

        long deadline = System.currentTimeMillis() + FANOUT_TIMEOUT_SEC * 1000L;
        LinkedHashMap<String, Map<String, Integer>> result = new LinkedHashMap<String, Map<String, Integer>>();
        for (Map.Entry<String, Future<Map<String, Integer>>> entry : pending.entrySet()) {
            try {
                long left = Math.max(0, deadline - System.currentTimeMillis());
                Map<String, Integer> counts = entry.getValue().get(left, TimeUnit.MILLISECONDS);
                if (counts != null && !counts.isEmpty()) {
                    result.put(entry.getKey(), counts);
                }
            } catch (Exception e) {
                // one system short is a gap in the ribbon; a thrown exception is a blank report page
                entry.getValue().cancel(true);
                System.out.println("ExpressionIndexCounts: no counts for gene " + geneRgdId
                        + " / " + entry.getKey() + " -- " + e);
            }
        }

        if (CACHE.size() >= CACHE_MAX_ENTRIES) {
            CACHE.clear(); // coarse, but this is a render cache, not a store
        }
        CACHE.put(cacheKey, new CacheEntry(result));
        return copyOf(result);
    }

    /**
     * One system: ask the index for its facets under this gene and turn the {@code levels} buckets
     * into level -&gt; count. Returns an empty map when the system has no records, which is what
     * keeps it off the ribbon.
     */
    private static Map<String, Integer> levelCounts(int geneRgdId, String tissueAccId, String units) throws Exception {

        String url = apiBase() + PATH_FACETS
                + "?rgdIds=" + geneRgdId
                + "&tissueIds=" + enc(tissueAccId)
                + (units.isEmpty() ? "" : "&units=" + enc(units));

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
