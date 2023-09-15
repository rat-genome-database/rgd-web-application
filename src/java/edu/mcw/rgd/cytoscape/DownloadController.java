package edu.mcw.rgd.cytoscape;

import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;

/**
 * Created by jthota on 3/21/2019.
 */
public class DownloadController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpSession session=request.getSession();
        List<InteractionReportRecord> records= (List<InteractionReportRecord>) session.getAttribute("records");
        //System.out.println(records.size());
        Report report= new Report();
        Record header =new Record();

        header.append("Interactor_A");
        header.append("Gene_A");
        header.append("Gene_A_RGD_ID");
        header.append("Interactor B");
        header.append("Gene_B");
        header.append("Gene_B_RGD_ID");
        header.append("Species A");
        header.append("Species B");
        header.append("Interaction Type");
        header .append("Attributes");
        report.append(header);

        for(InteractionReportRecord r:records){
            Record rec=new Record();
            rec.append(r.getProteinUniprotId1());
            rec.append(r.getGeneSymbol1());
            rec.append(r.getGeneRgdId1());
            rec.append(r.getProteinUniprotId2());
            rec.append(r.getGeneSymbol2());
            rec.append(r.getGeneRgdId2());
            rec.append(r.getSpecies1());
            rec.append(r.getSpecies2());
            rec.append(r.getInteractionType());
            rec.append(r.getAttributes());
            report.append(rec);
        }
        request.setAttribute("report", report);
        return new ModelAndView("/WEB-INF/jsp/cytoscape/download.jsp");
    }
}
