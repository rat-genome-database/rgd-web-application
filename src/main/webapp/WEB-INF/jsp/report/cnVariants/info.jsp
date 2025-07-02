<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.InetAddress" %>

<%@ page import="org.elasticsearch.common.recycler.Recycler" %>
<%@ page import="org.locationtech.jts.awt.PointShapeFactory" %>
<%@ page import="edu.mcw.rgd.datamodel.variants.VariantSSId" %>
<%@ include file="../sectionHeader.jsp"%>
<style>
    .wrap660 {
        display: block;
        width: 660px;
        word-break: break-all;
    }
</style>
<%
    String objType = "{unknown object type}";
    String description = null;
    if( obj!=null ) {
        objType = obj.getObjectTypeName();
    }

boolean isEva = false;

    if (mapKey!=631) {
        for (Sample s : samples){
            if (s.getAnalysisName().contains("European Variation Archive")) {
                isEva = true;
                break;
            }
        }
    }


    int start = (int) var.getStartPos();
    int stop = (var.getStartPos()+1) == var.getEndPos() ? (int) var.getStartPos() : (int) var.getEndPos();
    List<MapData> mapData = mapDAO.getMapDataWithinRange(start,stop,var.getChromosome(),var.getMapKey(),1);
    List<Gene> geneList = new ArrayList<>();
    String genes = "";
    if (mapData.size()>0) {
        GeneDAO geneDao = new GeneDAO();
        for (MapData m : mapData) {
            Gene g = geneDao.getGene(m.getRgdId());
            if (g != null)
                geneList.add(g);
        }
    }

    String genicStatus = "INTERGENIC";
    if (geneList.size()>0)
        genicStatus = "GENIC";

    RGDManagementDAO rdao = new RGDManagementDAO();
    RgdId rid = rdao.getRgdId2(obj.getRgdId());
    if (!rid.getObjectStatus().equals("ACTIVE")) {
    %>
        <div style="border:5px solid red; padding:20px;margin-bottom:10px;">
            <h1 style="color:red;">This object has been <%=rid.getObjectStatus()%>.
        </div>

    <%
        return;
    } %>

<%
    if (var.getRsId() == null || var.getRsId().equals("")) {
        //try to get it from the xdb table
        Xdb xdb = XDBIndex.getInstance().getXDB(48);
        xdb.getUrl(obj.getSpeciesTypeKey());
        List<XdbId> xids = new XdbIdDAO().getXdbIdsByRgdId(48, obj.getRgdId());
        for (XdbId xid : xids) {
            var.setRsId("rs" + xid.getAccId());
            break;
        }
    }
%>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr><td colspan="2"><h3>Variant: <%=displayName%>&nbsp;-&nbsp; <%=SpeciesType.getTaxonomicName(speciesType)%>
    </h3></td></tr>

