package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.datamodel.Chromosome;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

/**
 * Emits a GViewer ideogram XML stream for any assembly, sourced from
 * {@link MapDAO#getChromosomes(int)}. Used as a fallback for assemblies
 * that don't have a hand-built static ideogram file in
 * /rgdweb/gviewer/data. Each chromosome is rendered as a single
 * featureless band of the correct sequence length (no cytogenetic bands).
 */
public class IdeogramController implements Controller {

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        response.setContentType("text/xml");
        PrintWriter out = response.getWriter();

        String mapKeyStr = request.getParameter("mapKey");
        int mapKey;
        try {
            mapKey = Integer.parseInt(mapKeyStr);
        } catch (Exception e) {
            out.println("<?xml version='1.0' standalone='yes' ?>");
            out.println("<genome></genome>");
            return null;
        }

        MapDAO mdao = new MapDAO();
        List<Chromosome> chromosomes = new ArrayList<>(mdao.getChromosomes(mapKey));

        // Skip mitochondrial — the GViewer ideogram only lists nuclear chromosomes.
        chromosomes.removeIf(c -> {
            String name = c.getChromosome();
            return name != null && name.equalsIgnoreCase("MT");
        });

        // Sort 1, 2, 3, ..., X, Y to match the static files.
        chromosomes.sort(Comparator.comparingInt(c -> Chromosome.getOrdinalNumber(c.getChromosome())));

        out.println("<?xml version='1.0' standalone='yes' ?>");
        out.println("<genome>");
        int idx = 1;
        for (Chromosome c : chromosomes) {
            int length = c.getSeqLength();
            if (length <= 0) {
                idx++;
                continue;
            }
            String name = c.getChromosome();
            out.println("<chromosome index=\"" + idx + "\" number=\"" + name
                    + "\" length=\"" + length + "\">");
            // Single placeholder band spanning the full chromosome. The
            // renderer needs at least one band to size the chromosome track;
            // we omit cytogenetic detail because it isn't in the database.
            out.println("\t<band index=\"1\" name=\"\">");
            out.println("\t\t<start>1</start>");
            out.println("\t\t<end>" + length + "</end>");
            out.println("\t\t<stain>gneg</stain>");
            out.println("\t\t<link></link>");
            out.println("\t</band>");
            out.println("</chromosome>");
            idx++;
        }
        out.println("</genome>");
        return null;
    }
}
