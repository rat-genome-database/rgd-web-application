<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Map" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Experiment" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.phenominer.PhenominerPgaLoadBean" />
<%
    String pageTitle = "Phenominer Curation";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="editHeader.jsp"%>

<span class="phenominerPageHeader">PGA Load - Experiments</span>

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
    <h3>List of Experiments to be created</h3>
    <form action="pgaload.html" method="POST">
    <table class="pga_tab">
    <tr>
        <th>Nr</th>
        <th>Experiment Name</th>
        <th>Experiment Notes</th>
    </tr>
    <%  int i=0;
        for( Experiment exp: bean.getExperiments() ) { i++; %>
        <tr>
            <td><%=i%>.</td>
            <td><%=exp.getName()%></td>
            <td><%=exp.getNotes()%></td>
        </tr>
    <%}%>
    </table>
    </form>

    <div style="margin-left:150px;">
    <form action="pgaload.html" method="POST">
        <input type="submit" value="Proceed to EXPERIMENT RECORDS">
        <input type="hidden" name="stage" value="stage9">
    </form>
    </div>
</div>

<%-- PREVIEW of FIRST FEW LINES FROM THE FILE --%>
<%@ include file="pgaload_file_preview.jsp"%>

<div style="clear:both;"></div>

<%@ include file="editFooter.jsp"%>
