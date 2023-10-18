package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.MiRnaTargetDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.MiRnaTarget;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 6/12/15
 * Time: 4:34 PM
 * <p>
 * to download (often very long) list of mirna targets data for a given gene
 */
public class MirnaTargetsController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        int rgdId = Integer.parseInt(Utils.NVL(request.getParameter("id"), "0"));
        String fmt = Utils.NVL(request.getParameter("fmt"), "full"); // one of 'full','csv','tab','print'

        GeneDAO geneDAO = new GeneDAO();
        Gene obj;
        try {
            obj = geneDAO.getGene(rgdId);
        } catch(GeneDAO.GeneDAOException e) {
            obj = new Gene();
            obj.setSymbol("");
        }
        request.setAttribute("geneSymbol", obj.getSymbol());

        Report report = getMirnaData(obj, geneDAO, fmt.equals("full"), request);
        request.setAttribute("report", report);
        return new ModelAndView("/WEB-INF/jsp/report/miRnaTargets_"+fmt+".jsp");
    }

    Report getMirnaData(Gene obj, GeneDAO dao, boolean generateGeneLinks, HttpServletRequest request) throws Exception {

        // detect if this gene is a mirna gene or not
        boolean isMirnaGene = Utils.stringsAreEqualIgnoreCase(obj.getType(), "ncrna") &&
                Utils.defaultString(obj.getName()).startsWith("microRNA");
        List<MiRnaTarget> miRnaTargets;
        if( isMirnaGene ) {
            miRnaTargets = new MiRnaTargetDAO().getTargets(obj.getRgdId());
        } else {
            miRnaTargets = new MiRnaTargetDAO().getMiRnaGenes(obj.getRgdId());
        }

        // sort first by target type, then by rgd id
        Collections.sort(miRnaTargets, new Comparator<MiRnaTarget>() {
            @Override
            public int compare(MiRnaTarget o1, MiRnaTarget o2) {
                int r = o1.getTargetType().compareTo(o2.getTargetType());
                if( r!=0 )
                    return r;
                r = o1.getGeneRgdId()-o2.getGeneRgdId();
                if( r!=0 )
                    return r;
                return o1.getMiRnaRgdId() - o2.getMiRnaRgdId();
            }
        });

        // create report header
        Report report = new Report();
        Record rec = new Record();
        rec.append("Target Type");
        if( isMirnaGene ) {
            rec.append("Target Gene " + RgdContext.getSiteName(request) + " Id");
            rec.append("Target Gene Symbol");
        } else {
            rec.append("miRNA Gene " + RgdContext.getSiteName(request) + " Id");
            rec.append("miRNA Gene Symbol");
        }
        rec.append("Mature miRNA");
        rec.append("Method Name");
        rec.append("Result Type");
        rec.append("Data Type");
        rec.append("Support Type");
        rec.append("PMID");

        rec.append("Target Transcript Acc");
        rec.append("Transcript Biotype");
        rec.append("Isoform");
        rec.append("Amplification");
        rec.append("UTR Start");
        rec.append("UTR End");
        rec.append("Target Site");
        rec.append("Score");
        rec.append("Normalized Score");
        rec.append("Energy");
        report.append(rec);

        report.addSortMapping(13, Report.NUMERIC_SORT); // UTR Start
        report.addSortMapping(14, Report.NUMERIC_SORT); // UTR stop
        report.addSortMapping(16, Report.NUMERIC_SORT); // score
        report.addSortMapping(17, Report.NUMERIC_SORT); // norm score
        report.addSortMapping(18, Report.NUMERIC_SORT); // energy

        Map<Integer, String> geneSymbols = new HashMap<>();
        for( MiRnaTarget t: miRnaTargets ) {
            int geneRgdId = isMirnaGene ? t.getGeneRgdId() : t.getMiRnaRgdId();
            String geneSymbol = geneSymbols.get(geneRgdId);
            if( geneSymbol == null ) {
                Gene gene = dao.getGene(geneRgdId);
                geneSymbol = Utils.NVL(gene.getSymbol(), "");
                geneSymbols.put(geneRgdId, geneSymbol);
            }

            rec = new Record();
            rec.append(t.getTargetType());
            if( generateGeneLinks ) {
                rec.append("<a href=\""+Link.gene(geneRgdId)+"\">"+geneRgdId+"</a>");
            } else {
                rec.append(Integer.toString(geneRgdId));
            }
            rec.append(geneSymbol);
            rec.append(t.getMiRnaSymbol());
            rec.append(t.getMethodName());
            rec.append(t.getResultType());
            rec.append(t.getDataType());
            rec.append(t.getSupportType());
            rec.append(t.getPmid());

            rec.append(t.getTranscriptAcc());
            rec.append(t.getTranscriptBioType());
            rec.append(t.getIsoform());
            rec.append(t.getAmplification());
            rec.append(t.getUtrStart()==null?"":Integer.toString(t.getUtrStart()));
            rec.append(t.getUtrEnd()==null?"":Integer.toString(t.getUtrEnd()));
            rec.append(t.getTargetSite());
            rec.append(t.printScore());
            rec.append(t.printNormalizedScore());
            rec.append(t.printEnergy());
            report.append(rec);
        }

        return report;
    }
}
