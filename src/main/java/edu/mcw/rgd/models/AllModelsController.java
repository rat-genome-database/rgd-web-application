package edu.mcw.rgd.models;

import edu.mcw.rgd.datamodel.models.GeneticModel;
import edu.mcw.rgd.models.models1.GeneticModelsSingleton;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Controller for handling all genetic models display.
 * Created by jthota on 10/28/2016.
 */
public class AllModelsController extends GeneticModelsController implements Controller {

    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {
        GeneticModelsSingleton instance = GeneticModelsSingleton.getInstance();
        List<GeneticModel> strainsWithAliases = instance.getAllModels();

        Set<String> genes = new HashSet<>();
        for (GeneticModel s : strainsWithAliases) {
            String geneSymbol = s.getGeneSymbol();
            genes.add(geneSymbol);
        }
        this.setGenes(genes);

        Map<String, List<GeneticModel>> gsMap = this.getGeneStrainMap(strainsWithAliases);
        Map<ModelsHeaderRecord, List<GeneticModel>> hcMap = this.getHeaderRecords(strainsWithAliases);

        httpServletRequest.setAttribute("strains", strainsWithAliases);
        httpServletRequest.setAttribute("geneStrainMap", gsMap);
        httpServletRequest.setAttribute("headerChildMap", hcMap);
        backgroundStrainList(gsMap, httpServletRequest);

        return new ModelAndView("/WEB-INF/jsp/models/allModels.jsp");
    }

    public void backgroundStrainList(Map<String, List<GeneticModel>> gsMap, HttpServletRequest httpServletRequest) throws Exception {
        Map<String, String> bsl = new HashMap<>();

        for (Map.Entry<String, List<GeneticModel>> entry : gsMap.entrySet()) {
            String gene = entry.getKey();
            List<GeneticModel> models = entry.getValue();

            Set<String> uniqueStrainNames = new LinkedHashSet<>();
            for (GeneticModel m : models) {
                String str = m.getBackgroundStrain();
                if (str != null && !str.isEmpty()) {
                    uniqueStrainNames.add(str);
                }
            }

            if (uniqueStrainNames.isEmpty()) {
                bsl.put(gene, "No Background Strains Assigned");
            } else {
                bsl.put(gene, String.join(", ", uniqueStrainNames));
            }
        }

        httpServletRequest.setAttribute("backStrainList", bsl);
    }
}
