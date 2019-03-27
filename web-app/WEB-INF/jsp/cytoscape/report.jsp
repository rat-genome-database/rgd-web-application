<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="edu.mcw.rgd.reporting.SearchReportStrategy" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>

<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String pageTitle =  " Interactions Report";
    String headContent = "";
    String pageDescription = "Protein-Protein Interactions";
%>
<style>
    #interactionBrowser th{
        font-size: small;
        background-color: #0d7cd0;
        color:white;
    }
</style>
<div class="container">
    <%@ include file="/common/headerarea.jsp"%>
    <div class="container">
        <div style="style:100px;float:right">
            <form action="download.html" method="post" >
            <button type="submit" class="btn btn-primary">Download</button>
            </form>
        </div>
        <h1>${fn:length(model.records)} Protein-Protein Binary Interactions for ${model.species}</h1>
        <input type="hidden" value="${model.species}" name="species"/>
        <table class="table table-striped" id="interactionBrowser" >
            <thead>
            <tr>
                <th>Interactor_A</th>
                <th>Interactor_A Gene</th>
                <th>Interactor_A Gene_RGD_ID</th>
                <th >Interactor_B</th>
                <th>Interactor_B Gene</th>
                <th>Interactor_B Gene_RGD_ID</th>
                <th >Species A</th>
                <th >Species B</th>
                <th >Interaction Type</th>
                <th>Attibutes</th>

            </tr>
            </thead>
            <tbody>
            <c:forEach items="${model.records}" var="item">
                <tr>
                    <td class="table-cell" style="padding:0">${item.proteinUniprotId1}</td>
                    <td><a href="/rgdweb/report/gene/main.html?id=${item.geneRgdId1}" >${item.geneSymbol1}</a></td>
                    <td>${item.geneRgdId1}</td>
                    <td class="table-cell">${item.proteinUniprotId2}</td>
                    <td><a href="/rgdweb/report/gene/main.html?id=${item.geneRgdId2}" >${item.geneSymbol2}</a></td>
                    <td>${item.geneRgdId2}</td>
                    <td class="table-cell">${item.species1}</td>
                    <td class="table-cell">${item.species2}</td>
                    <td class="table-cell">${item.interactionType}</td>
                    <td class="table-cell">${item.attributes}</td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </div>
    <%@ include file="/common/footerarea.jsp"%>
</div>
<%--
   Report report= (Report) request.getAttribute("report");
    SearchReportStrategy strat = new SearchReportStrategy();
    strat.hideColumn(0);
    strat.setTableProperties("border='0' cellpadding='2' cellspacing='2' width=100%");
    try {
        out.println(report.format(strat));
    } catch (Exception e) {
        e.printStackTrace();
    }
--%>


