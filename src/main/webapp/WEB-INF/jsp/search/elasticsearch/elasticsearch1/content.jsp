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
<link type="text/css" href="/rgdweb/css/elasticserch.css"/>