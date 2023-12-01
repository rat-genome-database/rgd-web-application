<%@ page import="java.util.Map" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Ontology" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermWithStats" %>
<%@ page import="edu.mcw.rgd.ontology.OntSearchBean" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.ontology.OntSearchBean" />
<% String headContent = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/css/ontology.css\" />\n";
   String pageTitle = bean.getSearchString() + " - Ontology Search - Rat Genome Database";
   String pageDescription = pageTitle;
%>
<%@ include file="ontHeader.jsp"%>

<h2>ONTOLOGY GENERAL SEARCH RESULTS</h2>

<table>
<tr><td valign="top"><%-- 1st column contains search box, to refine the search, and the ontologies found --%>
    <form name="searchForm" action="/rgdweb/elasticResults.html">
        <input type="hidden" name="category" value="Ontology"/>
        <table><tr><td>
            <input type="input" name="term" size="40" class="searchTerm" value="<%=bean.getSearchString()%>"/>
        </td><td>
            <input type="image" class="searchButtonSmall" title="search for terms" src="/common/images/searchGlass.gif" onclick="document.searchForm.submit();"/>
        </td></tr></table>
    </form>

        <% if (bean.getHitCount().isEmpty()) {%>
    <p>You can tune up search now by modifying the list of search words above. Or you can use wildcard '*' character
       if you don't know the exact name of the term (like 'blo*d').</p>
    <table class="searchBox" border="0" cellspacing="1" cellpadding="1">
    <tr>
        <th>NO TERMS FOUND</th>
    </tr>
  </table>
    <% }
        if (!bean.getHitCount().isEmpty()) {%>
    <%------ RESULTS: ontology term hit counts + terms for given ontology -------%>
    <table class="searchBox" border="0" cellspacing="1" cellpadding="1" style="width:260px;">
    <tr>
        <th>Ontology Name</th>
        <th>Terms</th>
    </tr>
    <% for( Map.Entry<String, OntSearchBean.OntInfo> entry: bean.getHitCount().entrySet() ) {
        String ontId = entry.getKey();
        OntSearchBean.OntInfo info = entry.getValue();
        String className = "o_blue";

        if( ontId.equals(bean.getSelOntId()) ) {
            className += " o_bold";
            out.print("<tr class='o_bk_dark'>\n");
        }
        else
            out.print("<tr>\n");

        String anchorStart = "<a class=\""+className+"\" href=\"search.html?term="+ URLEncoder.encode(bean.getSearchString(), "UTF-8")+"&ont="+ontId+"\" title=\"Click to see terms\">";
        String anchorEnd = "</a>";
    %>
             <td><%=anchorStart%><%=info.ontology.getName()%><%=anchorEnd%></td>
             <td class="num <%=className%>"><%=anchorStart%><%=info.hitCount%><%=anchorEnd%></td>
             <td>
                <%if (info.hasAnnots){%>
                     <%=anchorStart%><img alt="annotations found for ontology <%=ontId%>" title="annotations found for ontology <%=ontId%>" src="/rgdweb/images/icon-a.gif"/><%=anchorEnd%>
                <%}%>
             </td>
         </tr><%
        }
    %>
  </table>
  <p style="width:240px;">Hint: click ontology name to see terms matching your search phrase.</p>
  <p style="width:240px;">Hint: if a term shown has annotations, click it to see the annotations.</p>
<% } %>

