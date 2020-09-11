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

<script type="text/javascript" src="https://www.google.com/jsapi"></script>



  <script type="text/javascript">

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

<style>
    .gaLabel {
        font-weight:700;
        color:#3F3F3F;
    }

    .gaLabelHeader {
        font-weight:700;
        color:#3F3F3F;
        background-color:#D8D8DB;
    }
    .gaTable{
        background-color: #E6E6E6;
        border: 1px solid #c8c8c8;
    }

    h1, h2, h3, h4, h5, h6 {
        font-family: Georgia, "Times New Roman", Times, serif;
        color:#4088b8;
        clear: both;
        font-weight:700;
    }

    #wrap {
        color: #404040;
        /*margin: 0 12%;*/
        margin: 20px 40px;
    }


    ul, ol {
        margin-left 0;
    }

    ul ul {
        margin-bottom: 20px;
    }

    a {
        color: #4088b8;
    }
    .gaTable td, .gaTable a, .gaTable input, .gaTable option{
       font-size:11px;
       background: #f8f8f8;
       font-family:Arial;
       color:#3F3F3F;
            background: #f8f8f8;
    text-align: left;
    padding: 5px;
    vertical-align: top;
    }
       .evenRow {
    background-color: #FFFFFF;
}
.oddRow {
    background-color: #E2E2E2;
}
.headerRow {
    background-color: #838383;
    color: white;
    font-family: arial;
    font-size: 11px;
    font-weight: 700;
}
</style>

<link href="/rgdweb/js/jsor-jcarousel-7bb2e0a/style.css" rel="stylesheet" type="text/css"/>
<script type="text/javascript" src="/rgdweb/js/jsor-jcarousel-7bb2e0a/lib/.2.min.js"></script>
<script type="text/javascript" src="/rgdweb/js/jsor-jcarousel-7bb2e0a/lib/jquery.jcarousel.min.js"></script>
<link rel="stylesheet" type="text/css" href="/rgdweb/js/jsor-jcarousel-7bb2e0a/skins/tango/skin.css"/>

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


%>

