<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermSynonym" %>
<%@ page import="edu.mcw.rgd.ontology.OntDotController" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="java.util.regex.*" %>
<%@ page import="edu.mcw.rgd.report.DaoUtils" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.datamodel.XDBIndex" %>
<%@ page import="edu.mcw.rgd.datamodel.XdbId" %>
<%@ page import="edu.mcw.rgd.ontology.OntBrowser" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.ontology.OntViewBean" />
<% String headContent = "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/css/ontology.css\" >\n";
   String pageTitle = bean.getTerm().getTerm() + " - Ontology Browser - Rat Genome Database";
   String pageDescription = pageTitle;
   response.setHeader("Access-Control-Allow-Origin", "*.mcw.edu");

%>
<style>
    /*three auto scrolls*/
    /*.myDiv{*/
    /*    white-space:nowrap;*/
    /*    overflow:auto;*/
    /*   max-width: 90vw;*/
    /*}*/

    /*one auto scroll(preline or normal)*/
    .myDiv{
        white-space:normal;
        overflow:auto;
        max-width:90vw;
    }

    /*one big td data*/
    /*.myDiv{*/
    /*    white-space:break-spaces;*/
    /*    overflow:auto;*/
    /*    max-width: 90vw;*/
    /*    text-align: justify-all;*/
    /*}*/

    /*.myDiv{*/
    /*    max-width: 90vw;*/
    /*}*/

</style>
<%@ include file="ontHeader.jsp"%>

