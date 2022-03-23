<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<table>
        <tr>
            <th>Record ID</th>
            <th>Study ID</th>
            <th>Study</th>
            <th>Experiment Name</th>
            <th>Experiment Notes</th>
            <th>Strain</th>
            <th>Sex</th>
            <th>Age</th>
            <th># of Animals</th>
            <th>Sample Notes</th>
            <th>Phenotype</th>
            <th>Formula</th>
            <th>Clinical Measurement Notes</th>
            <th>Average Type</th>
            <th>Value</th>
            <th>Units</th>
            <th>SEM</th>
            <th>SD</th>
\            <th>Method</th>
            <th>Method Site</th>
            <th>Method Duration</th>
            <th>Method Notes</th>
            <th>Post Insult Type</th>
            <th>Post Insult Time Value</th>
            <th>Post Insult Time Unit</th>
            <th>Conditions</th>
        </tr>
        <c:forEach items="${sr.hits.hits}" var="hit">
            <tr>
                <td>${hit.sourceAsMap.recordId}</td>
                <td>Study ID</td>
                <td>Study</td>
                <td>Experiment Name</td>
                <td>Experiment Notes</td>
                <td>${hit.sourceAsMap.rsTerm}</td>
                <td>${hit.sourceAsMap.sex}</td>
                <td>Age</td>
                <td># of Animals</td>
                <td>Sample Notes</td>
                <td>${hit.sourceAsMap.cmoTerm}</td>
                <td>Formula</td>
                <td>Clinical Measurement Notes</td>
                <td>Average Type</td>
                <td>Value</td>
                <td>${hit.sourceAsMap.units}</td>
                <td>${hit.sourceAsMap.sem}</td>
                <td>${hit.sourceAsMap.sd}</td>
                <td>${hit.sourceAsMap.mmoTerm}</td>
                <td>Method Site</td>
                <td>Method Duration</td>
                <td>Method Notes</td>
                <td>Post Insult Type</td>
                <td>Post Insult Time Value</td>
                <td>Post Insult Time Unit</td>
                <td>Conditions</td>


            </tr>
        </c:forEach>

</table>
