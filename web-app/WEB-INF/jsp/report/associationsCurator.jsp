<%@ include file="sectionHeader.jsp"%>
<%
    AnnotationFormatter af = new AnnotationFormatter();
    List<Annotation> annotList = annotationDAO.getAnnotations(obj.getRgdId());
    int isReferenceRgd=0;

    if (annotList.isEmpty()) {
        annotList = annotationDAO.getAnnotationsByReference(obj.getRgdId());
        if(annotList.size()>0){
            isReferenceRgd=1;
        }
    }
    boolean hasPhenoMinerAnn = (annotationDAO.getPhenoAnnotationsCountByReference(obj.getRgdId())>0);

    List<Annotation> filteredList = af.filterList(annotList, "D");
    if (filteredList.size() > 0) {
        // split annotations into 5 buckets
        List<Annotation> listClinVar = new ArrayList<>(filteredList.size());
        List<Annotation> listCTD = new ArrayList<>(filteredList.size());
        List<Annotation> listOmim = new ArrayList<>(filteredList.size());
        List<Annotation> listGAD = new ArrayList<>(filteredList.size());
        List<Annotation> listManual = new ArrayList<>(filteredList.size());
        List<Annotation> listMGI = new ArrayList<>(filteredList.size());

        for( Annotation ax: filteredList ) {
            switch(ax.getDataSrc()) {
                case "ClinVar": listClinVar.add(ax); break;
                case "CTD": listCTD.add(ax); break;
                case "OMIM": listOmim.add(ax); break;
                case "GAD": listGAD.add(ax); break;
                case "MouseDO": listMGI.add(ax); break;
                default: listManual.add(ax); break;
            }
        }
%>
<%=ui.dynOpen("diseaseAsscociationC", "Disease Annotations")%>
<% if( !listManual.isEmpty() ) { %>
  <h4><%=RgdContext.getSiteName(request)%> Manual Annotations</h4>
  <%=af.createGridFormatAnnotationsTable(listManual,RgdContext.getSiteName(request))%>
<% } if( !listClinVar.isEmpty() ) { %>
  <h4>Imported Annotations - ClinVar </h4>
  <%=af.createGridFormatAnnotationsTable(listClinVar,RgdContext.getSiteName(request))%>
<% } if( !listCTD.isEmpty() ) { %>
  <h4>Imported Annotations - CTD </h4>
  <%=af.createGridFormatAnnotationsTable(listCTD,RgdContext.getSiteName(request))%>
<% } if( !listGAD.isEmpty() ) { %>
  <h4>Imported Annotations - Genetic Association Database </h4>
  <%=af.createGridFormatAnnotationsTable(listGAD,RgdContext.getSiteName(request))%>
<% } if( !listMGI.isEmpty() ) { %>
  <h4>Imported Annotations - MGI </h4>
  <%=af.createGridFormatAnnotationsTable(listMGI,RgdContext.getSiteName(request))%>
<% } if( !listOmim.isEmpty() ) { %>
  <h4>Imported Annotations - OMIM </h4>
  <%=af.createGridFormatAnnotationsTable(listOmim,RgdContext.getSiteName(request))%>
<% } %>
<br>
<%=ui.dynClose("diseaseAsscociationC")%>
<% } %>


<%
    filteredList = af.filterList(annotList, "E");
    if (filteredList.size() > 0) {
%>
<%=ui.dynOpen("chemiAssociationC", "Gene-Chemical Interaction Annotations")%>
    <%=af.createGridFormatAnnotationsTable(filteredList,RgdContext.getSiteName(request))%><br>
<%=ui.dynClose("chemiAssociationC")%>
<% } %>


<%
    List<Annotation> bpList = af.filterList(annotList,"P");
    List<Annotation> ccList = af.filterList(annotList,"C");
    List<Annotation> mfList = af.filterList(annotList,"F");
    if ((bpList.size() + ccList.size() + mfList.size()) > 0 ) {
%>

<%=ui.dynOpen("goAsscociationC", "Gene Ontology Annotations")%>

<% if (bpList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Biological Process</u></span><br></span>
       <%=af.createGridFormatAnnotationsTable(bpList,RgdContext.getSiteName(request))%>
<% } %>
<% if (ccList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Cellular Component</u></span><br></span>
       <%=af.createGridFormatAnnotationsTable(ccList,RgdContext.getSiteName(request))%>
<% } %>
<% if (mfList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Molecular Function</u></span><br></span>
       <%=af.createGridFormatAnnotationsTable(mfList,RgdContext.getSiteName(request))%>
<% } %>

<br>
<%=ui.dynClose("goAsscociationC")%>
<% } %>

