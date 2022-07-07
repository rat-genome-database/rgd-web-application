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
        if( !aliases.isEmpty() ) {
    %>
    <tr>
        <td class="label" valign="top">Previously&nbsp;known&nbsp;as:</td>
        <td><%=Utils.concatenate("; ", aliases, "getValue")%></td>
    </tr>
    <% } %>
    
    <tr>
        <td class="label">Type:</td>
        <td><%=fu.chkNullNA(obj.getStrainTypeName())%></td>
    </tr>
    <tr>
        <td class="label">Source:</td>
        <td id="strain-info-table-source-data"><%=fu.chkNullNA(obj.getSource())%></td>
    </tr>

    <% if (obj.getImageUrl() != null) { %>
    <tr>
        <td class="label">Photo</td>
        <td><img src="<%=obj.getImageUrl()%>"/></td>
    </tr>
    <% } %>
    <% if (obj.getOrigin() != null) { %>
    <tr>
        <td class="label">Origin:</td>
        <td><%=obj.getOrigin()%></td>
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
