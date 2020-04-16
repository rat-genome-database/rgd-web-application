<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.datamodel.Pathway" %>
<%@ page import="edu.mcw.rgd.datamodel.PathwayObject" %>
<%@ page import="edu.mcw.rgd.datamodel.Reference" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.*" %>
<%@ page import="edu.mcw.rgd.ontology.OntAnnotation" %>
<%@ page import="edu.mcw.rgd.ontology.OntDotController" %>
<%@ page import="edu.mcw.rgd.pathway.PathwayDiagramController" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.Record" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.ontology.OntAnnotBean" />

<%
    String headContent = "\n" +
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/jkl-parsexml.js\">\n"+
    "/***********************************************\n"+
    "*  jkl-parsexml.js ---- JavaScript Kantan Library for Parsing XML\n"+
    "*  Copyright 2005-2007 Kawasaki Yusuke u-suke[AT]kawa.net\n"+
    "*  http://www.kawa.net/works/js/jkl/parsexml.html\n"+
    "************************************************/\n"+
    "</script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/dhtmlwindow.js\">\n"+
    "/***********************************************\n"+
    "* DHTML Window script- � Dynamic Drive (http://www.dynamicdrive.com)\n"+
    "* This notice MUST stay intact for legal use\n"+
    "* Visit http://www.dynamicdrive.com/ for this script and 100s more.\n"+
    "***********************************************/\n"+
    "</script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/util.js\"></script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/gviewer.js\"></script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/domain.js\"></script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/contextMenu.js\">\n"+
    "/***********************************************\n"+
    "* Context Menu script- � Dynamic Drive (http://www.dynamicdrive.com)\n"+
    "* This notice MUST stay intact for legal use\n"+
    "* Visit http://www.dynamicdrive.com/ for this script and 100s more.\n"+
    "***********************************************/\n"+
    "</script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/event.js\"></script>\n"+
    "<script type=\"text/javascript\" src=\"/rgdweb/gviewer/script/ZoomPane.js\"></script>\n"+
"<script src=\"http://cytoscape.github.io/cytoscape.js/api/cytoscape.js-latest/cytoscape.min.js\"></script>\n"+
//"<script src=\"http://cpettitt.github.io/project/dagre/latest/dagre.js\"></script>\n"+
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/gviewer/css/gviewer.css\" />\n"+
    "<link href=\"/rgdweb/common/search.css\" rel=\"stylesheet\" type=\"text/css\">\n"+
    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/rgdweb/css/ontology.css\" />\n";

    XdbIdDAO xd = new XdbIdDAO();
    OntologyXDAO ontDao = new OntologyXDAO();
    PathwayDAO pwDao = new PathwayDAO(); 

    Pathway pwObj = (Pathway) request.getAttribute("pathway");

    String pageDescription = pwObj.getName()+ RgdContext.getLongSiteName(request);
    String pageTitle = pwObj.getName()+ RgdContext.getLongSiteName(request);

    String pwName = pwObj.getName().trim();
    String pwId = pwObj.getId();
    String pwDesc = pwObj.getDescription();
    String pwAlt = pwObj.getHasAlteredPath();
    if (pwAlt.equals("")){
        pwAlt = "NA";
    }
    List<Reference> pwRefList = pwObj.getReferenceList();
    List<PathwayObject> pwAssObjList = pwObj.getObjectList();
    String url = "";

    PathwayDiagramController pd = new PathwayDiagramController();

    //get the associated diseases info:
    Map<String, List<Integer>> oneDiseaseManyGenes = (Map<String, List<Integer>>) request.getAttribute("OneDiseaseManyGenes");
    Map<String, List<Integer>> onePheManyGenes = (Map<String, List<Integer>>) request.getAttribute("OnePheManyGenes");
    Map<String, List<Integer>> onePathManyGenes = (Map<String, List<Integer>>) request.getAttribute("OnePathManyGenes");

    Map<Integer, List<String>> oneGeneManyTerms = (Map<Integer, List<String>>) request.getAttribute("OneGeneManyTerms");
    List<Integer> oneGeneManyTermsKeys = (List<Integer>) request.getAttribute("OneGeneManyTermsKeys");

    Map<String,String> termMap = (Map<String,String>) request.getAttribute("termMap");
    Map<Integer,String> geneMap = (Map<Integer,String>) request.getAttribute("geneMap");

    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties("width=97%");

