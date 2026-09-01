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
<%-- Utils reaches these pages today only because some deeply nested include happens to
     import it; naming it here makes every report page independent of that. --%>
<%@ page import="edu.mcw.rgd.process.Utils" %>

<% if (RgdContext.isChinchilla(request)) {%>
<link href="/rgdweb/common/searchNGC.css" rel="stylesheet" type="text/css" />
<% } else { %>
<link href="/rgdweb/common/search.css" rel="stylesheet" type="text/css" />
<% } %>

<link href="/rgdweb/css/report.css?v=3" rel="stylesheet" type="text/css" />

<%-- The modern report skin. It lives here rather than in each report's main.jsp because every
     report page includes this file, and almost every rule in it is scoped under
     .rgd-modern-report - so a page that does not carry that class on #page-container is
     unaffected by loading it. --%>
<link href="/rgdweb/css/reportModern.css?v=8" rel="stylesheet" type="text/css" />

<%
    // The class that turns the skin on, computed once. Static includes share a translation
    // unit, so every page that includes this file can use it on its #page-container.
    String reportSkinClass = RgdContext.isChinchilla(request) ? "rgd-modern-report chinchilla" : "rgd-modern-report";

    // Defaults for the report hero (see reportHero.jsp). They live here so a page only has to
    // set what it actually has - a report with no species, no RGD id or no extra action can
    // include the hero without touching those fields at all.
    String heroEyebrow = "Report";
    String heroTitle = "";
    String heroTitleClass = "";
    String heroShortName = "";
    String heroSubtitle = "";
    String heroIcon = "";
    int heroSpeciesKey = 0;
    int heroRgdId = 0;
    java.util.List<String> heroChips = new java.util.ArrayList<String>();
    String heroAnalyze = null;
    String heroTutorialLink = null;
    String heroExtraActions = "";
    boolean heroWatch = true;
%>

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