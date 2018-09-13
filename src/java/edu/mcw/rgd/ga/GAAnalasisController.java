package edu.mcw.rgd.ga;

import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.XdbIdDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.datamodel.XDBIndex;
import edu.mcw.rgd.datamodel.XdbId;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class GAAnalasisController implements Controller {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        this.request = request;
        this.response = response;

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        HttpRequestFacade req = new HttpRequestFacade(request);

        GeneDAO gdao = new GeneDAO();
        if (req.getParameter("download").equals("1")) {

            response.setHeader("Content-disposition", "attachment;filename=\"report.tab\"");

            int speciesTypeKey = Integer.parseInt(req.getParameter("species"));


            if (!req.getParameter("rgdId").equals("")) {
                this.writeRecord(req.getParameter("rgdId") ,speciesTypeKey,gdao, req);
            }else {
                String geneList = req.getParameter("genes");
                Pattern pattern = Pattern.compile("[\\w]+");
                Matcher matcher = pattern.matcher(geneList);

                while (matcher.find()) {
                    String match = matcher.group();
                    this.writeRecord(match,speciesTypeKey,gdao, req);
                }
            }

            return null;
        }


        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/ga/dist.jsp", "hello", null);
    }


    private void writeRecord(String identifier, int speciesTypeKey, GeneDAO gdao, HttpRequestFacade req) throws Exception {

        String del = "\t";
        Gene g = null;

        try {
            int id = Integer.parseInt(identifier);
            g = gdao.getGene(id);
        } catch (Exception isString) {
            g = gdao.getGenesBySymbol(identifier, speciesTypeKey);
        }


        if (g == null) {
            response.getWriter().println(identifier + " not found");
        }


        int rgdId = g.getRgdId();

        List<Gene> orthologs = gdao.getActiveOrthologs(rgdId);
        List<String> orthologKeys = req.getParameterValues("ortholog");
        Map orthoMap = new HashMap();

        for (String key : orthologKeys) {
            orthoMap.put(Integer.parseInt(key), null);
        }

        response.getWriter().println("\nObject Information"+ del+ del+ del+ del);

        response.getWriter().print(g.getSymbol() + del);
        response.getWriter().print(g.getRgdId() + del);
        response.getWriter().print(SpeciesType.getCommonName(g.getSpeciesTypeKey()) + del);
        response.getWriter().print(Link.gene(g.getRgdId()) + del);
        response.getWriter().println(Link.gene(g.getRgdId()));

        response.getWriter().println("\nOrthologs" + del+ del+ del+ del);
        for (Gene ortho : orthologs) {
            if (orthoMap.containsKey(ortho.getSpeciesTypeKey())) {

                response.getWriter().print(ortho.getSymbol() + del);
                response.getWriter().print(ortho.getRgdId() + del);
                response.getWriter().print(SpeciesType.getCommonName(ortho.getSpeciesTypeKey()) + del);
                response.getWriter().print(Link.gene(ortho.getRgdId()) + del);
                response.getWriter().println();
            }
        }

        Map aspects = new HashMap();
        aspects.put("W","Pathway");
        aspects.put("N","Phenotype");
        aspects.put("D","Disease");
        aspects.put("C","GO: Cellular Component");
        aspects.put("P","GO: Biological Process");
        aspects.put("B","Neuro Behavioral");
        aspects.put("F","GO: Molecular Function");

        orthologs.add(0, g);

        AnnotationDAO adao = new AnnotationDAO();

        List<String> ontologies = req.getParameterValues("ontology");

        response.getWriter().println("\nAnnotations");


        for (String asp : ontologies) {
            int count = 0;

            for (Gene ortho : orthologs) {
                List<Annotation> annotList = adao.getAnnotationsByAspect(ortho.getRgdId(), asp);
                for (Annotation annot : annotList) {
                    if (count == 0) {
                        response.getWriter().println("\n" + aspects.get(annot.getAspect()));

                        aspects.put(annot.getAspect(), null);
                    }
                    count++;

                    if (ortho.getSpeciesTypeKey() == speciesTypeKey || orthoMap.containsKey(ortho.getSpeciesTypeKey())) {

                        response.getWriter().print(SpeciesType.getCommonName(ortho.getSpeciesTypeKey()) + del);
                        response.getWriter().print(annot.getTermAcc() + del);
                        response.getWriter().print(annot.getTerm() + del);
                        response.getWriter().print(annot.getEvidence() + del);
                        response.getWriter().println(annot.getRefRgdId());
                    }
                }
            }
        }

        response.getWriter().println("\nExternal Links" + del + del + del + del);

        XdbIdDAO xdao = new XdbIdDAO();

        List<XdbId> xdbids = new ArrayList();

        if (req.getParameterValues("xdb").size() > 0) {
            xdbids = xdao.getXdbIdsByRgdId(req.getParameterValues("xdb"), g.getRgdId());
        }


        XDBIndex xdb = XDBIndex.getInstance();

        for (XdbId xdbId : xdbids) {

            response.getWriter().print(XDBIndex.getInstance().getXDB(xdbId.getXdbKey()).getName() + del);
            response.getWriter().print(xdbId.getAccId() + del);
            response.getWriter().print(xdb.getXDB(xdbId.getXdbKey()).getUrl() + xdbId.getAccId());
            response.getWriter().print(del);
            response.getWriter().println();


        }

        response.flushBuffer();

    }


}