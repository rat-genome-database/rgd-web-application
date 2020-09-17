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
<br>

<%--<%=ui.dynClose("phenominerAssociation")%>--%>

<% } %>

<%@ include file="../sectionFooter.jsp"%>
