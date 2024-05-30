package edu.mcw.rgd.phenominer.elasticsearch.service;




import com.google.gson.Gson;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.vv.VVException;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.ml.job.results.Bucket;
import org.elasticsearch.core.TimeValue;
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
    private static int speciesTypeKey=3;
    public static void setPhenominerIndex(String phenominerIndex) {
        PhenominerService.phenominerIndex = phenominerIndex;
    }


    public SearchResponse getSearchResponse(HttpRequestFacade req, Map<String,String> filterMap) throws VVException, IOException {


        BoolQueryBuilder builder=this.boolQueryBuilder(req, filterMap);
        if(req.getParameter("species")!=null && !req.getParameter("species").equals(""))
            speciesTypeKey= Integer.parseInt(req.getParameter("species"));
        SearchSourceBuilder srb=new SearchSourceBuilder();
        srb.query(builder);
        srb.size(10000);
        srb.aggregation(this.buildAggregations("cmoTermWithUnits"));
        srb.aggregation(this.buildAggregations("cmoTerm"));
        srb.aggregation(this.buildAggregations("mmoTerm"));
        srb.aggregation(this.buildAggregations("rsTerm"));
        srb.aggregation(this.buildAggregations("xcoTerm"));
        srb.aggregation(this.buildAggregations("vtTerm"));
        srb.aggregation(this.buildAggregations("sex"));
        srb.aggregation(this.buildAggregations("units"));
        SearchRequest searchRequest=new SearchRequest(phenominerIndex);
        searchRequest.source(srb);
     //   searchRequest.scroll(TimeValue.timeValueMinutes(1L));
        return ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);

    }
    public AggregationBuilder buildAggregations(String fieldName){
        //System.out.println("SPECIES TYPE KEY IN AGGS:" + speciesTypeKey);
        AggregationBuilder aggs= null;
        if(fieldName.equalsIgnoreCase("units")){
            aggs= AggregationBuilders.terms(fieldName).field(fieldName+".keyword")
                    .size(1000).order(BucketOrder.key(true))
                    .subAggregation(AggregationBuilders.terms("experimentName").field("experimentName.keyword")
                            .subAggregation(AggregationBuilders.terms("cmoTerm").field("cmoTerm.keyword"))
                   );
        }else
            if(fieldName.equalsIgnoreCase("rsTerm") && speciesTypeKey==3){
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
        Map<String, List<String>> termsMap=getSegregatedTerms(req);
        if(termsMap.get("CMO")!=null)
        builder.filter(QueryBuilders.termsQuery("cmoTermAcc.keyword",termsMap.get("CMO")));
        if(termsMap.get("MMO")!=null)
               builder.filter(QueryBuilders.termsQuery("mmoTermAcc.keyword", termsMap.get("MMO")));
        if(termsMap.get("RS")!=null)
                builder.filter(QueryBuilders.termsQuery("rsTermAcc.keyword", termsMap.get("RS")));
        if(termsMap.get("XCO")!=null)
                builder.filter(QueryBuilders.termsQuery("xcoTermAcc.keyword", termsMap.get("XCO"))
               );
        if(termsMap.get("VT")!=null)
            builder.filter(QueryBuilders.boolQuery().should(QueryBuilders.termsQuery("vtTermAcc.keyword", termsMap.get("VT")))
                    .should(QueryBuilders.termsQuery("vtTerm2Acc.keyword", termsMap.get("VT")))
                    .should(QueryBuilders.termsQuery("vtTerm3Acc.keyword", termsMap.get("VT"))));

        if(filterMap!=null && filterMap.size()>0)
            for(String key:filterMap.keySet()){
              /*  if(key.equalsIgnoreCase("cmoTerm")){
                  //  builder.filter(QueryBuilders.termsQuery("cmoTermWithUnits.keyword", filterMap.get(key).split(",")));
                }else*/
               builder.filter(QueryBuilders.termsQuery(key+".keyword", filterMap.get(key).split(",")));
            }

            if(speciesTypeKey>0){
                builder.filter(QueryBuilders.termQuery("speciesTypeKey", speciesTypeKey));

            }
       // System.out.println(builder);
        return builder;
    }
    public Map<String, List<String>> getSegregatedTerms(HttpRequestFacade req){
        Map<String, List<String>> segregatedTermsMap=new HashMap<>();
        List<String> terms= Arrays.asList(req.getParameter("terms").split(","));
        for(String term:terms){
            if(term.contains("CMO")){
                List<String> cmoTerms=segregatedTermsMap.get("CMO");
                if(cmoTerms==null) {
                    cmoTerms=new ArrayList<>();
                }
                cmoTerms.add(term);
                segregatedTermsMap.put("CMO", cmoTerms);
            }
            if(term.contains("XCO")){
                List<String> xcoTerms=segregatedTermsMap.get("XCO");
                if(xcoTerms==null) {
                    xcoTerms=new ArrayList<>();
                }
                xcoTerms.add(term);
                segregatedTermsMap.put("XCO", xcoTerms);
            }
            if(term.contains("MMO")){
                List<String> mmoTerms=segregatedTermsMap.get("MMO");
                if(mmoTerms==null) {
                    mmoTerms=new ArrayList<>();
                }
                mmoTerms.add(term);
                segregatedTermsMap.put("MMO", mmoTerms);
            }
            if(term.contains("VT")){
                List<String> vtTerms=segregatedTermsMap.get("VT");
                if(vtTerms==null) {
                    vtTerms=new ArrayList<>();
                }
                vtTerms.add(term);
                segregatedTermsMap.put("VT", vtTerms);
            }
            if(term.contains("RS") || term.contains("CS")){
                List<String> rsTerms=segregatedTermsMap.get("RS");
                if(rsTerms==null) {
                    rsTerms=new ArrayList<>();
                }
                rsTerms.add(term);
                segregatedTermsMap.put("RS", rsTerms);
            }

        }
      //  Gson gson=new Gson();
      //  System.out.println("TERMS MAP:"+ gson.toJson(segregatedTermsMap));
        return segregatedTermsMap;
    }
    public QueryBuilder getDisMaxQuery( HttpRequestFacade req){
        DisMaxQueryBuilder dqb=new DisMaxQueryBuilder();
        if(req.getParameter("refRgdId")!=null && !req.getParameter("refRgdId").equals("") && Integer.parseInt(req.getParameter("refRgdId"))>0){
            dqb.add(QueryBuilders.termQuery("refRgdId", Integer.parseInt(req.getParameter("refRgdId"))));

        }else {
            dqb.add(QueryBuilders.termsQuery("cmoTermAcc.keyword", req.getParameter("terms").split(",")));
            dqb.add(QueryBuilders.termsQuery("mmoTermAcc.keyword", req.getParameter("terms").split(",")));
            dqb.add(QueryBuilders.termsQuery("rsTermAcc.keyword", req.getParameter("terms").split(",")));
            dqb.add(QueryBuilders.termsQuery("xcoTermAcc.keyword", req.getParameter("terms").split(",")));
            dqb.add(QueryBuilders.termsQuery("xcoTerm.keyword", req.getParameter("terms").split(",")));
            dqb.add(QueryBuilders.boolQuery().should(QueryBuilders.termsQuery("vtTermAcc.keyword", req.getParameter("terms").split(",")))
                    .should(QueryBuilders.termsQuery("vtTerm2Acc.keyword", req.getParameter("terms").split(",")))
                    .should(QueryBuilders.termsQuery("vtTerm3Acc.keyword",req.getParameter("terms").split(","))));

        }
        return dqb;

    }
    public java.util.Map<String, List<Terms.Bucket>> getAggregationsBeforeFilters(HttpRequestFacade req) throws IOException, VVException {
        SearchResponse sr= getSearchResponse(req, null);
        return getSearchAggregations(sr);
    }
    public java.util.Map<String, List<Terms.Bucket>> getSearchAggregations(SearchResponse sr){
        java.util.Map<String, List<Terms.Bucket>> aggregations=new HashMap<>();
        if(sr!=null && sr.getAggregations()!=null) {
            Terms cmoAggs = sr.getAggregations().get("cmoTerm");
            if (cmoAggs != null) {
                aggregations.put("cmoTermBkts", (List<Terms.Bucket>) cmoAggs.getBuckets());
//                for (Terms.Bucket bkt : cmoAggs.getBuckets()) {
//                    //   System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
//                }
            }
       /*     Terms cmoAggs=sr.getAggregations().get("cmoTermWithUnits");
            if(cmoAggs!=null){
                aggregations.put("cmoTermBkts", (List<Terms.Bucket>) cmoAggs.getBuckets());
                for(Terms.Bucket bkt:cmoAggs.getBuckets()){
                //    System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
                }}*/
            Terms mmoAggs = sr.getAggregations().get("mmoTerm");
            if (mmoAggs != null) {
                aggregations.put("mmoTermBkts", (List<Terms.Bucket>) mmoAggs.getBuckets());
//                for (Terms.Bucket bkt : mmoAggs.getBuckets()) {
//                    //   System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
//                }
            }
            Terms vtAggs = sr.getAggregations().get("vtTerm");
            if (vtAggs != null) {
                aggregations.put("vtTermBkts", (List<Terms.Bucket>) vtAggs.getBuckets());
//                for (Terms.Bucket bkt : vtAggs.getBuckets()) {
//                    //   System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
//                }
            }
            Terms xcoAggs = sr.getAggregations().get("xcoTerm");
            if (xcoAggs != null) {
                aggregations.put("xcoTermBkts", (List<Terms.Bucket>) xcoAggs.getBuckets());
//                for (Terms.Bucket bkt : xcoAggs.getBuckets()) {
//                    // System.out.println(bkt.getKey()+"\t"+bkt.getDocCount());
//                }
            }
            Terms rsTopLevelTerm = sr.getAggregations().get("rsTopLevelTerm");
            if (rsTopLevelTerm != null) {
                aggregations.put("rsTermBkts", (List<Terms.Bucket>) rsTopLevelTerm.getBuckets());

            }
            if (speciesTypeKey == 4){
                Terms rsTermAggs = sr.getAggregations().get("rsTerm");
            if (rsTermAggs != null) {
                aggregations.put("rsTerms", (List<Terms.Bucket>) rsTermAggs.getBuckets());
//                for (Terms.Bucket bkt : rsTermAggs.getBuckets()) {
//                   //System.out.println("CHINCHILLA:"+bkt.getKey()+"\t"+bkt.getDocCount());
//                }
            }
        }
        Terms sexAggs=sr.getAggregations().get("sex");
        if(sexAggs!=null){
        aggregations.put("sexBkts", (List<Terms.Bucket>) sexAggs.getBuckets());
        }
        Terms unitsAggs=sr.getAggregations().get("units");
        if(unitsAggs!=null) {
            aggregations.put("unitBkts", (List<Terms.Bucket>) unitsAggs.getBuckets());
            List<Terms.Bucket> unitsSubBkts=new ArrayList<>();
//            for (Terms.Bucket bkt : unitsAggs.getBuckets()) {
//               // System.out.println(bkt.getKey() + "\t" + bkt.getDocCount());
//                Terms unitsSubAggs=bkt.getAggregations().get("experimentName");
//                for(Terms.Bucket subBkt:unitsSubAggs.getBuckets()){
//                   //System.out.println(subBkt.getKey()+"\t"+ subBkt.getDocCount());
//                 //   unitsSubBkts.add(subBkt);
//                }
//            }
            aggregations.put("cmoTermBkts", unitsSubBkts);
        }}
        return aggregations;
    }

    public java.util.Map<String, List<Terms.Bucket>> getFilteredAggregations(Map<String, String> filterMap, HttpRequestFacade req) throws IOException, VVException {
        SearchResponse sr=null;
      /*  if(filterMap.size()==1 || (filterMap.size()==2 && filterMap.get("experimentName")!=null)){
         sr= getSearchResponse(req, null);
        }else{
             sr= getSearchResponse(req, filterMap);
        }*/
        SearchSourceBuilder srb=new SearchSourceBuilder();
        if(filterMap.size()==1 || (filterMap.size()==2 && filterMap.containsKey("experimentName")) ) {
            srb.query(this.boolQueryBuilder(req, null));
            //   srb.aggregation(this.buildSearchAggregations("category", category));
           String  filterField=filterMap.entrySet().iterator().next().getKey();
            if(filterField.equalsIgnoreCase("cmoTerm"))
            srb.aggregation(this.buildAggregations("units"));
            else
                srb.aggregation(this.buildAggregations(filterField));
        }

        //   srb.highlighter(this.buildHighlights());
        srb.size(0);
        //  SearchRequest searchRequest=new SearchRequest("scge_search_test");
        SearchRequest searchRequest=new SearchRequest(phenominerIndex);
        searchRequest.source(srb);

        sr= ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);

        return getSearchAggregations(sr);

    }
}
