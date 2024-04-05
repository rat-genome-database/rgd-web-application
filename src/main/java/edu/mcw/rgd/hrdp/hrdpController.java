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
        String choice = request.getParameter("userChoice");
        String[]ontIds = request.getParameterValues("ontId");
        String[] sampleIds = request.getParameterValues("sampleIds");
        String mapKey = request.getParameter("mapKey");
        StringBuilder urlBuilder = new StringBuilder();

        if(choice!=null&&choice.equals("phenominer")) {
            if (ontIds != null) {
                for (String ontId : ontIds) {
                    if (ontId != null) {
                        if (urlBuilder.length() > 0) {
                            urlBuilder.append(","); // Append comma before adding the next value, except for the first
                        }
                        urlBuilder.append(ontId);
                    }
                }
            }
            String phenominerUrl = urlBuilder.toString()==null?"": urlBuilder.toString();
            System.out.println("Phenominer Url: "+phenominerUrl);
            return new ModelAndView("redirect:/phenominer/ontChoices.html?species=3&terms=" + phenominerUrl);
        }

        if(choice!=null&&choice.equals("variantVisualizer")) {
            if (sampleIds != null) {
                for (int i = 0; i < sampleIds.length; i++){
                    urlBuilder.append("&sample").append(i + 1).append("=").append(sampleIds[i]);
                }
            }
            String vvUrl = urlBuilder.toString()==null?"": urlBuilder.toString();
            System.out.println("vvUrl:" + vvUrl);
            return new ModelAndView("redirect:/front/select.html?mapKey="+mapKey + vvUrl);
        }

        return new ModelAndView("/WEB-INF/jsp/hrdp/hrdpLandingPage.jsp");
    }
}
