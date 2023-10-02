<%@ page import="edu.mcw.rgd.datamodel.Identifiable" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.GeneWrapper" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.OntologyEnrichment" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.TermWrapper" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.MathContext" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>


<%@ include file="gaHeader.jsp" %>


<%
    List mappedRGDIds = new ArrayList();
    Iterator mappedIt = om.getMapped().iterator();
    while (mappedIt.hasNext()) {
        Object next = mappedIt.next();

        if (next instanceof Identifiable) {
            Identifiable ided = (Identifiable) next;
            mappedRGDIds.add(ided.getRgdId());
        }
    }


    OntologyEnrichment oe = adao.getOntologyEnrichment(mappedRGDIds, termSet, new ArrayList());

    Iterator tit = oe.getTermWrappers().keySet().iterator();
    while (tit.hasNext()) {
        String acc = (String) tit.next();
        TermWrapper tw = (TermWrapper) oe.termMap.get(acc);
        termWrappers.add(tw);
    }
%>


<br><span style="font-size:20px;">Cross Term Analysis (<%=oe.termMap.size()%> terms)</span><br>
<br>


<%

    List<GeneWrapper> overlapList = oe.getOverlap(termSet);
    BigDecimal genePercent = new BigDecimal(((double) overlapList.size() / (double) om.getMapped().size() * 100));

%>



<%=ui.dynOpen("cross1", "&nbsp;&nbsp" + genePercent.round(new MathContext(4)) + "% of this set are annotated to " + termSet ) %>
 <table border=0 style="border: 1px dashed black; padding:3px; margin: 2px;" width="400">
     <%
         Iterator git = overlapList.iterator();
         boolean first = true;
         String genes="";
         while (git.hasNext()) {
             GeneWrapper gw = (GeneWrapper) git.next();
             if (first) {
                 genes += gw.getGene().getSymbol();
                 first=false;
             }else {
                 genes += "," + gw.getGene().getSymbol();
             }
         }

     %>

     <tr><td align="right" colspan=2><a href="javascript:explore('<%=genes%>')">Explore this Gene Set</a>&nbsp;&nbsp;</td></tr>

<%

    for (GeneWrapper gw: overlapList) {
        %>
<tr><td>&nbsp;</td><td valign="top"><li><a onclick="geneList('<%=gw.getGene().getRgdId()%>')" href="javascript:void(0)"><%=gw.getGene().getSymbol()%></a></li></td></tr>

    <%
    }
%>
</table>
<%=ui.dynClose("cross1") %>


<br>
<br>







