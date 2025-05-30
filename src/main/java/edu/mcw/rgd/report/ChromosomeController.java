package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.MapDAO;

import edu.mcw.rgd.datamodel.*;
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
        if(request.getParameter("mapKey")==null)
            return null;
        int mapKey= Integer.parseInt(request.getParameter("mapKey"));

      /* ============================================================================*/
        Map m= mapDAO.getMap(mapKey);
            int speciesTypeKey= m.getSpeciesTypeKey();
        String species= SpeciesType.getCommonName(speciesTypeKey);
        /*=============================================================================*/
        ModelMap model= new ModelMap();
        if(chr!=null && !chr.equals("")) {
            List<SearchHit[]> hits = this.getChromosome(mapKey, chr);
            model.put("hits", hits);
            model.put("species", species);
            if (locus != null) {
                model.put("locus", locus);
            }
            ExternalDBLinks xlinks = new ExternalDBLinks();
            ExternalDbs extDbLinks = xlinks.getXLinks(mapKey, chr, locus);
            model.addAttribute("xlinks", extDbLinks);
        }
        return new ModelAndView("/WEB-INF/jsp/report/genomeInformation/chromosome.jsp","model", model);

    }

    public List<SearchHit[]> getChromosome(int mapKey, String chr) throws IOException {
       List<SearchHit[]> hitsList= new ArrayList<>();
        SearchSourceBuilder srb=new SearchSourceBuilder();
        srb.query(QueryBuilders.matchAllQuery());
        srb.postFilter(QueryBuilders.boolQuery().filter(QueryBuilders.matchQuery("chromosome.keyword", chr)).filter(QueryBuilders.matchQuery("mapKey", mapKey)));

        SearchRequest searchRequest=new SearchRequest(RgdContext.getESIndexName("chromosome"));
        searchRequest.source(srb);
        SearchResponse sr= ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
      /*  SearchResponse sr = ClientInit.getClient().prepareSearch(RgdContext.getESIndexName("chromosome"))
                .setTypes("chromosome")
                .setQuery(QueryBuilders.matchAllQuery())
                .setPostFilter(QueryBuilders.boolQuery().filter(QueryBuilders.matchQuery("chromosome.keyword", chr)).filter(QueryBuilders.matchQuery("mapKey", mapKey)))
                .get();
*/
        if(sr!=null) {
            hitsList.add(sr.getHits().getHits());
        }
        return hitsList;
    }

}
