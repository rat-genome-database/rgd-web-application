<%
    List<XdbId>  xIds = xdbDAO.getXdbIdsByRgdId(20,obj.getRgdId());

    if (xIds.size() > 0 && obj.getSpeciesTypeKey()==3) {
%>

<%@ include file="sectionHeader.jsp"%>

<%-- One link to Phenogen's gene page.

     This was three deep links into sections of Phenogen's gene.jsp - eQTL, WGCNA and
     tissue/strain expression - each carrying this gene's Ensembl id and genomeVer=rn6
     (sample gene: Agt(ENSRNOG00000018445)). Phenogen retired that url and all three stopped
     working. Their generic gene page is what replaces it: there is no per-section equivalent
     to point at and nothing gene-specific to pass, so three links collapse into one and the
     lead-in has to stop promising this gene in particular.

     The section still renders only for rat genes carrying an Ensembl id (xdb key 20). The id
     no longer goes into the url, but keeping the condition leaves the section on exactly the
     genes that showed it before rather than adding it to every rat gene report. --%>
<div class="light-table-border">
<div class="sectionHeading" id="transcriptome">Transcriptome</div>
<div class="rgdLinkRow">
    <span class="rgdLinkRowLead">Rat expression, eQTL and co-expression data at Phenogen:</span>
    <a class="rgdChipLink" href="https://phenogen.org/gene.html" title="look this gene up at Phenogen">Phenogen gene search</a>
</div>
</div>

<%@ include file="sectionFooter.jsp"%>
<%
    }
%>