<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String title = "miRNA Targets Report for gene "+request.getAttribute("geneSymbol").toString();
    Report report = (Report) request.getAttribute("report");
%>
<html>
  <head><title><%=title%></title></head>
  <body>
  <table>
      <tr>
          <%
          if (RgdContext.isChinchilla(request)) {
          out.print("<img src='/common/images/ngcLogo.jpg'/><br><br>");
          }else {
          out.print("<img src='/common/images/rgd_LOGO_blue_rgd.gif'/><br><br>");
          }
          %>
          <td style="color:#2865a3; font-size:16px; font-style:italic; font-weight:700;"><%=title%></td>
      </tr>
      <tr>
          <td colspan="2"><%=report.format(new HTMLTableReportStrategy())%></td>
      </tr>
  </table>
  </body>
</html>