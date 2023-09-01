<%@ page import="org.elasticsearch.search.SearchHit" %>
<%@ page import="java.util.*" %>
<%@ include file="genomeInfoHeader.jsp"%>
<script type="text/javascript"  src="/rgdweb/js/jquery/jquery-1.12.4.min.js"></script>
<script src="/rgdweb/js/genomeInformation/genomeHome.js"></script>

<%
    LinkedList<SearchHit> hits = (LinkedList<SearchHit>) request.getAttribute("hits");
    Map<String, List<edu.mcw.rgd.datamodel.Map>> assemblyListsMap = (Map) request.getAttribute("assemblyListsMap");
%>

<div class="container">

    <div id="wrapper" style="border-color: white">
        <div class="card-group">
<%--    <c:forEach items="${model.hits}" var="hit">--%>
        <% for (SearchHit hit : hits) {
            Map<String, Object> hitMap = hit.getSourceAsMap();
            String species = (String) hitMap.get("species");
            String primaryAssembly = (String) hitMap.get("primaryAssembly");
            if (primaryAssembly.equals("Y") && (species.equals("Rat") || species.equals("Human") || species.equals("Mouse")
                    || species.equals("Chinchilla") || species.equals("Dog") )){%>

                   <%@include file="genomeContent.jsp"%>

        <% }
        } %>
<%--    </c:forEach>--%>
        </div>
        <div class="card-group">
            <% for (SearchHit hit : hits) {
                Map<String, Object> hitMap = hit.getSourceAsMap();
                String species = (String) hitMap.get("species");
                String primaryAssembly = (String) hitMap.get("primaryAssembly");
                if (primaryAssembly.equals("Y") && (species.equals("Squirrel") || species.equals("Pig") || species.equals("Naked Mole-rat")
                        || species.equals("Green Monkey") || species.equals("Bonobo") )){%>

            <%@include file="genomeContent.jsp"%>

            <% }
            } %>
        </div>
</div>
</div>

<%@ include file="genomeInfoFooter.jsp"%>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" type="text/css" href="/rgdweb/common/jquery-ui/jquery-ui.css">
<script src="/rgdweb/common/jquery-ui/jquery-ui.js"></script>