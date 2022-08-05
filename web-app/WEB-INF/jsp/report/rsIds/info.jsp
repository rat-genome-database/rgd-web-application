<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.dao.impl.variants.VariantTranscriptDao" %>
<%@ page import="edu.mcw.rgd.dao.impl.variants.PolyphenDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.variants.VariantTranscript" %>
<%@ page import="edu.mcw.rgd.dao.spring.variants.Polyphen" %>
<%@ page import="edu.mcw.rgd.datamodel.prediction.PolyPhenPrediction" %>
<%
    Map map = mapDAO.getMap(mapKey);
    VariantTranscriptDao vtdao = new VariantTranscriptDao();
    PolyphenDAO polydao = new PolyphenDAO();
//    int objRgdId = (int) request.getAttribute("rgdId");
    String start =  request.getAttribute("start").toString();
    String stop = request.getAttribute("stop").toString();
    String chr = request.getAttribute("chr").toString();
%>


<table>
    <tr>
        <td colspan="2" style="font-size:20px; color:#2865A3; font-weight:700;">
            Your selection has multiple variants. Select which variant for <%=symbol%>&nbsp;you would like to view -&nbsp;<%=SpeciesType.getTaxonomicName(speciesType)%></td>
        <td width="10%"></td>
        <td align="right">
            <form id="downloadVue">
                <input type="hidden" id="start" value=""/>
                <input type="hidden" id="stopPos" value=""/>
                <input type="hidden" id="chr" value=""/>
                <input type="hidden" id="mapKey" value=""/>
                <input type="hidden" id="symbol" value=""/>
                <input type="image" style="cursor:pointer;" height=33 width=35 v-on:click="downloadVars" src="/rgdweb/common/images/excel.png"></input> <!--  onclick="downloadVariants()" -->
            </form>
        </td>
    </tr>
    <tr>
        <td>Assembly:&nbsp;<a href='<%=SpeciesType.getNCBIAssemblyDescriptionForSpecies(map.getSpeciesTypeKey())%>'><%=map.getName()%></a></td>
    </tr>
    <% if (speciesType != SpeciesType.CHINCHILLA && speciesType != SpeciesType.BONOBO && speciesType != SpeciesType.NAKED_MOLE_RAT ){ %>
    <tr>
        <td><b>
            <a style="font-size: 14px;" href="/rgdweb/front/select.html?start=&stop=&chr=&geneStart=&geneStop=&geneList=<%=symbol%>&mapKey=<%=mapKey%>">View in Variant Visualizer</a>
        </b></td>
    </tr>
    <% } %>
