<%@ page import="edu.mcw.rgd.carpenovo.SampleManager" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.dao.impl.SampleDAO" %>
<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>

<%
String pageTitle = "Variant Visualizer (Define Gene Symbol List)";
String headContent = "";
String pageDescription = "Define Gene Symbol List";
%>

<%@ include file="carpeHeader.jsp"%>
<%@ include file="menuBar.jsp" %>


<br>
<div class="typerMat">
    <div class="typerTitle"><div class="typerTitleSub">Variant&nbsp;Visualizer</div></div>

    <br>
    <table width="100%" class="stepLabel" cellpadding=0 cellspacing=0>
        <tr>
            <td>Enter one or more gene symbols into the the text box</td>
            <td align="right"><%=MapManager.getInstance().getMap(Integer.parseInt(request.getParameter("mapKey"))).getName()%> assembly</td>
        </tr>
    </table>

    <br><br>

<script>
    function checkGeneList() {

       if (document.getElementById("geneList").value.length > 2000) {
          alert("Gene List input must be under 2000 characters.  Your current list is " + document.getElementById("geneList").value.length + ". Please reduce the size of your list.");
       }else {
          document.optionForm.submit();
       }
    }


</script>

<form action="config.html" name="optionForm">

    <!--<input type="button" class="btn btn-info btn-sm" data-toggle="modal" data-target="#myModal" value="Import" ng-click="rgd.loadMyRgd($event)" style="background-color:#4584ED;"/>-->

    <table border=0 align="center" style="padding:8px; ">
    <tr>
        <td width=120 style="font-size:12px;color:white;">If multiple gene symbols are entered, please seperate by commas (,) or place each symbol on it's own line.</td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td >

            <table border="0" cellspacing=4 cellpadding=0 class="carpeASTable">
                <tr>
                <td   colspan=3><div class="typerSubTitle" >Gene Symbol List</div></td>
                </tr>
                <tr>
                    <td colspan=2><textarea rows=15 cols=80 name="geneList" id="geneList"><%=dm.out("geneList",req.getParameter("geneList"))%></textarea></td>
                    <!--{importTarget} -->
                </tr>
            </table>
            </td>
        <td valign="top" align="left">
            <div style="margin-left:10px;"><input  class="continueButton"  type="button" onClick="checkGeneList();" value="Continue..."/></div>
        </td>
    </tr>
</table>

    <br><br>
   <table width="100%" class="stepLabel" cellpadding=0 cellspacing=0>
   <tr>
   <td><b>Samples Selected</b></td>
   </tr>
   </table>

        <div style="margin-top:12px; margin-bottom:12px;">
<table border=0 width="100%" style="border:1px dashed white; padding-bottom:5px;">
    <tr>
     <td style="font-size:11px;color:white;" >
    <%

        if (request.getParameter("sample1") != null && request.getParameter("sample1").equals("all")) {

            SampleDAO sdao = new SampleDAO();
            sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
            int mapKey = Integer.parseInt(request.getParameter("mapKey"));
            List<Sample> samples = sdao.getSamplesByMapKey(mapKey);

            int count=1;
            for (Sample s : samples) {
                String strain = "";
                if (count > 1) {
                    strain += ",&nbsp;";
                }

                strain+= SampleManager.getInstance().getSampleName(s.getId()).getAnalysisName();
    %>
         <%=strain%>
         <input type="hidden" name="sample<%=count++%>" value="<%=s.getId()%>"/>
         <%

             }

         } else {


        for (int i=1; i<100; i++) {
        if (request.getParameter("sample" + i) != null) {
            String strain = "";
            if (i > 1) {
                strain += ",&nbsp;";
            }

            strain+= SampleManager.getInstance().getSampleName(Integer.parseInt(request.getParameter("sample" + i))).getAnalysisName();

    %>
        <%=strain%>
        <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
    <%
        }
            }
    }
    %>
         <input type="hidden" name="mapKey" value="<%=request.getParameter("mapKey")%>"/>
        </td>
    </tr>
</table>
</div>


</div>

</form>

<%@ include file="/common/angularBottomBodyInclude.jsp" %>


