package edu.mcw.rgd.web;

import java.util.List;
import java.util.Map;

// JSP-friendly snapshot of a terms aggregation bucket. The typed client returns
// StringTermsBucket/etc. whose accessors are key()/docCount() — incompatible
// with JSP EL which calls bean-style getters. This adapter preserves the old
// getKey()/getDocCount() surface so JSPs render unchanged.
public class EsBucket {
    private final String key;
    private final long docCount;
    private final Map<String, List<EsBucket>> subAggregations;

    public EsBucket(String key, long docCount) {
        this(key, docCount, Map.of());
    }

    public EsBucket(String key, long docCount, Map<String, List<EsBucket>> subAggregations) {
        this.key = key;
        this.docCount = docCount;
        this.subAggregations = subAggregations;
    }

    public String getKey() { return key; }
    public String getKeyAsString() { return key; }
    public long getDocCount() { return docCount; }
    public Map<String, List<EsBucket>> getSubAggregations() { return subAggregations; }

    @Override
    public String toString() { return key; }
}
