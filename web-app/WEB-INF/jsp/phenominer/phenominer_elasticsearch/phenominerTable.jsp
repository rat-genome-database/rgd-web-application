<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jstl/fmt" %>
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
            widgets: ['zebra','resizable', 'stickyHeaders'],

        })

    .bind("sortEnd",function(e, t) {
        updateChart();
        });
    });

</script>
<div id="display"></div>
<c:set var="missedColumCount" value="0"/>

<c:if test="${columns.averageType==null}">
    <c:set var="missedColumCount" value="${missedColumCount+1}"/>
</c:if>
<c:if test="${columns.formula==null}">
    <c:set var="missedColumCount" value="${missedColumCount+1}"/>
    </c:if>
<script>
    var missedColumnCount=${missedColumCount}
    console.log("MISSED COLUN COUNT:"+ missedColumnCount)
</script>
<table id="mytable" class="tablesorter">
    <thead>
        <tr>
            <th>Conditions</th>

            <th>Study</th>
            <th>Experiment Name</th>

            <th>Strain</th>
            <th>Sex</th>
            <th>Age</th>
            <th># of Animals</th>

            <th>Phenotype</th>
<c:if test="${columns.formula!=null}">

<th>Formula</th>
</c:if>

<c:if test="${columns.averageType!=null}">
            <th>Average Type</th>
</c:if>
            <th>Value</th>
            <th>Units</th>
            <th>SEM</th>
            <th>SD</th>
            <th>Method</th>
<c:if test="${columns.methodSite!=null}">

<th>Method Site</th>
</c:if>
            <th>Method Duration</th>

<c:if test="${columns.postInsultType!=null}">

<th>Post Insult Type</th>
</c:if>
            <th>Post Insult Time Value</th>
<c:if test="${columns.postInsultTimeUnit!=null}">

<th>Post Insult Time Unit</th>
</c:if>
            <c:if test="${columns.methodNotes!=null}">

                <th>Method Notes</th>
            </c:if>
            <c:if test="${columns.clinicalMeasurementNotes!=null}">
                <th>Clinical Measurement Notes</th>
            </c:if>
            <c:if test="${columns.sampleNotes!=null}">
                <th>Sample Notes</th>
            </c:if>
            <c:if test="${columns.experimentNotes!=null}">
                <th>Experiment Notes</th>
            </c:if>
            <th>Record ID</th>
            <th>Study ID</th>
        </tr>
    </thead>
    <tbody>
        <c:forEach items="${sr.hits.hits}" var="hit">
            <tr>
                <td>${hit.sourceAsMap.xcoTerm}</td>
                <td>${hit.sourceAsMap.study}</td>
                <td>${hit.sourceAsMap.experimentName}</td>

                <td><a href="/rgdweb/ontology/annot.html?acc_id=${hit.sourceAsMap.rsTermAcc}">${hit.sourceAsMap.rsTerm}</a></td>
                <td>${hit.sourceAsMap.sex}</td>
                <td>${hit.sourceAsMap.ageLowBound}-${hit.sourceAsMap.ageHighBound}</td>
                <td>${hit.sourceAsMap.numberOfAnimals}</td>

                <td><a href="/rgdweb/ontology/annot.html?acc_id=${hit.sourceAsMap.cmoTermAcc}">${hit.sourceAsMap.cmoTerm}</a></td>
                <c:if test="${columns.formula!=null}">

                <td>${hit.sourceAsMap.formula}</td>
                </c:if>

                <c:if test="${columns.averageType!=null}">

                <td>${hit.sourceAsMap.averageType}</td>
                </c:if>
                <td>${hit.sourceAsMap.value}</td>
                <td>${hit.sourceAsMap.units}</td>
                <td>${hit.sourceAsMap.sem}</td>
                <td>${hit.sourceAsMap.sd}</td>
                <td><a href="/rgdweb/ontology/annot.html?acc_id=${hit.sourceAsMap.mmoTermAcc}">${hit.sourceAsMap.mmoTerm}</a></td>
                <c:if test="${columns.methodSite!=null}">

                <td>${hit.sourceAsMap.methodSite}</td>
                </c:if>
                <td>${hit.sourceAsMap.methodDuration}</td>

                <c:if test="${columns.postInsultType!=null}">
                <td>${hit.sourceAsMap.postInsultType}</td>
                </c:if>
                <td>${hit.sourceAsMap.postInsultTimeValue}</td>
                <c:if test="${columns.postInsultTimeUnit!=null}">

                <td>${hit.sourceAsMap.postInsultTimeUnit}</td>
                </c:if>
                <c:if test="${columns.methodNotes!=null}">

                    <td>${hit.sourceAsMap.methodNotes}</td>
                </c:if>
                <c:if test="${columns.clinicalMeasurementNotes!=null}">

                    <td>${hit.sourceAsMap.clinicalMeasurementNotes}</td>
                </c:if>
                <c:if test="${columns.sampleNotes!=null}">
                    <td>${hit.sourceAsMap.sampleNotes}</td>
                </c:if>
                <c:if test="${columns.experimentNotes!=null}">
                    <td>${hit.sourceAsMap.experimentNotes}</td>
                </c:if>
                <td>${hit.sourceAsMap.recordId}</td>
                <td>${hit.sourceAsMap.studyId}</td>
            </tr>
        </c:forEach>
    </tbody>
</table>
