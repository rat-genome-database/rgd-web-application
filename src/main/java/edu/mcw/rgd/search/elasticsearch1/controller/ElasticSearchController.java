package edu.mcw.rgd.search.elasticsearch1.controller;

import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.dao.impl.SearchLogDAO;
import edu.mcw.rgd.datamodel.Map;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.SearchLog;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.search.RGDSearchController;
import edu.mcw.rgd.search.elasticsearch1.model.SearchBean;
import edu.mcw.rgd.search.elasticsearch1.service.SearchService;

import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.RequestDispatcher;
import org.apache.lucene.search.TotalHits;
import org.elasticsearch.action.search.SearchResponse;

import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Created by jthota on 2/22/2017.
 */
public class ElasticSearchController extends RGDSearchController {

    static  java.util.Map<Integer, String> maps=new LinkedHashMap<>();
    static {
        MapDAO mapDAO=new MapDAO();
        try {
            List<Map> mapList=mapDAO.getActiveMapsByRankASC();
            java.util.Map<Integer, String> rgdMaps=new LinkedHashMap<>();
            for(Map m:mapList){
              rgdMaps.put( m.getRank(),m.getDescription());
            }
            maps= Collections.unmodifiableMap(rgdMaps);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public Report getReport(edu.mcw.rgd.process.search.SearchBean search, HttpRequestFacade req) throws Exception {
        return null;
    }

    @Override
    public String getViewUrl() throws Exception {
        return null;
    }

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req=new HttpRequestFacade(request);
        ModelMap model = new ModelMap();

        ArrayList error = new ArrayList();
        SearchService service = new SearchService();
        String searchTerm = req.getParameter("term").trim();
        int termLength=searchTerm.replaceAll("\\*", "").length();
        if (((termLength < 1 || termLength > 200 ) && (req.getParameter("category").equalsIgnoreCase("general") || req.getParameter("category").equals("")))
        || ((!req.getParameter("category").equalsIgnoreCase("general") && !req.getParameter("category").equals("") && termLength>200))) {
            if(termLength>200)
            error.add("Search term must be less than 200 characters long. Please search again.");
            else
                error.add("Search term must be at least 2 characters long. Please search again.");
            request.setAttribute("error", error);
            RequestDispatcher dispatcher = request.getServletContext().getRequestDispatcher("/");
            dispatcher.forward(request, response);
            return null;
        }

        if( searchTerm.startsWith("RGD:") || searchTerm.startsWith("RGD_") || searchTerm.startsWith("RGD ") )
            searchTerm = searchTerm.substring(4);
        else if(searchTerm.startsWith("RGD"))
            searchTerm=searchTerm.substring(3);
        else {
          searchTerm=searchTerm.toLowerCase().replaceAll("rgd", " ").trim();
        }

        searchTerm=searchTerm.toLowerCase();
     //   String term=searchTerm.replaceAll("[^\\w\\s]","");
        String term=searchTerm;
        SearchBean sb= service.getSearchBean(req, term);
        String objectSearch= req.getParameter("objectSearch");

            boolean log= (req.getParameter("log").equals("true"));
            String cat1= new String();
            String sp1=new String();
            List<edu.mcw.rgd.datamodel.Map> assemblyMaps=MapManager.getInstance().getAllMaps(SpeciesType.parse(sb.getSpecies()), "bp");
            String assembly=req.getParameter("assembly");
            if(assembly.equals("")){
                assembly="all";
            }
            sb.setAssembly(assembly);
           boolean page =(req.getParameter("page").equals("true"));
           int postCount=!req.getParameter("postCount").equals("")?Integer.parseInt(req.getParameter("postCount")):0;
           postCount= postCount+1;
           if(postCount<=1){
                cat1=sb.getCategory();
                sp1=sb.getSpecies();
            }else{
                cat1=req.getParameter("cat1");
                sp1=req.getParameter("sp1");
            }

            String redirUrl = this.getRedirectUrl(request, term, sb);

            if (redirUrl != null) {
                response.sendRedirect(redirUrl);
                return null;
            }else{
            int defaultPageSize=(sb.getSize()>0)?sb.getSize():50;
            SearchResponse sr=service.getSearchResponse(request,term, sb);
            int totalPages= 0;
            if(sr!=null){
               TotalHits hits=sr.getHits().getTotalHits();
                       totalPages= (int)((hits.value/defaultPageSize)) + (((int) (hits.value)%defaultPageSize>0)?1:0);
                ModelMap resultsMap=service.getResultsMap(sr,term);
                if(log) {
                    this.logResults(term, sb.getCategory(), hits.value);
                }
                model.putAll(resultsMap);
            }
            int mapKey=this.getMapKey(assembly, sb.getSpecies());
            model.addAttribute("assemblyMaps", assemblyMaps);
            model.addAttribute("assemblyMapsByRank", maps);
            model.addAttribute("mapKey", mapKey);
            model.addAttribute("defaultAssembly", assembly);
            model.addAttribute("totalPages", totalPages);
            model.addAttribute("postCount", postCount);
            model.addAttribute("cat1", cat1);
            model.addAttribute("sp1", sp1);
            model.addAttribute("term", term);
            model.addAttribute("searchBean", sb);
            request.setAttribute("searchBean", sb);
            if(objectSearch!=null){model.addAttribute("objectSearch", objectSearch);}

            if (page) { return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/content.jsp", "model", model);}

        if (sb.getCategory() != null ) {
            if(sb.getSpecies()!=null){
            if (sb.getCategory().equalsIgnoreCase("general") && sb.getSpecies().equals("") && !sb.isViewAll()) {
               return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResultsSummary.jsp", "model", model);
            }else
              return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResults.jsp", "model", model);
        }}
        return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/searchResults.jsp", "model", model);
        }
     }

    public String getRedirectUrl(HttpServletRequest request, String term, SearchBean sb){
        RGDManagementDAO rdao = new RGDManagementDAO();
        String redirUrl =null;
        try {
            if(term.matches("[0-9]+") && !sb.isRedirect()) { // if the seartch term is RGDID
                int rgdid = Integer.parseInt(term);
                RgdId id = rdao.getRgdId2(rgdid);
                if(id != null) {
                    if(id.getSpeciesTypeKey()!=1 && id.getObjectKey()==7)
                        redirUrl="/rgdweb/report/variants/main.html?id="+id.getRgdId();
                    else
                        redirUrl= Link.it(rgdid, id.getObjectKey()) ;

                }
                // Link.it handles this rgd_id with this object_key -- redirect to right report page
                if (redirUrl != null && !redirUrl.equals(String.valueOf(rgdid))) {
                    return request.getScheme() + "://" + request.getServerName() + redirUrl;

                }
            }else if (term.toLowerCase().startsWith("rs") && term.substring(2).matches("[0-9]+" ))
            {
                redirUrl=Link.rsId(term);
                return request.getScheme() + "://" + request.getServerName() + redirUrl;

            }
            else {
                SearchService service = new SearchService();
                SearchResponse sr;
             // if in the summarys results there is only one result, then redirect to report page directly.
                if(sb.isRedirect()) {
                    sr = service.getSearchResponse(request, term, sb);
                    if (sr != null) {
                    TotalHits hits=sr.getHits().getTotalHits();
                        if (sr.getHits() != null && hits.value == 1)
                            return getUrl(sr, request, term);
                        else return null;
                    }
                    return null;
                }}

        }catch (Exception e){

            e.printStackTrace();
        }
        return null;
    }
    public String getUrl(SearchResponse sr, HttpServletRequest request,String term){
        this.logResults(term,request.getParameter("category"), sr.getHits().getTotalHits().value);
        int rgdIdValue=0;

        RGDManagementDAO rdao= new RGDManagementDAO();
        String redirUrl=null;
        String docId= (String) sr.getHits().getHits()[0].getSourceAsMap().get("term_acc");
        String category=(String) sr.getHits().getHits()[0].getSourceAsMap().get("category");
        String species=(String) sr.getHits().getHits()[0].getSourceAsMap().get("species");

        String rsId=(String) sr.getHits().getHits()[0].getSourceAsMap().get("rsId");

        try {
            if(rsId!=null && !rsId.equals("")){
                redirUrl = Link.rsId(rsId);
            }else
      if (docId.matches("[0-9]+") && docId.length() > 2) {
                rgdIdValue = Integer.parseInt(docId);
                RgdId  id = rdao.getRgdId2(rgdIdValue);
           if (id != null) {
               if(!category.equalsIgnoreCase("variant") || species.equalsIgnoreCase("human"))
               redirUrl = Link.it(rgdIdValue, id.getObjectKey());
                // Link.it handles this rgd_id with this object_key -- redirect to right report page
               else {
                   if(category.equalsIgnoreCase("variant") && !species.equalsIgnoreCase("human")){
                       redirUrl="/rgdweb/report/variants/main.html?id="+rgdIdValue;
                   }
               }
            }
        }else {
          if(docId.contains(":"))
              redirUrl = Link.ontAnnot(docId);

      }
            if(redirUrl!=null && !redirUrl.equals(String.valueOf(rgdIdValue))){
            //      redirUrl = request.getScheme() + "://" + request.getServerName() + ":8080" + redirUrl;
              redirUrl = request.getScheme() + "://" + request.getServerName() + redirUrl;

            }
        } catch (Exception e) {e.printStackTrace();}

        return redirUrl;
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
                    break;
                    }
            }
        if(mapKey==0 && species!=null && !species.equals("")){
            Map referenceAssemblyMap=MapManager.getInstance().getReferenceAssembly(SpeciesType.parse(species));
            mapKey=referenceAssemblyMap.getKey();
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
