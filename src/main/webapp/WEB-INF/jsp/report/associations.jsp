<%@ page import="edu.mcw.rgd.web.HeatMap" %>
<%@ include file="sectionHeader.jsp"%>
<script type="text/javascript" src="/rgdweb/js/sorttable.js" >
</script>

<%

    AnnotationFormatter af = new AnnotationFormatter();
    int oType=managementDAO.getRgdId(obj.getRgdId()).getObjectKey();
    List<Annotation> annotList=null;
    boolean hasPhenoMinerAnn=false;
    int isReferenceRgd = 0;
    if(oType==14){
         annotList = annotationDAO.getAnnotationsForProject(obj.getRgdId());
         isReferenceRgd=0;

        if (annotList.size() == 0) {
            annotList = annotationDAO.getAnnotationsByReferenceForProject(obj.getRgdId());
            if(annotList.size()>0){
                isReferenceRgd=1;
            }
        }
        hasPhenoMinerAnn = (annotationDAO.getPhenoAnnotationsCountByReferenceForProject(obj.getRgdId())>0);
    }
    else{
        annotList = annotationDAO.getAnnotations(obj.getRgdId());
        isReferenceRgd=0;

        if (annotList.size() == 0) {
            annotList = annotationDAO.getAnnotationsByReference(obj.getRgdId());
            if(annotList.size()>0){
                isReferenceRgd=1;
            }
        }
        hasPhenoMinerAnn = (annotationDAO.getPhenoAnnotationsCountByReference(obj.getRgdId())>0);
    }


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
    <div class="sectionHeading" id="diseaseAnnotations">Disease Annotations&nbsp;&nbsp;&nbsp;&nbsp;
<%--        <%if(!title.equalsIgnoreCase("references")) { %>--%>
            <a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('manualAnnotationsTableWrapper', 'diseaseAnnotationsTableWrapper');">Click to see Annotation Detail View</a>
<%--        <%}%>--%>
    </div>

<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize" >
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option selected="selected"  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

    <input class="search table-search" type="search" data-column="0-2" placeholder="Search table">

</div>
    <div id="diseaseAnnotationsTable">
<%=af.createGridFormatAnnotations(filteredList, obj.getRgdId(),3)%>
</div>
<br>
<%//ui.dynClose("diseaseAsscociation")%>


    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize" >
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option  value="30">30</option>
                    <option selected="selected" value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>
<% } %>


<%
    filteredList = af.filterList(annotList, "E");
    if (filteredList.size() > 0) {
%>
<%//ui.dynOpen("chemiAssociation", "Gene-Chemical Interaction Annotations")%>

<div class="reportTable light-table-border" id="geneChemicalInteractionTableWrapper">
    <div class="sectionHeading" id="geneChemicalInteraction">Gene-Chemical Interaction Annotations&nbsp;&nbsp;&nbsp;&nbsp;
        <%if(!title.equalsIgnoreCase("references")) { %>
            <a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('geneChemicalInteractionDetailsTableWrapper', 'geneChemicalInteractionTableWrapper');">Click to see Annotation Detail View</a>
        <%}%>
    </div>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form autocomplete="off">
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

    <input class="search table-search" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="geneChemicalInteractionTable">
<%=af.createGridFormatAnnotations(filteredList, obj.getRgdId(),3)%><br>
    </div>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form autocomplete="off">
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>
<%//ui.dynClose("chemiAssociation")%>
<% } %>





