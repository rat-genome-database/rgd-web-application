<%@ include file="sectionHeader.jsp"%>
<%
    List aliases = aliasDAO.getAliases(obj.getRgdId());
%>
<br><br>
<div class="reportSection">Array IDs</div>
  <br>
<%=ArrayIdFormatter.format(aliases)%>

<%@ include file="sectionFooter.jsp"%>
