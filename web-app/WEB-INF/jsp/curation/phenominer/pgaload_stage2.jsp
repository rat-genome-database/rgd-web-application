<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.Map" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<jsp:useBean id="bean" scope="request" class="edu.mcw.rgd.phenominer.PhenominerPgaLoadBean" />
<%
    String pageTitle = "Phenominer Curation";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="editHeader.jsp"%>

<span class="phenominerPageHeader">PGA Load - Rat Strains</span>

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
    <h3>Strains found in the file</h3>
    <div style="background-color:#b2d1ff;border:solid 1px black;">
        There are <%=bean.getMapStrains().size()%> rat strains found in the file.
        There are <%=bean.getUnmappedStrainCount()%> rat strains without strain ontology accession id assigned.
    </div>
    <form action="pgaload.html" method="POST">
    <table>
    <tr>
        <th>Strain in Excel</th>
        <th>Ont Acc Id</th>
        <th>Ont Term Name</th>
        <th>Match By</th>
    </tr>
    <%  for( Map.Entry<String, Term> entry: bean.getMapStrains().entrySet() ) {
            Term term = entry.getValue(); %>
        <tr>
            <td><%=entry.getKey()%></td>
            <% if(term.getAccId().isEmpty() || term.getComment().equals("custom mapping")) { %>
            <td><input type="text" name="map_acc_id" value="<%=term.getAccId()%>">
                <input type="hidden" name="map_term" value="<%=entry.getKey()%>">
            </td>
            <% } else { %>
            <td><%=term.getAccId()%></td>
            <%}%>
            <td><%=term.getTerm()%></td>
            <td><%=term.getComment()%></td>
        </tr>
    <%}%>
        <tr>
            <th colspan="4">
            <input type="submit" value="Save Strain Custom Mappings">
            <input type="hidden" name="stage" value="stage2">
            </th>
        </tr>
    </table>
    </form>

    <div style="margin-left:150px;">
    <form action="pgaload.html" method="POST">
        <input type="submit" value="Proceed to ATMOSPHERIC CONDITIONS">
        <input type="hidden" name="stage" value="stage3">
    </form>
    </div>
</div>

<%-- PREVIEW of FIRST FEW LINES FROM THE FILE --%>
<%@ include file="pgaload_file_preview.jsp"%>

<div style="clear:both;"></div>

<%@ include file="editFooter.jsp"%>
