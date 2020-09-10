<%@ page import="edu.mcw.rgd.web.HeatMap" %>
<%@ include file="sectionHeader.jsp"%>
<script type="text/javascript" src="/rgdweb/js/sorttable.js" >
</script>
<style>
    .reportTable{
        display: flex;
        overflow-x: auto;
        flex-flow: column wrap;
    }
</style>
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
<%//ui.dynOpen("diseaseAsscociation", "Disease Annotations")%>


<div class="reportTable light-table-border" id="diseaseAnnotationsTableWrapper">
    <div class="sectionHeading" id="diseaseAnnotations">Disease Annotations</div>
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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
<div id="diseaseAnnotationsTable">
<%=af.createGridFormatAnnotations(filteredList, obj.getRgdId(),3)%>
</div>
<br>
<%//ui.dynClose("diseaseAsscociation")%>
<% } %>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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



<%
    filteredList = af.filterList(annotList, "E");
    if (filteredList.size() > 0) {
%>
<%//ui.dynOpen("chemiAssociation", "Gene-Chemical Interaction Annotations")%>

<div class="reportTable light-table-border" id="geneChemicalInteractionTableWrapper">
    <div class="sectionHeading" id="geneChemicalInteraction">Gene-Chemical Interaction Annotations</div>
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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

    <div id="geneChemicalInteractionTable">
<%=af.createGridFormatAnnotations(filteredList, obj.getRgdId(),3)%><br>
    </div>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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
<%//ui.dynClose("chemiAssociation")%>
<% } %>
</div>




<%
    List<Annotation> bpList = af.filterList(annotList,"P");
    List<Annotation> ccList = af.filterList(annotList,"C");
    List<Annotation> mfList = af.filterList(annotList,"F");
    if ((bpList.size() + ccList.size() + mfList.size()) > 0 ) {
%>

<%//ui.dynOpen("goAsscociation", "Gene Ontology Annotations")%>

<% if (bpList.size() > 0) { %>
<div class="sectionHeading" id="geneOntologyAnnotations">Gene Ontology Annotations</div>

<div class="reportTable light-table-border" id="biologicalProcessAnnotationsTableWrapper">
    <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Biological Process</u></span><br></span>
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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
    <div id="biologicalProcessAnnotationsTable">
<%=af.createGridFormatAnnotations(bpList, obj.getRgdId(),3)%>
    </div>
<% } %>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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
<% if (ccList.size() > 0) { %>

<div class="reportTable light-table-border" id="cellularComponentAnnotationsTableWrapper">
    <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Cellular Component</u></span><br></span>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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
    <div id="cellularComponentAnnotationsTable">
<%=af.createGridFormatAnnotations(ccList, obj.getRgdId(),3)%>
    </div>
<% } %>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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
<% if (mfList.size() > 0) { %>

<div class="reportTable light-table-border" id="molecularFunctionAnnotationsTableWrapper">
    <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Molecular Function</u></span><br></span>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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
    <div id="molecularFunctionAnnotationsTable">
<%=af.createGridFormatAnnotations(mfList, obj.getRgdId(),3)%>
        </div>
<% } %>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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
<br>
<%//ui.dynClose("goAsscociation")%>
<% } %>



<%
    List<XdbId> xdbKeggPathways = xdbDAO.getXdbIdsByRgdId(XdbId.XDB_KEY_KEGGPATHWAY, obj.getRgdId());

    filteredList = af.filterList(annotList, "W");
    if(!filteredList.isEmpty() || xdbKeggPathways.size()>0) {
%>
<%//ui.dynOpen("pathwayAssociation", "Molecular Pathway Annotations")%>

<div class="reportTable light-table-border" id="molecularPathwayAnnotationsTableWrapper">
    <div class="sectionHeading" id="molecularPathwayAnnotations">Molecular Pathway Annotations</div>
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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

    <div id="molecularPathwayAnnotationsTable">
<% if( !filteredList.isEmpty() ) { %>
<%=af.createGridFormatAnnotations(filteredList, obj.getRgdId(),3)%><br>
<% }
    if( xdbKeggPathways.size()>0 ) { %>
<%@ include file="xdbs_pathways.jsp"%>
<% } %>
<%//ui.dynClose("pathwayAssociation")%>
<% } %>
        </div>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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



<%
    List<Annotation> mpList = af.filterList(annotList,"N");
    List<Annotation> hpList = af.filterList(annotList,"H");
    if (mpList.size()+hpList.size() > 0) {
%>
<%//ui.dynOpen("phenoAssociation", "Phenotype Annotations")%>
    <div class="sectionHeading" id="phenotypeAnnotations">Phenotype Annotations</div>

<% if (mpList.size() > 0) { %>
<div class="reportTable light-table-border" id="mammalianPhenotypeAnnotationsTableWrapper">
    <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Mammalian Phenotype</u></span><br></span>
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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
    <div id="mammalianPhenotypeAnnotationsTable">
<%=af.createGridFormatAnnotations(mpList, obj.getRgdId(),3)%>

    </div>
        <div class="modelsViewContent" >
            <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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


<% if (hpList.size() > 0) { %>
<div class="reportTable light-table-border" id="humanPhenotypeAnnotationsTableWrapper">
<span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Human Phenotype</u></span><br></span>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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
    <div id="humanPhenotypeAnnotationsTable">
<%=af.createGridFormatAnnotations(hpList, obj.getRgdId(),3)%>

    </div>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
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

<%//ui.dynClose("phenoAssociation")%>
<% } %>
</div>

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



<%//ui.dynOpen("expAssociation", "Experimental Data Annotations")%>
<div class="sectionHeading" id="experimentalDataAnnotations">Experimental Data Annotations</div>
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
<%//ui.dynClose("expAssociation")%>
<% } %>



<%@ include file="sectionFooter.jsp"%>
