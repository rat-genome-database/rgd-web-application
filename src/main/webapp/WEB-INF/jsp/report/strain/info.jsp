<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermWithStats" %>
<%@ page import="edu.mcw.rgd.process.pheno.SearchBean" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Record" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Condition" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.Statement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="java.sql.Blob" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.io.ByteArrayOutputStream" %>
<%@ include file="../sectionHeader.jsp"%>

<%
    String ontId = ontologyDAO.getStrainOntIdForRgdId(obj.getRgdId());
    if( ontId==null )
        ontId = "N/A";
    request.setAttribute("ontId", ontId);

    RgdId id = managementDAO.getRgdId(obj.getRgdId());

    List<Alias> aliases = aliasDAO.getAliases(obj.getRgdId());

    // add to aliases 'TAGLESS_STRAIN_SYMBOL'
    if( !Utils.isStringEmpty(obj.getTaglessStrainSymbol()) && !Utils.stringsAreEqualIgnoreCase(obj.getSymbol(), obj.getTaglessStrainSymbol()) ) {

        boolean isDuplicate = false;
        for( Alias a: aliases ) {
            if( Utils.stringsAreEqualIgnoreCase(obj.getTaglessStrainSymbol(), a.getValue()) ) {
                isDuplicate = true;
                break;
            }
        }

        // if a tagless strain symbol is already the same as one of the existing aliases -- do not add it
        if( !isDuplicate ) {
            // create 'fake' alias for tagless strain symbol
            Alias alias = new Alias();
            alias.setRgdId(obj.getRgdId());
            alias.setTypeName("tagless_strain_symbol");
            alias.setValue(obj.getTaglessStrainSymbol());
            aliases.add(alias);
        }
    }

    String RRRCid = null;
    List<XdbId> xids = xdbDAO.getXdbIdsByRgdId(141, obj.getRgdId());
    if( !xids.isEmpty() ) {
        String accId = xids.get(0).getAccId();
        if( accId.length()==4 ) {
            RRRCid = "RRRC_0" + accId;
        } else {
            RRRCid = "RRRC_" + accId;
        }
    }
