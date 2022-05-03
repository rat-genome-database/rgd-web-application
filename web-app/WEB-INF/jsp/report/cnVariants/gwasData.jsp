<%@ include file="../sectionHeader.jsp"%>
<%
    if (isGwas){
    String studiesUrl = "https://www.ebi.ac.uk/gwas/studies/"+gwas.getStudyAcc();
%>
<div class="gwasDataTable light-table-border" id="gwasDataTableWrapper">
    <div class="sectionHeading" id="gwasData">GWAS Catalog Data</div>
    <div id="gwasDataTableDiv" >
        <table id="gwasDataTable" class="tablesorter" border='0' cellpadding='2' cellspacing='2' >
            <tr></tr>
            <tr>
                <td class="label" style="background-color: #e0e2e1;width:fit-content;">GWAS Catalog Study:</td>
                <td>
                <span><a href="<%=studiesUrl%>"><%=gwas.getStudyAcc()%></a></span>
            </td>
            </tr>
            <tr>
                <td class="label" style="background-color: #e0e2e1;width:fit-content;">Disease Trait:</td>
                <td><%=gwas.getDiseaseTrait()%></td>
            </tr>
            <tr>
                <td class="label" style="background-color: #e0e2e1;width:fit-content;">Study Size:</td>
                <td><%=gwas.getInitialSample()%></td>
            </tr>
            <tr>
                <td class="label" style="background-color: #e0e2e1;width:fit-content;">Risk Allele Frequency:</td>
                <td><%=gwas.getRiskAlleleFreq()%></td>
            </tr>
            <tr>
                <td class="label" style="background-color: #e0e2e1;width:fit-content;">P&nbsp;Value:</td>
                <td><%=gwas.getpVal()%></td>
            </tr>
            <tr>
                <td class="label" style="background-color: #e0e2e1;width:fit-content;">P Value MLOG:</td>
                <td><%=gwas.getpValMlog()%></td>
            </tr>
            <tr>
                <td class="label" style="background-color: #e0e2e1;width:fit-content;">SNP Passing QC:</td>
                <td><%=gwas.getSnpPassQc()%></td>
            </tr>
            <tr>
                <td class="label" style="background-color: #e0e2e1;width:fit-content;">Reported Odds Ratio or Beta-coefficient:</td>
                <td><%=gwas.getOrBeta()%></td>
            </tr>
            <tr>
                <td class="label" style="background-color: #e0e2e1;width:fit-content;">Ontology Accession:</td>
                <td>
                    <%for (Term efo : gwasTerms) {%>
                    <%=efo.getTerm()%>&nbsp;<a href="<%=Link.ontView(efo.getAccId())%>" title="click to go to ontology page"><%= "("+ efo.getAccId() + ")"%></a>&nbsp;
                    <% } %>
                </td>
            </tr>

        </table>
    </div>
</div>
<% } %>
<%@ include file="../sectionFooter.jsp"%>