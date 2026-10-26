<%@ include file="../sectionHeader.jsp"%>

<% String viewNr = Utils.NVL(request.getParameter("view"), "1");
%>
<div id="searchResultHeader" style="border-bottom: 3px solid gray;">
    <ul>
        <li <%=viewNr.equals("1")?"id=selected":""%>><a href="javascript:addParam('view',1)">General</a></li>
        <!-- these comments between li's solve a problem in IE that prevents spaces appearing between list items that appear on different lines in the source
        -->
        <%-- Array IDs is a section of the report body now, under External Database Links,
             so it no longer needs a tab of its own. --%>
        <!--
        -->
<%--        <li <%=viewNr.equals("5")?"id=selected":""%>><a href="javascript:addParam('view',5)">References</a></li>--%>
        <% if (RgdContext.isCurator()) {%>
        <!--
        -->
        <li ><a href="/rgdweb/curation/edit/editGene.html?edit=new&objectType=editGene.html&rgdId=<%=obj.getRgdId()%>">Edit Me!</a></li>
        <% } %>
    </ul>
</div>

<%@ include file="../sectionFooter.jsp"%>
