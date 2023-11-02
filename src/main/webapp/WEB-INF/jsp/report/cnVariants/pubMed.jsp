<%if (isGwas && !Utils.isStringEmpty(gwas.getPmid()) ) {
    String pmid = gwas.getPmid().split(":")[1];
    String url = "https://pubmed.ncbi.nlm.nih.gov/"+pmid;
%>
<%@ include file="../sectionHeader.jsp"%>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>

<div class="gwasPubMedReferencesTable light-table-border" id="gwasPubMedReferencesTableWrapper">
    <div class="sectionHeading" id="gwasPubMedReferences">GWAS PubMed Reference</div>

    <div id="gwasPubMedReferencesTableDiv" class="annotation-detail">
        <table id="gwasPubMedReferencesTable" class="tablesorter" border='0' cellpadding='2' cellspacing='2'>
            <tr></tr>
            <tr class="oddRow" role="row">
                <td>
                    <span>PMID:<a href="<%=url%>"><%=pmid%></a></span>
                </td>
            </tr>
        </table>
    </div>

</div>

<%@ include file="../sectionFooter.jsp"%>
<% } %>