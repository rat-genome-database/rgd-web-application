package edu.mcw.rgd.generator;

import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.QTL;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.datamodel.Strain;
import edu.mcw.rgd.process.generator.GeneratorCommandParser;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.commons.collections4.ListUtils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class ListSaveController implements Controller {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        String aValue = "";
        ArrayList<String> operators = new ArrayList<String>();
        ArrayList<String> accIds = new ArrayList<String>();
        ArrayList<HashMap<String,String>> excludeMap = new ArrayList<HashMap<String,String>>();
        ArrayList<ArrayList<String>> objectSymbols = new ArrayList<ArrayList<String>>();
        List newList = new ArrayList();
        List resultSet = new ArrayList();
        ArrayList<String> urlParts = new ArrayList<String>();

        HashMap exclude = new HashMap();
        int mapKey = MapManager.getInstance().getReferenceAssembly(SpeciesType.RAT).getKey();
        int oKey=1;
        ObjectMapper om = new ObjectMapper();
        HashMap messages = new HashMap();

        try {
            mapKey = Integer.parseInt(request.getParameter("mapKey"));
        }catch(Exception e) {
        }

        try {
            oKey = Integer.parseInt(request.getParameter("oKey"));
        }catch(Exception e) {
        }

        int speciesType = SpeciesType.getSpeciesTypeKeyForMap(mapKey);

        if (req.getParameter("a") != null) {
            aValue= req.getParameter("a");
        }

        if (!aValue.equals("")) {
            String[] tmpArray = aValue.split("\\|");

            for (int i=0; i< tmpArray.length;i++) {
                if (oKey!=1 && (tmpArray[i].substring(1).startsWith("lst"))) {
                }else {
                    urlParts.add(tmpArray[i]);
                }
            }
        }


        if (urlParts.size() > 0) {

            for (int i = 0; i< urlParts.size(); i++) {

                String accIdBlock = urlParts.get(i);
                operators.add(accIdBlock.substring(0,1));

                //get the minus genes
                String[] minGenesArray = accIdBlock.split("\\*");

                HashMap minGenes = new HashMap();
                for (int j=1; j<minGenesArray.length; j++) {
                    minGenes.put(minGenesArray[j],null);
                }

                String accId = minGenesArray[0].substring(1);
                accIds.add(accId);
                excludeMap.add(minGenes);
            }

            List<String> allGenes = new ArrayList<String>();

            HashMap<Integer,Object> allObjects = new HashMap<Integer, Object>();

            for (int i=0; i < accIds.size(); i++ ) {

                String accId = (String) accIds.get(i);
                //String operation=accId.substring(0,1);

                GeneratorCommandParser gcp = new GeneratorCommandParser(mapKey,oKey);

                allGenes.addAll(gcp.parse(accId));

                List objects = gcp.parseObjects(accId);
                Iterator it = objects.iterator();

                if (oKey == 1) {
                    while (it.hasNext()) {
                        Gene g = (Gene) it.next();
                        allObjects.put(g.getRgdId(), g);
                    }
                }else if (oKey ==6) {
                    //qtl
                    while (it.hasNext()) {
                        QTL q = (QTL) it.next();
                        allObjects.put(q.getRgdId(), q);
                    }
                }else if (oKey ==5) {
                    //strain
                    while (it.hasNext()) {
                        Strain s = (Strain) it.next();
                        allObjects.put(s.getRgdId(), s);
                    }

                }

                messages.putAll(gcp.getLog());
                ArrayList<String> genes = new ArrayList<String>();
                HashMap exclusions = (HashMap) excludeMap.get(i);

                for (String gene: allGenes) {
                    if (!exclusions.containsKey(gene)) {
                        genes.add(gene);
                    }
                }

                objectSymbols.add(genes);
                allGenes = new ArrayList<String>();
            }

            newList = objectSymbols.get(0);
            for (int i=1; i < accIds.size(); i++ ) {

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
                resultSet.add(gene);
                seen.put(gene, null);
            }
        }


        request.setAttribute("mapKey",mapKey);
        request.setAttribute("accIds", accIds);
        request.setAttribute("om", om);
        request.setAttribute("operators", operators);
        request.setAttribute("objectSymbols", objectSymbols);
        request.setAttribute("resultSet",resultSet);
        request.setAttribute("exclude",exclude);
        request.setAttribute("messages", messages);
        request.setAttribute("oKey", oKey);


        return new ModelAndView("/WEB-INF/jsp/generator/save.jsp");
    }

  
}