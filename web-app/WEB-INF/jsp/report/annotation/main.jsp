<%@ page import="edu.mcw.rgd.datamodel.ontology.Annotation" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdId" %>
<%@ page import="edu.mcw.rgd.datamodel.EvidenceCode" %>
<%@ page import="edu.mcw.rgd.datamodel.Reference" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.report.DaoUtils" %>
<%@ page import="edu.mcw.rgd.ontology.OntAnnotation" %>

<%@ include file="../dao.jsp"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%  boolean includeMapping = true;
    String title = "Ontology";
    String objectType = "";

    String termAcc = request.getParameter("term");
    int rgdId = Integer.parseInt(request.getParameter("id"));
    int speciesTypeKey = SpeciesType.ALL;

    List<Annotation> annotList = annotationDAO.getAnnotations(rgdId, termAcc);

    String term = termAcc;
    Annotation obj = null;
    if (annotList.size() > 0) {
        obj = annotList.get(0);
        term = obj.getTerm();
    }

    String pageTitle = "RGD Annotation Report for " + term + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "View " + RgdContext.getLongSiteName(request) + " annotations to  " + term;
%>

  <%@ include file="/common/headerarea.jsp"%>
  <%@ include file="../reportHeader.jsp"%>

<div id="searchResultHeader" style="border-bottom: 3px solid gray;">
    <ul>
        <li id=selected><a href="">View As List</a></li>
        <li><a href="javascript:location.replace('/rgdweb/report/annotation/table.html?id=<%=rgdId%>&term=<%=termAcc%>');">View As Table</a></li>
    </ul>
</div>