%>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr><td colspan="2"><h3>Strain: <%=obj.getSymbol()%></h3></td></tr>

    <tr>
        <td class="label">Symbol:</td>
        <td><%=obj.getSymbol()%></td>
    </tr>

    <tr>
        <td class="label">Strain:</td>
        <td><%=obj.getStrain()%></td>
    </tr>

    <% if (obj.getSubstrain() != null) { %>
    <tr>
        <td class="label">Substrain:</td>
        <td><%=obj.getSubstrain()%></td>
    </tr>
    <% } %>

    <% if( obj.getName() != null ) { %>
    <tr>
        <td class="label">Full Name:</td>
        <td><%=obj.getName()%></td>
    </tr>
    <% } %>


    <tr>
        <td class="label">RGD ID:</td>
        <td><%=id.getRgdId()%></td>
    </tr>


    <tr>
        <td class="label">Citation ID:</td>
        <td>RRID:<% if( RRRCid==null ) {
            out.print("RGD_" + obj.getRgdId());
        } else {
            out.print(RRRCid);
        }%></td>
    </tr>

    <tr>
        <td class="label">Ontology ID:</td>
        <td>
        <% if( ontId.equals("N/A") ) { %>
            <%=ontId%>
        <% } else { %>
            <a href="<%=Link.ontView(ontId)%>" title="click to go to strain ontology"><%=ontId%></a>
        <% } %>
        </td>
    </tr>

    <%
        List<Strain2MarkerAssociation> geneAlleles = (List<Strain2MarkerAssociation>) request.getAttribute("gene_alleles");
        if( geneAlleles!=null && !geneAlleles.isEmpty() ) {
    %>
    <tr>
        <td class="label" valign="top">Alleles:</td>
        <td><%
            int allelesPrinted = 0;
            for (Strain2MarkerAssociation a: geneAlleles) {
                if( allelesPrinted++ > 0 )
                    out.print("; &nbsp; ");
                out.print("<a href=\""+Link.gene(a.getMarkerRgdId())+"\">"+a.getMarkerSymbol()+"</a>");
            }
        %></td>
    </tr>
    <% } %>
    <%
        RgdVariantDAO variantDAO = new RgdVariantDAO();
        List<RgdVariant> variants = variantDAO.getVariantsFromStrainKey(obj.getKey());
        String joinedLinks="";
        if(variants.size()>0){
            Set<String>seenNames = new HashSet<>();
            List<String>links= new ArrayList<>();
    %>
    <tr>
        <td class="label">Variant(s):</td>
        <%for(RgdVariant variant:variants){
            if(!seenNames.contains(variant.getName())){
                seenNames.add(variant.getName());
                links.add("<a href=\"/rgdweb/report/rgdvariant/main.html?id=" + variant.getRgdId() + "\">" + variant.getName() + "</a>");
            }
        }
            joinedLinks = String.join("; ",links);
        %>
        <td><%=joinedLinks%></td>
    </tr>
    <% } %>
    <%
        if( !aliases.isEmpty() ) {
    %>
    <tr>
        <td class="label" valign="top">Also&nbsp;Known&nbsp;As:</td>
        <td><%=Utils.concatenate("; ", aliases, "getValue")%></td>
    </tr>
    <% } %>
    
    <tr>
        <td class="label">Type:</td>
        <td><%=fu.chkNullNA(obj.getStrainTypeName())%></td>
    </tr>
    <tr>
        <td class="label">Available Source:</td>
        <td id="strain-info-table-source-data"><%=fu.chkNullNA(obj.getSource())%></td>
    </tr>
    <%if(obj.getOrigination()!=null){%>
    <tr>
        <td class="label">Origination:</td>
        <td><%=obj.getOrigination()%></td>
    </tr>
    <% } %>
    <% if (obj.getImageUrl() != null) { %>
    <tr>
        <td class="label">Photo</td>
        <td><img src="<%=obj.getImageUrl()%>"/></td>
    </tr>
    <% } %>
    <% if (obj.getDescription() != null) { %>
    <tr>
        <td class="label">Description:</td>
        <td><%=obj.getDescription()%></td>
    </tr>
    <% } %>
    <% if (obj.getGenetics() != null) { %>
    <tr>
        <td class="label">Genetic Markers:</td>
        <td><%=obj.getGenetics()%></td>
    </tr>
    <% } %>
    <% if (obj.getGeneticStatus() != null) { %>
    <tr>
        <td class="label">Genetic Status:</td>
        <td><%=obj.getGeneticStatus()%></td>
    </tr>
    <% } %>
    <% if (obj.getColor() != null) { %>
    <tr>
        <td class="label">Coat Color:</td>
        <td><%=obj.getColor()%></td>
    </tr>
    <% } %>
    <% if (obj.getInbredGen() != null) { %>
    <tr>
        <td class="label">Inbred Generations:</td>
        <td><%=obj.getInbredGen()%></td>
    </tr>
    <% } %>
    <tr>
        <td class="label">Last Known Status:</td>
        <td><%=obj.getLastStatus()%></td>
    </tr>

    <% if (obj.getResearchUse() != null) { %>
    <tr>
        <td class="label">Research Usage</td>
        <td><%=obj.getResearchUse()%></td>
    </tr>
    <% } %>
<% String content = strainDAO.getContentType(obj.getRgdId(),"Genotype");
    if(content != null) {
%> <tr>
    <td class="label">Genotyping Protocol</td>
    <td><a href="/rgdweb/report/strain/strainFileDownload.html?id=<%=obj.getRgdId()%>&type=Genotype" download="true">Download Genotyping Protocol </a></td>
</tr>
    <% } %>
    <% String supp = strainDAO.getContentType(obj.getRgdId(),"Supplemental");
        if(supp != null) {
    %> <tr>
    <td class="label">Strain Phenotyping</td>
    <td><a href="/rgdweb/report/strain/strainFileDownload.html?id=<%=obj.getRgdId()%>&type=Supplemental" download="true">View Strain Phenotyping </a></td>
</tr>
    <% } %>

    <%
        List<MapData> mapData = mapDAO.getMapData(obj.getRgdId());
        if( !mapData.isEmpty() ) {
    %>
    <tr>
        <td class="label">Position</td>
        <td><%=MapDataFormatter.buildTable(obj.getSpeciesTypeKey(), mapData, rgdId.getObjectKey(), obj.getSymbol())%></td>
    </tr>
    <% } %>
    <%if(new HrdpPortalCacheDAO().checkAvailableStrainExists(String.valueOf(obj.getRgdId()))){%>
    <tr>
        <td class="label">Portal(s):</td>
        <td><a href="/rgdweb/hrdp_panel.html">HRDP portal</a></td>
    </tr>
    <%}%>
</table>

<br>
<script>
    let data = document.getElementById("strain-info-table-source-data");
    let link = data.getElementsByTagName('a')[0];
    if(data.textContent.trim() === "PGA"){
        link.removeAttribute("href");
    }
</script>
<%@ include file="../sectionFooter.jsp"%>