%>
<%@ include file="/common/headerarea.jsp"%>
<%
HttpRequestFacade req= new HttpRequestFacade(request);
DisplayMapper dm = new DisplayMapper(req, error);
//int speciesKey = (Integer) request.getAttribute("speciesTypeKey");
boolean hasAnnots = (Boolean) request.getAttribute("hasAnnotations");
%>
<style type="text/css">
    .sectionLink {font-style:italic;padding-left:10px;list-style:square}
    #cy {
      height: 600px;
      width: 800px;
	  border: solid 1px blue;
    }
    #cy2 {
      height: 600px;
      width: 800px;
	  border: solid 1px blue;
    }
</style>

<script type="text/javascript">
function getHostName(){
    return window.location.hostname;
}


function showonlyonePheno(selectedBlock,fld) {
    var newboxes = document.getElementsByTagName("div");
    for(var x=0; x<newboxes.length; x++) {

        var name = newboxes[x].id;

        if (name.search('PheBoxes')>-1) {
            if (newboxes[x].id == selectedBlock) {
                newboxes[x].style.display = 'block';
            //newboxes[x].style.backgroundColor='red';
            }
            else {
                newboxes[x].style.display = 'none';
                //document.getElementById(fld).style.backgroundColor='blue';
                //newboxes[x].style.backgroundColor='white';
            }
        }
        if(name.search('pheHeader')>-1) {
            if (newboxes[x].id == fld) {
                //newboxes[x].style.display = 'block';
                newboxes[x].style.backgroundColor='#ffd700';
            }
            else {
                newboxes[x].style.backgroundColor='#808000';
            }
        }

    }
}

function showonlyonePath(selectedBlock,fld) {
    var newboxes = document.getElementsByTagName("div");
    for(var x=0; x<newboxes.length; x++) {

        name = newboxes[x].id;

        if (name.search('PathBoxes')>-1) {
            if (newboxes[x].id == selectedBlock) {
                newboxes[x].style.display = 'block';
            //newboxes[x].style.backgroundColor='red';
            }
            else {
                newboxes[x].style.display = 'none';
                //document.getElementById(fld).style.backgroundColor='blue';
                //newboxes[x].style.backgroundColor='white';
            }
        }
        if(name.search('pathHeader')>-1) {
            if (newboxes[x].id == fld) {
                //newboxes[x].style.display = 'block';
                newboxes[x].style.backgroundColor='#7fffd4';
            }
            else {
                newboxes[x].style.backgroundColor='#5f9ea0';
            }
        }

    }
}

function showonlyoneDis(selectedBlock,fld) {
    var newboxes = document.getElementsByTagName("div");
    for(var x=0; x<newboxes.length; x++) {

        name = newboxes[x].id;

        if (name.search('DisBoxes')>-1) {
            if (newboxes[x].id == selectedBlock) {
                newboxes[x].style.display = 'block';
            //newboxes[x].style.backgroundColor='red';
            }
            else {
                newboxes[x].style.display = 'none';
                //document.getElementById(fld).style.backgroundColor='blue';
                //newboxes[x].style.backgroundColor='white';
            }
        }
        if(name.search('disHeader')>-1) {
            if (newboxes[x].id == fld) {
                //newboxes[x].style.display = 'block';
                newboxes[x].style.backgroundColor='#ffdab9';
            }
            else {
                newboxes[x].style.backgroundColor='#cd5c5c';
            }
        }

    }
}
</script>

