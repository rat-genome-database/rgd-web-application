package edu.mcw.rgd.search.elasticsearch1.model;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by jthota on 8/10/2017.
 */
public  class SortMap {
    private static Map<String, Sort> sortMap;
    static {
        Map<String, Sort> map=new HashMap<>();
        map.put("0", new Sort("relevance", "desc") );
        map.put("1", new Sort("symbol", "asc") );
        map.put("2", new Sort("symbol", "desc") );
        map.put("3", new Sort("chromosome", "asc") );
        map.put("4", new Sort("chromosome", "desc") );

        map.put("5", new Sort("startPos", "asc") );
        map.put("6", new Sort("startPos", "desc") );
        map.put("7", new Sort("stopPos", "asc") );
        map.put("8", new Sort("stopPos", "desc") );
        sortMap= Collections.unmodifiableMap(map);
    }

    public static Map<String, Sort> getSortMap() {
        return sortMap;
    }

    public static void setSortMap(Map<String, Sort> sortMap) {
        SortMap.sortMap = sortMap;
    }
}
