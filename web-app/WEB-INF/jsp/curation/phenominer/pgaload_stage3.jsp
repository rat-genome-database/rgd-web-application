<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Map" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Condition" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.phenominer.PhenominerPgaLoadBean" />
<%
    String pageTitle = "Phenominer Curation";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="editHeader.jsp"%>

<span class="phenominerPageHeader">PGA Load - Atmospheric Conditions</span>

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
    <h3>Atmospheric conditions found in the file</h3>
    <form action="pgaload.html" method="POST">
    <table>
    <tr>
        <th>Atm. Condition (Excel)</th>
        <th>Ont Acc Id</th>
        <th>Value</th>
        <th>Unit</th>
        <th>Notes</th>
    </tr>
    <%  for( Map.Entry<String, Condition> entry: bean.getMapAtmCond().entrySet() ) {
            Condition cond = entry.getValue(); %>
        <tr>
            <td><%=entry.getKey()%></td>
            <td><%=cond.getOntologyId()%></td>
            <td><%=cond.getValue()%></td>
            <td><%=cond.getUnits()%></td>
            <td><%=cond.getNotes()%></td>
        </tr>
    <%}%>
        <tr>
            <th colspan="4">
                <input type="submit" value="Proceed to DIET CONDITIONS">
                <input type="hidden" name="stage" value="stage4">
            </th>
        </tr>
    </table>
    </form>
</div>

<%-- PREVIEW of FIRST FEW LINES FROM THE FILE --%>
<%@ include file="pgaload_file_preview.jsp"%>

<div style="clear:both;"></div>

<%@ include file="editFooter.jsp"%>