<%--<a href="/rgdweb/curation/pathway/home.html">Back to Pathway Search</a>--%>
<div class="container-fluid">
<table width="900">
<tr>
    <td></td><td>
        <h5 align="right">
        <c:if test='<%=req.getParameter("processType").equals("create")%>'>
        <form id="pathwayCreate" action="/rgdweb/curation/pathway/pathwayCreate.html" method="GET">
            <input name="editPW" id="editPW1" type="submit" value="Edit This Pathway">
            <input name="acc_id" id="acc_id1a" type="hidden" value="<%=pwId%>">
            <input name="processType" type="hidden" id="processType1a" value="update"/>
        </form>
        <form id="pathwayCreate" action="/rgdweb/curation/pathway/home.html" method="GET">
        <input name="createPW" id="createPW1a" type="submit" value="Create a new Pathway">
        </form>
        </c:if>
        </h5>

        <h5 align="right">
        <c:if test='<%=req.getParameter("processType").equals("update")%>'>
        <form id="pathwayCreate" action="/rgdweb/curation/pathway/pathwayCreate.html" method="GET">
            <input name="editPW" id="editPW2" type="submit" value="Edit This Pathway">
            <input name="acc_id" id="acc_id2a" type="hidden" value="<%=pwId%>">
            <input name="processType" type="hidden" id="processType2a" value="update"/>
        </form>
        <form id="pathwayCreate" action="/rgdweb/curation/pathway/home.html" method="GET">
        <input name="createPW" id="createPW2a" type="submit" value="Create a new Pathway">
        </form>
        </c:if>
        </h5>
    </td>
</tr>
<tr>
    <td rowspan="100" valign="top" >
        <img style="border:white;" alt="" hspace="10" vspace="20" src="/common/images/pathwayDiagramLegend.jpg"/>
    </td>
    <h3 align="justify"><%=pwName.toUpperCase()+"  ("+pwId+")"%></h3>
    <h4><a href="/rgdweb/ontology/annot.html?species=Rat&acc_id=<%=pwId%>" target="_blank">View Ontology Report</a></h4>

    <h3 align="justify">Description</h3>
    <td valign="top" width="780">
        <%
        if( !Utils.isStringEmpty(pwDesc) ){
            if(pwDesc.length()>500){
                String start = pwDesc.substring(0, 500);
                start = start+"<div id='pw_descA' style=\"display:inline;\">"+"<a href='javascript:document.getElementById(\"pw_desc\").style.display=\"inline\";document.getElementById(\"pw_descA\").style.display=\"none\";void(0);' >...(more)</a></div>";
                String last = pwDesc.substring(500);
                String div = "<div id='pw_desc' style='display:none;'>"+last+"<a href='javascript:document.getElementById(\"pw_descA\").style.display=\"inline\";document.getElementById(\"pw_desc\").style.display=\"none\";void(0);' >...(less)</a></div>";
                pwDesc = start+div;
            }
        }else{
            pwDesc = "(no description added)";
        }
        %>
        <%=pwDesc%>
    </td>
</tr>
<tr>
    <td align="justify" style="padding-top:2%;padding-bottom:2%">
        <h3>Pathway Diagram:</h3>
    <%
        if(!(pd.generateContent("map", pwId.replaceAll(":", "")).equals(""))){
            out.println(pd.generateContent("map", pwId.replaceAll(":", "")));
        }else{
        %>
        <h5 style="color:#0000ff;">Diagram to be Modified:</h5>
        <%}%>
    </td>
</tr>
<tr>
    <td>
    <table style="border-style:ridge;padding-top:1.2%;" width="780"><b>GO TO:</b>
        <tr>
            <td>
                <ul>
                  <c:if test='<%=hasAnnots%>'>
                  <li><a class="sectionLink" href="#GenesInPathway">Genes</a></li>
                  </c:if>
                  <c:if test='<%=pwAlt.equals("Y")%>'>
                  <li><a class="sectionLink" href="#AlteredPathway">Altered Pathway</a></li>
                  </c:if>
                  <c:if test='<%=pwAssObjList!=null%>'>
                  <li><a class="sectionLink" href="#PathwayObjects">Additional Elements</a></li>
                  </c:if>
                </ul>
            </td>

            <td>
                <ul>
                  <c:if test='<%=!(oneDiseaseManyGenes.isEmpty())%>'>
                  <li><a class="sectionLink" href="#Disease">Disease annotations to Pathway Genes</a></li>
                  </c:if>
                  <c:if test='<%=!(onePathManyGenes.isEmpty())%>'>
                  <li><a class="sectionLink" href="#Pathway">Pathway annotations to Pathway Genes</a></li>
                  </c:if>
                  <c:if test='<%=!(onePheManyGenes.isEmpty())%>'>
                  <li><a class="sectionLink" href="#Phenotype">Phenotype annotations to Pathway Genes</a></li>
                  </c:if>
                </ul>
            </td>

            <td>
                <ul>
                  <c:if test='<%=!(pwRefList.isEmpty())%>'>
                  <li><a class="sectionLink" href="#References">References</a></li>
                  </c:if>
                  <li><a class="sectionLink" href="#PathwayGraph">Ontology path Diagram</a></li>
                </ul>
            </td>
        </tr>
    </table>
    </td>
