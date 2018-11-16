package edu.mcw.rgd.search.elasticsearch1.controller;

import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.dao.impl.SearchLogDAO;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.SearchLog;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.search.elasticsearch1.model.Sort;
import edu.mcw.rgd.search.elasticsearch1.model.SortMap;
import edu.mcw.rgd.search.elasticsearch1.model.Source;
import edu.mcw.rgd.search.elasticsearch1.service.SearchService;

import edu.mcw.rgd.search.restClient.ElasticsearchRestClient;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.http.HttpHost;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.index.query.Operator;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.SearchHits;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.elasticsearch.search.fetch.subphase.highlight.HighlightBuilder;
import org.elasticsearch.search.fetch.subphase.highlight.HighlightField;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.ParseException;
import java.util.*;

/**
 * Created by jthota on 2/22/2017.
 */
public class ElasticSearchController implements Controller {

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ModelMap model = new ModelMap();


       SearchService service = new SearchService();
        String objectSearch= request.getParameter("objectSearch");
        String start=request.getParameter("start")!=null?request.getParameter("start"):"",
                stop=request.getParameter("stop")!=null?request.getParameter("stop"):"",
                chr=request.getParameter("chr")!=null && !request.getParameter("chr").equalsIgnoreCase("all")?request.getParameter("chr"):"";


        String term,
                category=null,
                species=null,
                type, subCat,
                pageCurrent,
                pageSize,
                viewAll=null,
                sortBy, sortValue,
                sortOrder,
                assembly=null,
                trait;

        boolean log=false,
                page=false,
                redirect=false;
        int mapKey=0;
        Map<String, Sort> sortMap= SortMap.getSortMap();
        if(request!=null){
            if(request.getParameter("log")!=null){log=request.getParameter("log").equals("true");}
            if(request.getParameter("redirect")!=null){redirect=request.getParameter("redirect").equals("true");}

            term = request.getParameter("term") == null ? "" : request.getParameter("term").trim();
            term=term.replaceAll("\"", "");
            if( term.startsWith("RGD:") || term.startsWith("RGD_") )
                term = term.substring(4);
            term=term.toLowerCase();

            category = request.getParameter("category") != null ? request.getParameter("category") : "";
            species = (request.getParameter("species") == null) ? "" : request.getParameter("species");
            type = (request.getParameter("type") == null) ? "" : request.getParameter("type");
            subCat = (request.getParameter("subCat") == null) ? "" : request.getParameter("subCat");
            sortValue=(request.getParameter("sortBy")==null)?"0":request.getParameter("sortBy");
            trait=(request.getParameter("trait")==null)?"":request.getParameter("trait");
            Sort s= sortMap.get(sortValue);
            sortBy=s.getSortBy();
            sortOrder= s.getSortOrder();
            String defaultAssemblyName=null;
            List<edu.mcw.rgd.datamodel.Map> assemblyMaps=MapManager.getInstance().getAllMaps(SpeciesType.parse(species), "bp");
            if((request.getParameter("assembly") != null && !request.getParameter("assembly").equals(""))){
                assembly = request.getParameter("assembly");

            }

            if(!species.equals("") && !species.equalsIgnoreCase("ALL")) {
                int speciesKey= SpeciesType.parse(species);
                edu.mcw.rgd.datamodel.Map defaultAssembly=  MapManager.getInstance().getReferenceAssembly(speciesKey);
                defaultAssemblyName=defaultAssembly.getDescription();
                    if(assembly==null){
                        assembly=defaultAssemblyName;
                    }
            }



            pageCurrent = request.getParameter("currentPage");
            pageSize = request.getParameter("size");
            viewAll = request.getParameter("viewall");

            //  boolean page = false;
            if (request.getParameter("page") != null)
                page = (request.getParameter("page").equals("true"));
            int currentPage = (pageCurrent != null) ? Integer.parseInt(pageCurrent) : 1;
            int size = (pageSize != null) ? Integer.parseInt(request.getParameter("size")) : 50;


            int postCount=0;

            String cat1= new String();
            String sp1=new String();
            Map<String, String> persistObj = new HashMap<>();
            if(request.getParameter("postCount")==null){
                 postCount=0;
            }
            if(request.getParameter("postCount")!=null){
                postCount=Integer.parseInt(request.getParameter("postCount"));
            }
                postCount= postCount+1;


           Map<String, Map> map = new HashMap<>();
            if(postCount<=1){
                cat1=category;
                sp1=species;

            }else{

                cat1=request.getParameter("cat1");
                sp1=request.getParameter("sp1");

            }

        String redirUrl = this.getRedirectUrlIfTermAccMatched(term, request,redirect,category, species, type, subCat, sortOrder, sortBy, assembly, trait, start, stop, chr);
        if (redirUrl != null) {
            response.sendRedirect(redirUrl);
            return null;
        }else{
           int defaultPageSize=(size>0)?size:50;
           SearchResponse sr=service.getSearchResponse(term,  category, species, type, subCat, currentPage, size, page, sortOrder, sortBy, assembly, trait, start, stop, chr);
            int totalPages= 0;
            if(sr!=null){
                totalPages= (int) ((sr.getHits().getTotalHits()/defaultPageSize)) + (((int) (sr.getHits().getTotalHits())%defaultPageSize>0)?1:0);
                ModelMap resultsMap=service.getResultsMap(sr,term, cat1, sp1, postCount);
                model.putAll(resultsMap);
            }
            model.put("viewall", viewAll);
            model.put("qtlTrait", trait);
            model.put("filterOption", type);
            model.put("subCat", subCat);
            model.addAttribute("currentPage", currentPage);
            model.addAttribute("totalPages", totalPages);
            model.addAttribute("term", term);
            model.addAttribute("category", category);
            model.addAttribute("species", species);
            model.addAttribute("assemblyMaps", assemblyMaps);
            model.addAttribute("defaultAssembly", assembly);
            model.addAttribute("mapKey", this.getMapKey(assembly, species));
            model.addAttribute("postCount", postCount);
            model.addAttribute("cat1", cat1);
            model.addAttribute("sp1", sp1);
            model.addAttribute("persistObj",map);
            model.addAttribute("start",start);
            model.addAttribute("stop",stop);
            model.addAttribute("chr",chr);
            if(objectSearch!=null){
                model.addAttribute("objectSearch", objectSearch);

            }


            if(log) {
                if(sr!=null)
                this.logResults(term, category, sr.getHits().getTotalHits());
            }
    }
            if (page) {

                return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/content.jsp", "model", model);
            }

        if (category != null ) {
            if(species!=null){
            if (category.equalsIgnoreCase("general") && species.equals("") && viewAll == null) {

                return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResultsSummary.jsp", "model", model);
            }
                else

                    return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResults.jsp", "model", model);
        }}

        return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResults.jsp", "model", model);
        }



