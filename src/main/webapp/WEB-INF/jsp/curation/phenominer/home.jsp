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
    <tr>
        <td><a href="javascript:addUnit()"><li>Add Unit</a> </td>
    </tr>
</table>

<script type="text/javascript" src="/rgdweb/js/ontologyLookup.js"></script>
<link rel="stylesheet" href="/rgdweb/js/windowfiles/dhtmlwindow.css" type="text/css"/>
<script type="text/javascript" src="/rgdweb/js/windowfiles/dhtmlwindow.js"></script>

<script>
    function addUnit() {
        var unit = document.getElementById("unit");
        unit.style.display = "block";
    }
    function addSD() {
        var ontId = document.getElementById("accId").value;
        if (ontId != null && ontId != "") {
            $.ajax({
                url: "/rgdws/lookup/standardUnit/" + ontId.replace(":", "%3A"), success: function (result) {
                    document.getElementById("unitSD").value = result;
                }
            });
        }
    }
    function checkUnitConversion() {
        var SD = document.getElementById("unitSD").value;
        var unitValue = document.getElementById("unitValue").value;

        if (SD != null && SD != unitValue && SD != "")
            document.getElementById("termScale").style.display = "block";
    }
</script>
<br>
<div id="unit" style="display:none;">
    <form name="addUnitForm" action="home.html" method="get">
        <input type="hidden" name="action" value="addUnit"/>
        <b>Add Unit</b>
        Unit Type: <select name="unitType" id="unitType">
            <option value="3">CMO Unit</option>
            <option value="2">Experiment Unit</option>
        </select>
        *ACC ID <input type="text" id="accId" name="accId" size="40" value="" onchange="addSD()"/>
        <a href="javascript:lookup_treeRender('accId', 'CMO', 'CMO:0000000')"><img src="/rgdweb/common/images/tree.png"
                                                                                   border="0"/></a>
        Standard Unit <input id="unitSD" name="unitSD" style="background-color: #dddddd"
                             readonly="true">
        <br>
        *New Unit <input name="unitValue" id="unitValue" onchange="checkUnitConversion()">
        Description <input name="description">
        <br>
        <input id="termScale" style="display:none;" name="termScale" placeholder="Term Specific Scale">
        <button type="submit">Add</button>
    </form>
</div>

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