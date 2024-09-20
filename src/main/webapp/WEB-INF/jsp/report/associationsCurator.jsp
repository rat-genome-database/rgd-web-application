<%@ include file="sectionHeader.jsp"%>
<%--<% int associationsCuratorObjectId=14;%>--%>
<style>
    label.hideEviText{
        font-size: 14px;
        font-weight: bold;
    }
    .only-show-annot-background {
        /*background: linear-gradient(135deg, #f5f7fa, #c3cfe2);*/
        /*background-color:#E1EBEE;*/
        background-color: #ebf2fa;
        padding: 8px;
        border-radius: 15px;
        font-family: Arial, sans-serif;
        width: auto;
        white-space: nowrap;
    }
    .only-show-annot-background label {
        cursor: pointer;
    }
</style>
<%


    String siteName = RgdContext.getSiteName(request);
    AnnotationFormatter af = new AnnotationFormatter();
    int oType=managementDAO.getRgdId(obj.getRgdId()).getObjectKey();
    List<Annotation> annotList=null;
    boolean hasPhenoMinerAnn=false;
    int isReferenceRgd = 0;
    boolean excludeRef=false;
    if (oType==12) {
        excludeRef=true;
    }
    if(oType==14){
         annotList = annotationDAO.getAnnotationsForProject(obj.getRgdId());
        if (annotList.isEmpty()) {
            annotList = annotationDAO.getAnnotationsByReferenceForProject(obj.getRgdId());
            if(annotList.size()>0){
                isReferenceRgd=1;
            }
        }
         hasPhenoMinerAnn = (annotationDAO.getPhenoAnnotationsCountByReferenceForProject(obj.getRgdId())>0);
    }
    else {


         annotList = annotationDAO.getAnnotations(obj.getRgdId());


        if (annotList.isEmpty()) {
            annotList = annotationDAO.getAnnotationsByReference(obj.getRgdId());
            if (annotList.size() > 0) {
                isReferenceRgd = 1;
            }
        }
         hasPhenoMinerAnn = (annotationDAO.getPhenoAnnotationsCountByReference(obj.getRgdId()) > 0);
    }
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
        List<Annotation> listGwas = new ArrayList<>();

        for( Annotation ax: filteredList ) {
            switch(ax.getDataSrc()) {
                case "ClinVar": listClinVar.add(ax); break;
                case "CTD": listCTD.add(ax); break;
                case "OMIA": listOmia.add(ax); break;
                case "OMIM": listOmim.add(ax); break;
                case "GAD": listGAD.add(ax); break;
                case "MouseDO": listMGI.add(ax); break;
                case "GWAS_CATALOG": listGwas.add(ax); break;
                default: listManual.add(ax); break;
            }
        }
%>

