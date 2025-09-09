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

<div id="pubMedReferencesTableDiv" class="light-table-border">
    <div class="sectionHeading" id="pubMedReferences">Additional References at PubMed</div>

    <div class="modelsViewContent" >
        <div class="pager pubMedReferencesPager" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize" >
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option selected="selected"  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>




    <table border="0"  id="pubMedReferencesTable" class="tablesorter">
        <thead></thead>
        <tbody>

    <%
        String pubmedLink=xdbDAO.getXdbUrlnoSpecies(XdbId.XDB_KEY_PUBMED);

        for (int i = 0; i < ei.size(); i++) {
            String link=ei.get(i).getLinkText()==null ? ei.get(i).getAccId() : ei.get(i).getLinkText();
            if(i % 12 == 0){
    %>
<%--Beggining of row--%>
        <tr>
            <td class="report-page-grey">
                <span>PMID:<a href="<%=pubmedLink%><%=ei.get(i).getAccId()%>"><%=link%></a></span> &nbsp;
            </td>

    <% }else if(i % 12 == 11){ %>
<%--            End of Row--%>
            <td class="report-page-grey">
                <span>PMID:<a href="<%=pubmedLink%><%=ei.get(i).getAccId()%>"><%=link%></a></span> &nbsp;
            </td>
        </tr>
  <% }else{%>
<%--middle item--%>
            <td class="report-page-grey">
                <span>PMID:<a href="<%=pubmedLink%><%=ei.get(i).getAccId()%>"><%=link%></a></span> &nbsp;
            </td>
    <% }
    }%>
        </tbody>
    </table>


    <div class="modelsViewContent" >
        <div class="pager pubMedReferencesPager" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize" >
                    <option  value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option selected="selected"  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>

<br>
</div>

<% } %>
<%@ include file="sectionFooter.jsp"%>