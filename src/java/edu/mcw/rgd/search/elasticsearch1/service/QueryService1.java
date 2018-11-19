package edu.mcw.rgd.search.elasticsearch1.service;

import edu.mcw.rgd.search.elasticsearch.client.ClientInit;

import edu.mcw.rgd.web.RgdContext;
import org.apache.lucene.search.join.ScoreMode;
import org.elasticsearch.action.search.SearchRequestBuilder;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;
import org.elasticsearch.index.query.*;
import org.elasticsearch.search.aggregations.AggregationBuilder;
import org.elasticsearch.search.aggregations.AggregationBuilders;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.elasticsearch.search.fetch.subphase.highlight.HighlightBuilder;
import org.elasticsearch.search.sort.SortBuilders;
import org.elasticsearch.search.sort.SortOrder;

import java.net.UnknownHostException;
import java.util.*;

import static edu.mcw.rgd.datamodel.search.ElasticMappings.boostValues;
import static edu.mcw.rgd.datamodel.search.ElasticMappings.categories;
import static edu.mcw.rgd.datamodel.search.ElasticMappings.fields;


/**
 * Created by jthota on 3/27/2017.
 */
public class QueryService1 {

    private boolean sort;


    public QueryService1() throws UnknownHostException {
        this.sort=true;
    }