<div style="clear:both; padding-top:1px;">
<%
    boolean titleWritten = false;

    HashMap<String, Integer> annotCountByTermAccMap = new HashMap<String, Integer>();
    HashMap<Integer, Integer> annotCountByRefRgdIdMap = new HashMap<Integer, Integer>();
    HashMap<Integer, Integer> refCountByObjRgdIdMap = new HashMap<Integer, Integer>();

    Iterator it = annotList.iterator();
    while (it.hasNext()) {
        obj = (Annotation) it.next();


    RgdId annotatedObjRGDId = managementDAO.getRgdId(obj.getAnnotatedObjectRgdId());
    speciesTypeKey = annotatedObjRGDId.getSpeciesTypeKey();
    objectType = annotatedObjRGDId.getObjectTypeName().toUpperCase();

    if( !titleWritten ) {
        if( termAcc.startsWith("CHEBI") ) {
            out.write("<h3>"+objectType+" - CHEMICAL INTERACTIONS REPORT</h3>\n");
        } else {
            out.write("<h3>"+objectType+" - TERM ANNOTATION REPORT</h3>\n");
        }

        out.println("<h3>" + annotList.size() + " Annotations Found.</h3>");

        titleWritten = true;
    }
	// handle null references
    Reference ref = null;
	if( obj.getRefRgdId()!=null && obj.getRefRgdId()>0 ) {
		ref = referenceDAO.getReference(obj.getRefRgdId());
	}
%>

<span class="subTitle">An association has been curated linking <span class="highlight"><%=obj.getObjectSymbol()%></span>
and <span class="highlight"><%=obj.getTerm()%></span> in <%=SpeciesType.getTaxonomicName(speciesTypeKey)%>.</span>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

<% if (RgdContext.isCurator()) { %>
<a href="/rgdweb/curation/edit/editAnnotation.html?rgdId=<%=obj.getKey()%>">(Edit Me!)</a>
<% } %>
<br><br>

<table border="0" cellspacing=5>

<tr><td><li>The association was <span class="highlight"><%=EvidenceCode.getName(obj.getEvidence())%></span> (<%=obj.getEvidence()%>)</td><td>&nbsp;</td></tr>

<% if( ref!=null ) { %>
<tr><td><li>The annotation was made from <span class="highlight"><a HREF="<%=Link.ref(ref.getRgdId())%>"><%=ref.getCitation()%></a> </span></td><td></td></tr>

<% }
   if (obj.getWithInfo() != null) {

    String linkText = obj.getWithInfo();
    String linkingSentence = "";

    if(linkText.contains("|")){

        String linkTextSubPart[] = linkText.split("\\|");
        for(String subPart : linkTextSubPart){

            String link = DaoUtils.getInstance().buildEvidenceLink(subPart, obj, managementDAO);
            linkingSentence += link+" & ";
        }

        linkingSentence = linkingSentence.substring(0, (linkingSentence.length()-2));
    } else {
        String link = DaoUtils.getInstance().buildEvidenceLink(linkText, obj, managementDAO);
        linkingSentence += link+",";
        linkingSentence = linkingSentence.substring(0, (linkingSentence.length()-1));
    }
%>
    <tr><td><li>The annotation has been <%=EvidenceCode.getName(obj.getEvidence())%> with <b><%=linkingSentence%></b></td><td></td></tr>
<%}

    // get count of annotations from cache first
    Integer countOfAnnotations = annotCountByTermAccMap.get(obj.getTermAcc());
    if( countOfAnnotations==null ) {
        // old code: count annotations directly on database, which could be time consuming
        //countOfAnnotations = annotationDAO.getAnnotationCount(obj.getTermAcc(), true, annotatedObjRGDId.getSpeciesTypeKey());

        // new code: read annotation counts precomputed weekly (right before data release)
        countOfAnnotations = ontologyDAO.getTermWithStatsCached(obj.getTermAcc()).getAnnotObjectCountForSpecies(annotatedObjRGDId.getSpeciesTypeKey());

        annotCountByTermAccMap.put(obj.getTermAcc(), countOfAnnotations);
    }

    // get count of annotations for given reference from cache first
    // note: skip annotation counts for pipeline references, because the counts could be in millions
    //       causing a strain on database when called too often (f.e. web spiders)
    Integer refCount = null;
    if( ref!=null && !ref.getReferenceType().equals("DIRECT DATA TRANSFER")) {
        refCount = annotCountByRefRgdIdMap.get(obj.getRefRgdId());
        if( refCount==null ) {
            refCount = annotationDAO.getCountOfAnnotationsByReference(obj.getRefRgdId()) - 1;
            annotCountByRefRgdIdMap.put(obj.getRefRgdId(), refCount);
        }
    }

    // get count of references for given object from cache first
    Integer refCountForObj = refCountByObjRgdIdMap.get(obj.getAnnotatedObjectRgdId());
    if( refCountForObj==null ) {
        refCountForObj = referenceDAO.getReferenceCountForObject(obj.getAnnotatedObjectRgdId());
        refCountByObjRgdIdMap.put(obj.getAnnotatedObjectRgdId(), refCountForObj);
    }
%>

<% if (refCount!=null && refCount > 0) {%>
    <tr><td><li><b><%=refCount%></b> additional annotations were made from <span class="highlight"><a href="<%=Link.ref(ref.getRgdId())%>"><%=ref.getCitation()%></a></span></td></td><td></tr>
<% } %>

<tr><td><li><span class="highlight"><%=countOfAnnotations%></span> <%=RgdContext.getSiteName(request)%> objects have been annotated to <span class="highlight"><a href="/rgdweb/ontology/annot.html?acc_id=<%=obj.getTermAcc()%>"><%=obj.getTerm()%>&nbsp;&nbsp;</a></span>(<%=obj.getTermAcc()%>)</td><td></tr>

    <tr><td><li><b><%=refCountForObj%></b> papers in <%=RgdContext.getSiteName(request)%> have been used to annotate <span class="highlight"><a href="<%=Link.it(obj.getAnnotatedObjectRgdId())%>"><%=obj.getObjectSymbol()%></a></span></td><td></tr>
    <%
        if (obj.getQualifier() != null) { %>
        <tr><td><li>Qualifier: <%=obj.getQualifier()%></td><td></tr>

    <% } %>

    <%
        if (obj.getNotes() != null) { %>
        <tr><td><li>Curation Notes: <%=obj.getNotes()%></td><td></tr>

    <% } %>

<%
    if( obj.getXrefSource()!=null && obj.getXrefSource().trim().length()>0 ) {

%>
    <tr><td><li>Original References(s):
         <%=AnnotationFormatter.formatXdbUrls(obj.getXrefSource(), obj.getRgdObjectKey())%>
    </td><td></td></tr>
    <% } %>

</table>

<% if (obj.getLastModifiedDate() != null && obj.getLastModifiedBy() != null) { %>
    <br>This annotation was curated on <%=obj.getLastModifiedDate()%> by <%=RgdContext.getSiteName(request)%>
    <% if( RgdContext.isCurator() ) { out.print("curator number "+obj.getLastModifiedBy()); } %>.
    For more information <a href="/contact/index.shtml">contact us</a>
<% } %>

<br><br>
<%
   }
%>

<table align="center">
    <tr>
        <td><a style="font-size:20px; font-weight: 700" href="javascript:history.back();">Go Back to source page</a></td>
        <td>&nbsp;</td>
        <td><a href="<%=Link.ontAnnot(termAcc)%>&species=<%=SpeciesType.getCommonName(speciesTypeKey)%>"
               style="font-size:20px; font-weight: 700" >Continue to Ontology report</a></td>
    </tr>
</table>


<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>
