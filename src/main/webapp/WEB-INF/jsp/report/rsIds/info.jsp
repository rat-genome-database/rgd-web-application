<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.dao.impl.variants.VariantTranscriptDao" %>
<%@ page import="edu.mcw.rgd.dao.impl.variants.PolyphenDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.variants.VariantTranscript" %>
<%@ page import="edu.mcw.rgd.datamodel.prediction.PolyPhenPrediction" %>
<%@ page import="java.util.ArrayList" %>
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


<%-- Every section of a report page has to sit in a .reportTable .light-table-border. That
     class is what carries the card background, and because it is display:block with
     overflow-x:auto it is also the scroll container that keeps a wide table inside the page.
     Markup placed bare under #content-wrap gets neither: reportModern.css deliberately makes
     the legacy 95%-width layout table wrapper transparent (background:none) and
     table-layout:fixed, so an unwrapped section renders straight onto the page background
     and its widest descendant spills past the right edge instead of scrolling. --%>
<div class="reportTable light-table-border">
    <div class="sectionHeading" id="variantSummary">Variant Summary</div>

    <%-- This was a layout table. The count, the assembly and the two actions are three
         independent blocks rather than a grid - nothing lines up column-wise - so they sit
         in a flex row that wraps the actions underneath on a narrow body column instead of
         forcing a horizontal scroll the way table cells did. --%>
    <div class="variantSummary">

        <div class="variantSummaryLead">
            <div class="variantSummaryHeadline">
                <span class="variantSummaryFigure"><%=NumberFormat.getNumberInstance(Locale.US).format(totalSize)%></span>
                <span class="variantSummaryLabel">
                    RGD variant record<%=totalSize==1 ? "" : "s"%> for <strong><%=symbol%></strong>
                    <span class="variantSummarySpecies"><%=SpeciesType.getTaxonomicName(speciesType)%></span>
                </span>
            </div>

            <% if (isGene){%>
            <div class="variantSummaryChips">
                <a class="rgd-chip variantSummaryChip" title="the assembly these positions are on"
                   href='<%=SpeciesType.getNCBIAssemblyDescriptionForSpecies(map.getSpeciesTypeKey())%>'>
                    <i class="fa fa-map-o"></i><%=map.getName()%>
                </a>
            </div>
            <% } %>
        </div>

        <% if (isGene){%>
        <div class="variantSummaryActions">
            <% if (speciesType != SpeciesType.CHINCHILLA && speciesType != SpeciesType.BONOBO && speciesType != SpeciesType.NAKED_MOLE_RAT ){ %>
            <a class="rgd-action" title="open every variant of this gene in Variant Visualizer"
               href="/rgdweb/front/select.html?start=&stop=&chr=&geneStart=&geneStop=&geneList=<%=symbol%>&mapKey=<%=mapKey%>">
                <i class="fa fa-bar-chart"></i>Variant Visualizer
            </a>
            <% } %>
            <%-- The five hidden inputs that used to be here were dead: downloadVariants.jsp
                 reads start/stopPos/chr/mapKey/symbol off the axios POST body, and the Vue
                 instance takes its data from the JSP values below, never from the DOM.
                 type="image" also submitted the form on click - a plain button does not. --%>
            <form id="downloadVue" class="variantSummaryDownload">
                <button type="button" class="rgd-action" v-on:click="downloadVars"
                        title="download every variant in this report as CSV">
                    <img src="/rgdweb/common/images/excel.png" alt=""/>Download all
                </button>
            </form>
        </div>
        <% } %>
    </div>
</div>

<%-- The filter, the pager and the variant table share one card, and that card is what
     scrolls. #mapDataTable has 12 columns and no width of its own, so with nothing around it
     carrying overflow-x it sized to its content, stretched the cell of the #content-wrap
     layout table and ran off the right of the page. table-layout:fixed on that wrapper pins
     the body column to the container, which is what lets this card's overflow-x:auto
     actually scroll rather than just grow. --%>
<div class="reportTable light-table-border">
    <div class="sectionHeading" id="variantList">Variants</div>

<%-- One toolbar: the location filter on the left, the pager on the right, wrapping onto two
     rows when the body column is narrow. The pager was a layout table and the controls each
     carried an inline font-size:25px - larger than the report hero's own title, which is
     most of why this section read as unstyled. Both are gone; sizing comes from the CSS.

     The form element keeps id="locationChange" and the radios stay direct form controls:
     the handler at the foot of this file walks it as an HTMLFormControlsCollection
     (rad.length / rad[i]), so moving the radios out of the form would break it. --%>
