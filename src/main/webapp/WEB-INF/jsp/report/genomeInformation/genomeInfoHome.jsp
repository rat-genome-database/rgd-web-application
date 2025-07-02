<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<jsp:include page="genomeInfoHeader.jsp"/>
<script type="text/javascript"  src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>
<script src="/rgdweb/js/genomeInformation/genomeHome.js"></script>

<div class="container">

    <div id="wrapper" style="border-color: white">
        <div class="card-group">
    <c:forEach items="${model.hits}" var="hit">



                <c:if test="${hit.sourceAsMap.primaryAssembly=='Y' && ( hit.sourceAsMap.species=='Rat' ||
                hit.sourceAsMap.species=='Human' || hit.sourceAsMap.species=='Mouse' || hit.sourceAsMap.species=='Chinchilla' || hit.sourceAsMap.species=='Dog'
                ) }">

                   <%@include file="genomeContent.jsp"%>
                </c:if>



    </c:forEach>
        </div>
        <div class="card-group">
        <c:forEach items="${model.hits}" var="hit">


                    <c:if test="${hit.sourceAsMap.primaryAssembly=='Y' && (
               hit.sourceAsMap.species=='Squirrel' || hit.sourceAsMap.species=='Pig'
                 || hit.sourceAsMap.species=='Naked Mole-rat'|| hit.sourceAsMap.species=='Green Monkey' || hit.sourceAsMap.species=='Bonobo') }">

                        <%@include file="genomeContent.jsp"%>
                    </c:if>


        </c:forEach>
        </div>
</div>
</div>
</div>
<jsp:include page="genomeInfoFooter.jsp"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">
<link rel="stylesheet" type="text/css" href="/rgdweb/common/jquery-ui/jquery-ui.css">
<script src="/rgdweb/common/jquery-ui/jquery-ui.js"></script>