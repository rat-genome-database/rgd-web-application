

<%
    String pageTitle = "Phenominer Curation";
    String headContent = "";
    String pageDescription = "";


%>


<%@ include file="editHeader.jsp"%>

<form action="upload.html" method="post">
    <textarea name="data" rows="40" cols="100"></textarea>
    <input type="submit" />
</form>



<%@ include file="editFooter.jsp"%>
