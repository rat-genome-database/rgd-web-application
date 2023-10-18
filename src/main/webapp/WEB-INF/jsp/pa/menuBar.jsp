<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.datamodel.MapData" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>


<%@ include file="navFunctions.jsp" %>

<!--
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
                        <td><a href="javascript:void(0);" onclick="termCompare('RDO:0000001','PW:0000001')">Comparison&nbsp;Heat&nbsp;Map</a></td>
                    <% if( !RgdContext.isChinchilla(request)) { %>
                        <td><img src="/rgdweb/common/images/bullet_green.png"/></td>
                        <td><a href="javascript:void(0);" onclick="viewGviewer()">Genome&nbsp;Plot</a></td>
                    <% } %>
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
-->

</div>
