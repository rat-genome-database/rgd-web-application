<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.*" %>
<%@ include file="../sectionHeader.jsp"%>
<style>
    .wrap660 {
        display: block;
        width: 660px;
        word-break: break-all;
    }
</style>
<%
    String objType = "{unknown object type}";
    String description = null;
    if( obj!=null ) {
        objType = obj.getObjectTypeName();
    }
    String src = "";


    MapDAO mdao = new MapDAO();
    Map map = mdao.getMap(var.getMapKey());
    if (var.getMapKey()!=631) {
        for (Sample s : samples) {
            src += (s.getAnalysisName() + " ");
        }
    }
    else {
        for (Sample s : samples){
            if (s.getAnalysisName().equals("EVA"))
                src = s.getAnalysisName();
        }
    }

    int start = (int) var.getStartPos();
    List<MapData> mapData = mdao.getMapDataWithinRange(start,start,var.getChromosome(),var.getMapKey(),1);
    List<Gene> geneList = new ArrayList<>();
    String genes = "";
    if (mapData.size()>0) {
        GeneDAO gdao = new GeneDAO();
        for (MapData m : mapData) {
            Gene g = gdao.getGene(m.getRgdId());
            if (g != null)
                geneList.add(g);
        }
    }

    String genicStatus = "INTERGENIC";
    if (geneList.size()>0)
        genicStatus = "GENIC";
%>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr><td colspan="2"><h3>Variant: <%=displayName%>&nbsp;-&nbsp; <%=SpeciesType.getTaxonomicName(var.getSpeciesTypeKey())%>
    </h3></td></tr>

<%--    <tr>--%>
<%--        <td class="label" valign="top">Name:</td>--%>
<%--        <td><%=Utils.NVL(var.getName(), "")%></td>--%>
<%--    </tr>--%>
    <tr>
        <td class="label"><%=RgdContext.getSiteName(request)%> ID:</td>
        <td><%=obj.getRgdId()%></td>
    </tr>
    <%if (!Utils.isStringEmpty(var.getRsId())) {%>
    <tr>
        <td class="label">RS ID:</td>
        <td><%=var.getRsId()%></td>
    </tr>
    <% } %>
    <%if (!Utils.isStringEmpty(var.getClinvarId())) {%>
    <tr>
        <td class="label">ClinVar ID:</td>
        <td><%=var.getClinvarId()%></td>
    </tr>
    <% } %>
    <tr>
        <td class="label" valign="top">Genic Status:</td>
        <td><%=Utils.NVL(genicStatus, "")%></td>
    </tr>

    <tr>
        <td class="label">Type:</td>
        <td>
            <%=t.getTerm()%>&nbsp;<a href="<%=Link.ontView(t.getAccId())%>" title="click to go to ontology page"><%= "("+ t.getAccId() + ")"%></a>&nbsp;
        </td>
    </tr>

    <%  //if (genicStatus.equals("GENIC")) {

        if (geneList.size() > 0) {

            // sort strains by symbol
            Collections.sort(geneList, new Comparator<Gene>() {
                public int compare(Gene o1, Gene o2) {
                    return Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
                }
            });
         for(Gene g: geneList){
             String url = Link.gene(g.getRgdId());
             genes = genes.concat("<a href="+url+">");
             genes=genes.concat(g.getSymbol());
             genes = genes.concat("</a>&nbsp;&nbsp;");
         }
    %>
    <tr>
        <td class="label" valign="top">Associated Genes:</td>
        <td><%=genes%></td>
    </tr>
    <% }// genelist>0
%>
    <tr>
        <td class="label" valign="top">Reference Nucleotide:</td>
        <td class="wrap660"><%=Utils.NVL(var.getReferenceNucleotide(), "-")%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Variant Nucleotide:</td>
        <td class="wrap660"><%=Utils.NVL(var.getVariantNucleotide(), "-")%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Padding Base:</td>
        <td class="wrap660"><%=Utils.NVL(var.getPaddingBase(), "-")%></td>
    </tr>
    <tr>
        <td class="label">Position</td>
        <td>
            <table border="0" class="mapDataTable" width="670">
                <tr>
                    <th align="left"><b>Rat Assembly</b></th>
                    <th align="left">Chr</th>
                    <th align="left">Position</th>
                </tr>
                <tr>
                    <td><%=map.getName()%></td>
                    <td><%=var.getChromosome()%></td>
                    <td><%=NumberFormat.getNumberInstance(Locale.US).format(var.getStartPos())%>&nbsp;-&nbsp;<%=NumberFormat.getNumberInstance(Locale.US).format(var.getEndPos())%></td>

                </tr>
            </table></td>
    </tr>
    <tr>
        <td class="label">Source:</td>
        <td><%=src%></td>
    </tr>
    <% if (var.getMapKey()==631) {%>
    <tr>
        <td class="label">Breeds:</td>
        <td>
            <%for (int i = 0 ; i < breeds.size();i++) {
                if (i == breeds.size()-1)
                    out.print(breeds.get(i));
                else
                    out.print(breeds.get(i) +", ");
            } %>
        </td>
    </tr>
    <% }
        List<Alias> aliases = aliasDAO.getAliases(obj.getRgdId());
        if (aliases.size() > 0 ) {
            // sort aliases alphabetically by alias value
            Collections.sort(aliases, new Comparator<Alias>() {
                public int compare(Alias o1, Alias o2) {
                    return Utils.stringsCompareToIgnoreCase(o1.getValue(), o2.getValue());
                }
            });
    %>
    <tr>
        <td class="label" valign="top">Aliases:</td>
        <td><%=Utils.concatenate("; ", aliases, "getValue")%></td>
    </tr>
    <% } %>

</table>
<br>

<%@ include file="../sectionFooter.jsp"%>
