<%@ include file="../sectionHeader.jsp"%>
<%
    if (isGwas){ %>
<div class="gwasDataTable light-table-border" id="gwasDataTableWrapper">
    <div class="sectionHeading" id="gwasData">GWAS Catalog Data</div>

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
                <td>GWAS Catalog Study</td>
                <td>Disease&nbsp;Trait</td>
                <td>Study&nbsp;Size</td>
                <td>Risk&nbsp;Allele&nbsp;Frequency</td>
                <td>P&nbsp;Value</td>
                <td>P Value MLOG</td>
                <td>SNP Passing QC</td>
                <td>Reported Odds Ratio or Beta-coefficient</td>
                <td>Ontology&nbsp;Accession</td>
                <td>PubMed</td>
            </tr>
<%
        for (GWASCatalog gwas : gwasList){
        String lessTerms = "";
        String moreTerms = "";
        String gwasTerm = gwas.getEfoId().replace('_', ':');
        String[] terms = gwasTerm.split(",");
        for (String termAcc : terms){
            if (termAcc.contains("Orphanet") || termAcc.contains("NCIT") )
                continue;
            String trimmed = termAcc.trim();
//                System.out.println(trimmed);
            Term term = odao.getTermByAccId(trimmed);
            gwasTerms.add(term);
        }

        for (int i = 0; i < gwasTerms.size();i++){
            if (i < 4){
                lessTerms += gwasTerms.get(i).getTerm()+"&nbsp;<a href=\""+Link.ontView(gwasTerms.get(i).getAccId())+
                "\" title=\"click to go to ontology page\">("+gwasTerms.get(i).getAccId()+")</a><br>";
            }
            else{
                moreTerms += gwasTerms.get(i).getTerm()+"&nbsp;<a href=\""+Link.ontView(gwasTerms.get(i).getAccId())+
                        "\" title=\"click to go to ontology page\">("+gwasTerms.get(i).getAccId()+")</a><br>";
            }
        }

    String studiesUrl = "https://www.ebi.ac.uk/gwas/studies/"+gwas.getStudyAcc();
        String pmid = gwas.getPmid().split(":")[1];
        String url = "https://pubmed.ncbi.nlm.nih.gov/"+pmid;
%>

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
                    <%=lessTerms%>
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
<% } %>
<%@ include file="../sectionFooter.jsp"%>