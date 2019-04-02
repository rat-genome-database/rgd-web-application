package edu.mcw.rgd.report;


import edu.mcw.rgd.dao.impl.StrainDAO;
import edu.mcw.rgd.datamodel.Strain;
import edu.mcw.rgd.datamodel.Map;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.VariantDAO;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.datamodel.Variant;
import edu.mcw.rgd.datamodel.Sample;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.HashMap;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Created by hsnalabolu on 11/26/2018.
 */
public class DamagingVariantController implements Controller{

    private Set<String> geneList = new TreeSet<String>();

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        int sampleId = Integer.parseInt(Utils.NVL(request.getParameter("id"), "0"));
        String fmt = Utils.NVL(request.getParameter("fmt"), "full"); // one of 'full','csv','tab','print'
        int assembly = Integer.parseInt(Utils.NVL(request.getParameter("map"),"0"));
        SampleDAO sampleDAO = new SampleDAO();
        sampleDAO.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
        Sample obj;
        Map m = MapManager.getInstance().getMap(assembly);
        try {
            obj = sampleDAO.getSampleBySampleId(sampleId);
            System.out.println(obj.getAnalysisName());
        } catch(Exception e) {
            obj = new Sample();
            obj.setAnalysisName("");
        }
        request.setAttribute("sample", obj.getAnalysisName());
        request.setAttribute("assembly",m.getName());
        request.setAttribute("mapKey",m.getKey());
        request.setAttribute("species",m.getSpeciesTypeKey());
        request.setAttribute("sampleId",sampleId);
        Report report = getDamagingVariants(sampleId,assembly);
        request.setAttribute("report", report);
        request.setAttribute("geneList",geneList);

        return new ModelAndView("/WEB-INF/jsp/report/strain/damagingVariants_"+fmt+".jsp");
    }
    private Report getDamagingVariants(int sampleId,int assembly) throws Exception {
        VariantDAO vdao = new VariantDAO();
        vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
        List<Variant> variants = vdao.getDamagingVariantsForSampleByAssembly(sampleId,assembly);
        SampleDAO sdao = new SampleDAO();
        sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

        Report report = new Report();
        edu.mcw.rgd.reporting.Record rec = new edu.mcw.rgd.reporting.Record();
        rec.append("Chromosome");
        rec.append("Position Start");
        rec.append("Position End");
        rec.append("Reference Nucleotide");
        rec.append("Variant Nucleotide");
        rec.append("Variant Type");
        rec.append("GeneSymbol");
        report.append(rec);

        for (Variant v : variants) {

            rec = new edu.mcw.rgd.reporting.Record();
            rec.append(v.getChromosome());
            rec.append(String.valueOf(v.getStartPos()));
            rec.append(String.valueOf(v.getEndPos()));
            rec.append(v.getReferenceNucleotide());
            rec.append(v.getVariantNucleotide());
            rec.append(v.getVariantType());
            rec.append(v.getRegionName());
            geneList.add(v.getRegionName());

            report.append(rec);
        }

        return report;
    }
}
