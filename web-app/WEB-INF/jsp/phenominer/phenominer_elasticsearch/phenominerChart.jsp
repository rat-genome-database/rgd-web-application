<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.js"> </script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.widgets.js"></script>

<link href="/rgdweb/common/tablesorter-2.18.4/css/filter.formatter.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.jui.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>


<script>
    $(function () {
        $("#mytable").tablesorter({
            theme: 'blue',
            widthFixed: false,
            widgets: ['zebra',"filter",'resizable', 'stickyHeaders'],

        })
    })
</script>
<table id="mytable" class="tablesorter">
    <thead>
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
            <th>Method</th>
            <th>Method Site</th>
            <th>Method Duration</th>
            <th>Method Notes</th>
            <th>Post Insult Type</th>
            <th>Post Insult Time Value</th>
            <th>Post Insult Time Unit</th>
            <th>Conditions</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach items="${sr.hits.hits}" var="hit">
            <tr>
                <td>${hit.sourceAsMap.recordId}</td>
                <td>${hit.sourceAsMap.studyId}</td>
                <td>${hit.sourceAsMap.study}</td>
                <td>${hit.sourceAsMap.experimentName}</td>
                <td>${hit.sourceAsMap.experimentNotes}</td>
                <td>${hit.sourceAsMap.rsTerm}</td>
                <td>${hit.sourceAsMap.sex}</td>
                <td>${hit.sourceAsMap.ageLowBound}-${hit.sourceAsMap.ageHighBound}</td>
                <td>${hit.sourceAsMap.numberOfAnimals}</td>
                <td>${hit.sourceAsMap.sampleNotes}</td>
                <td>${hit.sourceAsMap.cmoTerm}</td>
                <td>${hit.sourceAsMap.formula}</td>
                <td>${hit.sourceAsMap.clinicalMeasurementNotes}</td>
                <td>${hit.sourceAsMap.averageType}</td>
                <td>${hit.sourceAsMap.value}</td>
                <td>${hit.sourceAsMap.units}</td>
                <td>${hit.sourceAsMap.sem}</td>
                <td>${hit.sourceAsMap.sd}</td>
                <td>${hit.sourceAsMap.mmoTerm}</td>
                <td>${hit.sourceAsMap.methodSite}</td>
                <td>${hit.sourceAsMap.methodDuration}</td>
                <td>${hit.sourceAsMap.methodNotes}</td>
                <td>${hit.sourceAsMap.postInsultType}</td>
                <td>${hit.sourceAsMap.postInsultTimeValue}</td>
                <td>${hit.sourceAsMap.postInsultTimeUnit}</td>
                <td>${hit.sourceAsMap.xcoTerm}</td>
            </tr>
        </c:forEach>
    </tbody>
</table>
