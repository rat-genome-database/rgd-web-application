package edu.mcw.rgd.search;

import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.io.PrintWriter;

public class VariantCountController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String chr = request.getParameter("chr");
        String startStr = request.getParameter("start");
        String stopStr = request.getParameter("stop");
        String mapKeyStr = request.getParameter("mapKey");

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();

        try {
            int mapKey = Integer.parseInt(mapKeyStr);
            long start = Long.parseLong(startStr);
            long stop = Long.parseLong(stopStr);

            String species = SpeciesType.getCommonName(SpeciesType.getSpeciesTypeKeyForMap(mapKey)).replace(" ", "");
            String indexName = RgdContext.getESVariantIndexName("variants_" + species.toLowerCase() + mapKey);

            BoolQueryBuilder qb = QueryBuilders.boolQuery()
                    .must(QueryBuilders.termQuery("chromosome.keyword", chr))
                    .filter(QueryBuilders.rangeQuery("startPos").gte(start).lte(stop));

            SearchSourceBuilder srb = new SearchSourceBuilder();
            srb.query(qb);
            srb.size(0);
            srb.trackTotalHits(true);

            SearchRequest searchRequest = new SearchRequest(indexName);
            searchRequest.source(srb);

            SearchResponse sr = ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
            long count = sr.getHits().getTotalHits().value;

            out.print("{\"count\":" + count + "}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"count\":-1,\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }

        out.flush();
        return null;
    }
}
