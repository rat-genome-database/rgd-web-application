<%@ include file="sectionHeader.jsp"%>
<%
    List<NomenclatureEvent> events = nomenclatureDAO.getNomenclatureEvents(obj.getRgdId());
    if (events.size() > 0) {
%>
<%//ui.dynOpen("nomenAssociation", "Nomenclature History")%><br>
<div class="light-table-border">
<div class="sectionHeading" id="nomenclatureHistory">Nomenclature History</div>
<table border="1" cellspacing="0" width="95%">
    <tr>
        <th>Date</th>
        <th>Current Symbol</th>
        <th>Current Name</th>
        <th>Previous Symbol</th>
        <th>Previous Name</th>
        <th>Description</th>
        <th>Reference</th>
        <th>Status</th>
    </tr>
<%
    for (NomenclatureEvent event: events) {
        int refeRgdId = referenceDAO.getReferenceRgdIdByKey(Integer.parseInt(event.getRefKey()));
%>
     <tr>
         <td><%=event.getEventDate()%></td>
         <td><%=fu.chkNull(event.getSymbol())%>&nbsp;</td>
         <td><%=fu.chkNull(event.getName())%>&nbsp;</td>
         <td><%=fu.chkNull(event.getPreviousSymbol())%>&nbsp;</td>
         <td><%=fu.chkNull(event.getPreviousName())%>&nbsp;</td>
         <td><%=event.getDesc()%></td>
         <td><a href="<%=Link.ref(refeRgdId)%>"><%=refeRgdId%></a></td>
         <td><%=event.getNomenStatusType()%></td>
     </tr>
  <% } %>
</table>
</div>
<br>
<%//ui.dynClose("nomenAssociation")%>

<% } %>

<%@ include file="sectionFooter.jsp"%>

