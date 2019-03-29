package edu.mcw.rgd.carpenovo;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.datamodel.VariantSearchBean;
import edu.mcw.rgd.datamodel.search.Position;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Arrays;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 10/21/11
 * Time: 9:53 AM
 */
public class ConfigController extends HaplotyperController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ArrayList errorList = new ArrayList();
        if(!checkRegionPositionBounds(request)){
            errorList.addAll(new ArrayList<>(Arrays.asList("Please reduce the region size to below 30000000")));
            request.setAttribute("error", errorList);
            Position p=getGeneSSLPRegion(request);
            if(p!=null){
                request.setAttribute("error", errorList);
                request.setAttribute("start", p.getStart());
                request.setAttribute("stop", p.getStop());
                request.setAttribute("chr", p.getChromosome());
               }
           return new ModelAndView("/WEB-INF/jsp/haplotyper/region.jsp");
        }


        boolean positionSet=false;
        boolean strainsSet=false;
        boolean genesSet=false;
        boolean regionSet=false;


        try {
            HttpRequestFacade req = new HttpRequestFacade(request);

            VariantSearchBean vsb = this.fillBean(req);
            request.setAttribute("vsb", vsb);


            if (!req.getParameter("chr").equals("") && !req.getParameter("start").equals("") && !req.getParameter("stop").equals("")) {
                positionSet = true;
            }

            if (!req.getParameter("sample1").equals("")) {
                strainsSet = true;
            }

            if (!req.getParameter("geneList").equals("")) {
                genesSet = true;
            }

            if (!req.getParameter("geneStart").equals("") && !req.getParameter("geneStop").equals("")) {
                regionSet = true;
            }


            request.setAttribute("positionSet", positionSet);
            request.setAttribute("strainSet", strainsSet);
            request.setAttribute("genesSet", genesSet);

            request.setAttribute("mapKey", vsb.getMapKey());


            if ((positionSet || genesSet || regionSet) && !strainsSet) {

                SampleDAO sampleDAO = new SampleDAO();
                sampleDAO.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

                request.setAttribute("sampleList", sampleDAO.getSamplesByMapKey(vsb.getMapKey()));

                return new ModelAndView("/WEB-INF/jsp/haplotyper/select.jsp");
            }


            if ((positionSet || genesSet || regionSet) && strainsSet) {
                return new ModelAndView("/WEB-INF/jsp/haplotyper/options.jsp");
            }

        }catch (Exception e) {
            errorList.add(e.getMessage());
        }

        request.setAttribute("error",errorList);

        return new ModelAndView("/WEB-INF/jsp/haplotyper/searchType.jsp");
    }
}
