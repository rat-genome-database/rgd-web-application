package edu.mcw.rgd.carpenovo.vvservice;

import edu.mcw.rgd.datamodel.MappedGene;
import edu.mcw.rgd.datamodel.VariantSearchBean;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.search.elasticsearch.client.ClientInit;

import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.biojava.utils.regex.Search;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchRequestBuilder;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;
import org.elasticsearch.common.document.DocumentField;
import org.elasticsearch.common.unit.TimeValue;
import org.elasticsearch.index.query.*;
import org.elasticsearch.script.Script;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.Aggregation;
import org.elasticsearch.search.aggregations.AggregationBuilder;
import org.elasticsearch.search.aggregations.AggregationBuilders;
import org.elasticsearch.search.aggregations.BucketOrder;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

/**
 * Created by jthota on 7/10/2019.
 */
public class VVService {
    private static String variantIndex;

    public static String getVariantIndex() {
        return variantIndex;
    }

    public static void setVariantIndex(String variantIndex) {
        VVService.variantIndex = variantIndex;
    }

    public List<SearchHit> getVariants(VariantSearchBean vsb, HttpRequestFacade req){

        BoolQueryBuilder builder=this.boolQueryBuilder(vsb,req);

        SearchRequestBuilder srb = ClientInit.getClient().prepareSearch(RgdContext.getESIndexName(variantIndex))
                .setQuery(builder)
                .setSize(10000);

        if(req.getParameter("showDifferences").equals("true")){
            SearchResponse sr=srb
                    .setSearchType(SearchType.QUERY_THEN_FETCH)
                    .setRequestCache(true)
                    .setScroll(new TimeValue(60000))
                    .execute().actionGet();

                return this.excludeCommonVariants(sr, vsb);

        }else {

            SearchResponse sr = srb
                    .setSearchType(SearchType.QUERY_THEN_FETCH)
                    .setRequestCache(true)
                    .setScroll(new TimeValue(60000))
                    .execute().actionGet();
            return Arrays.asList(sr.getHits().getHits());
        }

    }
    public SearchResponse getAggregations(VariantSearchBean vsb, HttpRequestFacade req){
        BoolQueryBuilder builder=this.boolQueryBuilder(vsb,req);

        SearchRequestBuilder srb = ClientInit.getClient().prepareSearch(RgdContext.getESIndexName(variantIndex))
                .setQuery(builder)
                .setSize(0);

        if(req.getParameter("showDifferences").equals("true")){
            srb.addAggregation(this.buildAggregations("regionName"));
             return       srb
                    .setSearchType(SearchType.QUERY_THEN_FETCH)
                    .setRequestCache(true)
                    .execute().actionGet();


        }else
            srb.addAggregation(this.buildAggregations("sampleId"));
            return srb
                    .setSearchType(SearchType.QUERY_THEN_FETCH)
                    .setRequestCache(true)
                    .execute().actionGet();
    }
    public List<SearchHit> excludeCommonVariants(SearchResponse sr,VariantSearchBean vsb){
        SearchHit[] searchHits=sr.getHits().getHits();
        List<SearchHit> searchHitList= Arrays.asList(searchHits);
        List<SearchHit> nonSharedVariants=new ArrayList<>();
        List<Integer> verifiedPositions=new ArrayList<>();
        do {
            for (SearchHit hit : searchHitList) {
                List<SearchHit> tempList = new ArrayList<>();
                String chr = (String) hit.getSourceAsMap().get("chromosome");
                int startPos = (int) hit.getSourceAsMap().get("startPos");
                String varNuc = (String) hit.getSourceAsMap().get("varNuc");

                if (!verifiedPositions.contains(startPos)) {
                    verifiedPositions.add(startPos);
                    for (SearchHit h : searchHitList) {
                        String chr1 = (String) h.getSourceAsMap().get("chromosome");
                        int startPos1 = (int) h.getSourceAsMap().get("startPos");
                        String varNuc1 = (String) h.getSourceAsMap().get("varNuc");
                        if (chr1.equals(chr) && startPos1 == startPos && varNuc1.equals(varNuc)) {
                            tempList.add(h);
                        }
                    }
                    if (tempList.size() > 0 && tempList.size() < vsb.sampleIds.size()) {
                        nonSharedVariants.addAll(tempList);
                    }

                }
            }
        //    System.out.println("NON SHARED VARIANTS: "+ nonSharedVariants.size());
            sr = ClientInit.getClient().prepareSearchScroll(sr.getScrollId()).setScroll(new TimeValue(60000)).execute().actionGet();
        }while (sr.getHits().getHits().length!=0);
        return nonSharedVariants;
    }