<% if( bean.getTerm()!=null ) { %><%-- VALID TERM ACC ID --%>
<br>
<table width='98%'>
    <tr>
        <td valign="top"><h2>Ontology Browser</h2></td>
        <td align="right">
            <form name="searchForm" action="/rgdweb/elasticResults.html">
            <table><tbody><tr>
                <% if (RgdContext.isCurator()) {%>
                <td style="margin-right:30px; border: 1px solid blue; background-color: yellow;"><a href="/rgdweb/curation/edit/editTerm.html?termAcc=<%=bean.getAccId()%>" style="font-weight:bold;font-size:11px;color:blue">EDIT</a></td>
                <% } %>
                <td>Term: </td>
                <td>
                <input name="term" size="30" class="searchTerm" value="" type="input">
                    <input type="hidden" name="category" value="Ontology"/>
            </td><td>
            <input class="searchButtonSmall" title="search for terms" src="/common/images/searchGlass.gif" onclick="document.searchForm.submit();" type="image">
         </td></tr></tbody></table>
    </form>
            <!--<a href="/rgdweb/ontology/search.html"><<< Return to Ontology Search</a></td>-->
    </tr>
</table>

<%
    String url="/rgdweb/ontology/view.html";
    if( Utils.NVL(request.getParameter("dia"),"0").equals("1") ) {
        url += "?dia=1";
    }

    OntBrowser ontBrowser = new OntBrowser();
    ontBrowser.setAcc_id( bean.getAccId(), request );
    ontBrowser.setUrl(url);
    ontBrowser.setOffset(request.getParameter("offset"));

    ontBrowser.doTag(request, out);
%>

<%-- TERM INFO TABLE, WITH SYNONYMS --%>
<!-- background-image: url(/rgdweb/common/images/bg3.png);-->


<table>
    <tr>
        <td colospan="2"><img border="0" src="/rgdweb/common/images/ontology_browser_key.png"/></td>
    </tr>
</table>

<div id="browser" style="padding-top:0px;">

<% // show term synonyms and definition db-xrefs
    String xrefs = Utils.defaultString(DaoUtils.getInstance().getTermXRefs(bean.getTerm()));
    if( (bean.getTermSynonyms()!=null && !bean.getTermSynonyms().isEmpty()) || !xrefs.isEmpty() ) {
%>
    <br>
    <table width="99.5%"style="border: 1px solid black;  background-color:#F6F6F6; margin: 5px; padding:5px;">
      <tr>
        <td style="font-size:16px; font-weight:700;" colspan=2 >Synonyms</TD>

        <% String prevType = "";
        int synonymsPerType = 0;
        for( TermSynonym syn: bean.getTermSynonyms() ) {

          if( !prevType.equals(syn.getType()) ) {
              // finish prev row
              if( !prevType.isEmpty() ) {
              %>
                </td></tr>
              <%
              }
              %>
              <tr>
                  <td class="syn_type"><%=syn.getFriendlyType()%>:</td><td class="myDiv" style='padding:3px;'>

              <%
              synonymsPerType = 0;
              prevType = syn.getType();
          }
          synonymsPerType++;
          if( synonymsPerType>1 ) {
          %>
            ; &nbsp;
          <%
          }
          // turn synonym name into a link from MESH and MIM ids
          if( syn.getName().startsWith("MESH:") ) { %>
              <a href="<%=XDBIndex.getInstance().getXDB(47).getUrl()%><%=syn.getName().substring(5)%>"><%=syn.getName()%></a>
          <% } else if( syn.getName().startsWith("MIM:PS") ) { %>
              <a href="<%=XDBIndex.getInstance().getXDB(66).getUrl()%><%=syn.getName().substring(4)%>"><%=syn.getName()%></a>
          <% } else if( syn.getName().startsWith("MIM:") ) { %>
              <a href="<%=XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_OMIM).getUrl()%><%=syn.getName().substring(4)%>"><%=syn.getName()%></a>
          <% } else if( syn.getName().startsWith("RGD ID:") ) { %>
              <a href="<%=Link.strain(Integer.parseInt(syn.getName().substring(8)))%>"><%=syn.getName()%></a>
          <% } else if( syn.getName().startsWith("DOID:") && !bean.getAccId().startsWith("DOID:") ) { %>
              <a href="<%=Link.ontView(syn.getName())%>"><%=syn.getName()%></a>
          <% } else if( syn.getName().startsWith("GARD:") ) { %>
              <a href="<%=XDBIndex.getInstance().getXDB(67).getUrl().replace("#ID#",syn.getName().substring(5))%>"><%=syn.getName()%></a>
          <% } else if( syn.getName().startsWith("ORDO:") ) { %>
              <a href="<%=XDBIndex.getInstance().getXDB(62).getUrl()%><%=syn.getName().substring(5)%>"><%=syn.getName()%></a>
          <% } else if( syn.getName().startsWith("NCI:") ) { %>
              <a href="<%=XDBIndex.getInstance().getXDB(74).getUrl()%><%=syn.getName().substring(4)%>"><%=syn.getName()%></a>
          <% } else if( syn.getName().startsWith("ICD10CM:") ) { %>
              <a href="<%=XDBIndex.getInstance().getXDB(129).getUrl()%><%=syn.getName().substring(8)%>"><%=syn.getName()%></a>
          <% } else if( syn.getName().startsWith("ICD9CM:") ) { %>
              <a href="<%=XDBIndex.getInstance().getXDB(130).getUrl()%><%=syn.getName().substring(7)%>"><%=syn.getName()%></a>
          <% } else if( syn.getName().startsWith("MONDO:") ) { %>
              <a href="<%=XDBIndex.getInstance().getXDB(145).getUrl()%>MONDO_<%=syn.getName().substring(6)%>"><%=syn.getName()%></a>
          <% } else if( syn.getName().startsWith("EFO:") ) { %>
              <a href="<%=XDBIndex.getInstance().getXDB(93).getUrl()%>EFO_<%=syn.getName().substring(4)%>"><%=syn.getName()%></a>
          <% } else if( syn.getType().startsWith("omim_gene") ) {
              List<Gene> omimGenes = new GeneDAO().getActiveGenes(SpeciesType.HUMAN, syn.getName());
              if( !omimGenes.isEmpty() ) {
           %>
                  <a href=<%=Link.gene(omimGenes.get(0).getRgdId())%>"><%=syn.getName()%></a>
            <%
              } else {
            %><%=syn.getName()%><%
              }
           } else {
              // create pattern based on ontology id
              int pos = bean.getAccId().indexOf(":");
              String ontId = !syn.getType().equals("alt_id") && pos>0 ? bean.getAccId().substring(0, pos) : null;
              if( ontId!=null ) {
                  Pattern p = Pattern.compile("\\b("+ontId+"\\:\\d{7})\\b");
                  StringBuffer sb = new StringBuffer();
                  Matcher m = p.matcher(syn.getName());
                  while( m.find() ) {
                      m.appendReplacement(sb, "<a href=\""+Link.ontView(m.group(1))+"\">"+syn.getName()+"</a>");
                  }
                  m.appendTail(sb);
                  out.append(sb.toString());
              }
              else
                out.append(syn.getName());
          }
      }

      // terminate table row
      if( !prevType.isEmpty() ) {
        out.append("</td></tr>\n");
      }

      if( !xrefs.isEmpty() ) { %>
          <tr>
          <td class="syn_type">Definition Sources:</td>
          <td style='padding:3px;'><%=xrefs%></td>
          </tr>
      <% } %>
    </table>
<% } %>

<br>
    <div style="border:1px solid black;">
    <table align="center">
    <tr>
        <td colspan="3" align="center">
            <div id="browser_graph" style="max-width:90vw;overflow:auto;"><%-- below the browser panes, display the term graph;
             since entire window width is available, terms within the graph are displayed in wide boxes,
             up to 26 chars per line --%>
<%--                <img src="https://pipelines.rgd.mcw.edu/rgdweb/ontology/dot.html?img_id=graph_4187211377720431301.png" alt="image">--%>
            <%=OntDotController.generateResponse(bean.getAccId(), "view.html?acc_id=", 26)%>
            </div>
        </td>
    </tr>
    </table>
</div>
<% } %>
<%--    <script>--%>
<%--        window.onresize = resizeDiv;--%>

<%--        function resizeDiv() {--%>
<%--            var td = document.getElementsByClassName('myDiv');--%>
<%--            td.style.maxWidth = window.innerWidth * 0.9 + 'vw';--%>
<%--        }--%>

<%--        window.onload = resizeDiv; // Resize on load--%>
<%--    </script>--%>
<%@ include file="/common/footerarea.jsp" %>
