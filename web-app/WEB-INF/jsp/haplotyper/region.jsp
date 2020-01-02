<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.carpenovo.SampleManager" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>

<%
String pageTitle = "Variant Visualizer (Define Region)";
String headContent = "";
String pageDescription = "Define Region";

%>
<%@ include file="/common/headerarea.jsp" %>
<%@ include file="carpeHeader.jsp"%>
<%@ include file="menuBar.jsp" %>

<%

   int mapKey = Integer.parseInt(request.getParameter("mapKey"));
%>

   <br>
<div class="typerMat">
    <div class="typerTitle"><div class="typerTitleSub">Variant&nbsp;Visualizer</div></div>
     <br><br>
    <table width="100%" class="stepLabel" cellpadding=0 cellspacing=0>
        <tr>
            <td><b>Step 2:</b> Define a Region</td>
            <td align="right"><%=MapManager.getInstance().getMap(mapKey).getName()%> assembly</td>
        </tr>
    </table>

<br><br>

        <table border=0 align="center" style="padding:8px; ">
            <tr>
                <td width=200 style="font-size:14px;color:white;">A region can be defined using a genomic position or 2 gene/SSLP flanks located on the same chromosome. The region must be 30 Mb or smaller.</td>
                <td>
                    <table border="0" cellspacing=4 cellpadding=0 class="carpeASTable" style="padding: 10px;">
                        <tr>
                            <td colspan=3>
                                <div class="typerSubTitle">Position</div>
                                <form action="config.html" id="optionForm1" name="optionForm" >
                                    <input type="hidden" name="mapKey" value="<%=request.getParameter("mapKey")%>"/>
                                    <% String start = new String();
                                        String stop= new String();
                                        if(req.getParameter("start")!=null && !req.getParameter("start").equals("")){
                                            start=req.getParameter("start");
                                        }else{
                                            if(request.getAttribute("start")!=null)
                                            start= String.valueOf(request.getAttribute("start"));
                                        }
                                        if(req.getParameter("stop")!=null && !req.getParameter("stop").equals("")){
                                            stop=req.getParameter("stop");
                                        }else{
                                            if(request.getAttribute("stop")!=null)
                                            stop= String.valueOf(request.getAttribute("stop"));
                                        }

                                    %>
                                    <%
                                        for (int i=1; i<100; i++) {
                                            if (request.getParameter("sample" + i) != null) {
                                    %>
                                    <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
                                    <%}} %>
                                    <table>
                                        <tr>
                                            <td colspan=2>
                                                <table>
                                                    <tr>
                                                        <td>Chromosome <select   name="chr" id="chr" ><option value="1" selected>1</option><option value="2">2</option><option value="3">3</option><option value="4">4</option><option value="5">5</option><option value="6">6</option><option value="7">7</option><option value="8">8</option><option value="9">9</option><option value="10">10</option><option value="11">11</option><option value="12">12</option><option value="13">13</option><option value="14">14</option><option value="15">15</option><option value="16">16</option><option value="17">17</option><option value="18">18</option><option value="19">19</option><option value="20">20</option><option value="21">21</option><option value="X">X</option><option value="Y">Y</option><option value="MT">MT</option></select></td>
                                                        <td>&nbsp;&nbsp;&nbsp;Start <input type="text" placeholder="required" id="start" name="start" size="25" value="<%=FormUtility.formatThousands(dm.out("start",start))%>" required></td>
                                                        <td>&nbsp;&nbsp;&nbsp;Stop <input type="text" placeholder="required" id="stop" name="stop" size="25" value="<%=FormUtility.formatThousands(dm.out("stop",stop))%>" required></td>
                                                        <td valign="top" align="left">
                                                            <div style="margin-left:10px;"><input  class="continueButton"  type="submit"  value="Continue..." style="color:white" onclick="validateRegion()"/></div>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </td>
                                        </tr>
                                    </table>
                                </form>

                            </td>
                        </tr>
                        <tr>
                            <td>
                                <form action="config.html" id="optionForm2" name="optionForm">
                                    <input type="hidden" name="mapKey" value="<%=request.getParameter("mapKey")%>"/>
                                    <%
                                        for (int i=1; i<100; i++) {
                                            if (request.getParameter("sample" + i) != null) {
                                    %>
                                    <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
                                    <%}} %>
                                    <table>
                                        <% if (MapManager.getInstance().getMap(mapKey).getSpeciesTypeKey() == 3) { %>
                                        <tr>
                                            <td colspan=3 align="center"><div style="background-color:#002752; margin-top:20px; margin-bottom:20px; padding:2px;font-weight:700; color:white;"><< OR >></div></td>
                                        </tr>

                                        <tr>
                                            <td   colspan=3><div class="typerSubTitle" >Gene or SSLP Bounds  <span style="font-size:11px;">&nbsp;&nbsp;&nbsp;&nbsp;(must be on same chromosome)</span></div></td>
                                        </tr>
                                        <tr>
                                            <td colspan=2>Symbol 1: <input type="text" name="geneStart" size=30 value="<%=dm.out("geneStart",req.getParameter("geneStart"))%>" required/> &nbsp;&nbsp;&nbsp;&nbsp;Symbol 2: <input type="text" size="30" name="geneStop" value="<%=dm.out("geneStop",req.getParameter("geneStop"))%>" required/> </td>
                                            <td valign="top" align="left">
                                                <div style="margin-left:10px;color:white;font-weight: bold"><input  class="continueButton"  type="submit"  value="Continue..." style="color:white"/></div>
                                            </td>
                                        </tr>
                                        <% } %>

                                    </table>
                                </form>

                            </td>
                        </tr>
                    </table>

                </td>
            </tr>
            </table>

    <table width="100%" class="stepLabel" cellpadding=0 cellspacing=0>
        <tr>
            <td><b>Strains Selected</b></td>
        </tr>
    </table>
    <div style="margin-top:12px; margin-bottom:12px;">
    <table border=0 width="100%" style="border:1px dashed white; padding-bottom:5px;">
    <tr>
     <td style="font-size:11px;color:white;" >
        <%
        for (int i=1; i<100; i++) {
            if (request.getParameter("sample" + i) != null) {
                String strain = "";
                if (i > 1) {
                    strain += ",&nbsp;";
                }

                strain+= SampleManager.getInstance().getSampleName(Integer.parseInt(request.getParameter("sample" + i))).getAnalysisName();

        %>
        <%=strain%>
     <%}}%>

     </td>
    </tr>
</table>
</div>




</div>

<%@ include file="/common/footerarea.jsp" %>