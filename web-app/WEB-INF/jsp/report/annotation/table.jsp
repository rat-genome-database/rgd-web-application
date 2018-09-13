<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.report.DaoUtils" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.report.GeneTermAnnotationsBean" />

<%
    String pageTitle = "RGD Gene Chemical Interaction Report - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "View " + RgdContext.getLongSiteName(request) + " interactions to " + (bean.getTerm()!=null ? bean.getTerm().getTerm() : bean.getAccId());
%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>

<div id="searchResultHeader" style="padding-top:20px; border-bottom: 3px solid gray;">
    <ul>
        <li><a href="javascript:location.replace('/rgdweb/report/annotation/main.html?id=<%=bean.getRgdId().getRgdId()%>&term=<%=bean.getAccId()%>');">View As List</a></li>
        <li id=selected><a href="">View As Table</a></li>
    </ul>
</div>
<div style="clear:both; padding-top:1px;">
<%
    String objectType = bean.getRgdId().getObjectTypeName().toUpperCase();
    if( bean.getAccId().startsWith("CHEBI") ) {
        out.write("<h3>"+objectType+" - CHEMICAL INTERACTIONS REPORT</h3>\n");
    } else {
        out.write("<h3>"+objectType+" - TERM ANNOTATION REPORT</h3>\n");
    }
%>
<table><tr><td valign="top">

    <%-- gene information --%>
    <table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
        <tr>
            <td class="label" valign="top"><%=RgdContext.getSiteName(request)%> ID:</td>
            <td><a href="<%=Link.it(bean.getRgdId().getRgdId())%>"><%=bean.getRgdId().getRgdId()%></a></td>
        </tr>
        <tr>
            <td class="label" valign="top">Species:</td>
            <td><%=SpeciesType.getTaxonomicName(bean.getRgdId().getSpeciesTypeKey())%></td>
        </tr>
        <tr>
            <td class="label" valign="top"><%=RgdContext.getSiteName(request)%> Object:</td>
            <td><%=bean.getRgdId().getObjectTypeName()%></td>
        </tr>
        <% if( bean.getRgdObject() instanceof ObjectWithSymbol ) { %>
        <tr>
            <td class="label" valign="top">Symbol:</td>
            <td><a href="<%=Link.it(bean.getRgdId().getRgdId())%>"><%=((ObjectWithSymbol)bean.getRgdObject()).getSymbol()%></a></td>
        </tr>
        <% } %>
        <% if( bean.getRgdObject() instanceof ObjectWithName ) { %>
        <tr>
            <td class="label" valign="top">Name:</td>
            <td><%=((ObjectWithName)bean.getRgdObject()).getName()%></td>
        </tr>
        <% } %>
    </table>

</td><td valign="top" width="67%">

    <%-- term information --%>
    <table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
        <tr>
            <td class="label" valign="top">Acc ID:</td>
            <td><a href="<%=Link.ontView(bean.getAccId())%>"><%=bean.getAccId()%></a></td>
        </tr>
        <tr>
            <td class="label" valign="top">Term:</td>
            <td><%=bean.getTerm()!=null ? bean.getTerm().getTerm() : ""%></td>
        </tr>
        <tr>
            <td class="label" valign="top">Definition:</td>
            <td><%=bean.getTerm()!=null ? bean.getTerm().getDefinition() : ""%></td>
        </tr>
        <%  String xrefs = DaoUtils.getInstance().getTermXRefs(bean.getTerm());
            if( xrefs!=null && !xrefs.isEmpty() ) { %>
        <tr>
            <td class="label" valign="top">Definition Source(s):</td>
            <td><%=xrefs%></td>
        </tr>
        <% }
           if( bean.getCasRN()!=null ) { %>
        <tr>
            <td class="label" valign="top">CasRN:</td>
            <td><%=bean.getCasRN()%></td>
        </tr>
        <% }
           if( bean.getMeshID()!=null ) { %>
        <tr>
            <td class="label" valign="top">Chemical ID:</td>
            <td><%=bean.getMeshID()%></td>
        </tr>
        <% } %>
    </table>

</td></tr></table>
</div>

<div style="font-size:80%; padding:15px; color:rgb(64,64,64)">
Note: Use of the qualifier "multiple interactions" designates that the annotated interaction
is comprised of a complex set of reactions and/or regulatory events, possibly involving
additional chemicals and/or gene products.
</div>

<div>
    <%=bean.getAnnotTable(RgdContext.getSiteName(request))%>
</div>

<table align="center">
    <tr>
        <td><a style="font-size:20px; font-weight: 700" href="javascript:history.back();">Go Back to source page</a></td>
        <td>&nbsp;</td>
        <td><a href="<%=Link.ontAnnot(bean.getAccId())%>&species=<%=SpeciesType.getCommonName(bean.getRgdId().getSpeciesTypeKey())%>"
               style="font-size:20px; font-weight: 700" >Continue to Ontology report</a></td>
    </tr>
</table>

<%@ include file="/common/footerarea.jsp"%>
