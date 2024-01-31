<%@ page import="edu.mcw.rgd.dao.impl.MyDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.WatchedObject" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c"
           uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: 4/13/2016
  Time: 9:17 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Title</title>
</head>


Manage Alerts<br><br>

<%
    String user = (String) request.getSession().getAttribute("user");

    MyDAO mdao = new MyDAO();

    List<WatchedObject> wos = mdao.getWatchedObjects(user);

    for (WatchedObject wo: wos ) {
        %>



        <input type="checkbox" <c:if test="${wo.getWatchingNomenclature().equals(0)}"> </c:if> />Nomenclature Changes
        <input type="checkbox" />New GO Annotation
        <input type="checkbox" />New Disease Annotation
        <input type="checkbox" />New Phenotype Annotation
        <input type="checkbox" />New Pathway Annotation
        <input type="checkbox" />New PubMed Reference
        <input type="checkbox" />Altered Strains
        <input type="checkbox" />New NCBI Transcript/Protein
        <input type="checkbox" />New Protein Interaction
        <input type="checkbox" />RefSeq Status Has Changed




<%
    }


%>


</body>
</html>