<div class="variantToolbar">

    <% if (isGene){%>
    <form id="locationChange" class="variantLocFilter">
        <span class="variantToolbarLabel">Location</span>
        <span class="variantSegmented">
            <input type="radio" id="exon" name="locationType" value="exon" <%=locType.equals("exon") ? "checked" : ""%>>
            <label for="exon">Exon</label>
            <input type="radio" id="intron" name="locationType" value="intron" <%=locType.equals("intron") ? "checked" : ""%>>
            <label for="intron">Intron</label>
            <input type="radio" id="all" name="locationType" value="all" <%=locType.equals("all") ? "checked" : ""%>>
            <label for="all">All</label>
        </span>
    </form>
    <% } %>

    <%-- Two different things page this report and they must not read as one control.

         This one moves between SERVER batches: the controller fetches 1000 records per
         request, so each button here is a page load. It is hidden entirely when everything
         fits in one batch - which is the common case - leaving the row pager below as the
         only pagination on screen. The row pager is the one that pages what is already
         loaded. --%>
    <% if (maxPage>1){
        int batchTo = Math.min(offset + vars.size() - 1, totalSize);
    %>
    <div class="variantPager">
        <span class="variantPagerStatus">
            Records <strong><%=NumberFormat.getNumberInstance(Locale.US).format(offset)%>&#8211;<%=NumberFormat.getNumberInstance(Locale.US).format(batchTo)%></strong>
            of <%=NumberFormat.getNumberInstance(Locale.US).format(totalSize)%>
        </span>
        <% if (curPage > 1) {%>
        <button type="button" title="load the previous 1000 records" onclick="goBack()">
            <i class="fa fa-chevron-left"></i>Prev
        </button>
        <% } %>
        <% if (curPage<maxPage) {%>
        <button type="button" title="load the next 1000 records" onclick="goForward()">
            Next<i class="fa fa-chevron-right"></i>
        </button>
        <% } %>
        <label class="variantToolbarLabel" for="pageChanger">Batch</label>
        <select id="pageChanger" onchange="pageChange()">
            <%
                for (int i = 1 ; i <= maxPage;i++){
                    if (i==curPage)
                        out.print("<option value="+i+" selected>"+i+"</option>");
                    else
                        out.print("<option value="+i+">"+i+"</option>");
                }
            %>
        </select>
    </div>
    <% } %>
