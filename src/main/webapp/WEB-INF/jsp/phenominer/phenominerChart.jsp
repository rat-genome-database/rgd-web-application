<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.LocalDateTime" %>
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
            widgets: ['zebra','resizable'],

        })

    .bind("sortEnd",function(e, t) {
        updateChart();
        });
        $('[data-toggle="popover"]').popover({
            html: true,
            content: function () {
                var content = $(this).attr("data-popover-content");
                return $(content).children(".popover-body").html();
            }

        })
            .on("focus", function () {
                $(this).popover("show");
            }).on("focusout", function () {
            var _this = this;
            if (!$(".popover:hover").length) {
                $(this).popover("hide");
            } else {
                $('.popover').mouseleave(function () {
                    $(_this).popover("hide");
                    $(this).off('mouseleave');
                });
            }
        });
    });
    function downloadSelected(){
        $("#mytable").tableSelectionToCSV();
    }
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
<%
    DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
    LocalDateTime now = LocalDateTime.now();

%>
<div id="fileCitation" style="display:none;">downloaded on: <%=dtf.format(now)%></div>
<table id="mytable" class="tablesorter">
    <thead>
        <tr>
            <th>Strain</th>
            <th>Phenotype</th>
            <th>Conditions</th>

            <th>Study</th>
            <th>Experiment Name</th>
            <th>Trait</th>

            <th>Sex</th>
            <th>Age</th>
            <th># of Animals</th>


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
            <c:if test="${sampleData!=null && fn:length(sampleData)>0}">
                <th>Individual Records</th>
            </c:if>
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

    <script>
        function downloadIndividualValues(strain, measure, units,sex,vals) {

            texts = "Animal ID, Value, Units, Strain, Sex, Phenotype\n";

            if (sex == "both") {
                sex = "";
            }

            lines = vals.split(":");

            for (i=1;i<lines.length;i++) {
                texts+= lines[i].trim();
                texts+= ",";
                texts+= units
                texts+= ",";
                texts+= strain;
                texts+= ",";
                texts+= sex;
                texts+= ",";
                texts+= measure;
                texts+="\n";
            }
            // Create dummy <a> element using JavaScript.
            var hidden_a = document.createElement('a');

            // add texts as a href of <a> element after encoding.
            hidden_a.setAttribute('href', 'data:text/csv;charset=utf-8, '+ encodeURIComponent(texts));

            // also set the value of the download attribute
            hidden_a.setAttribute('download', strain + " (" + measure + ").csv");
            document.body.appendChild(hidden_a);

            // click the link element
            hidden_a.click();
            document.body.removeChild(hidden_a);
        }
    </script>

    <tbody>
        <c:forEach items="${sr.hits.hits}" var="hit">
            <tr>
                <td><a href="/rgdweb/ontology/annot.html?acc_id=${hit.sourceAsMap.rsTermAcc}">${hit.sourceAsMap.rsTerm}</a></td>
                <td><a href="/rgdweb/ontology/annot.html?acc_id=${hit.sourceAsMap.cmoTermAcc}">${hit.sourceAsMap.cmoTerm}</a></td>

                <td>${hit.sourceAsMap.xcoTerm}</td>
                <td>${hit.sourceAsMap.study}</td>
                <td>${hit.sourceAsMap.experimentName}</td>
                <td>${hit.sourceAsMap.vtTerm}</td>
                <td>${hit.sourceAsMap.sex}</td>
                <td>
                    <c:choose>
                        <c:when test="${hit.sourceAsMap.ageLowBound==hit.sourceAsMap.ageHighBound}">
                            ${hit.sourceAsMap.ageHighBound}&nbsp;days
                        </c:when>
                        <c:otherwise>
                            ${hit.sourceAsMap.ageLowBound}&nbsp;days-${hit.sourceAsMap.ageHighBound}&nbsp;days</td>

            </c:otherwise>
                    </c:choose>
                <td>${hit.sourceAsMap.numberOfAnimals}</td>

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
                <c:if test="${sampleData!=null && fn:length(sampleData)>0}">
                    <td>
                        <c:if test="${fn:length(sortedIndividualRecords.get(hit.sourceAsMap.recordId))>0}">
                            <a href="javascript:void(0);" onclick="downloadIndividualValues('${hit.sourceAsMap.rsTerm}','${hit.sourceAsMap.cmoTerm}','${hit.sourceAsMap.units}','${hit.sourceAsMap.sex}','<c:forEach items="${sortedIndividualRecords.get(hit.sourceAsMap.recordId)}" var="r">:${r.animalId},${r.measurementValue}</c:forEach>')">Download Values</a>
                        </c:if>
                    </td>
                </c:if>
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
