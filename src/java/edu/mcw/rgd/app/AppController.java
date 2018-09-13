package edu.mcw.rgd.app;

import edu.mcw.rgd.carpenovo.SNPlotyper;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.MappedGene;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 9/17/13
 * Time: 3:23 PM
 * To change this template use File | Settings | File Templates.
 */
public class AppController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);

        GeneDAO gdao = new GeneDAO();

        List<MappedGene> genes = gdao.getActiveMappedGenes(17);

        int count=0;

        JSONArray ja= new JSONArray();



        for (MappedGene mg: genes) {

            JSONObject json = new JSONObject();
            json.put("symbol", mg.getGene().getSymbol());
            json.put("name", mg.getGene().getName());
            json.put("chr", mg.getChromosome());
            json.put("start",mg.getStart());
            json.put("stop",mg.getStop());
            json.put("type",mg.getGene().getType());



            ja.put(json);

            /*
            if (count++ > 5){
                return null;
            }
            */


        }
        response.getWriter().print(ja.toString());

        return null;
    }


}
