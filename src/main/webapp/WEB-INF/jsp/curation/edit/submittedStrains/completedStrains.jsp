<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<h3 style="color:grey">COMPLETED & DENIED STRAINS (${fn:length(model.completedStrains)})</h3>

<hr>
<div>

    <table class="table table-striped" >
        <thead>
        <tr>
            <th style="font-size:small;">Key</th>
            <th style="font-size:small;">Gene Symbol</th>
            <th style="font-size:small;">Allele Symbol</th>
            <th style="font-size:small;">Strain Symbol</th>
            <th style="font-size:small;width:15%">Display Status</th>
            <th style="font-size:small;width:20%">Origination</th>
            <th style="font-size:small;">Date of Completion</th>
            <th style="font-size:small;">Status</th>
        </tr>
        </thead>
        <tbody>
        <!--c:set var="sortedStrains" value="$--{m:sortByGeneSymbol(model.submittedStrains)}"/-->
        <c:forEach items="${model.completedStrains}" var="s">
            <tr>
                <td>${s.submittedStrainKey}</td>
                <td><a href="/rgdweb/report/gene/main.html?id=${s.geneRgdId}" title="RGD Gene Report" target="_blank">${s.geneSymbol}</a></td>
                <td><a href="/rgdweb/report/gene/main.html?id=${s.alleleRgdId}" title="RGD Allele Report" target="_blank">${s.alleleSymbol}</a></td>
                <td><a href="/rgdweb/report/strain/main.html?id=${s.strainRgdId}" title="RGD Strain Report" target="_blank">${s.strainSymbol}</a></td>
                <td>${s.displayStatus}</td>
                <td>${s.source}</td>
                <td>${s.last_updated_date}</td>
                <td>
                    <form action="editStrains.html?statusUpdate=true&submissionKey=${s.submittedStrainKey}" method="post">
                        <select class="form-control" class="status" name="status" onchange="this.form.submit()" >
                            <option  value="${s.approvalStatus}" selected >${s.approvalStatus}</option>
                            <c:if test="${s.approvalStatus!='submitted'}">
                                <option value="submitted">submitted</option>
                            </c:if>
                            <c:if test="${s.approvalStatus!='incomplete'}">
                                <option value="incomplete">incomplete</option>
                            </c:if>
                            <c:if test="${s.approvalStatus!='complete'}">
                                <option value="complete">complete</option>
                            </c:if>
                            <c:if test="${s.approvalStatus!='denied'}">
                                <option value="denied">denied</option>
                            </c:if>
                        </select>
                    </form>
                </td>
            </tr>
        </c:forEach>
        </tbody>
    </table>
</div>