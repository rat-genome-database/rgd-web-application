<%@ page import="edu.mcw.rgd.datamodel.pheno.Experiment" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.*" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<%
    String pageTitle = "Edit Experiment";
    String headContent = "";
    String pageDescription = "";
%>
<%
    String studyId = request.getParameter("studyId");

    String title="Create Experiment";

%>
<span><%=title%></span>

<%@ include file="/common/headerarea_phenominer.jsp"%>
<script type="text/javascript" src="/rgdweb/js/ontologyLookup.js"></script>
<script type="text/javascript" src="/QueryBuilder/js/jquery.autocomplete.js"></script>

<script type="text/javascript" src="/rgdweb/OntoSolr/ont_util.js"></script>

<script>
$(document).ready(function(){
    var not4Curation = ' AND NOT Not4Curation';
    $("#traitOntId").autocomplete('/OntoSolr/select', {
                extraParams:{
                'qf': 'term^2 synonym^1 idl_s^1',
                'fq': 'cat:VT'+not4Curation,
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

<form action="study.html" method="get" >

<input type="hidden" name="act" value="createExperiment"/>


    <br>
    <table width="90%" cellpadding="5">

    <tr>
        <td>Acc ID:</td><td><input id="traitOntId" type="text" name="traitOntId" size="30" value="">&nbsp;<a href="javascript:lookup_treeRender('traitOntId', '', '')"><img src="/rgdweb/common/images/tree.png" border="0"/></a>&nbsp;
        &#160;&#160; Experimental name: <input type="text" name="name" size="50" id="name" value=""  style="background-color: #dddddd" readonly="true"> </td>
    </tr>
    <tr>
        <td>Notes:</td><td><textarea name="notes" rows="6" cols="25" id="notes"></textarea> </td>
    </tr>
    <tr><td>Study Id: <input type="text" name="studyId" size="50" id="studyId" value="<%=studyId%>"  style="background-color: #dddddd" readonly="true"></td></tr>

    <tr>
        <td colspan="2"><td><input type="submit" value="Save Experiment"></td></td>
    </tr>

</table>

</form>

