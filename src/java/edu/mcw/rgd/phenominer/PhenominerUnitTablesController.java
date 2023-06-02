package edu.mcw.rgd.phenominer;

import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.pheno.PhenominerUnitTable;
import edu.mcw.rgd.datamodel.pheno.phenominerEnumTable;
import edu.mcw.rgd.datamodel.pheno.phenominerNoStdUnitTable;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

public class PhenominerUnitTablesController extends PhenominerController{
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);
        String action = req.getParameter("act");
        String cmoIdField = req.getParameter("cmoIdField");
        String stdUnitField = req.getParameter("stdUnitField");
        String unitFromField = req.getParameter("unitFromField");
        String typeField = req.getParameter("typeField");
        String labelField = req.getParameter("labelField");

        PhenominerDAO pdao = new PhenominerDAO();
        List<PhenominerUnitTable> phenominerUnitTables = new ArrayList<PhenominerUnitTable>();
        List<phenominerEnumTable> phenominerEnumTables = new ArrayList<phenominerEnumTable>();
        List<phenominerNoStdUnitTable> phenominerNoStdUnitTables = new ArrayList<phenominerNoStdUnitTable>();
        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        Report unitReport = new Report();
        Report enumReport = new Report();
        Report noStdUnitReport = new Report();
        String viewPath = "/WEB-INF/jsp/curation/phenominer/phenominerUnitTables.jsp";

        if(request.getCookies() != null && request.getCookies().length != 0)
            if(request.getCookies()[0].getName().equalsIgnoreCase("accessToken")) {
                String accessToken = request.getCookies()[0].getValue();
                if(!checkToken(accessToken)) {
                   response.sendRedirect("https://github.com/login/oauth/authorize?client_id=7de10c5ae2c3e3825007&scope=user&redirect_uri=https://dev.rgd.mcw.edu/rgdweb/curation/login.html");
                 //   response.sendRedirect(RgdContext.getGithubOauthRedirectUrl());
                    return null;
                }
            }

           //Validation for input fields
            if (cmoIdField.length() != 11 && (stdUnitField == null || stdUnitField == "") && (unitFromField == null || unitFromField == "")) {
                if(!action.equals("enumSearch"))
                    action = "showAll";
            }
            PhenominerUnitTable pUnitTable = new PhenominerUnitTable();
            if (cmoIdField.length() == 11) {
                pUnitTable.setOntId(cmoIdField);
            }
            if (!stdUnitField.equals("")) {
                pUnitTable.setStdUnit(stdUnitField);
            }
            if (!unitFromField.equals("")) {
                pUnitTable.setUnitFrom(unitFromField);
            }
            if (action.equals("unitSearch")) {
                phenominerUnitTables = pdao.getPhenominerUnitSearchResultsTables(pUnitTable);
                if (phenominerUnitTables.isEmpty()) {
                    error.add("0 records found");
                    viewPath = "/WEB-INF/jsp/curation/phenominer/phenominerUnitTables.jsp";
                } else {
                    unitReport = this.buildPhenominerUnitTablesReport(phenominerUnitTables, pdao, false);
                }
            } else {
                phenominerUnitTables = pdao.getPhenominerUnitTables();
                unitReport = this.buildPhenominerUnitTablesReport(phenominerUnitTables, pdao, false);
            }


            if (typeField.length() != 1 && (labelField == null || labelField == "")) {
                if(!action.equals("unitSearch"))
                    action = "showAll";
            }
            phenominerEnumTable pEnumTable = new phenominerEnumTable();
            if (typeField.length() == 1) {
                pEnumTable.setType(Integer.parseInt(typeField));
            }
            if (!labelField.equals("")) {
                pEnumTable.setLabel(labelField);
            }
            if (action.equals("enumSearch")) {
                phenominerEnumTables = pdao.getPhenominerEnumSearchResultsTables(pEnumTable);
                if (phenominerEnumTables.isEmpty()) {
                    error.add("0 records found");
                    viewPath = "/WEB-INF/jsp/curation/phenominer/phenominerUnitTables.jsp";
                } else {
                    enumReport = this.buildPhenominerEnumTablesReport(phenominerEnumTables, pdao, false);
                }
            }else {
                phenominerEnumTables = pdao.getPhenominerEnumTables();
                enumReport = this.buildPhenominerEnumTablesReport(phenominerEnumTables, pdao, false);
            }

        phenominerNoStdUnitTables = pdao.getPhenominerNoStdUnitsTables();
        noStdUnitReport = this.buildPhenominerNoStdUnitTablesReport(phenominerNoStdUnitTables, pdao, false);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);
        request.setAttribute("unitReport", unitReport);
        request.setAttribute("enumReport", enumReport);
        request.setAttribute("noStdUnitReport", noStdUnitReport);

        return new ModelAndView(viewPath);
    }

    //Build unit table records to show on ui
    Report buildPhenominerUnitTablesReport(List<PhenominerUnitTable> phenominerUnitTables, PhenominerDAO dao, boolean edit) throws Exception {
        Report report = new Report();
        Record header = new Record();

        header.append(" ONT ID ");
        header.append(" Standard Unit ");
        header.append(" Unit From ");
        header.append(" Unit To ");
        header.append(" Term Specific Scale ");
        header.append(" Zero Offset ");
        header.append(" ");
        report.insert(0, header);

        for (PhenominerUnitTable pt : phenominerUnitTables) {
            Record rec = new Record();
            rec.append(pt.getOntId());
            rec.append(pt.getStdUnit());
            rec.append(pt.getUnitFrom());
            rec.append(pt.getUnitTo());
            rec.append(String.valueOf(pt.getTermSpecificScale()));
            rec.append(String.valueOf(pt.getZeroOffset()));

            report.append(rec);
        }
        return report;
    }

    //Build unit table records to show on ui
    Report buildPhenominerEnumTablesReport(List<phenominerEnumTable> phenominerEnumTables, PhenominerDAO dao, boolean edit) throws Exception {
        Report report = new Report();
        Record header = new Record();

        header.append(" Type ");
        header.append(" Label ");
        header.append(" Value ");
        header.append(" Description ");
        header.append(" ");
        report.insert(0, header);

        for (phenominerEnumTable pn : phenominerEnumTables) {
            Record rec = new Record();
            rec.append(String.valueOf(pn.getType()));
            rec.append(pn.getLabel());
            rec.append(pn.getValue());
            rec.append(pn.getDescription());
            report.append(rec);
        }
        return report;
    }

    //Build unit table records to show on ui
    Report buildPhenominerNoStdUnitTablesReport(List<phenominerNoStdUnitTable> phenominerNoStdUnitTables, PhenominerDAO dao, boolean edit) throws Exception {
        Report report = new Report();
        Record header = new Record();

        header.append(" ONT ID ");
        header.append(" Term ");
        header.append(" Measurement Units ");
        header.append(" ");
        report.insert(0, header);

        for (phenominerNoStdUnitTable pnStd : phenominerNoStdUnitTables) {
            Record rec = new Record();
            rec.append(pnStd.getOntId());
            rec.append(pnStd.getTerm());
            rec.append(pnStd.getMeasurementUnit());
            report.append(rec);
        }
        return report;
    }
}
