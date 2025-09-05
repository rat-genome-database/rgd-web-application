<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Ontology" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.ontology.OntSearchBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% String pageDescription = "Ontology Search - " + RgdContext.getLongSiteName(request);
   String headContent = "";
   String pageTitle = "Ontology Search - Rat Genome Database";
%>
<style>
.rootont {
    float:left;
    padding-left:5px;
    padding-right:20px;
    width:230px;
}

.credittext {
    font-size:11px;
    color:#808080;
}
.credittext A {
    font-size:11px;
    color:#505050;
}
</style>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.ontology.OntSearchBean" />
<%@ include file="ontHeader.jsp"%>



<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading">Ontology and Annotation</div>
</div>


<div style="border: 1px solid black; margin-top:5px; padding-left:8px; padding-right:8px;padding-top:4px; padding-bottom:4px; background-color:#F0F2F1;">

<% if( !RgdContext.isChinchilla(request) ) { %>
<div style="font-style:italic; padding:3px; margin-bottom:10px;margin-top:5px;">
 RGD uses ontologies: hierarchical, controlled vocabularies to annotate genes, QTLs, strains and homologs:
 Gene Ontology, Mammalian Phenotype Ontology, Disease Ontology, Pathway Ontology and others. <br><br><b>The Ontology Browser
 allows you to retrieve all genes, QTLs, strains and homologs annotated to a particular term.</b>
</div>
<% } %>

<!--form method="GET" action="search.html" name="search2"-->
    <form method="GET" action="/rgdweb/elasticResults.html" name="search2">
        <input type="hidden" name="category" value="Ontology"/>
<div style="border: 1px solid black;background-color:white;margin-bottom: 10px; padding-left:8px; padding-rigth:8px;padding-bottom:5px;">
<h2>Search Ontology</h2>

<div id="keywordBox">
  <div >
    <div >
    <b>Examples:</b>
        <a href="javascript:document.search2.term.value='eye';document.search2.submit();">eye</a>,
        <% if( RgdContext.isChinchilla(request) ) { %>
        <a href="javascript:document.search2.term.value='Lep';document.search2.submit();">Lep</a>,
        <% } else { %>
        <a href="javascript:document.search2.term.value='SS BN Mcwi';document.search2.submit();">SS BN Mcwi</a>,
        <% } %>
        <a href="javascript:document.search2.term.value='kinase pathway';document.search2.submit();" >kinase pathway</a>
        <!--a href="javascript:document.search2.term.value='*mgh*';document.search2.submit();">*mgh*</a-->,
    </div>
    <br>
    <div>
       <table cellpadding=0 cellspacing=0>
           <tr>
               <td><select name="subCat">
                   <option value="">Any Ontology</option>
                       <%
          for( Ontology o: bean.getOntologies() ) {

              if( !o.isPublic() )
                  continue;
              // show only subset of ontologies for chinchilla
              if( RgdContext.isChinchilla(request) ) {
                  if( !(o.getId().equals("BP") || o.getId().equals("CC") || o.getId().equals("MF") ||
                   o.getId().equals("RDO") || o.getId().equals("MP") || o.getId().equals("PW")))
                      continue;
              }
              %>
                   <option value="<%=o.getName()%>"><%=o.getName()%></option>
                   <%}%>

               </select></td>
               <td><input name="term" size="60" class="searchKeyword" value="" type="text" /></td>
               <td><input type="submit" value="Search" alt="Search RGD" class="searchButton" /></td>
           </tr>
       </table>


    </div>
  </div>
</div>

</div>
    </form>
<div style="border: 1px solid black;background-color:white;margin-bottom: 10px; padding-left:8px; padding-rigth:8px;padding-bottom:5px;">
<h2>Browse Ontologies</h2>


    <p style="font-size:11px;color:gray">Click ontology name to browse term tree.</p>

  <%-- NEW TEMPORARY CODE --%>
  <div><!-- div with all checkboxes for ontologies -->
      <%  Map<String, Ontology> ontMap = new HashMap<String, Ontology>();
      List<Ontology> withAnnots = new ArrayList<>();
      List<Ontology> noAnnots = new ArrayList<>();
          for( Ontology o: bean.getOntologies() ) {
//              ontMap.put(o.getId(), o);
              if (!o.isPublic())
                  continue;
              // show only subset of ontologies for chinchilla
              if (RgdContext.isChinchilla(request)) {
                  if (!(o.getId().equals("BP") || o.getId().equals("CC") || o.getId().equals("MF") ||
                          o.getId().equals("RDO") || o.getId().equals("MP") || o.getId().equals("PW")))
                      continue;
              }
              if (bean.getAnnotCount().get(o.getRootTermAcc())!=0)
                  withAnnots.add(o);
              else
                  noAnnots.add(o);
          }
      %>
      <table>
          <tr>
              <td>
                  <h4>Ontologies with Annotations</h4>
                  <%
                      for (Ontology o : withAnnots){
                     %>
                  <div class="rootont"><%
                          String rootTermAcc = bean.getRootTerms().get(o.getId());
                          if( rootTermAcc!=null ) {
                  %>      <table border=0 width="300">
                            <tr>
                                <td width=20><a href="<%=Link.ontView(rootTermAcc)%>"><img src="/rgdweb/common/images/add.png"></a></td>
                                <td><label for="ontid_<%=o.getId()%>"><a href="<%=Link.ontView(rootTermAcc)%>" title="click to browse ontology tree"><%=o.getName().replace(" ","&nbsp;")%></a></label></td>
                            </tr>
                          </table>
                        <% } else { %>
                                <label for="ontid_<%=o.getId()%>"><%=o.getName()%></label><br>
                        <% } %>
                        </div>
                  <%}%>
              </td>
          </tr>
          <tr>
              <td>
                  <h4>Ontologies without Annotations</h4>
                  <%
                  for (Ontology o : noAnnots){
                  %>
                  <div class="rootont"><%
                      String rootTermAcc = bean.getRootTerms().get(o.getId());
                      if( rootTermAcc!=null ) {
                  %>      <table border=0 width="300">
                      <tr>
                          <td width=20><a href="<%=Link.ontView(rootTermAcc)%>"><img src="/rgdweb/common/images/add.png"></a></td>
                          <td><label for="ontid_<%=o.getId()%>"><a href="<%=Link.ontView(rootTermAcc)%>" title="click to browse ontology tree"><%=o.getName().replace(" ","&nbsp;")%></a></label></td>
                      </tr>
                  </table>
                      <% } else { %>
                      <label for="ontid_<%=o.getId()%>"><%=o.getName()%></label><br>
                      <% } %>
                  </div>
                  <%}%>
              </td>
          </tr>
      </table>
      <div style="clear:both;"></div>
  </div>

