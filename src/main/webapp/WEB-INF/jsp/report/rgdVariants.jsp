<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.RgdVariantDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdVariant" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="java.util.ArrayList" %>
<%!
    // Long ref/var nucleotide sequences (deletions/insertions can be kb-scale)
    // are shown collapsed with a FASTA-wrapped expander.
    String formatNuc(String s) {
        if (s == null || s.isEmpty()) return "-";
        if (s.length() <= 60) return s;
        StringBuilder fasta = new StringBuilder(s.length() + s.length()/60 + 4);
        for (int i = 0; i < s.length(); i += 60) {
            fasta.append(s, i, Math.min(i + 60, s.length())).append('\n');
        }
        return "<details style=\"display:inline-block; vertical-align:top; max-width:520px;\">"
            + "<summary style=\"cursor:pointer; color:#24609c; font-family:monospace; font-size:11px;\">"
            + s.substring(0, 30) + "&hellip; <span style=\"color:#666; font-family:Arial; font-size:11px;\">("
            + s.length() + " bp)</span></summary>"
            + "<pre style=\"font-family:monospace; font-size:11px; margin:4px 0 0 0; white-space:pre; "
            + "max-height:240px; max-width:520px; overflow:auto; padding:4px; background:#f7f7f7; "
            + "border:1px solid #ddd;\">" + fasta + "</pre></details>";
    }
%>

<%@ include file="sectionHeader.jsp"%>
<%
    RgdVariantDAO variantDAO = new RgdVariantDAO();
    OntologyXDAO odao = new OntologyXDAO();
    List<RgdVariant> variants = new ArrayList<>();
    if(title.equals("Genes"))
        variants = variantDAO.getVariantsFromGeneRgdId(obj.getRgdId());
    else if (title.equals("Strains"))
        variants = variantDAO.getVariantsFromStrainKey(obj.getKey());

    if(variants.size()>0){
%>
<%--<%=ui.dynOpen("rgdVariants", "Rat Variants")%>--%>
<div class="light-table-border">
<div class="sectionHeading" id="rgdVariants">Allelic Variants</div>
<table id="variants" border="1" cellspacing="0" width="95%">
    <tr>
        <td align="center"><b>Name</b></td>
        <td align="center"><b>Chromosome</b></td>
        <td align="center"><b>Start Pos</b></td>
        <td align="center"><b>End Pos</b></td>
        <td align="Left"><b>Reference Nucleotide</b></td>
        <td align="Left"><b>Variant Nucleotide</b></td>
        <td align="center"><b>Variant Type</b></td>
        <td align="center"><b>Assembly</b></td>

    </tr>
    <%
        String rowClass="oddRow";
        for (RgdVariant variant : variants)
        {
            // alternate rows {even,odd}
            if( rowClass.equals("oddRow") )
                rowClass = "evenRow";
            else
                rowClass = "oddRow";

            for(MapData var : mapDAO.getMapData(variant.getRgdId())) {
            %>
            <tr>
            <td align="center"><a href="/rgdweb/report/rgdvariant/main.html?id=<%=var.getRgdId()%>"><%=variant.getName()%></a></td>
            <td align="center"><%="chr"+var.getChromosome()%></td>
            <td align="center"><%=var.getStartPos()%></td>
            <td align="center"><%=var.getStopPos()%></td>
            <td align="left" style="vertical-align:top; word-break:break-all;"><%= formatNuc(variant.getRefNuc()) %></td>
            <td align="left" style="vertical-align:top; word-break:break-all;"><%= formatNuc(variant.getVarNuc()) %></td>
            <td align="center"><%
                Term so = odao.getTermByAccId(variant.getType());
                out.print(so.getTerm());
            %></td>
                <td><%=mapDAO.getMap(var.getMapKey()).getName()%></td>
        </tr>
            <% } // end varData for

        } //end variant for %>
</table>
</div>
<%--<%=ui.dynClose("rgdVariants")%>--%>
<% } // end if variants is not empty%>
<%@ include file="sectionFooter.jsp"%>