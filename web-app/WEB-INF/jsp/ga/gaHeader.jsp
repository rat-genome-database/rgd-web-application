<%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Identifiable" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.OntologyEnrichment" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.TermWrapper" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.LinkedHashMap" %>

<%@ page import="edu.mcw.rgd.web.*" %>


<link href="/rgdweb/ga/ga.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/js/jsor-jcarousel-7bb2e0a/style.css" rel="stylesheet" type="text/css"/>


<!--<script type="text/javascript" src="/rgdweb/js/jsor-jcarousel-7bb2e0a/lib/jquery-1.4.2.min.js"></script>-->

<!--
<script type="text/javascript" src="/rgdweb/js/jsor-jcarousel-7bb2e0a/lib/jquery.jcarousel.min.js"></script>
-->
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
    List<TermWrapper> termWrappers = new ArrayList<TermWrapper>();

    String method="get";

    if (Utils.symbolSplit(req.getParameter("genes")).size() > 250) {
        method="post";
    }

    LinkedHashMap<String,String> aspects = new LinkedHashMap<String,String>();
    aspects.put("D","Disease");
    aspects.put("W","Pathway");
    aspects.put("N","Phenotype");
    aspects.put("P","GO: Biological Process");
    aspects.put("C","GO: Cellular Component");
    aspects.put("F","GO: Molecular Function");
    if( !RgdContext.isChinchilla(request) )
        aspects.put("E","Chemical Interactions");
%>

<style>
    #headerBar, #headerBar a, #headerBar td {
        font-size:12px;
        font-weight: 700;
        font-family:arial;
        padding:1px;
        background-color: #f0f6f9;
        border: 0px solid black;
    }
</style>

<script>

    function regCrossHeader(title) {
        document.getElementById(title).onclick = showSection;
        document.getElementById(title + "_i").onclick = showSection;
        document.getElementById(title + "_content").style.display = "none";
    }


    function regHeader(title) {
        document.getElementById(title).onclick = getTermDetail;
        document.getElementById(title + "_i").onclick = getTermDetail;
        document.getElementById(title + "_content").style.display = "none";
    }

    <% if (om != null )  { %>

    function getTermDetail(e) {

        if (!e) e = window.event;
        var obj = document.all ? e.srcElement : e.currentTarget;

        if (document.all) {
            if (obj.id.indexOf("_i") != -1) {
                var acc = obj.id.substring(0,obj.id.indexOf("_i"));
                obj=document.getElementById(acc);
            }
            window.event.cancelBubble = true;
        }else {
            if (obj.id.indexOf("_i") != -1) {
                return;
            }

        }
            $.ajax({
                url: "/rgdweb/ga/termDetail.html",
                data: {species:'<%=request.getParameter("species")%>', genes: "<%=om.getMappedAsString()%>", acc: obj.id  },
                type: "POST",
                error: function(XMLHttpRequest, textStatus, errorThrown) {
                    document.getElementById(obj.id + "_content").innerHTML = XMLHttpRequest.status + " " + XMLHttpRequest.statusText + "<br>";
                },
                success: function(data) {
                    document.getElementById(obj.id + "_content").innerHTML = data;
                }
        });


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

    <% } %>


    function showSection(e) {

        if (!e) e = window.event;
        var obj = document.all ? e.srcElement : e.currentTarget;

        if (document.all) {
            if (obj.id.indexOf("_i") != -1) {
                var name = obj.id.substring(0, obj.id.indexOf("_i"));
                obj = document.getElementById(name);
            }
            window.event.cancelBubble = true;
        } else {

        }

        var content = document.getElementById(obj.id + "_content");
        if (content) {
            if (content.style.display == "block") {
                content.style.display = "none";
                document.getElementById(obj.id + "_i").src = "/rgdweb/common/images/add.png";
            } else {
                content.style.display = "block";
                document.getElementById(obj.id + "_i").src = "/rgdweb/common/images/remove.png";
            }
        }

    }

    ddtabmenu.definemenu("ddtabs4", 2);
</script>

