package edu.mcw.rgd.phenominer.elasticsearch.service;




import edu.mcw.rgd.search.elasticsearch.client.ClientInit;
import edu.mcw.rgd.vv.VVException;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.ml.job.results.Bucket;
import org.elasticsearch.common.unit.TimeValue;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.DisMaxQueryBuilder;
import org.elasticsearch.index.query.QueryBuilder;

import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.aggregations.AggregationBuilder;

import org.elasticsearch.search.aggregations.AggregationBuilders;
import org.elasticsearch.search.aggregations.BucketOrder;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.elasticsearch.search.builder.SearchSourceBuilder;

import java.io.IOException;

import java.util.*;

public class PhenominerService {
    private static String phenominerIndex;

    public static void setPhenominerIndex(String phenominerIndex) {
        PhenominerService.phenominerIndex = phenominerIndex;
    }


    public SearchResponse getSearchResponse(HttpRequestFacade req, Map<String,String> filterMap) throws VVException, IOException {

        BoolQueryBuilder builder=this.boolQueryBuilder(req, filterMap);
        SearchSourceBuilder srb=new SearchSourceBuilder();
        srb.query(builder);
        srb.size(10000);
        srb.aggregation(this.buildAggregations("cmoTermWithUnits"));
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
        if(fieldName.equalsIgnoreCase("units")){
            aggs= AggregationBuilders.terms(fieldName).field(fieldName+".keyword")
                    .size(1000).order(BucketOrder.key(true))
                    .subAggregation(AggregationBuilders.terms("experimentName").field("experimentName.keyword")
                            .subAggregation(AggregationBuilders.terms("cmoTerm").field("cmoTerm.keyword"))
                   );
        }else
            if(fieldName.equalsIgnoreCase("rsTerm")){
                aggs= AggregationBuilders.terms("rsTopLevelTerm").field("rsTopLevelTerm"+".keyword")
                        .size(1000).order(BucketOrder.key(true))
                                .subAggregation(AggregationBuilders.terms(fieldName).field(fieldName+".keyword"));
            }else
            aggs= AggregationBuilders.terms(fieldName).field(fieldName+".keyword")
                    .size(1000).order(BucketOrder.key(true));


        return aggs;
    }
    public BoolQueryBuilder boolQueryBuilder(HttpRequestFacade req, Map<String, String> filterMap){
        BoolQueryBuilder builder=new BoolQueryBuilder();
        builder.must(this.getDisMaxQuery( req));
        if(filterMap!=null && filterMap.size()>0)
            for(String key:filterMap.keySet()){
              /*  if(key.equalsIgnoreCase("cmoTerm")){
                  //  builder.filter(QueryBuilders.termsQuery("cmoTermWithUnits.keyword", filterMap.get(key).split(",")));
                }else*/
               builder.filter(QueryBuilders.termsQuery(key+".keyword", filterMap.get(key).split(",")));
            }
        System.out.println(builder);
        return builder;
    }
    public QueryBuilder getDisMaxQuery( HttpRequestFacade req){
        System.out.println();
        DisMaxQueryBuilder dqb=new DisMaxQueryBuilder();
        dqb.add(QueryBuilders.termsQuery("cmoTermAcc.keyword", req.getParameter("terms").split(",")));
        dqb.add(QueryBuilders.termsQuery("mmoTermAcc.keyword", req.getParameter("terms").split(",")));
        dqb.add(QueryBuilders.termsQuery("rsTermAcc.keyword", req.getParameter("terms").split(",")));
        dqb.add(QueryBuilders.termsQuery("xcoTermAcc.keyword", req.getParameter("terms").split(",")));
        return dqb;

    }
    public java.util.Map<String, List<Terms.Bucket>> getAggregationsBeforeFilters(HttpRequestFacade req) throws IOException, VVException {
        SearchResponse sr= getSearchResponse(req, null);
        return getSearchAggregations(sr);
    }
    public java.util.Map<String, List<Terms.Bucket>> getSearchAggregations(SearchResponse sr){
        java.util.Map<String, List<Terms.Bucket>> aggregations=new HashMap<>();
        if(sr!=null && sr.getAggregations()!=null){
        Terms cmoAggs=sr.getAggregations().get("cmoTerm");
        if(cmoAggs!=null){
        aggregations.put("cmoTermBkts", (List<Terms.Bucket>) cmoAggs.getBuckets());
        for(Terms.Bucket bkt:cmoAggs.getBuckets()){
         //   System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
        }}
       /*     Terms cmoAggs=sr.getAggregations().get("cmoTermWithUnits");
            if(cmoAggs!=null){
                aggregations.put("cmoTermBkts", (List<Terms.Bucket>) cmoAggs.getBuckets());
                for(Terms.Bucket bkt:cmoAggs.getBuckets()){
                //    System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
                }}*/
        Terms mmoAggs=sr.getAggregations().get("mmoTerm");
        if(mmoAggs!=null){
        aggregations.put("mmoTermBkts", (List<Terms.Bucket>) mmoAggs.getBuckets());
        for(Terms.Bucket bkt:mmoAggs.getBuckets()){
         //   System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
        }}
        Terms xcoAggs=sr.getAggregations().get("xcoTerm");
        if(xcoAggs!=null){
        aggregations.put("xcoTermBkts", (List<Terms.Bucket>) xcoAggs.getBuckets());
        for(Terms.Bucket bkt:xcoAggs.getBuckets()){
           // System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
        }}
        Terms rsTopLevelTerm=sr.getAggregations().get("rsTopLevelTerm");
            if (rsTopLevelTerm != null) {
                aggregations.put("rsTermBkts", (List<Terms.Bucket>) rsTopLevelTerm.getBuckets());

            }

    /*    Terms rsTermAggs=sr.getAggregations().get("rsTerm");
        if(rsTermAggs!=null){
        aggregations.put("rsTermBkts", (List<Terms.Bucket>) rsTermAggs.getBuckets());
        for(Terms.Bucket bkt:rsTermAggs.getBuckets()){
          //  System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
        }}*/
        Terms sexAggs=sr.getAggregations().get("sex");
        if(sexAggs!=null){
        aggregations.put("sexBkts", (List<Terms.Bucket>) sexAggs.getBuckets());
        for(Terms.Bucket bkt:sexAggs.getBuckets()){
           // System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
        }}
        Terms unitsAggs=sr.getAggregations().get("units");
        if(unitsAggs!=null) {
            aggregations.put("unitBkts", (List<Terms.Bucket>) unitsAggs.getBuckets());
            List<Terms.Bucket> unitsSubBkts=new ArrayList<>();
            for (Terms.Bucket bkt : unitsAggs.getBuckets()) {
               // System.out.println(bkt.getKey() + "\t" + bkt.getDocCount());
                Terms unitsSubAggs=bkt.getAggregations().get("experimentName");
                for(Terms.Bucket subBkt:unitsSubAggs.getBuckets()){
                   System.out.println(subBkt.getKey()+"\t"+ subBkt.getDocCount());
                 //   unitsSubBkts.add(subBkt);
                }
            }
            aggregations.put("cmoTermBkts", unitsSubBkts);
        }}
        return aggregations;
    }

    public java.util.Map<String, List<Terms.Bucket>> getFilteredAggregations(Map<String, String> filterMap, HttpRequestFacade req) throws IOException, VVException {

        SearchResponse sr= getSearchResponse(req, filterMap);
        return getSearchAggregations(sr);

    }
}