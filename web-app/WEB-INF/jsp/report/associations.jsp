<%@ page import="edu.mcw.rgd.web.HeatMap" %>
<%@ include file="sectionHeader.jsp"%>
<script type="text/javascript" src="/rgdweb/js/sorttable.js" >
</script>
<%

    AnnotationFormatter af = new AnnotationFormatter();
    List<Annotation> annotList = annotationDAO.getAnnotations(obj.getRgdId());
    int isReferenceRgd=0;

    if (annotList.size() == 0) {
        annotList = annotationDAO.getAnnotationsByReference(obj.getRgdId());
        if(annotList.size()>0){
            isReferenceRgd=1;
        }
    }
    boolean hasPhenoMinerAnn = (annotationDAO.getPhenoAnnotationsCountByReference(obj.getRgdId())>0);

    // sort annotations by TERM, then by EVIDENCE code
    // to enable createGridFormatAnnotations() to group evidence codes properly
    Collections.sort(annotList, new Comparator<Annotation>() {

        public int compare(Annotation o1, Annotation o2) {

            int result = Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            if( result!=0 )
                return result;
            return o1.getEvidence().compareTo(o2.getEvidence());
        }
    });
%>


<%
    List<Annotation> filteredList = af.filterList(annotList, "D");
    if (filteredList.size() > 0) {
%>
<%=ui.dynOpen("diseaseAsscociation", "Disease Annotations")%>
 <%=af.createGridFormatAnnotations(filteredList, obj.getRgdId(),3)%>
<br>
<%=ui.dynClose("diseaseAsscociation")%>
<% } %>


<%
    filteredList = af.filterList(annotList, "E");
    if (filteredList.size() > 0) {
%>
<%=ui.dynOpen("chemiAssociation", "Gene-Chemical Interaction Annotations")%>
    <%=af.createGridFormatAnnotations(filteredList, obj.getRgdId(),3)%><br>
<%=ui.dynClose("chemiAssociation")%>
<% } %>


<%
    List<Annotation> bpList = af.filterList(annotList,"P");
    List<Annotation> ccList = af.filterList(annotList,"C");
    List<Annotation> mfList = af.filterList(annotList,"F");
    if ((bpList.size() + ccList.size() + mfList.size()) > 0 ) {
%>

<%=ui.dynOpen("goAsscociation", "Gene Ontology Annotations")%>    

<% if (bpList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Biological Process</u></span><br></span>
       <%=af.createGridFormatAnnotations(bpList, obj.getRgdId(),2)%>
<% } %>
<% if (ccList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Cellular Component</u></span><br></span>
       <%=af.createGridFormatAnnotations(ccList, obj.getRgdId(),3)%>
<% } %>
<% if (mfList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Molecular Function</u></span><br></span>
       <%=af.createGridFormatAnnotations(mfList, obj.getRgdId(),3)%>
<% } %>

<br>
<%=ui.dynClose("goAsscociation")%>
<% } %>



<%
    List<XdbId> xdbKeggPathways = xdbDAO.getXdbIdsByRgdId(XdbId.XDB_KEY_KEGGPATHWAY, obj.getRgdId());

    filteredList = af.filterList(annotList, "W");
    if(!filteredList.isEmpty() || xdbKeggPathways.size()>0) {
%>
<%=ui.dynOpen("pathwayAssociation", "Molecular Pathway Annotations")%>
      <% if( !filteredList.isEmpty() ) { %>
      <%=af.createGridFormatAnnotations(filteredList, obj.getRgdId(),2)%><br>
      <% }
      if( xdbKeggPathways.size()>0 ) { %>
      <%@ include file="xdbs_pathways.jsp"%>
      <% } %>
<%=ui.dynClose("pathwayAssociation")%>
<% } %>


<%
    List<Annotation> mpList = af.filterList(annotList,"N");
    List<Annotation> hpList = af.filterList(annotList,"H");
    if (mpList.size()+hpList.size() > 0) {
%>
<%=ui.dynOpen("phenoAssociation", "Phenotype Annotations")%>
<% if (mpList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Mammalian Phenotype</u></span><br></span>
       <%=af.createGridFormatAnnotations(mpList, obj.getRgdId(),3)%>
<% } %>
<% if (hpList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Human Phenotype</u></span><br></span>
       <%=af.createGridFormatAnnotations(hpList, obj.getRgdId(),3)%>
<% } %>

<%=ui.dynClose("phenoAssociation")%>
<% } %>


<%
    List<Annotation> maList = Collections.emptyList(); // af.filterList(annotList,"A");
    List<Annotation> clList = af.filterList(annotList,"O");
    List<Annotation> vtList = af.filterList(annotList,"V");
    List<Annotation> rsList = af.filterList(annotList,"S");
    List<Annotation> cmoList = af.filterList(annotList,"L");
    List<Annotation> mmoList = af.filterList(annotList,"M");
    List<Annotation> xcoList = af.filterList(annotList,"X");

    int rgdid = phenominerDAO.getNumOfRecords(obj.getRgdId());

    if((( clList.size() + vtList.size() + cmoList.size() + mmoList.size() + xcoList.size() + maList.size() + rsList.size() > 0 ) && (isReferenceRgd==0)) ||
            ((isReferenceRgd==1) && (rgdid>0)) || hasPhenoMinerAnn) {
%>

<%=ui.dynOpen("expAssociation", "Experimental Data Annotations")%>

    <%
    if(hasPhenoMinerAnn){
        String phenoMinerUrl = "/rgdweb/phenominer/table.html?refRgdId=";
    %>
        <table>
        <tr>
            <td><img src='/rgdweb/common/images/bullet_green.png'/></td>
            <td><a href="<%=phenoMinerUrl+obj.getRgdId()%>">View experimental data from this reference here</a><span style="font-size:10px;">&nbsp;</span></td>
        </tr>
        <br />
        </table>
<%  }else if(isReferenceRgd==0){
        if (clList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Cell Ontology</u></span><br></span>
       <%=af.createGridFormatAnnotations(clList, obj.getRgdId(),2)%>
<% } %>
<% if (cmoList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Clinical Measurement</u></span><br></span>
       <%=af.createGridFormatAnnotations(cmoList, obj.getRgdId(),2)%>
<% } %>
<% if (xcoList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Experimental Condition</u></span><br></span>
       <%=af.createGridFormatAnnotations(xcoList, obj.getRgdId(),2)%>
<% } %>
<% if (mmoList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Measurement Method</u></span><br></span>
       <%=af.createGridFormatAnnotations(mmoList, obj.getRgdId(),2)%>
<% } %>
<% if (rsList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Rat Strain</u></span><br></span>
       <%=af.createGridFormatAnnotations(rsList, obj.getRgdId(),2)%>
<% } %>
<%-- if (maList.size() + rsList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>GEO Annotations</u></span><br></span>
       <% HeatMap hm = af.createGeoAnnotationsGrid(maList, rsList);%>
<%@ include file="/common/heatmap.jsp"%>
       <%=af.createGeoAnnotationsTable(maList, rsList)%>
<% } --%>
<% if (vtList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Vertebrate Trait</u></span><br></span>
       <%=af.createGridFormatAnnotations(vtList, obj.getRgdId(),2)%>
    <% }
    }
    %>

<br>
<%=ui.dynClose("expAssociation")%>
<% } %>



<%@ include file="sectionFooter.jsp"%>