<%--    <tr>--%>
<%--        <td class="label" valign="top">Name:</td>--%>
<%--        <td><%=Utils.NVL(var.getName(), "")%></td>--%>
<%--    </tr>--%>
    <tr>
        <td class="label">RGD ID:</td>
        <td><%=obj.getRgdId()%></td>
    </tr>
    <%if (!Utils.isStringEmpty(var.getRsId()) && !var.getRsId().equals(".")) {
    String evaUrl = xdbDAO.getXdbUrlnoSpecies(158);%>
    <tr>
        <td class="label">RS ID:</td>
        <% if (!isEva){%>
        <td><%=var.getRsId()%></td>
        <% } else { %>
        <td><a href="<%=evaUrl+var.getRsId()%>" title="view variant from EVA"><%=var.getRsId()%></a></td>
        <% } %>
    </tr>
    <% }
        if (ssIds != null && !ssIds.isEmpty()) {
            String evaUrl = xdbDAO.getXdbUrlnoSpecies(158);%>
    <tr>
        <td class="label">
            Associated ss Id(s):
        </td>
        <td>
            <%for (int i = 0; i < ssIds.size(); i++) {
                VariantSSId ssId = ssIds.get(i);
                if (i == ssIds.size()-1){%>
                <a href="<%=evaUrl+ssId.getSSId()%>"><%=ssId.getSSId()%></a>
                <% } else {%>
                <a href="<%=evaUrl+ssId.getSSId()%>"><%=ssId.getSSId()%></a>,&nbsp;
            <%  }
            } %>
        </td>
    </tr>
    <% } %>
    <%if (!Utils.isStringEmpty(var.getClinvarId())) {%>
    <tr>
        <td class="label">ClinVar ID:</td>
        <td><%=var.getClinvarId()%></td>
    </tr>
    <% } %>
    <tr>
        <td class="label" valign="top">Genic Status:</td>
        <td><%=Utils.NVL(genicStatus, "")%></td>
    </tr>

    <% if( t != null ) { %>
    <tr>
        <td class="label">Type:</td>
        <td>
            <%=t.getTerm()%>&nbsp;<a href="<%=Link.ontView(t.getAccId())%>" title="click to go to ontology page"><%= "("+ t.getAccId() + ")"%></a>&nbsp;
        </td>
    </tr>
    <% } %>

    <%  if (geneList.size() > 0) {

            // sort strains by symbol
            Collections.sort(geneList, new Comparator<Gene>() {
                public int compare(Gene o1, Gene o2) {
                    return Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
                }
            });
         for(Gene g: geneList){
             String url = Link.gene(g.getRgdId());
             genes = genes.concat("<a href="+url+">");
             genes=genes.concat(g.getSymbol());
             genes = genes.concat("</a>&nbsp;&nbsp;");
         }
    %>
    <tr>
        <td class="label" valign="top">Associated Genes:</td>
        <td><%=genes%></td>
    </tr>
    <% }// genelist>0 %>

    <tr>
        <td class="label" valign="top">Reference Nucleotide:</td>
        <td class="wrap660"><%=Utils.NVL(var.getReferenceNucleotide(), "-")%></td>
    </tr>
    <tr>
        <td class="label" valign="top">Variant Nucleotide:</td>
        <td class="wrap660"><%=Utils.NVL(var.getVariantNucleotide(), "-")%></td>
    </tr>
    <tr>
        <td class="label">Position</td>
        <td>
            <table border="0" class="mapDataTable" width="670">
                <tr>
                    <th align="left"><b>Assembly</b></th>
                    <th align="left">Chr</th>
                    <th align="left">Position</th>
                </tr>
                <% for (VariantMapData v : vars) {
                    Map map = mapDAO.getMap(v.getMapKey()); %>
                <tr>
                    <% if (v.getMapKey()==refMap.getKey()) { %>
                    <td><a style='color:blue;font-weight:700;font-size:11px;' href='<%=SpeciesType.getNCBIAssemblyDescriptionForSpecies(map.getSpeciesTypeKey())%>'><%=map.getName()%></a></td>
                    <% }
                    else {%>
                    <td><%=map.getName()%></td>
                    <% } %>
                    <td><%=v.getChromosome()%></td>
                    <td><% if( (v.getEndPos()-v.getStartPos())==1 || (v.getEndPos()-v.getStartPos())==0 ){
                        out.print( NumberFormat.getNumberInstance(Locale.US).format(v.getStartPos()) );
                    } else{%>
                        <%=NumberFormat.getNumberInstance(Locale.US).format(v.getStartPos())%>&nbsp;-&nbsp;<%=NumberFormat.getNumberInstance(Locale.US).format(v.getEndPos())%>
                        <%}%></td>
                </tr>
                <% } %>
            </table></td>
    </tr>
    <% if(fu.mapPosIsValid(var)) {
        String dbJBrowse = "";
        switch (var.getMapKey()){
            case 372:
                dbJBrowse = "data_rn7_2";
                break;
            case 360:
                dbJBrowse = "data_rgd6";
                break;
            case 70:
                dbJBrowse = "data_rgd5";
                break;
            case 38:
                dbJBrowse = "data_hg38";
                break;
            case 17:
                dbJBrowse = "data_hg19";
                break;
            case 35:
                dbJBrowse = "data_mm38";
                break;
            case 239:
                dbJBrowse = "data_mm39";
                break;
            case 1311:
                dbJBrowse = "data_chlSab2";
                break;
            case 631:
            case 634:
                dbJBrowse = "data_dog3_1";
                break;
            case 910:
                dbJBrowse = "data_pig10_2";
                break;
            case 911:
                dbJBrowse = "data_pig11_1";
                break;
            default:
                dbJBrowse = "data_rn7_2";
                break;
        }

        String tracks = "";
        if (genicStatus.equals("GENIC"))
            tracks = "ARGD_curated_genes%2C";
        if (obj.getSpeciesTypeKey()==SpeciesType.HUMAN)
            tracks += "ClinVar";
        else
            tracks += "EVA";

        String url = request.getRequestURL().toString();
        String baseURL = url.substring(0, url.length() - request.getRequestURI().length()) + "/";
        if (baseURL.contains("localhost"))
            baseURL = "https://dev.rgd.mcw.edu/";

        String jbUrl = baseURL+"jbrowse?data="+dbJBrowse+"&tracks="+tracks+"&highlight=&tracklist=0&nav=0&overview=0&loc="+FormUtility.getJBrowseLoc(var);

    %>
    <tr>
        <td  class="label">JBrowse:</td>
        <td align="left">
            <a href="<%=baseURL%>jbrowse?data=<%=dbJBrowse%>&loc=<%=fu.getJBrowseLoc(var)%>&tracks=<%=tracks%>">View Region in Genome Browser (JBrowse)</a>
        </td>
    </tr>
    <tr>
        <td class="label">Model</td>
        <td>
            <iframe id="jbrowseMini" style="overflow:hidden; border: 1px solid black" width="660" scrolling="no"></iframe>
        </td>
    </tr>
    <script>
        $(document).ready(function() {
            document.getElementById('jbrowseMini').src = '<%=jbUrl%>';
        });
    </script>
    <% } if (var.getMapKey()==631) {%>
    <tr>
        <td class="label">Breeds:</td>
        <td>
            <%for (int i = 0 ; i < breeds.size();i++) {
                if (i == breeds.size()-1)
                    out.print(breeds.get(i));
                else
                    out.print(breeds.get(i) +", ");
            } %>
        </td>
    </tr>
    <% } %>

</table>
<br>

<%@ include file="../sectionFooter.jsp"%>
