<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.dao.impl.ReferenceDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Reference" %>
<%
    String pageTitle = "Studies";
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="editHeader.jsp"%>
<%

    List<String> idList = req.getParameterValues("studyId");
    Report report = (Report) request.getAttribute("report");

    Study study = new Study();
    if (idList.size()==0) {
        study.setSource("RGD");
        study.setType("Published Paper");
    }

    String title = "Create Study";
    String ref = req.getParameter("referenceId");
    ReferenceDAO refDAO = new ReferenceDAO();

    if (!ref.equals("")) {
        Reference reference = refDAO.getReference(Integer.parseInt(ref));
        study.setName(reference.getCitation());        
    }

    if (idList.size() == 1) {
        study = dao.getStudy(Integer.parseInt(idList.get(0)));
//        ref=study.getRefRgdId().toString();
    }

    if (idList.size() > 0) {
        title="Edit Study";
    }
    
%>
<span class="phenominerPageHeader"><%=title%></span>

<div class="phenoNavBar">
<table >
    <tr>
        <td><a href='studies.html?act=new'>Create New Study</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='home.html'>Home</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='search.html?act=new'>Search</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='studies.html'>List All Studies</a></td>
    </tr>
</table>
</div>


<%
    if (report != null) {

        HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
        strat.setTableProperties("class='sortable'");

        out.print(report.format(strat));
    }    
%>

<form action="studies.html" method="get" >

<input type="hidden" name="act" value="save"/>

<% for (String id: idList)  { %>
    <input type="hidden" name="studyId" value="<%=id%>"/>
<% } %>

    <br>
<table border="0">
    <tr>
        <td>Name:</td>
        <td><input type="text" size="80" name="name" id="name" value="<%=dm.out("name", study.getName())%>"> </td>
    </tr>
    <tr>
        <td>Source:</td><td><input type="text" size="30" name="source" id="source" value="<%=dm.out("source", study.getSource())%>"> </td>
    </tr>
    <tr>
        <td>Type:</td><td><input size="40" type="text" name="type" id="type" value="<%=dm.out("type", study.getType())%>"> </td>
    </tr>
    <tr>
        <td>Reference(s):</td><td>
        <%int i = 0;
        for (i = 0; i < study.getRefRgdIds().size(); i++){%>
        <input type="text" size="15" name="refRgdId<%=i%>" id="refRgdId<%=i%>" value="<%=dm.out("refRgdId"+i, study.getRefRgdIds().get(i))%>">
        <% }
        for (int j = i; j < 3; j++){%>
            <input type="text" size="15" name="refRgdId<%=i%>" id="refRgdId<%=i%>" value="<%=dm.out("refRgdId"+i, "")%>">
        <%  } %></td>
    </tr>
    <tr>
        <td>Data Type:</td><td><input size="40" type="text" name="dataType" id="dataType" value="<%=dm.out("dataType", study.getDataType())%>"> </td>
    </tr>
    <tr>
        <td>GEO Series Acc:</td><td><input size="40" type="text" name="geoSeriesAcc" id="geoSeriesAcc" value="<%=dm.out("geoSeriesAcc", study.getGeoSeriesAcc())%>"> </td>
    </tr>
    <tr>
        <td>Created By:</td><td><input size="40" type="text" name="createdBy" id="createdBy" value="<%=dm.out("createdBy", study.getCreatedBy())%>" > </td>
    </tr>
    <tr>
        <td>Last Modified By:</td><td><input size="40" type="text" name="modifiedBy" id="modifiedBy" value="<%=dm.out("modifiedBy", study.getLastModifiedBy())%>"> </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td>Curation status:</td><td><%=fu.buildSelectList("sStatus", dao.getEnumerableMap(6, 0, true), "")%> </td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td colspan="2" align="right"><input type="submit" value="Save Study"></td>
    </tr>


</table>




</form>

<%@ include file="editFooter.jsp"%>