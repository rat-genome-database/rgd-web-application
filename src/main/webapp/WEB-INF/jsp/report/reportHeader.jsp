<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.reporting.SearchReportStrategy" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.datamodel.ontology.Annotation" %>
<%@ page import="edu.mcw.rgd.report.AnnotationFormatter" %>
<%@ page import="edu.mcw.rgd.report.ArrayIdFormatter" %>
<%@ page import="edu.mcw.rgd.process.describe.DescriptionGenerator" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.report.MapDataFormatter" %>
<%@ page import="edu.mcw.rgd.web.*" %>

<% if (RgdContext.isChinchilla(request)) {%>
<link href="/rgdweb/common/searchNGC.css" rel="stylesheet" type="text/css" />
<% } else { %>
<link href="/rgdweb/common/search.css" rel="stylesheet" type="text/css" />
<% } %>

<link href="/rgdweb/css/report.css?v=2" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="/rgdweb/js/report.js?v=6">
</script>

<script src="/rgdweb/common/jquery-ui/jquery-ui.js">

</script>



<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.js"> </script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.widgets.js"></script>


<script src="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.js"></script>
<link href="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.css"/>

<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.jui.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>











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