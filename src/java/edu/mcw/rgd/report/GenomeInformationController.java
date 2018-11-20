package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.datamodel.*;

import edu.mcw.rgd.report.GenomeModel.ExternalDBLinks;
import edu.mcw.rgd.report.GenomeModel.ExternalDbs;
import edu.mcw.rgd.search.elasticsearch.client.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchResponse;

import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;

import java.util.HashMap;
import java.util.List;

/**
 * Created by jthota on 10/11/2017.
 */
public class GenomeInformationController implements Controller{
    MapDAO mdao= new MapDAO();

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelMap model= new ModelMap();
        String species= request.getParameter("species");
        String assembly= request.getParameter("assembly");
        String action= request.getParameter("action");
        String key= request.getParameter("mapKey");
        String infoTable=request.getParameter("infoTable");
        boolean isDetailsPage=false;
        if(request.getParameter("details")!=null){
            isDetailsPage=true;
        }

        int mapKey=0;
        if (key != null) {

            mapKey=Integer.parseInt(key);
        }
        List<SearchHit[]> hits;
        model.addAttribute("speciesList", this.getSpeciesList());

            if (isDetailsPage || species != null || action != null) {
                int speciesTypeKey = SpeciesType.parse(species);

                if (assembly != null && key == null) {
                    mapKey = this.getMapKey(assembly, speciesTypeKey);

                }
                model.addAttribute("species", species);
                if (assembly == null && mapKey==0) {
                    Map map = mdao.getPrimaryRefAssembly(speciesTypeKey);
                    assembly = map.getDescription();
                     mapKey = map.getKey();
                 }else{
                    if(assembly==null){
                        Map map= mdao.getMap(mapKey);
                        assembly=map.getDescription();
                    }
                }

                List<Chromosome> chromosomes = mdao.getChromosomes(mapKey);
                ExternalDBLinks xlinks= new ExternalDBLinks();
                ExternalDbs extDbLinks= xlinks.getXLinks(mapKey,null, null);
                model.addAttribute("assembly", assembly);
                model.addAttribute("mapKey", mapKey);

                model.addAttribute("assemblyList", this.getAssemblyList(speciesTypeKey));
                model.addAttribute("chromosomes", chromosomes);

                hits = this.getGenome(mapKey);
                model.addAttribute("hits", hits);
                model.addAttribute("mapKey", mapKey);
                model.addAttribute("xlinks", extDbLinks);
                return new ModelAndView("/WEB-INF/jsp/report/genomeInformation/genomeInformation.jsp", "model", model);

            }

        hits=this.getGenome(mapKey);
        model.addAttribute("hits",hits ) ;
        if(infoTable!=null){
            return new ModelAndView("/WEB-INF/jsp/report/genomeInformation/homeInfoTable.jsp", "model", model );
        }

       model.addAttribute("assemblyListsMap", this.getAllSpeciesAssemblyListMap());

       return new ModelAndView("/WEB-INF/jsp/report/genomeInformation/genomeInfoHome.jsp", "model", model );
    }

    public java.util.Map<String, List<Map>> getAllSpeciesAssemblyListMap() throws Exception {
        java.util.Map<String, List<Map>> assemblyListsMap= new HashMap<>();
        for(int speciesKey:SpeciesType.getSpeciesTypeKeys()){
            List<Map> maps= mdao.getMaps(speciesKey, "bp");
            assemblyListsMap.put(SpeciesType.getCommonName(speciesKey), maps);
        }
        return assemblyListsMap;
    }

    public List<SearchHit[]> getGenome(int mapkey){
        List<SearchHit[]> hitsList= new ArrayList<>();

        SearchResponse sr;
        if( mapkey==0 ) {
            System.out.println("SPECIES AND MAPKEY 0");
            sr = ClientInit.getClient().prepareSearch(RgdContext.getESIndexName("genome"))
                    .setTypes("genome")
                    .setQuery(QueryBuilders.matchAllQuery())
                    .setSize(100)
                 //   .setPostFilter(QueryBuilders.boolQuery().filter(QueryBuilders.matchQuery("primaryAssembly", "Y")))
                    .get();
            System.out.println("PRIMARY ASSEMBLIES:"+sr.getHits().getTotalHits());
        }else {
            sr = ClientInit.getClient().prepareSearch(RgdContext.getESIndexName("genome"))
                    .setTypes("genome")
                    .setQuery(QueryBuilders.matchAllQuery())
                    .setPostFilter(QueryBuilders.boolQuery().filter(QueryBuilders.matchQuery("mapKey", mapkey)))
                    .get();
        }
        if(sr!=null) {
            hitsList.add(sr.getHits().getHits());
            System.out.println("TOTAL HITS:" + sr.getHits().getTotalHits());
        }
        return hitsList;
    }


    private List<String> getSpeciesList(){
    List<String> speciesList= new ArrayList<>();

    for(int key:SpeciesType.getSpeciesTypeKeys()){
        System.out.println("SPECIES KEY: " + key);
        if(key!=0)
        speciesList.add(SpeciesType.getCommonName(key));
    }
    return speciesList;
    }

    private List<String> getAssemblyList(int speciesTypeKey) throws Exception {
        List<String> assemblyList= new ArrayList<>();

        List<Map> maps= mdao.getMaps(speciesTypeKey, "bp");
        for(Map m: maps){
            int mapKey=m.getKey();
            if(mapKey!=6 && mapKey!=36 && mapKey!=8 && mapKey!=21 && mapKey!=19 && mapKey!=7) {
            assemblyList.add(m.getDescription());
        }
        }
        return assemblyList;
    }
 public int getMapKey(String assembly, int speciesTypeKey) throws Exception {
     List<Map> maps= mdao.getMaps(speciesTypeKey);
         for(Map m:maps){
             if(m.getDescription().equalsIgnoreCase(assembly)){
                 return m.getKey();
             }else{
                 if(m.getName().equalsIgnoreCase(assembly))
                     return m.getKey();
             }
         }
     return 0;
 }
}

