package edu.mcw.rgd.phenominer;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.pheno.Enumerable;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class PhenominerCurationController extends PhenominerController {


    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        String action = req.getParameter("action");
        PhenominerDAO dao = new PhenominerDAO();

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();


        if (!req.getParameter("referenceId").equals("")) {
            status.add("Reference imported with RGD ID " + req.getParameter("referenceId"));
        }

        if (action.equals("addUnit")) {
            try {
                String unitType = request.getParameter("unitType");
                String unitValue = request.getParameter("unitValue");
                String description = request.getParameter("description");

                Enumerable e = new Enumerable();
                e.setType(Integer.parseInt(unitType));
                e.setValue(unitValue);
                e.setLabel(unitValue);
                e.setDescription(description);

                if (Integer.parseInt(unitType) == 3) {
                    List<String> existingCMO = dao.getDistinct("PHENOMINER_ENUMERABLES where type=3  ", "label", true);
                    if (!existingCMO.contains(unitValue)) {
                        if (unitValue != null && !unitValue.equals(""))
                            dao.insertEnumerable(e);
                    }
                    String termAcc = request.getParameter("accId");
                    if (request.getParameterMap().containsKey("termScale") && request.getParameter("termScale") != null && !request.getParameter("termScale").trim().isEmpty()) {
                        String termScale = request.getParameter("termScale");
                        dao.insertUnitConversion(termAcc, unitValue, termScale);
                    } else {
                        dao.checkUnitConversion(termAcc, unitValue);
                    }
                } else {
                    List<String> existingXCO = dao.getDistinct("PHENOMINER_ENUMERABLES where type=2  ", "label", true);
                    if (!existingXCO.contains(unitValue)) {
                        if (unitValue != null && !unitValue.equals(""))
                            dao.insertEnumerable(e);
                    }
                }
                status.add("Unit added successfully");
            } catch (Exception e) {
                error.add("Error adding unit: " + e.getMessage());
            }
        }

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/phenominer/home.jsp");
    }

}