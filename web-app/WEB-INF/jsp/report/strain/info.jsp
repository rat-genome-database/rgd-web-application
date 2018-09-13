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
<%@ include file="../sectionHeader.jsp"%>

<%
    String ontId = ontologyDAO.getStrainOntIdForRgdId(obj.getRgdId());
    if( ontId==null )
        ontId = "N/A";
    request.setAttribute("ontId", ontId);
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
        List<Alias> aliases = aliasDAO.getAliases(obj.getRgdId());
        if( !aliases.isEmpty() ) {
    %>
    <tr>
        <td class="label" valign="top">Also&nbsp;known&nbsp;as:</td>
        <td><%=Utils.concatenate("; ", aliases, "getValue")%></td>
    </tr>
    <% } %>
    
    <tr>
        <td class="label">Type:</td>
        <td><%=fu.chkNullNA(obj.getStrainTypeName())%></td>
    </tr>
    <tr>
        <td class="label">Source:</td>
        <td><%=fu.chkNullNA(obj.getSource())%></td>
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
<%@ include file="../sectionFooter.jsp"%>