</tr>
<tr>
    <td style="padding-top:2%" width="780">
        <a name="GenesInPathway"><h3><b>Genes in Pathway:</b></h3></a>
            <%@ include file="../ontology/annotTable.jsp" %>
    </td>
</tr>
<tr>
    <td>
    <table width="780">
    <c:if test='<%=pwAlt.equals("Y")%>'>
    <tr>
        <td>
            <a name="AlteredPathway"><h3><b>Altered Pathway: </b></h3></a>
            <ul>
                <li>
                <%
                    List<String> pwAtlFullTerm = pwDao.getAltPwIDs(pwId);
                    if(pwAtlFullTerm.size()>0){

                        for(String altTerm : pwAtlFullTerm){
                            Pathway pwTerm = pwDao.getPathwayInfo(altTerm);
                            Term alternateTerm = ontDao.getTerm(altTerm);
                            if(pwTerm != null){
                        %>

                        <a href="/rgdweb/pathway/pathwayRecord.html?acc_id=<%=pwTerm.getId()%>"><%=pwTerm.getName()%></a>

                        <%  } else { %>

                        <a style="font:bold" href="/rgdweb/ontology/annot.html?acc_id=<%=altTerm%>"><%=alternateTerm.getTerm()%></a>

                        <% }
                        }
                    }else{

                    %>
                        <b>NA</b>
                    <% } %>
                </li>
            </ul>
        </td>
    </tr>
    </c:if>
    <tr>
        <td>
            <c:if test="<%=pwAssObjList!=null%>">
            <a name="PathwayObjects"><h3><b>Additional Elements in Pathway:</b><h6>(includes Gene Groups, Small Molecules, Other Pathways..etc.)</h6></h3></a>
            <%
                Report pathwayObjReport = new Report();
                Record poHeader = new Record();

                poHeader.append("Object Type");
                poHeader.append("Pathway Object");
                poHeader.append("Pathway Object Description");

                pathwayObjReport.append(poHeader);

                for(PathwayObject pwo: pwAssObjList){

                    if(pwo.getXdb_key()!=null){
                        url = xd.getXdbUrlnoSpecies(pwo.getXdb_key());
                        url += pwo.getAccId();
                    }else{
                       url = pwo.getUrl();
                       if(url==null){
                           url="null";
                       }else{
                           url += pwo.getAccId();
                       }
                    }

                    Record pathObjRec = new Record();

                    pathObjRec.append(pwo.getTypeName());
                    if(url.equals("null")){
                        pathObjRec.append(pwo.getObjName());
                    }else{
                        pathObjRec.append("<a href="+url+">"+ pwo.getObjName()+"</a>");
                    }
                    pathObjRec.append(pwo.getObjDesc());

                    pathwayObjReport.append(pathObjRec);
                }

                pathwayObjReport.sort(2,Report.ASCENDING_SORT,true);

            %>
                <%= strat.format(pathwayObjReport)%>
            </c:if>
        </td>
    </tr>
    <tr><td><h3 style="padding-top:5%"><b>Pathway Gene Annotations</b></h3></td></tr>
    <c:if test="<%=!(oneDiseaseManyGenes.isEmpty())%>">
    <tr>
        <td>
        <table width="780" align="center">
           <tr>
               <td colspan="2">
                   <a name="Disease"><b style="font-size:115%;">Disease Annotations Associated with Genes in the <%=pwName%></b></a>
               </td>
           </tr>
           <tr>
              <td style="width:50%;">
                 <div align="center" id="disHeader2" style="border: 2px #00008b; border-style:ridge; background-color:#ffdab9;padding:5px;">
                    <a id="myDisHeader2" href="javascript:showonlyoneDis('newDisBoxes2', 'disHeader2');" >
                        <b>Diseases/Genes</b>
                    </a>
                 </div>
              </td>
              <td>
                 <div align="center" id="disHeader1" style="border: 2px #00008b; border-style:ridge; background-color:#cd5c5c; padding:5px;">
                    <a id="myDisHeader1" href="javascript:showonlyoneDis('newDisBoxes1', 'disHeader1');" >
                        <b>Genes/Diseases</b>
                    </a>
                 </div>
              </td>
           </tr>
           <tr>
              <td colspan="2">
                 <div align="center" name="newDisBoxes" id="newDisBoxes1" style="border: 2px #00008b; border-style:ridge; background-color:#ffe4e1;
                 display: none;padding: 5px;">
                    <c:if test="<%=hasAnnots%>">
                        <%
                            Report otherAnn = new Report();
                            Record annRecordHeader = new Record();
                            annRecordHeader.append("GeneSymbol");
                            annRecordHeader.append("Diseases");

                            otherAnn.append(annRecordHeader);

                            for( int rgdId: oneGeneManyTermsKeys ){

                                List<String> termAccIds = oneGeneManyTerms.get(rgdId);
                                Record annRecord = new Record();

                                StringBuilder DList = new StringBuilder();
                                for(String termAccId: termAccIds){

                                    if( termAccId.startsWith("DOID:") ){
                                        DList.append("<a href='/rgdweb/ontology/annot.html?acc_id=")
                                             .append(termAccId).append("'>")
                                             .append(termMap.get(termAccId))
                                             .append("</a> , ");
                                    }
                                }
                                if( DList.length()>0 ) {
                                    DList.delete(DList.length()-2, DList.length());

                                    annRecord.append("<a href="+Link.gene(rgdId)+">"+geneMap.get(rgdId)+"</a>");
                                    annRecord.append(DList.toString());

                                    otherAnn.append(annRecord);
                                }
                            }

                            out.print(strat.format(otherAnn));
                        %>
                    </c:if>
                 </div>
                 <div align="center" name="newDisBoxes" id="newDisBoxes2" style="border: 2px #00008b; border-style:ridge; background-color: #ffe4e1;
                 display: block;padding: 5px;">
                     <c:if test="<%=hasAnnots%>">
                        <%
                            Report diseaseReport = new Report();
                            Record diseaseHeader = new Record();
                            diseaseHeader.append("Disease Terms");
                            diseaseHeader.append("Gene Symbols");
                            diseaseReport.append(diseaseHeader);

                            List<String> oneDiseaseMeanyGenesKeys = (List<String>) request.getAttribute("OneDiseaseManyGenesKeys");
                            for( String termAccId: oneDiseaseMeanyGenesKeys ) {
                                Record dHeader = new Record();

                                List<Integer> rgdIds = oneDiseaseManyGenes.get(termAccId);

                                StringBuilder GList = new StringBuilder();
                                for(Integer rgdId: rgdIds){

                                    GList.append("<a href='")
                                         .append(Link.gene(rgdId))
                                         .append("'>")
                                         .append(geneMap.get(rgdId))
                                         .append("</a> , ");
                                }
                                GList.delete(GList.length()-2, GList.length());

                                dHeader.append("<a href=/rgdweb/ontology/annot.html?acc_id="+termAccId+">"+
                                                                            termMap.get(termAccId)+"</a>");
                                dHeader.append(GList.toString());
                                diseaseReport.append(dHeader);
                            }

                            out.print(strat.format(diseaseReport));
                        %>
                    </c:if>
                 </div>
              </td>
           </tr>
        </table>
        </td>
    </tr>
    </c:if>

    <c:if test="<%=!(onePathManyGenes.isEmpty())%>">
    <tr>
        <td>
        <table style="padding-top:2%" width="780" align="center">
           <tr>
               <td colspan="2">
                   <a name="Pathway"><b style="font-size:115%">Pathway Annotations Associated with Genes in the <%=pwName%></b></a>
               </td>
           </tr>
           <tr>
              <td style="width:50%;">
                 <div align="center" id="pathHeader2" style="border: 2px #00008b; border-style:ridge; background-color:#7fffd4; padding: 5px;">
                    <a id="myPathHeader2" href="javascript:showonlyonePath('newPathBoxes2', 'pathHeader2');" >
                        <b>Pathways/Genes</b>
                    </a>
                 </div>
              </td>
              <td>
                 <div align="center" id="pathHeader1" style="border: 2px #00008b; border-style:ridge; background-color:#5f9ea0; padding: 5px;">
                    <a id="myPathHeader1" href="javascript:showonlyonePath('newPathBoxes1', 'pathHeader1');" >
                        <b>Genes/Pathways</b>
                    </a>
                 </div>
              </td>
           </tr>
           <tr>
              <td colspan="2">
                 <div align="center" name="newPathBoxes" id="newPathBoxes1" style="border: 2px #00008b; border-style:ridge; background-color: #b0e0e6;
                 display: none;padding: 5px;">
                    <c:if test="<%=hasAnnots%>">
                        <%
                            Report otherAnn = new Report();
                            Record annRecordHeader = new Record();

                            annRecordHeader.append("GeneSymbol");
                            annRecordHeader.append("Pathways");
                            otherAnn.append(annRecordHeader);

                            for( int rgdId: oneGeneManyTermsKeys ){

                                List<String> termAccIds = oneGeneManyTerms.get(rgdId);
                                Record annRecord = new Record();

                                StringBuilder DList = new StringBuilder();
                                for(String termAccId: termAccIds){

                                    if( termAccId.startsWith("PW:") ){
                                        DList.append("<a href='/rgdweb/ontology/annot.html?acc_id=")
                                             .append(termAccId).append("'>")
                                             .append(termMap.get(termAccId))
                                             .append("</a> , ");
                                    }
                                }
                                if( DList.length()>0 ) {
                                    DList.delete(DList.length()-2, DList.length());

                                    annRecord.append("<a href="+Link.gene(rgdId)+">"+geneMap.get(rgdId)+"</a>");
                                    annRecord.append(DList.toString());

                                    otherAnn.append(annRecord);
                                }
                            }

                            out.print(strat.format(otherAnn));
                        %>
                    </c:if>
                 </div>
                 <div align="center" name="newPathBoxes" id="newPathBoxes2" style="border: 2px #00008b; border-style:ridge; background-color: #b0e0e6;
                 display: block;padding: 5px;">
                     <c:if test="<%=hasAnnots%>">
                        <%
                            Report pathReport = new Report();
                            Record pathHeader = new Record();
                            pathHeader.append("Pathway Terms");
                            pathHeader.append("Gene Symbols");
                            pathReport.append(pathHeader);

                            List<String> onePathManyGenesKeys = (List<String>) request.getAttribute("OnePathManyGenesKeys");
                            for( String termAccId: onePathManyGenesKeys ) {
                                Record dHeader = new Record();

                                List<Integer> rgdIds = onePathManyGenes.get(termAccId);

                                StringBuilder GList = new StringBuilder();
                                for(Integer rgdId: rgdIds){

                                    GList.append("<a href='")
                                         .append(Link.gene(rgdId))
                                         .append("'>")
                                         .append(geneMap.get(rgdId))
                                         .append("</a> , ");
                                }
                                GList.delete(GList.length()-2, GList.length());

                                dHeader.append("<a href=/rgdweb/ontology/annot.html?acc_id="+termAccId+">"+
                                                                            termMap.get(termAccId)+"</a>");
                                dHeader.append(GList.toString());
                                pathReport.append(dHeader);
                            }
                            out.print(strat.format(pathReport));
                        %>
                    </c:if>
                 </div>
              </td>
           </tr>
        </table>
        </td>
    </tr>
    </c:if>

    <c:if test="<%=!(onePheManyGenes.isEmpty())%>">
    <tr>
        <td>
        <table style="padding-top:2%" width="780">
           <tr>
               <td colspan="2">
                   <a name="Phenotype"><b style="font-size:115%;">Phenotype Annotations Associated with Genes in the <%=pwName%></b></a>
               </td>
           </tr>
           <tr>
              <td style="width:50%;">
                 <div align="center" id="pheHeader2" style="border: 2px #00008b; border-style:ridge; background-color:#ffd700; padding: 5px;">
                    <a id="myPheHeader2" href="javascript:showonlyonePheno('newPheBoxes2', 'pheHeader2');" >
                        <b>Phenotype/Gene</b>
                    </a>
                 </div>
              </td>
              <td>
                 <div align="center" id="pheHeader1" style="border: 2px #00008b; border-style:ridge; background-color:#808000; padding: 5px;">
                    <a id="myPheHeader1" href="javascript:showonlyonePheno('newPheBoxes1', 'pheHeader1');" >
                        <b>Gene/Phenotype</b>
                    </a>
                 </div>
              </td>
           </tr>
           <tr>
              <td colspan="2">
                 <div align="center" name="newPheBoxes" id="newPheBoxes1" style="border: 2px #00008b; border-style:ridge; background-color:#f0e68c;
                 display: none;padding: 5px;">
                    <c:if test="<%=hasAnnots%>">
                        <%
                            Report otherAnn2 = new Report();
                            Record annRecordHeader2 = new Record();

                            annRecordHeader2.append("GeneSymbol");
                            annRecordHeader2.append("Phenotype");

                            otherAnn2.append(annRecordHeader2);

                            for( int rgdId: oneGeneManyTermsKeys ){

                                List<String> termAccIds = oneGeneManyTerms.get(rgdId);
                                Record annRecord = new Record();

                                StringBuilder DList = new StringBuilder();
                                for(String termAccId: termAccIds){

                                    if( termAccId.startsWith("MP:") ){
                                        DList.append("<a href='/rgdweb/ontology/annot.html?acc_id=")
                                             .append(termAccId).append("'>")
                                             .append(termMap.get(termAccId))
                                             .append("</a> , ");
                                    }
                                }
                                if( DList.length()>0 ) {
                                    DList.delete(DList.length()-2, DList.length());

                                    annRecord.append("<a href="+Link.gene(rgdId)+">"+geneMap.get(rgdId)+"</a>");
                                    annRecord.append(DList.toString());

                                    otherAnn2.append(annRecord);
                                }
                            }

                            out.print(strat.format(otherAnn2));
                        %>
                    </c:if>
                 </div>
                 <div align="center" name="newPheBoxes" id="newPheBoxes2" style="border: 2px #00008b; border-style:ridge; background-color: #f0e68c;
                 display: block;padding: 5px;">
                     <c:if test="<%=hasAnnots%>">
                        <%
                            Report pheReport = new Report();
                            Record pheHeader = new Record();
                            pheHeader.append("Phenotype Terms");
                            pheHeader.append("Gene Symbols");
                            pheReport.append(pheHeader);

                            List<String> onePheManyGenesKeys = (List<String>) request.getAttribute("OnePheManyGenesKeys");
                            for( String termAccId: onePheManyGenesKeys ) {
                                Record dHeader = new Record();

                                List<Integer> rgdIds = onePheManyGenes.get(termAccId);

                                StringBuilder GList = new StringBuilder();
                                for(Integer rgdId: rgdIds){

                                    GList.append("<a href='")
                                         .append(Link.gene(rgdId))
                                         .append("'>")
                                         .append(geneMap.get(rgdId))
                                         .append("</a> , ");
                                }
                                GList.delete(GList.length()-2, GList.length());

                                dHeader.append("<a href=/rgdweb/ontology/annot.html?acc_id="+termAccId+">"+
                                                                            termMap.get(termAccId)+"</a>");
                                dHeader.append(GList.toString());
                                pheReport.append(dHeader);
                            }
                            out.print(strat.format(pheReport));
                        %>
                    </c:if>
                 </div>
              </td>
           </tr>
        </table>
        </td>
    </tr>
    </c:if>

    <tr>
        <td>
            <a name="References"><h3><b>References Associated with the <%=pwName%>:</b></h3></a>
            <ul>
            <%
                for (Reference aRef: pwRefList) {
            %>
                <li><a href="<%=Link.ref(aRef.getRgdId())%>"><%=aRef.getCitation()%>
                </a></li>
            <% } %>
            </ul>
        </td>
    </tr>
</table>
    </td>
</tr>
<tr>
    <td>
        <a name="PathwayGraph"><h3>Ontology Path Diagram:</h3></a>
        <table align="center">
            <tr>
                <td colspan="3" align="center">
                    <div class="container-fluid">
                <%=OntDotController.generateResponse(pwId, "/rgdweb/ontology/annot.html?acc_id=", 30)%>
                    </div>
                </td>
            </tr>
        </table>
    </td>
</tr>
<tr>
    <td>
        <a name="Import"><h3><b>Import into Pathway Studio:</b></h3></a>
        <ul><li>
        <a href="<%=pd.generateContent("gpp", pwId)%>"><%=pwName+".gpp"%></a>
        </li></ul>
    </td>
</tr>
</table>
</div>
<%@ include file="/common/footerarea.jsp"%>