<%//ui.dynOpen("diseaseAsscociationC", "Disease Annotations")%>
<% if( !listManual.isEmpty() ) { %>


<div class="reportTable light-table-border" id="manualAnnotationsTableWrapper">

    <div class="sectionHeading" id="manualAnnotations"><%=siteName%> Manual Disease Annotations&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('manualAnnotationsTableWrapper', 'diseaseAnnotationsTableWrapper');">Click to see Annotation Detail View</a></div>
 <div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager manualAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="manualAnnotationsSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <br>
    <div class="only-show-annot-background">
        <input type="checkbox" class="hideTableEvidence" onchange="hideEvidence('manualAnnotationsTable');">&nbsp;&nbsp;<label class="hideEviText" style="position: relative;" onclick="checkBox('manualAnnotationsTable');">Only show annotations with direct experimental evidence (0 objects hidden)</label>
    </div>


    <div id="manualAnnotationsTableDiv" class="annotation-detail">

        <%=af.createGridFormatAnnotationsTable(listManual, siteName,excludeRef)%>
    </div>

    <div class="modelsViewContent" >
        <div class="pager manualAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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


    <div class="reportTable light-table-border" id="importedAnnotationsClinVarTableWrapper">
        <%if (title.equalsIgnoreCase("Variants")){%>
            <div class="sectionHeading" id="importedAnnotationsClinVar">Imported Disease Annotations - ClinVar&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('importedAnnotationsClinVar', 'diseaseAnnotationsTableWrapper');">Click to see Annotation Detail View</a></div>
        <%} else {%>
            <div class="sectionHeading" id="importedAnnotationsClinVar"><h4>Imported Disease Annotations - ClinVar </h4></div>
        <%}%>


<div class="search-and-pager">
        <div class="modelsViewContent" >
            <div class="pager importedAnnotationsClinVarPager" >
                <form>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                    <span type="text" class="pagedisplay"></span>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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

        <input class="search table-search" id="importedAnnotationsClinVarSearch" type="search" data-column="all" placeholder="Search table">
    </div>
        <div id="importedAnnotationsClinVarTableDiv" class="annotation-detail">
            <%=af.createGridFormatAnnotationsTable(listClinVar, siteName,excludeRef)%>
        </div>
        <div class="modelsViewContent" >
            <div class="pager importedAnnotationsClinVarPager" >
                <form>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                    <span type="text" class="pagedisplay"></span>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
<div class="reportTable light-table-border" id="importedAnnotationsCTDTableWrapper">
<div class="sectionHeading" id="importedAnnotationsCTD"><h4>Imported Disease Annotations - CTD </h4></div>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsCTDPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="importedAnnotationsCTDSearch" type="search" data-column="all" placeholder="Search table">
</div>

    <div id="importedAnnotationsCTDTableDiv" class="annotation-detail">
  <%=af.createGridFormatAnnotationsTable(listCTD, siteName,excludeRef)%>
    </div>

    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsCTDPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
<div class="reportTable light-table-border" id="importedAnnotationsGADTableWrapper">
<div class="sectionHeading" id="importedAnnotationsGAD"><h4>Imported Disease Annotations - GAD </h4></div>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsGADPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="importedAnnotationsGADSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="importedAnnotationsGADTableDiv" class="annotation-detail">
        <%=af.createGridFormatAnnotationsTable(listGAD, siteName,excludeRef)%>
    </div>

    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsGADPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
<div class="reportTable light-table-border" id="importedAnnotationsMGITableWrapper">
<div class="sectionHeading" id="importedAnnotationsMGI"><h4>Imported Disease Annotations - MGI </h4></div>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsMGIPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="importedAnnotationsMGISearch" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="importedAnnotationsMGITableDiv" class="annotation-detail">
  <%=af.createGridFormatAnnotationsTable(listMGI, siteName,excludeRef)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsMGIPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
<div class="reportTable light-table-border" id="importedAnnotationsOMIATableWrapper">
<div class="sectionHeading" id="importedAnnotationsOMIA"><h4>Imported Disease Annotations - OMIA </h4></div>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsOMIAPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="importedAnnotationsOMIASearch" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="importedAnnotationsOMIATableDiv" class="annotation-detail">
        <%=af.createGridFormatAnnotationsTable(listOmia, siteName,excludeRef)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsOMIAPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
<div class="reportTable light-table-border" id="importedAnnotationsOMIMTableWrapper">
<div class="sectionHeading" id="importedAnnotationsOMIM"><h4>Imported Disease Annotations - OMIM </h4></div>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsOMIMPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="importedAnnotationsOMIMSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="importedAnnotationsOMIMTableDiv" class="annotation-detail">
        <%=af.createGridFormatAnnotationsTable(listOmim, siteName,excludeRef)%>
    </div>

    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsOMIMPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
<% } if ( !listGwas.isEmpty() ){ %>
<div class="reportTable light-table-border" id="importedAnnotationsGWASTableWrapper">
<div class="sectionHeading" id="importedAnnotationsGWAS"><h4>Imported Disease Annotations - GWAS Catalog </h4></div>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsGWASPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="importedAnnotationsGWASSearch" type="search" data-column="all" placeholder="Search table">
</div>

<div id="importedAnnotationsGWASTableDiv" class="annotation-detail">
    <%=af.createGridFormatAnnotationsTable(listGwas, siteName,excludeRef)%>
</div>

<div class="modelsViewContent" >
    <div class="pager importedAnnotationsGWASPager" >
        <form>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
            <span type="text" class="pagedisplay"></span>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
<div class="reportTable light-table-border" id="geneChemicalInteractionDetailsTableWrapper">
<div class="sectionHeading" id="geneChemicalInteractionAnnotations">Gene-Chemical Interaction Annotations&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('geneChemicalInteractionDetailsTableWrapper', 'geneChemicalInteractionTableWrapper');">Click to see Annotation Detail View</a>
</div>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager geneChemicalInteractionAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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

    <input class="search table-search" id="geneChemicalInteractionAnnotationsSearch" type="search" data-column="all" placeholder="Search table">

</div>
    <br>
    <div class="only-show-annot-background">
        <input type="checkbox" class="hideTableEvidence" onchange="hideEvidence('geneChemicalInteractionAnnotationsTable');">&nbsp;&nbsp;<label class="hideEviText" style="position: relative;" onclick="checkBox('geneChemicalInteractionAnnotationsTable');">Only show annotations with direct experimental evidence (0 objects hidden)</label>
    </div>
    <div id="geneChemicalInteractionAnnotationsTableDiv" class="annotation-detail">
        <%=af.createGridFormatAnnotationsTable(filteredList, siteName,excludeRef)%><br>
    </div>

    <div class="modelsViewContent" >
        <div class="pager geneChemicalInteractionAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
<div class="sectionHeading" id="geneOntologyAnnotationsCurator">Gene Ontology Annotations&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('geneOntologyAnnotationsCurator', 'geneOntologyAnnotations');">Click to see Annotation Detail View</a>
</div>
<% if (bpList.size() > 0) { %>
<div class="reportTable light-table-border" id="biologicalProcessAnnotationsTableWrapper">
   <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Biological Process</u></span><br></span>

<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager biologicalProcessAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="biologicalProcessAnnotationsSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <br>
    <div class="only-show-annot-background">
        <input type="checkbox" class="hideTableEvidence" onchange="hideEvidence('biologicalProcessAnnotationsTable');">&nbsp;&nbsp;<label class="hideEviText" style="position: relative;" onclick="checkBox('biologicalProcessAnnotationsTable');">Only show annotations with direct experimental evidence (0 objects hidden)</label>
    </div>
    <div id="biologicalProcessAnnotationsTableDiv" class="annotation-detail">
       <%=af.createGridFormatAnnotationsTable(bpList, siteName,excludeRef)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager biologicalProcessAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
<div class="reportTable light-table-border" id="cellularComponentAnnotationsTableWrapper">
   <span style="border-bottom: 0 solid gray"><br><span class="highlight" id="cellularComponentDetail"><u>Cellular Component</u></span><br></span>

<div class="search-and-pager">

    <div class="modelsViewContent" >
        <div class="pager cellularComponentAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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

    <input class="search table-search" id="cellularComponentAnnotationsSearch" type="search" data-column="all" placeholder="Search table">

</div>
    <br>
    <div class="only-show-annot-background">
        <input type="checkbox" class="hideTableEvidence" onchange="hideEvidence('cellularComponentAnnotationsTable');">&nbsp;&nbsp;<label class="hideEviText" style="position: relative;" onclick="checkBox('molecularFunctionAnnotationsTable');">Only show annotations with direct experimental evidence (0 objects hidden)</label>
    </div>
    <div id="cellularComponentAnnotationsTableDiv" class="annotation-detail">
       <%=af.createGridFormatAnnotationsTable(ccList, siteName,excludeRef)%>
    </div>

    <div class="modelsViewContent" >
        <div class="pager cellularComponentAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
<% if (mfList.size() > 0) { %>
<div class="reportTable light-table-border" id="molecularFunctionAnnotationsTableWrapper">
   <span style="border-bottom: 0 solid gray"><br><span class="highlight" id="molecularFunctionDetail"><u>Molecular Function</u></span><br></span>

<div class="search-and-pager">

    <div class="modelsViewContent" >
        <div class="pager molecularFunctionAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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

    <input class="search table-search" id="molecularFunctionAnnotationsSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <br>
    <div class="only-show-annot-background">
        <input type="checkbox" class="hideTableEvidence" onchange="hideEvidence('molecularFunctionAnnotationsTable');">&nbsp;&nbsp;<label class="hideEviText" style="position: relative;" onclick="checkBox('molecularFunctionAnnotationsTable');">Only show annotations with direct experimental evidence (0 objects hidden)</label>
    </div>
    <div id="molecularFunctionAnnotationsTableDiv" class="annotation-detail">
       <%=af.createGridFormatAnnotationsTable(mfList, siteName,excludeRef)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager molecularFunctionAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
<%//ui.dynClose("goAsscociationC")%>
<% } %>

<%
    List<XdbId> xdbKeggPathways = xdbDAO.getXdbIdsByRgdId(XdbId.XDB_KEY_KEGGPATHWAY, obj.getRgdId());
    List<XdbId> xdbBioCycPathway = xdbDAO.getXdbIdsByRgdId(XdbId.XDB_KEY_BIOCYC_PATHWAY, obj.getRgdId());

    filteredList = af.filterList(annotList, "W");
    if(!filteredList.isEmpty() || xdbKeggPathways.size()>0 || xdbBioCycPathway.size()>0) {
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
<div class="sectionHeading" id="molecularPathwayAnnotationsDetail">Molecular Pathway Annotations&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('molecularPathwayAnnotationsDetail', 'molecularPathwayAnnotationsTableWrapper');">Click to see Annotation Detail View</a>
</div>

<% if( !listManual.isEmpty() ) { %>
<div class="reportTable light-table-border" id="molecularPathwayManualAnnotationsTableWrapper">
    <h4><%=siteName%> Manual Annotations</h4>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager molecularPathwayManualAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="molecularPathwayManualAnnotationsSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <br>
    <div class="only-show-annot-background">
        <input type="checkbox" class="hideTableEvidence" onchange="hideEvidence('molecularPathwayManualAnnotationsTable');">&nbsp;&nbsp;<label class="hideEviText" style="position: relative;" onclick="checkBox('molecularPathwayManualAnnotationsTable');">Only show annotations with direct experimental evidence (0 objects hidden)</label>
    </div>
    <div id="molecularPathwayManualAnnotationsTableDiv" class="annotation-detail">
        <%=af.createGridFormatAnnotationsTable(listManual, siteName,excludeRef)%>
    </div>

    <div class="modelsViewContent" >
        <div class="pager molecularPathwayManualAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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

    <% } if( !listImportedSMPDB.isEmpty() ) { %>
<div class="reportTable light-table-border" id="importedAnnotationsSMPDBTableWrapper">
    <h4>Imported Annotations - SMPDB</h4>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsSMPDBPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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

    <input class="search table-search" id="importedAnnotationsSMPDBSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="importedAnnotationsSMPDBTableDiv" class="annotation-detail">
    <%=af.createGridFormatAnnotationsTable(listImportedSMPDB, siteName,excludeRef)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsSMPDBPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <% } if( !listImportedKEGG.isEmpty() ) { %>
<div class="reportTable light-table-border" id="importedAnnotationsKEGGTableWrapper">
    <h4>Imported Annotations - KEGG (archival)</h4>

<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsKEGGPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="importedAnnotationsKEGGSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="importedAnnotationsKEGGTableDiv" class="annotation-detail">
        <%=af.createGridFormatAnnotationsTable(listImportedKEGG, siteName,excludeRef)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsKEGGPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <% } if( !listImportedPID.isEmpty() ) { %>
<div class="reportTable light-table-border" id="importedAnnotationsPIDTableWrapper">
    <h4>Imported Annotations - PID (archival)</h4>

    <div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsPIDPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="importedAnnotationsPIDSearch" type="search" data-column="all" placeholder="Search table">
    </div>
    <div id="importedAnnotationsPIDTableDiv" class="annotation-detail">
        <%=af.createGridFormatAnnotationsTable(listImportedPID, siteName,excludeRef)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsPIDPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <% } if( !listImported.isEmpty() ) { %>
<div class="reportTable light-table-border" id="importedAnnotationsOtherTableWrapper">
    <h4>Imported Annotations - Other</h4>

<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsOtherPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="importedAnnotationsOtherSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="importedAnnotationsOtherTableDiv" class="annotation-detail">
        <%=af.createGridFormatAnnotationsTable(listImported, siteName,excludeRef)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager importedAnnotationsOtherPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <% }

    if( xdbKeggPathways.size()>0 ) { %>
    <%@ include file="xdbs_pathways.jsp"%>
    <% } %>
<%//ui.dynClose("pathwayAssociationC")%>
<%@ include file="gene/bioCycPathway.jsp"%>
<% } %>

<%
    List<Annotation> mpList = af.filterList(annotList,"N");
    List<Annotation> hpList = af.filterList(annotList,"H");
    if (mpList.size()+hpList.size() > 0) {

        List<Annotation> hpClinVarList = new ArrayList<>();
        List<Annotation> hpManualList = new ArrayList<>();
        List<Annotation> hpOtherList = new ArrayList<>();

        for( Annotation ay: hpList ) {
            switch(ay.getDataSrc()) {
                case "ClinVar": hpClinVarList.add(ay); break;
                case "RGD": hpManualList.add(ay); break;
                default: hpOtherList.add(ay); break;
            }
        }
%>
<div class="reportTable light-table-border">
  <div class="sectionHeading" id="phenotypeAnnotationsCurator">Phenotype Annotations&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('phenotypeAnnotationsCurator', 'phenotypeAnnotations');">Click to see Annotation Detail View</a></div>


<% if (mpList.size() > 0) { %>
<div class="reportTable light-table-border" id="mammalianPhenotypeAnnotationsTableWrapper">
   <div class="sectionHeading" id="mammalianPhenotypeAnnotations"><h4>Mammalian Phenotype</h4></div>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager mammalianPhenotypeAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="mammalianPhenotypeAnnotationsSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="mammalianPhenotypeAnnotationsTableDiv" class="annotation-detail">
       <%=af.createGridFormatAnnotationsTable(mpList, siteName,excludeRef)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager mammalianPhenotypeAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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

<% } if (hpManualList.size() > 0) { %>
 <div class="reportTable light-table-border" id="humanPhenotypeManualAnnotationsTableWrapper">
    <div class="sectionHeading" id="humanPhenotypeManualAnnotations"><h4>Manual Human Phenotype Annotations - RGD</h4></div>

 <div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager humanPhenotypeManualAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="humanPhenotypeManualAnnotationsSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="humanPhenotypeManualAnnotationsTableDiv" class="annotation-detail">
       <%=af.createGridFormatAnnotationsTable(hpManualList, siteName,excludeRef)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager humanPhenotypeManualAnnotationsPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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

    <% } if (hpOtherList.size() > 0) { %>
<div class="reportTable light-table-border" id="humanPhenotypeAnnotationsTableWrapper">
    <div class="sectionHeading" id="humanPhenotypeAnnotations"><h4>Imported Human Phenotype Annotations - HPO</h4></div>

        <div class="search-and-pager">
            <div class="modelsViewContent" >
                <div class="pager humanPhenotypeAnnotationsPager" >
                    <form>
                        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                        <span type="text" class="pagedisplay"></span>
                        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
            <input class="search table-search" id="humanPhenotypeAnnotationsSearch" type="search" data-column="all" placeholder="Search table">
        </div>
        <div id="humanPhenotypeAnnotationsTableDiv" class="annotation-detail">
            <%=af.createGridFormatAnnotationsTable(hpOtherList, siteName,excludeRef)%>
        </div>
        <div class="modelsViewContent" >
            <div class="pager humanPhenotypeAnnotationsPager" >
                <form>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                    <span type="text" class="pagedisplay"></span>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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

 <% } if (hpClinVarList.size() > 0) { %>
<div class="reportTable light-table-border" id="humanPhenotypeClinVarAnnotationsTableWrapper">
    <div class="sectionHeading" id="humanPhenotypeClinVarAnnotations"><h4>Imported Human Phenotype Annotations - ClinVar</h4></div>

        <div class="search-and-pager">
            <div class="modelsViewContent" >
                <div class="pager humanPhenotypeClinVarAnnotationsPager" >
                    <form>
                        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                        <span type="text" class="pagedisplay"></span>
                        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
            <input class="search table-search" id="humanPhenotypeClinVarAnnotationsSearch" type="search" data-column="all" placeholder="Search table">
        </div>
        <div id="humanPhenotypeClinVarAnnotationsTableDiv" class="annotation-detail">
            <%=af.createGridFormatAnnotationsTable(hpClinVarList, siteName,excludeRef)%>
        </div>
        <div class="modelsViewContent" >
            <div class="pager humanPhenotypeClinVarAnnotationsPager" >
                <form>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                    <span type="text" class="pagedisplay"></span>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
<% } %>
</div>


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
<% if(!title.equalsIgnoreCase("references")&&oType!=14) { %>
<div class="light-table-border">
<div class="sectionHeading" id="experimentalDataAnnotationsCurator">Experimental Data Annotations&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('experimentalDataAnnotationsCurator', 'experimentalDataAnnotations');">Click to see Annotation Detail View</a></div>


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
<div id="cellOntologyTableWrapper">
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Cell Ontology</u></span><br></span>

<div class="search-and-pager">

    <div class="modelsViewContent" >
        <div class="pager cellOntologyPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="cellOntologySearch" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="cellOntologyTableDiv" class="annotation-detail">
           <%=af.createGridFormatAnnotationsTable(clList, siteName,excludeRef)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager cellOntologyPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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

    <% if (cmoList.size() > 0) { %>
    <div class="reportTable" id="clinicalMeasurementTableWrapper">
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Clinical Measurement</u></span><br></span>
        <div id="clinicalMeasurementTableDiv" class="annotation-detail">
            <%=af.createGridFormatAnnotationsTable(cmoList, siteName,excludeRef)%>
        </div>
    </div>
    <% } %>
    <% if (xcoList.size() > 0) { %>
    <div class="reportTable" id="experimentalConditionTableWrapper">
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Experimental Condition</u></span><br></span>
        <div id="experimentalConditionTableDiv" class="annotation-detail">
            <%=af.createGridFormatAnnotationsTable(xcoList, siteName,excludeRef)%>
        </div>
    </div>
    <% } %>
    <% if (mmoList.size() > 0) { %>
        <div class="reportTable" id="measurementMethodTableWrapper">
           <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Measurement Method</u></span><br></span>
            <div id="measurementMethodTableDiv" class="annotation-detail">
                <%=af.createGridFormatAnnotationsTable(mmoList, siteName,excludeRef)%>
            </div>
        </div>
    <% } %>

    <% if (maList.size() > 0) { %>
<div class="reportTable " id="mouseAnatomyTableWrapper">
    <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Mouse Anatomy</u></span><br></span>


<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager mouseAnatomyPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="mouseAnatomySearch" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="mouseAnatomyTableDiv" class="annotation-detail">
           <%=af.createGridFormatAnnotationsTable(maList)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager mouseAnatomyPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <% if (rsList.size() > 0) { %>
<div class="reportTable" id="ratStrainTableWrapper">
       <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Rat Strain</u></span><br></span>

<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager ratStrainPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="ratStrainSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <div id="ratStrainTableDiv" class="annotation-detail">
           <%=af.createGridFormatAnnotationsTable(rsList)%>
    </div>
    <div class="modelsViewContent" >
        <div class="pager ratStrainPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <%}%>
    <% if (vtList.size() > 0) { %>
    <div class="reportTable" id="vertebrateTraitTableWrapper">
        <span style="border-bottom: 0 solid gray"><br><span class="highlight"><u>Vertebrate Trait</u></span><br></span>
        <div id="vertebrateTraitTableDiv" class="annotation-detail">
            <%=af.createGridFormatAnnotationsTable(vtList)%>
        </div>
    </div>
    <% }%>
</div>
  <%  } %>
<br>
<%//ui.dynClose("expAssociationC")%>
<% }
    List<Annotation> efoList = af.filterList(annotList,"T");
    if (efoList.size()>0){%>
<div class="light-table-border">
    <div class="sectionHeading" id="experimentalFactorAnnotationsCurator">Experimental Factor Annotations&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('experimentalDataAnnotationsCurator', 'experimentalDataAnnotations');">Click to see Annotation Detail View</a></div>

<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="pager efoAnnotPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
    <input class="search table-search" id="efoAnnotSearch" type="search" data-column="all" placeholder="Search table">
</div>
<div id="efoAnnotTableDiv" class="annotation-detail">
    <%=af.createGridFormatAnnotationsTable(efoList)%>
</div>
<div class="modelsViewContent" >
    <div class="pager efoAnnotPager" >
        <form>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
            <span type="text" class="pagedisplay"></span>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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

<script>
    function hideEvidence(table) {
        var oTable = document.getElementById(table.toString());
        var oRows = oTable.getElementsByTagName("tr");
        var cb = oTable.parentNode.parentNode.getElementsByClassName('hideTableEvidence');
        var selectVal = parseInt(oTable.parentNode.parentNode.getElementsByTagName("select")[0].value);
        var startPoint = parseInt(oTable.parentNode.parentNode.getElementsByClassName("pagedisplay")[0].innerText.replace(/(^\d+)(.+$)/i,'$1') );
        var endVal = selectVal + startPoint;
        if (endVal > oRows.length){
            endVal = oRows.length;
        }
        var hideCnt = 0;
        for( var i=startPoint; i < endVal; i++ ) {  // hide rows with ISO ISS IEA, evidence is column 5
            if (oRows[i].cells[4].innerText === "ISO" || oRows[i].cells[4].innerText === "ISS" ||
                oRows[i].cells[4].innerText === "IEA" || oRows[i].cells[4].innerText === "IBA"){
                if ($(cb).is(':checked')){
                    oRows[i].style.display = 'none';
                    hideCnt++;
                }
                else {
                    oRows[i].style.display = '';
                }
            }
        }

        var myLabel = oTable.parentNode.parentNode.getElementsByClassName("hideEviText")[0];//cb.nextSibling;
        myLabel.innerText = 'Only show annotations with direct experimental evidence ('+hideCnt+' objects hidden)';
    }
    function checkBox(table) {
        var oTable = document.getElementById(table.toString());
        var cb = oTable.parentNode.parentNode.getElementsByClassName('hideTableEvidence');
        if ($(cb).is(':checked')){
            $(cb).prop("checked",false);
            hideEvidence(table);
        }
        else {
            $(cb).prop("checked",true);
            hideEvidence(table);
        }
    }
</script>
<%@ include file="sectionFooter.jsp"%>
