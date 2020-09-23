<%@ include file="sectionHeader.jsp"%>
<%
    String siteName = RgdContext.getSiteName(request);
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
        // split annotations into buckets
        List<Annotation> listClinVar = new ArrayList<>(filteredList.size());
        List<Annotation> listCTD = new ArrayList<>(filteredList.size());
        List<Annotation> listOmim = new ArrayList<>(filteredList.size());
        List<Annotation> listGAD = new ArrayList<>(filteredList.size());
        List<Annotation> listManual = new ArrayList<>(filteredList.size());
        List<Annotation> listMGI = new ArrayList<>();
        List<Annotation> listOmia = new ArrayList<>();

        for( Annotation ax: filteredList ) {
            switch(ax.getDataSrc()) {
                case "ClinVar": listClinVar.add(ax); break;
                case "CTD": listCTD.add(ax); break;
                case "OMIA": listOmia.add(ax); break;
                case "OMIM": listOmim.add(ax); break;
                case "GAD": listGAD.add(ax); break;
                case "MouseDO": listMGI.add(ax); break;
                default: listManual.add(ax); break;
            }
        }
%>
<%//ui.dynOpen("diseaseAsscociationC", "Disease Annotations")%>
<% if( !listManual.isEmpty() ) { %>


<div class="reportTable" id="manualAnnotationsTableWrapper">
    <div class="sectionHeading" id="manualAnnotations"><h4><%=siteName%> Manual Annotations</h4></div>
    <div class="modelsViewContent" >
        <div class="pager manualAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <div id="manualAnnotationsTableDiv">
        <%=af.createGridFormatAnnotationsTable(listManual, siteName)%>
    </div>

    <div class="modelsViewContent" >
        <div class="pager manualAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>


</div>
<% } if( !listClinVar.isEmpty() ) { %>


    <div class="reportTable" id="importedAnnotationsClinVarTableWrapper">
        <div class="sectionHeading" id="importedAnnotationsClinVar"><h4>Imported Annotations - ClinVar </h4></div>
        <div class="modelsViewContent" >
            <div class="pager importedAnnotationsClinVarPager" >
                <form>
                    <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                    <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                    <span type="text" class="pagedisplay"></span>
                    <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                    <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                    <select class="pagesize">
                        <option selected="selected" value="10">10</option>
                        <option value="20">20</option>
                        <option value="30">30</option>
                        <option  value="40">40</option>
                        <option   value="100">100</option>
                        <option value="9999">All Rows</option>
                    </select>
                </form>
            </div>
        </div>
        <div id="importedAnnotationsClinVarTableDiv">
            <%=af.createGridFormatAnnotationsTable(listClinVar, siteName)%>
        </div>
        <div class="modelsViewContent" >
            <div class="pager importedAnnotationsClinVarPager" >
                <form>
                    <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                    <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                    <span type="text" class="pagedisplay"></span>
                    <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                    <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                    <select class="pagesize">
                        <option selected="selected" value="10">10</option>
                        <option value="20">20</option>
                        <option value="30">30</option>
                        <option  value="40">40</option>
                        <option   value="100">100</option>
                        <option value="9999">All Rows</option>
                    </select>
                </form>
            </div>
        </div>

    </div>

<% } if( !listCTD.isEmpty() ) { %>
<div class="reportTable" id="importedAnnotationsCTDTableWrapper">
<div class="sectionHeading" id="importedAnnotationsCTD"><h4>Imported Annotations - CTD </h4></div>
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsCTDPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <div id="importedAnnotationsCTDTableDiv">
  <%=af.createGridFormatAnnotationsTable(listCTD, siteName)%>
    </div>

    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsCTDPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

</div>
<% } if( !listGAD.isEmpty() ) { %>
<div class="reportTable" id="importedAnnotationsGADTableWrapper">
<div class="sectionHeading" id="importedAnnotationsGAD"><h4>Imported Annotations - GAD </h4></div>
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsGADPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <div id="importedAnnotationsGADTableDiv">
        <%=af.createGridFormatAnnotationsTable(listGAD, siteName)%>
    </div>

    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsGADPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>
<% } if( !listMGI.isEmpty() ) { %>
<div class="reportTable" id="importedAnnotationsMGITableWrapper">
<div class="sectionHeading" id="importedAnnotationsMGI"><h4>Imported Annotations - MGI </h4></div>

    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsMGIPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <div id="importedAnnotationsMGITableDiv">
  <%=af.createGridFormatAnnotationsTable(listMGI, siteName)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsMGIPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

</div>
<% } if( !listOmia.isEmpty() ) { %>
<div class="reportTable" id="importedAnnotationsOMIATableWrapper">
<div class="sectionHeading" id="importedAnnotationsOMIA"><h4>Imported Annotations - OMIA </h4></div>

    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsOMIAPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <div id="importedAnnotationsOMIATableDiv">
        <%=af.createGridFormatAnnotationsTable(listOmia, siteName)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsOMIAPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

</div>
<% } if( !listOmim.isEmpty() ) { %>
<div class="reportTable" id="importedAnnotationsOMIMTableWrapper">
<div class="sectionHeading" id="importedAnnotationsOMIM"><h4>Imported Annotations - OMIM </h4></div>
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsOMIMPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <div id="importedAnnotationsOMIMTableDiv">
        <%=af.createGridFormatAnnotationsTable(listOmim, siteName)%>
    </div>

    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsOMIMPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>


</div>
<% } %>
<br>
<%//ui.dynClose("diseaseAsscociationC")%>
<% } %>


