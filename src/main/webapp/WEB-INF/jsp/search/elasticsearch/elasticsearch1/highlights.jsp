<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script>
    $('[data-toggle="popover"]').popover({
        html: true,
        content: function () {
            var content = $(this).attr("data-popover-content");
            return $(content).children(".popover-body").html();
        }

    })
        .on("focus", function () {
            $(this).popover("show");
        }).on("focusout", function () {
        var _this = this;
        if (!$(".popover:hover").length) {
            $(this).popover("hide");
        } else {
            $('.popover').mouseleave(function () {
                $(_this).popover("hide");
                $(this).off('mouseleave');
            });
        }
    });
</script>

<% if(!RgdContext.isProduction()){%>
<c:set var="hightlightId" value="${hit.sourceAsMap.term_acc}"/>
<c:if test="${fn:contains(hit.sourceAsMap.term_acc, ':')}">
    <c:set var="hightlightId" value="${fn:replace(hit.sourceAsMap.term_acc, ':','')}"/>

</c:if>
<button type="button" class="btn btn-light btn-sm" data-container="body" data-trigger="click" data-toggle="popover" data-placement="bottom" data-popover-content="#popover-study-${hightlightId}" title="Highlights" style="background-color: transparent">
    <span style="text-decoration:underline">Show Matches</span>
</button>
<!--a href="#" class="moreLink" style="color:dodgerblue" title="Matched fragments">Show Matches...</a-->
<div style="display: none" id="popover-study-${hightlightId}">
    <div class="popover-body">
        <c:set value="true" var="first"/>
        <c:forEach items="${hit.getHighlightFields()}" var="hf">
            <c:if test="${fn:toLowerCase(hf.key)!='category.keyword' && hf.key!='category'
         && hf.key!='species' && hf.key!='species.keyword'}">
                <strong>${fn:substring(hf.key,0,fn:indexOf(hf.key,"." ))}</strong>
                <c:forEach items="${hf.value.getFragments()}" var="f">
                    "${f}";
                </c:forEach>
            </c:if>
        </c:forEach>
    </div>
</div>
<%}%>