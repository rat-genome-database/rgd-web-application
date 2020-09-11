<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>

<%
String pageTitle = "test";
String headContent = "test";
String pageDescription = "test";

%>

<%@ include file="/rgd/common/headerarea.jsp"%>
<%@ include file="../../front/carpeHeader.jsp"%>



<%


    List list = (List) request.getAttribute("sampleList");


%>

<table >
    <tr>
        <td style="font-size:22px;">Carpe Novo</td>
    </tr>
    <tr>
        <td style="font-size:14px;">Select a Sample</td>
    </tr>
</table>


<table border="0" class="carpeNavTable" align="center" style="border: 1px dotted black;">
    <tr>
        <td class="carpeLabelHeader">ID</td>
        <td class="carpeLabelHeader">Date</td>
        <td class="carpeLabelHeader">Name</td>
        <td class="carpeLabelHeader">Analyst</td>
        <td class="carpeLabelHeader">Sequencer</td>
        <td class="carpeLabelHeader">Description</td>
        <td class="carpeLabelHeader">Directory</td>
        <td class="carpeLabelHeader">Geneticist</td>
    </tr>
<%
    Iterator it = list.iterator();
    while (it.hasNext()) {
        Sample s = (Sample)it.next();
    %>
    <tr>
        <td><a href="search.html?pid=<%=request.getParameter("pid")%>&sid=<%=s.getId()%>"> <%=s.getId()%></a></td>
        <td><%=s.getAnalystDate()%></td>
        <td><%=s.getAnalysisName()%></td>
        <td><%=s.getAnalyst()%></td>
        <td><%=s.getSequencer()%></td>
        <td><%=s.getDescription()%></td>
        <td><%=s.getDirectory()%></td>
        <td><%=s.getGeneticist()%></td>
    </tr>

    <%
    }
%>

<%@ include file="/rgd/common/footerarea.jsp"%>