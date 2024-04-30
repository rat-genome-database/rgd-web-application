<%@ page import="org.springframework.ui.ModelMap" %>
<%@ page import="java.util.List" %>
<%@ page import="org.elasticsearch.search.SearchHit" %>
<%@ page import="java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="genomeInfoHeader.jsp"/>
<script type="text/javascript"  src="/rgdweb/js/jquery/jquery-1.12.4.min.js"></script>
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
           <%for(int j=0; j<3;j++){
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

<%--&lt;%&ndash;<c:forEach items="${model.hits}" var="hit">&ndash;%&gt;--%>
<%--    <div class="card-deck">--%>
<%--        <div class="card">--%>
<%--            <div class="card-img-top" align="center">--%>
<%--                <img class="" src="/rgdweb/common/images/species/${fn:toLowerCase(hit.sourceAsMap.species)}I.png" alt="Card image cap">--%>
<%--                <h4 class="card-title">${hit.sourceAsMap.species}</h4>--%>
<%--            </div>--%>
<%--            <div class="card-body">--%>
<%--                <%@include file="genomeContent.jsp"%>--%>
<%--            </div>--%>
<%--            <div class="card-footer">--%>
<%--                <small class="text-muted">Last updated 3 mins ago</small>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--        <div class="card">--%>
<%--            <div class="card-img-top" align="center">--%>
<%--                <img class="" src="/rgdweb/common/images/species/humanI.png" alt="Card image cap">--%>
<%--                <h4 class="card-title">Human</h4>--%>

<%--            </div>--%>
<%--            <div class="card-body">--%>
<%--                <%@include file="genomeContent.jsp"%>--%>
<%--            </div>--%>
<%--            <div class="card-footer">--%>
<%--                <small class="text-muted">Last updated 3 mins ago</small>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--        <div class="card">--%>
<%--            <div class="card-img-top" align="center">--%>
<%--                <img class="" src="/rgdweb/common/images/species/mouseI.jpg" alt="Card image cap">--%>
<%--                <h4 class="card-title">Mouse</h4>--%>
<%--            </div>--%>
<%--            <div class="card-body">--%>



<%--                <p class="card-text">This is a wider card with supporting text below as a natural lead-in to additional content. This card has even longer content than the first to show that equal height action.</p>--%>
<%--            </div>--%>
<%--            <div class="card-footer">--%>
<%--                <small class="text-muted">Last updated 3 mins ago</small>--%>
<%--            </div>--%>
<%--        </div>--%>
    </div>

<%--</c:forEach>--%>
<%--    <br>--%>
<%--    <div class="card-deck">--%>
<%--        <div class="card">--%>
<%--            <img class="card-img-top" src="..." alt="Card image cap">--%>
<%--            <div class="card-body">--%>
<%--                <h5 class="card-title">Card title</h5>--%>
<%--                <p class="card-text">This is a wider card with supporting text below as a natural lead-in to additional content. This content is a little bit longer.</p>--%>
<%--            </div>--%>
<%--            <div class="card-footer">--%>
<%--                <small class="text-muted">Last updated 3 mins ago</small>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--        <div class="card">--%>
<%--            <img class="card-img-top" src="..." alt="Card image cap">--%>
<%--            <div class="card-body">--%>
<%--                <h5 class="card-title">Card title</h5>--%>
<%--                <p class="card-text">This card has supporting text below as a natural lead-in to additional content.</p>--%>
<%--            </div>--%>
<%--            <div class="card-footer">--%>
<%--                <small class="text-muted">Last updated 3 mins ago</small>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--        <div class="card">--%>
<%--            <img class="card-img-top" src="..." alt="Card image cap">--%>
<%--            <div class="card-body">--%>
<%--                <h5 class="card-title">Card title</h5>--%>
<%--                <p class="card-text">This is a wider card with supporting text below as a natural lead-in to additional content. This card has even longer content than the first to show that equal height action.</p>--%>
<%--            </div>--%>
<%--            <div class="card-footer">--%>
<%--                <small class="text-muted">Last updated 3 mins ago</small>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--    </div>--%>
<%--    <br>--%>
<%--    <div class="card-deck">--%>
<%--        <div class="card">--%>
<%--            <img class="card-img-top" src="..." alt="Card image cap">--%>
<%--            <div class="card-body">--%>
<%--                <h5 class="card-title">Card title</h5>--%>
<%--                <p class="card-text">This is a wider card with supporting text below as a natural lead-in to additional content. This content is a little bit longer.</p>--%>
<%--            </div>--%>
<%--            <div class="card-footer">--%>
<%--                <small class="text-muted">Last updated 3 mins ago</small>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--        <div class="card">--%>
<%--            <img class="card-img-top" src="..." alt="Card image cap">--%>
<%--            <div class="card-body">--%>
<%--                <h5 class="card-title">Card title</h5>--%>
<%--                <p class="card-text">This card has supporting text below as a natural lead-in to additional content.</p>--%>
<%--            </div>--%>
<%--            <div class="card-footer">--%>
<%--                <small class="text-muted">Last updated 3 mins ago</small>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--        <div class="card">--%>
<%--            <img class="card-img-top" src="..." alt="Card image cap">--%>
<%--            <div class="card-body">--%>
<%--                <h5 class="card-title">Card title</h5>--%>
<%--                <p class="card-text">This is a wider card with supporting text below as a natural lead-in to additional content. This card has even longer content than the first to show that equal height action.</p>--%>
<%--            </div>--%>
<%--            <div class="card-footer">--%>
<%--                <small class="text-muted">Last updated 3 mins ago</small>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--    </div>--%>
<%--    <br>--%>
<%--    <div class="card-deck">--%>
<%--        <div class="card">--%>
<%--            <img class="card-img-top" src="..." alt="Card image cap">--%>
<%--            <div class="card-body">--%>
<%--                <h5 class="card-title">Card title</h5>--%>
<%--                <p class="card-text">This is a wider card with supporting text below as a natural lead-in to additional content. This content is a little bit longer.</p>--%>
<%--            </div>--%>
<%--            <div class="card-footer">--%>
<%--                <small class="text-muted">Last updated 3 mins ago</small>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--        <div class="card">--%>
<%--            <img class="card-img-top" src="..." alt="Card image cap">--%>
<%--            <div class="card-body">--%>
<%--                <h5 class="card-title">Card title</h5>--%>
<%--                <p class="card-text">This card has supporting text below as a natural lead-in to additional content.</p>--%>
<%--            </div>--%>
<%--            <div class="card-footer">--%>
<%--                <small class="text-muted">Last updated 3 mins ago</small>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--        <div class="card">--%>
<%--            <img class="card-img-top" src="..." alt="Card image cap">--%>
<%--            <div class="card-body">--%>
<%--                <h5 class="card-title">Card title</h5>--%>
<%--                <p class="card-text">This is a wider card with supporting text below as a natural lead-in to additional content. This card has even longer content than the first to show that equal height action.</p>--%>
<%--            </div>--%>
<%--            <div class="card-footer">--%>
<%--                <small class="text-muted">Last updated 3 mins ago</small>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--    </div>--%>
<%--    <div id="wrapper" style="border-color: white">--%>
<%--        <div class="card-group">--%>
<%--    <c:forEach items="${model.hits}" var="hit">--%>



<%--                <c:if test="${hit.sourceAsMap.primaryAssembly=='Y' && ( hit.sourceAsMap.species=='Rat' ||--%>
<%--                hit.sourceAsMap.species=='Human' || hit.sourceAsMap.species=='Mouse' || hit.sourceAsMap.species=='Chinchilla' || hit.sourceAsMap.species=='Dog'--%>
<%--                ) }">--%>

<%--                   <%@include file="genomeContent.jsp"%>--%>
<%--                </c:if>--%>



<%--    </c:forEach>--%>
<%--        </div>--%>
<%--        <div class="card-group">--%>
<%--        <c:forEach items="${model.hits}" var="hit">--%>


<%--                    <c:if test="${hit.sourceAsMap.primaryAssembly=='Y' && (--%>
<%--               hit.sourceAsMap.species=='Squirrel' || hit.sourceAsMap.species=='Pig'--%>
<%--                 || hit.sourceAsMap.species=='Naked Mole-rat'|| hit.sourceAsMap.species=='Green Monkey' || hit.sourceAsMap.species=='Bonobo') }">--%>

<%--                        <%@include file="genomeContent.jsp"%>--%>
<%--                    </c:if>--%>


<%--        </c:forEach>--%>
<%--        </div>--%>
<%--</div>--%>
<%--</div>--%>

<jsp:include page="genomeInfoFooter.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" type="text/css" href="/rgdweb/common/jquery-ui/jquery-ui.css">
<script src="/rgdweb/common/jquery-ui/jquery-ui.js"></script>