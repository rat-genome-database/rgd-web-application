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
    function CheckPresence(existing, unitValue) {
        for (var i = 0; i < existing.length; i++) {
            if (existing[i].value == unitValue) {
                alert("Unit exists in the database - Only conversion will be added");
                return;
            }
        }
    }
    function saveUnit() {
        var unitType = document.getElementById("unitType").value;
        var unitValue = document.getElementById("unitValue").value;
        if (unitType == 3) {
            CheckPresence(document.getElementsByName("existingCmoUnits")[0].options, unitValue);
        } else {
            CheckPresence(document.getElementsByName("existingExpUnits")[0].options, unitValue);
        }
        document.addUnitForm.submit();
    }
</script>
<br>
<div id="unit" style="display:none; border:1px solid #999; border-radius:5px; padding:15px; margin-top:10px; background-color:#f9f9f9;">
    <form name="addUnitForm" action="home.html" method="get">
        <input type="hidden" name="action" value="addUnit"/>
        <b style="font-size:14px;">Add Unit</b><br><br>
        <table cellpadding="4" cellspacing="0">
            <tr>
                <td><b>Unit Type:</b></td>
                <td><select name="unitType" id="unitType">
                    <option value="3">CMO Unit</option>
                    <option value="2">Experiment Unit</option>
                </select></td>
                <td><b>*ACC ID:</b></td>
                <td><input type="text" id="accId" name="accId" size="40" value="" onchange="addSD()"/>
                    <a href="javascript:lookup_treeRender('accId', 'CMO', 'CMO:0000000')"><img src="/rgdweb/common/images/tree.png" border="0"/></a></td>
                <td><b>Standard Unit:</b></td>
                <td><input id="unitSD" name="unitSD" style="background-color:#dddddd" readonly="true"></td>
            </tr>
            <tr>
                <td><b>Existing CMO Units:</b></td>
                <td><%=fu.buildSelectListNewValue("existingCmoUnits", dao.getDistinct("PHENOMINER_ENUMERABLES where type=3", "label", true), "", false)%></td>
                <td><b>Existing Experiment Units:</b></td>
                <td><%=fu.buildSelectListNewValue("existingExpUnits", dao.getDistinct("PHENOMINER_ENUMERABLES where type=2", "value", true), "", false)%></td>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td><b>*New Unit:</b></td>
                <td><input name="unitValue" id="unitValue" onchange="checkUnitConversion()"></td>
                <td><b>Description:</b></td>
                <td><input name="description" size="40"></td>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td colspan="6">
                    <input id="termScale" style="display:none;" name="termScale" placeholder="Term Specific Scale">
                    <button type="button" onclick="saveUnit()" style="margin-top:5px; padding:4px 12px;">Save</button>
                </td>
            </tr>
        </table>
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