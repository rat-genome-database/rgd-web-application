<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Map" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.phenominer.PhenominerPgaLoadBean" />
<%
    String pageTitle = "Phenominer Curation";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="editHeader.jsp"%>

<span class="phenominerPageHeader">PGA Load - Phenotypes</span>

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
    <h3>Phenotypes found in the file</h3>
    <form action="pgaload.html" method="POST">
    <table class="pga_tab">
    <tr>
        <th>Column in Excel</th>
        <th>Unit</th>
        <th>Cmo Acc Id</th>
        <th>Cmo Acc Status</th>
        <th>Cmo Term Name</th>
        <th>Mmo Acc Id</th>
        <th>Mmo Acc Status</th>
        <th>Mmo Term Name</th>
    </tr>
    <%  for( Map<String, Object> map: bean.getPhenotypes() ) {
             %>
        <tr>
            <td><%=map.get("col_name")%></td>
            <td><%=map.get("unit")%></td>

            <td><input type="text" name="cmo_acc_id" value="<%=map.get("cmo_acc_id")%>">
                <input type="hidden" name="cmo_phenotype" value="<%=map.get("phenotype")%>">
            </td>
            <td><%=map.get("cmo_acc_status")%></td>
            <td><%=map.get("cmo_term_name")%></td>

            <td><input type="text" name="mmo_acc_id" value="<%=map.get("mmo_acc_id")%>">
                <input type="hidden" name="mmo_phenotype" value="<%=map.get("phenotype")%>">
            </td>
            <td><%=map.get("mmo_acc_status")%></td>
            <td><%=map.get("mmo_term_name")%></td>
        </tr>
    <%}%>
        <tr>
            <th colspan="8">
            <input type="submit" value="Save Phenotype Mappings">
            <input type="hidden" name="stage" value="stage7">
            </th>
        </tr>
    </table>
    </form>

    <div style="margin-left:150px;">
    <form action="pgaload.html" method="POST">
        <input type="submit" value="Proceed to EXPERIMENTS">
        <input type="hidden" name="stage" value="stage8">
    </form>
    </div>
</div>

<%-- PREVIEW of FIRST FEW LINES FROM THE FILE --%>
<%@ include file="pgaload_file_preview.jsp"%>

<div style="clear:both;"></div>

<%@ include file="editFooter.jsp"%>
