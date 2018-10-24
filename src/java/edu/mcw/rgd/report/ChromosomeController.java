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
import java.util.List;

/**
 * Created by jthota on 11/3/2017.
 */
public class ChromosomeController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        MapDAO mapDAO= new MapDAO();
        String chr= request.getParameter("chr");
        String locus=request.getParameter("locus");
        int mapKey= Integer.parseInt(request.getParameter("mapKey"));

      /* ============================================================================*/
        Map m= mapDAO.getMap(mapKey);
            int speciesTypeKey= m.getSpeciesTypeKey();
        String species= SpeciesType.getCommonName(speciesTypeKey);
        /*=============================================================================*/
        ModelMap model= new ModelMap();

        List<SearchHit[]> hits=this.getChromosome(mapKey, chr);
        model.put("hits", hits);
        model.put("species", species);
        if(locus!=null){
            model.put("locus", locus);
        }
        ExternalDBLinks xlinks= new ExternalDBLinks();
        ExternalDbs extDbLinks= xlinks.getXLinks(mapKey,chr, locus);
        model.addAttribute("xlinks", extDbLinks);
        return new ModelAndView("/WEB-INF/jsp/report/genomeInformation/chromosome.jsp","model", model);

    }

    public List<SearchHit[]> getChromosome(int mapKey, String chr){
        List<SearchHit[]> hitsList= new ArrayList<>();

        SearchResponse sr = ClientInit.getClient().prepareSearch(RgdContext.getESIndexName())
                .setTypes("chromosomes")
                .setQuery(QueryBuilders.matchAllQuery())
                .setPostFilter(QueryBuilders.boolQuery().filter(QueryBuilders.matchQuery("chromosome.keyword", chr)).filter(QueryBuilders.matchQuery("mapKey", mapKey)))
                .get();

        if(sr!=null) {
            System.out.println("PRIMARY ASSEMBLIES:"+sr.getHits().getTotalHits());
            hitsList.add(sr.getHits().getHits());
            System.out.println("TOTAL HITS:" + sr.getHits().getTotalHits());
        }
        return hitsList;
    }

}
