<%@ page import="edu.mcw.rgd.process.pheno.SearchBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    String ontId = request.getAttribute("ontId").toString();

    List<Integer> recIds = null;
    if( ontId != null ) {
        SearchBean sb = new SearchBean();
        sb.setSAccId(ontId);

        recIds = phenominerDAO.getRecordIdsForReport(sb);
    }
    if (recIds!=null && recIds.size() > 0) {
%>

<%--<%=ui.dynOpen("phenominerAssociation", "Phenotype Values via Phenominer")%>--%>
<div id="phenominerAssociationTableWrapper" class="light-table-border">
<div class="sectionHeading" id="phenominerAssociation">Phenotype Values via Phenominer</div>
    <div class="modelsViewContent" >
        <div class="pager phenominerAssociationPager" >
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

<table>
    <tr>
      <td><b>Options:&nbsp;</b></td>
      <td><a href="/rgdweb/phenominer/table.html?species=3&terms=<%=ontId%>#ViewChart">View chart</a></td>
      <td>&nbsp;|&nbsp;</td>
      <td><a href="/rgdweb/phenominer/table.html?species=3&fmt=3&terms=<%=ontId%>">Download data table</a></td>
      <td>&nbsp;|&nbsp;</td>
      <td><a href="/rgdweb/phenominer/table.html?species=3&fmt=2&terms=<%=ontId%>">View expanded data table</a></td>
    </tr>
  </table>
   <br/>
    <div id="phenominerAssociationTableDiv">
<%
    /*if( recIds.size()>1000 ) {
        out.println("<p><span class=\"highlight\"><u>Note: Only first 1000 records are shown!</u></span><br></p>");
    }
    */

    List<Record> records = phenominerDAO.getRecords(recIds);

    Report r = new Report();

    edu.mcw.rgd.reporting.Record row = new edu.mcw.rgd.reporting.Record();
    row.append("Clinical Measurement");

    r.append(row);

    HashMap seen = new HashMap();



    for (Record rec: records) {
       row = new edu.mcw.rgd.reporting.Record();

       String term = ontologyDAO.getTerm(rec.getClinicalMeasurement().getAccId()).getTerm();

        if (!seen.containsKey(term)) {
            row.append("<a href='/rgdweb/phenominer/table.html?species=3&terms=" + rec.getSample().getStrainAccId()
                    + "," + rec.getClinicalMeasurement().getAccId()
                    + "#ViewDataTable'>" + ontologyDAO.getTerm(rec.getClinicalMeasurement().getAccId()).getTerm() + "</a>");
            r.append(row);
            seen.put(term,true);
        }

    }
    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    r.sort(0, Report.CHARACTER_SORT, Report.ASCENDING_SORT, true);

    out.print(strat.format(r));

%>
    </div>
<br>
    <div class="modelsViewContent" >
        <div class="pager phenominerAssociationPager" >
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
<%--<%=ui.dynClose("phenominerAssociation")%>--%>
</div>
<% } %>

<%@ include file="../sectionFooter.jsp"%>
