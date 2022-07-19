<%@ page import="edu.mcw.rgd.datamodel.variants.VariantSampleDetail" %>

<%@ include file="../sectionHeader.jsp"%>
<%
List<VariantSampleDetail> sampleDetailList = new ArrayList<>();
for (VariantSampleDetail vsd : sampleDetails){
    if (vsd.getZygosityStatus() != null)
        sampleDetailList.add(vsd);
}
if (!sampleDetailList.isEmpty() ) {
%>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>

<div class="sampleDetailsTable light-table-border" id="sampleDetailsTableWrapper">
    <div class="sectionHeading" id="sampleDetails">Variant Sample Details</div>

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

    <div id="sampleDetailsTableDiv" class="annotation-detail">
        <table id="sampleDetailsTable" class="tablesorter" border='0' cellpadding='2' cellspacing='2' aria-describedby="sampleDetailsTable_pager_info">
            <tr>
                <td>Sample</td>
                <td>Total Depth</td>
                <td>Sample Allele Frequency</td>
                <td>Zygosity Status</td>
                <td>Zygosity Percent Read</td>
            </tr>
            <%for (VariantSampleDetail vsd : sampleDetailList) {
                Sample s = sdao.getSampleBySampleId(vsd.getSampleId());%>
            <tr>
                <td><%=s.getAnalysisName()%></td>
                <td><%=vsd.getDepth()%></td>
                <td><%=vsd.getVariantFrequency()%></td>
                <td><%=vsd.getZygosityStatus()%></td>
                <td><%=vsd.getZygosityPercentRead()%></td>
            </tr>
            <% } %>
        </table>
    </div>

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