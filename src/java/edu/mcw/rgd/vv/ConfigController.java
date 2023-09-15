package edu.mcw.rgd.vv;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.datamodel.Sample;
import edu.mcw.rgd.datamodel.VariantSearchBean;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 10/21/11
 * Time: 9:53 AM
 */
public class ConfigController extends HaplotyperController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ArrayList errorList = new ArrayList();

        boolean positionSet=false;
        boolean strainsSet=false;
        boolean genesSet=false;
        boolean regionSet=false;
        long region=0L;
        VariantSearchBean vsb=new VariantSearchBean(0);

        try {
            HttpRequestFacade req = new HttpRequestFacade(request);

            vsb = this.fillBean(req);
            request.setAttribute("vsb", vsb);
           // System.out.println("IN CONFIG CONTRL: MAPKEY: "+vsb.getMapKey()+"\tstart: "+vsb.getStartPosition()+"\tstp:"+vsb.getStopPosition() );
            if ((vsb.getStopPosition() - vsb.getStartPosition()) > 30000000) {
                region = (vsb.getStopPosition() - vsb.getStartPosition()) / 1000000;
                throw new Exception("Maximum Region size is 30MB. Current region is " + region + "MB.");

            }

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
            request.setAttribute("sampleIds", vsb.sampleIds);

            if ((positionSet || genesSet || regionSet) && !strainsSet) {

                SampleDAO sampleDAO = new SampleDAO();
                sampleDAO.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
                List<Sample> samples=new ArrayList<>();
                if(vsb.getMapKey()==17){
                    List<String> populations=new ArrayList<> (Arrays.asList("FIN", "GBR"));
                    for(String population:populations) {
                        samples.addAll(sampleDAO.getSamplesByMapKey(vsb.getMapKey(), population));
                    }
                }else
                      samples=  sampleDAO.getSamplesByMapKey(vsb.getMapKey());
                request.setAttribute("sampleList",samples );

                return new ModelAndView("/WEB-INF/jsp/vv/select.jsp");
            }
          /*  if ((vsb.sampleIds.size()>50)) {
                String msg="Maximum samples size should be less than 50. You selected  " +vsb.getSampleIds().size()+". Please <span style='color:grey;font-weight:bold'>EDIT STRAINS</span> to reduce the number of samples.";
                response.sendRedirect("select.html?"+request.getQueryString()+"&msg="+msg);

            }*/

            if ((positionSet || genesSet || regionSet) && strainsSet) {

                return new ModelAndView("/WEB-INF/jsp/vv/options.jsp");
            }

        }catch (Exception e) {
            errorList.add(e.getMessage());
            request.setAttribute("error", errorList);
           if(vsb!=null) {
               request.setAttribute("start", vsb.getStartPosition());
               request.setAttribute("stop", vsb.getStopPosition());
               request.setAttribute("chr", vsb.getChromosome());
           }
         /*   if(vsb.getSampleIds().size()>50){
                return new ModelAndView("/WEB-INF/jsp/vv/select.jsp");
            }*/
            return new ModelAndView("/WEB-INF/jsp/vv/region.jsp");
        }

        request.setAttribute("error",errorList);

        return new ModelAndView("/WEB-INF/jsp/vv/searchType.jsp");
    }
}