    public SearchResponse getSearchResponse(String term, String category, String species, String  type, String subCat, int from, int size, boolean page, String sortOrder, String sortBy, String assembly, String trait, String start, String stop, String chr) {

        if(term!=null) {
            Map<String, String> filterMap= this.getFilterMap(category, species,type,subCat);
            BoolQueryBuilder builder=this.boolQueryBuilder(term,category,species, filterMap,chr, start, stop, assembly );


            String sortField=null;
            SearchRequestBuilder srb = ClientInit.getClient().prepareSearch(RgdContext.getESIndexName())
                    .setQuery(builder);
               if(sortBy.equalsIgnoreCase("relevance")){
                     srb.addSort(SortBuilders.scoreSort().order(SortOrder.DESC));
                }else{
                   if(sortBy.equalsIgnoreCase("symbol")) {
                       sortField=sortBy + ".keyword";
                       if (sortOrder.equalsIgnoreCase("asc")) {
                               srb.addSort(SortBuilders.fieldSort(sortField).missing("_last").order(SortOrder.ASC));
                       } else {
                           srb .addSort(SortBuilders.fieldSort(sortField).missing("_last").order(SortOrder.DESC));
                       }
                   }else{
                       sortField="mapDataList."+sortBy;
                       if (sortOrder.equalsIgnoreCase("asc")) {
                         //  System.out.println("SORT BY: " + sortBy + " " + sortOrder);
                           srb .addSort(SortBuilders.fieldSort(sortField).setNestedPath("mapDataList").missing("_last").order(SortOrder.ASC)
                                  );
                       } else {
                        //   System.out.println("SORT BY: " + sortBy + " " + sortOrder);
                           srb .addSort(SortBuilders.fieldSort(sortField).setNestedPath("mapDataList").missing("_last").order(SortOrder.DESC));
                       }
                   }
               }

           List<String> aggFields = new ArrayList<>(Arrays.asList("species", "category", "type", "trait"));

           if (!page) {

               for (String field : aggFields) {
                   AggregationBuilder aggs = this.buildAggregations(field);
                   if(aggs!=null)
                   srb.addAggregation(aggs);
               }
           }

            srb
                    .highlighter(this.buildHighlights())
                    .setFrom(from)
                    .setSize(size);
           // System.out.println("trait: "+ trait);
          //  System.out.println("type:"+ type);
          if(!Objects.equals(species, "") &&  !category.equalsIgnoreCase("general") ) {
              if(type!=null && !Objects.equals(type, "")) {
                  if (!Objects.equals(type, "null")) {
                      srb.setPostFilter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("species.keyword", species)).filter(QueryBuilders.termQuery("category.keyword", category)).filter(QueryBuilders.termQuery("type.keyword", type)));
                  }

              }

           if(!trait.equals("")){
               srb.setPostFilter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("species.keyword", species)).filter(QueryBuilders.termQuery("category.keyword", category)).filter(QueryBuilders.termQuery("trait.keyword", trait)));
           }
              if (type != null && type.equals("") && trait.equalsIgnoreCase("")) {
                srb.setPostFilter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("species.keyword", species)).filter(QueryBuilders.termQuery("category.keyword", category)));
            }
            }else{
              if (!Objects.equals(species, "")) {
                  srb.setPostFilter(QueryBuilders.termQuery("species.keyword", species));

              }
              if (!category.equalsIgnoreCase("general")) {
                  if(category.equalsIgnoreCase(("Ontology"))){
                 //     System.out.println("SUBCAT INSIDE: " + subCat);
                      if(subCat!=null && subCat!="") {
                          srb.setPostFilter((QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("category.keyword", category)).filter(QueryBuilders.termQuery("subcat.keyword", subCat))));
                      }else{
                          srb.setPostFilter((QueryBuilders.termQuery("category.keyword", category)));
                      }
                      }else
                  srb.setPostFilter((QueryBuilders.termQuery("category.keyword", category)));

              }
          }

        SearchResponse sr=srb
                .setSearchType(SearchType.QUERY_THEN_FETCH)
                .setRequestCache(true)
                   .execute().actionGet();

        return sr;
       }

       return null;
    }
    public Map<String, String> getFilterMap(String category, String species, String type, String subCat){
        Map<String, String> filterMap= new HashMap<>();
        if(species!=null){
            if(!species.equals("")){
                filterMap.put("species", species);}}
        if(category!=null){
            if(!category.equalsIgnoreCase("general") ){
                filterMap.put("category", category);
            }
            if(category.equalsIgnoreCase("ontology")){
                if(!subCat.equals("")) {
                    filterMap.put("subcat", subCat);
                }else{
                    filterMap.put("category", category);
                }

            }}
        if(type!=null) {
                    if(!type.equals("")){
                          filterMap.put("type", type);
                     }
                   }


        return filterMap;
    }
    public BoolQueryBuilder boolQueryBuilder(String term, String category, String species,Map<String, String> filterMap, String chr, String start, String stop, String assembly){
        BoolQueryBuilder builder=new BoolQueryBuilder();
        builder.must(this.getDisMaxQuery(term, category));
        if(!category.equalsIgnoreCase("general")){
            builder.filter(QueryBuilders.termQuery("category.keyword", category));
        }
        if(species!=null && !species.equals("")){
            builder.filter(QueryBuilders.termQuery("species.keyword", species));
        }
        if(!chr.equals("")){
            if (!start.equals("") && !stop.equals("")) {
                builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.
                        nestedQuery("mapDataList", QueryBuilders.boolQuery().must(QueryBuilders.matchQuery("mapDataList.map", assembly))
                                .must(QueryBuilders.matchQuery("mapDataList.chromosome", chr)).must(QueryBuilders.rangeQuery("mapDataList.startPos").from(1).to(stop).includeUpper(true).includeUpper(false))
                                .must(QueryBuilders.rangeQuery("mapDataList.stopPos").from(start).includeLower(true).includeLower(false)), ScoreMode.None)));
            }else{
                builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders
                        .nestedQuery("mapDataList", QueryBuilders.boolQuery().should(QueryBuilders.matchQuery("mapDataList.map", assembly))
                                .must(QueryBuilders.matchQuery("mapDataList.chromosome", chr)), ScoreMode.None)));

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

    public QueryBuilder getDisMaxQuery(String term, String category){
     DisMaxQueryBuilder dqb=new DisMaxQueryBuilder();
      dqb

              .add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol", term)).must(QueryBuilders.matchQuery("category", "Gene")).boost(300))
              .add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol.symbol", term)).must(QueryBuilders.matchQuery("category", "Gene")).boost(1200))

              .add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol", term)).must(QueryBuilders.matchQuery("category", "SSLP")).boost(200))
              .add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol.symbol", term)).must(QueryBuilders.matchQuery("category", "SSLP")).boost(500))

              .add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol", term)).must(QueryBuilders.matchQuery("category", "Strain")).boost(300))
              .add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol.symbol", term)).must(QueryBuilders.matchQuery("category", "Strain")).boost(1100))

              .add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol", term)).must(QueryBuilders.matchQuery("category", "Variant")).boost(300))
              .add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol.symbol", term)).must(QueryBuilders.matchQuery("category", "Variant")).boost(900))

              .add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol", term)).must(QueryBuilders.matchQuery("category", "QTL")).boost(300))
              .add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("symbol.symbol", term)).must(QueryBuilders.matchQuery("category", "QTL")).boost(1000))

             // .add(QueryBuilders.prefixQuery("symbol.symbol", term))
             .add(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("htmlStrippedSymbol.ngram", term)).must(QueryBuilders.matchQuery("category", "Strain")).boost(200))
     

       /*  .add(QueryBuilders.matchQuery("symbol" , term).operator(Operator.AND).boost(500))
          .add(QueryBuilders.matchQuery("symbol.symbol", term).operator(Operator.AND).boost(1200))
         
           .add(QueryBuilders.termQuery("symbol.ngram", term).boost(500))*/
         //    .add(QueryBuilders.termQuery("htmlStrippedSymbol.ngram", term)).boost(1200)

           .add(QueryBuilders.matchQuery("name.name", term).operator(Operator.AND).boost(200))
           .add(QueryBuilders.matchQuery("name", term).operator(Operator.AND).boost(100))
       //    .add(QueryBuilders.prefixQuery("name.name", term))


            .add(QueryBuilders.matchQuery("synonyms.synonyms", term).operator(Operator.AND).boost(75))
            .add(QueryBuilders.matchQuery("synonyms", term).operator(Operator.AND).boost(30))
            .add(QueryBuilders.matchQuery("description.description", term).operator(Operator.AND).boost(10))
            .add(QueryBuilders.matchQuery("description", term).operator(Operator.AND).boost(5))

           .add(QueryBuilders.matchQuery("term", term).operator(Operator.AND).boost(400))
           .add(QueryBuilders.matchQuery("term.term", term).operator(Operator.AND).boost(600))
       //    .add(QueryBuilders.prefixQuery("term.term", term))
           .add(QueryBuilders.matchQuery("term_def", term).operator(Operator.AND).boost(100))
           .add(QueryBuilders.matchQuery("term_def.term", term).operator(Operator.AND).boost(200))


           .add(QueryBuilders.matchQuery("title", term).operator(Operator.AND).boost(50))
           .add(QueryBuilders.matchQuery("title.title", term).operator(Operator.AND).boost(100))
           .add(QueryBuilders.matchQuery("citation", term).operator(Operator.AND).boost(100))

         //     .add(QueryBuilders.matchQuery("citation", term).operator(Operator.OR).boost(100))
           .add(QueryBuilders.matchQuery("citation.citation", term).operator(Operator.AND).boost(100))
         //   .add(QueryBuilders.matchQuery("citation", term))
           .add(QueryBuilders.matchQuery("author", term).operator(Operator.AND).boost(50))
           .add(QueryBuilders.matchQuery("author.author", term).operator(Operator.AND).boost(100))
           .add(QueryBuilders.matchQuery("refAbstract", term).operator(Operator.AND).boost(10))
           .add(QueryBuilders.matchQuery("refAbstract.refAbstract", term).operator(Operator.AND).boost(30))

            .add(QueryBuilders.boolQuery().must(QueryBuilders.matchQuery("title.title", term))
             .must(QueryBuilders.matchQuery("citation.citation", term)))

             .add(QueryBuilders.boolQuery().must(QueryBuilders.matchQuery("title.title", term))
                     .must(QueryBuilders.matchQuery("citation.cittion", term))
                     .must(QueryBuilders.matchQuery("author.author", term)))


              .add(QueryBuilders.matchQuery("origin", term).operator(Operator.AND).boost(10))
              .add(QueryBuilders.matchQuery("origin.origin", term).operator(Operator.AND).boost(50))
              .add(QueryBuilders.matchQuery("source", term).operator(Operator.AND).boost(5))
              .add(QueryBuilders.matchQuery("source.source", term).operator(Operator.AND).boost(10))
              .add(QueryBuilders.matchQuery("trait", term).operator(Operator.AND).boost(2))

              .add(QueryBuilders.matchQuery("subTrait", term).operator(Operator.AND).boost(1))

              .add(QueryBuilders.matchQuery("promoters", term).operator(Operator.AND).boost(1))

              .add(QueryBuilders.matchQuery("protein_acc_ids", term).operator(Operator.AND).boost(1))
              .add(QueryBuilders.matchQuery("transcriptIds", term).operator(Operator.AND).boost(1))
              .add(QueryBuilders.matchQuery("type", term).operator(Operator.AND).boost(1))
              .add(QueryBuilders.matchQuery("xdbIdentifiers", term).operator(Operator.AND).boost(1))
              .add(QueryBuilders.termQuery("xdata", term).boost(1))
      ;

        return dqb;

    }
    public AggregationBuilder buildAggregations(String aggField) {

        AggregationBuilder   aggs=null;


       if(aggField.equalsIgnoreCase("species")) {
            aggs = AggregationBuilders.terms(aggField).field(aggField + ".keyword")
                    .subAggregation(AggregationBuilders.terms("categoryFilter").field("category.keyword").subAggregation(AggregationBuilders.terms("typeFilter").field("type.keyword"))
                    .subAggregation(AggregationBuilders.terms("trait").field("trait.keyword")))
                    .subAggregation(AggregationBuilders.terms("ontologies").field("subcat.keyword").size(20))
                        //    .order(Terms.Order.term(true))) deprecated in 6.4
            ;

           return aggs;
     }
        if(aggField.equalsIgnoreCase("category")) {
            aggs = AggregationBuilders.terms(aggField).field(aggField + ".keyword")
                    .subAggregation(AggregationBuilders.terms("speciesFilter").field("species.keyword"))
                    .subAggregation(AggregationBuilders.terms("subspecies").field("species.keyword"))

                    .subAggregation(AggregationBuilders.terms("ontologies").field("subcat.keyword").size(20))
                          //  .order(Terms.Order.term(true)))  deprecated in 6.4
            ;

            return aggs;
        }
        aggs = AggregationBuilders.terms(aggField).field(aggField + ".keyword")
                .subAggregation(AggregationBuilders.terms("subspecies").field("species.keyword"))
                .subAggregation(AggregationBuilders.terms("ontologies").field("subcat.keyword").size(20))
                       // .order(Terms.Order.term(true)))  deprecated in 6.4
        ;
       return aggs;
    }

    public HighlightBuilder buildHighlights(){
        List<String> fields=new ArrayList<>(Arrays.asList(
                "symbol","symbol.symbol","symbol.ngram","htmlStrippedSymbol.ngram",
                "name","name.name", "description","description.description",
                "citation","citation.citation","title",
                "title.title","author","author.author","refAbstract", "refAbstract.refAbstract",
                "term","term.term","term_def","term_def.term","term_acc",
                "synonyms",   "synonyms.synonyms",
                "source","source.source",
                "origin","origin.origin",
                "trait","subTrait",
                "type","transcripts", "promoters",
                "protein_acc_ids", "transcript_ids", "xdata", "xdbIdentifiers"
        ));
        HighlightBuilder hb=new HighlightBuilder();
        for(String field:fields){
            hb.field(field);
        }
        return hb;
    }

    public boolean isSort() {
        return sort;
    }

    public void setSort(boolean sort) {
        this.sort = sort;
    }

    public SearchResponse getSearchResponse(String term, String category) throws Exception {
        return ClientInit.getClient().prepareSearch(RgdContext.getESIndexName())
                         .setSearchType(SearchType.DFS_QUERY_THEN_FETCH)
                           .setQuery(QueryBuilders.termQuery("term_acc", term))
                           .get();
    }
}
