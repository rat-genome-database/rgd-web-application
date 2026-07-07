package edu.mcw.rgd.search.elasticsearch1.service;


import co.elastic.clients.elasticsearch._types.aggregations.Aggregate;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsAggregate;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsBucket;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.search.elasticsearch1.model.SearchBean;
import edu.mcw.rgd.search.elasticsearch1.model.Sort;
import edu.mcw.rgd.search.elasticsearch1.model.SortMap;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.EsBucket;
import edu.mcw.rgd.web.EsHit;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.ui.ModelMap;

import jakarta.servlet.http.HttpServletRequest;
import java.io.IOException;

import java.net.UnknownHostException;
import java.util.*;
import java.util.logging.Logger;

public class SearchService {

    private static final Logger logger = Logger.getLogger(SearchService.class.getName());

    public ModelMap getResultsMap(SearchResponse<Map> sr, String term) throws IOException {
        ModelMap model = new ModelMap();

        long totalHits = 0;

        Map<String, List<EsBucket>> aggregations = new HashMap<>();
        String[][] speciesCatArray = new String[9][13];
        int matrixElements = (9 * 13);
        speciesCatArray[0][0] = "Gene";
        speciesCatArray[1][0] = "Gene (With Expression)";

        speciesCatArray[2][0] = "Strain";
        speciesCatArray[3][0] = "QTL";
        speciesCatArray[4][0] = "SSLP";
        speciesCatArray[5][0] = "Variant";
        speciesCatArray[6][0] = "Promoter";
        speciesCatArray[7][0] = "Cell line";

        speciesCatArray[8][0] = "Expression Study";

        long totalTerms = 0;
        int nvCount = 0;

        Map<String, Aggregate> aggResults = sr.aggregations();
        if (aggResults != null && !aggResults.isEmpty()) {
            StringTermsAggregate speciesAgg = aggResults.get("species").sterms();
            List<StringTermsBucket> speciesBuckets = speciesAgg.buckets().array();
            aggregations.put("species", toEsBuckets(speciesBuckets));

            StringTermsAggregate categoryAgg = aggResults.get("category").sterms();
            List<StringTermsBucket> catBuckets = categoryAgg.buckets().array();
            aggregations.put("category", toEsBuckets(catBuckets));


            for (StringTermsBucket speciesBkt : speciesBuckets) {
                StringTermsAggregate catFilterAgg = speciesBkt.aggregations().get("categoryFilter").sterms();
                String species = speciesBkt.key().stringValue().toLowerCase().replace(" ", "").replace("-", "");

                List<StringTermsBucket> catFilterBuckets = catFilterAgg.buckets().array();
                aggregations.put(species, toEsBuckets(catFilterBuckets));

                Aggregate speciesAssemblyAggs = speciesBkt.aggregations().get("assemblyAggs");
                if (speciesAssemblyAggs != null && speciesAssemblyAggs.isNested()) {
                    StringTermsAggregate speciesAssemblies = optSterms(speciesAssemblyAggs.nested().aggregations(), "assembly");
                    if (speciesAssemblies != null) {
                        aggregations.put(species + "Assembly", toEsBuckets(speciesAssemblies.buckets().array()));
                    }
                }
                for (StringTermsBucket bucket : catFilterBuckets) {
                    Map<String, Aggregate> subAggs = bucket.aggregations();
                    StringTermsAggregate typeFilterAgg = optSterms(subAggs, "typeFilter");
                    StringTermsAggregate traitFilterAgg = optSterms(subAggs, "trait");
                    StringTermsAggregate polyphenFilterAgg = optSterms(subAggs, "polyphen");
                    StringTermsAggregate regionFilterAgg = optSterms(subAggs, "region");
                    StringTermsAggregate sampleFilterAgg = optSterms(subAggs, "sample");
                    StringTermsAggregate variantCategoryFilterAgg = optSterms(subAggs, "variantCategory");
                    StringTermsAggregate expressionLevelFilterAgg = optSterms(subAggs, "expressionLevel");
                    StringTermsAggregate strainTermsFilterAgg = optSterms(subAggs, "strainTerms");
                    StringTermsAggregate tissueTermsFilterAgg = optSterms(subAggs, "tissueTerms");
                    StringTermsAggregate cellTypeTermsFilterAgg = optSterms(subAggs, "cellTypeTerms");
                    StringTermsAggregate conditionsFilterAgg = optSterms(subAggs, "conditions");
                    StringTermsAggregate expressionSourceFilterAgg = optSterms(subAggs, "expressionSource");

                    String bucketKey = bucket.key().stringValue();
                    if (bucketKey.equalsIgnoreCase("variant")) {
                        putIfNotNull(aggregations, species + "Polyphen", polyphenFilterAgg);
                        putIfNotNull(aggregations, species + "Region", regionFilterAgg);
                        putIfNotNull(aggregations, species + "Sample", sampleFilterAgg);
                        putIfNotNull(aggregations, species + "VariantCategory", variantCategoryFilterAgg);
                    }
                    if (bucketKey.equalsIgnoreCase("expressed Gene")) {
                        putIfNotNull(aggregations, species + "ExpressionLevel", expressionLevelFilterAgg);
                        putIfNotNull(aggregations, species + "CellTypeTerms", cellTypeTermsFilterAgg);
                        putIfNotNull(aggregations, species + "Conditions", conditionsFilterAgg);
                        putIfNotNull(aggregations, species + "StrainTerms", strainTermsFilterAgg);
                        putIfNotNull(aggregations, species + "TissueTerms", tissueTermsFilterAgg);
                        putIfNotNull(aggregations, species + "ExpressionSource", expressionSourceFilterAgg);
                        putIfNotNull(aggregations, species + "ExpressionGeneType", typeFilterAgg);
                    }
                    if (bucketKey.equalsIgnoreCase("expression Study")) {
                        putIfNotNull(aggregations, species + "ExpressionLevel", expressionLevelFilterAgg);
                        putIfNotNull(aggregations, species + "CellTypeTerms", cellTypeTermsFilterAgg);
                        putIfNotNull(aggregations, species + "Conditions", conditionsFilterAgg);
                        putIfNotNull(aggregations, species + "StrainTerms", strainTermsFilterAgg);
                        putIfNotNull(aggregations, species + "TissueTerms", tissueTermsFilterAgg);
                        putIfNotNull(aggregations, species + "ExpressionSource", expressionSourceFilterAgg);
                        putIfNotNull(aggregations, species + bucketKey.replace(" ", ""), typeFilterAgg);
                    }
                    if (bucketKey.equalsIgnoreCase("qtl")) {
                        putIfNotNull(aggregations, species + bucketKey, traitFilterAgg);
                    } else {
                        putIfNotNull(aggregations, species + bucketKey, typeFilterAgg);
                    }
                }
            }
            for (StringTermsBucket bucket : catBuckets) {

                String bucketType = bucket.key().stringValue();
                String bType = bucketType;

                // Debug logging for Expression Study
                if (bucketType.equalsIgnoreCase("Expression Study")) {
                    logger.info("Expression Study bucket found with docCount: " + bucket.docCount());
                    StringTermsAggregate subAgg = optSterms(bucket.aggregations(), "subspecies");
                    if (subAgg != null) {
                        for (StringTermsBucket b : subAgg.buckets().array()) {
                            logger.info("  Subspecies: " + b.key().stringValue() + " count: " + b.docCount());
                        }
                    } else {
                        logger.info("  No subspecies aggregation found for Expression Study");
                    }
                }

                if (bucketType.equalsIgnoreCase("ontology")) {
                    StringTermsAggregate ontologySubcatAgg = optSterms(bucket.aggregations(), "ontologies");
                    if (ontologySubcatAgg != null) {
                        aggregations.put("ontology", toEsBuckets(ontologySubcatAgg.buckets().array()));
                    }
                }

                StringTermsAggregate subAgg = optSterms(bucket.aggregations(), "subspecies");
                if (subAgg == null) continue;
                int k = 0;
                for (StringTermsBucket b : subAgg.buckets().array()) {
                    String key = b.key().stringValue();
                    int speciesTypeKey = SpeciesType.parse(key);
                    if (SpeciesType.isSearchable(speciesTypeKey)) {
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
                        } else if (key.equalsIgnoreCase("Pig")) {
                            k = 8;
                        } else if (key.equalsIgnoreCase("Green Monkey")) {
                            k = 9;
                        } else if (key.equalsIgnoreCase("Naked Mole-rat")) {
                            k = 10;
                        } else if (key.equalsIgnoreCase("Black Rat")) {
                            k = 11;
                        }
                        int all = 12;

                        switch (bType) {
                            case "Gene":
                                speciesCatArray[0][k] = String.valueOf(b.docCount());
                                speciesCatArray[0][all] = String.valueOf(bucket.docCount());
                                break;
                            case "Expressed Gene":
                                speciesCatArray[1][k] = String.valueOf(b.docCount());
                                speciesCatArray[1][all] = String.valueOf(bucket.docCount());
                                break;

                            case "Strain":
                                speciesCatArray[2][k] = String.valueOf(b.docCount());
                                speciesCatArray[2][all] = String.valueOf(bucket.docCount());

                                break;
                            case "QTL":
                                speciesCatArray[3][k] = String.valueOf(b.docCount());
                                speciesCatArray[3][all] = String.valueOf(bucket.docCount());
                                break;
                            case "SSLP":
                                speciesCatArray[4][k] = String.valueOf(b.docCount());
                                speciesCatArray[4][all] = String.valueOf(bucket.docCount());
                                break;
                            case "Variant":
                                speciesCatArray[5][k] = String.valueOf(b.docCount());
                                speciesCatArray[5][all] = String.valueOf(bucket.docCount());
                                break;
                            case "Promoter":

                                speciesCatArray[6][k] = String.valueOf(b.docCount());
                                speciesCatArray[6][all] = String.valueOf(bucket.docCount());
                                break;
                            case "Cell line":
                                speciesCatArray[7][k] = String.valueOf(b.docCount());
                                speciesCatArray[7][all] = String.valueOf(bucket.docCount());
                                break;

                            case "Expression Study":
                                speciesCatArray[8][k] = String.valueOf(b.docCount());
                                speciesCatArray[8][all] = String.valueOf(bucket.docCount());
                                break;

                            default:
                                break;
                        }
                    }
                }
            }

            // Debug: log Expression Study row before null-fill
            logger.info("Expression Study row BEFORE null-fill: " + Arrays.toString(speciesCatArray[8]));

            for (int j = 0; j < 9; j++) {

                for (int l = 1; l < 13; l++) {
                    if (speciesCatArray[j][l] == null || Objects.equals(speciesCatArray[j][l], "")) {
                        nvCount = nvCount + 1;
                        speciesCatArray[j][l] = "-";
                    }
                }
            }

            // Debug: log Expression Study row after null-fill
            logger.info("Expression Study row AFTER null-fill: " + Arrays.toString(speciesCatArray[8]));


            StringTermsAggregate typeAgg = optSterms(aggResults, "type");
            if (typeAgg != null) {
                aggregations.put("type", toEsBuckets(typeAgg.buckets().array()));
            }
            Aggregate assemblyAggsAgg = aggResults.get("assemblyAggs");
            if (assemblyAggsAgg != null && assemblyAggsAgg.isNested()) {
                StringTermsAggregate assemblies = optSterms(assemblyAggsAgg.nested().aggregations(), "assembly");
                if (assemblies != null) {
                    aggregations.put("assembly", toEsBuckets(assemblies.buckets().array()));
                }
            }
        }
        totalHits = sr.hits().total() != null ? sr.hits().total().value() : 0;

