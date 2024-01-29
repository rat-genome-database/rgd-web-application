<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%
    String pageTitle = "Edit Gene";
    String headContent = "";
    String pageDescription = "";
    
%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="editHeader.jsp" %>
<%
    GeneDAO geneDAO = new GeneDAO();
    Gene gene = (Gene) request.getAttribute("editObject");
    int rgdId = gene.getRgdId();
    int displayRgdId = rgdId;
    int key = gene.getKey();
    String submittedParentGene= (String) request.getAttribute("submittedParentGene");
    String references= (String) request.getAttribute("references");

    String symbol = gene.getSymbol();
    if (isClone) {
        Gene clone = (Gene) request.getAttribute("cloneObject");
        gene = clone;
        displayRgdId = gene.getRgdId();
        symbol = gene.getSymbol() + " (COPY)";
    }
    AssociationDAO associationDAO = new AssociationDAO();
%>

<% if( key==0 || rgdId==0  ){ %>
<h1>Create Gene</h1>
<% } else { %>
<h1>Edit Gene: <%=dm.out("symbol", symbol)%></h1>
<% } %>
<% if (request.getAttribute("additionalInfo")!=null && !(request.getAttribute("additionalInfo").equals(""))){
    if(!request.getAttribute("additionalInfo").equals("null")){%>
<p style="color:red"><span style="text-decoration:underline">Additional information provided by USER:</span><span style="color:blue"><%=request.getAttribute("additionalInfo")%></span> </p>
<%}}%>
<% if(request.getParameter("submittedParentGeneInfo")!=null && !request.getParameter("submittedParentGeneInfo").equals("")){
    if(!request.getParameter("submittedParentGeneInfo").equals("null")){%>
        <p style="color:blue">Submitter provided parent gene <span style="color:red"> <%=request.getParameter("submittedParentGeneInfo")%> </span>Make association if you dont see this information in Parent Gene Associaiton</p>

 <%   }
}%>
<table>
    <tr>
        <td valign="top">

        <form action="editGene.html" method="get">
        <input type="hidden" name="rgdId" value="<%=rgdId%>"/>
        <input type="hidden" name="key" value="<%=key%>" />
        <input type="hidden" name="act" value="<%=key==0?"add":"upd"%>" />
        <input type="hidden" name="speciesType" value="<%=request.getParameter("speciesType")%>" />
        <input type="hidden" name="objectStatus" value="<%=request.getParameter("objectStatus")%>" />
        <input type="hidden" name="submittedParentGene" value="<%=submittedParentGene%>"/>
        <input type="hidden" name="references" value="<%=references%>"/>
        <table>
            <tr>
                <td class="label">Key:</td>
                <td id="geneKey"><%=gene.getKey()%></td>
            </tr>
            <tr>
                <td class="label">Symbol:</td>
                <td><input type="text" name="symbol" size="61" value="<%=dm.out("symbol",gene.getSymbol())%>" /></td>
            </tr>
            <tr>
                <td class="label">Name:</td>
                <td><input type="text" name="name" size="61" value="<%=dm.out("name",gene.getName())%>" /> </td>
            </tr>
            <tr>
                <td class="label">Description:</td>
                <td><textarea rows="6" name="description" cols="60" ><%=dm.out("description", gene.getDescription())%></textarea></td>
            </tr>
            <tr>
                <td class="label">Notes:</td>
                <td><textarea rows="3" name="notes" cols="60" ><%=dm.out("notes",gene.getNotes())%></textarea></td>
            </tr>
            <tr>
                <td class="label">Type:</td>
                <td><%=fu.buildSelectList("type",geneDAO.getTypes(), dm.out("type",gene.getType()))%></td>
            </tr>
            <tr>
                <td class="label">Nomenclature:</td>
                <td><b>Review Date:</b> <%=gene.getNomenReviewDate()%> &nbsp; &nbsp; <b>Source:</b><%=gene.getNomenSource()%></td>
            </tr>
            <tr>
                <td class="label">Refseq Status:</td>
                <td><input type="text" name="refseq_status" size="30" value="<%=dm.out("refseq_status",gene.getRefSeqStatus())%>" /></td>
            </tr>
            <tr>
                <td colspan="2" align="center">
                    <% if( key==0 || rgdId==0 ) { %>
                    <input type="submit" value="Create Gene" />
                    <% } else { %>
                    <input type="button" value="Update Gene" onclick="makePOSTRequest(this.form)"/>
                    <% } %>
                </td>
            </tr>
        </table>
        </form>

    </td>
    <td>&nbsp;&nbsp;</td>
    <td valign="top">
        <%@ include file="idInfo.jsp" %>
    </td>
</tr>
</table>
<%@ include file="mapData.jsp" %>
<%@ include file="geneVariantData.jsp" %>
<%@ include file="curatedReferencesData.jsp" %>
<%@ include file="geneAssociationData.jsp" %>
<%@ include file="geneVariantAssociationData.jsp"%>
<%@ include file="aliasData.jsp" %>
<%@ include file="externalLinksData.jsp" %>

<%
    String notesObjectType = "genes";
%>
<%@ include file="notesData.jsp" %>

<%@ include file="/common/footerarea.jsp"%>

