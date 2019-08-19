package edu.mcw.rgd.carpenovo;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.VariantDAO;
import edu.mcw.rgd.datamodel.SearchResult;
import edu.mcw.rgd.datamodel.VariantResult;
import edu.mcw.rgd.datamodel.VariantSearchBean;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 9/25/12
 * Time: 9:49 AM
 */
public class DetailController extends HaplotyperController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

         try {
             return handle(request);
         }catch (Exception e) {

            // do not print stack trace for Exceptions that are 'expected' by us
            if( !(e instanceof VVException) ) {
                e.printStackTrace();
            }

            request.setAttribute("error",e.getMessage());
            return new ModelAndView("/WEB-INF/jsp/haplotyper/region.jsp");
        }
    }

    ModelAndView handle(HttpServletRequest request) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        String vid = req.getParameter("vid");
        String sid = req.getParameter("sid");

        int mapKey = 60; // map key defaults to rat assembly 3.4
        String mapKeyStr = request.getParameter("mapKey");
        if( mapKeyStr!=null && !mapKeyStr.isEmpty() )
           mapKey = Integer.parseInt(mapKeyStr);

        if( vid.isEmpty() ) {

            VariantSearchBean vsb = new VariantSearchBean(mapKey);

            if( !sid.isEmpty() )
               vsb.sampleIds.add(Integer.parseInt(sid));

            vsb.setPosition(req.getParameter("chr"), req.getParameter("start"), req.getParameter("stop"));

            // there must be start and stop position
            if( Utils.isStringEmpty(vsb.getChromosome()) ||
                vsb.getStartPosition()==null || vsb.getStartPosition()<1 ||
                vsb.getStopPosition()==null || vsb.getStopPosition()<vsb.getStartPosition() ) {

                throw new VVException("variant detail: missing chr or start or stop");
            }

            VariantDAO vdao = new VariantDAO();
            vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

            SearchResult sr = new SearchResult();
            List<VariantResult> vr = vdao.getVariantResults(vsb);

            sr.setVariantResults(vr);

            return new ModelAndView("/WEB-INF/jsp/haplotyper/detail.jsp", "searchResult", sr);

        } else {

            String[] vids = vid.split("\\|");

            VariantDAO vdao = new VariantDAO();

            List<SearchResult> allResults = new ArrayList<SearchResult>();
            for (int i=0; i < vids.length; i++) {

               SearchResult sr = new SearchResult();
               VariantSearchBean vsb = new VariantSearchBean(mapKey);


               vsb.setVariantId(Long.parseLong(vids[i]));

               vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
               List<VariantResult> vr = vdao.getVariantResults(vsb);

               sr.setVariantResults(vr);
               allResults.add(sr);
            }

            request.setAttribute("searchResults",allResults);

            return new ModelAndView("/WEB-INF/jsp/haplotyper/detail.jsp");
        }
    }
}
