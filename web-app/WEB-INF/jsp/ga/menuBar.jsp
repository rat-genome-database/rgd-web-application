<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.datamodel.MapData" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.reporting.Record" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>


<%@ include file="navFunctions.jsp" %>

<%
    int species=3;
    int mapKey=360;
    String a= new String();
    if (request.getParameter("species") != null && !request.getParameter("species").equals("")) {
        species = Integer.parseInt(request.getParameter("species"));
        mapKey=MapManager.getInstance().getReferenceAssembly(species).getKey();
    }
    if(request.getParameter("a")!=null){
        a=request.getParameter("a");
    }
%>

<div style="width:100%; border: 1px solid #346f97; background-color:#f0f6f9; padding:2px; " >

    <table width=100% cellpadding=0 cellspacing=0  align="center" id="headerBar" style="border: 1px solid #346f97;">
    <tr>
        <td align="left" width="10%">
            <table cellpadding=0 cellspacing=0  >
            <tr>
                <td>&nbsp;</td>
                <td style="font-style: italic;font-weight:700;">Options:&nbsp;&nbsp;</td>
                <td><img src="/rgdweb/common/images/bullet_green.png"/></td>
                <td><td><a href="javascript:void(0)" onclick="selectGenes()">Home</a></td></td>
            </tr>
            </table>

        </td>
        <td width="33%">
            <table cellpadding=0 cellspacing=0  align="center">
                <tr>
                    <td align="center">
                        <td style="font-style: italic;font-weight:700;">Analysis:&nbsp;&nbsp;</td>
                        <td><img src="/rgdweb/common/images/bullet_green.png"/></td>
                        <td><a href="javascript:void(0);" onclick="geneList()" >Annotations</a></td>
                        <td><img src="/rgdweb/common/images/bullet_green.png"/></td>
                        <td><a href="javascript:void(0);" onclick="cross()">Annotation&nbsp;Distribution</a></td>
                        <td><img src="/rgdweb/common/images/bullet_green.png"/></td>
                        <td><a href="javascript:void(0);" onclick="termCompare('DOID:4','PW:0000001')">Comparison&nbsp;Heat&nbsp;Map</a></td>
                    <% if( !RgdContext.isChinchilla(request)) { %>
                        <td><img src="/rgdweb/common/images/bullet_green.png"/></td>
                        <!--<td><a href="javascript:void(0);" onclick="viewGviewer()">Genome&nbsp;Plot</a></td>-->
                    <% } %>
                    <td valign="center"><img src="/rgdweb/common/images/tools-white-30.png" style="cursor:hand; border: 2px solid black;" border="0" ng-click="rgd.showTools('geneList','<%=species%>','<%=mapKey%>',1, '<%=a%>')"/></td>
                    <td><a href="javascript:void(0)" ng-click="rgd.showTools('geneList','<%=species%>','<%=mapKey%>',1, '<%=a%>')">All Analysis Tools</a></td>

                    </td>
                </tr>
            </table>

        </td>
        <td align="right" width="10%">
            <table cellpadding=0 cellspacing=0>
            <tr>
                <td style="font-style: italic;font-weight:700;">Download:&nbsp;&nbsp;</td>

                <% if (request.getServletPath().endsWith("ui.jsp")) {%>
                    <td><img src="/rgdweb/common/images/bullet_green.png"/></td>
                    <td><a href="javascript:void(0);" onclick="downloadThis()">This&nbsp;Gene</a></td>
                <% } %>
                <td><img src="/rgdweb/common/images/bullet_green.png"/></td>
                <td><a href="javascript:void(0);" onclick="downloadAll()" style="font-size:12px; font-weigth:700;">All&nbsp;Genes</a></td>
                <td>&nbsp;</td>
            </tr>
            </table>
        </td>
    </tr>
</table>


</div>
