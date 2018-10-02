package edu.mcw.rgd.search.elasticsearch1.service;


import edu.mcw.rgd.search.elasticsearch.client.ClientInit;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.bucket.filter.Filter;

import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.springframework.ui.ModelMap;

import java.io.IOException;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Objects;

/**
 * Created by jthota on 2/22/2017.
 */
public class SearchService {

    public ModelMap getResultsMap(SearchResponse sr, String term, String cat1, String sp1, int postCount ) throws IOException {
        ModelMap model= new ModelMap();

        String scrollId= sr.getScrollId();

        long totalHits=0;
        List<Terms.Bucket> speciesBkts = new ArrayList<>();
        List<Terms.Bucket> categoryBks = new ArrayList<>();
        List<Terms.Bucket> speciesFilterBkts = new ArrayList<>();
        List<Terms.Bucket> categoryFilterBkts = new ArrayList<>();


        List<Terms.Bucket> humanFilterBkts = new ArrayList<>();
        List<Terms.Bucket> mouseFilterBkts = new ArrayList<>();
        List<Terms.Bucket> ratFilterBkts = new ArrayList<>();
        List<Terms.Bucket> bonoboFilterBkts = new ArrayList<>();
        List<Terms.Bucket> squirrelFilterBkts = new ArrayList<>();
        List<Terms.Bucket> dogFilterBkts = new ArrayList<>();
        List<Terms.Bucket> chinchillaFilterBkts = new ArrayList<>();

        List<Terms.Bucket> ontologyBkts = new ArrayList<>();
        List<Terms.Bucket> subCatBks = new ArrayList<>();
        List<Terms.Bucket> typeBks = new ArrayList<>();
        List<Terms.Bucket> chrBkts = new ArrayList<>();
        List<SearchHit[]> searchHits=new ArrayList<>();

        List<Terms.Bucket> ratGeneTypeBkts= new ArrayList<>();
        List<Terms.Bucket> ratVariantTypeBkts= new ArrayList<>();
        List<Terms.Bucket> ratSslpTypeBkts= new ArrayList<>();
        List<Terms.Bucket> ratQtlTypeBkts= new ArrayList<>();
        List<Terms.Bucket> ratStrainTypeBkts= new ArrayList<>();

        List<Terms.Bucket> humanGeneTypeBkts= new ArrayList<>();
        List<Terms.Bucket> humanVariantTypeBkts= new ArrayList<>();
        List<Terms.Bucket> humanSslpTypeBkts= new ArrayList<>();
        List<Terms.Bucket> humanQtlTypeBkts= new ArrayList<>();

        List<Terms.Bucket> chinchillaGeneTypeBkts= new ArrayList<>();
        List<Terms.Bucket>  chinchillaVariantTypeBkts= new ArrayList<>();
        List<Terms.Bucket>  chinchillaSslpTypeBkts= new ArrayList<>();
        List<Terms.Bucket>  chinchillaQtlTypeBkts= new ArrayList<>();

        List<Terms.Bucket> dogGeneTypeBkts= new ArrayList<>();
        List<Terms.Bucket> dogVariantTypeBkts= new ArrayList<>();
        List<Terms.Bucket> dogSslpTypeBkts= new ArrayList<>();
        List<Terms.Bucket> dogQtlTypeBkts= new ArrayList<>();

        List<Terms.Bucket> squirrelGeneTypeBkts= new ArrayList<>();
        List<Terms.Bucket> squirrelVariantTypeBkts= new ArrayList<>();
        List<Terms.Bucket> squirrelSslpTypeBkts= new ArrayList<>();
        List<Terms.Bucket> squirrelQtlTypeBkts= new ArrayList<>();

        List<Terms.Bucket> bonoboGeneTypeBkts= new ArrayList<>();
        List<Terms.Bucket> bonoboVariantTypeBkts= new ArrayList<>();
        List<Terms.Bucket> bonoboSslpTypeBkts= new ArrayList<>();
        List<Terms.Bucket> bonoboQtlTypeBkts= new ArrayList<>();

        List<Terms.Bucket> mouseGeneTypeBkts= new ArrayList<>();
        List<Terms.Bucket> mouseVariantTypeBkts= new ArrayList<>();
        List<Terms.Bucket> mouseSslpTypeBkts= new ArrayList<>();
        List<Terms.Bucket> mouseQtlTypeBkts= new ArrayList<>();



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
    //    if(sr!=null) {
            if (sr.getAggregations() != null) {
                speciesAgg = sr.getAggregations().get("species");
             //   System.out.println("speciesBKTs size:"+speciesAgg.getBuckets().size());
                speciesBkts.addAll(speciesAgg.getBuckets());

                categoryAgg = sr.getAggregations().get("category");
                List<Terms.Bucket> catBuckets=categoryAgg.getBuckets();
                System.out.println("CAT BUCKETS SIZE:"+catBuckets.size());
                categoryBks.addAll(catBuckets);

               for(Terms.Bucket speciesBkt:speciesBkts){
               Terms catFilterAgg= speciesBkt.getAggregations().get("categoryFilter");

                    if(speciesBkt.getKey().toString().equalsIgnoreCase("rat")){
                       ratFilterBkts.addAll(catFilterAgg.getBuckets());
                       for(Terms.Bucket bucket:catFilterAgg.getBuckets()){
                           Terms typeFilterAgg=bucket.getAggregations().get("typeFilter");
                           Terms traitFilterAgg= bucket.getAggregations().get("trait");
                           if(bucket.getKey().toString().equalsIgnoreCase("gene")){
                               ratGeneTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("qtl")){
                             //  ratQtlTypeBkts.addAll(typeFilterAgg.getBuckets());
                               ratQtlTypeBkts.addAll(traitFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("sslp")){
                               ratSslpTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("variant")){
                               ratVariantTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("strain")){
                               ratStrainTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }

                       }
                   }
                   if(speciesBkt.getKey().toString().equalsIgnoreCase("mouse")){
                      mouseFilterBkts.addAll(catFilterAgg.getBuckets());
                       for(Terms.Bucket bucket:catFilterAgg.getBuckets()){
                           Terms typeFilterAgg=bucket.getAggregations().get("typeFilter");
                           Terms traitFilterAgg= bucket.getAggregations().get("trait");
                           if(bucket.getKey().toString().equalsIgnoreCase("gene")){
                               mouseGeneTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("qtl")){
                               mouseQtlTypeBkts.addAll(traitFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("sslp")){
                               mouseSslpTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("variant")){
                               mouseVariantTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }

                       }
                   }
                   if(speciesBkt.getKey().toString().equalsIgnoreCase("human")){
                       humanFilterBkts.addAll(catFilterAgg.getBuckets());
                       for(Terms.Bucket bucket:catFilterAgg.getBuckets()){
                           Terms typeFilterAgg=bucket.getAggregations().get("typeFilter");
                           Terms traitFilterAgg= bucket.getAggregations().get("trait");
                           if(bucket.getKey().toString().equalsIgnoreCase("gene")){
                               humanGeneTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("qtl")){
                              humanQtlTypeBkts.addAll(traitFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("sslp")){
                              humanSslpTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("variant")){
                               humanVariantTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }

                       }
                   }
                   if(speciesBkt.getKey().toString().equalsIgnoreCase("chinchilla")){
                       chinchillaFilterBkts.addAll(catFilterAgg.getBuckets());
                       for(Terms.Bucket bucket:catFilterAgg.getBuckets()){
                           Terms typeFilterAgg=bucket.getAggregations().get("typeFilter");
                           if(bucket.getKey().toString().equalsIgnoreCase("gene")){
                               chinchillaGeneTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("qtl")){
                               chinchillaQtlTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("sslp")){
                               chinchillaSslpTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("variant")){
                               chinchillaVariantTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }

                       }
                   }
                   if(speciesBkt.getKey().toString().equalsIgnoreCase("dog")){
                       dogFilterBkts.addAll(catFilterAgg.getBuckets());
                       for(Terms.Bucket bucket:catFilterAgg.getBuckets()){
                           Terms typeFilterAgg=bucket.getAggregations().get("typeFilter");
                           if(bucket.getKey().toString().equalsIgnoreCase("gene")){
                               dogGeneTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("qtl")){
                               dogQtlTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("sslp")){
                               dogSslpTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("variant")){
                               dogVariantTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }

                       }
                   }
                   if(speciesBkt.getKey().toString().equalsIgnoreCase("squirrel")){
                       squirrelFilterBkts.addAll(catFilterAgg.getBuckets());
                       for(Terms.Bucket bucket:catFilterAgg.getBuckets()){
                           Terms typeFilterAgg=bucket.getAggregations().get("typeFilter");
                           if(bucket.getKey().toString().equalsIgnoreCase("gene")){
                               squirrelGeneTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("qtl")){
                               squirrelQtlTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("sslp")){
                               squirrelSslpTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("variant")){
                               squirrelVariantTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }

                       }
                   }
                   if(speciesBkt.getKey().toString().equalsIgnoreCase("bonobo")){
                       bonoboFilterBkts.addAll(catFilterAgg.getBuckets());
                       for(Terms.Bucket bucket:catFilterAgg.getBuckets()){
                           Terms typeFilterAgg=bucket.getAggregations().get("typeFilter");
                           if(bucket.getKey().toString().equalsIgnoreCase("gene")){
                               bonoboGeneTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("qtl")){
                             bonoboQtlTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("sslp")){
                               bonoboSslpTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }
                           if(bucket.getKey().toString().equalsIgnoreCase("variant")){
                               bonoboVariantTypeBkts.addAll(typeFilterAgg.getBuckets());
                           }

                       }
                   }
               }
                chromosomeAgg=sr.getAggregations().get("chromosome");
             /*   if(chromosomeAgg!=null)
                System.out.println("CHROMOSOME AGG:"+chromosomeAgg.getDocCount());*/

         //      for (Terms.Bucket bucket : categoryAgg.getBuckets()) {
                   for (Terms.Bucket bucket :categoryBks) {

                    String bucketType = bucket.getKey().toString();
                    String bType = new String();
                    bType = bucketType;

                    if(bucketType.equalsIgnoreCase("ontology")){
                        Terms ontologySubcatAgg=bucket.getAggregations().get("ontologies");
                        ontologyBkts.addAll(ontologySubcatAgg.getBuckets());

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
                typeBks.addAll(typeAgg.getBuckets());
            }

           totalHits = sr.getHits().getTotalHits();
            searchHits.add(sr.getHits().getHits());

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
       model.addAttribute("speciesBkts", speciesBkts);
       model.addAttribute("categoryBkts", categoryBks);
       model.addAttribute("hitArray", searchHits);
       model.addAttribute("subCatBkts", subCatBks);
       model.addAttribute("speciesFilterBkts", speciesFilterBkts);
       model.addAttribute("categoryFilterBkts", categoryFilterBkts);
       model.addAttribute("humanFilterBkts",humanFilterBkts);
       model.addAttribute("mouseFilterBkts",mouseFilterBkts);
       model.addAttribute("ratFilterBkts",ratFilterBkts);
       model.addAttribute("bonoboFilterBkts", bonoboFilterBkts);
       model.addAttribute("squirrelFilterBkts", squirrelFilterBkts);
       model.addAttribute("dogFilterBkts", dogFilterBkts);
       model.addAttribute("chinchillaFilterBkts", chinchillaFilterBkts);

        model.addAttribute("humanGeneTypeBkts", humanGeneTypeBkts);
        model.addAttribute("humanVariantTypeBkts", humanVariantTypeBkts);
        model.addAttribute("humanSslpTypeBkts", humanSslpTypeBkts);
        model.addAttribute("humanQtlTypeBkts", humanQtlTypeBkts);

        model.addAttribute("mouseGeneTypeBkts", mouseGeneTypeBkts);
        model.addAttribute("mouseVariantTypeBkts", mouseVariantTypeBkts);
        model.addAttribute("mouseSslpTypeBkts", mouseSslpTypeBkts);
        model.addAttribute("mouseQtlTypeBkts", mouseQtlTypeBkts);

        model.addAttribute("ratGeneTypeBkts", ratGeneTypeBkts);
        model.addAttribute("ratVariantTypeBkts", ratVariantTypeBkts);
        model.addAttribute("ratSslpTypeBkts", ratSslpTypeBkts);
        model.addAttribute("ratQtlTypeBkts", ratQtlTypeBkts);
        model.addAttribute("ratStrainTypeBkts", ratStrainTypeBkts);


        model.addAttribute("dogGeneTypeBkts", dogGeneTypeBkts);
        model.addAttribute("dogVariantTypeBkts", dogVariantTypeBkts);
        model.addAttribute("dogSslpTypeBkts", dogSslpTypeBkts);
        model.addAttribute("dogQtlTypeBkts", dogQtlTypeBkts);

        model.addAttribute("chinchillaGeneTypeBkts", chinchillaGeneTypeBkts);
        model.addAttribute("chinchillaVariantTypeBkts", chinchillaVariantTypeBkts);
        model.addAttribute("chinchillaSslpTypeBkts", chinchillaSslpTypeBkts);
        model.addAttribute("chinchillaQtlTypeBkts", chinchillaQtlTypeBkts);

        model.addAttribute("bonoboGeneTypeBkts", bonoboGeneTypeBkts);
        model.addAttribute("bonoboVariantTypeBkts", bonoboVariantTypeBkts);
        model.addAttribute("bonoboSslpTypeBkts", bonoboSslpTypeBkts);
        model.addAttribute("bonoboQtlTypeBkts", bonoboQtlTypeBkts);

        model.addAttribute("squirrelGeneTypeBkts", squirrelGeneTypeBkts);
        model.addAttribute("squirrelVariantTypeBkts", squirrelVariantTypeBkts);
        model.addAttribute("squirrelSslpTypeBkts", squirrelSslpTypeBkts);
        model.addAttribute("squirrelQtlTypeBkts",squirrelQtlTypeBkts);


        model.addAttribute("chrBkts", chrBkts);
        model.addAttribute("ontologyBkts", ontologyBkts);
        model.addAttribute("typeBks", typeBks);
        model.addAttribute("speciesCatArray", speciesCatArray);
        model.addAttribute("message", message);
        model.addAttribute("matrixResultsExists", matrixResultsExists );
        model.addAttribute("ontologyTermCount", totalTerms);
        model.addAttribute("scrollId", scrollId);
        model.addAttribute("took", sr.getTookInMillis());
     //   System.out.println("TOOK: " + sr.getTook() + " || "+ sr.getTookInMillis() + " || "+ sr.getTotalShards());
        return model;
    }
    public SearchResponse getSearchResponse(String term, String category, String species, String type, String subCat,int  currentPage, int pagesize, boolean page,String sortOrder, String sortBy, String assembly, String trait, String start, String stop, String chr)  {
        int defaultPageSize=(pagesize>0)?pagesize:50;
        int from=(currentPage>0)?(currentPage-1)*defaultPageSize:0;
        try {
            QueryService1 qs = new QueryService1();
           return qs.getSearchResponse(term, category, species, type, subCat, from, defaultPageSize, page, sortOrder, sortBy, assembly, trait, start, stop, chr);
        }catch (Exception e){
        System.out.println("UNKNOWN HOST EXCETPITON.. Reinitiating client...");
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