</table>
<br>
<% if (vars.size() <= 5000) {%>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>
<div id="mapDataTableDiv" class="annotation-detail" >
    <div class="search-and-pager">
        <div class="modelsViewContent" >
            <div class="pager mapDataPager" >
                <form>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                    <span type="text" class="pagedisplay"></span>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                    <select class="pagesize">
                        <option value="25">25</option>
                        <option value="50">50</option>
                        <option selected="selected" value="100">100</option>
                        <option value="250">250</option>
                        <option value="500">500</option>
                        <option value="1000">1000</option>
                    </select>
                </form>
            </div>
        </div>
    </div>

    <table border="0" id="mapDataTable" class="tablesorter" border='0' cellpadding='2' cellspacing='2' aria-describedby="mapDataTable_pager_info">
        <tr>
            <th align="left">Variant Page</th>
            <% if (isGene) { %>
            <th align="left">rs ID</th> <% } %>
            <th align="left">Chr</th>
            <th align="left">Position</th>
            <th align="left">Type</th>
            <th align="left">Reference Nucleotide</th>
            <th align="left">Variant Nucleotide</th>
            <th align="left">Location Name</th>
            <th align="left">PolyPhen Prediction</th>
            <% if (speciesType != SpeciesType.CHINCHILLA && speciesType != SpeciesType.BONOBO && speciesType != SpeciesType.NAKED_MOLE_RAT ){ %>
            <th align="left">VV</th>
            <%}%>
        </tr>
        <% for (VariantMapData v : vars) {
            List<VariantTranscript> vts = vtdao.getVariantTranscripts(v.getId(),mapKey);
            List<PolyPhenPrediction> p = null;
            if (vts != null && !vts.isEmpty()) {
                System.out.println("Transcript size: "+vts.size());
                p = polydao.getPloyphenDataByVariantId((int) v.getId(), vts.get(0).getTranscriptRgdId());
            }
        %>
        <tr>
            <td><a style='color:blue;font-weight:700;font-size:11px;' href="/rgdweb/report/variants/main.html?id=<%=v.getId()%>" title="see more information in the variant page">View more Information</a></td>
            <% if (isGene) {
                String rsId = "<a href=\"https://www.ebi.ac.uk/eva/?variant&accessionID="+v.getRsId()+"\">"+v.getRsId()+"</a>";%>
            <td align="left"><%=(v.getRsId()!=null && !v.getRsId().equals("."))?rsId:"-"%></td> <% } %>
            <td><%=v.getChromosome()%></td>
            <td><%=NumberFormat.getNumberInstance(Locale.US).format(v.getStartPos())%>&nbsp;-&nbsp;<%=NumberFormat.getNumberInstance(Locale.US).format(v.getEndPos())%></td>
            <td><%=v.getVariantType()%></td>
            <td><%=Utils.NVL(v.getReferenceNucleotide(), "-")%></td>
            <td><%=Utils.NVL(v.getVariantNucleotide(),"-")%></td>
            <% if (vts != null && !vts.isEmpty()) {%>
            <td><%=Utils.NVL(vts.get(0).getLocationName(),"-")%></td>
            <%} else {out.print("<td>-</td>");}%>
            <% if (p != null && !p.isEmpty()) {%>
            <td><%=p.get(0).getPrediction()%></td>
            <%} else {out.print("<td>-</td>");}%>
            <% if (speciesType != SpeciesType.CHINCHILLA && speciesType != SpeciesType.BONOBO && speciesType != SpeciesType.NAKED_MOLE_RAT ){ %>
            <td><a title="View in Variant Visualizer" href="/rgdweb/front/select.html?start=<%=v.getStartPos()%>&stop=<%=v.getEndPos()%>&chr=<%=v.getChromosome()%>&geneStart=&geneStop=&geneList=<%=symbol%>&mapKey=<%=mapKey%>">
                <img src="/rgdweb/common/images/variantVisualizer-abr.png" width="30" height="15">
            </a></td>
            <% } %>
        </tr>
        <% } %>
    </table>
    <div class="modelsViewContent" >
        <div class="pager mapDataPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option value="25">25</option>
                    <option value="50">50</option>
                    <option selected="selected" value="100">100</option>
                    <option value="250">250</option>
                    <option value="500">500</option>
                    <option value="1000">1000</option>
                </select>
            </form>
        </div>
    </div>
</div>
<% }
else { %>
<br>
<h1 style="color: red;">Exceeded amount of Variants to view (5000). They can still be viewed in Variant Visualizer or be downloaded.</h1>
<% } %>
<%--<div style="width:1px; height:1px; overflow:hidden;visibility:hidden;">--%>
<%--    <form id="download" name="download" >--%>
<%--        <input name="start" value=""/>--%>
<%--        <input name="stopPos" value=""/>--%>
<%--        <input name="chr" value=""/>--%>
<%--        <input name="mapKey" value=""/>--%>
<%--        <input name="symbol" value=""/>--%>
<%--    </form>--%>
<%--</div>--%>

<script>
    var downloadVue = new Vue ({
        el: '#downloadVue',
        data: {
            start: '<%=start%>',
            stopPos: '<%=stop%>',
            chr: '<%=chr%>',
            mapKey: '<%=mapKey%>',
            symbol: '<%=symbol%>'
        },
        methods: {
            downloadVars: function () {
                // alert("Start vue");
                axios
                    .post('/rgdweb/report/rsIds/download.html',
                        {
                            start: downloadVue.start,
                            stopPos: downloadVue.stopPos,
                            chr: downloadVue.chr,
                            mapKey: downloadVue.mapKey,
                            symbol: downloadVue.symbol
                        },
                    {responseType: 'blob'})
                    .then(function (response) {
                        // alert("done");
                        // console.log(response);
                        var a = document.createElement("a");
                        document.body.appendChild(a);
                        a.style = "display: none";
                        let blob = new Blob([response.data], { type: 'text/csv' }),
                            url = window.URL.createObjectURL(blob);
                        a.href = url;
                        a.download = "variants.csv";
                        a.click();
                        window.URL.revokeObjectURL(url);
                        // window.open(url)
                    })
                    .catch(function (error) {
                    console.log(error.response.data)
                })
            }
        }
    });
</script>