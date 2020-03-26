package edu.mcw.rgd.search;

import edu.mcw.rgd.dao.impl.AssociationDAO;
import edu.mcw.rgd.dao.impl.CellLineDAO;
import edu.mcw.rgd.dao.impl.XdbIdDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.search.SearchBean;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;

import java.util.ArrayList;
import java.util.List;

/**
 * RGDSearchController implementation used by the Cell Line Search.
 */
public class CellLineSearchController extends RGDSearchController {

    XdbIdDAO xdao = new XdbIdDAO();
    AssociationDAO adao = new AssociationDAO();

    /**
     * Return all cell line objects.
     *
     * @param search
     * @param req
     * @return
     * @throws Exception
     */
    public Report getReport(SearchBean search, HttpRequestFacade req) throws Exception {

        // page nr
        String p = req.getParameter("p");
        int pageNr = p.isEmpty() ? 1 : Integer.parseInt(p);
        req.getRequest().setAttribute("pageNr", pageNr);

        // page size
        p = req.getParameter("psize");
        int pageSize = p.isEmpty() ? 30 : Integer.parseInt(p);
        req.getRequest().setAttribute("pageSize", pageSize);

        Report report = new Report();

        Record header = new Record();
        header.append("Symbol");
        header.append("Name");
        header.append("Type");
        header.append("Gender");
        header.append("Germline Competent");
        header.append("References");
        header.append("RGD ID");
        header.append("--Symbol--"); // column used only for sorting
        report.append(header);

        for( CellLine cl: new CellLineDAO().getActiveCellLines(pageNr-1, pageSize) ) {

            Record row = new Record();
            String url = "<a href=\""+ Link.cellLine(cl.getRgdId())+"\" title=\"go to cell line report page\">"+
                    cl.getSymbol()+"</a>";
            row.append(url);
            row.append(cl.getName());
            row.append(cl.getObjectType());
            row.append(cl.getGender());
            row.append(cl.getGermlineCompetent());
            row.append(getPubMedIds(cl.getRgdId()));
            row.append(Integer.toString(cl.getRgdId()));
            row.append(cl.getSymbol());
            report.append(row);
        }

        report.sort(6, Report.ASCENDING_SORT, true);
        report.removeColumn(6);

        return report;
    }

    String getPubMedIds(int cellLineRgdId) throws Exception {
        List<XdbId> xdbIds = new ArrayList<>();
        List<Reference> refs = adao.getReferenceAssociations(cellLineRgdId);
        for( Reference ref: refs ) {
            List<XdbId> pubMedIds = xdao.getPubmedIdsByRefRgdId(ref.getRgdId());
            for( XdbId pmid: pubMedIds ) {
                pmid.setLinkText("<a href=\""+Link.ref(ref.getRgdId())+"\">PMID:"+pmid.getAccId()+"</a>");
            }
            xdbIds.addAll(pubMedIds);
        }
        return Utils.concatenate("; ", xdbIds, "getLinkText");
    }

    /**
     * Returns a string representation of the view url.
     * The string returned must be the path to a file on the file system.
     *
     * @return
     */
    public String getViewUrl() {
        return "advanced/cellLines.jsp";
    }
}
