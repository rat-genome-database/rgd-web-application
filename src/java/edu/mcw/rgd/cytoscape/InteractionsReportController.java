package edu.mcw.rgd.cytoscape;

import edu.mcw.rgd.datamodel.Interaction;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.search.elasticsearch1.model.SearchBean;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by jthota on 3/21/2019.
 */
public class InteractionsReportController implements Controller {
    Map<String, List<InteractionReportRecord>> map= new HashMap<>();
    Map<String, Report> reportMap= new HashMap<>();
 /* @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
      String species= request.getParameter("species");
      InteractionsService service= new InteractionsService();
        Report report= service.getInteractionsBySpecies(species);
        if(reportMap.get(species.toLowerCase())!=null){
            report=reportMap.get(species);
        }else{
            report= service.getInteractionsBySpecies(species);
            reportMap.put(species.toLowerCase(), report);
        }


      request.setAttribute("report", report);
      request.setAttribute("species", species);
      return new ModelAndView("/WEB-INF/jsp/cytoscape/report.jsp");
    }
*/
 @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String species = request.getParameter("species");
         HttpSession session = request.getSession();
        InteractionsService service = new InteractionsService();
        ModelMap model = new ModelMap();
        List<InteractionReportRecord> records= new ArrayList<>();
        if(map.get(species.toLowerCase())!=null){
            records=map.get(species.toLowerCase());

        }else{
            records= service.getInteractionsBySpecies(species);
            map.put(species.toLowerCase(), records);
        }
        session.setAttribute("records", records);
        model.put("records", records);
        model.put("species", species);

        return new ModelAndView("/WEB-INF/jsp/cytoscape/report.jsp", "model", model);
    }
}
