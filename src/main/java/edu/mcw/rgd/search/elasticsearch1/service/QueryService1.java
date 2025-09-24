package edu.mcw.rgd.search.elasticsearch1.service;


import edu.mcw.rgd.search.elasticsearch1.model.SearchBean;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.apache.lucene.search.join.ScoreMode;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchRequestBuilder;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.index.query.*;
import org.elasticsearch.search.aggregations.AggregationBuilder;
import org.elasticsearch.search.aggregations.AggregationBuilders;
import org.elasticsearch.search.aggregations.BucketOrder;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.elasticsearch.search.fetch.subphase.highlight.HighlightBuilder;
import org.elasticsearch.search.sort.NestedSortBuilder;
import org.elasticsearch.search.sort.SortBuilders;
import org.elasticsearch.search.sort.SortOrder;

import java.io.IOException;
import java.net.UnknownHostException;
import java.util.*;


/**
 * Created by jthota on 3/27/2017.
 */
public class QueryService1 {

    private boolean sort;


    public QueryService1() throws UnknownHostException {
        this.sort=true;
    }


    public SearchResponse getSearchResponse(String term, SearchBean sb) throws IOException {
        BoolQueryBuilder builder=this.boolQueryBuilder(term,sb);
        String sortField=null;
        SearchSourceBuilder srb=new SearchSourceBuilder();
        srb.query(builder);
        if(sb != null) {
            if (sb.getSortBy().equalsIgnoreCase("relevance") && !sb.getCategory().equalsIgnoreCase("variant")) {
                srb.sort(SortBuilders.scoreSort().order(SortOrder.DESC));
            } else {
                if (sb.getSortBy().equalsIgnoreCase("symbol")) {
                    sortField = sb.getSortBy() + ".keyword";
                    if (sb.getSortOrder().equalsIgnoreCase("asc")) {
                        srb.sort(SortBuilders.fieldSort(sortField).missing("_last").order(SortOrder.ASC));
                    } else {
                        srb.sort(SortBuilders.fieldSort(sortField).missing("_last").order(SortOrder.DESC));
                    }
                } else {
                    if (sb.getCategory().equalsIgnoreCase("variant")) {
                        sortField = "mapDataList.rank";
                        srb.sort(SortBuilders.fieldSort(sortField).missing("_last").order(SortOrder.ASC).setNestedSort(new NestedSortBuilder("mapDataList")));

                    } else {
                        sortField = "mapDataList." + sb.getSortBy();
                        if (sb.getSortOrder().equalsIgnoreCase("asc")) {
                            srb.sort(SortBuilders.fieldSort(sortField).missing("_last").order(SortOrder.ASC).setNestedSort(new NestedSortBuilder("mapDataList")));
                        } else {
                            srb.sort(SortBuilders.fieldSort(sortField).missing("_last").order(SortOrder.DESC).setNestedSort(new NestedSortBuilder("mapDataList")));
                        }
                    }
                }

            }

            List<String> aggFields = new ArrayList<>(Arrays.asList("species", "category", "type", "trait", "assembly"));

            if (!sb.isPage()) {

                for (String field : aggFields) {
                    AggregationBuilder aggs = this.buildAggregations(field);
                    if (aggs != null)
                        srb.aggregation(aggs);
                }
            }

            srb
                    .highlighter(this.buildHighlights())
                    .from(sb.getFrom())
                    .size(sb.getSize());

            if (!Objects.equals(sb.getSpecies(), "") && !sb.getCategory().equalsIgnoreCase("general")) {
                if (sb.getType() != null && !Objects.equals(sb.getType(), "")) {
                    if (!Objects.equals(sb.getType(), "null")) {
                        srb.postFilter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("species.keyword", sb.getSpecies())).filter(QueryBuilders.termQuery("category.keyword", sb.getCategory())).filter(QueryBuilders.termQuery("type.keyword", sb.getType())));
                    }

                }
                if (!sb.getTrait().equals("")) {
                    srb.postFilter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("species.keyword", sb.getSpecies())).filter(QueryBuilders.termQuery("category.keyword", sb.getCategory())).filter(QueryBuilders.termQuery("trait.keyword", sb.getTrait())));
                }
                if (sb.getType() != null && sb.getType().equals("") && sb.getTrait().equalsIgnoreCase("")) {
                    srb.postFilter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("species.keyword", sb.getSpecies())).filter(QueryBuilders.termQuery("category.keyword", sb.getCategory())));
                }
            } else {
                if (!Objects.equals(sb.getSpecies(), "")) {
                    srb.postFilter(QueryBuilders.termQuery("species.keyword", sb.getSpecies()));

                }
                if (!sb.getCategory().equalsIgnoreCase("general") && !sb.getCategory().equals("")) {
                    if (sb.getCategory().equalsIgnoreCase(("Ontology"))) {

                        if (sb.getSubCat() != null && sb.getSubCat() != "") {
                            srb.postFilter((QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("category.keyword", sb.getCategory())).filter(QueryBuilders.termQuery("subcat.keyword", sb.getSubCat()))));
                        } else {
                            srb.postFilter((QueryBuilders.termQuery("category.keyword", sb.getCategory())));
                        }
                    } else
                        srb.postFilter((QueryBuilders.termQuery("category.keyword", sb.getCategory())));

                }

            }
        }
        SearchRequest searchRequest=new SearchRequest(RgdContext.getESIndexName("search"));
        searchRequest.source(srb);
        SearchResponse sr= ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
        return sr;
    }

    public BoolQueryBuilder boolQueryBuilder(String term, SearchBean sb){
        BoolQueryBuilder builder=new BoolQueryBuilder();
        builder.must(this.getDisMaxQuery(term, sb));
        if(sb!=null) {
            if (!sb.getCategory().equalsIgnoreCase("general") && !sb.getCategory().equalsIgnoreCase("")) {
                builder.filter(QueryBuilders.termQuery("category.keyword", sb.getCategory()));
            }
            if (sb.getSpecies() != null && !sb.getSpecies().equals("")) {
                builder.filter(QueryBuilders.termQuery("species.keyword", sb.getSpecies()));
            }
            if(sb.getAssembly()!=null && !sb.getAssembly().equals("") && !sb.getAssembly().equalsIgnoreCase("all")) {
                builder.filter(QueryBuilders.nestedQuery("mapDataList", QueryBuilders.boolQuery().must(QueryBuilders.termQuery("mapDataList.map", sb.getAssembly())),ScoreMode.None));
            }
            if (!sb.getChr().equals("") && !sb.getChr().equalsIgnoreCase("all") ) {
                builder.filter(QueryBuilders.nestedQuery("mapDataList", QueryBuilders.boolQuery().must(QueryBuilders.termQuery("mapDataList.chromosome", sb.getChr())),ScoreMode.None));

            }
            if (!sb.getStart().equals("") && !sb.getStop().equals("") && sb.getAssembly()!=null && !sb.getAssembly().equals("") && !sb.getAssembly().equalsIgnoreCase("all")) {
               if(sb.getChr()!=null) {
                   builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.
                           nestedQuery("mapDataList", QueryBuilders.boolQuery()
                                   .must(QueryBuilders.termQuery("mapDataList.map", sb.getAssembly()))
                                   .must(QueryBuilders.rangeQuery("mapDataList.chromosome").lte(sb.getStop()))
                                   .must(QueryBuilders.rangeQuery("mapDataList.startPos").lte(sb.getStop()))
                                   .must(QueryBuilders.rangeQuery("mapDataList.stopPos").gte(sb.getStart())), ScoreMode.None)));
               }else{
                   builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.
                           nestedQuery("mapDataList", QueryBuilders.boolQuery()
                                   .must(QueryBuilders.termQuery("mapDataList.map", sb.getAssembly()))
                                   .must(QueryBuilders.rangeQuery("mapDataList.startPos").lte(sb.getStop()))
                                   .must(QueryBuilders.rangeQuery("mapDataList.stopPos").gte(sb.getStart())), ScoreMode.None)));
               }
            }else{
                if (!sb.getStart().equals("") && !sb.getStop().equals("")) {
                    builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.
                            nestedQuery("mapDataList", QueryBuilders.boolQuery()
                                    .must(QueryBuilders.rangeQuery("mapDataList.startPos").lte(sb.getStop()))
                                    .must(QueryBuilders.rangeQuery("mapDataList.stopPos").gte(sb.getStart())), ScoreMode.None)));
                }
            }
            if (!sb.getPolyphenStatus().equals("")) {
                builder.filter(QueryBuilders.termQuery("polyphenStatus.keyword", sb.getPolyphenStatus()));

            }
            if (!sb.getVariantCategory().equals("")) {
                builder.filter(QueryBuilders.termQuery("variantCategory.keyword", sb.getVariantCategory()));

            }
            if (!sb.getSample().equals("")) {
                builder.filter(QueryBuilders.termQuery("analysisName.keyword", sb.getSample()));

            }
            if (!sb.getRegion().equals("")) {
                builder.filter(QueryBuilders.termQuery("regionName.keyword", sb.getRegion()));

            }
            if (sb.getExpressionLevel()!=null && !sb.getExpressionLevel().equals("")) {
                builder.filter(QueryBuilders.termQuery("expressionLevel.keyword", sb.getExpressionLevel()));

            }
        }
        return builder;
    }


    public BoolQueryBuilder getCategoryOrSpeciesQuery(String term,Map<String, String> filterMap){
        BoolQueryBuilder builder=new BoolQueryBuilder();

        List<String> speciesList=new ArrayList<>(Arrays.asList("rat", "human", "mouse", "bonobo", "squirrel","dog","chinchilla"));
        List<String> categories=new ArrayList<>(Arrays.asList("gene","genes","strain","strains", "qtl","qtls", "sslp","sslps", "reference","references", "ontology","ontologies","variant","variants","promoter", "promoters", "cell lines","cell line" ));
        if(speciesList.contains(term)){
            builder
                    .must(QueryBuilders.matchPhraseQuery("species", term));
            return builder;
        }
        if(categories.contains(term)){
            if(!term.equalsIgnoreCase("sslp")) {
                if (term.lastIndexOf('s') != -1) {
                    String stripedTerm=term.substring(0, term.lastIndexOf('s'));
                    builder.must(QueryBuilders.matchPhraseQuery("category", stripedTerm));
                    return builder;
                }
            }else{
                return builder.must(QueryBuilders.matchPhraseQuery("category",term));
            }
            builder.must(QueryBuilders.matchPhraseQuery("category", term));
            return builder;
        }

        return null;
    }

    public QueryBuilder getDisMaxQuery(String term, SearchBean sb){
        DisMaxQueryBuilder dqb=new DisMaxQueryBuilder();

        if((term==null || term.equals("") ) && sb!=null){
            return dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.matchAllQuery()).must(QueryBuilders.termQuery("category.keyword", sb.getCategory())));
        }
        if(sb==null) {
            return dqb.add(QueryBuilders.termQuery("term_acc", term));
        }
        if(sb.getMatchType()!=null && !sb.getMatchType().equals("") && !sb.getMatchType().equalsIgnoreCase("contains")){
            buildQuery(sb, dqb);
        }else {

            if (sb.getCategory() != null && (sb.getCategory().equalsIgnoreCase("") || sb.getCategory().equalsIgnoreCase("gene") || sb.getCategory().equalsIgnoreCase("general")))
                dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol.symbol", term)).must(QueryBuilders.termQuery("category.keyword", "Gene")).boost(1200));
            if (sb.getCategory() != null && (sb.getCategory().equalsIgnoreCase("") || sb.getCategory().equalsIgnoreCase("SSLP") || sb.getCategory().equalsIgnoreCase("general")))
                dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol.symbol", term)).must(QueryBuilders.termQuery("category.keyword", "SSLP")).boost(500));
            if (sb.getCategory() != null && (sb.getCategory().equalsIgnoreCase("") || sb.getCategory().equalsIgnoreCase("strain") || sb.getCategory().equalsIgnoreCase("general")))
                dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol.symbol", term)).must(QueryBuilders.termQuery("category.keyword", "Strain")).boost(1100));
            if (sb.getCategory() != null && (sb.getCategory().equalsIgnoreCase("") || sb.getCategory().equalsIgnoreCase("variant") || sb.getCategory().equalsIgnoreCase("general")))
                dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol.symbol", term)).must(QueryBuilders.termQuery("category.keyword", "Variant")).boost(900));
            if (sb.getCategory() != null && (sb.getCategory().equalsIgnoreCase("") || sb.getCategory().equalsIgnoreCase("qtl") || sb.getCategory().equalsIgnoreCase("general")))
                dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol.symbol", term)).must(QueryBuilders.termQuery("category.keyword", "QTL")).boost(1000));
            if (sb.getCategory() != null && (sb.getCategory().equalsIgnoreCase("") || sb.getCategory().equalsIgnoreCase("strain") || sb.getCategory().equalsIgnoreCase("general")))
                dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("htmlStrippedSymbol.ngram", term)).must(QueryBuilders.termQuery("category.keyword", "Strain")).boost(200));
            dqb.add(QueryBuilders.termQuery("symbol.symbol", term).boost(2000));
            dqb.add(QueryBuilders.termQuery("term.symbol", term).boost(2000));
            dqb.add(QueryBuilders.termQuery("expressedGeneSymbols.symbol", term).boost(2000));
            if(termIsAccId(term)) {
                dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("synonyms.symbol", term)).must(QueryBuilders.termQuery("category.keyword", "Ontology")).boost(2000));

            }else {
                dqb.add(QueryBuilders.multiMatchQuery(term)
                                .field("symbol.symbol", 100)
                                .field("term.symbol", 100)
                                .analyzer("standard")
                                .type(MultiMatchQueryBuilder.Type.PHRASE_PREFIX).boost(10))
                        .add(QueryBuilders.multiMatchQuery(term)
                                .type(MultiMatchQueryBuilder.Type.PHRASE_PREFIX)
                                .analyzer("standard")
                                .boost(8))
                        .add(QueryBuilders.multiMatchQuery(term)
                                .type(MultiMatchQueryBuilder.Type.PHRASE)
                                .analyzer("standard")
                                .boost(5))
                        .add(QueryBuilders.multiMatchQuery(term)
                                .type(MultiMatchQueryBuilder.Type.CROSS_FIELDS)
                                .operator(Operator.AND)

                                .boost(3))

                ;
                //   String[] tokens=term.split("[\\s,]+");
                //  if(tokens.length>0){
//                dqb.add(QueryBuilders.multiMatchQuery(term)
//                        .operator(Operator.AND));
            }
        }
        return dqb;

    }
    public void buildQuery(SearchBean sb, DisMaxQueryBuilder dqb){

        switch (sb.getMatchType()) {
            case "equals" -> exactMatchQuery(dqb, sb);
            case "begins" -> beginsWithQuery(dqb, sb);
            //  case "contains" -> containsQuery(dqb, sb);
            case "ends" -> endsWithQuery(dqb, sb);
            default -> {}
        }


    }
    public boolean termIsAccId(String term){
        if(term.contains(":"))
            return true;
        return false;
    }

    public void exactMatchQuery(DisMaxQueryBuilder dqb, SearchBean sb){
        dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol.symbol", sb.getTerm())).must(QueryBuilders.termQuery("category.keyword", sb.getCategory()).caseInsensitive(true)).boost(1000));
        dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("name.symbol", sb.getTerm())).must(QueryBuilders.termQuery("category.keyword", sb.getCategory()).caseInsensitive(true)).boost(1000));

    }
    public void beginsWithQuery(DisMaxQueryBuilder dqb, SearchBean sb){

//        dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol.symbol", sb.getTerm())).must(QueryBuilders.termQuery("category.keyword", sb.getCategory()).caseInsensitive(true)).boost(1000));
//        dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("name.symbol", sb.getTerm())).must(QueryBuilders.termQuery("category.keyword", sb.getCategory()).caseInsensitive(true)).boost(1000));
//        dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.multiMatchQuery(sb.getTerm(), "symbol.symbol", "name.symbol")
//                .type(MultiMatchQueryBuilder.Type.PHRASE_PREFIX).boost(10)).must(QueryBuilders.termQuery("category.keyword", sb.getCategory()).caseInsensitive(true)));

        dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.matchPhrasePrefixQuery("symbol", sb.getTerm())).must(QueryBuilders.termQuery("category.keyword", sb.getCategory()).caseInsensitive(true)).boost(1000));
        dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.matchPhrasePrefixQuery("name.symbol", sb.getTerm())).must(QueryBuilders.termQuery("category.keyword", sb.getCategory()).caseInsensitive(true)).boost(1000));

    }
    public void endsWithQuery(DisMaxQueryBuilder dqb, SearchBean sb){
        for(String field:searchPrimaryFields) {
            dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.regexpQuery(field+".symbol", ".*(" + sb.getTerm() + ")").caseInsensitive(true))
                    .must(QueryBuilders.termQuery("category.keyword", sb.getCategory())).boost(1000));
            dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.regexpQuery(field+".keyword", ".*(" + sb.getTerm() + ")").caseInsensitive(true))
                    .must(QueryBuilders.termQuery("category.keyword", sb.getCategory())).boost(1000));

        }

    }
    static List<String> searchPrimaryFields=
            Arrays.asList("name", "symbol"
            );

    public AggregationBuilder buildAggregations(String aggField) {

        AggregationBuilder   aggs=null;
        if(aggField.equalsIgnoreCase("species")) {
            aggs = AggregationBuilders.terms(aggField).field(aggField + ".keyword").size(20)
                    .subAggregation(AggregationBuilders.terms("categoryFilter").field("category.keyword")
                            .subAggregation(AggregationBuilders.terms("typeFilter").field("type.keyword"))
                            .subAggregation(AggregationBuilders.terms("trait").field("trait.keyword").size(500))
                            .subAggregation(AggregationBuilders.terms("polyphen").field("polyphenStatus.keyword"))
                            .subAggregation(AggregationBuilders.terms("region").field("regionName.keyword").size(200))
                            .subAggregation(AggregationBuilders.terms("expressionLevel").field("expressionLevel.keyword"))

                            .subAggregation(AggregationBuilders.terms("sample").field("analysisName.keyword").size(200))
                            .subAggregation(AggregationBuilders.terms("variantCategory").field("variantCategory.keyword"))



                    )
                    .subAggregation(AggregationBuilders.terms("ontologies").field("subcat.keyword").size(50).order(BucketOrder.key(true)))
            //    .order(Terms.Order.term(true))) deprecated in 6.4

            ;

            return aggs;
        }
        if(aggField.equalsIgnoreCase("category")) {
            aggs = AggregationBuilders.terms(aggField).field(aggField + ".keyword")
                    .subAggregation(AggregationBuilders.terms("speciesFilter").field("species.keyword").size(20))
                    .subAggregation(AggregationBuilders.terms("subspecies").field("species.keyword").size(20))
                    .subAggregation(AggregationBuilders.terms("polyphen").field("polyphenStatus.keyword"))
                    .subAggregation(AggregationBuilders.terms("region").field("regionName.keyword"))
                    .subAggregation(AggregationBuilders.terms("expressionLevel").field("expressionLevel.keyword"))

                    .subAggregation(AggregationBuilders.terms("sample").field("analysisName.keyword"))
                    .subAggregation(AggregationBuilders.terms("variantCategory").field("variantCategory.keyword"))

                    .subAggregation(AggregationBuilders.terms("ontologies").field("subcat.keyword").size(20).order(BucketOrder.key(true)))
            //  .order(Terms.Order.term(true)))  deprecated in 6.4
            ;

            return aggs;
        }
        if(aggField.equalsIgnoreCase("assembly")) {
            aggs=AggregationBuilders.nested("assemblyAggs", "mapDataList")
                    .subAggregation(AggregationBuilders.terms(aggField).field("mapDataList.map").size(100).order(BucketOrder.key(true)));

            return aggs;
        }
        aggs = AggregationBuilders.terms(aggField).field(aggField + ".keyword")
                .subAggregation(AggregationBuilders.terms("subspecies").field("species.keyword").size(20))
                .subAggregation(AggregationBuilders.terms("ontologies").field("subcat.keyword").size(100).order(BucketOrder.key(true)))
        // .order(Terms.Order.term(true)))  deprecated in 6.4
        ;
        return aggs;
    }

    public HighlightBuilder buildHighlights(){
        HighlightBuilder hb=new HighlightBuilder();
        hb.field("*");
        return hb;
    }

    public boolean isSort() {
        return sort;
    }

    public void setSort(boolean sort) {
        this.sort = sort;
    }

    public SearchResponse getSearchResponse(String term, String category) throws Exception {

        SearchSourceBuilder srb=new SearchSourceBuilder();
        srb.query(QueryBuilders.termQuery("term_acc", term));
        SearchRequest searchRequest=new SearchRequest(RgdContext.getESIndexName("search"));
        searchRequest.source(srb);
        return ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);

    }
}