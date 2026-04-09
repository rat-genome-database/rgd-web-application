package edu.mcw.rgd.generator;

import com.google.gson.Gson;
import edu.mcw.rgd.datamodel.Chromosome;
import edu.mcw.rgd.process.mapping.MapManager;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Returns chromosome names and sizes as JSON for a given mapKey.
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

        List<Map<String,Object>> chromosomeList = new ArrayList<>();
        try {
            List<Chromosome> chromosomes = MapManager.getInstance().getChromosomes(mapKey);
            for (Chromosome ch : chromosomes) {
                Map<String,Object> entry = new HashMap<>();
                entry.put("name", ch.getChromosome());
                entry.put("size", ch.getSeqLength());
                chromosomeList.add(entry);
            }
        } catch (Exception e) {
            // Return empty list on error
        }

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(new Gson().toJson(chromosomeList));
        return null;
    }
}
