<%@ include file="../sectionHeader.jsp"%>

<div id="searchResultHeader" style="border-bottom: 3px solid gray;">

    <ul>
<%--            <li id=selected><a href="javascript:addParam('view',1)">General</a></li>--%>
            <!-- these comments between li's solve a problem in IE that prevents spaces appearing between list items that appear on different lines in the source
            -->
        <% if (RgdContext.isCurator()) {%>
           <li ><a href="/rgdweb/curation/edit/editProject.html?rgdId=<%=obj.getRgdId()%>">Edit Me!</a></li>
           <li ><a href="/rgdweb/curation/edit/editProject.html?act=clone&rgdId=<%=obj.getRgdId()%>">Clone Me!</a></li>
        <% } %>
    </ul>

</div>

<%@ include file="../sectionFooter.jsp"%>