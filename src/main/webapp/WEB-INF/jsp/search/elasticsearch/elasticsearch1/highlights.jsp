<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="org.elasticsearch.search.fetch.subphase.highlight.HighlightField" %>
<%@ page import="org.elasticsearch.common.text.Text" %>
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

<% if(!RgdContext.isProduction()){
    String id= (String) sourceMap.get("term_acc");
    String highlightId=new String();
    if(id.contains(":")){
        highlightId=id.replace(":", "");
    }else highlightId=id;
%>
<%--<c:set var="hightlightId" value="${hit.sourceAsMap.term_acc}"/>--%>
<%--<c:if test="${fn:contains(hit.sourceAsMap.term_acc, ':')}">--%>
<%--    <c:set var="hightlightId" value="${fn:replace(hit.sourceAsMap.term_acc, ':','')}"/>--%>

<%--</c:if>--%>
<button type="button" class="btn btn-light btn-sm" data-container="body" data-trigger="click" data-toggle="popover" data-placement="bottom" data-popover-content="#popover-study-<%=highlightId%>" title="Highlights" style="background-color: transparent">
    <span style="text-decoration:underline">Show Matches</span>
</button>
<!--a href="#" class="moreLink" style="color:dodgerblue" title="Matched fragments">Show Matches...</a-->
<div style="display: none" id="popover-study-<%=highlightId%>">
    <div class="popover-body">
        <%
            Map<String, HighlightField> highlightFields=hit.getHighlightFields();
            for(String key:highlightFields.keySet()){
                if(!key.toLowerCase().contains("category".toLowerCase()) &&
                        !key.toLowerCase().contains("species".toLowerCase())){
                  HighlightField hf=  highlightFields.get(key);
                  if(!hf.getName().contains(".")){%>
                        <%=hf.getName()%>:
                   <%for(Text t: hf.getFragments()){%>
                       <%=t%>
                   <%}%>

                <%}}}%>

</div>
</div>
<%}%>