<%
    List<Annotation> bpList = af.filterList(annotList,"P");
    List<Annotation> ccList = af.filterList(annotList,"C");
    List<Annotation> mfList = af.filterList(annotList,"F");
    if ((bpList.size() + ccList.size() + mfList.size()) > 0 ) {
%>

<%//ui.dynOpen("goAsscociation", "Gene Ontology Annotations")%>
<div class = "light-table-border reportTable">
<div class="sectionHeading" id="geneOntologyAnnotations">Gene Ontology Annotations&nbsp;&nbsp;&nbsp;&nbsp;
    <%if(!title.equalsIgnoreCase("references")) { %>
    <a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('geneOntologyAnnotationsCurator', 'geneOntologyAnnotations');">Click to see Annotation Detail View</a>
    <%}%>
</div>
<% if (bpList.size() > 0) { %>


<div id="biologicalProcessAnnotationsTableWrapper">


    <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Biological Process</u></span><br></span>

    <div class="search-and-pager">


    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>



        <input class="search table-search" type="search" data-column="all" placeholder="Search table">

    </div>

    <div id="biologicalProcessAnnotationsTable">
<%=af.createGridFormatAnnotations(bpList, obj.getRgdId(),3)%>
    </div>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
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

<div id="cellularComponentAnnotationsTableWrapper">
    <span style="border-bottom: 0 solid gray"><br><span class="highlight" id="cellularComponentSummary"><u>Cellular Component</u></span><br></span>

<div class="search-and-pager">

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

    <input class="search table-search" type="search" data-column="all" placeholder="Search table">

</div>
    <div id="cellularComponentAnnotationsTable">
<%=af.createGridFormatAnnotations(ccList, obj.getRgdId(),3)%>
    </div>


    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>
<% } %>
<% if (mfList.size() > 0) { %>

<div id="molecularFunctionAnnotationsTableWrapper">
    <span style="border-bottom: 0 solid gray"><br><span class="highlight" id="molecularFunctionSummary"><u>Molecular Function</u></span><br></span>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  selected="selected">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

    <input class="search table-search" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="molecularFunctionAnnotationsTable">
<%=af.createGridFormatAnnotations(mfList, obj.getRgdId(),3)%>
        </div>


    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option   selected="selected" value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>
<% } %>
<br>
<%//ui.dynClose("goAsscociation")%>
</div>
<% } %>



<%
    List<XdbId> xdbKeggPathways = xdbDAO.getXdbIdsByRgdId(XdbId.XDB_KEY_KEGGPATHWAY, obj.getRgdId());

    filteredList = af.filterList(annotList, "W");
    if(!filteredList.isEmpty() || xdbKeggPathways.size()>0) {
%>
<%//ui.dynOpen("pathwayAssociation", "Molecular Pathway Annotations")%>

<div class="reportTable light-table-border" id="molecularPathwayAnnotationsTableWrapper">
    <div class="sectionHeading" id="molecularPathwayAnnotations">Molecular Pathway Annotations&nbsp;&nbsp;&nbsp;&nbsp;
        <%if(!title.equalsIgnoreCase("references")) { %>
            <a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('molecularPathwayAnnotationsDetail', 'molecularPathwayAnnotationsTableWrapper');">Click to see Annotation Detail View</a>
        <%}%>
    </div>

<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

    <input class="search table-search" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="molecularPathwayAnnotationsTable">
<% if( !filteredList.isEmpty() ) { %>
<%=af.createGridFormatAnnotations(filteredList, obj.getRgdId(),3)%><br>
<% }
    if( xdbKeggPathways.size()>0 ) { %>
<%@ include file="xdbs_pathways.jsp"%>
<% } %>
<%//ui.dynClose("pathwayAssociation")%>

        </div>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>

<% } %>

