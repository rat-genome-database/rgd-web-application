package edu.mcw.rgd.generator;

import com.google.gson.Gson;
import edu.mcw.rgd.datamodel.Chromosome;
import edu.mcw.rgd.process.mapping.MapManager;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.ArrayList;
import java.util.List;

/**
 * Returns chromosome names as JSON for a given mapKey.
 * Used by OLGA wizard for populating chromosome dropdown.
 */
public class ChromosomeController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        int mapKey = 380; // Default to GRCr8

        try {
            String mapKeyStr = request.getParameter("mapKey");
            if (mapKeyStr != null && !mapKeyStr.isEmpty()) {
                mapKey = Integer.parseInt(mapKeyStr);
            }
        } catch (NumberFormatException e) {
            // Use default
        }

        List<String> chromosomeNames = new ArrayList<>();
        try {
            List<Chromosome> chromosomes = MapManager.getInstance().getChromosomes(mapKey);
            for (Chromosome ch : chromosomes) {
                chromosomeNames.add(ch.getChromosome());
            }
        } catch (Exception e) {
            // Return empty list on error
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(chromosomeNames));
        return null;
    }
}
