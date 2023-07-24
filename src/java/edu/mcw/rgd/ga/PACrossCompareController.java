package edu.mcw.rgd.ga;

import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 4/11/12
 * Time: 10:34 AM
 * To change this template use File | Settings | File Templates.
 */
public class PACrossCompareController extends GAController {


    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        this.init(request,response);

        ObjectMapper om = this.buildMapper(req.getParameter("idType"));
        ObjectMapper omTemp = new ObjectMapper();
        AnnotationDAO adao = new AnnotationDAO();

        List<String> overlap =  adao.getOverlap(om.getMappedRgdIds(),request.getParameter("term1"),request.getParameter("term2"));

        List mapped = om.getMapped();
        Iterator mit = mapped.iterator();

        while (mit.hasNext()) {
            Object nxt = mit.next();

            if (nxt instanceof Gene) {
                Gene gene = (Gene) nxt;

                for (String oid: overlap) {
                    if (gene.getSymbol().equals(oid)) {
                        omTemp.addToMap(gene);
                    }
                }
            }
        }

        request.setAttribute("objectMapper", omTemp);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/pa/window.jsp", "hello", null);
    }

}
