<%@ page import="edu.mcw.rgd.dao.impl.SearchDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.datamodel.search.IndexRow" %>

<%
    String seed = "";
    if (request.getParameter("seed") != null) {
        seed = request.getParameter("seed");
    }
%>


<form action="" onsubmit="return false">
    Enter Symbol: <input type="text" name="lookup_entry" id="lookup_entry" size='30' value="<%=seed%>"/>&nbsp;<input type="submit" value="Search" onClick="lookup_checkValue()"/>
</form>

<div id="myDiv" style="border: 1px solid black; height: 300px; overflow:auto;"></div>
