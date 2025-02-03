<%@ page import="edu.mcw.rgd.datamodel.variants.VariantSampleDetail" %>

<%@ include file="../sectionHeader.jsp"%>
<%
List<VariantSampleDetail> sampleDetailList = new ArrayList<>();
for (VariantSampleDetail vsd : sampleDetails){
    if (vsd.getZygosityStatus() != null)
        sampleDetailList.add(vsd);
}
if (!sampleDetailList.isEmpty() ) {
    int i = 0;
%>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>

<div class="sampleDetailsTable light-table-border" id="sampleDetailsTableWrapper">
    <div class="sectionHeading" id="sampleDetails">Variant Samples</div>

    <div class="search-and-pager">
        <div class="modelsViewContent" >
            <div class="pager sampleDetailsPager" >
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

        <input class="search table-search" id="sampleDetailsSearch" type="search" data-column="all" placeholder="Search table">
    </div>

<%--    <div id="sampleDetailsTableDiv" class="annotation-detail">--%>
        <table id="sampleDetailsTable" class="tablesorter" border='0' cellpadding='2' cellspacing='2' aria-describedby="sampleDetailsTable_pager_info">
            <thead>
<%--            <tr>--%>
<%--                <td>Sample</td>--%>
<%--                <td>Variant Allele Depth</td>--%>
<%--                <td>Variant Zygosity in Sample</td>--%>
<%--            </tr>--%>
            </thead>
            <tbody>
            <%for (VariantSampleDetail vsd : sampleDetailList) {
                Sample s = sdao.getSampleBySampleId(vsd.getSampleId());
                long start = var.getStartPos() - 1;
                long stop = var.getEndPos() + 1;
                String vvUrl = "/rgdweb/front/variants.html?start="+ start +"&stop="+stop+"&chr=" + var.getChromosome() +
                        "&geneStart=&geneStop=&geneList=&mapKey="+s.getMapKey()+"&con=&depthLowBound=1&depthHighBound=&sample1="+s.getId();
            if (i % 4 == 0){%>
            <tr>
                <%}%>
                <td><a href="<%=vvUrl%>" title="View in Variant Visualizer"><%=s.getAnalysisName()%></a></td>
<%--                <td><%=vsd.getVariantFrequency()%>/<%=vsd.getDepth()%>&nbsp;(<%=vsd.getZygosityPercentRead()%>%)</td>--%>
<%--                <td><%=vsd.getZygosityStatus()%></td>--%>
                <%if (i % 4 == 3){%>
            </tr>
            <% }
            i++;} %>
            </tbody>
        </table>
<%--    </div>--%>

    <div class="modelsViewContent" >
        <div class="pager sampleDetailsPager" >
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
<%@ include file="../sectionFooter.jsp"%>