<%@ page import="edu.mcw.rgd.search.elasticsearch1.model.SearchBean" %>
<%@ page import="org.springframework.ui.ModelMap" %>
<%@ page import="org.elasticsearch.search.aggregations.bucket.terms.Terms" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.URLEncoder" %>
<%
    ModelMap model = (ModelMap) request.getAttribute("model");
    SearchBean searchBean = (SearchBean) model.get("searchBean");
    Map<String, List<? extends Terms.Bucket>> aggregations =
            (Map<String, List<? extends Terms.Bucket>>) model.get("aggregations");

    String species = searchBean.getSpecies();
    String assembly = searchBean.getAssembly();
    String category = searchBean.getCategory();
    String categoryLC = (category == null) ? "" : category.toLowerCase();

    String speciesLC = (species == null) ? "" : species.toLowerCase();

    // Per-category aggregation keys (mirrors naming in sidebar4.jsp/SearchService)
    String geneKey            = speciesLC + "Gene";
    String strainKey          = speciesLC + "Strain";
    String qtlKey             = speciesLC + "QTL";
    String sslpKey            = speciesLC + "SSLP";
    String cellLineKey        = speciesLC + "Cell line";
    String promoterKey        = speciesLC + "Promoter";
    String variantCategoryKey = speciesLC + "VariantCategory";
    String variantTypeKey     = speciesLC + "Variant";
    String regionKey          = speciesLC + "Region";
    String sampleKey          = speciesLC + "Sample";
    String polyphenKey        = speciesLC + "Polyphen";
    String esStrainKey        = speciesLC + "ESStrainTerms";
    String esTissueKey        = speciesLC + "ESTissueTerms";
    String esCellTypeKey      = speciesLC + "ESCellTypeTerms";
    String esConditionsKey    = speciesLC + "ESConditions";
    String exprGeneTypeKey    = speciesLC + "ExpressionGeneType";
    String exprLevelKey       = speciesLC + "ExpressionLevel";
