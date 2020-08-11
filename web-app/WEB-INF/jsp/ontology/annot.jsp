<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.*" %>
<%@ page import="edu.mcw.rgd.ontology.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.ontology.OntAnnotBean" />
<% String headContent = "\n" +
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/jkl-parsexml.js\">\n"+
    "/***********************************************\n"+
    "*  jkl-parsexml.js ---- JavaScript Kantan Library for Parsing XML\n"+
    "*  Copyright 2005-2007 Kawasaki Yusuke u-suke[AT]kawa.net\n"+
    "*  http://www.kawa.net/works/js/jkl/parsexml.html\n"+
    "************************************************/\n"+
    "</script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/dhtmlwindow.js\">\n"+
    "/***********************************************\n"+
    "* DHTML Window script- © Dynamic Drive (http://www.dynamicdrive.com)\n"+
    "* This notice MUST stay intact for legal use\n"+
    "* Visit http://www.dynamicdrive.com/ for this script and 100s more.\n"+
    "***********************************************/\n"+
    "</script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/util.js\"></script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/gviewer.js\"></script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/domain.js\"></script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/contextMenu.js\">\n"+
    "/***********************************************\n"+
    "* Context Menu script- © Dynamic Drive (http://www.dynamicdrive.com)\n"+
    "* This notice MUST stay intact for legal use\n"+
    "* Visit http://www.dynamicdrive.com/ for this script and 100s more.\n"+
    "***********************************************/\n"+
    "</script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/event.js\"></script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/ZoomPane.js\"></script>\n"+
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/gviewer/css/gviewer.css\">\n"+

    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/css/ontology.css\">\n"+
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/common/search.css\">\n";

   String pageTitle = bean.getTerm().getTerm()+" - Ontology Report - " + RgdContext.getLongSiteName(request);
   String pageDescription = pageTitle;
%>

<%@ include file="ontHeader.jsp"%>
<div style="margin-left:10px;">

    <table width="100%">
        <%  String[] ontologyAbr = bean.getAccId().split(":");
            String OntPrefix = ontologyAbr[0];
            if(OntPrefix.equals("DOID"))
                OntPrefix = "RDO";
            String ontology = "ONTOLOGY REPORT", source = null;
            OntologyXDAO dao = new OntologyXDAO();
            Ontology onto = dao.getOntology(OntPrefix);
            if(onto != null) {
                String[] anotherOntAbr = onto.getName().split(":");
                ontology = anotherOntAbr[1].toUpperCase();
                source = onto.getDescription();
            }
        %>
        <tr>
            <td><h2> <%=ontology%> - ANNOTATIONS </h2></td>
            <td align="center"><div ng-click="rgd.addWatch(pageObject)"><img heght="30" width="30" src="/rgdweb/common/images/binoculars.png" border="0"/><br><a href="javascript:void(0)" >{{ watchLinkText }}</a></div></td>

        </tr>
        <tr>
            <td>
                <%if(source != null){
                    out.print(source);%>

                <%}%>
            </td>
        </tr>
    </table>

  <hr/>
  <%-- TERM INFO TABLE, WITH SYNONYMS --%>
  <%@ include file="termInfoTable.jsp" %>
  <%-- <a name="top"/>  <!-- for sme reason this line causes links in GViewer stop working --> --%>
  <hr/>
  <br>
    <table width="100%">
        <tr>
            <td align="center">
                <div id="gviewer" class="gviewer">
                    <c:if test="${bean.speciesTypeKey==0}">Please select species to view GViewer data.</c:if>
                    <c:if test="${bean.speciesTypeKey==4}">GViewer not supported for chinchilla.</c:if>
                </div>
                <div id="zoomWrapper" class="zoom-pane"></div>
            </td>
        </tr>
    </table>

    <% if( bean.getAnnotCount()>= OntAnnotBean.MAX_ANNOT_COUNT ) { %>
<%--
    <div style="font-weight:bold; color:brown; margin-top:15px; margin-left:50px; margin-right:50px; padding: 5px; background-color:rgb(235,235,235)">
    Note: RGD's Gviewer shows a maximum of <span style="text-decoration:underline"><%=OntAnnotBean.MAX_ANNOT_COUNT%></span> annotations.
    The number of <%=bean.getSpecies()%> annotations for this term <%=bean.isWithChildren()?"and its children":""%>
    is <span style="text-decoration:underline"><%=bean.getAnnotCount()%></span>.
    Click 'download' to see all annotations in this set.
    </div>
--%>
    <% } %>

    <%-- ANNOTATIONS TABLE --%>
