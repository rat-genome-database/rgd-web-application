<%@ page import="org.springframework.ui.ModelMap" %>
<%@ page import="java.util.List" %>
<%@ page import="org.elasticsearch.search.SearchHit" %>
<%@ page import="java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="genomeInfoHeader.jsp"/>
<script type="text/javascript"  src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>
<script src="/rgdweb/js/genomeInformation/genomeHome.js"></script>
<style>
.card-img-top {
width: 100%;
height: 100px;

}
</style>
<div class="container">

    <%
        ModelMap modelMap= null;
        java.util.Map<String, List<edu.mcw.rgd.datamodel.Map>> assemblies=null;
    if(request.getAttribute("model")!=null)
        modelMap=   (ModelMap) request.getAttribute("model");
        List<SearchHit> hits= (List<SearchHit>) modelMap.get("hits");
       assemblies= (java.util.Map<String, List<edu.mcw.rgd.datamodel.Map>>) modelMap.get("assemblyListsMap");
        int rows=0;
        if(hits.size()%3==0){
            rows=(hits.size())/3;
        }else {
            rows=((hits.size())/3)+1;
        }
        int hitCount=0;

        for(int i=0;i<rows;i++){%>
        <div class="card-deck">
           <%for(int j=0;hitCount<hits.size() && j<3;j++){
                SearchHit hit=hits.get(hitCount);
                Map<String, Object> sourceMap=hit.getSourceAsMap();
                hitCount++;
           %>
            <div class="card" style="border-width: thick">
                <a href="genomeInformation.html?species=<%=sourceMap.get("species")%>&mapKey=<%=sourceMap.get("mapKey")%>&details=true" id="headerLink<%=sourceMap.get("species")%>" title="click to see more info and other assemblies">
                <div class="card-img-top" align="center">
                    <img class="" src="/rgdweb/common/images/species/<%=sourceMap.get("species").toString().toLowerCase().replace(" ","_")%>I.png" alt="Card image cap">
                    <h4 class="card-title"><%=sourceMap.get("species")%></h4>
                </div>
            </a>
                <div class="card-body">
                    <%@include file="genomeContent.jsp"%>
                </div>
<%--                <div class="card-footer" align="center">--%>
<%--                    <small class="text-muted"><a href="genomeInformation.html?species=<%=sourceMap.get("species")%>&mapKey=<%=sourceMap.get("mapKey")%>&details=true" title="click to see more info and other assemblies"><strong>More Details..</strong></a>--%>
<%--                    </small>--%>
<%--                </div>--%>
            </div>
            <%}%>
        </div>
    <br>
        <%}%>


    </div>


<jsp:include page="genomeInfoFooter.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" type="text/css" href="/rgdweb/common/jquery-ui/jquery-ui.css">
<script src="/rgdweb/common/jquery-ui/jquery-ui.js"></script>