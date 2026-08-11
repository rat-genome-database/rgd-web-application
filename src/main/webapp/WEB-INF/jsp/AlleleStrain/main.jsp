<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    String pageTitle = "Alleles and Mutated Strains";
    String pageDescription = "Alleles and mutated strains for the submitted gene list";
    String headContent = "";
%>
<%@ include file="/common/headerarea.jsp"%>

<link rel="stylesheet" href="/rgdweb/common/bootstrap/css/bootstrap.css">
<script src="/rgdweb/common/bootstrap/js/bootstrap.js"></script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.js"></script>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>

<style>
    #alleleStrainContent { width: 90%; margin: 20px auto; }
    #alleleStrainContent h2 { margin-bottom: 8px; }
    #alleleStrainContent .summary { color: #555; margin-bottom: 16px; }
    #alleleStrainContent table { width: 100%; table-layout: auto; border-collapse: collapse; }
    #alleleStrainContent th,
    #alleleStrainContent td {
        vertical-align: top;
        padding: 8px 10px;
        line-height: 1.5;
        word-break: break-word;
        border: 1px solid #ddd;
    }
    #alleleStrainContent th {
        background-color: #24609c;
        color: #fff;
        white-space: nowrap;
    }
    #alleleStrainContent tbody tr:nth-child(odd) td { background-color: #fafafa; }
    #alleleStrainContent sup,
    #alleleStrainContent sub {
        font-size: 0.75em;
        line-height: 1;
        vertical-align: baseline;
        position: relative;
    }
    #alleleStrainContent sup { top: -0.5em; }
    #alleleStrainContent sub { bottom: -0.25em; }
    #alleleStrainContent tr.no-hits td { font-style: italic; color: #777; }
</style>

<div id="alleleStrainContent">
    <h2>Alleles and Mutated Strains</h2>
    <div class="summary">
        <c:choose>
            <c:when test="${empty submittedSymbols}">
                No gene symbols were submitted.
            </c:when>
            <c:otherwise>
                Showing results for ${fn:length(submittedSymbols)} submitted gene
                <c:choose><c:when test="${fn:length(submittedSymbols) == 1}">symbol</c:when><c:otherwise>symbols</c:otherwise></c:choose>.
            </c:otherwise>
        </c:choose>
    </div>

    <c:if test="${not empty submittedSymbols}">
        <div class="controls" style="margin-bottom: 12px; display: flex; align-items: center; gap: 16px;">
            <label style="cursor: pointer; user-select: none; font-size: 12px">
                <input type="checkbox" id="hideNoHits"> Hide genes with no alleles / mutated strains
            </label>
            <button type="button" id="downloadTsv" class="btn btn-primary btn-sm">Download TSV</button>
        </div>
        <table id="alleleStrainTable" class="tablesorter table table-striped table-bordered">
            <thead>
                <tr>
                    <th>Gene Symbol</th>
                    <th>Allele Symbol</th>
                    <th>Strain Symbol</th>
                    <th>Background Strain</th>
                    <th>Modification Method</th>
                    <th>Origination</th>
                    <th>Source</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach var="entry" items="${geneStrainMap}">
                    <c:set var="geneSymbol" value="${entry.key}"/>
                    <c:set var="models" value="${entry.value}"/>

                    <c:choose>
                        <c:when test="${empty models}">
                            <tr class="no-hits">
                                <td>
                                    <strong>${geneSymbol}</strong>
                                </td>
                                <td>No alleles / mutated strains found</td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td></td>
                                <td></td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="m" items="${models}" varStatus="loop">
                                <tr>
                                    <td>
                                        <a href="/rgdweb/report/gene/main.html?id=${m.geneRgdId}"
                                           target="_blank">${m.geneSymbol}</a>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${m.alleleRgdId > 0}">
                                                <a href="/rgdweb/report/gene/main.html?id=${m.alleleRgdId}"
                                                   target="_blank">${m.alleleSymbol}</a>
                                            </c:when>
                                            <c:otherwise>${m.alleleSymbol}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${m.strainRgdId > 0}">
                                                <a href="/rgdweb/report/strain/main.html?id=${m.strainRgdId}"
                                                   target="_blank">${m.strainSymbol}</a>
                                            </c:when>
                                            <c:otherwise>${m.strainSymbol}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${m.backgroundStrainRgdId > 0}">
                                                <a href="/rgdweb/report/strain/main.html?id=${m.backgroundStrainRgdId}"
                                                   target="_blank">
                                                    <c:choose>
                                                        <c:when test="${not empty m.backgroundStrain}">${m.backgroundStrain}</c:when>
                                                        <c:otherwise>RGD:${m.backgroundStrainRgdId}</c:otherwise>
                                                    </c:choose>
                                                </a>
                                            </c:when>
                                            <c:otherwise>${m.backgroundStrain}</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${m.method}</td>
                                    <td>${m.origination}</td>
                                    <td>${m.source}</td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>
            </tbody>
        </table>
    </c:if>
</div>

<script>
    $(function () {
        if ($('#alleleStrainTable').length) {
            $('#alleleStrainTable').tablesorter({
                theme: 'blue',
                sortList: [[0, 0]]   // default: sort by Gene Symbol ascending
            });
        }

        $('#hideNoHits').on('change', function () {
            $('#alleleStrainTable tr.no-hits').toggle(!this.checked);
        });

        function cellText(cell) {
            // keep ONLY <sup> tags; strip every other tag (links, <i>, tablesorter header divs, etc.)
            // and collapse whitespace so stray tabs/newlines don't break the TSV columns
            return $(cell).html()
                .replace(/<(?!\/?sup\b)[^>]*>/gi, '')   // remove all tags except <sup> / </sup>
                .replace(/\s+/g, ' ')
                .trim();
        }

        $('#downloadTsv').on('click', function () {
            var $table = $('#alleleStrainTable');
            if (!$table.length) return;

            var lines = [];

            // header row
            var headers = [];
            $table.find('thead th').each(function () { headers.push(cellText(this)); });
            lines.push(headers.join('\t'));

            // body rows — only those currently visible (respects the hide-no-hits filter)
            $table.find('tbody tr:visible').each(function () {
                var cols = [];
                $(this).find('td').each(function () { cols.push(cellText(this)); });
                lines.push(cols.join('\t'));
            });

            var tsv = lines.join('\r\n');
            var blob = new Blob([tsv], { type: 'text/tab-separated-values;charset=utf-8;' });
            var url = URL.createObjectURL(blob);
            var a = document.createElement('a');
            a.href = url;
            a.download = 'alleles_and_mutated_strains.tsv';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        });
    });
</script>

<%@ include file="/common/footerarea.jsp"%>
