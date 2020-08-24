<%@ page import="org.springframework.dao.EmptyResultDataAccessException" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.Comparator" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.datamodel.XdbId" %>
<%@ page import="java.util.List" %>
<%@ include file="sectionHeader.jsp"%>
<%
    XdbId xi = new XdbId();
    xi.setRgdId(obj.getRgdId());
    List<XdbId> ei = xdbDAO.getUncuratedPubmedIds(xi.getRgdId());

    Collections.sort(ei, new Comparator<XdbId>() {
        public int compare(XdbId o1, XdbId o2) { // sort pubmed ids as numbers
            int r = o1.getAccId().length() - o2.getAccId().length();
            if( r!=0 )
                return r;
            return o1.getAccId().compareTo(o2.getAccId());
        }
    });

    if (ei.size() > 0) {
%>

<%//ui.dynOpen("otherPubmed", "References - uncurated")%>

<div class="sectionHeading" id="pubMedReferences">PubMed References</div>
<div id="pubMedReferencesTableDiv">

    <div id="modelsViewContent" >
        <div id="pubMedReferencesPager" class="pager" style="float:right;margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tableSorter/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <table border="0"  class="tablesorter" id="pubMedReferencesTable">
        <thead></thead>
        <tbody>
    <tr>
        <td style="background-color:#e2e2e2; vertical-align:top"><b>PubMed</b></td>
        <td style="background-color:#e2e2e2;">
    <%
        String pubmedLink=xdbDAO.getXdbUrl(XdbId.XDB_KEY_PUBMED, obj.getSpeciesTypeKey());
        for (XdbId xid: ei) {
            String link=xid.getLinkText()==null ? xid.getAccId() : xid.getLinkText();

    %>
        <a href="<%=pubmedLink%><%=xid.getAccId()%>"><%=link%></a> &nbsp;
    <% } %>
        </td>
    </tr>
        </tbody>
    </table>

<br>
<%//ui.dynClose("otherPubmed")%>

<% } %>
</div>
<%@ include file="sectionFooter.jsp"%>