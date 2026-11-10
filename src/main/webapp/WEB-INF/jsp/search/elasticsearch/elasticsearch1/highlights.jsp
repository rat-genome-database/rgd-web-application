<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  This page is included once per result row, so anything emitted here is emitted once per row.
  The popover initialization that used to sit at the top of this file is now in results.jsp,
  where it runs once for the whole table: as a script here it shipped 1000 copies of itself on a
  1000 row page, each one re-scanning the document and re-initializing every popover already
  parsed - around half a million initializations, and 1000 stacked focus handlers on the first
  row. That was the bulk of the wait after the response arrived.
--%>
<div>
    <%

        if (!RgdContext.isProduction()) {
            String id = (String) sourceMap.get("term_acc");
            String highlightId = id != null ? id.replace(":", "") : "";
            Map<String, List<String>> highlightFields = hit.getHighlightFields();
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
                    for (Map.Entry<String, List<String>> entry : highlightFields.entrySet()) {
                        String key = entry.getKey();
                        List<String> fragments = entry.getValue();
                        if (key != null &&
                                !key.equalsIgnoreCase("category") &&
                                !key.equalsIgnoreCase("species") &&
                                !key.contains(".")) {%>

                            <%=key + ": "%>
                           <% if (fragments != null && !fragments.isEmpty()) {
                                for (String fragment : fragments) {%>
                                "<%=fragment%>"
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
