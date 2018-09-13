<%--
  Created by IntelliJ IDEA.
  User: mtutaj
  Date: Feb 22, 2012
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ include file="../dao.jsp"%>


 <% boolean includeMapping = true;
    String title = "Genomic Elements";

    String pageTitle = "Genomic Element Report - Rat Genome Database";
    String headContent = "";
    String pageDescription = "GENOMIC ELEMENT DESCRIPTION";

    GenomicElement obj = (GenomicElement) request.getAttribute("reportObject");
    String objectType = "genomic element";
    String displayName = obj.getSymbol();
%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>
<%@ include file="menu.jsp"%>


<% if (view.equals("3")) { %>

<% } else if (!obj.getObjectStatus().equals("ACTIVE")) { %>
    <br><br>This object has been <%=obj.getObjectStatus()%> <br><br>


<% } else {%>


<table width="95%" border="0">
    <tr>
        <td>
            <%@ include file="info.jsp"%>

            <br>
            <div class="subTitle">Region</div>
            <br>
            <%@ include file="../sequence.jsp"%>
            <%@ include file="../pubMedReferences.jsp"%>

            <br>
            <div class="subTitle">Sequence</div>
            <br>
            <%@ include file="../nucleotide.jsp"%>
            <%@ include file="../proteins.jsp"%>

            <br>
            <div class="subTitle">Additional Information</div>
            <br>

            <%@ include file="../xdbs.jsp"%>
        </td>
        <td>&nbsp;</td>
        <td align="right" valign="top">
      <%--      <%@ include file="links.jsp" %>   --%>
            <br>
            <%@ include file="../idInfo.jsp" %>
        </td>        
    </tr>
 </table>

<% } %>


<%@ include file="../reportFooter.jsp"%>
<%@ include file="/common/footerarea.jsp"%>



