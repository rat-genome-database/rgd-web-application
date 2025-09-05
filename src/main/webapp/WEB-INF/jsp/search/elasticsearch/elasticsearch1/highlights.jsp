<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="org.elasticsearch.search.fetch.subphase.highlight.HighlightField" %>
<%@ page import="org.elasticsearch.common.text.Text" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>
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
<div>
    <%

        if (!RgdContext.isProduction()) {
            String id = (String) sourceMap.get("term_acc");
            String highlightId = id != null ? id.replace(":", "") : "";
            Map<String, HighlightField> highlightFields = hit.getHighlightFields();
    %>

    <button type="button" class="btn btn-light btn-sm"
            data-container="body"
            data-trigger="click"
            data-toggle="popover"
            data-placement="bottom"
            data-popover-content="#popover-study-<%=highlightId%>"
            title="Highlights"
            style="background-color: transparent">
        <span style="text-decoration: underline">Show Matches</span>
    </button>

    <div style="display: none" id="popover-study-<%=highlightId%>">
        <div class="popover-body">
            <%
                if (highlightFields != null && !highlightFields.isEmpty()) {
                    for (Map.Entry<String, HighlightField> entry : highlightFields.entrySet()) {
                        String key = entry.getKey();
                        HighlightField hf = entry.getValue();
                        if (key != null &&
                                !key.equalsIgnoreCase("category") &&
                                !key.equalsIgnoreCase("species") &&
                                hf != null &&
                                !hf.getName().contains(".")) {%>

                            <%=hf.getName() + ": "%>
                           <% Text[] fragments = hf.getFragments();
                            if (fragments != null && fragments.length > 0) {
                                for (Text fragment : fragments) {%>
                                "<%=fragment.toString()%>"
                                <%}}%><br>
            <%
                    }
                }
            }
        %>
        </div>
    </div>

    <% } %>
</div>
