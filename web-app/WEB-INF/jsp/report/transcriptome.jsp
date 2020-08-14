<%
    List<XdbId>  xIds = xdbDAO.getXdbIdsByRgdId(20,obj.getRgdId());

    if (xIds.size() > 0 && obj.getSpeciesTypeKey()==3) {
        String ensemblId=xIds.get(0).getAccId();
%>

<%@ include file="sectionHeader.jsp"%>


<div class="sectionHeading" id="transcriptome">Transcriptome</div>
<br>
<table><%-- sample gene: Agt(ENSRNOG00000018445) --%>
    <tr>
        <td style="background-color:#e2e2e2;font-weight:700;">eQTL</td>
        <td>&nbsp;</td>
        <td><a href="https://phenogen.org/gene.jsp?speciesCB=Rn&auto=Y&geneTxt=<%=ensemblId%>&genomeVer=rn6&section=geneEQTL">View at Phenogen</a></td>
    </tr>
    <tr>
        <td style="background-color:#e2e2e2;font-weight:700;">WGCNA</td>
        <td>&nbsp;</td>
        <td><a href="https://phenogen.org/gene.jsp?speciesCB=Rn&auto=Y&geneTxt=<%=ensemblId%>&genomeVer=rn6&section=geneWGCNA">View at Phenogen</a></td>
    </tr>
    <tr>
        <td style="background-color:#e2e2e2;font-weight:700;">Tissue/Strain Expression</td>
        <td>&nbsp;</td>
        <td><a href="https://phenogen.org/gene.jsp?speciesCB=Rn&auto=Y&geneTxt=<%=ensemblId%>&genomeVer=rn6&section=geneApp">View at Phenogen</a></td>
    </tr>
</table>
<br>



<%@ include file="sectionFooter.jsp"%>
<%
    }
%>