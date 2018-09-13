<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.UI" %>
<%@ page import="edu.mcw.rgd.reporting.SearchReportStrategy" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.datamodel.ontology.Annotation" %>
<%@ page import="edu.mcw.rgd.report.AnnotationFormatter" %>
<%@ page import="edu.mcw.rgd.report.ArrayIdFormatter" %>
<%@ page import="edu.mcw.rgd.process.describe.DescriptionGenerator" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.report.MapDataFormatter" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>

<% if (RgdContext.isChinchilla(request)) {%>
<link href="/rgdweb/common/searchNGC.css" rel="stylesheet" type="text/css" />
<% } else { %>
<link href="/rgdweb/common/search.css" rel="stylesheet" type="text/css" />
<% } %>

<link href="/rgdweb/css/report.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="/rgdweb/js/report.js">
</script>


<%
HttpRequestFacade req = (HttpRequestFacade) request.getAttribute("requestFacade");
SimpleDateFormat sdf = new SimpleDateFormat("mm/dd/yyyy");
FormUtility fu = new FormUtility();
UI ui=new UI();
//DisplayMapper dm = new DisplayMapper(req, error);

AnnotationFormatter formatter = new AnnotationFormatter();

String view = request.getParameter("view");
if (view == null || view.equals("")) {
    view="1";
}

%>