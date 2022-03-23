package edu.mcw.rgd.phenominer.elasticsearch.service;


import com.google.gson.Gson;
import edu.mcw.rgd.datamodel.*;

import edu.mcw.rgd.search.elasticsearch.client.ClientInit;
import edu.mcw.rgd.vv.VVException;
import edu.mcw.rgd.vv.vvservice.VVService;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchScrollRequest;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.common.unit.TimeValue;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.DisMaxQueryBuilder;
import org.elasticsearch.index.query.QueryBuilder;

import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.AggregationBuilder;

import org.elasticsearch.search.aggregations.AggregationBuilders;
import org.elasticsearch.search.aggregations.BucketOrder;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.elasticsearch.search.builder.SearchSourceBuilder;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class PhenominerService {
    private static String phenominerIndex;
    public static String getPhenominerIndex() {
        return phenominerIndex;
    }

    public static void setPhenominerIndex(String phenominerIndex) {
        PhenominerService.phenominerIndex = phenominerIndex;
    }


    public SearchResponse getSearchResponse(HttpRequestFacade req) throws VVException, IOException {

        BoolQueryBuilder builder=this.boolQueryBuilder(req);
        SearchSourceBuilder srb=new SearchSourceBuilder();
        srb.query(builder);
        srb.size(10000);
        srb.aggregation(this.buildAggregations("cmoTerm"));
        srb.aggregation(this.buildAggregations("mmoTerm"));
        srb.aggregation(this.buildAggregations("rsTerm"));
        srb.aggregation(this.buildAggregations("xcoTerm"));
        srb.aggregation(this.buildAggregations("sex"));
        srb.aggregation(this.buildAggregations("units"));
        SearchRequest searchRequest=new SearchRequest(phenominerIndex);
        searchRequest.source(srb);
        searchRequest.scroll(TimeValue.timeValueMinutes(1L));
        return ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);

    }




    public AggregationBuilder buildAggregations(String fieldName){
        AggregationBuilder aggs= null;

            aggs= AggregationBuilders.terms(fieldName).field(fieldName+".keyword")
                    .size(1000).order(BucketOrder.key(true));


        return aggs;
    }
    public BoolQueryBuilder boolQueryBuilder(HttpRequestFacade req){
        BoolQueryBuilder builder=new BoolQueryBuilder();
        builder.must(this.getDisMaxQuery( req));

        return builder;
    }
    public QueryBuilder getDisMaxQuery( HttpRequestFacade req){

        DisMaxQueryBuilder dqb=new DisMaxQueryBuilder();
        dqb.add(QueryBuilders.matchAllQuery());
        return dqb;

    }
    public java.util.Map<String, List<Terms.Bucket>> getSearchAggregations(SearchResponse sr){
        java.util.Map<String, List<Terms.Bucket>> aggregations=new HashMap<>();
        Terms cmoAggs=sr.getAggregations().get("cmoTerm");
        aggregations.put("cmoTermBkts", (List<Terms.Bucket>) cmoAggs.getBuckets());
        for(Terms.Bucket bkt:cmoAggs.getBuckets()){
            System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
        }
        Terms mmoAggs=sr.getAggregations().get("mmoTerm");
        aggregations.put("mmoTermBkts", (List<Terms.Bucket>) mmoAggs.getBuckets());
        for(Terms.Bucket bkt:mmoAggs.getBuckets()){
            System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
        }
        Terms xcoAggs=sr.getAggregations().get("xcoTerm");
        aggregations.put("xcoTermBkts", (List<Terms.Bucket>) xcoAggs.getBuckets());
        for(Terms.Bucket bkt:xcoAggs.getBuckets()){
            System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
        }
        Terms rsTermAggs=sr.getAggregations().get("rsTerm");
        aggregations.put("rsTermBkts", (List<Terms.Bucket>) rsTermAggs.getBuckets());
        for(Terms.Bucket bkt:rsTermAggs.getBuckets()){
            System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
        }
        Terms sexAggs=sr.getAggregations().get("sex");
        aggregations.put("sexBkts", (List<Terms.Bucket>) sexAggs.getBuckets());
        for(Terms.Bucket bkt:sexAggs.getBuckets()){
            System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
        }
        Terms unitsAggs=sr.getAggregations().get("units");
        aggregations.put("unitBkts", (List<Terms.Bucket>) unitsAggs.getBuckets());
        for(Terms.Bucket bkt:unitsAggs.getBuckets()){
            System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
        }
        Gson gson=new Gson();
        System.out.println(gson.toJson(aggregations));
        return aggregations;
    }


}
