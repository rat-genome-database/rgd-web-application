<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<h1>${model.hitsCount} Results</h1>
<table class="table">
    <thead>
    <tr>
        <th>Model</th>
        <th>Model RGD ID</th>
        <th>Species</th>
        <th>Evidence Code</th>
        <th>Disease/Phenotype</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach items="${model.searchHits}" var="hitArray">
        <c:forEach items="${hitArray}" var="hit">
            <tr>
                <td><a href="/rgdweb/report/strain/main.html?id=${hit.getSourceAsMap().annotatedObjectRgdId}">${hit.getSourceAsMap().annotatedObjectSymbol}</a></td>
                <td>${hit.getSourceAsMap().annotatedObjectRgdId}</td>
                <td>${hit.getSourceAsMap().species}</td>
                <td>${hit.getSourceAsMap().evidenceCode}</td>
                <td>${hit.getSourceAsMap().term} &nbsp;&nbsp;<a href="/rgdweb/ontology/view.html?acc_id=${hit.getSourceAsMap().termAcc}"><img border="0" src="/rgdweb/common/images/tree.png" title="click to browse the term" alt="term browser"></a>
                </td>
            </tr>
        </c:forEach>
    </c:forEach>
    </tbody>
</table>