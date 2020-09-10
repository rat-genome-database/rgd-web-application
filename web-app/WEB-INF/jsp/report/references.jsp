<%@ include file="sectionHeader.jsp"%>

<%
    List<Reference> refs = associationDAO.getReferenceAssociations(obj.getRgdId());
    if (refs.size() > 0 ) {
        // sort references by citation
        Collections.sort(refs, new Comparator<Reference>() {
            public int compare(Reference o1, Reference o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getCitation(), o2.getCitation());
            }
        });
%>


<%//ui.dynOpen("refAssociation", "References - curated")%>    <br>
<div class="sectionHeading" id="referencesCurated">References - curated</div>
<div id="referencesCuratedTableDiv" class="light-table-border">

    <div class="modelsViewContent" >
        <div class="referencesCuratedPager" class="pager" style="margin-bottom:2px;">
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
    <table class="tablesorter" id="referencesCuratedTable">
        <thead></thead>
        <tbody>
    <%
    int count=1;
    for(Reference ref: refs ) {
    %>
        <tr>
            <td><%=count++%>.</td>
            <td><a href="<%=Link.ref(ref.getRgdId())%>"><%=ref.getCitation()%></a><br></td>
        </tr>
    <%
        }
    %>
        </tbody>
    </table>

    <div class="modelsViewContent" >
        <div class="referencesCuratedPager" class="pager" style="margin-bottom:2px;">
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
    <%//ui.dynClose("refAssociation")%>
</div>
<% } %>
<%@ include file="sectionFooter.jsp"%>
