<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 3/15/2024
  Time: 12:48 PM
  To change this template use File | Settings | File Templates.
--%>
<p>
    <c:if test="${model.totalHits == 10000}">
        <span style="font-weight: bold">Showing Top</span>
    </c:if>
    <strong style="color:blue">${model.totalHits}</strong> results found for search... <strong><c:out value="${model.searchBean.matchType}"/></strong>&nbsp;<c:if test="${model.term!=''}"><strong style="color:blue">&nbsp;|Term:<c:out value="${model.term}"/></strong></c:if>&nbsp;| Category:<c:out value="${model.searchBean.category}"/>&nbsp;| Assembly <span style="font-weight: bold;color:blue"><c:out value="${model.defaultAssembly}"/></span>
    <c:if test="${model.searchBean.chr!='0' && model.searchBean.chr!=''}">
        &nbsp;|&nbsp;Location <span style="font-weight:bold;font-size: 15px">CHR-<c:out value="${(model.searchBean.chr)}"/>:<c:out value="${model.searchBean.start}-${model.searchBean.stop}"/></span>
    </c:if>
</p>

