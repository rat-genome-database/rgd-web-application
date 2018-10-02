package edu.mcw.rgd.search.elasticsearch1.controller;


import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.dao.impl.SearchLogDAO;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.SearchLog;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.search.elasticsearch.client.ClientInit;
import edu.mcw.rgd.search.elasticsearch1.model.RgdIndex;
import edu.mcw.rgd.search.elasticsearch1.model.Sort;
import edu.mcw.rgd.search.elasticsearch1.model.SortMap;
import edu.mcw.rgd.search.elasticsearch1.service.SearchService;

import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;
import org.elasticsearch.index.query.QueryBuilders;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.ParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by jthota on 2/22/2017.
 */
public class ElasticSearchController implements Controller {

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelMap model = new ModelMap();

       /* String start="100000";
        String stop="200000000";
        String chr="4";*/
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

           int totalPages= (int) ((sr.getHits().getTotalHits()/defaultPageSize)) + (((int) (sr.getHits().getTotalHits())%defaultPageSize>0)?1:0);
            if(sr!=null){
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


            if(log)
            this.logResults(term,category, sr.getHits().getTotalHits());

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
        if(sr.getHits()!=null)
     return getRedirectUrl(sr, request, term);
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
}
