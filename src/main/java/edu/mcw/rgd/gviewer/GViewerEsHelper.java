package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.ClearScrollRequest;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchScrollRequest;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.core.TimeValue;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.builder.SearchSourceBuilder;

import java.util.*;

/**
 * Shared helpers for the Gviewer controllers that fetch object positions
 * from the "gviewer" Elasticsearch index instead of joining maps_data in
 * Oracle. Term resolution still uses Oracle (ontology DAG traversal); ES
 * is used only for position lookup and result rendering.
 */
public class GViewerEsHelper {

    public static final List<String> SUPPORTED_OBJECT_TYPES =
            Arrays.asList("gene", "qtl", "strain");

    public static final String[] POSITION_SOURCE_FIELDS = new String[]{
            "annotatedObjectRgdId", "objectSymbol", "objectType",
            "chromosome", "startPos", "stopPos", "termAcc", "term"
    };

    /** One position row for an object (matches a maps_data row). */
    public static class Row {
        public final int rgdId;
        public final String objectSymbol;
        public final String objectType;
        public final String chromosome;
        public final String startPos;
        public final String stopPos;

        public Row(int rgdId, String objectSymbol, String objectType,
                   String chromosome, String startPos, String stopPos) {
            this.rgdId = rgdId;
            this.objectSymbol = objectSymbol == null ? "" : objectSymbol;
            this.objectType = objectType == null ? "" : objectType;
            this.chromosome = chromosome == null ? "" : chromosome;
            this.startPos = startPos == null ? "" : startPos;
            this.stopPos = stopPos == null ? "" : stopPos;
        }

        @Override
        public boolean equals(Object o) {
            if (!(o instanceof Row)) return false;
            Row r = (Row) o;
            return rgdId == r.rgdId
                    && Objects.equals(chromosome, r.chromosome)
                    && Objects.equals(startPos, r.startPos)
                    && Objects.equals(stopPos, r.stopPos);
        }

        @Override
        public int hashCode() {
            return Objects.hash(rgdId, chromosome, startPos, stopPos);
        }
    }

    /** One annotation hit (rgdId + the term that brought it in). */
    public static class TermHit {
        public final int rgdId;
        public final String termAcc;
        public final String term;

        public TermHit(int rgdId, String termAcc, String term) {
            this.rgdId = rgdId;
            this.termAcc = termAcc == null ? "" : termAcc;
            this.term = term == null ? "" : term;
        }
    }

    /** Result of resolving + querying ES for a single search criterion. */
    public static class CriterionResult {
        public final Set<Integer> rgdIds = new LinkedHashSet<>();
        public final Map<Integer, List<Row>> positions = new LinkedHashMap<>();
        public final Map<Integer, List<TermHit>> termHits = new LinkedHashMap<>();
    }

    /**
     * Resolve a free-text term query within the selected ontologies and
     * expand to all active descendants (plus the matched terms themselves).
     */
    public static Set<String> expandToDescendants(OntologyXDAO xdao,
                                                  String termText,
                                                  String ontList) throws Exception {
        Set<String> result = new LinkedHashSet<>();
        if (termText == null || termText.trim().isEmpty()) return result;

        Set<String> ontIds = parseOntIds(ontList);
        if (ontIds.isEmpty()) return result;

        List<Term> matched = xdao.searchForTerms("contains", termText, false);
        if (matched == null) return result;

        for (Term t : matched) {
            if (!ontIds.contains(t.getOntologyId())) continue;
            result.add(t.getAccId());
            result.addAll(xdao.getAllActiveTermDescendantAccIds(t.getAccId()));
        }
        return result;
    }

    /**
     * Parse the GViewerBean-formatted ontology list (e.g. "'BP','MF','CC'")
     * into a Set of bare ontology ids ({"BP","MF","CC"}).
     */
    public static Set<String> parseOntIds(String ontList) {
        Set<String> set = new LinkedHashSet<>();
        if (ontList == null) return set;
        for (String part : ontList.split(",")) {
            String s = part.trim();
            if (s.length() >= 2 && s.startsWith("'") && s.endsWith("'")) {
                s = s.substring(1, s.length() - 1);
            }
            if (!s.isEmpty()) set.add(s);
        }
        return set;
    }

