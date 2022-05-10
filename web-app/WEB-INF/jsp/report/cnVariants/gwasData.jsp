<%@ include file="../sectionHeader.jsp"%>
<%
    if (isGwas){
    String studiesUrl = "https://www.ebi.ac.uk/gwas/studies/"+gwas.getStudyAcc();
        String pmid = gwas.getPmid().split(":")[1];
        String url = "https://pubmed.ncbi.nlm.nih.gov/"+pmid;
%>
<div class="gwasDataTable light-table-border" id="gwasDataTableWrapper">
    <div class="sectionHeading" id="gwasData">GWAS Catalog Data</div>
    <div id="gwasDataTableDiv" class="annotation-detail">
        <table id="gwasDataTable" class="tablesorter" border='0' cellpadding='2' cellspacing='2' >
            <tr>
                <td>GWAS Catalog Study</td>
                <td>Disease Trait</td>
                <td>Study Size</td>
                <td>Risk Allele Frequency</td>
                <td>P&nbsp;Value</td>
                <td>P Value MLOG</td>
                <td>SNP Passing QC</td>
                <td>Reported Odds Ratio or Beta-coefficient</td>
                <td>Ontology Accession</td>
                <td>PubMed</td>
            </tr>
            <tr>
                <td><span><a href="<%=studiesUrl%>"><%=gwas.getStudyAcc()%></a></span></td>
                <td><%=gwas.getDiseaseTrait()%></td>
                <td><%=gwas.getInitialSample()%></td>
                <td><%=gwas.getRiskAlleleFreq()%></td>
                <td><%=gwas.getpVal()%></td>
                <td><%=gwas.getpValMlog()%></td>
                <td><%=gwas.getSnpPassQc()%></td>
                <td><%=gwas.getOrBeta()%></td>
                <td>
                    <%for (Term efo : gwasTerms) {%>
                    <%=efo.getTerm()%>&nbsp;<a href="<%=Link.ontView(efo.getAccId())%>" title="click to go to ontology page"><%= "("+ efo.getAccId() + ")"%></a>&nbsp;
                    <% } %>
                </td>
                <td><span>PMID:<a href="<%=url%>"><%=pmid%></a></span></td>
            </tr>

        </table>
    </div>
</div>
<% } %>
<%@ include file="../sectionFooter.jsp"%>