package edu.mcw.rgd.vv;

import edu.mcw.rgd.datamodel.VariantSearchBean;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 10/21/11
 * Time: 9:53 AM
 * To change this template use File | Settings | File Templates.
 */
public class StrainOptionsController extends HaplotyperController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        try {
            HttpRequestFacade req = new HttpRequestFacade(request);


            boolean hasPos = false;
            boolean hasBounds=false;
            boolean hasList=false;
            boolean hasFunction=false;

            VariantSearchBean vsb = this.fillBean(req);
            request.setAttribute("vsb",vsb);
            request.setAttribute("mapKey",vsb.getMapKey());
            if (!req.getParameter("chr").equals("") && !req.getParameter("start").equals("") && !req.getParameter("stop").equals("")) {
                hasPos=true;
            }

            if (!req.getParameter("geneStart").equals("") && !req.getParameter("geneStop").equals("")) {
               hasBounds = true;
            }

            if (!req.getParameter("geneList").equals("")) {
               hasList=true;
            }

            if (!req.getParameter("rdo_acc_id").equals("") || !req.getParameter("mp_acc_id").equals("") || !req.getParameter("pw_acc_id").equals("") || !req.getParameter("chebi_acc_id").equals("")){
               hasFunction=true;
            }



            int count=0;

            if (hasPos) {
               count++;
            }
            if (hasBounds) {
                count++;
            }
            if (hasList) {
                count++;
            }
            if (hasFunction) {
                count++;
            }


            if (count==0) {
                throw new Exception("Please define a region");
            }

            if (count > 1) {
                //throw new Exception("You can not define a position and Gene/SSLP bounds.  Please choose one.");
            }
        }catch (Exception e) {

            e.printStackTrace();
            request.setAttribute("error",e.getMessage());
            return new ModelAndView("/WEB-INF/jsp/vv/region.jsp");
        }

             return new ModelAndView("/WEB-INF/jsp/vv/options.jsp");
    }
}