<%
    filteredList = af.filterList(annotList, "E");
    if (filteredList.size() > 0) {
%>
<%//ui.dynOpen("chemiAssociationC", "Gene-Chemical Interaction Annotations")%>
<div class="reportTable" id="geneChemicalInteractionAnnotationsTableWrapper">
<div class="sectionHeading" id="geneChemicalInteractionAnnotations"><h4>Gene-Chemical Interaction Annotations</h4></div>

    <div class="modelsViewContent" >
        <div class="pager geneChemicalInteractionAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <div id="geneChemicalInteractionAnnotationsTableDiv">
        <%=af.createGridFormatAnnotationsTable(filteredList, siteName)%><br>
    </div>

    <div class="modelsViewContent" >
        <div class="pager geneChemicalInteractionAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>


</div>
<%//ui.dynClose("chemiAssociationC")%>
<% } %>


<%
    List<Annotation> bpList = af.filterList(annotList,"P");
    List<Annotation> ccList = af.filterList(annotList,"C");
    List<Annotation> mfList = af.filterList(annotList,"F");
    if ((bpList.size() + ccList.size() + mfList.size()) > 0 ) {
%>

<%//ui.dynOpen("goAsscociationC", "Gene Ontology Annotations")%>
<div class="sectionHeading" id="geneOntologyAnnotationsCurator"><h4>Gene Ontology Annotations</h4></div>
<% if (bpList.size() > 0) { %>
<div class="reportTable" id="biologicalProcessAnnotationsTableWrapper">
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Biological Process</u></span><br></span>

    <div class="modelsViewContent" >
        <div class="pager biologicalProcessAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <div id="biologicalProcessAnnotationsTableDiv">
       <%=af.createGridFormatAnnotationsTable(bpList, siteName)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager biologicalProcessAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>
<% } %>
<% if (ccList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Cellular Component</u></span><br></span>
       <%=af.createGridFormatAnnotationsTable(ccList, siteName)%>
<% } %>
<% if (mfList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Molecular Function</u></span><br></span>
       <%=af.createGridFormatAnnotationsTable(mfList, siteName)%>
<% } %>

<br>
<%//ui.dynClose("goAsscociationC")%>
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
<%//ui.dynOpen("pathwayAssociationC", "Molecular Pathway Annotations")%>
<div class="sectionHeading" id="molecularPathwayAnnotationsCurator"><h4>Molecular Pathway Annotations</h4></div>
<% if( !listManual.isEmpty() ) { %>
    <h4><%=siteName%> Manual Annotations</h4>
    <%=af.createGridFormatAnnotationsTable(listManual, siteName)%>
    <% } if( !listImportedSMPDB.isEmpty() ) { %>
    <h4>Imported Annotations - SMPDB</h4>
    <%=af.createGridFormatAnnotationsTable(listImportedSMPDB, siteName)%>
    <% } if( !listImportedKEGG.isEmpty() ) { %>
    <h4>Imported Annotations - KEGG (archival)</h4>
    <%=af.createGridFormatAnnotationsTable(listImportedKEGG, siteName)%>
    <% } if( !listImportedPID.isEmpty() ) { %>
    <h4>Imported Annotations - PID (archival)</h4>
    <%=af.createGridFormatAnnotationsTable(listImportedPID, siteName)%>
    <% } if( !listImported.isEmpty() ) { %>
    <h4>Imported Annotations - Other</h4>
    <%=af.createGridFormatAnnotationsTable(listImported, siteName)%>
    <% }

    if( xdbKeggPathways.size()>0 ) { %>
    <%@ include file="xdbs_pathways.jsp"%>
    <% } %>
<%//ui.dynClose("pathwayAssociationC")%>
<% } %>

<%
    List<Annotation> mpList = af.filterList(annotList,"N");
    List<Annotation> hpList = af.filterList(annotList,"H");
    if (mpList.size()+hpList.size() > 0) {
%>
<%//ui.dynOpen("phenoAssociationC", "Phenotype Annotations")%>
<div class="sectionHeading" id="phenotypeAnnotations"><h4>Phenotype Annotations</h4></div>
<% if (mpList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Mammalian Phenotype</u></span><br></span>
       <%=af.createGridFormatAnnotationsTable(mpList, siteName)%>
<% } %>
<% if (hpList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Human Phenotype</u></span><br></span>
       <%=af.createGridFormatAnnotationsTable(hpList, siteName)%>
<% } %>

<%//ui.dynClose("phenoAssociationC")%>
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

<%//ui.dynOpen("expAssociationC", "Experimental Data Annotations")%>
<div class="sectionHeading" id="experimentalDataAnnotations"><h4>Experimental Data Annotations</h4></div>

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
           <%=af.createGridFormatAnnotationsTable(clList, siteName)%>
    <% } %>
    <% if (cmoList.size() > 0) { %>
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Clinical Measurement</u></span><br></span>
           <%=af.createGridFormatAnnotationsTable(cmoList, siteName)%>
    <% } %>
    <% if (xcoList.size() > 0) { %>
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Experimental Condition</u></span><br></span>
           <%=af.createGridFormatAnnotationsTable(xcoList, siteName)%>
    <% } %>
    <% if (mmoList.size() > 0) { %>
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Measurement Method</u></span><br></span>
           <%=af.createGridFormatAnnotationsTable(mmoList, siteName)%>
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
<%//ui.dynClose("expAssociationC")%>
<% } %>

<%@ include file="sectionFooter.jsp"%>