<%@ include file="annotTable.jsp" %>

  <HR/>
    <div><%-------------- PATHS TO ROOT -------%>
    <a name="paths"></a>
    <span>Term paths to the root</span> <%=fu.buildSelectList("path_type\" onChange=\"addParamToLocHref('path_type',this.options[selectedIndex].value, '#paths')", bean.getPathTypeChoices(), bean.getPathType())%>
    <br/>
    <div id="searchResultWrapperTable" style="margin-right:25px;">
    <div id="searchResult">
    <table><tr><td valign="top">
    <table cellspacing="2" cellpadding="2" border="0">

    <%  int pathNo = 0;
        for( List<TermWithStats> path: bean.getPaths() ) {
            pathNo++;
            if( pathNo==1 && bean.getPathType().equals("6") && bean.getPaths().size()==50 ) {
                out.print("<tr><td colspan=\"3\" align='right'>showing first 50 paths to root</td></tr>\n");
            }
        %><tr class="srH1" align="left">
            <th colspan="3">Path <%=pathNo%></th>
        </tr>
        <tr class="headerRow">
            <td><b>Term</b></td>
            <td><b title="Count of annotations for term and descendants">Annotations</b></td>
            <td><img title="click to browse term" alt="click to browse term" src="/rgdweb/common/images/tree.png" border="0"/></td>
        </tr><%
            String spacer = " &nbsp; ";
            for( TermWithStats term: path ) {
                out.append("<tr><td>")
                   .append(spacer);
                // if this is a current term, show it on bold with special image
                if( term.getAccId().equals(bean.getAccId()) ) {
                    // spacer followed by current term image
                    out.append("<img class='rel' src='/rgdweb/images/current_term.png' title='current term'> ");
                    // and followed by term name in bold
                    out.append("<span style='font-weight:bold;'>")
                       .append(term.getTerm()).append("</span></td>\n");
                }
                else {
                    // term relation image -- could be null
                    String image = OntViewBean.getRelationImage(term.getRel());
                    if( image!=null ) {
                        out.append("<img class='rel' src='/common/images/").append(image)
                                .append("' title='").append(term.getRel().toString()).append("'> ");
                    }
                    // spacer followed by term name; term name clickable linking to term annotations
                    out.append("<a href='annot.html?acc_id=").append(term.getAccId()).append("'>")
                            .append(term.getTerm()).append("</a></td>\n");
                }
                // show number of annotations
                out.append("<td class=\"num\">")
                   .append(Integer.toString(term.getAnnotObjectCountForSpecies(bean.getSpeciesTypeKey())))
                   .append("</td>\n");

                // show number of annotations
                out.append("<td><a href=\"view.html?acc_id=")
                   .append(term.getAccId())
                   .append("\"><img title=\"click to browse term\" src=\"/rgdweb/common/images/tree.png\" border=\"0\"/></a></td></tr>\n");

                spacer += "&nbsp; ";
            }

            // show now the child terms
            for( TermWithStats term: bean.getChildren() ) {
                out.append("<tr><td>")
                   .append(spacer);

                // term relation image -- could be null
                String image = OntViewBean.getRelationImage(term.getRel());
                if( image!=null ) {
                    out.append("<img class='rel' src='/common/images/").append(image)
                            .append("' title='").append(term.getRel().toString()).append("'> ");
                }
                // spacer followed by term name; term name clickable linking to term annotations
                out.append("<a href='annot.html?acc_id=").append(term.getAccId()).append("'>")
                        .append(term.getTerm()).append("</a>");

                // show plus sign if there are any childs present
                if( term.getChildTermCount()>0 ) {
                    out.append("<span title=\"").append(Integer.toString(term.getChildTermCount())).append(" child terms\" class='cc'>&nbsp;+</span>");
                }
                out.append("</td>\n");

                // show number of annotations
                out.append("<td class=\"num\">")
                   .append(Integer.toString(term.getAnnotObjectCountForSpecies(bean.getSpeciesTypeKey())))
                   .append("</td>\n");

                // show number of annotations
                out.append("<td><a href=\"view.html?acc_id=")
                   .append(term.getAccId())
                   .append("\"><img title=\"click to browse term\" src=\"/rgdweb/common/images/tree.png\" border=\"0\"/></a></td></tr>\n");

            }
        }
    %>
    </table>
    </td><td valign="top"><div style="width:600px;overflow:auto">

        <% try { %>

            <%=OntDotController.generateResponse(bean.getAccId(), "annot.html?acc_id=")%>
        <% } catch (Exception e ) {

        }%>
    </div></td></tr></table>
    </div><%--end of searchResultWrapperTable--%>
    </div><%--end of searchResult--%>
    </div>