<%
    List<XdbId> xdbKeggPathways = xdbDAO.getXdbIdsByRgdId(XdbId.XDB_KEY_KEGGPATHWAY, obj.getRgdId());

    filteredList = af.filterList(annotList, "W");
    if(!filteredList.isEmpty() || xdbKeggPathways.size()>0) {
        // split annotations into buckets
        List<Annotation> listManual = new ArrayList<Annotation>(filteredList.size());
        List<Annotation> listImportedPID = new ArrayList<Annotation>(filteredList.size());
        List<Annotation> listImportedKEGG = new ArrayList<Annotation>(filteredList.size());
        List<Annotation> listImportedSMPDB = new ArrayList<Annotation>(filteredList.size());
        List<Annotation> listImported = new ArrayList<Annotation>(filteredList.size());

        for( Annotation ax: filteredList ) {
            if( Utils.stringsAreEqual(ax.getDataSrc(), "RGD") ) {
                listManual.add(ax);
            } else if( Utils.stringsAreEqual(ax.getDataSrc(), "SMPDB") ) {
                listImportedSMPDB.add(ax);
            } else if( Utils.stringsAreEqual(ax.getDataSrc(), "KEGG") ) {
                listImportedKEGG.add(ax);
            } else if( Utils.stringsAreEqual(ax.getDataSrc(), "PID") ) {
                listImportedPID.add(ax);
            } else {
                listImported.add(ax);
            }
        }
%>
<%=ui.dynOpen("pathwayAssociationC", "Molecular Pathway Annotations")%>

<% if( !listManual.isEmpty() ) { %>
    <h4><%=RgdContext.getSiteName(request)%> Manual Annotations</h4>
    <%=af.createGridFormatAnnotationsTable(listManual, RgdContext.getSiteName(request))%>
    <% } if( !listImportedSMPDB.isEmpty() ) { %>
    <h4>Imported Annotations - SMPDB</h4>
    <%=af.createGridFormatAnnotationsTable(listImportedSMPDB, RgdContext.getSiteName(request))%>
    <% } if( !listImportedKEGG.isEmpty() ) { %>
    <h4>Imported Annotations - KEGG (archival)</h4>
    <%=af.createGridFormatAnnotationsTable(listImportedKEGG, RgdContext.getSiteName(request))%>
    <% } if( !listImportedPID.isEmpty() ) { %>
    <h4>Imported Annotations - PID (archival)</h4>
    <%=af.createGridFormatAnnotationsTable(listImportedPID, RgdContext.getSiteName(request))%>
    <% } if( !listImported.isEmpty() ) { %>
    <h4>Imported Annotations - Other</h4>
    <%=af.createGridFormatAnnotationsTable(listImported, RgdContext.getSiteName(request))%>
    <% }

    if( xdbKeggPathways.size()>0 ) { %>
    <%@ include file="xdbs_pathways.jsp"%>
    <% } %>
<%=ui.dynClose("pathwayAssociationC")%>
<% } %>

<%
    List<Annotation> mpList = af.filterList(annotList,"N");
    List<Annotation> hpList = af.filterList(annotList,"H");
    if (mpList.size()+hpList.size() > 0) {
%>
<%=ui.dynOpen("phenoAssociationC", "Phenotype Annotations")%>

<% if (mpList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Mammalian Phenotype</u></span><br></span>
       <%=af.createGridFormatAnnotationsTable(mpList,RgdContext.getSiteName(request))%>
<% } %>
<% if (hpList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Human Phenotype</u></span><br></span>
       <%=af.createGridFormatAnnotationsTable(hpList,RgdContext.getSiteName(request))%>
<% } %>

<%=ui.dynClose("phenoAssociationC")%>
<% } %>



<%
    List<Annotation> maList = af.filterList(annotList,"A");
    List<Annotation> clList = af.filterList(annotList,"O");
    List<Annotation> vtList = af.filterList(annotList,"V");
    List<Annotation> rsList = af.filterList(annotList,"S");
    List<Annotation> cmoList = af.filterList(annotList,"L");
    List<Annotation> mmoList = af.filterList(annotList,"M");
    List<Annotation> xcoList = af.filterList(annotList,"X");

    int rgdid = phenominerDAO.getNumOfRecords(obj.getRgdId());

    if((( clList.size() + vtList.size() + cmoList.size() + mmoList.size() + xcoList.size() > 0 ) && (isReferenceRgd==0)) ||
            ((isReferenceRgd==1) && (rgdid>0)) || hasPhenoMinerAnn) {
%>

<%=ui.dynOpen("expAssociationC", "Experimental Data Annotations")%>


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
<%
    }else if(isReferenceRgd==0){
       if (clList.size() > 0) { %>
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Cell Ontology</u></span><br></span>
           <%=af.createGridFormatAnnotationsTable(clList,RgdContext.getSiteName(request))%>
    <% } %>
    <% if (cmoList.size() > 0) { %>
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Clinical Measurement</u></span><br></span>
           <%=af.createGridFormatAnnotationsTable(cmoList,RgdContext.getSiteName(request))%>
    <% } %>
    <% if (xcoList.size() > 0) { %>
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Experimental Condition</u></span><br></span>
           <%=af.createGridFormatAnnotationsTable(xcoList,RgdContext.getSiteName(request))%>
    <% } %>
    <% if (mmoList.size() > 0) { %>
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Measurement Method</u></span><br></span>
           <%=af.createGridFormatAnnotationsTable(mmoList,RgdContext.getSiteName(request))%>
    <% } %>
    <% if (maList.size() > 0) { %>
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Mouse Anatomy</u></span><br></span>
           <%=af.createGridFormatAnnotationsTable(maList)%>
    <% } %>
    <% if (rsList.size() > 0) { %>
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Rat Strain</u></span><br></span>
           <%=af.createGridFormatAnnotationsTable(rsList)%>
    <% } %>
    <% if (vtList.size() > 0) { %>
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Vertebrate Trait</u></span><br></span>
           <%=af.createGridFormatAnnotationsTable(vtList)%>
    <% }
    }
    %>

<br>
<%=ui.dynClose("expAssociationC")%>
<% } %>


<%@ include file="sectionFooter.jsp"%>
