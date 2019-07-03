<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<% String pageTitle = "Variant Results - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="/common/headerarea.jsp"%>

<div>
    <h4>Total Hits: ${fn:length(model.hitsArray)}</h4>
</div>
<table class="table" style="border:1px;border-color: #00b38f">
    <thead>
    <tr>
        <td>genicStatus</td>
        <td>zygosityStatus}</td>
        <td>zygosityInPseudo  </td>
        <td>geneSymbols</td>
        <td>conScores</td>
        <td>zygosityPossError</td>
        <td>sampleId</td>
        <td>refNuc</td>
        <td>totalDepth</td>
        <td>varFreq</td>
        <td>varNuc</td>

        <td>geneRgdIds</td>
        <td>variantType</td>
        <td>variant_id</td>
        <td>mapKey</td>
        <td>startPos</td>
        <td>endPos</td>
        <td>zygosityPercentRead</td>




    <!--c:forEach items="$-{model.hitsArray[0].getSourceAsMap()}" var="head">
        <td>$-{head.key}</td>
        <!--/c:forEach-->


    </tr>
    </thead>
    <tbody>
    <c:forEach items="${model.hitsArray}" var="hit">
        <tr>
            <td>${model.hitsArray[0].getSourceAsMap().genicStatus}</td>
            <td>${model.hitsArray[0].getSourceAsMap().zygosityStatus}</td>
            <td>${model.hitsArray[0].getSourceAsMap().zygosityInPseudo}</td>
            <td>${model.hitsArray[0].getSourceAsMap().geneSymbols}</td>
            <td>${model.hitsArray[0].getSourceAsMap().conScores}</td>
            <td>${model.hitsArray[0].getSourceAsMap().zygosityPossError}</td>
            <td>${model.hitsArray[0].getSourceAsMap().sampleId}</td>
            <td>${model.hitsArray[0].getSourceAsMap().refNuc}</td>
            <td>${model.hitsArray[0].getSourceAsMap().totalDepth}</td>
            <td>${model.hitsArray[0].getSourceAsMap().varFreq}</td>
            <td>${model.hitsArray[0].getSourceAsMap().varNuc}</td>
            <td>${model.hitsArray[0].getSourceAsMap().geneRgdIds}</td>
            <td>${model.hitsArray[0].getSourceAsMap().variantType}</td>
            <td>${model.hitsArray[0].getSourceAsMap().variant_id}</td>
            <td>${model.hitsArray[0].getSourceAsMap().mapKey}</td>
            <td>${model.hitsArray[0].getSourceAsMap().startPos}</td>
            <td>${model.hitsArray[0].getSourceAsMap().endPos}</td>
            <td>${model.hitsArray[0].getSourceAsMap().zygosityPercentRead}</td>


        <!--c:forEach items="$--{hit.getSourceAsMap()}" var="field">
            <td>$-{field.value}</td>
        <!--/c:forEach-->
        </tr>
    </c:forEach>
    </tbody>
</table>


<%@ include file="/common/footerarea.jsp"%>