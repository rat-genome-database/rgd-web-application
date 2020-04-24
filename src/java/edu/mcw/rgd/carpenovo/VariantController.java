package edu.mcw.rgd.carpenovo;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.TranscriptDAO;
import edu.mcw.rgd.dao.impl.VariantDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 10/25/11
 * Time: 10:32 AM
 */
public class VariantController extends HaplotyperController {

    // class logger
    Log log = LogFactory.getLog(VariantController.class);

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

    try {

        HttpRequestFacade req = new HttpRequestFacade(request);
        String geneList=req.getParameter("geneList");

        String searchType="";

        if (!req.getParameter("chr").equals("") && !req.getParameter("start").equals("") && !req.getParameter("stop").equals("")) {
            searchType="CHR";

        }else if (!req.getParameter("geneStart").equals("") && !req.getParameter("geneStop").equals("")) {
            searchType="REGION";
        }else if (!geneList.equals("")) {
            if (!geneList.contains("|") && !geneList.contains("*") && Utils.symbolSplit(geneList).size()>1 ) {
                //searchType="LIST";
                return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
            }else {
                searchType="GENE";
            }
        }

        if (!geneList.equals("") && !geneList.contains("|") && !geneList.contains("*")) {
            if (Utils.symbolSplit(geneList).size()>1) {
                return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
            }
        }

        if (geneList.equals("") && !req.getParameter("rdo_term").equals("")) {
            //if (Utils.symbolSplit(geneList).size()>1) {
                return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
            //}
        }

        GeneDAO gdao = new GeneDAO();

        VariantSearchBean vsb = this.fillBean(req);

        VariantDAO vdao = new VariantDAO();
        vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

        int count=0;

        if ((vsb.getStopPosition() - vsb.getStartPosition()) > 30000000) {
            long region = (vsb.getStopPosition() - vsb.getStartPosition()) / 1000000;
            throw new Exception("Maximum Region size is 30MB. Current region is " + region + "MB.");
        }else if ((vsb.getStopPosition() - vsb.getStartPosition()) > 20000000) {
            return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
        }

        if ((vsb.getStopPosition() - vsb.getStartPosition()) > 250000) {
            count = vdao.getPositionCount(vsb);
            System.out.println("position count = " + count);
        }

        SearchResult searchResult = null;


        if (count < 2000 || searchType.equals("GENE")) {

            SNPlotyper snplotyper = new SNPlotyper();

            snplotyper.addSampleIds(vsb.sampleIds);

            List<VariantResult> variantResults = vdao.getVariantAndConservation(vsb);

            System.out.println(variantResults.size());

            for (VariantResult vr: variantResults) {
                if (vr.getVariant() != null) {
                   snplotyper.add(vr);
                }
            }

            List<MappedGene> mappedGenes = gdao.getActiveMappedGenes(vsb.getChromosome(), vsb.getStartPosition(), vsb.getStopPosition(), vsb.getMapKey());
            snplotyper.addGeneMappings(mappedGenes);
            TranscriptDAO tdao = new TranscriptDAO();
            List<MapData> mapData = tdao.getFeaturesByGenomicPos(vsb.getMapKey(),vsb.getChromosome(), (int) (long) vsb.getStartPosition(), (int) (long) vsb.getStopPosition(),15);
            snplotyper.addExons(mapData);

            request.setAttribute("snplotyper",snplotyper);
            request.setAttribute("vsb",vsb);

            // note: call the methods below to catch 'no-strand' exceptions
            boolean b1 = snplotyper.hasPlusStrandConflict();
            boolean b2 = snplotyper.hasMinusStrandConflict();

            return new ModelAndView("/WEB-INF/jsp/haplotyper/variants.jsp", "searchResult", searchResult);
        }else {
            return new ModelAndView("redirect:dist.html?" + request.getQueryString() );
        }

        }catch (Exception e) {

            // do not print stack trace for Exceptions that are 'expected' by us
            if( !(e instanceof VVException) ) {
                e.printStackTrace();
            }

            ArrayList errors = new ArrayList();
            errors.add(e.getMessage());
            request.setAttribute("error", errors);
            return new ModelAndView("/WEB-INF/jsp/haplotyper/region.jsp");
        }
    }
}
