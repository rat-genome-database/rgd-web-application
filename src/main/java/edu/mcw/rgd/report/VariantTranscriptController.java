package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.dao.impl.variants.VariantDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.vv.VariantController;
import edu.mcw.rgd.vv.vvservice.VVService;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

public class VariantTranscriptController implements Controller {
    VariantController ctrl = new VariantController();
    VariantDAO vdao= new VariantDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);
        SampleDAO sdao = new SampleDAO();
        sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
        String vid = req.getParameter("vid");
        String sid = req.getParameter("sid");

        int rgdId = Integer.parseInt(vid);
        int sampleId = Integer.parseInt(sid);
        Sample s = sdao.getSampleBySampleId(sampleId);

        int mapKey = s.getMapKey(); // will be sample mapKey
        List<SearchResult> allResults = new ArrayList<SearchResult>();
        VariantSearchBean vsb = new VariantSearchBean(mapKey); // sample contains the mapKey
        vsb.sampleIds.add(sampleId);
        vsb.setVariantId(rgdId);
        try {
            List<VariantResult> vr = ctrl.getVariantResults(vsb, req, true);
            SearchResult sr = new SearchResult();

            sr.setVariantResults(vr);
            allResults.add(sr); // add this to request or whatever
//        System.out.println(allResults.size());
        } catch (Exception e) {
            System.out.println(e);
        }
        request.setAttribute("searchResults", allResults);
        return new ModelAndView("/WEB-INF/jsp/report/cnVariants/transcripts.jsp");
    }
}
