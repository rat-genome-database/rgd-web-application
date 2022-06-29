<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <!-- select which variant you want to view -->
    <tr><td colspan="2"><h3>This variant maps to multiple locations. Select which position for <%=displayName%>&nbsp;you would like to view -&nbsp;<%=SpeciesType.getTaxonomicName(speciesType)%>
    </h3></td></tr>
    <tr>
        <td class="label">
        Position(s)
        </td>
        <td>
            <table border="0" class="mapDataTable" width="670">
                <tr>
                    <th align="left"><b>RGD ID</b></th>
                    <th align="left">Chr</th>
                    <th align="left">Position</th>
                    <th align="left">Reference Nucleotide</th>
                    <th align="left">Variant Nucleotide</th>
                    <th align="left">Assembly</th>
                </tr>
                <% for (VariantMapData v : vars) {
                    Map map = mapDAO.getMap(v.getMapKey()); %>
                <tr>
                    <td><a style='color:blue;font-weight:700;font-size:11px;' href="/rgdweb/report/variants/main.html?id=<%=v.getId()%>" title="see more information in the variant page"><%=v.getId()%></a></td>
                    <td><%=v.getChromosome()%></td>
                    <td><%=NumberFormat.getNumberInstance(Locale.US).format(v.getStartPos())%>&nbsp;-&nbsp;<%=NumberFormat.getNumberInstance(Locale.US).format(v.getEndPos())%></td>
                    <td><%=Utils.NVL(v.getReferenceNucleotide(), "-")%></td>
                    <td><%=Utils.NVL(v.getVariantNucleotide(),"-")%></td>
                    <td><a style='color:blue;font-weight:700;font-size:11px;' href='<%=SpeciesType.getNCBIAssemblyDescriptionForSpecies(map.getSpeciesTypeKey())%>'><%=map.getName()%></a></td>
                </tr>
                <% } %>
            </table></td>
    </tr>
</table>