        // Wrap hits in EsHit[] so JSPs that read hit.sourceAsMap still work
        List<Hit<Map>> rawHits = sr.hits().hits();
        EsHit[] searchHits = new EsHit[rawHits.size()];
        for (int i = 0; i < rawHits.size(); i++) {
            Hit<Map> h = rawHits.get(i);
            @SuppressWarnings("unchecked")
            Map<String, Object> source = (Map<String, Object>) h.source();
            searchHits[i] = new EsHit(h.id(), source, h.highlight());
        }
        int matrixResultsExists = 0;

        if (nvCount < matrixElements) {
            matrixResultsExists = 1;
        }
        String message = "";
        if (totalHits == 0) {
            message = "0 results found for \"" + term + "\"";
        }

        model.addAttribute("totalHits", totalHits);
        model.addAttribute("aggregations", aggregations);
        model.addAttribute("hitArray", searchHits);
        model.addAttribute("speciesCatArray", speciesCatArray);
        model.addAttribute("message", message);
        model.addAttribute("matrixResultsExists", matrixResultsExists);
        model.addAttribute("ontologyTermCount", totalTerms);
        model.addAttribute("took", sr.took());
        return model;
    }

    private static StringTermsAggregate optSterms(Map<String, Aggregate> aggs, String name) {
        Aggregate a = aggs.get(name);
        if (a == null) return null;
        if (!a.isSterms()) return null;
        return a.sterms();
    }

    private static void putIfNotNull(Map<String, List<EsBucket>> aggregations, String key, StringTermsAggregate agg) {
        if (agg == null) return;
        aggregations.put(key, toEsBuckets(agg.buckets().array()));
    }

    private static List<EsBucket> toEsBuckets(List<StringTermsBucket> buckets) {
        List<EsBucket> out = new ArrayList<>(buckets.size());
        for (StringTermsBucket b : buckets) {
            out.add(new EsBucket(b.key().stringValue(), b.docCount()));
        }
        return out;
    }

   public SearchResponse<Map> getSearchResponse(HttpServletRequest request, String term, SearchBean sb) throws UnknownHostException {
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
        if(category==null || category.equals("")){
            category="general";
        }
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
        if(request.getParameter("strainTerms")!=null) sb.setStrainTerms(request.getParameter("strainTerms"));
        if(request.getParameter("cellTypeTerms")!=null) sb.setCellTypeTerms(request.getParameter("cellTypeTerms"));
        if(request.getParameter("conditions")!=null) sb.setConditions(request.getParameter("conditions"));
        if(request.getParameter("tissueTerms")!=null) {
            sb.setTissueTerms(request.getParameter("tissueTerms"));}
        if(request.getParameter("source")!=null) {
            sb.setExpressionSource(request.getParameter("source"));}

        return sb;
    }

}