    /**
     * Run the ES query for one search criterion: termAcc IN (expanded set)
     * AND mapKey = ? AND objectType IN (gene,qtl,strain). Collects position
     * rows and term-level hits keyed by rgdId.
     */
    public static CriterionResult queryCriterion(Set<String> expandedAccs,
                                                 int mapKey) throws Exception {
        CriterionResult res = new CriterionResult();
        if (expandedAccs == null || expandedAccs.isEmpty()) {
            return res;
        }

        BoolQueryBuilder query = QueryBuilders.boolQuery()
                .filter(QueryBuilders.termsQuery("termAcc", expandedAccs))
                .filter(QueryBuilders.termQuery("mapKey", mapKey))
                .filter(QueryBuilders.termsQuery("objectType", SUPPORTED_OBJECT_TYPES));

        SearchSourceBuilder ssb = new SearchSourceBuilder()
                .query(query)
                .fetchSource(POSITION_SOURCE_FIELDS, null)
                .size(SCROLL_PAGE_SIZE);

        RestHighLevelClient client = ClientInit.getClient();
        TimeValue scrollKeepAlive = TimeValue.timeValueMinutes(1);
        SearchRequest req = new SearchRequest(RgdContext.getESIndexName("gviewer"))
                .source(ssb)
                .scroll(scrollKeepAlive);

        SearchResponse resp = client.search(req, RequestOptions.DEFAULT);
        String scrollId = resp.getScrollId();
        try {
            while (resp.getHits().getHits().length > 0) {
                for (SearchHit hit : resp.getHits().getHits()) {
                    Map<String, Object> src = hit.getSourceAsMap();
                    if (src == null) continue;
                    consumeHit(src, res);
                }
                SearchScrollRequest scrollReq = new SearchScrollRequest(scrollId)
                        .scroll(scrollKeepAlive);
                resp = client.scroll(scrollReq, RequestOptions.DEFAULT);
                scrollId = resp.getScrollId();
            }
        } finally {
            if (scrollId != null) {
                ClearScrollRequest clear = new ClearScrollRequest();
                clear.addScrollId(scrollId);
                try { client.clearScroll(clear, RequestOptions.DEFAULT); } catch (Exception ignored) {}
            }
        }
        return res;
    }

    private static final int SCROLL_PAGE_SIZE = 5_000;

    private static void consumeHit(Map<String, Object> src, CriterionResult res) {
        int rgdId = numAsInt(src.get("annotatedObjectRgdId"));
        if (rgdId == 0) return;

        res.rgdIds.add(rgdId);

        Row row = new Row(
                rgdId,
                asString(src.get("objectSymbol")),
                asString(src.get("objectType")),
                asString(src.get("chromosome")),
                asString(src.get("startPos")),
                asString(src.get("stopPos")));

        List<Row> rows = res.positions.computeIfAbsent(rgdId, k -> new ArrayList<>());
        if (!rows.contains(row)) rows.add(row);

        String termAcc = asString(src.get("termAcc"));
        if (!termAcc.isEmpty()) {
            List<TermHit> hits = res.termHits.computeIfAbsent(rgdId, k -> new ArrayList<>());
            for (TermHit th : hits) {
                if (th.termAcc.equals(termAcc)) return;
            }
            hits.add(new TermHit(rgdId, termAcc, asString(src.get("term"))));
        }
    }

    /**
     * Combine per-criterion rgdId sets with AND/OR/AND NOT operators,
     * matching the old SQL INTERSECT/UNION/MINUS semantics. ops[i-1] is
     * the operator that joins the result-so-far with criterion i.
     */
    public static Set<Integer> combine(List<Set<Integer>> perCriterion, String[] ops) {
        if (perCriterion.isEmpty()) return new LinkedHashSet<>();
        Set<Integer> acc = new LinkedHashSet<>(perCriterion.get(0));
        for (int i = 1; i < perCriterion.size(); i++) {
            String op = (ops != null && (i - 1) < ops.length) ? ops[i - 1] : "OR";
            Set<Integer> next = perCriterion.get(i);
            if ("AND".equals(op)) acc.retainAll(next);
            else if ("AND NOT".equals(op)) acc.removeAll(next);
            else acc.addAll(next); // OR (default)
        }
        return acc;
    }

    private static String asString(Object o) {
        return o == null ? "" : String.valueOf(o);
    }

    private static int numAsInt(Object o) {
        if (o instanceof Number) return ((Number) o).intValue();
        if (o == null) return 0;
        try { return Integer.parseInt(String.valueOf(o)); } catch (NumberFormatException e) { return 0; }
    }
}
