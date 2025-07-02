<%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Identifiable" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.OntologyEnrichment" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.TermWrapper" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.web.UI" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.LinkedHashMap" %>


<link href="/rgdweb/ga/ga.css" rel="stylesheet" type="text/css"/>
<!--link href="/rgdweb/js/jsor-jcarousel-7bb2e0a/style.css" rel="stylesheet" type="text/css"/-->
<script src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>


<script type="text/javascript" src="https://www.google.com/jsapi"></script>


<%@ include file="/common/googleAnalytics.jsp" %>
<script>

function regHeader(title) {
    document.getElementById(title).onclick = showSection;
    document.getElementById(title + "_i").onclick = showSection;
    document.getElementById(title + "_content").style.display = "none";
}

function showSection(e) {

    if (!e) e = window.event;
    var obj = document.all ? e.srcElement : e.currentTarget;

    if (document.all) {
        if (obj.id.indexOf("_i") != -1) {
            var name = obj.id.substring(0,obj.id.indexOf("_i"));
            obj=document.getElementById(name);
        }
        window.event.cancelBubble = true;
    }else {

    }

        var content =  document.getElementById(obj.id + "_content");
        if (content) {
            if (content.style.display == "block") {
                content.style.display="none";
                document.getElementById(obj.id + "_i").src = "/rgdweb/common/images/add.png";
            }else {
                content.style.display="block";
                document.getElementById(obj.id + "_i").src = "/rgdweb/common/images/remove.png";
            }
        }

}
</script>

<%
    //initializations
    HttpRequestFacade req = new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req,  new java.util.ArrayList());
    FormUtility fu = new FormUtility();
    UI ui=new UI();
    AnnotationDAO adao = new AnnotationDAO();
    GeneDAO gdao = new GeneDAO();

    ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");
    List termSet= Utils.symbolSplit(req.getParameter("terms"));
    List<TermWrapper> termWrappers = new ArrayList();

    LinkedHashMap aspects = new LinkedHashMap();
    aspects.put("D","Disease");
    aspects.put("W","Pathway");
    aspects.put("N","Phenotype");
    aspects.put("P","GO: Biological Process");
    aspects.put("C","GO: Cellular Component");
    aspects.put("F","GO: Molecular Function");
    //aspects.put("B","Neuro Behavioral");
    aspects.put("E","Chemical Interactions");

%>

