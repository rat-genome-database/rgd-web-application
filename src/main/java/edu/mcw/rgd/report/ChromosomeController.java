package edu.mcw.rgd.report;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.report.GenomeModel.ExternalDBLinks;
import edu.mcw.rgd.report.GenomeModel.ExternalDbs;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.EsHit;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class ChromosomeController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        MapDAO mapDAO = new MapDAO();
        String chr = request.getParameter("chr");
        String locus = request.getParameter("locus");
        if (request.getParameter("mapKey") == null) {
            return null;
        }
        int mapKey = Integer.parseInt(request.getParameter("mapKey"));

        Map m = mapDAO.getMap(mapKey);
        int speciesTypeKey = m.getSpeciesTypeKey();
        String species = SpeciesType.getCommonName(speciesTypeKey);

        ModelMap model = new ModelMap();
        if (chr != null && !chr.equals("")) {
            List<List<EsHit>> hits = this.getChromosome(mapKey, chr);
            model.put("hits", hits);
            model.put("species", species);
            if (locus != null) {
                model.put("locus", locus);
            }
            ExternalDBLinks xlinks = new ExternalDBLinks();
            ExternalDbs extDbLinks = xlinks.getXLinks(mapKey, chr, locus);
            model.addAttribute("xlinks", extDbLinks);
        }
        return new ModelAndView("/WEB-INF/jsp/report/genomeInformation/chromosome.jsp", "model", model);
    }

    public List<List<EsHit>> getChromosome(int mapKey, String chr) throws IOException {
        ElasticsearchClient client = ClientInit.getClient();
        SearchResponse<java.util.Map> sr = client.search(s -> s
                        .index(RgdContext.getESIndexName("chromosome"))
                        .query(q -> q.matchAll(ma -> ma))
                        .postFilter(pf -> pf.bool(b -> b
                                .filter(f -> f.match(mq -> mq.field("chromosome.keyword").query(FieldValue.of(chr))))
                                .filter(f -> f.match(mq -> mq.field("mapKey").query(FieldValue.of(mapKey))))
                        )),
                java.util.Map.class);

        List<EsHit> inner = new ArrayList<>();
        for (Hit<java.util.Map> hit : sr.hits().hits()) {
            @SuppressWarnings("unchecked")
            java.util.Map<String, Object> source = (java.util.Map<String, Object>) hit.source();
            inner.add(new EsHit(hit.id(), source));
        }
        List<List<EsHit>> hitsList = new ArrayList<>();
        hitsList.add(inner);
        return hitsList;
    }
}
