<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.datamodel.Reference" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdId" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.ReferenceDAO" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>

<%
    String pageTitle = "Edit Reference";
    String headContent = "";
    String pageDescription = "";
%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="editHeader.jsp" %>

<%
    ReferenceDAO referenceDAO = new ReferenceDAO();
    Reference ref = (Reference) request.getAttribute("editObject");
    int rgdId = ref.getRgdId();

    int displayRgdId = rgdId;
    int key = ref.getKey();

    String title = ref.getTitle();
    if (isClone) {
        Reference clone = (Reference) request.getAttribute("cloneObject");
        ref = clone;
        displayRgdId = ref.getRgdId();
        title = ref.getTitle() + " (COPY)";
    }

    String pmid = "";
    XdbIdDAO xdao = new XdbIdDAO();
    for( XdbId xdbId: xdao.getPubmedIdsByRefRgdId(rgdId) ) {
        pmid = xdbId.getAccId();
    }
    String action;
%>

<% if( isClone ) {
    action = "add"; %>
<h1>Clone Reference: <%=title%></h1>
<% } else if( isNew ) {
    action = "add"; %>
<h1>New Reference</h1>
<% } else {
    action = "upd"; %>
<h1>Edit Reference: <%=title%></h1>
<% } %>

<form action="editReference.html" method="get">
<input type="hidden" name="rgdId" value="<%=rgdId%>" />
<input type="hidden" name="key" value="<%=key%>" />
<input type="hidden" name="act" value="<%=action%>" />

<table>
    <tr>
        <td valign="top">
            <table >
                <tr>
                    <td class="label">Key:</td>
                    <td><%=ref.getKey()%></td>
                </tr>
                <tr>
                    <td class="label">Title:</td>
                    <td><input type="text" name="title" size="45" value="<%=dm.out("title",ref.getTitle())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Editors:</td>
                    <td><input type="text" name="editors" size="45" value="<%=dm.out("editors",ref.getEditors())%>" /> </td>
                </tr>
                <tr>
                    <td class="label">Publication:</td>
                    <td><input type="text" name="publication" size="45" value="<%=dm.out("publication",ref.getPublication())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Volume:</td>
                    <td><input type="text" name="volume" size="15" value="<%=dm.out("volume",ref.getVolume())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Issue:</td>
                    <td><input type="text" name="issue" size="15" value="<%=dm.out("issue",ref.getIssue())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Pages:</td>
                    <td><input type="text" name="pages" size="15" value="<%=dm.out("pages",ref.getPages())%>" /></td>
                </tr><%--
                <tr>
                    <td class="label">Pub Status:</td>
                    <td><input type="text" name="pubStatus" size="15" value="<%=dm.out("pubStatus",ref.getPubStatus())%>" /></td>
                </tr>--%>
                <tr>
                    <td class="label">Pub Date:</td>
                    <td><%=ref.getPubDate()%></td>
                </tr>
                <tr>
                    <td class="label">Abstract:</td>
                    <td><textarea name="abstract" cols="45" rows="6"><%=dm.out("abstract",ref.getRefAbstract())%></textarea></td>
                </tr>
                <tr>
                    <td class="label">Reference Type:</td>
                    <td><%=fu.buildSelectList("referenceType",referenceDAO.getReferenceTypes(), dm.out("referenceType",ref.getReferenceType()))%></td>
                </tr>
                <tr>
                    <td class="label">Citation:</td>
                    <td><textarea name="citation" cols="45" rows="6"><%=dm.out("citation",ref.getCitation())%></textarea></td>
                </tr>
                <tr>
                    <td class="label">Publisher:</td>
                    <td><input type="text" name="publisher" size="45" value="<%=dm.out("publisher",ref.getPublisher())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Publisher City:</td>
                    <td><input type="text" name="publisherCity" size="45" value="<%=dm.out("publisherCity",ref.getPublisherCity())%>" /></td>
                </tr>
                <tr>
                    <td class="label">Notes:</td>
                    <td><textarea name="notes" cols="45" rows="6"><%=dm.out("notes",ref.getNotes())%></textarea></td>
                </tr>
                <tr>
                    <td class="label">PubMed ID:</td>
                    <td><input type="text" name="pmid" size="45" value="<%=dm.out("pmid",pmid)%>" /></td>
                </tr>
                <tr>
                    <td class="label">DOI:</td>
                    <td><input type="text" name="doi" size="45" value="<%=dm.out("doi",ref.getDoi())%>" /></td>
                </tr>
                <tr>
                    <td class="label">URL Web Reference:</td>
                    <td><input type="text" name="urlWebReference" size="50" value="<%=dm.out("urlWebReference",ref.getUrlWebReference())%>" /></td>
                </tr>

                <tr>
                <% if( isClone ) { %>
                    <td colspan="2" align="center"><input type="submit" value="Clone Reference"/></td>
                <% } else if( isNew ) { %>
                    <td colspan="2" align="center"><input type="submit" value="Insert Reference"/></td>
                <% } else { %>
                    <td colspan="2" align="center"><input type="button" value="Update Reference" onclick="makePOSTRequest(this.form)"/></td>
                <% } %>
                </tr>

                <% if( !Utils.isStringEmpty(pmid) ) { %>
                <tr>
                    <td colspan="2" align="center"><hr><input type="button" value="Reload Reference From PubMed" onclick="location.href='/rgdweb/pubmed/importReferences.html?mode=update&pmid_list=<%=pmid%>'" ></td>
                </tr>
                <% } %>
            </table>

            <p><h3>AUTHORS:</h3>
            <table cellspacing="1" cellpadding="5" border>
            <tr><th>Order.</th><th>Last Name</th><th>First Name</th><th>Initials</th><th>Suffix</th></tr>
            <% int authorOrder=0;
                for( Author author: referenceDAO.getAuthors(ref.getKey()) ) {
                    authorOrder++; %>
                <tr>
                    <td><%=authorOrder%>.</td>
                    <td><%=Utils.defaultString(author.getLastName())%></td>
                    <td><%=Utils.defaultString(author.getFirstName())%></td>
                    <td><%=Utils.defaultString(author.getInitials())%></td>
                    <td><%=Utils.defaultString(author.getSuffix())%></td>
                </tr>
            <% } %>
            </table>
        </td>
        <td>&nbsp;</td>
        <td valign="top" align="center">
            <%@ include file="idInfo.jsp"%>
        </td>
    </tr>
</table>
</form>

<%@ include file="/common/footerarea.jsp"%>
