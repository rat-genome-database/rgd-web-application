package edu.mcw.rgd.ga;

import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.datamodel.XDBIndex;
import edu.mcw.rgd.datamodel.XdbId;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.report.DaoUtils;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class GADownloadController extends GAController {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    String del = "\t";

    PrintWriter out = null;

    private void print(String str) {
        out.print(str + del);
    }

    private void print(int str) {
        print(str + "");
    }

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        this.request = request;
        this.response = response;

        HttpRequestFacade req = new HttpRequestFacade(request);

        this.init(request,response);

        GeneDAO gdao = new GeneDAO();

            response.setHeader("Content-Type", "text/tab");
            response.setHeader("Content-disposition", "attachment;filename=\"report.tab\"");

            int speciesTypeKey = Integer.parseInt(req.getParameter("species"));

            this.out = response.getWriter();

            response.getWriter().println("Date:" + new SimpleDateFormat("EEE, d MMM yyyy HH:mm:ss Z").format(new Date()));


            //System.out.println(req.getParameter("rgdId"));
            //System.out.println(req.getParameter("chr"));


            if (!req.getParameter("rgdId").equals("")) {
                this.writeRecord(req.getParameter("rgdId") ,speciesTypeKey,gdao, req);
            }else {
                ObjectMapper om = this.buildMapper(req.getParameter("idType"));

                Iterator it = om.getMapped().iterator();
                while (it.hasNext()) {
                        Gene g = (Gene) it.next();
                       this.writeRecord(g,speciesTypeKey,gdao, req);
                }

            }


            return null;


    }

    private void writeRecord(Gene g, int speciesTypeKey, GeneDAO gdao, HttpRequestFacade req) throws Exception {

        print("Species");
        print("Symbol");
        print(RgdContext.getSiteName(request) + " ID");
        print("URL");

        print("");

        int rgdId = g.getRgdId();

        List<Gene> orthologs = gdao.getActiveOrthologs(rgdId);
        List<String> orthologKeys = req.getParameterValues("ortholog");
        Map orthoMap = new HashMap();

        for (String key : orthologKeys) {
            orthoMap.put(Integer.parseInt(key), null);
        }

        Map aspects = new HashMap();
        aspects.put("W", "Pathway");
        aspects.put("N", "Phenotype");
        aspects.put("D", "Disease");
        aspects.put("C", "GO: Cellular Component");
        aspects.put("P", "GO: Biological Process");
        aspects.put("B", "Neuro Behavioral");
        aspects.put("F", "GO: Molecular Function");

        orthologs.add(0, g);

        AnnotationDAO adao = new AnnotationDAO();

        List<String> ontologies = req.getParameterValues("o");

        LinkedHashMap termLines = new LinkedHashMap();
        ArrayList xdbLines = new ArrayList();
        ArrayList orthoLines = new ArrayList();

        for (String asp : ontologies) {
            int count = 0;

            print(aspects.get(asp) + " Ontology");
            print("Acc ID");
            print("Term");
            print("Evidence Code");
            print("Reference " + RgdContext.getSiteName(request) + " ID");
            print("");

            if (!termLines.containsKey(asp)) {
                termLines.put(asp, new ArrayList());
            }

            for (Gene ortho : orthologs) {
                List<Annotation> annotList = adao.getAnnotationsByAspect(ortho.getRgdId(), asp);

                Annotation lastAnnot = null;
                for (Annotation annot : annotList) {

                    if (lastAnnot != null && (lastAnnot.getAnnotatedObjectRgdId().equals(annot.getAnnotatedObjectRgdId()) && lastAnnot.getTermAcc().equals(annot.getTermAcc()) && lastAnnot.getEvidence().equals(annot.getEvidence()) && lastAnnot.getRefRgdId().equals(annot.getRefRgdId()))) {
                        continue;
                    }

                    if (count == 0) {
                        aspects.put(annot.getAspect(), null);
                    }
                    count++;

                    if (ortho.getSpeciesTypeKey() == speciesTypeKey || orthoMap.containsKey(ortho.getSpeciesTypeKey())) {
                        List termList = (List) termLines.get(asp);
                        termList.add(SpeciesType.getCommonName(ortho.getSpeciesTypeKey()) + del + annot.getTermAcc() + del + annot.getTerm() + del + annot.getEvidence() + del + annot.getRefRgdId() + del + del);
                    }
                    lastAnnot = annot;
                }
            }
        }

        print("External Database");
        print("External Database ID");
        print("External Database URL");
        response.getWriter().println("External Database Source(s)");

        List<XdbId> xdbids;
        if (req.getParameterValues("x").size() > 0) {
            xdbids = DaoUtils.getInstance().getExternalDbLinksForGATool(req.getParameterValues("x"), rgdId);
        } else
            xdbids = Collections.emptyList();

        XDBIndex xdb = XDBIndex.getInstance();
        for (XdbId xdbId : xdbids) {
            xdbLines.add(xdb.getXDB(xdbId.getXdbKey()).getName() + del + xdbId.getAccId() + del + xdb.getXDB(xdbId.getXdbKey()).getSpeciesURL(speciesTypeKey) + xdbId.getAccId() + del + xdbId.getSrcPipeline());
        }


        if (RgdContext.isChinchilla(request)) {
            orthoLines.add(SpeciesType.getCommonName(g.getSpeciesTypeKey()) + del + g.getSymbol() + del + rgdId + del + "http://crrd.mcw.edu" + Link.gene(rgdId) + del + del);
        } else {
            orthoLines.add(SpeciesType.getCommonName(g.getSpeciesTypeKey()) + del + g.getSymbol() + del + rgdId + del + "http://rgd.mcw.edu" + Link.gene(rgdId) + del + del);

        }
        for (Gene ortho : orthologs) {
            if (orthoMap.containsKey(ortho.getSpeciesTypeKey())) {

                if (RgdContext.isChinchilla(request)) {
                    orthoLines.add(SpeciesType.getCommonName(ortho.getSpeciesTypeKey()) + del + ortho.getSymbol() + del + ortho.getRgdId() + del + "http://crrd.mcw.edu" + Link.gene(ortho.getRgdId()) + del + del);

                }else {

                    orthoLines.add(SpeciesType.getCommonName(ortho.getSpeciesTypeKey()) + del + ortho.getSymbol() + del + ortho.getRgdId() + del + "http://rgd.mcw.edu" + Link.gene(ortho.getRgdId()) + del + del);
                }
            }
        }


        int count=0;
        boolean more = true;
        while (more) {
           more = false;

            if (orthoLines.size() > count) {
                response.getWriter().print(orthoLines.get(count));
                more = true;
            }else {
                response.getWriter().print(del + del + del + del + del);
            }


            Iterator termIt = termLines.keySet().iterator();

            while (termIt.hasNext()) {
                List lst = (List) termLines.get(termIt.next());
                if (lst.size() > count) {
                    response.getWriter().print(lst.get(count));
                    more=true;
                }else {
                    response.getWriter().print(del + del + del + del + del + del);
                }
            }


            if (xdbLines.size() > count) {
                response.getWriter().print(xdbLines.get(count));
                more=true;
            }else {
                response.getWriter().print(del+ del + del + del + del + del);
            }

            response.getWriter().println("");
            count++;

        }

        response.flushBuffer();

    }



    private void writeRecord(String identifier, int speciesTypeKey, GeneDAO gdao, HttpRequestFacade req) throws Exception {

        Gene g;

        try {
            int id = Integer.parseInt(identifier);
            g = gdao.getGene(id);
        } catch (Exception isString) {
            g = gdao.getGenesBySymbol(identifier, speciesTypeKey);
        }


        if (g == null) {
            response.getWriter().println(identifier + " not found");
        }else {
            this.writeRecord(g,speciesTypeKey,gdao,req);
        }

    }


}

