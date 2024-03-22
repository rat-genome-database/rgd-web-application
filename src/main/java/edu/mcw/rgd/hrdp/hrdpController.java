package edu.mcw.rgd.hrdp;

import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.datamodel.Map;
import edu.mcw.rgd.datamodel.Sample;
import org.apache.commons.lang3.StringUtils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.ArrayList;
import java.util.List;

public class hrdpController implements Controller {

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String[] rgdIds = request.getParameterValues("rgdId");
        List<String> rsIds = new ArrayList<>();
        String choice = request.getParameter("userChoice");

        if (rgdIds != null && choice != null) {
            if (choice.equals("phenominer")) {
                OntologyXDAO ontDao = new OntologyXDAO();
                for (String id : rgdIds) {
                    String ontId = ontDao.getStrainOntIdForRgdId(Integer.parseInt(id));
                    if (ontId != null) {
                        rsIds.add(ontId);
                    }
                }
                String phenominerUrl = StringUtils.join(rsIds, ",");
                System.out.println(phenominerUrl);
                return new ModelAndView("redirect:/phenominer/ontChoices.html?species=3&terms=" + phenominerUrl);
            }
            if (choice.equals("variantVisualizer")) {
                Map mapKey = new MapDAO().getPrimaryRefAssembly(3);
                List<Integer> allSampleIds = new ArrayList<>();
                SampleDAO sampleDAO = new SampleDAO();
                for (String id : rgdIds) {
                    List<Sample> samples = sampleDAO.getSamplesByStrainRgdIdAndMapKey(Integer.parseInt(id), mapKey.getKey());
                    if (samples != null) {
                        for (Sample sample : samples) {
                            allSampleIds.add(sample.getId());
                        }
                    }
                }
                StringBuilder vvUrlBuilder = new StringBuilder();
                for (int i = 0; i < allSampleIds.size(); i++) {
                    vvUrlBuilder.append("&sample").append(i + 1).append("=").append(allSampleIds.get(i));
                }
                String vvUrl = vvUrlBuilder.toString();
                System.out.println("vvUrl:" + vvUrl);
                return new ModelAndView("redirect:/front/select.html?mapKey=372" + vvUrl);

            }
        }


        return new ModelAndView("/WEB-INF/jsp/hrdp/hrdpLandingPage.jsp");
    }
}
