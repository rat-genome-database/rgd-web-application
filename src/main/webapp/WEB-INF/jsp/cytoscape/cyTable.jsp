<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head><title>Protein Interactions Data Table</title>
    <!--link href="/rgdweb/css/cyStyle.css" rel="stylesheet" type="text/css"-->
    <link href="/rgdweb/css/cyTable.css" rel="stylesheet" type="text/css">
    <script src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>
<script src="/rgdweb/js/cyFilter.js"></script>
<script>
    var terms = ${model.matched};
    var report= ${model.report};
</script>
</head>

<body style="background-color:#CCCCCC">

    <div class="container" style="width:95%;border:1px solid black;margin-left:2%; margin-right:2%;background-color:#fff">
        <%@ include file="rgdHeader.jsp"%>
        <div class="panel panel-default" >
            <h3 style="color:green;padding-left: 20px;" >${fn:length(model.edges)} Binary Interactions are returned for your query</h3>
            <p style="color:red;padding-left:20px">${model.msg}</p>
            <div class="panel-heading" id="panelheading">
                <h3>Protein-Protein Binary Interactions Data Table</h3>
            </div>
            <div class="panel-body">

                <div id="info">
                    <table>
                        <tr><td style="font-weight: bold;background-color:#e6e6e6">Queried Objects:</td>
                            <td>
                            <c:forEach items="${model.matched}" var="i">
                            <a target="_blank" title="IMEX Link" href="http://www.ebi.ac.uk/intact/imex/main.xhtml?query=${i}"><c:out value="${fn:toUpperCase(i)}"/></a>,
                            </c:forEach>
                            </td>
                        </tr>
                        <tr><td style="font-weight: bold;background-color:#e6e6e6">Total Interactions:</td><td>${fn:length(model.edges)}</td></tr>
                        <tr><td style="font-weight: bold;background-color:#e6e6e6">Total Nodes(Participants):</td><td>${fn:length(model.nodes)}</td></tr>
                        <tr>
                            <td align="center" valign="center" style="padding-top:20px;">
                                <form action="cy.html?report=full" method="post">
                                    <input type="hidden" name="identifiers" value='${model.query}'>
                                    <input type="hidden" name="species" value='${model.species}'>
                                    <input type="hidden" name="browser" value="12">
                                    <button>View Full Report</button>
                                </form>
                            </td>
                            <td align="left" valign="center" style="padding-top:20px;">
                                <form action="cy.html?d=true" method="post">
                                    <input type="hidden" name="identifiers" value='${model.query}'>
                                    <input type="hidden" name="species" value='${model.species}'>
                                    <input type="hidden" name="browser" value="12">
                                    <button>Download</button>
                                </form>
                            </td>
                        </tr>
                    </table>
                </div>

            </div>
            <div class="panel-footer">
                <p>&copy; <a href="http://www.mcw.edu/bioinformatics.htm">Bioinformatics Program, HMGC</a> at the <a href="http://www.mcw.edu/">Medical
                    College of Wisconsin</a></p>

                <p align="center">RGD is funded by grant HL64541 from the National Heart, Lung, and Blood Institute on behalf of the NIH.<br><img src="/common/images/nhlbilogo.gif" alt="NHLBI Logo" title="National Heart Lung and Blood Institute logo">
            </div>
        </div>
    </div>

</body>


</html>