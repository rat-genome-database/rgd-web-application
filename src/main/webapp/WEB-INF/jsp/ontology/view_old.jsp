<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="edu.mcw.rgd.ontology.OntAnnotation" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermSynonym" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermWithStats" %>
<%@ page import="java.util.List" %>
<% String pageDescription = "Ontology Browser - Rat Genome Database";
   String headContent = "";
   String pageTitle = "Ontology Browser - Rat Genome Database";
%>
<%
    FormUtility fu = new FormUtility();
%>
<%@ include file="ontHeader.jsp"%>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.ontology.OntAnnotBean" />
<jsp:include page="sidebar.jsp" />

<div style="margin-left:158px;">
<h2>ONTOLOGY BROWSER</h2>
  <hr/>

    <table border="0" style="padding-top:20px;" width="100%"><tr><td>
    <div id="searchResultHeader">
        <ul>
            <li<c:if test="${bean.speciesTypeKey==3}"> id="selected"</c:if> ><a href="javascript:addParam('species','Rat')">Rat</a></li>
            <li<c:if test="${bean.speciesTypeKey==2}"> id="selected"</c:if> ><a href="javascript:addParam('species','Mouse')">Mouse</a></li>
            <li<c:if test="${bean.speciesTypeKey==1}"> id="selected"</c:if> ><a href="javascript:addParam('species','Human')">Human</a></li>
            <li<c:if test="${bean.speciesTypeKey==0}"> id="selected"</c:if> ><a href="javascript:addParam('species','All')">All</a></li>
            <li><input type="checkbox" <c:if test="${bean.withChildren}">checked="checked"</c:if> onchange="addParam('with_children','<%=bean.isWithChildren()?0:1%>')">
            show annotations for term's descendants</li>
            <li> &nbsp; &nbsp; Sort by:<%=fu.buildSelectList("sort_by\" onChange=\"addParam('sort_by',this.options[selectedIndex].text)", bean.getSortByChoices(), bean.getSortBy())%></li>
            <li><select name="sort_desc" onChange="addParam('sort_desc',this.options[selectedIndex].value)" title="ascending/descending sort order">
                <option value="0" <c:if test="${bean.sortDesc==false}">selected="selected"</c:if>>&uarr; asc</option>
                <option value="1" <c:if test="${bean.sortDesc==true}">selected="selected"</c:if>>&darr; desc</option>
            </select></li>
        </ul>
    </div>
    </td></tr></table>

    <div id="searchResultWrapperTable" style="margin-right:25px;">
        <div id="searchResult">
        <table border='0' cellpadding='2' cellspacing='2' width="100%">
          <%  for( Term term: bean.getAnnots().keySet() ) { %>
             <tr class='srH1' align="left"><th colspan="11">
                    <a href="annot.html?acc_id=<%=term.getAccId()%>"><%=term.getTerm()%></a>
                    <a href="view.html?acc_id=<%=term.getAccId()%>"><img src="/rgdweb/common/images/tree.png" title="click to browse the term" alt="term browser" border="0"></a>
             </th></tr>
             <tr class='headerRow'>
                 <td></td>
                 <c:if test="${!bean.pheno}">
                 <td><b>Symbol</b></td>
                 <td><b>Object Name</b></td>
                 <td><c:if test="${bean.hasQualifiers}"><b>Qualifiers</b></c:if></td>
                 <td><b>Evidence</b></td>
                 <td><b>Chr</b></td>
                 <td><b>Start</b></td>
                 <td><b>Stop</b></td>
                 <td><b>Reference</b></td>
                 </c:if>
                 <c:if test="${bean.pheno}">
                 <td><b>Strain</b></td>
                 <td><b>Study</b></td>
                 <td><b>Experiment</b></td>
                 <td><b>Record</b></td>
                 <td><b>Chr</b></td>
                 <td><b>Start</b></td>
                 <td><b>Stop</b></td>
                 <td><b>Reference</b></td>
                  </c:if>
             </tr>
              <% int row=0; for( OntAnnotation annot: bean.getAnnots().get(term) ) {
                  if( row++ % 2 == 1 )
                    out.print("<tr class='oddRow'>");
                  else
                    out.print("<tr class='evenRow'>"); %>

                <td class="objtag_<%=annot.getRgdObjectName()%>" title=" <%=annot.getRgdObjectName()%> "><%=annot.getRgdObjectName().substring(0,1).toUpperCase()%></td>
                <% if( annot.isGene() ) {%><td><a href="/tools/genes/genes_view.cgi?id=<%=annot.getRgdId()%>"><%=annot.getSymbol()%></a></td>
                <% } else if( annot.isQtl() ) { %><td><a href="/objectSearch/qtlReport.jsp?rgd_id=<%=annot.getRgdId()%>"><%=annot.getSymbol()%></a></td>
                <% } else if( annot.isStrain() ) { %><td><a href="/tools/strains/strains_view.cgi?id=<%=annot.getRgdId()%>"><%=annot.getSymbol()%></a></td>
                <% } else { %><td><%=annot.getSymbol()%></td><% } %>
                <td><%=annot.getName()%></td>
                <td><%=annot.getQualifier()%></td>
                <td><%=annot.getEvidenceWithInfo()%></td>
                <td class="mid"><%=annot.getChr()%></td>
                <td class="num"><%=annot.getStartPos()%></td>
                <td class="num"><%=annot.getStopPos()%></td>
                <td><%=annot.getReference()%></td>
                <% if( annot.isGene() ) {%><td><a href="/tools/genes/gene_ont_view.cgi?id=<%=annot.getRgdId()%>"><img src="/objectSearch/images/icon-a.gif" title="see other annotations for this gene" alt="see other annotations"></a></td>
                <% } else if( annot.isQtl() ) { %><td><a href="/objectSearch/qtlReport.jsp?rgd_id=<%=annot.getRgdId()%>#Anno"><img src="/objectSearch/images/icon-a.gif" title="see other annotations for this qtl" alt="see other annotations"></a></td>
                <% } else if( annot.isStrain() ) { %><td><a href="/tools/strains/strains_view.cgi?id=<%=annot.getRgdId()%>#Anno"><img src="/objectSearch/images/icon-a.gif" title="see other annotations for this strain" alt="see other annotations"></a></td><%}%>
              </tr>
            <% }} %>

            </tr>
        </table>
        </div>
    </div>

        <%-- ANNOTATIONS TABLE
<%@ include file="annotTable.jsp" %>
                               --%>
</div>

<%@ include file="/common/footerarea.jsp" %>
