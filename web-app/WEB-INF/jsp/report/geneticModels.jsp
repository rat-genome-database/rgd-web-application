<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.models.GeneticModel" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>

<%@ include file="sectionHeader.jsp"%>

<%

    List<GeneticModel> modelList = geneticModelsDAO.getAllModelsByGeneRgdId(obj.getRgdId());
    if (modelList.size() > 0) {
%>

<%//ui.dynOpen("geneticModels", "Genetic Models")%>    <br>
<div class="sectionHeading" id="geneticModels">Genetic Models</div>
<div class="reportTable light-table-border" id="geneticModelsTable">
This gene  <span class="highlight"><%=displayName%></span> is modified in the following models/strains

<div id="geneticModelsTableDiv">
<%
    List records = new ArrayList();
    for (GeneticModel model : modelList) {
        records.add("<tr><td><a href=\"" + Link.strain(model.getStrainRgdId()) + "\">" + model.getStrainSymbol() + "</a></td></tr>");
    }
    out.print(formatter.buildTable(records, 4));
%>
</div>
<br>

<%//ui.dynClose("geneticModels")%>
<% } %>
</div>
<%@ include file="sectionFooter.jsp"%>