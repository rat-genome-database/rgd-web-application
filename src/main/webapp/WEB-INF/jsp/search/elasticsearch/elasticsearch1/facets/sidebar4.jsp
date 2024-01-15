<%@ page import="edu.mcw.rgd.search.elasticsearch1.model.SearchBean" %>
<%@ page import="org.springframework.ui.ModelMap" %>
<%@ page import="org.elasticsearch.search.aggregations.bucket.terms.Terms" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    ModelMap model= (ModelMap) request.getAttribute("model");
    SearchBean searchBean= (SearchBean) model.get("searchBean");
    Map<String, List<? extends Terms.Bucket>> aggregations= (Map<String, List<? extends Terms.Bucket>>) model.get("aggregations");
%>
<div>
<!--div><button id="viewAllBtn" style="display:none">View All Results</button></div-->
    <div>
       <c:if test="${!model.objectSearch.equals('true')}">
    <div style="width:40%;float:right">
        <form action="/rgdweb/elasticResults.html" id="viewAllForm">
            <input type="hidden" value="${model.term}" id="searchTerm" name="term"/>
            <input type="hidden" value="general" id="searchCategory" name="category"/>
            <!--input type="hidden" name="species" id = "sp1" value="${model.sp1}"-->
            <input type="hidden" name="type" id = "type" >
            <input type="hidden" name="viewall" value="true"/>
            <input type="hidden" name="chr" id = "chr" value="${model.searchBean.chr}">
            <input type="hidden" name="start" id="start" value="${model.searchBean.start}"/>
            <input type="hidden" name="stop" id = "stop" value="${model.searchBean.stop}"/>

            <button  type="submit" id="viewAll">View All Results</button>
        </form>

    </div>
       </c:if>
<h3>Filters</h3>

   </div>
<div id="jstree_results">
    <ul>

           <% if(!searchBean.getCategory().equalsIgnoreCase("general") || model.get("defaultAssembly")!=null){%>
                <li>
                    <%@include file="facets/facets_rat.jsp"%>
                </li>
        <%}%>
    </ul>
</div>



</div>