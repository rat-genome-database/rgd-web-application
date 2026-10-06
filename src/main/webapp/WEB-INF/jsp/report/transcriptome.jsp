<%
    List<XdbId>  xIds = xdbDAO.getXdbIdsByRgdId(20,obj.getRgdId());

    if (xIds.size() > 0 && obj.getSpeciesTypeKey()==3) {
        String ensemblId=xIds.get(0).getAccId();
%>

<%@ include file="sectionHeader.jsp"%>

<%-- sample gene: Agt(ENSRNOG00000018445)

     Three links to three sections of one Phenogen page. This was a 3x3 table: a grey label
     cell, a "&nbsp;" spacer column, and "View at Phenogen" repeated verbatim on all three
     rows - nine cells to carry three links, where the only thing that differed between rows
     was the section name already sitting in the left column. The repeated words are the
     lead-in now, so each link only has to name its own section. --%>
<%
    String phenogenUrl = "https://phenogen.org/gene.jsp?speciesCB=Rn&auto=Y&geneTxt="
            + ensemblId + "&genomeVer=rn6&section=";
%>
<div class="light-table-border">
<div class="sectionHeading" id="transcriptome">Transcriptome</div>
<div class="rgdLinkRow">
    <span class="rgdLinkRowLead">View this gene at Phenogen:</span>
    <a class="rgdChipLink" href="<%=phenogenUrl%>geneEQTL" title="expression QTLs at Phenogen">eQTL</a>
    <a class="rgdChipLink" href="<%=phenogenUrl%>geneWGCNA" title="weighted gene co-expression network analysis at Phenogen">WGCNA</a>
    <a class="rgdChipLink" href="<%=phenogenUrl%>geneApp" title="tissue and strain expression at Phenogen">Tissue/strain expression</a>
</div>
</div>

<%@ include file="sectionFooter.jsp"%>
<%
    }
%>