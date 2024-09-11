<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.RgdVariantDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdVariant" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="java.util.ArrayList" %>

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
            <td align="center"><%if(variant.getRefNuc() == null)
                    out.print("-");
                  else
                    out.print(variant.getRefNuc());%></td>
            <td align="center"><%if(variant.getVarNuc() == null)
                out.print("-");
            else
                out.print(variant.getVarNuc());%></td>
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