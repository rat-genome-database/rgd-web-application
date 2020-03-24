<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<h3>${model.hitsCount} results for term "${model.term}
    <c:if test="${model.aspect=='D'}">
        Disease
    </c:if>
    <c:if test="${model.aspect=='N'}">
        Phenotype
    </c:if>
    ${model.qualifier}"</h3>
<table class="table">
    <thead>
    <tr>
        <th>Model</th>
        <!--th>Model RGD ID</th>
        <th>Species</th-->
        <th>Model Type</th>
        <th>Evidence Code</th>
        <th>Disease/Phenotype</th>
        <th>Reference</th>

    </tr>
    </thead>
    <tbody>
    <c:forEach items="${model.searchHits}" var="hitArray">
        <c:forEach items="${hitArray}" var="hit">
            <tr>
                <td><a href="/rgdweb/report/strain/main.html?id=${hit.getSourceAsMap().annotatedObjectRgdId}">${hit.getSourceAsMap().annotatedObjectSymbol}</a></td>
                <!--td>$-{hit.getSourceAsMap().annotatedObjectRgdId}</td>
                <td>$-{hit.getSourceAsMap().species}</td-->
                <td>${hit.getSourceAsMap().qualifier}</td>
                <td>${hit.getSourceAsMap().evidenceCode}</td>
                <td>${hit.getSourceAsMap().term} &nbsp;&nbsp;<a href="/rgdweb/ontology/view.html?acc_id=${hit.getSourceAsMap().termAcc}"><img border="0" src="/rgdweb/common/images/tree.png" title="click to browse the term" alt="term browser"></a>
                </td>
                <td><a href="/rgdweb/report/reference/main.html?id=${hit.getSourceAsMap().refRgdId}">${hit.getSourceAsMap().refRgdId}</a></td>
                <!--td>
                <!--c:forEach items="$-{hit.getSourceAsMap().references}" var="refRgdId">
                    <a href="/rgdweb/report/reference/main.html?id=$-{refRgdId}">$-{refRgdId}</a>
                <!--/c:forEach></td-->
            </tr>
        </c:forEach>
    </c:forEach>
    </tbody>
</table>