</div>
<%     if (totalSize != 0){ %>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>

<%-- Row pagination for the grid itself, so a batch of up to 1000 records is no longer one
     long scroll. tablesorterPager takes a jQuery set rather than a single node, so naming
     .mapDataPager wires this copy and the one below the grid from the single call in
     tablesorterReportCode.js and keeps them in step.

     The pager needs thead and tbody to slice rows out of - it has no way to tell a header
     row from a data row otherwise - which is why this could not have worked before the
     thead was added below.

     Note class="mapDataPager pager", one attribute. Most report pages write this as two
     separate class attributes; the HTML parser keeps the first and drops the second, so
     .pager never reaches them and they lose the skin's pager styling. --%>
<div class="mapDataPager pager">
    <form>
        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first" title="first page" alt="first"/>
        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev" title="previous page" alt="previous"/>
        <span class="pagedisplay" id="mapDataTable_pager_info"></span>
        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next" title="next page" alt="next"/>
        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last" title="last page" alt="last"/>
        <select class="pagesize" title="rows per page">
            <option value="10">10</option>
            <option value="25">25</option>
            <option value="50">50</option>
            <option value="100">100</option>
            <option value="9999">All Rows</option>
        </select>
    </form>
</div>

<div id="mapDataTableDiv" class="annotation-detail" >

    <%-- thead/tbody are required, not cosmetic: tablesorterReportCode.js calls .tablesorter()
         on #mapDataTable, and tablesorter bails out on a table with no thead. A browser
         auto-inserts tbody but never thead, so every row here landed in tbody, the plugin
         failed to initialise and never added its .tablesorter-blue class - which is what
         carries the header background, the zebra striping and the row hover. That is why the
         grid rendered as bare unstyled rows. --%>
    <table id="mapDataTable" class="tablesorter" border="0" cellpadding='2' cellspacing='2' aria-describedby="mapDataTable_pager_info">
        <thead>
        <tr>
<%--            <th class="variantIdx"></th>--%>
            <%-- "Variant Page" and its "View more" link are gone, replaced by the Links
                 column below. Neither column is conditional on isGene any more: Links is the
                 only route to the variant report now, and an rsId-scoped request (?id=rs...)
                 needs that route just as much as a gene-scoped one does. --%>
            <th align="left" class="variantRsId">rs ID</th>
            <th align="left" class="variantLinks">Links</th>
            <th align="left">Assembly</th>
            <th align="left" class="variantChr">Chr</th>
            <th align="left" class="variantPos">Position</th>
            <th align="left">Type</th>
            <th align="left" class="variantNuc">Reference Nucleotide</th>
            <th align="left" class="variantNuc">Variant Nucleotide</th>
            <th align="left">Location Name</th>
            <th align="left">Is Damaging?</th>
            <% if (speciesType != SpeciesType.CHINCHILLA && speciesType != SpeciesType.BONOBO && speciesType != SpeciesType.NAKED_MOLE_RAT ){ %>
            <th align="left">Visualize</th>
            <%}%>
        </tr>
        </thead>
        <tbody>
        <% for (VariantMapData v : vars) {
            Map m = mapDAO.getMap(v.getMapKey());
//            VariantMapData v = vars.get(i);
            List<VariantTranscript> vts = vtdao.getVariantTranscripts(v.getId(),v.getMapKey());
//            VariantTranscript transcript = null;
            List<PolyPhenPrediction> predictions = null;
            List<String> locNames = new ArrayList<>();
            String locName = null;
            String isDamaging = null;
            // Probably damaging > possibly damaging > benign
            for (VariantTranscript vt : vts){
                String[] types = vt.getLocationName().split(",");
                for (String type : types){
                    if (!locNames.contains(type)) {
                        locNames.add(type);
                        if (!Utils.isStringEmpty(locName)){
                            locName += ";"+type;
                        }
                        else
                            locName = type;
                    }
                }
                predictions = polydao.getPloyphenDataByVariantId((int) v.getId(), vt.getTranscriptRgdId());
                for (PolyPhenPrediction p : predictions){
                    if (p.getPrediction().equals("probably damaging")) {
                        isDamaging = p.getPrediction();
                        break;
                    }
                    else if (p.getPrediction().equals("possibly damaging")){
                        if (Utils.isStringEmpty(isDamaging) || Utils.stringsAreEqual(isDamaging,"benign"))
                            isDamaging = p.getPrediction();
                    }
                    else if (p.getPrediction().equals("benign")){
                        if (Utils.isStringEmpty(isDamaging))
                            isDamaging = p.getPrediction();
                    }
                }
            }
        %>
        <tr>
<%--            <td class="variantIdx"><%=offset%>.</td>--%>
            <%
                // "." is this dataset's null for an rs id, so it is not a value to link to.
                String rsIdVal = (v.getRsId()!=null && !v.getRsId().equals(".")) ? v.getRsId() : null;
            %>
            <td align="left" class="variantRsId"><%=rsIdVal!=null ? rsIdVal : "-"%></td>
            <td align="left" class="variantLinks">
                <%-- RGD is keyed off the variant's own id, not the rs id, so it is always
                     valid - including on the rows that have no rs id at all. --%>
                <a class="rgdChipLink" href="/rgdweb/report/variants/main.html?id=<%=v.getId()%>"
                   title="variant report in RGD">RGD</a>
                <%-- EVA is skipped for human, as it was before this column was rewritten:
                     the old code linked rs ids to EVA for every species except human and
                     rendered human ids as bare text. --%>
                <% if (rsIdVal!=null && speciesType!=SpeciesType.HUMAN) { %>
                <a class="rgdChipLink" href="https://www.ebi.ac.uk/eva/?variant&accessionID=<%=rsIdVal%>"
                   title="this variant in the European Variation Archive">EVA</a>
                <% } %>
            </td>
            <td><%=m.getName()%></td>
            <td class="variantChr"><%=v.getChromosome()%></td>
            <td class="variantPos"><%=NumberFormat.getNumberInstance(Locale.US).format(v.getStartPos())%>&nbsp;-&nbsp;<%=NumberFormat.getNumberInstance(Locale.US).format(v.getEndPos())%></td>
            <td><%=v.getVariantType()%></td>
            <td class="variantNuc">
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
            <td class="variantNuc">
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
            <td><%=locName!=null ? Utils.NVL(locName,"-") : v.getGenicStatus()%></td>
            <td><%=Utils.NVL(isDamaging,"-")%></td>
            <% if (speciesType != SpeciesType.CHINCHILLA && speciesType != SpeciesType.BONOBO && speciesType != SpeciesType.NAKED_MOLE_RAT ){ %>
            <td><a title="View with selected Strains" href="/rgdweb/front/select.html?start=<%=v.getStartPos()%>&stop=<%=v.getEndPos()%>&chr=<%=v.getChromosome()%>&geneStart=&geneStop=&geneList=&mapKey=<%=v.getMapKey()%>">
                <img src="/rgdweb/common/images/variantVisualizer-abr.png" width="30" height="15">
            </a></td>
            <% } %>
        </tr>
        <% offset++;} %>
        </tbody>
    </table>


</div>

<%-- the same container class again: one tablesorterPager call drives both --%>
<div class="mapDataPager pager mapDataPagerBottom">
    <form>
        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first" title="first page" alt="first"/>
        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev" title="previous page" alt="previous"/>
        <span class="pagedisplay"></span>
        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next" title="next page" alt="next"/>
        <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last" title="last page" alt="last"/>
        <select class="pagesize" title="rows per page">
            <option value="10">10</option>
            <option value="25">25</option>
            <option value="50">50</option>
            <option value="100">100</option>
            <option value="9999">All Rows</option>
        </select>
    </form>
</div>

<% } else {%>
<h1 style="color: red;">No variants for given selection!</h1>
<% } %>
</div><%-- /.reportTable.light-table-border (Variants) --%>


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