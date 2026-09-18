<%@ include file="../sectionHeader.jsp"%>

<%

List<Gene> candidateGenes = associationDAO.getGeneAssociationsByQTL(obj.getRgdId());

if (candidateGenes.size() > 0) {
%>

<%-- The card every other section on this report sits in. Without it this section had no
     background, and no collapse either: buildCards() in reportModernUx.js looks for
     ".light-table-border" and then for a ".sectionHeading" that is its DIRECT child, so the
     heading has to be the first thing inside the wrapper - that is also what lets the heading
     stay visible while ".rgd-collapsed > *:not(.sectionHeading)" hides the rest. --%>
<div class="light-table-border">
<div class="sectionHeading" id="candidateGenes">Candidate Gene Status</div>

<%-- One sentence and a chip per gene. This used to be a two column table with a green bullet
     image in the first cell and, in the second, "<symbol> is a candidate Gene for <this QTL>"
     written out again on every row - the same six words and the same QTL each time, since the
     QTL is the one whose report this is. The lead-in carries them once and the genes only have
     to say which they are, the same shape genesInRegion.jsp uses. --%>
<div class="rgdLinkRow">
    <span class="rgdLinkRowLead">The following
        <b><%=candidateGenes.size()%> Gene<%=candidateGenes.size()==1 ? "" : "s"%></b>
        <%=candidateGenes.size()==1 ? "is a candidate gene" : "are candidate genes"%> for
        <b><%=obj.getSymbol()%></b>.</span>
    <%
        for (Gene candidateGene : candidateGenes) {
            // the full gene name is what the symbol stands for - too long for a chip, so it rides
            // along as the tooltip rather than being dropped the way the old table dropped it
            String candidateGeneName = Utils.NVL(candidateGene.getName(), candidateGene.getSymbol());
    %>
    <a class="rgdChipLink" href="<%=Link.gene(candidateGene.getRgdId())%>"
       title="<%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(candidateGeneName)%>"><%=candidateGene.getSymbol()%></a>
    <% } %>
</div>
</div>

<% } %>

<%@ include file="../sectionFooter.jsp"%>
