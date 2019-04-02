<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Iterator" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String sample = request.getAttribute("sample").toString();
    String title = "Damaging Variants Report for strain "+sample;
    String pageDescription = title;
    String headContent = "";
    String pageTitle = title;




    Report report = (Report) request.getAttribute("report");
    Set geneList = (Set) request.getAttribute("geneList");
    int sampleId = (int) request.getAttribute("sampleId");
    int mapKey = (int) request.getAttribute("mapKey");
    int species = (int) request.getAttribute("species");
    String a= new String();
%>
<%@ include file="/common/compactHeaderArea.jsp" %>
<div class="container-fluid" style="background-color: white ">
<br>
    <table style="margin: 2%">
        <tr>
            <td>
                <b> Genes in Set: <%= geneList.size() %></b><br>
                <div style="overflow: auto; width: 90%; height: 100px; color: #2b669a">

                    <% Iterator itr = geneList.iterator();
                        while(itr.hasNext()) {
                            String symbol = (String)itr.next();
                    %>
                    <span class="geneList"><%=symbol%></span> &nbsp;

                    <% }%>
                </div>
            </td>
        <td> <img src="/rgdweb/common/images/tools-white-50.png" style="cursor:hand; border: 2px solid black;" border="0" ng-click="rgd.showTools('geneList',<%=species%>,<%=mapKey%>,'<%=1%>','<%=a%>')"/>
            <a  style="font-size:20px;" href="javascript:void(0)"; ng-click="rgd.showTools('geneList',<%=species%>,<%=mapKey%>,'<%=1%>','<%=a%>')">Analyze&nbsp;Gene&nbsp;Set</a></td>
        </tr>
     </table>
<br>
<table style="margin: 2%">
     <tr>
        <td style="color:#2865a3; font-size:16px; font-style:italic; font-weight:700;"><%=title%></td>
        <td><span class="detailReportLink"><a href="/rgdweb/report/strain/damagingVariants.html?id=<%=sampleId%>&fmt=csv&map=<%=mapKey%>">Download Variants</a></span></td>

    </tr>
    <tr>
        <td colspan="2"><%=report.format(new HTMLTableReportStrategy())%></td>
    </tr>
</table>
</div>

