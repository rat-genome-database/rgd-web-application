package edu.mcw.rgd.search.elasticsearch1.controller;

import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.dao.impl.SearchLogDAO;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.SearchLog;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.search.elasticsearch1.model.SearchBean;
import edu.mcw.rgd.search.elasticsearch1.service.SearchService;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.apache.lucene.search.TotalHits;
import org.elasticsearch.action.search.SearchResponse;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Objects;

/**
 * Created by jthota on 2/22/2017.
 */
public class PhenominerSearchController implements Controller {

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req=new HttpRequestFacade(request);
        ModelMap model = new ModelMap();
        SearchService service = new SearchService();

            String term = req.getParameter("term").trim();
            term=term.replaceAll("\"", "");
            if(term.length()>100){
                response.sendRedirect(request.getContextPath());
                return null;
            }
            if( term.startsWith("RGD:") || term.startsWith("RGD_") )
                term = term.substring(4);
            term=term.toLowerCase();
            SearchBean sb= service.getSearchBean(req, term);
            String objectSearch= req.getParameter("objectSearch");

            boolean log= (req.getParameter("log").equals("true"));

            String defaultAssemblyName=null;
            String cat1= new String();
            String sp1=new String();
            String assembly=req.getParameter("assembly");
            if(!sb.getSpecies().equals("") && !sb.getSpecies().equalsIgnoreCase("ALL")) {
                int speciesKey= SpeciesType.parse(sb.getSpecies());
                edu.mcw.rgd.datamodel.Map defaultAssembly=  MapManager.getInstance().getReferenceAssembly(speciesKey);
                defaultAssemblyName=defaultAssembly.getDescription();
                    if(Objects.equals(assembly, "")){
                        assembly=defaultAssemblyName;
                    }
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
            }else {
                int defaultPageSize = 1000;
                sb.setSize(defaultPageSize);
                SearchResponse sr = service.getSearchResponse(request, term, sb);
                int totalPages = 0;
                if (sr != null) {
                    TotalHits hits = sr.getHits().getTotalHits();
                    totalPages = (int) ((hits.value / defaultPageSize)) + (((int) (hits.value) % defaultPageSize > 0) ? 1 : 0);
                    ModelMap resultsMap = service.getResultsMap(sr, term);
                    if (log) {
                        if (sr != null) this.logResults(term, sb.getCategory(), hits.value);
                    }
                    model.putAll(resultsMap);
                }
                if(sb.getSpecies()!=null && !sb.getSpecies().equals("") && !sb.getSpecies().equalsIgnoreCase("all")) {
                    List<edu.mcw.rgd.datamodel.Map> assemblyMaps = MapManager.getInstance().getAllMaps(SpeciesType.parse(sb.getSpecies()), "bp");
                    model.addAttribute("assemblyMaps", assemblyMaps);
                }
                model.addAttribute("defaultAssembly", assembly);
                model.addAttribute("mapKey", this.getMapKey(assembly, sb.getSpecies()));
                model.addAttribute("totalPages", totalPages);
                model.addAttribute("postCount", postCount);
                model.addAttribute("cat1", cat1);
                model.addAttribute("sp1", sp1);
                model.addAttribute("term", term);
                model.addAttribute("searchBean", sb);

                if (objectSearch != null) {
                    model.addAttribute("objectSearch", objectSearch);
                }

                if (page) {
                    return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/content.jsp", "model", model);
                }


                return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/elasticsearch1/phenominerTermSearch.jsp", "model", model);
            }

     }

    public String getRedirectUrl(HttpServletRequest request, String term, SearchBean sb){
        RGDManagementDAO rdao = new RGDManagementDAO();

        try {
            if(term.matches("[0-9]+") && !sb.isRedirect()) { // if the seartch term is RGDID
                int rgdid = Integer.parseInt(term);
                RgdId id = rdao.getRgdId2(rgdid);
                String redirUrl = null;
                if(id != null) {
                    if(id.getSpeciesTypeKey()!=1 && id.getObjectKey()==7)
                        redirUrl="/rgdweb/report/variants/main.html?id="+id.getRgdId();
                    else
                        redirUrl= Link.it(rgdid, id.getObjectKey()) ;

                }
                // Link.it handles this rgd_id with this object_key -- redirect to right report page
                if (redirUrl != null && !redirUrl.equals(String.valueOf(rgdid))) {
                    //   redirUrl = RgdContext.getHostname() + ":8080" + redirUrl;
                    redirUrl = RgdContext.getHostname() + redirUrl;
                    return redirUrl;
                }
            }else {


                    SearchService service = new SearchService();
                    SearchResponse sr;
             if(sb.isRedirect()) { // if in the summarys results there is only one result, then redirect to report page directly.
                   sr = service.getSearchResponse(request, term, sb);
                }else{
                    sr = service.getSearchResponse(request, term, null);
                }
            //    sr = service.getSearchResponse(request, term, sb);
                if (sr != null) {
                    TotalHits hits=sr.getHits().getTotalHits();
                        if (sr.getHits() != null && hits.value == 1)
                            return getUrl(sr, request, term);
                        else return null;
                    }
                    return null;
                }

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


        try {
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
            //      redirUrl = RgdContext.getHostname() + ":8080" + redirUrl;
              redirUrl = RgdContext.getHostname() + redirUrl;

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
        if(species!=null && !species.equals("") && !species.equalsIgnoreCase("all")) {
            List<edu.mcw.rgd.datamodel.Map> maps = MapManager.getInstance().getAllMaps(SpeciesType.parse(species));
            for (edu.mcw.rgd.datamodel.Map m : maps) {
                if (m.getDescription().equalsIgnoreCase(assembly)) {
                    mapKey = m.getKey();
                    break;
                }
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
