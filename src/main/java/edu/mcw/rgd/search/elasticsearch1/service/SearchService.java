package edu.mcw.rgd.search.elasticsearch1.service;


import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.search.elasticsearch1.model.SearchBean;
import edu.mcw.rgd.search.elasticsearch1.model.Sort;
import edu.mcw.rgd.search.elasticsearch1.model.SortMap;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.lucene.search.TotalHits;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.bucket.filter.Filter;

import org.elasticsearch.search.aggregations.bucket.nested.Nested;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.springframework.ui.ModelMap;

import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;

import java.net.UnknownHostException;
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
        String[][] speciesCatArray = new String[9][12];
        speciesCatArray[0][0]="Gene";
        speciesCatArray[4][0]="Variant";
        speciesCatArray[1][0]="Strain";
        speciesCatArray[2][0]="QTL";
        speciesCatArray[3][0]="SSLP";
        speciesCatArray[5][0]="Promoter";
        speciesCatArray[6][0]="Cell line";
        speciesCatArray[7][0]="Expressed Gene";
        speciesCatArray[8][0]="Expression Study";
        Terms speciesAgg, categoryAgg, typeAgg, assembly = null;
        Filter chromosomeAgg;
        long totalTerms = 0;
        int nvCount=0;

            if (sr.getAggregations() != null) {
                speciesAgg = sr.getAggregations().get("species");
                aggregations.put("species", speciesAgg.getBuckets());

                categoryAgg = sr.getAggregations().get("category");
                List<Terms.Bucket> catBuckets= (List<Terms.Bucket>) categoryAgg.getBuckets();
                aggregations.put("category", catBuckets);



                for(Terms.Bucket speciesBkt:speciesAgg.getBuckets()) {
                   Terms catFilterAgg = speciesBkt.getAggregations().get("categoryFilter");
                   String species = new String();
                    species=   speciesBkt.getKey().toString().toLowerCase().replace(" ", "").replace("-","");

                    aggregations.put(species, catFilterAgg.getBuckets());
                   for (Terms.Bucket bucket : catFilterAgg.getBuckets()) {
                       Terms typeFilterAgg = bucket.getAggregations().get("typeFilter");
                       Terms traitFilterAgg=bucket.getAggregations().get("trait");
                       Terms polyphenFilterAgg=bucket.getAggregations().get("polyphen");
                       Terms regionFilterAgg=bucket.getAggregations().get("region");
                       Terms sampleFilterAgg=bucket.getAggregations().get("sample");
                       Terms variantCategoryFilterAgg=bucket.getAggregations().get("variantCategory");
                       Terms expressionLevelFilterAgg=bucket.getAggregations().get("expressionLevel");
                       Terms strainTermsFilterAgg=bucket.getAggregations().get("strainTerms");
                       Terms tissueTermsFilterAgg=bucket.getAggregations().get("tissueTerms");
                       Terms cellTypeTermsFilterAgg=bucket.getAggregations().get("cellTypeTerms");



                       if(bucket.getKey().toString().equalsIgnoreCase("variant")){
                           aggregations.put(species + "Polyphen", polyphenFilterAgg.getBuckets());
                           aggregations.put(species + "Region", regionFilterAgg.getBuckets());
                           aggregations.put(species + "Sample", sampleFilterAgg.getBuckets());
                           aggregations.put(species + "VariantCategory", variantCategoryFilterAgg.getBuckets());

                       }
                       if(bucket.getKey().toString().equalsIgnoreCase("expression")){

                           if(expressionLevelFilterAgg!=null)
                           aggregations.put(species + "ExpressionLevel", expressionLevelFilterAgg.getBuckets());
//                           aggregations.put(species + "CellTypeTerms", cellTypeTermsFilterAgg.getBuckets());
//                           aggregations.put(species + "StrainTerms", strainTermsFilterAgg.getBuckets());
//                           aggregations.put(species + "TissueTerms", tissueTermsFilterAgg.getBuckets());
                       }
                       if(bucket.getKey().toString().equalsIgnoreCase("expressionStudy")){

//                           if(expressionLevelFilterAgg!=null)
//                               aggregations.put(species + "ExpressionLevel", expressionLevelFilterAgg.getBuckets());
//                           aggregations.put(species + "CellTypeTerms", cellTypeTermsFilterAgg.getBuckets());
//                           aggregations.put(species + "StrainTerms", strainTermsFilterAgg.getBuckets());
//                           aggregations.put(species + "TissueTerms", tissueTermsFilterAgg.getBuckets());
                       }
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
                        aggregations.put("ontology", ontologySubcatAgg.getBuckets());
                    }

                    Terms subAgg = bucket.getAggregations().get("subspecies");
                    int k = 0;
                    for (Terms.Bucket b : subAgg.getBuckets()) {
                        String key = (String) b.getKey();
                        int speciesTypeKey= SpeciesType.parse(key);
                        if(SpeciesType.isSearchable(speciesTypeKey)){
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
                        }else if (key.equalsIgnoreCase("Pig")) {
                            k = 8;
                        }
                        else if (key.equalsIgnoreCase("Green Monkey")) {
                            k = 9;
                        }
                        else if (key.equalsIgnoreCase("Naked Mole-rat")) {
                            k = 10;
                        }

                            switch (bType) {
                            case "Gene":
                                speciesCatArray[0][k] = String.valueOf(b.getDocCount());
                                speciesCatArray[0][11] = String.valueOf(bucket.getDocCount()) ;
                                break;
                            case "Variant":
                                speciesCatArray[4][k] =  String.valueOf(b.getDocCount()) ;
                                speciesCatArray[4][11] = String.valueOf(bucket.getDocCount()) ;
                                break;
                            case "Strain":
                                speciesCatArray[1][k] =  String.valueOf(b.getDocCount());
                                speciesCatArray[1][11] = String.valueOf(bucket.getDocCount());

                                break;
                            case "QTL":
                                speciesCatArray[2][k] =  String.valueOf(b.getDocCount());
                                speciesCatArray[2][11] =  String.valueOf(bucket.getDocCount()) ;
                              //  System.out.println(key + " : "+ b.getDocCount());
                                break;
                            case "SSLP":
                                speciesCatArray[3][k] = String.valueOf(b.getDocCount());
                                speciesCatArray[3][11] = String.valueOf(bucket.getDocCount());
                                break;

                            case "Promoter":

                                speciesCatArray[5][k] =  String.valueOf(b.getDocCount());
                                speciesCatArray[5][11] = String.valueOf(bucket.getDocCount()) ;
                                break;
                            case "Cell line":
                                speciesCatArray[6][k] =  String.valueOf(b.getDocCount()) ;
                                speciesCatArray[6][11] = String.valueOf(bucket.getDocCount()) ;
                                break;
                                case "Expressed Gene":
                                    speciesCatArray[7][k] =  String.valueOf(b.getDocCount()) ;
                                    speciesCatArray[7][11] = String.valueOf(bucket.getDocCount()) ;
                                    break;
                                case "Expression Study":
                                    speciesCatArray[8][k] =  String.valueOf(b.getDocCount()) ;
                                    speciesCatArray[8][11] = String.valueOf(bucket.getDocCount()) ;
                                    break;

                            default:
                                break;
                        }
                    }}
                }

             for (int j = 0; j < 7; j++) {

                    for (int l = 0; l < 10; l++) {
                        if (speciesCatArray[j][l] == null || Objects.equals(speciesCatArray[j][l], "")) {
                            nvCount=nvCount+1;
                            speciesCatArray[j][l] = "-";
                        }
                    }
                }


                typeAgg = sr.getAggregations().get("type");
                aggregations.put("type", typeAgg.getBuckets());
                Nested assemblyAggs= sr.getAggregations().get("assemblyAggs");
                Terms assemblies=assemblyAggs.getAggregations().get("assembly");


                aggregations.put("assembly", assemblies.getBuckets());
            }
       TotalHits hits= sr.getHits().getTotalHits();
           totalHits =hits.value ;
            searchHits.add(sr.getHits().getHits());
        int matrixResultsExists=0;

        if(nvCount<63){
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
        return model;
    }
   public SearchResponse getSearchResponse(HttpServletRequest request, String term, SearchBean sb) throws UnknownHostException {
           try {
            QueryService1 qs = new QueryService1();
           return qs.getSearchResponse(term, sb);
        }catch (Exception e){
        System.out.println("UNKNOWN HOST EXCETPITON.. Reinitiating client..." );
            e.printStackTrace();
        reInitiateClient();
        try{

            QueryService1 qs = new QueryService1();
            return qs.getSearchResponse(term,sb);
        }catch (Exception exception){e.printStackTrace();}}
        return null;
    }

    public void reInitiateClient() throws UnknownHostException {
        ClientInit.init();

    }
    public SearchBean getSearchBean(HttpRequestFacade request, String term){

        String start=request.getParameter("start").replaceAll(",", ""),
                stop=request.getParameter("stop").replaceAll(",", ""),
                chr= !request.getParameter("chr").equalsIgnoreCase("all")?request.getParameter("chr"):"";

        String category = request.getParameter("category");
        String species =  new String();
        int speciesTypeKey = request.getParameter("speciesType")!=null && !request.getParameter("speciesType").equals("")?Integer.parseInt(request.getParameter("speciesType")):0;
        if(speciesTypeKey>0){
            species=SpeciesType.getCommonName(speciesTypeKey);
        }else{
            species= request.getParameter("species");
        }
        String type = request.getParameter("type");
        String subCat =  request.getParameter("subCat");
        String sortValue=request.getParameter("sortBy").equals("")?String.valueOf(0):request.getParameter("sortBy");
        String trait=request.getParameter("trait");
        String polyphenStatus=request.getParameter("polyphenStatus");
        String variantCategory=request.getParameter("variantCategory");

        String region=request.getParameter("region");
        String sample=request.getParameter("sample");

        Map<String, Sort> sortMap= SortMap.getSortMap();
        Sort s= sortMap.get(sortValue);
        String sortBy=s.getSortBy();
        String sortOrder= s.getSortOrder();
        boolean redirect= request.getParameter("redirect").equals("true");

        String pageCurrent = request.getParameter("currentPage");
        String size = request.getParameter("size");
        boolean viewAll = request.getParameter("viewall").equals("true");
        boolean page =(request.getParameter("page").equals("true"));
        int currentPage = (!Objects.equals(pageCurrent, "")) ? Integer.parseInt(pageCurrent) : 1;
        int pageSize = (!Objects.equals(size, "")) ? Integer.parseInt(request.getParameter("size")) : 50;

        String assembly=request.getParameter("assembly");

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
        sb.setPolyphenStatus(polyphenStatus);
        sb.setVariantCategory(variantCategory);

        sb.setRegion(region);
        sb.setSample(sample);


        sb.setType(type);
        sb.setViewAll(viewAll);
        sb.setCurrentPage(currentPage);
        sb.setRedirect(redirect);

        if(request.getParameter("match_type")!=null && !request.getParameter("match_type").equals("") ) sb.setMatchType(request.getParameter("match_type"));
        if(request.getParameter("objectSearch")!=null) sb.setObjectSearch((request.getParameter("objectSearch").equalsIgnoreCase("true")));
        if(request.getParameter("expressionLevel")!=null) sb.setExpressionLevel(request.getParameter("expressionLevel"));

        return sb;
    }

}
