<%@ page import="edu.mcw.rgd.datamodel.SSLP" %>
<%@ page import="edu.mcw.rgd.dao.spring.StringListQuery" %>
<%
    String pageTitle = "Edit SSLP";
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="/common/headerarea.jsp"%>
<%@ include file="editHeader.jsp" %>
<%
    AssociationDAO associationDAO = new AssociationDAO();
    StrainDAO strainDAO = associationDAO.getStrainDAO();
    QTLDAO qtlDAO = associationDAO.getQtlDAO();
    SSLPDAO sslpDAO = new SSLPDAO();

    SSLP sslp = (SSLP) request.getAttribute("editObject");
    int rgdId = sslp.getRgdId();
    int displayRgdId = rgdId;
    int key = sslp.getKey();

    String name = sslp.getName();
    if (isClone) {
        SSLP clone = (SSLP) request.getAttribute("cloneObject");
        sslp = clone;
        displayRgdId = sslp.getRgdId();
        name = sslp.getName() + " (COPY)";
    }
    List<String> sslpTypes = sslpDAO.getSslpTypes();
    sslpTypes.add(0, "");

    // temporary code
    String sql1 = "SELECT seq_template FROM sslps WHERE rgd_id=?";
    String sql2 = "SELECT seq_forward FROM sslps WHERE rgd_id=?";
    String sql3 = "SELECT seq_reverse FROM sslps WHERE rgd_id=?";

    // SSLP may have a forward primer, reverse primer and nucleotide sequence
    String cloneSeq = sslpDAO.getStringResult(sql1, rgdId);
    String forward = sslpDAO.getStringResult(sql2, rgdId);
    String reverse = sslpDAO.getStringResult(sql3, rgdId);

    String cloneSeqFormatted = "";
    if( cloneSeq != null ) {
        double value = (double) cloneSeq.length() / (double) 60;
        int loops = (int) Math.ceil(value);

        for (int i = 0; i < loops; i++) {

            int index = i * 60;
            if ((i + 1) == loops) {
                cloneSeqFormatted += cloneSeq.substring(index) + "\r";
            } else {
                cloneSeqFormatted += cloneSeq.substring(index, index + 60) + "\r";
            }
        }
    }
%>

<% if( key==0 || rgdId==0 ) { %>
<h1>Create SSLP</h1>
<% } else { %>
<h1>Edit SSLP: <%=name%></h1>
<% } %>

<table>
    <tr>
        <td  valign="top">


<form action="editSSLP.html" method="get">
    <input type="hidden" name="rgdId" value="<%=rgdId%>" />
    <input type="hidden" name="key" value="<%=key%>" />
    <input type="hidden" name="act" value="<%=key==0?"add":"upd"%>" />
    <input type="hidden" name="speciesType" value="<%=request.getParameter("speciesType")%>" />
    <input type="hidden" name="objectStatus" value="<%=request.getParameter("objectStatus")%>" />

<table>
    <tr>
        <td valign="top">
            <table >
                <tr>
                    <td class="label">Key:</td>
                    <td><%=key%></td>
                </tr>
                <tr>
                    <td class="label">Name:</td>
                    <td><input type="text" name="name" size="45" value="<%=dm.out("name",name)%>" /></td>
                </tr>
                <tr>
                    <td class="label">Expected Size:</td>
                    <td><input type="text" name="expectedSize" size="15" value="<%=dm.out("expectedSize",sslp.getExpectedSize())%>" /> </td>
                </tr>
                <tr>
                    <td class="label">SSLP Type:</td>
                    <td><%=fu.buildSelectList("sslp_type", sslpTypes, dm.out("sslp_type",sslp.getSslpType()))%></td>
                </tr>
                <tr>
                    <td class="label">Notes:</td>
                    <td><textarea rows="6" name="notes" cols="45" ><%=dm.out("notes",sslp.getNotes())%></textarea></td>
                </tr>
                <%  SSLP obj = sslp;
                    String objectType="marker";
                %>
                <%@ include file="../../report/markerFor.jsp" %>
<% if( rgdId!=0 ) { %>
                <tr>
                    <td class="label">Forward Primer:</td>
                    <td><input type="text" name="forwardPrimer" size="45" value="<%=dm.out("forwardPrimer",forward)%>" /></td>
                </tr>
                <tr>
                    <td class="label">Reverse Primer:</td>
                    <td><input type="text" name="reversePrimer" size="45" value="<%=dm.out("reversePrimer",reverse)%>" /></td>
                </tr>
                <tr>
                    <td class="label">Template Sequence:</td>
                    <td><textarea rows="6" name="templateSeq" cols="65" ><%=dm.out("templateSeq",cloneSeqFormatted)%></textarea></td>
                </tr>
<% } %>
                <tr>
                    <td colspan="2" align="center">
                    <% if( key==0 || rgdId==0 ) { %>
                        <input type="submit" value="Create SSLP" />
                    <% } else { %>
                        <input type="button" value="Update" onclick="makePOSTRequest(this.form)" size="10"/>
                    <% } %>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
</form>

            <%  String notesObjectType = "sslps"; %>
            <%@ include file="mapData.jsp" %>
            <%@ include file="aliasData.jsp" %>
            <%@ include file="curatedReferencesData.jsp" %>
            <%@ include file="notesData.jsp" %>
            <%@ include file="externalLinksData.jsp" %>
            <%@ include file="sslp2geneAssociationData.jsp" %>
            <%@ include file="sslpAlleleData.jsp" %>
        </td>
        <td valign="top">
           <%@ include file="idInfo.jsp" %>
        </td>
    </tr>
</table>

<%@ include file="/common/footerarea.jsp" %>
