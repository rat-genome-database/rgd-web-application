<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Experiment" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Record" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Condition" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Ontology" %>
<%
    String pageTitle = "Phenominer Curation";
    String headContent = "";
    String pageDescription = "";

%>


<%@ include file="editHeader.jsp"%>


<span class="phenominerPageHeader">Phenominer Curation</span>
<br><br>

<table>
    <tr>
        <td><a href="studies.html?act=new"><li>Create a New Study</a> </td>
    </tr>
    <tr>
        <td><a href="studies.html"><li>View All Studies</a> </td>
    </tr>
    <tr>
        <td><a href="search.html"><li>Search Phenominer</a> </td>
    </tr>
    <tr>
        <td><a href="phenominerUnits.html"><li>CMO Unit QC</a> </td>
    </tr>
    <tr>
        <td><a href="phenominerUnitTables.html"><li>View Phenominer Unit Tables</a> </td>
    </tr>
</table>


<%
    if (req.getParameter("fix").equals("1")) {

        try{

            dao = new PhenominerDAO();
            List<Study> sList = dao.getStudies();

            for (Study s: sList) {
                List<Experiment> eList = dao.getExperiments(s.getId());

                for (Experiment e: eList) {
                    List<Record> rList = dao.getRecords(e.getId());
                    for (Record r: rList) {
                        r.getClinicalMeasurement().setAccId(Ontology.formatId(r.getClinicalMeasurement().getAccId()));
                        r.getSample().setStrainAccId(Ontology.formatId(r.getSample().getStrainAccId()));
                        r.getMeasurementMethod().setAccId(Ontology.formatId(r.getMeasurementMethod().getAccId()));

                        for (Condition c: r.getConditions()) {
                            c.setOntologyId(Ontology.formatId(c.getOntologyId()));
                        }

                        dao.updateRecord(r);
                    }


                }
            }


        }catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<%@ include file="editFooter.jsp"%>