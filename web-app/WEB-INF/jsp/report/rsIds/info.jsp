<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.dao.impl.variants.VariantTranscriptDao" %>
<%@ page import="edu.mcw.rgd.dao.impl.variants.PolyphenDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.variants.VariantTranscript" %>
<%@ page import="edu.mcw.rgd.datamodel.prediction.PolyPhenPrediction" %>
<%
    Map map = mapDAO.getMap(mapKey);
    VariantTranscriptDao vtdao = new VariantTranscriptDao();
    PolyphenDAO polydao = new PolyphenDAO();
    int objRgdId = 0;
    String paramId="" , start="", stop="", chr="";
    int curPage = Integer.parseInt(request.getAttribute("p").toString());
    int maxPage = Integer.parseInt(request.getAttribute("maxPage").toString());
    String locType = request.getAttribute("locType").toString();
    int totalSize = Integer.parseInt(request.getAttribute("totalSize").toString());
    int offset = ((curPage - 1) * 1000) + 1;
    if (isGene){
        objRgdId = Integer.parseInt(request.getAttribute("rgdId").toString());
        paramId = request.getAttribute("pageId").toString();
        start =  request.getAttribute("start").toString();
        stop = request.getAttribute("stop").toString();
        chr = request.getAttribute("chr").toString();
    }
%>


<table>
    <tr>
        <td colspan="2" style="font-size:20px; color:#2865A3; font-weight:700;">
            <%=symbol%> has <%=totalSize%> Variants -&nbsp;<%=SpeciesType.getTaxonomicName(speciesType)%></td>
        <td width="63%"></td>
        <% if (isGene){%>
        <td align="center">
            <form id="downloadVue">
                <input type="hidden" id="start" value=""/>
                <input type="hidden" id="stopPos" value=""/>
                <input type="hidden" id="chr" value=""/>
                <input type="hidden" id="mapKey" value=""/>
                <input type="hidden" id="symbol" value=""/>
                <input type="image" style="cursor:pointer;" height=40 width=42 v-on:click="downloadVars" src="/rgdweb/common/images/excel.png"/> <!--  onclick="downloadVariants()" -->
                <br><label style="cursor: pointer;" v-on:click="downloadVars"><u>Download all</u></label>
            </form>
        </td>
        <% } %>
    </tr>
    <tr>
        <td>Assembly:&nbsp;<a href='<%=SpeciesType.getNCBIAssemblyDescriptionForSpecies(map.getSpeciesTypeKey())%>'><%=map.getName()%></a></td>
    </tr>

    <% if (isGene){
        if (speciesType != SpeciesType.CHINCHILLA && speciesType != SpeciesType.BONOBO && speciesType != SpeciesType.NAKED_MOLE_RAT ){ %>
    <tr>
        <td><b>
            <a style="font-size: 14px;" href="/rgdweb/front/select.html?start=&stop=&chr=&geneStart=&geneStop=&geneList=<%=symbol%>&mapKey=<%=mapKey%>">View in Variant Visualizer</a>
        </b></td>
    </tr>
    <% } } %>
</table>
<br>
<% if (isGene){%>
<div>
    <form id="locationChange">
        <% if (locType.equals("exon")){%>
        <input type="radio" id="exon" name="locationType" value="exon" checked>
        <%} else {%>
        <input type="radio" id="exon" name="locationType" value="exon">
        <% } %>
        <label for="exon">Exon</label>&nbsp;|&nbsp;
        <% if (locType.equals("intron")){%>
        <input type="radio" id="intron" name="locationType" value="intron" checked>
        <%} else {%>
        <input type="radio" id="intron" name="locationType" value="intron">
        <% } %>
        <label for="intron">Intron</label>&nbsp;|&nbsp;
        <% if (locType.equals("all")){%>
        <input type="radio" id="all" name="locationType" value="all" checked>
        <%} else {%>
        <input type="radio" id="all" name="locationType" value="all">
        <% } %>
        <label for="all">All</label>
    </form>
</div>
<% } %>
<div>
    <table>
        <tr>
            <% if (curPage > 1) {%>
            <td><button style="font-size: 25px; outline: none;" title="go to previous page" onclick="goBack()">Prev</button>&nbsp;&nbsp;</td>
            <% } %>
            <td><label style="font-size: 25px;">Page <%=curPage%> of <%=maxPage%></label>&nbsp;&nbsp;</td>
            <% if (curPage<maxPage) {%>
            <td><button style="font-size: 25px;outline: none;" title="go to next page" onclick="goForward()">Next</button>&nbsp;&nbsp;</td>
            <%}%>
            <%
            if (maxPage>1){%>
             <td><select style="font-size: 25px" id="pageChanger" onchange="pageChange()">
                <%
                for (int i = 1 ; i <= maxPage;i++){
                    if (i==curPage)
                        out.print("<option value="+i+" selected>"+i+"</option>");
                    else
                        out.print("<option value="+i+">"+i+"</option>");
                }
                %>
             </select>
             </td>
           <% } %>
        </tr>
    </table>

