<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.js"> </script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.widgets.js"></script>


<script src="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.js"></script>
<link href="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.css"/>

<link href="/rgdweb/common/tablesorter-2.18.4/css/filter.formatter.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.jui.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>
<script>
    $(function () {
        $("#findModelsTable").tablesorter({
            theme: 'blue',
            widthFixed: false,
            widgets: ['zebra',"filter",'resizable', 'stickyHeaders'],

        })
    })


</script>
<style>
    .tablesorter thead .disabled {display: none}
</style>
<h3>${model.hitsCount} results for term "${model.term}
    <c:if test="${model.aspect=='D'}">
        &nbsp;&&nbsp;Disease&nbsp;${model.qualifier}
    </c:if>
    <c:if test="${model.aspect=='N'}">
        &nbsp;&&nbsp;Phenotype&nbsp;${model.qualifier}
    </c:if>
    <c:if test="${model.strainType!=null && model.strainType!=''}">
        &nbsp;&&nbsp;${model.strainType}
    </c:if>
    <c:if test="${model.condition!=null && model.condition!=''}">
       &nbsp;&&nbsp;${model.condition}
    </c:if>
    "
   </h3>
<table id="findModelsTable" class="tablesorter">
    <thead>
    <tr>
        <th class="tablesorter-header"data-placeholder="Search for strain..." >Strain</th>
        <!--th>Model RGD ID</th>
        <th>Species</th-->
        <th class="tablesorter-header" data-filter="false" style=" cursor: pointer; width:6%;text-align:left" title="Click to Sort">Considered as type ...</th>
        <th class="tablesorter-header" data-filter="false" style=" cursor: pointer; width:6%;text-align:left" title="Click to Sort">Disease/Phenotype</th>

        <th class="tablesorter-header" data-filter="false" style=" cursor: pointer; width:6%;text-align:left" title="Click to Sort">With conditions</th>

        <th class="tablesorter-header" data-filter="false" style=" cursor: pointer; width:6%;text-align:left" title="Click to Sort">Evidence Code</th>
        <th class="tablesorter-header" data-filter="false" style=" cursor: pointer; width:6%;text-align:left" title="Click to Sort">Reference</th>

    </tr>
    </thead>
    <tbody>
    <c:forEach items="${model.searchHits}" var="hitArray">
        <c:forEach items="${hitArray}" var="hit">
            <tr>
                <td><a href="/rgdweb/report/strain/main.html?id=${hit.getSourceAsMap().annotatedObjectRgdId}">${hit.getSourceAsMap().annotatedObjectSymbol}</a></td>
                <!--td>$-{hit.getSourceAsMap().annotatedObjectRgdId}</td>
                <td>$-{hit.getSourceAsMap().species}</td-->
                <td>
                    <c:forEach items="${hit.getSourceAsMap().qualifiers}" var="q">
                        <c:out value="${q}"/>&nbsp;
                    </c:forEach>
             </td>
                <td><a href="/rgdweb/report/annotation/main.html?term=${hit.getSourceAsMap().termAcc}&id=${hit.getSourceAsMap().annotatedObjectRgdId}">${hit.getSourceAsMap().term}</a> &nbsp;&nbsp;<a href="/rgdweb/ontology/view.html?acc_id=${hit.getSourceAsMap().termAcc}"><img border="0" src="/rgdweb/common/images/tree.png" title="click to browse the term" alt="term browser"></a>
                </td>

                <!--td>$-{hit.getSourceAsMap().withInfoTerms}</td-->
                <td>
                    <c:set var="first" value="true"/>
                    <c:forEach items="${hit.getSourceAsMap().infoTerms}" var="xco">
                        <c:choose>
                            <c:when test="${first==true}">
                                <a href="/rgdweb/ontology/annot.html?acc_id=${xco.accId}">${xco.term}</a>
                                <c:set var="first" value="false"/>
                            </c:when>
                            <c:otherwise>
                               |&nbsp; <a href="/rgdweb/ontology/annot.html?acc_id=${xco.accId}">${xco.term}</a>

                            </c:otherwise>
                        </c:choose>

                    </c:forEach>
                </td>

                <td>
                    <c:forEach items="${hit.getSourceAsMap().evidences}" var="e">
                        <span title="${e.name}" >${e.evidence}</span>&nbsp;
                    </c:forEach>
                </td>
                <td>
                    <c:forEach items="${hit.getSourceAsMap().refRgdIds}" var="ref">
                        <a href="/rgdweb/report/reference/main.html?id=${ref}">${ref}</a>&nbsp;
                    </c:forEach>

                </td>

            </tr>
        </c:forEach>
    </c:forEach>
    </tbody>
</table>





