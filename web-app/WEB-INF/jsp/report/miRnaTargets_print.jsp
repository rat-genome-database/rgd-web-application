<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head><title>miRNA Targets Report for <%=request.getAttribute("geneSymbol").toString()%></title></head>
  <body >
  <%
      Report report = (Report) request.getAttribute("report");

      if (RgdContext.isChinchilla(request)) {
          out.print("<img src='/common/images/ngcLogo.jpg'/><br><br>");
      }else {
          out.print("<img src='/common/images/rgd_LOGO_blue_rgd.gif'/><br><br>");
      }

      out.println(report.format(new HTMLTableReportStrategy()));
  %>
  <script>
      setTimeout("window.print()",100);
  </script>

  </body>
</html>