</div>
<%     if (totalSize != 0){ %>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>
<div id="mapDataTableDiv" class="annotation-detail" >

    <table border="0" id="mapDataTable" class="tablesorter" border='0' cellpadding='2' cellspacing='2' aria-describedby="mapDataTable_pager_info">
        <tr>
            <th></th>
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
//            VariantMapData v = vars.get(i);
            List<VariantTranscript> vts = vtdao.getVariantTranscripts(v.getId(),mapKey);
            VariantTranscript transcript = null;
            List<PolyPhenPrediction> p = null;
            for (VariantTranscript vt : vts){
                String ltU = locType.toUpperCase();
                if (vt.getLocationName().contains(ltU)) {
                    transcript = vt;
                    p = polydao.getPloyphenDataByVariantId((int) v.getId(), vt.getTranscriptRgdId());
                    break;
                }
                else
                    transcript = vt;
            }
        %>
        <tr>
            <td><%=offset%>.</td>
            <td><a style='color:blue;font-weight:700;font-size:11px;' href="/rgdweb/report/variants/main.html?id=<%=v.getId()%>" title="see more information in the variant page">View more Information</a></td>
            <% if (isGene) {
                String rsId = "<a href=\"https://www.ebi.ac.uk/eva/?variant&accessionID="+v.getRsId()+"\">"+v.getRsId()+"</a>";%>
            <td align="left"><%=(v.getRsId()!=null && !v.getRsId().equals("."))?rsId:"-"%></td> <% } %>
            <td><%=v.getChromosome()%></td>
            <td><%=NumberFormat.getNumberInstance(Locale.US).format(v.getStartPos())%>&nbsp;-&nbsp;<%=NumberFormat.getNumberInstance(Locale.US).format(v.getEndPos())%></td>
            <td><%=v.getVariantType()%></td>
            <td>
                <% String ref = Utils.NVL(v.getReferenceNucleotide(), "-");
                    String refLess = ref;
                    String refMore = "";
                    if (!ref.equals("-") && ref.length()>15){
                        refLess = ref.substring(0,15);
                        refMore = ref.substring(15);
                    }
                %>
                <%=refLess%><% if (ref.length()>16) {%><span class="more" style="display: none;"><%=refMore%></span><a href="" class="moreLink" title="Click to see more">...</a><% } %>
            </td>
            <td>
                <% String varNuc = Utils.NVL(v.getVariantNucleotide(),"-");
                    String varLess = varNuc;
                    String varMore = "";
                    if (!varNuc.equals("-") && varNuc.length()>15){
                        varLess = varNuc.substring(0,15);
                        varMore = varNuc.substring(15);
                    }
                %>
                <%=varLess%><% if (varNuc.length()>16) {%><span class="more" style="display: none;"><%=varMore%></span><a href="" class="moreLink" title="Click to see more">...</a><% } %>
            </td>
            <% if (vts != null && !vts.isEmpty()) {%>
            <td><%=Utils.NVL(transcript.getLocationName(),"-")%></td>
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
        <% offset++;} %>
    </table>


</div>

<% } else {%>
<h1 style="color: red;">No variants for given selection!</h1>
<% } %>


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
                    .post('/rgdweb/report/rsId/download.html',
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

    function download(){
        downloadVue.downloadVars();
    }
    function goBack() {window.location.href = '/rgdweb/report/rsId/main.html?<%=paramId%>=<%=objRgdId%>&p=<%=curPage-1%>';}
    function goForward() {window.location.href = '/rgdweb/report/rsId/main.html?<%=paramId%>=<%=objRgdId%>&p=<%=curPage+1%>';}
    function pageChange() {
        var d = document.getElementById("pageChanger").value;
        window.location.href = '/rgdweb/report/rsId/main.html?<%=paramId%>=<%=objRgdId%>&p='+d;
    }

    var rad = document.getElementById('locationChange');
    var prev = null;
    for (var i = 0; i < rad.length; i++) {
        rad[i].addEventListener('change', function () {
            // (prev) ? console.log(prev.value) : null;
            if (this !== prev) {
                prev = this;
            }
            // console.log("selected "+this.value)
            window.location.href = '/rgdweb/report/rsId/main.html?<%=paramId%>=<%=objRgdId%>&locType='+this.value;
        });
    }

    $(function () {
        $(".more").hide();
        $(".moreLink").on("click", function(e) {

            var $this = $(this);
            var parent = $this.parent();
            var $content=parent.find(".more");
            var linkText = $this.text();

            if(linkText === "..."){
                linkText = " Hide...";
                $content.show();
            } else {
                linkText = "...";
                $content.hide();
            }
            $this.text(linkText);
            return false;

        });
    });
</script>