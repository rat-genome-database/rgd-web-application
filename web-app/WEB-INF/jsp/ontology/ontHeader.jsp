<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ include file="/common/headerarea.jsp"%>
<% if(RgdContext.isChinchilla(request) ) { %>
<script>
    ddtabmenu.definemenu("ddtabs4", 3);
</script>
<% } %>