</div>
</div>

<%--<% if( !RgdContext.isChinchilla(request) ) { %>--%>
<%--  <hr>--%>
<%--  <h4>Sources for external ontologies:</h4>--%>
<%--    <table><%--%>
<%--        for( Ontology oo: bean.getOntologies() ) {--%>
<%--            if( !oo.isPublic() || oo.isInternal() || oo.getDescription()==null || oo.getHomePage()==null || oo.getLogoUrl()==null )--%>
<%--                continue;--%>
<%--                if( !(oo.getId().equals("BP") || oo.getId().equals("CC") || oo.getId().equals("MF") ||--%>
<%--                 oo.getId().equals("RDO") || oo.getId().equals("MP") || oo.getId().equals("PW")))--%>
<%--                    continue;--%>
<%--        %>--%>
<%--        <tr>--%>
<%--            <%--%>
<%--                switch (oo.getId()){--%>
<%--                    case "MF":  %>--%>
<%--                        <th><a href="<%=oo.getHomePage()%>"><img width="56" height="30" src="/rgdweb/common/images/go-logo.png" alt="<%=oo.getName()%>"/></a></th>--%>
<%--                        <td class="credittext"><%=oo.getDescription()%></td>--%>
<%--            <%      break;--%>
<%--                    case "MP": %>--%>
<%--                        <th><a href="<%=oo.getHomePage()%>"><img width="56" height="30" src="/rgdweb/common/images/mgi_logo.gif" alt="<%=oo.getName()%>"/></a></th>--%>
<%--                        <td class="credittext"><%=oo.getDescription()%></td>--%>
<%--            <%      break;--%>
<%--                    default:    %>--%>
<%--                        <th><a href="<%=oo.getHomePage()%>"><img width="56" height="30" src="<%=oo.getLogoUrl()%>" alt="<%=oo.getName()%>"/></a></th>--%>
<%--                        <td class="credittext"><%=oo.getDescription()%></td>--%>
<%--            <%--%>
<%--                } // end switch--%>
<%--            %>--%>
<%--&lt;%&ndash;            <th><a href="<%=oo.getHomePage()%>"><img width="56" height="30" src="<%=oo.getLogoUrl()%>" alt="<%=oo.getName()%>"/></a></th>&ndash;%&gt;--%>
<%--&lt;%&ndash;            <td class="credittext"><%=oo.getDescription()%></td>&ndash;%&gt;--%>
<%--        </tr>--%>
<%--    <% } %>--%>
<%--    </table>--%>
<%--    <h4>RGD Ontologies:</h4>--%>
<%--    <table>--%>
<%--        <tr>--%>
<%--          <th style="border: solid 1px #808080" valign="top"><a href="/rgdweb/ontology/search.html"><img width="56" src="/common/images/rgd_logo_phenotypes.gif"/></a>--%>
<%--              <div style="padding-top:16px;font-size:16px;color:navy">CMO<br>MMO<br>XCO<br>PW<br>RS<br>VT</div></th>--%>
<%--          <td>--%>
<%--           <p class="credittext"><%=ontMap.get("CMO").getDescription()%></p>--%>
<%--           <p class="credittext"><%=ontMap.get("PW").getDescription()%></p>--%>
<%--           <p class="credittext"><%=ontMap.get("RS").getDescription()%></p>--%>
<%--           <p class="credittext"><%=ontMap.get("VT").getDescription()%></p>--%>
<%--          </td>--%>
<%--        </tr>--%>
<%--    </table>--%>
<%--    <% } %>--%>
  <p>
  </p>

<%@ include file="/common/footerarea.jsp"%>