    /*    ModelMap model= new ModelMap();
        ElasticsearchRestClient client= new ElasticsearchRestClient();

        SearchRequest searchRequest= new SearchRequest("rgd_index_dev").types("rgd_objects");
        SearchSourceBuilder searchSourceBuilder= new SearchSourceBuilder();
        HighlightBuilder highlightBuilder= new HighlightBuilder();
        HighlightBuilder.Field highlightSymbol=new HighlightBuilder.Field("symbol");
        HighlightBuilder.Field highlightName= new HighlightBuilder.Field("name");
        HighlightBuilder.Field highlightSource= new HighlightBuilder.Field("source");
        HighlightBuilder.Field highlightOrigin= new HighlightBuilder.Field("origin");

        highlightBuilder.field(highlightName).field(highlightSymbol).field(highlightSource).field(highlightOrigin);
        searchSourceBuilder.highlighter(highlightBuilder);
        searchSourceBuilder.query(QueryBuilders.multiMatchQuery( "LEW", "symbol","name","source","origin").operator(Operator.OR));
     //   searchSourceBuilder.query(QueryBuilders.matchAllQuery());
     //   searchSourceBuilder.query(QueryBuilders.matchQuery("id", "61104"));
    //    searchSourceBuilder.query(QueryBuilders.matchAllQuery());
        searchRequest.source(searchSourceBuilder);

        SearchResponse sr=client.getRestClient().search(searchRequest, RequestOptions.DEFAULT);
        SearchHits hits= sr.getHits();
        System.out.println("TOOK: " + sr.getTook()+"\tHITS SIZE: "+hits.getTotalHits());
            for(SearchHit h:hits){
                Map map= h.getSourceAsMap();
                System.out.println(map.get("term_acc")+"\t"+map.get("symbol")+"\t"+map.get("name") + "\t"+ map.get("source")+"\t"+ map.get("origin"));
            }

    /*    List<Source> sourceList= new ArrayList<>();
        List<String> idsTouched=new ArrayList<>();
        System.out.println("ID\tSymbol\ttName\tSource\ttOrigin\tSpeciesTypeKey\tMatchingFields");
        for(SearchHit h:hits){

            Map<java.lang.String,java.lang.Object> map=h.getSourceAsMap();
            String id= (String) map.get("id");
            if(!existsIn(idsTouched, id)) {
                Source source = new Source();
                idsTouched.add(id);
                source.setId(id);
                source.setSpeciesTypeKey(map.get("speciesTypeKey").toString());
                source.setObjectType(map.get("objectType").toString());
                Set<String> matchingFields = new HashSet<>();
                for (SearchHit hit : hits) {

                    Map<java.lang.String, java.lang.Object> map2 = hit.getSourceAsMap();
                    if (map2.get("value") != null) {
                        if (id.equalsIgnoreCase(map2.get("id").toString())) {


                            String fieldType = map2.get("fieldType").toString();
                            if (fieldType.equalsIgnoreCase("symbol")) {
                                source.setSymbol(map2.get("value").toString());

                            }
                            if (fieldType.equalsIgnoreCase("source")) {
                                source.setSource(map2.get("value").toString());
                            }
                            if (fieldType.equalsIgnoreCase("origin")) {
                                source.setOrigin(map2.get("value").toString());
                            }
                            if (fieldType.equalsIgnoreCase("name")) {
                                source.setName(map2.get("value").toString());
                            }
                            for(Map.Entry e: hit.getHighlightFields().entrySet()){
                                String key=e.getKey().toString();
                                HighlightField f= (HighlightField) e.getValue();
                                if(f.getName().equalsIgnoreCase("value")){
                                    matchingFields.add(map2.get("fieldType").toString());
                                }else
                                    matchingFields.add(f.getName());
                                //  System.out.println(key+"======\t"+f.getName());
                            }
                            source.setMatchingFields(matchingFields);
                        }

                    }

                  //  System.out.println("VALUE HIGHLIGHTED:"+hit.getHighlightFields().get("value").toString());


                }


                sourceList.add(source);
            }
        }
        for(Source s:sourceList){
            System.out.println(s.getId()+"\t"+ s.getSymbol()+"\t"+s.getName()+"\t"+s.getSource()+"\t"+s.getOrigin()+"\t"+s.getSpeciesTypeKey()+"\t"+s.getMatchingFields());
        }
        System.out.println("Total Hits:" +sr.getHits().getTotalHits());*/
   /*     client.close();*/

