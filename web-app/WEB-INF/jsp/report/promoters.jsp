<%@ page import="edu.mcw.rgd.web.RGDHandlerInterceptor" %>
<%@ page import="edu.mcw.rgd.report.PromoterEvidenceFormatter" %>
<%@ include file="sectionHeader.jsp"%>
<%
    String promoterDataTable = PromoterEvidenceFormatter.getInstance().buildTable(obj.getRgdId(), obj.getSpeciesTypeKey());
    if( promoterDataTable!=null ) {
        //out.println(ui.dynOpen("promotersSection", "Promoters"));
        out.println("<div class=\"light-table-border\">");
        out.println("<div class='sectionHeading' id='promoters'>Promoters</div>");

        out.print(promoterDataTable);
                out.println("</div>");
       // out.print(ui.dynClose("promotersSection"));
    }
%>
<%@ include file="sectionFooter.jsp"%>