<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.math.RoundingMode" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    if (isGwas){
    QTLDAO qdao = new QTLDAO();
%>
<div class="gwasDataTable light-table-border" id="gwasDataTableWrapper">
    <div class="sectionHeading" id="gwasData">GWAS QTLs Related by Peak Marker</div>

    <div class="search-and-pager">
        <div class="modelsViewContent" >
            <div class="pager gwasDataPager" >
                <form>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                    <span type="text" class="pagedisplay"></span>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                    <select class="pagesize">
                        <option selected="selected" value="10">10</option>
                        <option value="20">20</option>
                        <option value="30">30</option>
                        <option  value="40">40</option>
                        <option   value="100">100</option>
                        <option value="9999">All Rows</option>
                    </select>
                </form>
            </div>
        </div>

        <input class="search table-search" id="gwasDataSearch" type="search" data-column="all" placeholder="Search table">
    </div>

    <div id="gwasDataTableDiv" class="annotation-detail">
        <table id="gwasDataTable" class="tablesorter" border='0' cellpadding='2' cellspacing='2' >
            <tr>
                <td>QTL</td>
                <td>GWAS Catalog Study</td>
                <td>Disease&nbsp;Trait</td>
                <td>Study&nbsp;Size</td>
                <td>Risk&nbsp;Allele</td>
                <td>Risk&nbsp;Allele&nbsp;Frequency</td>
                <td>P&nbsp;Value</td>
                <td>P Value MLOG</td>
                <td>Peak Marker</td> <!-- change to peak marker -->
                <td>Reported Odds Ratio or Beta-coefficient</td>
                <td>Ontology&nbsp;Accession</td>
                <td>PubMed</td>
            </tr>
<%
        for (GWASCatalog gwas : gwasList){
            String lessTerms = "";
            String moreTerms = "";
            List<Term> gwasTerms = new ArrayList<>();
            String gwasTerm = "";
            String[] terms = {};
            if (!Utils.isStringEmpty(gwas.getEfoId())) {
                 gwasTerm = gwas.getEfoId().replace('_', ':');
                 terms = gwasTerm.split(",");
            }
    for (String termAcc : terms) {
        if (termAcc.contains("Orphanet") || termAcc.contains("NCIT") || termAcc.contains("MONDO"))
            continue;
        String trimmed = termAcc.trim();
//                System.out.println(trimmed);
        Term term = odao.getTermByAccId(trimmed);
        gwasTerms.add(term);
    }

    for (int i = 0; i < gwasTerms.size(); i++) {
        if (gwasTerms.get(i)!=null) {
            if (i < 4) {
                lessTerms += gwasTerms.get(i).getTerm() + "&nbsp;<a href=\"" + Link.ontView(gwasTerms.get(i).getAccId()) +
                        "\" title=\"click to go to ontology page\">(" + gwasTerms.get(i).getAccId() + ")</a><br>";
            } else {
                moreTerms += gwasTerms.get(i).getTerm() + "&nbsp;<a href=\"" + Link.ontView(gwasTerms.get(i).getAccId()) +
                        "\" title=\"click to go to ontology page\">(" + gwasTerms.get(i).getAccId() + ")</a><br>";
            }
        }
    }

    QTL q = null;
    String qtlExist = "";
    if (gwas.getQtlRgdId() != null && gwas.getQtlRgdId() != 0) {
        try {
            q = qdao.getQTL(gwas.getQtlRgdId());
            qtlExist = "<a href=\"/rgdweb/report/qtl/main.html?id=" + q.getRgdId() + "\">" + q.getSymbol() + "</a>";
        } catch (Exception e) {
            qtlExist = "None Available";
        }
    } else
        qtlExist = "None Available";

    String studiesUrl = "https://www.ebi.ac.uk/gwas/studies/" + gwas.getStudyAcc();
    String pmid = gwas.getPmid().split(":")[1];
    String url = "https://pubmed.ncbi.nlm.nih.gov/" + pmid;

            DecimalFormat df = new DecimalFormat("#.###");
            df.setRoundingMode(RoundingMode.CEILING);
 if (gwas.getQtlRgdId()!= null && obj.getRgdId()==gwas.getQtlRgdId()){
%>
            <tr id="rowOfInterest" class="rowOfInterest">
            <% } else {%>
            <tr>
            <% } %>

                <td><%=qtlExist%></td>
                <td><span><a href="<%=studiesUrl%>"><%=gwas.getStudyAcc()%></a></span></td>
                <td><%=gwas.getDiseaseTrait()%></td>
                <td><%=gwas.getInitialSample()%></td>
                <td><%=gwas.getStrongSnpRiskallele()%></td>
                <td><%=Utils.NVL(gwas.getRiskAlleleFreq(),"N/A")%></td>
                <td><%=gwas.getpVal()%></td>
                <td><%=df.format(gwas.getpValMlog())%></td>
                <td><a href="/rgdweb/report/rsId/main.html?id=<%=gwas.getSnps()%>"><%=gwas.getSnps()%></a></td>
                <td><%=Utils.NVL(gwas.getOrBeta(),"N/A")%></td>
                <td><%=Utils.NVL(lessTerms, "N/A")%>
                    <% if (gwasTerms.size()>4) {%>
                    <span class="more" style="display: none;"><%=moreTerms%> </span><a href="" class="moreLink" title="Click to see more"> More...</a>
                    <% } %>
                </td>
                <td><span>PMID:<a href="<%=url%>"><%=pmid%></a></span></td>
            </tr>
            <% } %>
        </table>
    </div>
    <div class="modelsViewContent" >
        <div class="pager gwasDataPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
</div>
<style>

    #rowOfInterest td{
        background-color: #fffeb4;
    }
</style>
<script>
    var table = document.getElementById("gwasDataTable");
    var rows = table.getElementsByTagName("tr");
    var secondRow = rows[1];
    var rowOfInterest = document.getElementById("rowOfInterest");
    if (secondRow!==rowOfInterest) {
        secondRow.parentNode.insertBefore(rowOfInterest.parentNode.removeChild(rowOfInterest), secondRow);
    }
</script>
<% } %>
<%@ include file="../sectionFooter.jsp"%>