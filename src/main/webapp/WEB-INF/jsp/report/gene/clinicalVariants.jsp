<%@ page import="edu.mcw.rgd.datamodel.VariantInfo" %>
<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.MapData" %>
<%@ page import="edu.mcw.rgd.datamodel.XDBIndex" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    MapDAO mapDAO = new MapDAO();
    List<VariantInfo> clinvars = (List<VariantInfo>) session.getAttribute("clinvars");
    if( !clinvars.isEmpty() ) {
        java.util.Map<Integer,List<MapData>> positionsForClinVars = getPositionsForClinVar(clinvars, mapDAO);
%>
<%//ui.dynOpen("clinicalVariants", "Clinical Variants")%><br>
<div class="light-table-border">
<div class="sectionHeading" id="clinicalVariants">Clinical Variants</div>

<div class = 'reportTable' id="clinicalVariantsTableDiv">



<div class="search-and-pager">
    <div class="modelsViewContent" >
        <div class="clinicalVariantsPager" class="pager" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="3">3</option>
                    <option value="5">5</option>
                    <option value="10">10</option>
                    <option value="20">20</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <input class="search table-search" id="clinicalVariantsSearch" type="search" data-column="all" placeholder="Search table">
</div>
    <script>
    $('#clinicalVariantsTable').on('click', '.headerRow', function(){
        $('#clinicalVariantsTable tr:nth-child(even)').removeClass('evenRow').addClass('oddRow');
        $('#clinicalVariantsTable tr:nth-child(odd)').removeClass('oddRow').addClass('evenRow');
    });


</script>
<table border="1" cellpadding="1" cellspacing="1" class="sortable" id="clinicalVariantsTable">
    <thead>
        <tr class="headerRow">
            <td title="click to sort by name">Name</td>
            <td title="click to sort by type">Type</td>
            <td title="click to sort by condition">Condition(s)</td>
            <td title="click to sort by position">Position(s)</td>
            <td title="click to sort by clinical significance">Clinical significance</td>
        </tr>
    </thead>
<%
    String rowClass="oddRow";
    for (VariantInfo var : clinvars) {

        // alternate rows {even,odd}
        if( rowClass.equals("oddRow") )
            rowClass = "evenRow";
        else
            rowClass = "oddRow";

        String position = "";
        for( MapData mdv: positionsForClinVars.get(var.getRgdId()) ) {
            String pos = "Chr"+mdv.getChromosome();
            if( mdv.getStartPos()>0 )
                pos += ":"+mdv.getStartPos();
            if( !mdv.getStopPos().equals(mdv.getStartPos()) )
                pos += ".."+mdv.getStopPos();
            if( mdv.getFishBand()!=null )
                pos += ":"+mdv.getFishBand();
            if( mdv.getMapKey()==17 )
                pos += "&nbsp;[GRCh37]";
            else if( mdv.getMapKey()==38 )
                pos += "&nbsp;[GRCh38]";
            else if( mdv.getMapKey()==13 )
                pos += "&nbsp;[NCBI36]";

            if( position.isEmpty() )
                position = pos;
            else
                position += "<br>"+pos;
        }
        if( position.isEmpty() )
            position="&nbsp;";
%>
    <tr class="<%=rowClass%>">
        <td><a href="<%=Link.variant(var.getRgdId())%>"><%=var.getName()%></a></td>
        <td><%=var.getObjectType()%></td>
        <td><%=expandClinVarLinks(var.getTraitName())%></td>
        <td><%=position%></td>
        <td><%=var.getClinicalSignificance()%></td>
    </tr>
    <% } %>
</table>
    <div class="modelsViewContent" >
        <div class="clinicalVariantsPager" class="pager" style="margin-bottom:2px;">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="3">3</option>
                    <option value="5">5</option>
                    <option value="10">10</option>
                    <option value="20">20</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>


</div>
</div>
    <%//ui.dynClose("clinicalVariants")%>

<% } %>

<%@ include file="../sectionFooter.jsp"%>

<%!
    String expandClinVarLinks(String conditions) throws Exception {
        String[] conds = conditions.split("[\\|]");
        for( int i=0; i<conds.length; i++ ) {
            String cond = conds[i];
            int pos = cond.lastIndexOf("[RCV");
            if( pos>0 ) {
                String clinVarId = cond.substring(pos + 1, cond.length() - 1);
                conds[i] = cond.substring(0, pos+1)+ XDBIndex.getInstance().getXDB(52).getALink(clinVarId, clinVarId)+"]";
            }
        }
        return Utils.concatenate(Arrays.asList(conds), "|");
    }

    java.util.Map<Integer,List<MapData>> getPositionsForClinVar(List<VariantInfo> clinvars, MapDAO mapDAO) throws Exception {

        java.util.Map<Integer, List<MapData>> result = new HashMap<>();

        // get rgd ids for variants
        List<Integer> rgdIds = new ArrayList<>(clinvars.size());
        for( VariantInfo vi: clinvars ) {
            rgdIds.add(vi.getRgdId());
            result.put(vi.getRgdId(), new ArrayList<MapData>());
        }

        // get positions from database
        List<MapData> mds = new ArrayList<>();
        for( int i=0; i<rgdIds.size(); i+=1000 ) {
            int j = i+1000;
            if( j>rgdIds.size() ) {
                j = rgdIds.size();
            }
            mds.addAll(mapDAO.getMapData(rgdIds.subList(i, j)));
        }

        // sort the positions by map_key, descending
        Collections.sort(mds, new Comparator<MapData>() {
            @Override
            public int compare(MapData o1, MapData o2) {
                return o2.getMapKey() - o1.getMapKey();
            }
        });

        // put positions into a hash with rgd-id as key
        for( MapData md: mds ) {
            List<MapData> positions = result.get(md.getRgdId());
            positions.add(md);
        }
        return result;
    }
%>