%>
<div>
    <h3>Filters</h3>
    <div style="font-size:13px;margin-bottom:10px">
        <strong>Species:</strong> <%=species%><br>
        <strong>Assembly:</strong> <%=assembly%><br>
        <strong>Category:</strong> <%=category%>
    </div>
    <div id="jstree_results">
        <ul>
            <%-- ============ VARIANT ============ --%>
            <% if(categoryLC.equals("variant")) { %>
                <% List<? extends Terms.Bucket> vcatBkts = aggregations.get(variantCategoryKey);
                   if(vcatBkts != null && !vcatBkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Category</span>
                    <ul>
                        <% for(Terms.Bucket bkt : vcatBkts) { %>
                        <li onclick="filterClick('Variant', '<%=species%>','', '<%=bkt.getKey()%>','variantCategory')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>
                <% List<? extends Terms.Bucket> vtypeBkts = aggregations.get(variantTypeKey);
                   if(vtypeBkts != null && !vtypeBkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Type</span>
                    <ul>
                        <% for(Terms.Bucket bkt : vtypeBkts) { %>
                        <li onclick="filterClick('Variant', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>
                <% List<? extends Terms.Bucket> regionBkts = aggregations.get(regionKey);
                   if(regionBkts != null && !regionBkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Region</span>
                    <ul>
                        <% for(Terms.Bucket bkt : regionBkts) { %>
                        <li onclick="filterClick('Variant', '<%=species%>','', '<%=bkt.getKey()%>','region')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>
                <% List<? extends Terms.Bucket> sampleBkts = aggregations.get(sampleKey);
                   if(sampleBkts != null && !sampleBkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Sample</span>
                    <ul>
                        <% for(Terms.Bucket bkt : sampleBkts) { %>
                        <li onclick="filterClick('Variant', '<%=species%>','', '<%=bkt.getKey()%>','sample')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>
                <% List<? extends Terms.Bucket> polyphenBkts = aggregations.get(polyphenKey);
                   if(polyphenBkts != null && !polyphenBkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Polyphen</span>
                    <ul>
                        <% for(Terms.Bucket bkt : polyphenBkts) { %>
                        <li onclick="filterClick('Variant', '<%=species%>','', '<%=bkt.getKey()%>','polyphenStatus')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>

            <%-- ============ GENE ============ --%>
            <% } else if(categoryLC.equals("gene")) {
                List<? extends Terms.Bucket> bkts = aggregations.get(geneKey);
                if(bkts != null && !bkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Gene</span>
                    <ul>
                        <% for(Terms.Bucket bkt : bkts) { %>
                        <li onclick="filterClick('Gene', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>

            <%-- ============ STRAIN ============ --%>
            <% } else if(categoryLC.equals("strain")) {
                List<? extends Terms.Bucket> bkts = aggregations.get(strainKey);
                if(bkts != null && !bkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Strain</span>
                    <ul>
                        <% for(Terms.Bucket bkt : bkts) { %>
                        <li onclick="filterClick('Strain', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>

            <%-- ============ QTL ============ --%>
            <% } else if(categoryLC.equals("qtl")) {
                List<? extends Terms.Bucket> bkts = aggregations.get(qtlKey);
                if(bkts != null && !bkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">QTL Trait</span>
                    <ul>
                        <% for(Terms.Bucket bkt : bkts) {
                            String qtlFacet = bkt.getKey().toString();
                            String qtlTitle = qtlFacet;
                            if(qtlFacet.length() > 50) qtlFacet = qtlFacet.substring(0,50) + "...";
                        %>
                        <li onclick="filterClick('QTL', '<%=species%>','', '<%=URLEncoder.encode(bkt.getKey().toString(),"UTF-8")%>','trait')" title="<%=qtlTitle%>"><%=qtlFacet%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>

            <%-- ============ SSLP ============ --%>
            <% } else if(categoryLC.equals("sslp")) {
                List<? extends Terms.Bucket> bkts = aggregations.get(sslpKey);
                if(bkts != null && !bkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">SSLP</span>
                    <ul>
                        <% for(Terms.Bucket bkt : bkts) { %>
                        <li onclick="filterClick('SSLP', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>

            <%-- ============ CELL LINE ============ --%>
            <% } else if(categoryLC.equals("cell line")) {
                List<? extends Terms.Bucket> bkts = aggregations.get(cellLineKey);
                if(bkts != null && !bkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Cell line</span>
                    <ul>
                        <% for(Terms.Bucket bkt : bkts) { %>
                        <li onclick="filterClick('Cell line', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>

            <%-- ============ PROMOTER ============ --%>
            <% } else if(categoryLC.equals("promoter")) {
                List<? extends Terms.Bucket> bkts = aggregations.get(promoterKey);
                if(bkts != null && !bkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Promoter</span>
                    <ul>
                        <% for(Terms.Bucket bkt : bkts) { %>
                        <li onclick="filterClick('Promoter', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>

            <%-- ============ EXPRESSION STUDY ============ --%>
            <% } else if(categoryLC.equals("expression study")) {
                List<? extends Terms.Bucket> strainBkts = aggregations.get(esStrainKey);
                if(strainBkts != null && !strainBkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Strains</span>
                    <ul>
                        <% for(Terms.Bucket bkt : strainBkts) { %>
                        <li onclick="filterClick('Expression Study', '<%=species%>','', decodeURIComponent('<%=URLEncoder.encode(bkt.getKey().toString(),"UTF-8").replace("+","%20")%>'),'strainTerms')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% }
                List<? extends Terms.Bucket> tissueBkts = aggregations.get(esTissueKey);
                if(tissueBkts != null && !tissueBkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Tissues</span>
                    <ul>
                        <% for(Terms.Bucket bkt : tissueBkts) { %>
                        <li onclick="filterClick('Expression Study', '<%=species%>','', decodeURIComponent('<%=URLEncoder.encode(bkt.getKey().toString(),"UTF-8").replace("+","%20")%>'),'tissueTerms')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% }
                List<? extends Terms.Bucket> cellTypeBkts = aggregations.get(esCellTypeKey);
                if(cellTypeBkts != null && !cellTypeBkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Cell Type</span>
                    <ul>
                        <% for(Terms.Bucket bkt : cellTypeBkts) { %>
                        <li onclick="filterClick('Expression Study', '<%=species%>','', decodeURIComponent('<%=URLEncoder.encode(bkt.getKey().toString(),"UTF-8").replace("+","%20")%>'),'cellTypeTerms')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% }
                List<? extends Terms.Bucket> condBkts = aggregations.get(esConditionsKey);
                if(condBkts != null && !condBkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Conditions</span>
                    <ul>
                        <% for(Terms.Bucket bkt : condBkts) {
                            String facet = bkt.getKey().toString();
                            if(facet.length() > 30) facet = facet.substring(0,30) + "...";
                        %>
                        <li onclick="filterClick('Expression Study', '<%=species%>','', decodeURIComponent('<%=URLEncoder.encode(bkt.getKey().toString(),"UTF-8").replace("+","%20")%>'),'conditions')"><%=facet%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>

            <%-- ============ EXPRESSED GENE ============ --%>
            <% } else if(categoryLC.equals("expressed gene")) {
                List<? extends Terms.Bucket> gtBkts = aggregations.get(exprGeneTypeKey);
                if(gtBkts != null && !gtBkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Gene Type</span>
                    <ul>
                        <% for(Terms.Bucket bkt : gtBkts) { %>
                        <li onclick="filterClick('Expressed Gene', '<%=species%>','', '<%=bkt.getKey()%>','type')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% }
                List<? extends Terms.Bucket> lvlBkts = aggregations.get(exprLevelKey);
                if(lvlBkts != null && !lvlBkts.isEmpty()) { %>
                <li><span style="font-weight:bold;color:#24609c">Expression Level</span>
                    <ul>
                        <% for(Terms.Bucket bkt : lvlBkts) { %>
                        <li onclick="filterClick('Expressed Gene', '<%=species%>','', '<%=bkt.getKey()%>','expressionLevel')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
                <% } %>

            <%-- ============ GENERAL / FALLBACK ============
                 Show every available sub-facet for this species (mirrors facets.jsp but scoped to one species).         --%>
            <% } else {
                String[][] genericGroups = new String[][] {
                    {"Gene",         geneKey},
                    {"Strain",       strainKey},
                    {"QTL",          qtlKey},
                    {"SSLP",         sslpKey},
                    {"Cell line",    cellLineKey},
                    {"Promoter",     promoterKey},
                    {"Variant Type", variantTypeKey}
                };
                for(String[] grp : genericGroups) {
                    String label = grp[0];
                    String aggKey = grp[1];
                    List<? extends Terms.Bucket> bkts = aggregations.get(aggKey);
                    if(bkts == null || bkts.isEmpty()) continue;
            %>
                <li><span style="font-weight:bold;color:#24609c"><%=label%></span>
                    <ul>
                        <% for(Terms.Bucket bkt : bkts) { %>
                        <li onclick="filterClick('<%=label.equals("Variant Type") ? "Variant" : label%>', '<%=species%>','', '<%=bkt.getKey()%>')"><%=bkt.getKey()%> (<%=bkt.getDocCount()%>)</li>
                        <% } %>
                    </ul>
                </li>
            <% } } %>
        </ul>
    </div>
</div>
