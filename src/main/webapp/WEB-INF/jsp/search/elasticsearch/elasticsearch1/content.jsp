<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<div id="results">
    <input type ="hidden" name="mapKey" id="mapKey" value="${model.mapKey}"/>
<table width="100%">
    <tr><td><div><jsp:include page="actions.jsp"/></div></td></tr>
    <tr><td><div ><jsp:include page="results.jsp"/></div></td></tr>
</table>

</div>
<script type="text/javascript" src="/rgdweb/js/elasticsearch/elasticsearch.js"></script>
<%-- The stylesheet link that was here pointed at /rgdweb/css/elasticserch.css: misspelled, in the
     wrong directory and with no rel="stylesheet", so it was a 404 the browser ignored - re-fetched
     on every AJAX page swap, since this file is what the paging calls replace. The real file is
     css/elasticsearch/elasticsearch.css and headerarea.jsp already loads it. --%>