        /******************************************************************************************/

   /*   ModelMap model = new ModelMap();

       /* String start="100000";
        String stop="200000000";
        String chr="4";*/
  /*   SearchService service = new SearchService();
        String objectSearch= request.getParameter("objectSearch");
        String start=request.getParameter("start")!=null?request.getParameter("start"):"",
                stop=request.getParameter("stop")!=null?request.getParameter("stop"):"",
                chr=request.getParameter("chr")!=null && !request.getParameter("chr").equalsIgnoreCase("all")?request.getParameter("chr"):"";


        String term,
                category=null,
                species=null,
                type, subCat,
                pageCurrent,
                pageSize,
                viewAll=null,
                sortBy, sortValue,
                sortOrder,
                assembly=null,
                trait;

        boolean log=false,
                page=false,
                redirect=false;
        int mapKey=0;
        Map<String, Sort> sortMap= SortMap.getSortMap();
        if(request!=null){
            if(request.getParameter("log")!=null){log=request.getParameter("log").equals("true");}
            if(request.getParameter("redirect")!=null){redirect=request.getParameter("redirect").equals("true");}

            term = request.getParameter("term") == null ? "" : request.getParameter("term").trim();
            term=term.replaceAll("\"", "");
            if( term.startsWith("RGD:") || term.startsWith("RGD_") )
                term = term.substring(4);
            term=term.toLowerCase();
          
            category = request.getParameter("category") != null ? request.getParameter("category") : "";
            species = (request.getParameter("species") == null) ? "" : request.getParameter("species");
            type = (request.getParameter("type") == null) ? "" : request.getParameter("type");
            subCat = (request.getParameter("subCat") == null) ? "" : request.getParameter("subCat");
            sortValue=(request.getParameter("sortBy")==null)?"0":request.getParameter("sortBy");
            trait=(request.getParameter("trait")==null)?"":request.getParameter("trait");
            Sort s= sortMap.get(sortValue);
            sortBy=s.getSortBy();
            sortOrder= s.getSortOrder();
            String defaultAssemblyName=null;
            List<edu.mcw.rgd.datamodel.Map> assemblyMaps=MapManager.getInstance().getAllMaps(SpeciesType.parse(species), "bp");
            if((request.getParameter("assembly") != null && !request.getParameter("assembly").equals(""))){
                assembly = request.getParameter("assembly");

            }

            if(!species.equals("") && !species.equalsIgnoreCase("ALL")) {
                int speciesKey= SpeciesType.parse(species);
                edu.mcw.rgd.datamodel.Map defaultAssembly=  MapManager.getInstance().getReferenceAssembly(speciesKey);
                defaultAssemblyName=defaultAssembly.getDescription();
                    if(assembly==null){
                        assembly=defaultAssemblyName;
                    }
            }



            pageCurrent = request.getParameter("currentPage");
            pageSize = request.getParameter("size");
            viewAll = request.getParameter("viewall");

            //  boolean page = false;
            if (request.getParameter("page") != null)
                page = (request.getParameter("page").equals("true"));
            int currentPage = (pageCurrent != null) ? Integer.parseInt(pageCurrent) : 1;
            int size = (pageSize != null) ? Integer.parseInt(request.getParameter("size")) : 50;


            int postCount=0;

            String cat1= new String();
            String sp1=new String();
            Map<String, String> persistObj = new HashMap<>();
            if(request.getParameter("postCount")==null){
                 postCount=0;
            }
            if(request.getParameter("postCount")!=null){
                postCount=Integer.parseInt(request.getParameter("postCount"));
            }
                postCount= postCount+1;


           Map<String, Map> map = new HashMap<>();
            if(postCount<=1){
                cat1=category;
                sp1=species;

            }else{

                cat1=request.getParameter("cat1");
                sp1=request.getParameter("sp1");

            }

        String redirUrl = this.getRedirectUrlIfTermAccMatched(term, request,redirect,category, species, type, subCat, sortOrder, sortBy, assembly, trait, start, stop, chr);
        if (redirUrl != null) {
            response.sendRedirect(redirUrl);
            return null;
        }else{
           int defaultPageSize=(size>0)?size:50;
           SearchResponse sr=service.getSearchResponse(term,  category, species, type, subCat, currentPage, size, page, sortOrder, sortBy, assembly, trait, start, stop, chr);
            int totalPages= 0;
            if(sr!=null){
                totalPages= (int) ((sr.getHits().getTotalHits()/defaultPageSize)) + (((int) (sr.getHits().getTotalHits())%defaultPageSize>0)?1:0);
                ModelMap resultsMap=service.getResultsMap(sr,term, cat1, sp1, postCount);
                model.putAll(resultsMap);
            }
            model.put("viewall", viewAll);
            model.put("qtlTrait", trait);
            model.put("filterOption", type);
            model.put("subCat", subCat);
            model.addAttribute("currentPage", currentPage);
            model.addAttribute("totalPages", totalPages);
            model.addAttribute("term", term);
            model.addAttribute("category", category);
            model.addAttribute("species", species);
            model.addAttribute("assemblyMaps", assemblyMaps);
            model.addAttribute("defaultAssembly", assembly);
            model.addAttribute("mapKey", this.getMapKey(assembly, species));
            model.addAttribute("postCount", postCount);
            model.addAttribute("cat1", cat1);
            model.addAttribute("sp1", sp1);
            model.addAttribute("persistObj",map);
            model.addAttribute("start",start);
            model.addAttribute("stop",stop);
            model.addAttribute("chr",chr);
            if(objectSearch!=null){
                model.addAttribute("objectSearch", objectSearch);

            }


            if(log) {
                if(sr!=null)
                this.logResults(term, category, sr.getHits().getTotalHits());
            }
    }
            if (page) {

                return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/content.jsp", "model", model);
            }

        if (category != null ) {
            if(species!=null){
            if (category.equalsIgnoreCase("general") && species.equals("") && viewAll == null) {

                return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResultsSummary.jsp", "model", model);
            }
                else

                    return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResults.jsp", "model", model);
        }}

        return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResults.jsp", "model", model);
        }*/
          return null;

    }


    /**s
     * Build redirect URL if "term" matched with "term_acc"
     * @param term
     * @param request
     * @return
     * @throws IOException
     * @throws ParseException
     */
    public String getRedirectUrlIfTermAccMatched(String term, HttpServletRequest request, boolean redirect, String category, String species, String type,String subCat, String sortOrder, String sortBy, String assembly, String trait, String start, String stop, String chr) throws IOException, ParseException {

        SearchService service=new SearchService();
        SearchResponse sr=new SearchResponse();
        if(redirect){
           sr=service.getSearchResponse(term,  category, species, type, subCat, 0,0, false, sortOrder, sortBy, assembly, trait, start, stop, chr);
           }else {
           sr = service.getSearchResponse(term, category);
        }
        if(sr!=null) {
            if (sr.getHits() != null)
                return getRedirectUrl(sr, request, term);
            else return null;
        }
        return null;
    }

    public String getRedirectUrl(SearchResponse sr, HttpServletRequest request, String term){
        RGDManagementDAO rdao = new RGDManagementDAO();
        RgdId id = null;
        String redirUrl =null;
        int rgdIdValue = 0;

        if (sr.getHits().getTotalHits() == 1) {
          this.logResults(term,request.getParameter("category"), sr.getHits().getTotalHits());

           String docId=sr.getHits().getHits()[0].getId();

            try {
              //  if (!source.getString("term_acc").contains(":")) {
                if (!docId.contains(":")) {
                    rgdIdValue = Integer.parseInt(docId);
                    id = rdao.getRgdId2(rgdIdValue);
                }

                if (id != null) {
                    redirUrl = Link.it(rgdIdValue, id.getObjectKey());
                    // Link.it handles this rgd_id with this object_key -- redirect to right report page
                } else {
                    if(docId.contains(":"))
                    redirUrl = Link.ontAnnot(docId);
                }
                if(redirUrl!=null && !redirUrl.equals(String.valueOf(rgdIdValue))){
                //   redirUrl = request.getScheme() + "://" + request.getServerName() + ":8080" + redirUrl;
                      redirUrl = request.getScheme() + "://" + request.getServerName()  + redirUrl;


                    return redirUrl;
                }
             } catch (Exception e) {
            }

            return null;
    }else{
            try {

                int rgdid = Integer.parseInt(term);

                id=rdao.getRgdId2(rgdid);
                if (id != null) {
                    redirUrl = Link.it(rgdid, id.getObjectKey());
                    // Link.it handles this rgd_id with this object_key -- redirect to right report page
                }

                if(redirUrl!=null && !redirUrl.equals(String.valueOf(rgdid))){
                //   redirUrl = request.getScheme() + "://" + request.getServerName() + ":8080" + redirUrl;
                   redirUrl = request.getScheme() + "://" + request.getServerName()  + redirUrl;


                    return redirUrl;
                }

                return null;
            }catch (Exception e){

                return null;
            }
        }


}
    public void logResults(String term, String category,long results){
        SearchLogDAO searchLogDAO= new SearchLogDAO();
        SearchLog searchLog= new SearchLog();
        searchLog.setSearchTerm(term);
        searchLog.setCategory(category);
        searchLog.setResults(results);
        try {
            searchLogDAO.insert(searchLog);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public int getMapKey(String assembly, String species) throws Exception {

        int mapKey=0;
       List<edu.mcw.rgd.datamodel.Map> maps= MapManager.getInstance().getAllMaps(SpeciesType.parse(species));
            for(edu.mcw.rgd.datamodel.Map m:maps){
                if(m.getDescription().equalsIgnoreCase(assembly)){
                    mapKey=m.getKey();
}
            }
        return mapKey;
    }
    public boolean existsIn(List<String> idsTouched, String id){
        for(String i:idsTouched){
            if(i.equalsIgnoreCase(id)){
                return true;
            }
        }
        return false;
    }
}