</div>

<%
%>
<% if (tws.getAnnotObjectCountForSpecies(bean.getSpeciesTypeKey(),false) <= 2400) { %>

<%----------------- GVIEWER ------------%>
<script language="JavaScript1.2">
<c:if test="${bean.speciesTypeKey==3}">
var gviewer = null;
onload= function() {

try {
    gviewer = new Gviewer("gviewer", 200, 750);
    gviewer.imagePath = "/rgdweb/gviewer/images";
    gviewer.exportURL = "/rgdweb/report/format.html";
    gviewer.annotationTypes = new Array("gene","qtl","strain");
    gviewer.genomeBrowserURL = "/jbrowse/?data=data_rgd6&tracks=ARGD_curated_genes";
    //gviewer.imageViewerURL = "/jbrowse/?data=data_rgd6&tracks=ARGD_curated_genes&menu=&nav=&overview=&tracklist=&loc=";
    gviewer.enableAdd=true;
    gviewer.genomeBrowserName = "JBrowse";
    gviewer.regionPadding=2;
    gviewer.annotationPadding = 1;
    gviewer.loadBands("/rgdweb/gviewer/data/rgd_rat_ideo.xml");
    gviewer.loadAnnotations("/rgdweb/ontology/gviewerData.html?acc_id=<%=bean.getAccId()%>&species_type=<%=bean.getSpeciesTypeKey()%>&with_childs=<%=bean.isWithChildren()?1:0%>");
    gviewer.addZoomPane("zoomWrapper", 200, 750);
}catch (err) {
    
}

}
</c:if>

<c:if test="${bean.speciesTypeKey==1}">
var gviewer = null;
onload= function() {

try {
    gviewer = new Gviewer("gviewer", 200, 750);
    gviewer.imagePath = "/rgdweb/gviewer/images";
    gviewer.exportURL = "/rgdweb/report/format.html";
    gviewer.annotationTypes = new Array("gene","qtl","strain");
    gviewer.genomeBrowserURL = "/jbrowse/?data=data_hg38&tracks=ARGD_curated_genes";
    //gviewer.imageViewerURL = "/jbrowse/?data=data_hg38&tracks=ARGD_curated_genes&menu=&nav=&overview=&tracklist=&loc=";
    gviewer.enableAdd=true;
    gviewer.genomeBrowserName = "JBrowse";
    gviewer.regionPadding=2;
    gviewer.annotationPadding = 1;
    gviewer.loadBands("/rgdweb/gviewer/data/human_ideo.xml");
    gviewer.loadAnnotations("/rgdweb/ontology/gviewerData.html?acc_id=<%=bean.getAccId()%>&species_type=<%=bean.getSpeciesTypeKey()%>&with_childs=<%=bean.isWithChildren()?1:0%>");
    gviewer.addZoomPane("zoomWrapper", 200, 750);
}catch (err) {

}

}
</c:if>

<c:if test="${bean.speciesTypeKey==2}">
var gviewer = null;
onload= function() {

try {
    gviewer = new Gviewer("gviewer", 200, 750);
    gviewer.imagePath = "/rgdweb/gviewer/images";
    gviewer.exportURL = "/rgdweb/report/format.html";
    gviewer.annotationTypes = new Array("gene","qtl","strain");
    gviewer.genomeBrowserURL = "/jbrowse/?data=data_mm38&tracks=ARGD_curated_genes";
    //gviewer.imageViewerURL = "/jbrowse/?data=data_mm38&tracks=ARGD_curated_genes&menu=&nav=&overview=&tracklist=&loc=";
    gviewer.enableAdd=true;
    gviewer.genomeBrowserName = "JBrowse";
    gviewer.regionPadding=2;
    gviewer.annotationPadding = 1;
    gviewer.loadBands("/rgdweb/gviewer/data/mouse_ideo.xml");
    gviewer.loadAnnotations("/rgdweb/ontology/gviewerData.html?acc_id=<%=bean.getAccId()%>&species_type=<%=bean.getSpeciesTypeKey()%>&with_childs=<%=bean.isWithChildren()?1:0%>");
    gviewer.addZoomPane("zoomWrapper", 200, 750);
}catch (err) {

}

}
</c:if>


</script>
<% } %>

<%@ include file="/common/footerarea.jsp"%>
