
<%

    List<XdbId>  xIds = xdbDAO.getXdbIdsByRgdId(20,obj.getRgdId());

    if (xIds.size() > 0 && obj.getSpeciesTypeKey()==3) {
        String ensemblId=xIds.get(0).getAccId();
%>


<%@ include file="sectionHeader.jsp"%>



<%=ui.dynOpen("transcriptomeAssociation", "Transcriptome")%>




<br>
<table>
    <tr>
        <td style="background-color:#e2e2e2;font-weight:700;">eQTL</td>
        <td>&nbsp;</td>
        <td><a href="https://phenogen.ucdenver.edu/PhenoGen/gene.jsp?speciesCB=Rn&auto=Y&geneTxt=<%=ensemblId%>&genomeVer=rn6&section=geneEQTL">View at Phenogen</a></td>
    </tr>
    <tr>
        <td style="background-color:#e2e2e2;font-weight:700;">WGCNA</td>
        <td>&nbsp;</td>
        <td><a href="https://phenogen.ucdenver.edu/PhenoGen/gene.jsp?speciesCB=Rn&auto=Y&geneTxt=<%=ensemblId%>&genomeVer=rn6&section=geneWGCNA">View at Phenogen</a></td>
    </tr>
    <tr>
        <td style="background-color:#e2e2e2;font-weight:700;">Tissue/Strain Expression</td>
        <td>&nbsp;</td>
        <td><a href="https://phenogen.ucdenver.edu/PhenoGen/web/GeneCentric/geneApplet.jsp?selectedID=<%=ensemblId%>&genomeVer=rn6">View at Phenogen</a></td>
    </tr>
</table>
<br>



<!--
Gene eQTL for Agt(ENSRNOG00000018445)
https://phenogen.ucdenver.edu/PhenoGen/gene.jsp?speciesCB=Rn&auto=Y&geneTxt=ENSRNOG00000018445&genomeVer=rn5&section=geneEQTL

Gene WGCNA for Agt(ENSRNOG00000018445)
https://phenogen.ucdenver.edu/PhenoGen/gene.jsp?speciesCB=Rn&auto=Y&geneTxt=ENSRNOG00000018445&genomeVer=rn5&section=geneWGCNA

Gene Tissue/Strain Expression for Agt(ENSRNOG00000018445)
https://phenogen.ucdenver.edu/PhenoGen/web/GeneCentric/geneApplet.jsp?selectedID=ENSRNOG00000018445&genomeVer=rn5
-->

<%=ui.dynClose("transcriptomeAssociation")%>


<%@ include file="sectionFooter.jsp"%>
<%
    }
%>