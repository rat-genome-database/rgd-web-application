<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%
    Map map = mapDAO.getMap(mapKey);
%>
<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <!-- select which variant you want to view -->
    <tr><td colspan="2"><h3>Your selection has multiple variants. Select which variant for <%=displayName%>&nbsp;you would like to view -&nbsp;<a style="margin-bottom: 0.5rem;font-weight: 500;line-height: 1.2;font-size: 1.75rem;color: #2865a3;" href='<%=SpeciesType.getNCBIAssemblyDescriptionForSpecies(map.getSpeciesTypeKey())%>'><%=SpeciesType.getTaxonomicName(speciesType)%></a>
    </h3></td></tr>
    <tr>
        <td class="label">
        Position(s)
        </td>
        <td>
            <table border="0" class="mapDataTable" width="670">
                <tr>
                    <th align="left"><b>RGD ID</b></th>
                    <% if (isGene) { %>
                    <th align="left">rs ID</th> <% } %>
                    <th align="left">Chr</th>
                    <th align="left">Position</th>
                    <th align="left">Reference Nucleotide</th>
                    <th align="left">Variant Nucleotide</th>
                    <th align="left">Assembly</th>
                </tr>
                <% for (VariantMapData v : vars) { %>
                <tr>
                    <td><a style='color:blue;font-weight:700;font-size:11px;' href="/rgdweb/report/variants/main.html?id=<%=v.getId()%>" title="see more information in the variant page"><%=v.getId()%></a></td>
                    <% if (isGene) {
                        String rsId = "<a href=\"https://www.ebi.ac.uk/eva/?variant&accessionID="+v.getRsId()+"\">"+v.getRsId()+"</a>";%>
                    <td align="left"><%=(v.getRsId()!=null && !v.getRsId().equals("."))?rsId:"-"%></td> <% } %>
                    <td><%=v.getChromosome()%></td>
                    <td><%=NumberFormat.getNumberInstance(Locale.US).format(v.getStartPos())%>&nbsp;-&nbsp;<%=NumberFormat.getNumberInstance(Locale.US).format(v.getEndPos())%></td>
                    <td><%=Utils.NVL(v.getReferenceNucleotide(), "-")%></td>
                    <td><%=Utils.NVL(v.getVariantNucleotide(),"-")%></td>
                    <td><%=map.getName()%></td>
                </tr>
                <% } %>
            </table></td>
    </tr>
</table>