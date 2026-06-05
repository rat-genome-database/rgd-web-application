package edu.mcw.rgd.search;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.json.JsonData;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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

            ElasticsearchClient client = ClientInit.getClient();
            SearchResponse<Void> sr = client.search(s -> s
                            .index(indexName)
                            .size(0)
                            .trackTotalHits(t -> t.enabled(true))
                            .query(q -> q.bool(b -> b
                                    .must(m -> m.term(t -> t.field("chromosome.keyword").value(FieldValue.of(chr))))
                                    .filter(f -> f.range(r -> r.untyped(u -> u
                                            .field("startPos")
                                            .gte(JsonData.of(start))
                                            .lte(JsonData.of(stop)))))
                            )),
                    Void.class);
            long count = sr.hits().total().value();

            out.print("{\"count\":" + count + "}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"count\":-1,\"error\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }

        out.flush();
        return null;
    }
}
