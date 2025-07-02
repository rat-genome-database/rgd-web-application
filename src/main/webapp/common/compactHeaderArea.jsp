<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.datamodel.WatchedObject" %>
<%@ page import="edu.mcw.rgd.datamodel.WatchedTerm" %>


<%@ include file="/common/googleAnalytics.jsp" %>
<%
    String idForAngular = request.getParameter("id");
    if (idForAngular == null) {
        idForAngular=request.getParameter("acc_id");
        if (idForAngular == null) {
            idForAngular="";
        }
    }
%>


<script>
    function getLoadedObject() {
        return "<%=idForAngular%>";
    }
    function getGeneWatchAttributes() {
        //return ["Nomenclature Changes","New GO Annotation","New Disease Annotation","New Phenotype Annotation","New Pathway Annotation","New PubMed Reference","Altered Strains","New NCBI Transcript/Protein","New Protein Interaction","RefSeq Status Has Changed"];
        return <%= WatchedObject.getAllWatchedLabelsAsJSON()%>
    }
    function getTermWatchAttributes() {
        return <%= WatchedTerm.getAllWatchedLabelsAsJSON()%>

    }


</script>


<link rel="stylesheet" href="/rgdweb/common/bootstrap/css/bootstrap.css">
<%--<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>--%>
<script src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>
<!--<script type="text/javascript">window.angJq = jQuery.noConflict();</script>-->
<script src="/rgdweb/common/bootstrap/js/bootstrap.js"></script>
<script type="text/javascript" src="/rgdweb/common/angular/1.4.8/angular.js"></script>
<script type="text/javascript" src="/rgdweb/common/angular/1.4.8/angular-sanitize.js"></script>
<script type="text/javascript" src="/rgdweb/my/my.js"></script>


<body style="background-color:#E8E7E2" ng-cloak ng-app="rgdPage" g-jq="angJq">
<%@ include file="/common/angularTopBodyInclude.jsp" %>

<% if( !RgdContext.isChinchilla(request) ) { %>
<table border=0 cellpadding=0 cellspacing=0 style="background-color:#24609C; order-bottom: 1px solid #24609C; color:white; font-size:12px; background-image: url('/common/images/gradient.jpg');" border="0" width="100%">
<tbody><tr>
    <td style="color:white;" align="left">
        <a href="/"><img src="/rgdweb/common/images/rgd_LOGO_small.gif" border=0/></a>
    </td>
    <td width=150 style="color:white;" align="right">
		<a style="color:white;" href="http://rgd.mcw.edu/wg/citing-rgd">Citing RGD</a>&nbsp;|&nbsp;
				<a style="color:white;" href="http://rgd.mcw.edu/contact/index.shtml">Contact Us</a>&nbsp;&nbsp;&nbsp;
</td>
    <!--
    <td width="90">
            <input type="button" class="btn btn-info btn-sm" data-toggle="modal" data-target="#myModal" value="{username}}" ng-click="rgd.loadMyRgd($event)" style="background-color:#4584ED;"/>
    </td>
    -->
</tr></tbody></table>
<% } %>


