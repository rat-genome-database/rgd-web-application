package edu.mcw.rgd.generator;

import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.generator.GeneratorCommandParser;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.commons.collections4.ListUtils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Controller for the OLGA wizard interface.
 * Extends the same logic as ListGeneratorController but returns the wizard view.
 */
public class ListWizardController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        String aValue = "";
        ArrayList<String> operators = new ArrayList<String>();
        ArrayList<String> accIds = new ArrayList<String>();
        ArrayList<HashMap<String,String>> excludeMap = new ArrayList<HashMap<String,String>>();
        ArrayList<ArrayList<String>> objectSymbols = new ArrayList<ArrayList<String>>();
        List newList = new ArrayList();
        LinkedHashMap<String, Object> resultSet = new LinkedHashMap<>();
        ArrayList<String> urlParts = new ArrayList<String>();

        HashMap exclude = new HashMap();
        int mapKey = MapManager.getInstance().getReferenceAssembly(SpeciesType.RAT).getKey();
        int oKey = 1;
        List omLog = new ArrayList();

        HashMap messages = new HashMap();

        try {
            mapKey = Integer.parseInt(request.getParameter("mapKey"));
        } catch (Exception e) {
        }

        try {
            oKey = Integer.parseInt(request.getParameter("oKey"));
        } catch (Exception e) {
        }

        int speciesType = SpeciesType.getSpeciesTypeKeyForMap(mapKey);

        if (req.getParameter("a") != null) {
            aValue = req.getParameter("a");
        }

        if (!aValue.equals("")) {
            String[] tmpArray = aValue.split("\\|");

            for (int i = 0; i < tmpArray.length; i++) {
                if (oKey != 1 && (tmpArray[i].substring(1).startsWith("lst"))) {
                    // Skip symbol lists for non-gene types
                } else {
                    urlParts.add(tmpArray[i]);
                }
            }
        }

        if (urlParts.size() > 0) {
            for (int i = 0; i < urlParts.size(); i++) {
                String accIdBlock = urlParts.get(i);
                operators.add(accIdBlock.substring(0, 1));

                String[] minGenesArray = accIdBlock.split("\\*");

                HashMap minGenes = new HashMap();
                for (int j = 1; j < minGenesArray.length; j++) {
                    minGenes.put(minGenesArray[j], null);
                }

                String accId = minGenesArray[0].substring(1);
                accIds.add(accId);
                excludeMap.add(minGenes);
            }

            List<String> allGenes = new ArrayList<String>();

            for (int i = 0; i < accIds.size(); i++) {
                String accId = (String) accIds.get(i);

                GeneratorCommandParser gcp = new GeneratorCommandParser(mapKey, oKey);
                allGenes.addAll(gcp.parse(accId));

                messages.putAll(gcp.getLog());

                ArrayList<String> genes = new ArrayList<String>();
                HashMap exclusions = (HashMap) excludeMap.get(i);

                for (String gene : allGenes) {
                    if (!exclusions.containsKey(gene)) {
                        genes.add(gene);
                    }
                }

                objectSymbols.add(genes);
                allGenes = new ArrayList<String>();

                omLog.addAll(gcp.getObjectMapperLog());
            }

            newList = objectSymbols.get(0);
            for (int i = 1; i < accIds.size(); i++) {
                String operator = operators.get(i);

                if (operator.equals("~")) {
                    newList = ListUtils.union(newList, objectSymbols.get(i));
                }

                if (operator.equals("^")) {
                    newList = ListUtils.subtract(newList, objectSymbols.get(i));
                }

                if (operator.equals("!")) {
                    newList = ListUtils.intersection(newList, objectSymbols.get(i));
                }
            }
        }

        Iterator it = newList.iterator();
        HashMap seen = new HashMap();

        while (it.hasNext()) {
            String gene = (String) it.next();
            if (!seen.containsKey(gene)) {
                resultSet.put(gene, null);
                seen.put(gene, null);
            }
        }

        request.setAttribute("mapKey", mapKey);
        request.setAttribute("accIds", accIds);
        request.setAttribute("omLog", omLog);
        request.setAttribute("operators", operators);
        request.setAttribute("objectSymbols", objectSymbols);
        request.setAttribute("resultSet", resultSet);
        request.setAttribute("exclude", exclude);
        request.setAttribute("messages", messages);
        request.setAttribute("oKey", oKey);

        return new ModelAndView("/WEB-INF/jsp/generator/list-wizard.jsp");
    }
}
