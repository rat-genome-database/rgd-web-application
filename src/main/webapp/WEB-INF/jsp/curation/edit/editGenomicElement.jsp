<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>

<%
    String pageTitle = "Edit Genomic Element";
    String headContent = "";
    String pageDescription = "";

    GenomicElement el = (GenomicElement) request.getAttribute("editObject");

    int rgdId = el.getRgdId();
    int displayRgdId = rgdId;
    String symbol = el.getSymbol();
%>
<%@ include file="/common/headerarea.jsp"%>
<%@ include file="editHeader.jsp" %>
<%
    if (isClone) {
        el = (GenomicElement) request.getAttribute("cloneObject");
        displayRgdId = el.getRgdId();
        symbol = el.getSymbol() + " (COPY)";
    }
%>


<h1>Edit Genomic Element: <a href="<%=Link.ge(rgdId)%>"><%=dm.out("symbol", symbol)%></a></h1>

<table>
    <tr>
        <td>

<form action="editGenomicElement.html" method="get">
<input type="hidden" name="rgdId" value="<%=rgdId%>" />
    <% if (isNew) {%>
        <input type="hidden" name="act" value="add"/>
    <% } else { %>
        <input type="hidden" name="act" value="upd"/>
    <% } %>
<input type="hidden" name="speciesType" value="<%=request.getParameter("speciesType")%>"/>
<input type="hidden" name="objectType" value="<%=request.getParameter("objectType")%>"/>
<input type="hidden" name="objectStatus" value="<%=request.getParameter("objectStatus")%>"/>

            <table>
                <tr>
                    <td class="label">Symbol:</td>
                    <td><input type="text" name="symbol" size="45" value="<%=dm.out("symbol",symbol)%>" />&nbsp;<a href="javascript:lookup_render('', 16,'PROMOTERS')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a></td>
                </tr>
                <tr>
                    <td class="label">Name:</td>
                    <td><input type="text" name="name" size="45" value="<%=dm.out("name",el.getName())%>" /> </td>
                </tr>
                <tr>
                    <td class="label">Description:</td>
                    <td><input type="text" name="description" size="45" value="<%=dm.out("description",el.getDescription())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Source:</td>
                    <td><input type="text" name="source" size="45" value="<%=dm.out("source",el.getSource())%>" /></td>
                </tr>
                <tr>
                    <td class="label">SO Acc Id:</td>
                    <td><input type="text" name="soAccId" size="45" value="<%=dm.out("soAccId",el.getSoAccId())%>" /></td>
                </tr>


                <tr>
                    <td colspan="2" align="center">
                        <% if (isNew) { %>
                            <input type="submit" value="Create Genomic Element"/>
                        <%} else { %>
                            <input type="button" value="Update Genomic Element" onclick="makePOSTRequest(this.form)"/>
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

<%@ include file="aliasData.jsp" %>
<%@ include file="genomicElementAttrData.jsp" %>
<%@ include file="sequenceData.jsp" %>

<%@ include file="/common/footerarea.jsp" %>
