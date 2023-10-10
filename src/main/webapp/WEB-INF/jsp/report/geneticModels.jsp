<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.models.GeneticModel" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>

<%@ include file="sectionHeader.jsp"%>

<%
    List<GeneticModel> modelList = geneticModelsDAO.getAllModelsByGeneRgdId(obj.getRgdId());
    if (modelList.size() > 0) {
%>

<br>
<div class="sectionHeading" id="geneticModels">Genetic Models</div>
<div class="reportTable light-table-border" id="geneticModelsTable">
    <div>This gene  <span class="highlight"><%=displayName%></span> is modified in the following models/strains:</div>

    <div id="geneticModelsTableDiv" style="border: 1px solid black; padding: 10px;" class="report-page-grey">

        <% for (GeneticModel model : modelList) { %>
        <span style="white-space: pre"><a href="<%=Link.strain(model.getStrainRgdId())%>"><%=model.getStrainSymbol()%></a></span> &nbsp; &nbsp;
        <% } %>
    </div>


    <br>
</div>
<% } %>
<%@ include file="sectionFooter.jsp"%>