 public AggregationBuilder buildAggregations(String fieldName){
     AggregationBuilder aggs= null;
     if(fieldName.equalsIgnoreCase("sampleId")){
         aggs= AggregationBuilders.terms(fieldName).field(fieldName).size(100)
                 .subAggregation(AggregationBuilders.terms("region").field("regionName.keyword").size(10000).missing("INTERGENIC")

                 .order(BucketOrder.key(true)));
     }
     if(fieldName.equalsIgnoreCase("regionName")){
           aggs= AggregationBuilders.terms(fieldName).field(fieldName+".keyword").size(10000).missing("INTERGENIC")
                 .subAggregation(AggregationBuilders.terms("startPos").field("startPos").size(10000)
                 .subAggregation(AggregationBuilders.terms("sample").field("sampleId"))
                 .subAggregation(AggregationBuilders.terms("varNuc").field("varNuc.keyword").size(10000))

                         .order(BucketOrder.key(true)));
     }

     return aggs;
 }
    public BoolQueryBuilder boolQueryBuilder(VariantSearchBean vsb, HttpRequestFacade req){
        BoolQueryBuilder builder=new BoolQueryBuilder();
        builder.must(this.getDisMaxQuery(vsb, req));
        List<String> synStats= new ArrayList<>();
        List<String> genicStats= new ArrayList<>();
        List<String> vTypes= new ArrayList<>();
        List<String> locs=new ArrayList<>();
        List<String> zygosity=new ArrayList<>();

        if(req.getParameter("nonSynonymous").equals("true")){ synStats.add("nonsynonymous");}
        if(req.getParameter("synonymous").equals("true")){synStats.add("synonymous");}
        if(synStats.size()>0){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termsQuery("synStatus.keyword", synStats.toArray())));
        }
        if(req.getParameter("genic").equals("true")){genicStats.add("GENIC");}
        if(req.getParameter("intergenic").equals("true")){genicStats.add("INTERGENIC");}
        if(genicStats.size()>0){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termsQuery("genicStatus.keyword", genicStats.toArray())));
        }
        if(req.getParameter("snv").equals("true")){ vTypes.add("snv");}
        if(req.getParameter("ins").equals("true")){ vTypes.add("ins");}
        if(req.getParameter("del").equals("true")){ vTypes.add("del");}
        if(vTypes.size()>0){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termsQuery("variantType.keyword", vTypes.toArray())));
        }
        if(req.getParameter("intron").equals("true")){locs.add("INTRON");}
        if(req.getParameter("3prime").equals("true")){locs.add("3UTRS"); }
        if(req.getParameter("5prime").equals("true")){locs.add("5UTRS"); }
        if(locs.size()>0){
            BoolQueryBuilder qb=new BoolQueryBuilder();
            for(String l:locs){
                qb.should(QueryBuilders.matchQuery("locationName", l));
            }
            builder.filter(qb);
        }
        if(req.getParameter("nearSpliceSite").equals("true")){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.existsQuery("nearSpliceSite.keyword")));
        }
        if(req.getParameter("proteinCoding").equals("true")){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.existsQuery("refAA")));
        }
        if(req.getParameter("frameshift").equals("true")){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.existsQuery("frameShift.keyword")));
        }
        List<String> pPredictions=new ArrayList<>();
        if(req.getParameter("benign").equals("true")){pPredictions.add("benign");}
        if(req.getParameter("possibly").equals("true")){pPredictions.add("possibly damaging");}
        if(req.getParameter("probably").equals("true")){pPredictions.add("probably damaging");}
        if(pPredictions.size()>0){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termsQuery("polyphenPrediction.keyword", pPredictions.toArray())));
        }

        /***************************zygosity************************************/
        if(req.getParameter("het").equals("true")){
            zygosity.add("heterozygous");
        }
        if(req.getParameter("hom").equals("true")){
            zygosity.add("homozygous");
        }
        if(req.getParameter("possiblyHom").equals("true")){
            zygosity.add("possibly homozygous");
        }
        if(zygosity.size()>0){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termsQuery("zygosityStatus.keyword", zygosity.toArray())));
        }
        if(req.getParameter("excludePossibleError").equals("true")){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("zygosityPossError.keyword","N")));
        }
        if(req.getParameter("hetDiffFromRef").equals("true")){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("zygosityRefAllele.keyword","N")));
        }
        /**************************************LIMIT TO**********************************************/

        if(req.getParameter("prematureStopCodon").equals("true")){
            builder
                   .filter(QueryBuilders.boolQuery().must(QueryBuilders.scriptQuery(new Script("doc['refAA.keyword'].value != doc['varAA.keyword'].value")))
                .filter(QueryBuilders.termQuery("varAA.keyword", "*"))
           );
        }

        if(req.getParameter("readthroughMutation").equals("true")){
            builder
                    .filter(QueryBuilders.boolQuery().must(QueryBuilders.scriptQuery(new Script("doc['refAA.keyword'].value != doc['varAA.keyword'].value")))
                            .filter(QueryBuilders.termQuery("refAA.keyword", "*"))
                    );
        }
        return builder;
    }
    public QueryBuilder getDisMaxQuery(VariantSearchBean vsb, HttpRequestFacade req){
        DisMaxQueryBuilder dqb=new DisMaxQueryBuilder();
        List<Integer> sampleIds=vsb.getSampleIds();
        String chromosome=vsb.getChromosome();
        BoolQueryBuilder qb=
                (QueryBuilders.boolQuery().must(QueryBuilders.matchAllQuery()));
        if(vsb.getChromosome()!=null){
           qb.filter(QueryBuilders.matchQuery("chromosome", chromosome));
        }
        if(sampleIds!=null && sampleIds.size()>0){
            qb.filter(QueryBuilders.termsQuery("sampleId", sampleIds.toArray()));
        }
        if(vsb.getStartPosition()!=null && vsb.getStartPosition()>=0 && vsb.getStopPosition()!=null && vsb.getStopPosition()>0){
            qb.filter(QueryBuilders.rangeQuery("startPos").from(vsb.getStartPosition()).to(vsb.getStopPosition()).includeLower(true).includeUpper(true));
        }
         if(!req.getParameter("geneList").equals("") && !req.getParameter("geneList").contains("|")){
            List<String> symbols= new ArrayList<>();
             for(String s:Utils.symbolSplit(req.getParameter("geneList"))){
                 symbols.add(s.toLowerCase());
             }
         //    System.out.println("SYMBOLS SIZE:"+symbols.size());
             if(!symbols.get(0).equals("null"))
           qb.filter(QueryBuilders.termsQuery("regionNameLc.keyword", symbols.toArray()));
        /*     for(String l:symbols){
                 qb.filter(QueryBuilders.matchQuery("regionName", l));
             }*/

        }
       /* if(req.getParameter("showDifferences").equals("true")){
            qb.filter();
        }*/

        dqb.add(qb);
        return dqb;

    }
}
