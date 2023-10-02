<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.Iterator" %>

<% String pageTitle = "GA Tool: Compared Terms Window";
    String headContent = "";
    String pageDescription = "";%>
<%@ include file="/common/headerarea.jsp" %>
<%@ include file="gaHeader.jsp" %>

<%--   <%@ include file="rgdHeader.jsp" %>--%>
    <%@ include file="menuBar.jsp" %>
<br>


<%
    OntologyXDAO xdao = new OntologyXDAO();

    Term term1 = xdao.getTermByAccId(request.getParameter("term1"));
    Term term2 = xdao.getTermByAccId(request.getParameter("term2"));


%>


<table align="center">
    <tr>
        <td align="center" style="font-style:italic;">Genes Annotated to </td>
    </tr>
    <tr>
        <td align="center"><a href="<%=Link.ontAnnot(term1.getAccId())%>" target="_blank"><%=term1.getTerm()%></a>  (<%=term1.getAccId()%>)</td>
    </tr>
    <tr>
        <td align="center">and</td>
    </tr>
    <tr>
        <td align="center"><a href="<%=Link.ontAnnot(term2.getAccId())%>"  target="_blank"><%=term2.getTerm()%></a> (<%=term2.getAccId()%>)</td>
    </tr>
</table>



<%
    Iterator geneIt = om.getMapped().iterator();
         boolean first = true;
         String genes="";
    while (geneIt.hasNext()) {
        Gene g = (Gene) geneIt.next();


            if (first) {
                 genes += g.getSymbol();
                 first=false;
             }else {
                 genes += "," + g.getSymbol();
             }

    }
     %>
<br>

<table border=0 width=100%>
    <tr>
        <td align="center">
            <table border=0 cellpadding=4 style="border:1px solid #74819D;" width="95%" >
                <tr>
                    <!--<td colspan=3 align="right"><a href="javascript:explore('<%=genes%>')">(Explore this Gene Set)</a></td>-->
                    <td colspan=3 align="right"><a href="javascript:postIt('/rgdweb/ga/analysis.html')">(Explore this Gene Set)</a></td>

                </tr>
                <tr>
                    <td style="font-weight:700; background-color:#771428; color: #ffffff;">Gene</td>
                </tr>
                <%
                geneIt = om.getMapped().iterator();
                while (geneIt.hasNext()) {
                    Gene g = (Gene) geneIt.next();
                %>
                <tr>
                    <td align="left" style="background-color:#E8E4D5;">
                            <a class="geneList" href="<%=Link.gene(g.getRgdId())%>" target="_blank"><%=g.getSymbol()%></a> - <%=g.getName()%><br>
                        </td>
                </tr>
                <%
                }
                %>
            </table>
        </td>
    </tr>
</table>

<%@ include file="/common/footerarea.jsp" %>