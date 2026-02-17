package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.datamodel.*;

import edu.mcw.rgd.datamodel.Map;
import edu.mcw.rgd.report.GenomeModel.ExternalDBLinks;
import edu.mcw.rgd.report.GenomeModel.ExternalDbs;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;

import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

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
        LinkedList<SearchHit> hits;
        model.addAttribute("speciesList", this.getSpeciesList());

            if (isDetailsPage || species != null || action != null) {
                int speciesTypeKey = SpeciesType.parse(species);

                if (assembly != null && key == null) {
                    mapKey = this.getMapKey(assembly, speciesTypeKey);

                }
                model.addAttribute("species", species);
                if (assembly == null && mapKey==0) {
                    Map map = mdao.getPrimaryRefAssembly(speciesTypeKey);
                    assembly = map.getRefSeqAssemblyName();
                     mapKey = map.getKey();
                 }else{
                    if(assembly==null){
                        Map map= mdao.getMap(mapKey);
                        assembly=map.getRefSeqAssemblyName();
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
            System.out.println("HITS SIZE:"+ hits.size());
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

    public LinkedList<SearchHit> getGenome(int mapkey) throws IOException {
        List<SearchHit[]> hitsList= new ArrayList<>();
        SearchSourceBuilder srb=new SearchSourceBuilder();
        srb.query(QueryBuilders.matchAllQuery());




    //    SearchResponse sr;
        if( mapkey==0 ) {
            srb.postFilter(QueryBuilders.boolQuery().filter(QueryBuilders.matchQuery("primaryAssembly", "Y")));
        /*    sr = ClientInit.getClient().prepareSearch(RgdContext.getESIndexName("genome"))
                    .setTypes("genome")
                    .setQuery(QueryBuilders.matchAllQuery())
                    .setSize(100)
                 //   .setPostFilter(QueryBuilders.boolQuery().filter(QueryBuilders.matchQuery("primaryAssembly", "Y")))
                    .get();
*/
        }else {
            srb.postFilter(QueryBuilders.boolQuery().filter(QueryBuilders.matchQuery("mapKey", mapkey)));
           /* sr = ClientInit.getClient().prepareSearch(RgdContext.getESIndexName("genome"))
                    .setTypes("genome")
                    .setQuery(QueryBuilders.matchAllQuery())
                    .setPostFilter(QueryBuilders.boolQuery().filter(QueryBuilders.matchQuery("mapKey", mapkey)))
                    .get();*/
        }
        srb.size(100);
        SearchRequest searchRequest=new SearchRequest(RgdContext.getESIndexName("genome"));
        searchRequest.source(srb);
        SearchResponse sr= ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
        if(sr!=null) {
            hitsList.add(sr.getHits().getHits());

        }
        LinkedList<SearchHit> map=new LinkedList<>();
        for(SearchHit[] hit:hitsList){
            for(SearchHit h:hit){
                if(h.getSourceAsMap().get("species").toString().equalsIgnoreCase("Rat"))
                map.add(h);
            }
            for(SearchHit h:hit){
                if(h.getSourceAsMap().get("species").toString().equalsIgnoreCase("Human"))
                    map.add(h);            }
            for(SearchHit h:hit){
                if(h.getSourceAsMap().get("species").toString().equalsIgnoreCase("Mouse"))
                    map.add(h);            }
            for(SearchHit h:hit){
                if(h.getSourceAsMap().get("species").toString().equalsIgnoreCase("Chinchilla"))
                    map.add(h);            }
            for(SearchHit h:hit){
                if(h.getSourceAsMap().get("species").toString().equalsIgnoreCase("Dog"))
                    map.add(h);            }

            for(SearchHit h:hit){
                if(h.getSourceAsMap().get("species").toString().equalsIgnoreCase("Bonobo"))
                    map.add(h);            }
            for(SearchHit h:hit){
                if(h.getSourceAsMap().get("species").toString().equalsIgnoreCase("Squirrel"))
                    map.add(h);            }

            for(SearchHit h:hit){
                if(h.getSourceAsMap().get("species").toString().equalsIgnoreCase("Pig"))
                    map.add(h);            }
            for(SearchHit h:hit){
                if(h.getSourceAsMap().get("species").toString().equalsIgnoreCase("Naked Mole-rat"))
                    map.add(h);            }
            for(SearchHit h:hit){
                if(h.getSourceAsMap().get("species").toString().equalsIgnoreCase("Green Monkey"))
                    map.add(h);            }
            for(SearchHit h:hit){
                if(h.getSourceAsMap().get("species").toString().equalsIgnoreCase("Black Rat"))
                    map.add(h);            }

        }
        return map;
    }


    private List<String> getSpeciesList(){
    List<String> speciesList= new ArrayList<>();

    for(int key:SpeciesType.getSpeciesTypeKeys()){

      //  if(key==1 || key==2 || key==3 || key==4 || key==5 || key==6 || key==7 || key==9)
        if(SpeciesType.isSearchable(key))
        speciesList.add(SpeciesType.getCommonName(key));
    }
    return speciesList;
    }

    private List<String> getAssemblyList(int speciesTypeKey) throws Exception {
        List<String> assemblyList= new ArrayList<>();

        List<Map> maps= mdao.getMaps(speciesTypeKey, "bp");
        for(Map m: maps){
            int mapKey=m.getKey();
            if(mapKey!=6 && mapKey!=36 && mapKey!=8 && mapKey!=21 && mapKey!=19 && mapKey!=7 ) {
                if(m.getRefSeqAssemblyName()!=null && !m.getRefSeqAssemblyName().equals(""))
                    assemblyList.add(m.getRefSeqAssemblyName().trim());
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

