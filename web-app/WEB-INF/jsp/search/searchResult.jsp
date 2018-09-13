<%@ page import="edu.mcw.rgd.datamodel.search.GeneralSearchResult" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Ontology" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermWithStats" %>
<%@ page import="edu.mcw.rgd.datamodel.Pathway" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdId" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 29, 2008
  Time: 9:36:57 AM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://rgd.mcw.edu/taglibs/search" prefix="search" %>
<%
try {
      GeneralSearchResult result = (GeneralSearchResult) request.getAttribute("GeneralSearchResult");
      String term = request.getParameter("term");
      term = term.replaceAll("\"", "&quot;");

      List<Pathway> pathways = (List<Pathway>) request.getAttribute("pathways");

    String pageTitle = term + " General Search Result - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = result.getTotal() + " genes, strains, sslps, qtls, promoters, cell lines, variants and ontology terms found for search term " + term;

%>

<%@ include file="/common/headerarea.jsp"%>

<% if (RgdContext.isChinchilla(request)) {%>
<link href="/rgdweb/common/searchNGC.css" rel="stylesheet" type="text/css" />
<% } else { %>
<link href="/rgdweb/common/search.css" rel="stylesheet" type="text/css" />
<% } %>

<link href="/rgdweb/css/ontology.css" rel="stylesheet" type="text/css" />

<style type="text/css">

body {
    font-size: 14px;
    font-family: arial;
}

td {
    font-size: 14px;
}

.grayBg{
}

.smallText{
    background-color:#cccccc;
    font-size:11px;
    color: #0c1d2e;
    width: 100%;
}

</style>

  <table  style="background-color:white;"><tr><td><h1><%=RgdContext.getSiteName(request)%> Search Result</h1></td></tr></table>

  <span style="font-size: 16px;"><b><%=result.getTotal()%></b> records found for search term <b><%=term%></b></span>
  <br>
  <br>
  
  <table width=90% border=0 id="searchSummary">

      <tr><td valign="top">
          <search:summary term="<%=term%>" title="Genes" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_GENES)%>" view="genes.html"/>
          <search:summary term="<%=term%>" title="QTLs" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_QTLS)%>" view="qtls.html"/>
          <search:summary term="<%=term%>" title="Strains" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_STRAINS)%>" view="strains.html"/>
          <search:summary term="<%=term%>" title="SSLPs" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_SSLPS)%>" view="markers.html"/>
          <search:summary term="<%=term%>" title="References" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_REFERENCES)%>" view="references.html" showDetails="false"/>
          <search:summary term="<%=term%>" title="Promoters" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_PROMOTERS)%>" view="ge.html" showDetails="false"/>
          <search:summary term="<%=term%>" title="Cell Lines" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_CELL_LINES)%>" view="ge.html" showDetails="false"/>
          <search:summary term="<%=term%>" title="Variants" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_VARIANTS)%>" view="variants.html" showDetails="false"/>
        </td>
<td>&nbsp;</td>
<td valign="top" width="200" align="center">

<div style="border: 2px ridge #cccccc;">
<div class="smallText">Result Matrix</div>
<table border=0 cellpadding=5 cellspacing=0>

    <tr>
        <td class="grayBg">&nbsp;</td>
        <% if (RgdContext.isChinchilla(request)) {%>
        <td width=50 class="grayBg">Chin</td>
        <td width=50 class="grayBg">Hum</td>


        <% }else { %>

        <td width=50 class="grayBg">Rat</td>
        <td width=50 class="grayBg">Mouse</td>
        <td width=50 class="grayBg">Hum</td>
        <td width=50 class="grayBg">Chin</td>
        <td width=50 class="grayBg">Bono</td>
        <td width=50 class="grayBg">Dog</td>
        <td width=50 class="grayBg">Squ</td>


        <% }%>
    </tr>

    <search:matrix term="<%=term%>" title="Genes" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_GENES)%>" view="genes.html"/>
    <search:matrix term="<%=term%>" title="QTLs" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_QTLS)%>" view="qtls.html"/>
    <search:matrix term="<%=term%>" title="Strains" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_STRAINS)%>" view="strains.html"/>
    <search:matrix term="<%=term%>" title="SSLPs" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_SSLPS)%>" view="markers.html"/>
    <search:matrix term="<%=term%>" title="Promoters" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_PROMOTERS)%>" view="ge.html"/>
    <search:matrix term="<%=term%>" title="Cell Lines" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_CELL_LINES)%>" view="ge.html"/>
    <search:matrix term="<%=term%>" title="Variants" counts="<%=result.getHitCounts(RgdId.OBJECT_KEY_VARIANTS)%>" view="variants.html"/>

</table>
 </div>

    </td></tr></table>
    <h2>Ontologies</h2>
    <span style="font-size:12px; ">Curators at <%=RgdContext.getSiteName(request)%> make annotations to genes, QTLs and strains using standardized vocabularies/ontologies.  Your search returned annotations to the terms below.</span><br><br>
  <%
    Map<Ontology, List<TermWithStats>> ontMap = (Map<Ontology, List<TermWithStats>>) request.getAttribute("ontMap");
    for( Map.Entry<Ontology, List<TermWithStats>> entry: ontMap.entrySet() ) {
        Ontology ont = entry.getKey();
        if( RgdContext.isChinchilla(request) ) {
            String oid = ont.getId();
            if( !(oid.equals("CC")||oid.equals("BP")||oid.equals("MF")||oid.equals("RDO")||oid.equals("PW")||oid.equals("MP")) )
                continue;
        }
        out.println("<div style=\"background-color: #cccccc; color: #0c1d2e;font-weight:700;width:50%;\">" + ont.getName() + "</div>");
        for( TermWithStats t: entry.getValue() ) {
        %>
        <a href="<%=Link.ontView(t.getAccId())%>" title="click to browse the term" alt="browse term">
            <img border="0" src="/rgdweb/common/images/tree.png" title="click to browse the term" alt="term browser"
        ></a>
        <% if( t.getAnnotObjectCountForTermAndChildren()>0 ) { %>
            <a href="<%=Link.ontAnnot(t.getAccId())%>&species=All" title="see <%=t.getAnnotObjectCountForTermAndChildren()%> annotated objects for this term with children">
            <%=t.getTerm()%>
            </a>
        <% } else { %>
            <span style="font-size:13px"><%=t.getTerm()%></span>
        <% } %>
        <br>
    <%} %>
   <br>
  <%} %>

<% if( pathways!=null ) { %>
<h2>Pathways</h2>
<span style="font-size:12px; ">Pathways with diagrams.</span><br><br>
<%
    for( Pathway pathway: pathways ) {
        out.println("<a href='/rgdweb/pathway/pathwayRecord.html?acc_id=" + pathway.getId() + "' title=\"view pathway diagram\">" + pathway.getName() + "</a> ");
        out.println("<br>");
    }
    out.println("<br>");
  }

}catch (Exception e) {
        e.printStackTrace();
    }

%>
<%@ include file="/common/footerarea.jsp"%>
