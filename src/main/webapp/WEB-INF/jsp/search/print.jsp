<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: Jun 13, 2008
  Time: 10:43:43 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head><title><%=RgdContext.getSiteName(request)%> Report</title></head>
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