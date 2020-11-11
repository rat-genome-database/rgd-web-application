<%@ page import="java.util.List" %>

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
<%=ui.dynOpen("rgdVariants", "Rat Variants")%>

<table id="variants">
    <tr>
        <td><b>Name</b></td>
        <td><b>Chromosome</b></td>
        <td><b>Start Pos</b></td>
        <td><b>End Pos</b></td>
        <td><b>Reference Nucleotide</b></td>
        <td><b>Variant Nucleotide</b></td>
        <td><b>Variant Type</b></td>

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
            <td><a href="/rgdweb/report/rgdvariant/main.html?id=<%=var.getRgdId()%>"><%=variant.getName()%></a></td>
            <td><%="chr"+var.getChromosome()%></td>
            <td><%=var.getStartPos()%></td>
            <td><%=var.getStopPos()%></td>
            <td><%if(variant.getRefNuc() == null)
                    out.print("-");
                  else
                    out.print(variant.getRefNuc());%></td>
            <td><%if(variant.getVarNuc() == null)
                out.print("-");
            else
                out.print(variant.getVarNuc());%></td>
            <td><%
                Term so = odao.getTermByAccId(variant.getType());
                out.print(so.getTerm());
            %></td>
            <% } // end varData for

        } //end variant for %>
</table>
<%=ui.dynClose("rgdVariants")%>
<% } // end if variants is not empty%>
<%@ include file="sectionFooter.jsp"%>