</td><td valign="top"><%-- TERMS FOUND : right pane --%>
     <% if( bean.getResults()!=null && !bean.getResults().isEmpty() ) {%>
     <a name="tl"></a>
     <table class="searchBox" border="0" cellspacing="1" cellpadding="1">
     <% for( Ontology ont: bean.getResults().keySet() ) {
          List<TermWithStats> terms = bean.getResults().get(ont);
          if( terms.size()>0 ) {
     %>
        <tr><th colspan="12" style="text-align:left;color:navy;"> <%=ont.getName()%></th></tr>
        <tr>
            <th></th>
            <th>&nbsp;</th>
            <th>&nbsp;</th>
            <th>Accession</th>
            <th>&nbsp;</th>
            <th colspan="7">Annotations</th>
         </tr>
         <tr>
            <th colspan="4" ></th>
             <th>&nbsp;</th>
             <th ><a href="#tl" class="sterm">R</a></th>
             <th ><a href="#tl" class="sterm">M</a></th>
             <th ><a href="#tl" class="sterm">H</a></th>
             <th ><a href="#tl" class="sterm">C</a></th>
             <th ><a href="#tl" class="sterm">B</a></th>
             <th ><a href="#tl" class="sterm">D</a></th>
             <th ><a href="#tl" class="sterm">S</a></th>
        </tr>
        <% for( TermWithStats term: terms ) { %>
          <tr>
              <td valign="top">
                  <a href="view.html?acc_id=<%=term.getAccId()%>" title="browse term tree"><img src="/rgdweb/common/images/tree.png" alt="" border="0"/></a>
              </td>
              <td valign="top" <%=term.isObsolete() ?  "class=\"obsolete\"" : "" %>>
                  <% if( term.getAnnotObjectCountForTermAndChildren()>0 ) { %>
                  <%-- link by default to Rat tab ontology report; if no rat annotations, link to All tab instead --%>
                  <a href="annot.html?acc_id=<%=term.getAccId()%><%=term.getAnnotObjectCountForSpecies(3)<=0 ? "&species=All" : ""%>" title="see term annotations"><%=term.getTerm()%></a>
                  <% } else { %>
                  <%=term.getTerm()%>
                  <% } %>
              </td>
              <td>&nbsp;</td>
              <td<%=term.isObsolete() ? "class=\"obsolete\"" : ""%>>
                  <%=term.getAccId()%></td>

              <td>&nbsp;</td>

              <td ><%-- RAT ANNOT COUNT --%>
                  <% if( term.getAnnotObjectCountForSpecies(3)>0 ) { %>
                  <a href="annot.html?species=Rat&with_children=1&acc_id=<%=term.getAccId()%>" title="see rat annotations to this term"><%=term.getAnnotObjectCountForSpecies(3)%></a>
                  <% } else { %>
                  0
                  <% } %>
              </td>
              <td ><%-- MOUSE ANNOT COUNT --%>
                  <% if( term.getAnnotObjectCountForSpecies(2)>0 ) { %>
                  <a href="annot.html?species=Mouse&with_children=1&acc_id=<%=term.getAccId()%>" ><%=term.getAnnotObjectCountForSpecies(2)%></a>
                  <% } else { %>
                  0
                  <% } %>
              </td>
              <td ><%-- HUMAN ANNOT COUNT --%>
                  <% if( term.getAnnotObjectCountForSpecies(1)>0 ) { %>
                  <a href="annot.html?species=Human&with_children=1&acc_id=<%=term.getAccId()%>" ><%=term.getAnnotObjectCountForSpecies(1)%></a>
                  <% } else { %>
                  0
                  <% } %>
              </td>
              <td ><%-- CHINCHILLA ANNOT COUNT --%>
                  <% if( term.getAnnotObjectCountForSpecies(4)>0 ) { %>
                  <a href="annot.html?species=Chinchilla&with_children=1&acc_id=<%=term.getAccId()%>" ><%=term.getAnnotObjectCountForSpecies(4)%></a>
                  <% } else { %>
                  0
                  <% } %>
              </td>
              <td ><%-- BONOBO ANNOT COUNT --%>
                  <% if( term.getAnnotObjectCountForSpecies(5)>0 ) { %>
                  <a href="annot.html?species=Bonobo&with_children=1&acc_id=<%=term.getAccId()%>" ><%=term.getAnnotObjectCountForSpecies(5)%></a>
                  <% } else { %>
                  0
                  <% } %>
              </td>
              <td ><%-- DOG ANNOT COUNT --%>
                  <% if( term.getAnnotObjectCountForSpecies(6)>0 ) { %>
                  <a href="annot.html?species=Dog&with_children=1&acc_id=<%=term.getAccId()%>" ><%=term.getAnnotObjectCountForSpecies(6)%></a>
                  <% } else { %>
                  0
                  <% } %>
              </td>
              <td ><%-- SQUIRREL ANNOT COUNT --%>
                  <% if( term.getAnnotObjectCountForSpecies(7)>0 ) { %>
                  <a href="annot.html?species=Squirrel&with_children=1&acc_id=<%=term.getAccId()%>" ><%=term.getAnnotObjectCountForSpecies(7)%></a>
                  <% } else { %>
                  0
                  <% } %>
              </td>

          </tr>
        <% } %>
     <% }} %>
     </table>
<% } %>
     <% if( bean.getObsoleteTermsInSearch()>0 ) { %>
         <span style="font-style: italic;font-size: small"><%=bean.getObsoleteTermsInSearch()%> obsolete term(s) not shown in the table.</span>
     <% } %>
</td></tr>
</table>

<%@ include file="/common/footerarea.jsp"%>