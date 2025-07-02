<%@ page import="edu.mcw.rgd.datamodel.Identifiable" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.OntologyEnrichment" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.TermWrapper" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>

<%@ page import="edu.mcw.rgd.web.*" %>


<link href="/rgdweb/ga/ga.css" rel="stylesheet" type="text/css"/>
<script src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>

<script type="text/javascript" src="https://www.google.com/jsapi"></script>


<%@ include file="/common/googleAnalytics.jsp" %>


<%

    //initializations
    HttpRequestFacade req = new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req,  new java.util.ArrayList());
    FormUtility fu = new FormUtility();
    UI ui=new UI();
    AnnotationDAO adao = new AnnotationDAO();

    ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");
    List termSet= Utils.symbolSplit(req.getParameter("terms"));
    List<TermWrapper> termWrappers = new ArrayList<TermWrapper>();

    String method="get";


    LinkedHashMap<String,String> aspects = new LinkedHashMap<String,String>();
    aspects.put("S","Rat Strain");
    aspects.put("L","Clinical Measurement");
    aspects.put("M","Measurement Method");
    aspects.put("X","Experimental Condition");
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
                url: "/rgdweb/pa/termDetail.html",
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

