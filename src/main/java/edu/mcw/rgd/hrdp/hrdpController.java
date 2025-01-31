package edu.mcw.rgd.hrdp;

import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.datamodel.Map;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.LinkedHashSet;
import java.util.Set;


public class hrdpController implements Controller {

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String choice = request.getParameter("userChoice");
        String[]ontIds = request.getParameterValues("ontId");
        String[]childontIds = request.getParameterValues("childontId");
        String[] sampleIds = request.getParameterValues("sampleIds");
        String[] sampleChildIds = request.getParameterValues("sampleChildIds");
        StringBuilder urlBuilder = new StringBuilder();

        if (choice != null && choice.equals("phenominer")) {
            Set<String> uniqueOntIds = new LinkedHashSet<>();

            // Add each individual ontology ID to the Set
            if (ontIds!= null) {
                for (String ontId : ontIds) {
                    String[] ids = ontId.split(",");
                    for (String id : ids) {
                        if (!id.trim().isEmpty()) {
                            uniqueOntIds.add(id.trim());
                        }
                    }
                }
            }

            // Add each individual child ontology ID to the Set
            if (childontIds!= null) {
                for (String childId : childontIds) {
                    String[] ids = childId.split(",");
                    for (String id : ids) {
                        if (!id.trim().isEmpty()) {
                            uniqueOntIds.add(id.trim());
                        }
                    }
                }
            }

            String phenominerUrl = String.join(",", uniqueOntIds);

            System.out.println("Phenominer Url: " + phenominerUrl);

            return new ModelAndView("redirect:/phenominer/ontChoices.html?species=3&terms=" + phenominerUrl);
        }

        if (choice != null && choice.equals("variantVisualizer")) {
            Map mapKey = new MapDAO().getPrimaryRefAssembly(3);
            int key = mapKey.getKey();

            // remove me when we get variants for GRCr8
            if (key==380){
                key=372;
            }
            // remove me when we get variants for GRCr8

            Set<String> uniqueIds = new LinkedHashSet<>();

            // Add each individual sample ID to the Set
            if (sampleIds != null) {
                for (String sampleGroup : sampleIds) {
                    String[] ids = sampleGroup.split(",");
                    for (String id : ids) {
                        uniqueIds.add(id.trim());
                    }
                }
            }

            // Add each individual child sample ID to the Set
            if (sampleChildIds != null) {
                for (String childGroup : sampleChildIds) {
                    String[] ids = childGroup.split(",");
                    for (String id : ids) {
                        uniqueIds.add(id.trim());
                    }
                }
            }

            // Append unique IDs to the URL
            int index = 1;
            for (String id : uniqueIds) {
                urlBuilder.append("&sample").append(index++).append("=").append(id);
            }

            String vvUrl = urlBuilder.toString();
            System.out.println("vvUrl:" + vvUrl);
            return new ModelAndView("redirect:/front/select.html?mapKey="+key + vvUrl);
        }

            return new ModelAndView("/WEB-INF/jsp/hrdp/hrdpLandingPage.jsp");
    }
}
