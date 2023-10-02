<% if (RgdContext.isCurator()) {%>
<%@ include file="../sectionHeader.jsp"%>
<div id="searchResultHeader" style="border-bottom: 3px solid gray;">
    <ul>
        <li id=selected><a href="javascript:addParam('view',1)">General</a></li>

           <li ><a href="/rgdweb/curation/edit/editCellLine.html?rgdId=<%=obj.getRgdId()%>">Edit Me!</a></li>
    </ul>
</div>
<%@ include file="../sectionFooter.jsp"%>
<% } %>