<%
    List<Annotation> mpList = af.filterList(annotList,"N");
    List<Annotation> hpList = af.filterList(annotList,"H");
    if (mpList.size()+hpList.size() > 0) {
%>
<%//ui.dynOpen("phenoAssociation", "Phenotype Annotations")%>
<div class="light-table-border reportTable">
    <div class="sectionHeading" id="phenotypeAnnotations">Phenotype Annotations&nbsp;&nbsp;&nbsp;&nbsp;
        <%if(!title.equalsIgnoreCase("references")) { %>
            <a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('phenotypeAnnotationsCurator', 'phenotypeAnnotations');">Click to see Annotation Detail View</a>
        <%}%>
    </div>
<% if (mpList.size() > 0) { %>
<div id="mammalianPhenotypeAnnotationsTableWrapper">
    <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Mammalian Phenotype</u></span><br></span>

<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

    <input class="search table-search" type="search" data-column="all" placeholder="Search table">

</div>
    <div id="mammalianPhenotypeAnnotationsTable">
<%=af.createGridFormatAnnotations(mpList, obj.getRgdId(),3)%>

    </div>
        <div class="modelsViewContent" >
            <div class="pager annotationPagerClass" style="margin-bottom:2px;">
                <form>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                    <span type="text" class="pagedisplay"></span>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                    <select class="pagesize">
                        <option  value="10">10</option>
                        <option value="20">20</option>
                        <option selected="selected" value="30">30</option>
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
<div id="humanPhenotypeAnnotationsTableWrapper">
<span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Human Phenotype</u></span><br></span>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

    <input class="search table-search" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="humanPhenotypeAnnotationsTable">
<%=af.createGridFormatAnnotations(hpList, obj.getRgdId(),3)%>

    </div>

    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
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
</div>
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

<%
    if(!title.equalsIgnoreCase("strains")){
%>

<%//ui.dynOpen("expAssociation", "Experimental Data Annotations")%>
<% if(!title.equalsIgnoreCase("references")&&oType!=14) { %>
<div class="light-table-border">

    <div class="sectionHeading" id="experimentalDataAnnotations">Experimental Data Annotations&nbsp;&nbsp;&nbsp;&nbsp;
        <a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('experimentalDataAnnotationsCurator', 'experimentalDataAnnotations');">Click to see Annotation Detail View</a>

</div><%
    if(hasPhenoMinerAnn ){
        String phenoMinerUrl = "/rgdweb/phenominer/table.html?refRgdId=";
%>

<table>
    <tr>
        <td><a href="<%=phenoMinerUrl+obj.getRgdId()%>">View PhenoMiner data from this reference here</a><span style="font-size:10px;">&nbsp;</span></td>
    </tr>
    <br />
</table>
<%  }else if(isReferenceRgd==0){
    if (clList.size() > 0) { %>

<div class="reportTable" id="cellOntologyAnnotationsTableWrapper">


<span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Cell Ontology</u></span><br></span>

    <div id="cellOntologyAnnotationsTable">
        <%=af.createGridFormatAnnotations(clList, obj.getRgdId(),2)%>
    </div>
</div>
<% } %>
<% if (cmoList.size() > 0) { %>
<div class="reportTable" id="clinicalMeasurementAnnotationsTableWrapper">
<span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Clinical Measurement</u></span><br></span>

    <div id="clinicalMeasurementAnnotationsTable">
        <%=af.createGridFormatAnnotations(cmoList, obj.getRgdId(),2)%>
    </div>

</div>
<% } %>
<% if (xcoList.size() > 0) {  %>

<div class="reportTable " id="experimentalConditionAnnotationsTableWrapper">
<span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Experimental Condition</u></span><br></span>

    <div id="experimentalConditionAnnotationsTable">
        <%=af.createGridFormatAnnotations(xcoList, obj.getRgdId(),2)%>
    </div>
</div>

<% } %>
<% if (mmoList.size() > 0) { %>
<div class="reportTable" id="measurementMethodAnnotationsTableWrapper">
<span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Measurement Method</u></span><br></span>
    <div id="measurementMethodAnnotationsTable">
        <%=af.createGridFormatAnnotations(mmoList, obj.getRgdId(),2)%>
    </div>
</div>

<% } %>
<% if (vtList.size() > 0) { %>
<div class="reportTable" id="vertebrateTraitAnnotationsTableWrapper">
    <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Vertebrate Trait</u></span><br></span>

    <div id="vertebrateTraitAnnotationsTable">
        <%=af.createGridFormatAnnotations(vtList, obj.getRgdId(),2)%>
    </div>
</div>
<% } %>

<% if (rsList.size() > 0) { %>
<div class="reportTable" id="ratStrainAnnotationsTableWrapper">
<span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Rat Strain</u></span><br></span>

<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

    <input class="search table-search" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="ratStrainAnnotationsTable">
        <%=af.createGridFormatAnnotations(rsList, obj.getRgdId(),2)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager annotationPagerClass" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option selected="selected" value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>
<% } %>
<%}%>
</div><%}%>
<%-- if (maList.size() + rsList.size() > 0) { %>
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>GEO Annotations</u></span><br></span>
       <% HeatMap hm = af.createGeoAnnotationsGrid(maList, rsList);%>
<%@ include file="/common/heatmap.jsp"%>
       <%=af.createGeoAnnotationsTable(maList, rsList)%>
<% } --%>

<% } %>

<br>
<%//ui.dynClose("expAssociation")%>
<% } %>



<%@ include file="sectionFooter.jsp"%>
