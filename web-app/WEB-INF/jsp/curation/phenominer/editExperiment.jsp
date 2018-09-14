<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Experiment" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.*" %>
<%@ page import="edu.mcw.rgd.reporting.Record" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%
    String pageTitle = "Edit Experiment";
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="editHeader.jsp"%>
<%
    String studyId = req.getParameter("studyId");
    List<String> idList = req.getParameterValues("expId");

    String title="Create Experiment";
    if (idList.size() > 0) {
        title = "Edit Experiment";
    }
%>
<span class="phenominerPageHeader"><%=title%></span>

<div class="phenoNavBar">
<table >
    <tr>
        <% if (!req.getParameter("studyId").equals("")) { %>
            <td><a href='experiments.html?act=new&studyId=<%=req.getParameter("studyId")%>'>Create New Experiment</a></td>
            <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <% } %>

        <td><a href='home.html'>Home</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='search.html'>Search</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='studies.html'>List All Studies</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href="experiments.html?studyId=<%=studyId%>">All Experiments</a></td>
    </tr>
</table>
</div>
<%
if (idList.size() > 0) {
    Report report = (Report) request.getAttribute("report");
        
    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties("width='75%' class='sortable'");

    out.print(report.format(strat));
}
    Experiment ex = new Experiment();

    if (idList.size() == 1) {
        ex = dao.getExperiment(Integer.parseInt(idList.get(0)));
    }

%>
<script type="text/javascript" src="/rgdweb/js/ontologyLookup.js"></script>
<script type="text/javascript" src="/OntoSolr/files/jquery-1.4.3.min.js"></script>
<script type="text/javascript" src="/OntoSolr/files/jquery.autocomplete.js"></script>
<script type="text/javascript" src="/OntoSolr/files/ont_util.js"></script>

<script>
$(document).ready(function(){
    var not4Curation = ' AND NOT Not4Curation';
    $("#traitOntId").autocomplete('/OntoSolr/select', {
                extraParams:{
                'qf': 'term^2 synonym^1 idl_s^1',
                'fq': 'cat:(VT OR RDO)'+not4Curation,
                'wt': 'velocity',
                'v.template': 'termidsel_cur'
              },
              max: 10000
            }
    );
  $("#traitOntId").result(function(data, value){
     $("#name").val(value[0]);
      $("#traitOntId").val(value[1]);
     });

    $("#traitOntId").keyup(function(event){
       getOntTerms($("#traitOntId").val(), "#name");
        $("#name").css("color", "blue");
    });

});
</script>

<form action="experiments.html" method="get" >

<input type="hidden" name="act" value="save"/>

<% for (String id: idList) { %>
    <input type="hidden" name="expId" value="<%=id%>"/>
<% } %>

    <br>
<table>
    <% if (idList.size() != 0) {
        String studyDisplay = "";
        if (ex.getStudyId() != 0) {
            studyDisplay=ex.getStudyId() + "";
        }
    %>
    <tr>
        <td>Study ID</td><td><input type="text" name="studyId" id="studyId" value="<%=dm.out("studyId", studyDisplay)%>"> </td>
    </tr>
    <% } else {%>    
        <input type="hidden" name="studyId" value="<%=studyId%>"/>
    <% } %>
    <tr>
        <td>Acc ID:</td><td><input id="traitOntId" type="text" name="traitOntId" size="30" value="<%=dm.out("traitOntId", ex.getTraitOntId())%>">&nbsp;<a href="javascript:lookup_treeRender('traitOntId', '', '')"><img src="/rgdweb/common/images/tree.png" border="0"/></a>&nbsp;
        &#160;&#160; Experimental name: <input type="text" name="name" size="50" id="name" value="<%=dm.out("name", ex.getName())%>"  style="background-color: #dddddd" readonly="true"> </td>
    </tr>
    <tr>
        <td>Notes:</td><td><textarea name="notes" rows="6" cols="25" id="notes"><%=dm.out("notes",ex.getNotes())%></textarea> </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td>Curation status of <br> all experiment records:</td><td><%=fu.buildSelectList("sStatus", dao.getEnumerableMap(6, 0, true), "")%> </td>
    </tr>
    <tr>
        <td colspan="2"><td><input type="submit" value="Save Experiment"></td></td>
    </tr>

</table>

</form>

<%@ include file="editFooter.jsp"%>