<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="edu.mcw.rgd.datamodel.variants.VariantMapData" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="edu.mcw.rgd.dao.impl.variants.VariantDAO" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="../dao.jsp"%>
<%
    String title = "Variant";
    List<VariantMapData> vars = (List<VariantMapData>) request.getAttribute("reportObjects");
    int speciesType = vars.get(0).getSpeciesTypeKey();
    int mapKey = vars.get(0).getMapKey();
    String objectType="Variants";
    String displayName = request.getParameter("id");
    String symbol = "";

    boolean isGene = false;
    if (request.getAttribute("symbol").toString().isEmpty())
         displayName = request.getParameter("id");
    else {
        isGene = true;

        symbol = request.getAttribute("symbol").toString();
        displayName = symbol + " Variants";
    }
    String pageTitle = displayName;
    String headContent = "";
    String pageDescription = pageTitle + " Variants";

%>

<div id="top" ></div>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<script>
    let reportTitle = "rgdvariant";
</script>

<div id="page-container">

    <div id="left-side-wrap">
        <div id="species-image">
            <img border="0" src="/rgdweb/common/images/species/<%=SpeciesType.getImageUrl(speciesType)%>"/>
        </div>

        <%@ include file="../reportSidebar.jsp"%>
    </div>

    <div id="content-wrap">
        <table width="95%" border="0">
            <tr>
                <td>

                    <%@ include file="info.jsp"%>

            </tr>
        </table>
    </div>
</div>
<%--<%@ include file="../reportFooter.jsp"%>--%>
<%@ include file="/common/footerarea.jsp"%>
<script src="/rgdweb/js/reportPages/geneReport.js?v=15"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=2"> </script>