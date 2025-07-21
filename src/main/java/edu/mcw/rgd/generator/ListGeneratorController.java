package edu.mcw.rgd.generator;

import com.google.gson.Gson;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.generator.GeneratorCommandParser;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.commons.collections4.ListUtils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class ListGeneratorController implements Controller {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        //System.out.println("entering List Gen Controller");
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
        List omLog = new ArrayList();

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

            for (int i=0; i < accIds.size(); i++ ) {

                String accId = (String) accIds.get(i);

                //String operation=accId.substring(0,1);

                GeneratorCommandParser gcp = new GeneratorCommandParser(mapKey,oKey);

                //List log = gcp.getObjectMapperLog();

                allGenes.addAll(gcp.parse(accId));

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

                omLog.addAll(gcp.getObjectMapperLog());

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


        Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("GMT"));
        calendar.setTime(new Date());
        calendar.set(Calendar.HOUR_OF_DAY, 23);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);

// Move to next Monday
        int dayOfWeek = calendar.get(Calendar.DAY_OF_WEEK);
        int daysUntilMonday = (Calendar.MONDAY - dayOfWeek + 7) % 7;
        if (daysUntilMonday == 0) {
            daysUntilMonday = 7;  // Ensure it's the *next* Monday
        }
        calendar.add(Calendar.DAY_OF_MONTH, daysUntilMonday);

        SimpleDateFormat sdf = new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z");
        sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
        String expiresHeader = sdf.format(calendar.getTime());

        response.setHeader("Expires", expiresHeader);



        request.setAttribute("mapKey",mapKey);
        request.setAttribute("accIds", accIds);
        request.setAttribute("omLog", omLog);
        request.setAttribute("operators", operators);
        request.setAttribute("objectSymbols", objectSymbols);
        request.setAttribute("resultSet",resultSet);
        request.setAttribute("exclude",exclude);
        request.setAttribute("messages", messages);
        request.setAttribute("oKey", oKey);

        //System.out.println("exiting List Gen Controller");

        return new ModelAndView("/WEB-INF/jsp/generator/list.jsp");
    }

  
}