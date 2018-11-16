package edu.mcw.rgd.search.elasticsearch1.service;


import edu.mcw.rgd.search.elasticsearch.client.ClientInit;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.bucket.filter.Filter;

import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.springframework.ui.ModelMap;

import java.io.IOException;

import java.util.*;

/**
 * Created by jthota on 2/22/2017.
 */
public class SearchService {

    public ModelMap getResultsMap(SearchResponse sr, String term, String cat1, String sp1, int postCount ) throws IOException {
        ModelMap model= new ModelMap();
        List<SearchHit[]> searchHits=new ArrayList<>();

    //    String scrollId= sr.getScrollId();

        long totalHits=0;

        Map<String,  List<? extends Terms.Bucket>> aggregations=new HashMap<>();
        String[][] speciesCatArray = new String[7][9];
        speciesCatArray[0][0]="Gene";
        speciesCatArray[4][0]="Variant";
        speciesCatArray[1][0]="Strain";
        speciesCatArray[2][0]="QTL";
        speciesCatArray[3][0]="SSLP";
        speciesCatArray[5][0]="Promoter";
        speciesCatArray[6][0]="Cell line";

        Terms speciesAgg, categoryAgg, typeAgg;
        Filter chromosomeAgg;
        long totalTerms = 0;
        int nvCount=0;

            if (sr.getAggregations() != null) {
                speciesAgg = sr.getAggregations().get("species");

                 aggregations.put("species", speciesAgg.getBuckets());
                categoryAgg = sr.getAggregations().get("category");
                List<Terms.Bucket> catBuckets= (List<Terms.Bucket>) categoryAgg.getBuckets();
                System.out.println("CAT BUCKETS SIZE:"+catBuckets.size());
                   aggregations.put("category", catBuckets);
               for(Terms.Bucket speciesBkt:speciesAgg.getBuckets()) {
                   Terms catFilterAgg = speciesBkt.getAggregations().get("categoryFilter");
                   String species = speciesBkt.getKey().toString().toLowerCase();
                   aggregations.put(species, catFilterAgg.getBuckets());
                   for (Terms.Bucket bucket : catFilterAgg.getBuckets()) {
                       Terms typeFilterAgg = bucket.getAggregations().get("typeFilter");
                       aggregations.put(species + bucket.getKey().toString(), typeFilterAgg.getBuckets());
                   }
               }
                chromosomeAgg=sr.getAggregations().get("chromosome");
                 for (Terms.Bucket bucket :catBuckets) {

                    String bucketType = bucket.getKey().toString();
                    String bType = new String();
                    bType = bucketType;

                    if(bucketType.equalsIgnoreCase("ontology")){
                        Terms ontologySubcatAgg=bucket.getAggregations().get("ontologies");
                     //   ontologyBkts.addAll(ontologySubcatAgg.getBuckets());
                        aggregations.put("ontology", ontologySubcatAgg.getBuckets());
                    }

                    Terms subAgg = bucket.getAggregations().get("subspecies");
                    int k = 0;
                    for (Terms.Bucket b : subAgg.getBuckets()) {
                        String key = (String) b.getKey();
                        if(!Objects.equals(key, "")){
                        if (key.equalsIgnoreCase("Rat")) {
                            k = 1;   //Matrix column 1

                        } else if (key.equalsIgnoreCase("Mouse")) {
                            k = 2;      //Matrix column 2
                        } else if (key.equalsIgnoreCase("Human")) {
                            k = 3;      //Matrix column 3
                        } else if (key.equalsIgnoreCase("Chinchilla")) {
                            k = 4;      //Matrix column 4
                        } else if (key.equalsIgnoreCase("Bonobo")) {
                            k = 5;      //Matrix column 5
                        } else if (key.equalsIgnoreCase("Dog")) {
                            k = 6;      //Matrix column 6
                        } else if (key.equalsIgnoreCase("Squirrel")) {
                            k = 7;      //Matrix column 7
                        }

                        switch (bType) {
                            case "Gene":
                         //       String url="elasticResults.html?category=Gene&species="+key+"&term=" + term.replace(" " ,"+") +"&cat1="+ cat1+"&sp1="+ sp1+"&postCount="+ postCount ;
                                speciesCatArray[0][k] = String.valueOf(b.getDocCount());
                                speciesCatArray[0][8] = String.valueOf(bucket.getDocCount()) ;
                                break;
                            case "Variant":
                                speciesCatArray[4][k] =  String.valueOf(b.getDocCount()) ;
                                speciesCatArray[4][8] = String.valueOf(bucket.getDocCount()) ;
                                break;
                            case "Strain":
                                speciesCatArray[1][k] =  String.valueOf(b.getDocCount());
                                speciesCatArray[1][8] = String.valueOf(bucket.getDocCount());

                                break;
                            case "QTL":
                                speciesCatArray[2][k] =  String.valueOf(b.getDocCount());
                                speciesCatArray[2][8] =  String.valueOf(bucket.getDocCount()) ;
                              //  System.out.println(key + " : "+ b.getDocCount());
                                break;
                            case "SSLP":
                                speciesCatArray[3][k] = String.valueOf(b.getDocCount());
                                speciesCatArray[3][8] = String.valueOf(bucket.getDocCount());
                                break;

                            case "Promoter":

                                speciesCatArray[5][k] =  String.valueOf(b.getDocCount());
                                speciesCatArray[5][8] = String.valueOf(bucket.getDocCount()) ;
                                break;
                            case "Cell line":
                                speciesCatArray[6][k] =  String.valueOf(b.getDocCount()) ;
                                speciesCatArray[6][8] = String.valueOf(bucket.getDocCount()) ;
                                break;

                            default:
                                break;
                        }
                    }}
                }

             for (int j = 0; j < 7; j++) {

                    for (int l = 0; l < 9; l++) {
                        if (speciesCatArray[j][l] == null || Objects.equals(speciesCatArray[j][l], "")) {
                            nvCount=nvCount+1;
                            speciesCatArray[j][l] = "-";
                        }
                    }
                }


                typeAgg = sr.getAggregations().get("type");
                aggregations.put("type", typeAgg.getBuckets());
            }

           totalHits = sr.getHits().getTotalHits();
            searchHits.add(sr.getHits().getHits());
            SearchHit[] hitsarray= sr.getHits().getHits();
        for(SearchHit h:hitsarray){{
           Map map=h.getSourceAsMap();

        }

        }

  //      }
        int matrixResultsExists=0;

        if(nvCount<56){
          matrixResultsExists=1;
        }
        String message=new String();
        if(totalHits==0){
            message="0 results found for \"" + term + "\"";
        }

       model.addAttribute("totalHits", totalHits);
        model.addAttribute("aggregations", aggregations);

        model.addAttribute("speciesCatArray", speciesCatArray);
        model.addAttribute("message", message);
        model.addAttribute("matrixResultsExists", matrixResultsExists );
        model.addAttribute("ontologyTermCount", totalTerms);
        model.addAttribute("took", sr.getTook());
        System.out.println("TOOK: " + sr.getTook() + " || "+ sr.getTook() + " || "+ sr.getTotalShards());
        return model;
    }
    public SearchResponse getSearchResponse(String term, String category, String species, String type, String subCat,int  currentPage, int pagesize, boolean page,String sortOrder, String sortBy, String assembly, String trait, String start, String stop, String chr)  {
        int defaultPageSize=(pagesize>0)?pagesize:50;
        int from=(currentPage>0)?(currentPage-1)*defaultPageSize:0;
        try {
            QueryService1 qs = new QueryService1();
           return qs.getSearchResponse(term, category, species, type, subCat, from, defaultPageSize, page, sortOrder, sortBy, assembly, trait, start, stop, chr);
        }catch (Exception e){
        System.out.println("UNKNOWN HOST EXCETPITON.. Reinitiating client..." );
            e.printStackTrace();
        reInitiateClient();
        try{

            QueryService1 qs = new QueryService1();
            return qs.getSearchResponse(term, category, species, type, subCat, from, defaultPageSize, page, sortOrder, sortBy, assembly, trait, start, stop, chr);
        }catch (Exception exception){}}
        return null;
    }
    public SearchResponse getSearchResponse(String term, String category){
        try{
            QueryService1 qs= new QueryService1();
            return qs.getSearchResponse(term, category);
        } catch (Exception e) {
             System.out.println("UNKNOWN HOST EXCETPITON When search for term_acc.. Reinitiating client...");
            reInitiateClient();
            try{
                QueryService1 qs = new QueryService1();
                return qs.getSearchResponse(term, category);
            }catch (Exception exception){}
        }
        return null;
    }

    public void reInitiateClient(){
        ClientInit esClient= new ClientInit();
        List<String> hostNames= esClient.getHostNames();
        ClientInit.setHosts(hostNames);
        ClientInit.setClient(null);
        esClient.init();

    }
    public static void main(String[] args) throws IOException {
        System.out.println("start time: " + new Date());
        SearchService service= new SearchService();

        System.out.println("end time: "+ new Date());
    }
}
