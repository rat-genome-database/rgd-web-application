<%@ page import="edu.mcw.rgd.datamodel.annotation.GeneWrapper" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.TermWrapper" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.MathContext" %>
<%@ page import="java.util.Iterator" %>

<%@ include file="header.jsp" %>



<br><span style="font-size:20px;">This set contains <b><%= oe.geneMap.size()%></b> genes and <b><%=oe.termMap.size()%> total terms</b><br></span>

<br>
<br><span style="font-size:20px;">Gene Set Analysis<br></span>
<br>
<%

    Iterator tit = oe.getGeneWrappers().keySet().iterator();
    while (tit.hasNext()) {
        Integer acc = (Integer) tit.next();
        GeneWrapper tw = (GeneWrapper) oe.geneMap.get(acc);
        BigDecimal genePercent = new BigDecimal(((double) tw.refs.size() / (double) oe.termMap.size() * 100));

        if (genePercent.doubleValue() < 9) {
        //    continue;
        }
        %>

<%=ui.dynOpen(tw.getGene().getRgdId() + "", "&nbsp;&nbsp;<b>" + tw.getGene().getSymbol() + "</b> has been annotated to <b>" + genePercent.round(new MathContext(4)) + "%</b> of the term set&nbsp;")%>

        <div id="<%=tw.getGene().getRgdId()%>_content">

        <table border=0>
        <%
        Iterator git = tw.refs.iterator();
        while (git.hasNext()) {
            TermWrapper gw = (TermWrapper) git.next();
         %>
            <tr><td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td><td valign="top"><a href=""><%=gw.getTerm().getTerm()%></a></td></tr>
        <%
        }
        %>
        </table>
        </div>
       <%=ui.dynClose(tw.getGene().getRgdId() + "")%>
    <%
    }
     %>



