<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.XDBIndex" %>
<%@ page import="edu.mcw.rgd.datamodel.XdbId" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    HgncFamily gf = obj;
%>
<table width="100%" border="0" id="info-table">
    <tbody>
    <tr>
        <td class="label" valign="top">Name:</td>
        <td><%=gf.getName()%></td>
    </tr>

    <% if (!Utils.isStringEmpty(gf.getAbbreviation())) { %>
    <tr>
        <td class="label" valign="top">Abbreviation:</td>
        <td><%=gf.getAbbreviation()%></td>
    </tr>
    <% } %>

    <tr>
        <td class="label" valign="top">Family ID:</td>
        <td><%=gf.getFamilyId()%></td>
    </tr>

    <% if (!Utils.isStringEmpty(gf.getDescComment())) { %>
    <tr>
        <td class="label" valign="top">Description:</td>
        <td><%=gf.getDescComment()%></td>
    </tr>
    <% } %>

    <% if (!Utils.isStringEmpty(gf.getDescLabel())) { %>
    <tr>
        <td class="label" valign="top">Description Label:</td>
        <td><%=gf.getDescLabel()%></td>
    </tr>
    <% } %>

    <% if (!Utils.isStringEmpty(gf.getDescSource())) { %>
    <tr>
        <td class="label" valign="top">Description Source:</td>
        <td>
            <% if (gf.getDescSource().startsWith("http://") || gf.getDescSource().startsWith("https://")) { %>
                <a href="<%=gf.getDescSource()%>"><%=gf.getDescSource()%></a>
            <% } else { %>
                <%=gf.getDescSource()%>
            <% } %>
        </td>
    </tr>
    <% } %>

    <% if (!Utils.isStringEmpty(gf.getDescGo())) { %>
    <tr>
        <td class="label" valign="top">Gene Ontology:</td>
        <td>
            <% if (gf.getDescGo().startsWith("http://") || gf.getDescGo().startsWith("https://")) { %>
                <a href="<%=gf.getDescGo()%>"><%=gf.getDescGo()%></a>
            <% } else { %>
                <%=gf.getDescGo()%>
            <% } %>
        </td>
    </tr>
    <% } %>

    <% if (!Utils.isStringEmpty(gf.getExternalNote())) { %>
    <tr>
        <td class="label" valign="top">External Note:</td>
        <td><%=gf.getExternalNote()%></td>
    </tr>
    <% } %>

    <% if (!Utils.isStringEmpty(gf.getPubmedIds())) {
            String pubmedBaseUrl = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_PUBMED).getUrl();
    %>
    <tr>
        <td class="label" valign="top">PubMed IDs:</td>
        <td>
            <%
                String[] pmids = gf.getPubmedIds().split(",");
                for (int i = 0; i < pmids.length; i++) {
                    String pmid = pmids[i].trim();
                    if (!pmid.isEmpty()) {
            %>
                <a href="<%=pubmedBaseUrl + pmid%>">PMID:<%=pmid%></a><%=(i < pmids.length - 1) ? ", " : ""%>
            <%
                    }
                }
            %>
        </td>
    </tr>
    <% } %>

    <% if (!Utils.isStringEmpty(gf.getTypicalGene())) { %>
    <tr>
        <td class="label" valign="top">Typical Gene:</td>
        <td><%=gf.getTypicalGene()%></td>
    </tr>
    <% } %>

    <% if (familyGenes != null && !familyGenes.isEmpty()) { %>
    <tr>
        <td class="label" valign="top">Genes in Family:</td>
        <td>
            <%
                int geneCount = 0;
                for (Gene gene : familyGenes) {
                    geneCount++;
                    boolean isLast = (geneCount == familyGenes.size());
            %>
                <a href="<%=Link.gene(gene.getRgdId())%>"><%=gene.getSymbol()%></a><%=!isLast ? " ; " : ""%>
            <% } %>
        </td>
    </tr>
    <% } %>

    <%
        List<String> hgncIds = (List<String>) request.getAttribute("hgncIds");
        if (hgncIds != null && !hgncIds.isEmpty()) {
            String hgncBaseUrl = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_HGNC).getUrl(SpeciesType.HUMAN);
    %>
    <tr>
        <td class="label" valign="top">All HGNC IDs:</td>
        <td>
            <%
                int hgncCount = 0;
                for (String hgncId : hgncIds) {
                    hgncCount++;
                    boolean isLast = (hgncCount == hgncIds.size());
            %>
                <a href="<%=hgncBaseUrl + hgncId%>"><%=hgncId%></a><%=!isLast ? " ; " : ""%>
            <% } %>
        </td>
    </tr>
    <% } %>

    </tbody>
</table>
<%@ include file="../sectionFooter.jsp"%>
