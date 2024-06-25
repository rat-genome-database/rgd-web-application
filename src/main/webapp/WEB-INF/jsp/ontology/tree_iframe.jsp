<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermSynonym" %>
<%@ page import="edu.mcw.rgd.datamodel.XDBIndex" %>
<%@ page import="edu.mcw.rgd.datamodel.XdbId" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="edu.mcw.rgd.ontology.OntBrowser" %>

<link href="/rgdweb/css/ontology.css" rel="stylesheet" type="text/css" >
<%
    // if acc_id parameter is not given, use 'ont' parameter to determine ontology root term
    // for browsing
    response.setHeader("Access-Control-Allow-Origin", "*.mcw.edu");

    String accId = request.getParameter("acc_id");
    if( Utils.isStringEmpty(accId) ) {
        String ontId = request.getParameter("ont");
        if( !Utils.isStringEmpty(ontId) ) {

            // try a term parameter
            String termName = request.getParameter("term");
            if( !Utils.isStringEmpty(termName) ) {
                Term term = new OntologyXDAO().getTermByTermName(termName, ontId);
                if( term!=null )
                    accId = term.getAccId();
            }

            if( Utils.isStringEmpty(accId) )
                accId = new OntologyXDAO().getRootTerm(ontId);
        }
    }

    // url for browsing the tree should include 'sel_acc_id' and 'sel_term' parameters if available
    String selAccId = request.getParameter("sel_acc_id");
    String selTerm = request.getParameter("sel_term");
    String url = "/rgdweb/ontology/view.html?mode=iframe&always_select=1";
    if( !Utils.isStringEmpty(selAccId) )
        url += "&sel_acc_id="+selAccId;
    if( !Utils.isStringEmpty(selTerm) )
        url += "&sel_term="+selTerm;
    if( Utils.NVL(request.getParameter("dia"),"0").equals("1") ) {
        url += "&dia=1";
    }

    OntBrowser ontBrowser = new OntBrowser();
    ontBrowser.setAcc_id( accId, request );
    ontBrowser.setUrl(url);
    ontBrowser.setOffset(request.getParameter("offset"));
    ontBrowser.setOpener_sel_acc_id(selAccId);
    ontBrowser.setOpener_sel_term(selTerm);

    ontBrowser.doTag(request, out);
%>
<table width=100% style="border: 1px solid black;  background-color:#F6F6F6; margin: 5px; padding:5px; ">

  <tr>
    <td style="font-size:16px; font-weight:700;" colspan=2 >Synonyms</TD>

    <% String prevType = "";
    int synonymsPerType = 0;
    OntologyXDAO ontDao = new OntologyXDAO();
    for( TermSynonym syn: ontDao.getTermSynonyms(accId) ) {

      if( !prevType.equals(syn.getType()) ) {
          // finish prev row
          if( !prevType.isEmpty() ) {
          %>
            </td></tr>
          <% } %>

          <tr>
          <td class="syn_type"><%=syn.getFriendlyType()%>:</td><td style='padding:3px;'>

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
      <% } else if( syn.getName().startsWith("DOID:") && !accId.startsWith("DOID:") ) { %>
          <a href="<%=Link.ontView(syn.getName())%>"><%=syn.getName()%></a>
      <% } else if( syn.getType().startsWith("omim_gene") ) {
          List<Gene> omimGenes = new GeneDAO().getActiveGenes(SpeciesType.HUMAN, syn.getName());
          if( !omimGenes.isEmpty() ) {
       %>
              <a href=<%=Link.gene(omimGenes.get(0).getRgdId())%>"><%=syn.getName()%></a>
        <%
          } else {
        %>
              <%=syn.getName()%>
         <%
          }
       } else {
          // create pattern based on ontology id
          int pos = accId.indexOf(":");
          String ontId = !syn.getType().equals("alt_id") && pos>0 ? accId.substring(0, pos) : null;
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
%>

