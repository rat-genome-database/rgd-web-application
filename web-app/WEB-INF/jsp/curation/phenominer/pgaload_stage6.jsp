<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Map" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.phenominer.PhenominerPgaLoadBean" />
<%
    String pageTitle = "Phenominer Curation";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="editHeader.jsp"%>

<span class="phenominerPageHeader">PGA Load - Rat Diet</span>

<div class="phenoNavBar">
<table >
    <tr>
        <td><a href='home.html'>Home</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='search.html?act=new'>Search</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='studies.html'>List All Studies</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='pgaload.html'>PGA Load</a></td>
    </tr>
</table>
</div>

<%-- SIDEBAR --%>
<%@ include file="pgaload_sidebar.jsp"%>

<%-- LIST OF STRAINS FOUND IN THE FILE --%>
<div class="pga_main">
    <h3>Rat diet codes found in the file</h3>
    <form action="pgaload.html" method="POST">
    <table>
    <tr>
        <th>Rat diet code (Excel)</th>
        <th>Description</th>
    </tr>
        <c:if test="${!empty bean.mapRatDiet}">
    <%  for( Map.Entry<String, String> entry: bean.getMapRatDiet().entrySet() ) { %>
        <tr>
            <td><%=entry.getKey()%></td>
            <td><%=entry.getValue()%></td>
        </tr>
    <%}%>
        </c:if>
        <tr>
            <th colspan="2">
                <input type="submit" value="Proceed to PHENOTYPES">
                <input type="hidden" name="stage" value="stage7">
            </th>
        </tr>
    </table>
    </form>
</div>

<%-- PREVIEW of FIRST FEW LINES FROM THE FILE --%>
<%@ include file="pgaload_file_preview.jsp"%>

<div style="clear:both;"></div>

<%@ include file="editFooter.jsp"%>
