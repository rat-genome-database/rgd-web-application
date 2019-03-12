package edu.mcw.rgd.search.elasticsearch1.service;


import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.search.elasticsearch.client.ClientInit;
import edu.mcw.rgd.search.elasticsearch1.model.SearchBean;
import edu.mcw.rgd.search.elasticsearch1.model.Sort;
import edu.mcw.rgd.search.elasticsearch1.model.SortMap;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.common.collect.HppcMaps;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.bucket.filter.Filter;

import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.springframework.http.HttpRequest;
import org.springframework.ui.ModelMap;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

import java.util.*;

/**
 * Created by jthota on 2/22/2017.
 */
public class SearchService {

    public ModelMap getResultsMap(SearchResponse sr, String term ) throws IOException {
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
             //   System.out.println("CAT BUCKETS SIZE:"+catBuckets.size());
                aggregations.put("category", catBuckets);
                for(Terms.Bucket speciesBkt:speciesAgg.getBuckets()) {
                   Terms catFilterAgg = speciesBkt.getAggregations().get("categoryFilter");
                   String species = speciesBkt.getKey().toString().toLowerCase();
                   aggregations.put(species, catFilterAgg.getBuckets());
                   for (Terms.Bucket bucket : catFilterAgg.getBuckets()) {
                       Terms typeFilterAgg = bucket.getAggregations().get("typeFilter");
                       Terms traitFilterAgg=bucket.getAggregations().get("trait");
                       if(bucket.getKey().toString().equalsIgnoreCase("qtl")){
                           aggregations.put(species + bucket.getKey().toString(), traitFilterAgg.getBuckets());
                       }else
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
                        if(key.equalsIgnoreCase("Rat") || key.equalsIgnoreCase("Mouse") ||
                                key.equalsIgnoreCase("Human") || key.equalsIgnoreCase("Chinchilla") || key.equalsIgnoreCase("Dog")
                                || key.equalsIgnoreCase("Squirrel")){
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
          /*  SearchHit[] hitsarray= sr.getHits().getHits();
        for(SearchHit h:hitsarray){
           Map map=h.getSourceAsMap();  }*/

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
        model.addAttribute("hitArray", searchHits);
        model.addAttribute("speciesCatArray", speciesCatArray);
        model.addAttribute("message", message);
        model.addAttribute("matrixResultsExists", matrixResultsExists );
        model.addAttribute("ontologyTermCount", totalTerms);
        model.addAttribute("took", sr.getTook());
    //    System.out.println("TOOK: " + sr.getTook() + " || "+ sr.getTook() + " || "+ sr.getTotalShards());
        return model;
    }
   public SearchResponse getSearchResponse(HttpServletRequest request, String term, SearchBean sb)  {
           try {
            QueryService1 qs = new QueryService1();
           return qs.getSearchResponse(term, sb);
                   //sb.getCategory(), sb.getSpecies(), sb.getType(), sb.getSubCat(), sb.getFrom(), sb.getSize(), sb.isPage(), sb.getSortOrder(), sb.getSortBy(), sb.getAssembly(), sb.getTrait(), sb.getStart(), sb.getStop(), sb.getStop());
        }catch (Exception e){
        System.out.println("UNKNOWN HOST EXCETPITON.. Reinitiating client..." );
            e.printStackTrace();
        reInitiateClient();
        try{

            QueryService1 qs = new QueryService1();
            return qs.getSearchResponse(term,sb);
                    //sb.getCategory(), sb.getSpecies(), sb.getType(), sb.getSubCat(), sb.getFrom(), sb.getSize(), sb.isPage(), sb.getSortOrder(), sb.getSortBy(), sb.getAssembly(), sb.getTrait(), sb.getStart(), sb.getStop(), sb.getStop());
        }catch (Exception exception){}}
        return null;
    }

    public void reInitiateClient(){
        ClientInit esClient= new ClientInit();
        List<String> hostNames= esClient.getHostNames();
        ClientInit.setHosts(hostNames);
        ClientInit.setClient(null);
        esClient.init();

    }
    public SearchBean getSearchBean(HttpServletRequest request, String term){
        String start=request.getParameter("start")!=null?request.getParameter("start"):"",
                stop=request.getParameter("stop")!=null?request.getParameter("stop"):"",
                chr=request.getParameter("chr")!=null && !request.getParameter("chr").equalsIgnoreCase("all")?request.getParameter("chr"):"";

        String category = request.getParameter("category") != null ? request.getParameter("category") : "";
        String species = (request.getParameter("species") == null) ? "" : request.getParameter("species");
        String type = (request.getParameter("type") == null) ? "" : request.getParameter("type");
        String subCat = (request.getParameter("subCat") == null) ? "" : request.getParameter("subCat");
        String sortValue=(request.getParameter("sortBy")==null)?"0":request.getParameter("sortBy");
        String trait=(request.getParameter("trait")==null)?"":request.getParameter("trait");
        Map<String, Sort> sortMap= SortMap.getSortMap();
        Sort s= sortMap.get(sortValue);
        String sortBy=s.getSortBy();
        String sortOrder= s.getSortOrder();
        boolean redirect= request.getParameter("redirect") != null && request.getParameter("redirect").equals("true");

        String pageCurrent = request.getParameter("currentPage")!=null?request.getParameter("currentPage"):null;
        String size = request.getParameter("size")!=null?request.getParameter("size"):null;
        boolean viewAll = request.getParameter("viewall") != null && request.getParameter("viewall").equals("true");
        boolean page =request.getParameter("page") != null && (request.getParameter("page").equals("true"));
        int currentPage = (pageCurrent != null) ? Integer.parseInt(pageCurrent) : 1;
        int pageSize = (size != null) ? Integer.parseInt(request.getParameter("size")) : 50;

        String assembly=(request.getParameter("assembly") != null && !request.getParameter("assembly").equals(""))?request.getParameter("assembly"):null;

        int defaultPageSize=(pageSize>0)?pageSize:50;
        int from=(currentPage>0)?(currentPage-1)*defaultPageSize:0;
        SearchBean sb= new SearchBean();
        sb.setAssembly(assembly);
        sb.setCategory(category);
        sb.setChr(chr);
        sb.setFrom(from);
        sb.setPage(page);
        sb.setSize(pageSize);
        sb.setSortBy(sortBy);
        sb.setSortOrder(sortOrder);
        sb.setSpecies(species);
        sb.setStart(start);
        sb.setStop(stop);
        sb.setSubCat(subCat);
        sb.setTerm(term);
        sb.setTrait(trait);
        sb.setType(type);
        sb.setViewAll(viewAll);
        sb.setCurrentPage(currentPage);
        sb.setRedirect(redirect);
        return sb;
    }
    public static void main(String[] args) throws IOException {
        System.out.println("start time: " + new Date());
        SearchService service= new SearchService();

        System.out.println("end time: "+ new Date());
    }
}
