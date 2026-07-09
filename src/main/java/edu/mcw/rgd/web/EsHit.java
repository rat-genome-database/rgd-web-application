package edu.mcw.rgd.web;

import java.util.List;
import java.util.Map;

// Adapter that exposes getSourceAsMap() / getHighlightFields() so JSPs written
// for the legacy 7.x org.elasticsearch.search.SearchHit continue to work after
// the migration to the typed co.elastic.clients.elasticsearch.ElasticsearchClient.
public class EsHit {
    private final String id;
    private final Map<String, Object> sourceAsMap;
    private final Map<String, List<String>> highlightFields;

    public EsHit(String id, Map<String, Object> sourceAsMap) {
        this(id, sourceAsMap, Map.of());
    }

    public EsHit(String id, Map<String, Object> sourceAsMap, Map<String, List<String>> highlightFields) {
        this.id = id;
        this.sourceAsMap = sourceAsMap;
        this.highlightFields = (highlightFields != null) ? highlightFields : Map.of();
    }

    public String getId() { return id; }
    public Map<String, Object> getSourceAsMap() { return sourceAsMap; }
    public Map<String, List<String>> getHighlightFields() { return highlightFields; }
}
