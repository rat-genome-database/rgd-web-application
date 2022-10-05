<%@ include file="../sectionHeader.jsp"%>
<link rel="stylesheet" href="/rgdweb/js/javascriptPopUpWindow/GAdhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/rgdweb/js/javascriptPopUpWindow/dhtmlwindow.js">
</script>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>
<div class="reportTable light-table-border" id="variantSamplesTableWrapper">
    <div class="sectionHeading" id="variantSamples">Variant Samples</div>

    <div class="search-and-pager">
        <div class="modelsViewContent" >
            <div class="pager variantSamplesPager" >
                <form>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                    <span type="text" class="pagedisplay"></span>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                    <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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

        <input class="search table-search" id="variantSamplesSearch" type="search" data-column="all" placeholder="Search table">
    </div>

    <div id="variantSamplesTableDiv" class="annotation-detail">
        <table id="variantSamplesTable" border='0' cellpadding='2' cellspacing='2' aria-describedby="variantSamplesTable_pager_info">
            <tr></tr>
        <%
            boolean isRow = false;
            String evenOdd = (isRow) ? "even" : "odd";
            isRow = true;
            for (int i=0 ; i < col.size();i++){
                Sample s = sdao.getSampleBySampleId(col.get(i).getSampleId());
                long start = var.getStartPos() - 10;
                long stop = var.getEndPos() + 10;
                String vvUrl = "/rgdweb/front/variants.html?start="+ start +"&stop="+stop+"&chr=" + var.getChromosome() +
                        "&geneStart=&geneStop=&geneList=&mapKey="+s.getMapKey()+"&con=&depthLowBound=1&depthHighBound=&sample1="+s.getId();
                if (i==0) {
                    out.print("<tr  class=\"" + evenOdd + "Row\">");
                }
                else if (i%3==0){
                    evenOdd = (isRow) ? "even" : "odd";
                    out.print("</tr><tr  class=\""+evenOdd+"Row\">" );
                    isRow = !isRow;
                } %>
            <td><a href="<%=vvUrl%>" title="View in Variant Visualizer"><%=s.getAnalysisName()%></a></td>
<%--                <div style="margin:10px; position:absolute; z-index:100; visibility:hidden; padding:10px;background: #2865A3;" id="div_<%=s.getId()%>">--%>
<%--                    <table cellpadding='4' style="background-color:#063968;border:2px solid white;padding:10px;">--%>
<%--                        <tr>--%>
<%--                            <td style="font-size:14px; font-weight:700; color:white;background: #2865A3;">Sample ID:</td>--%>
<%--                            <td style="font-size:14px; color:white;background: #2865A3;"><%=s.getId()%></td>--%>
<%--                        </tr>--%>

<%--                        <% if (SpeciesType.getSpeciesTypeKeyForMap(var.getMapKey()) == 3) { %>--%>
<%--                        <tr>--%>
<%--                            <td style="font-size:14px; font-weight:700; color:white;background: #2865A3;">Strain RGD ID</td>--%>
<%--                            <td style="font-size:14px; color:white;background: #2865A3;"><%=s.getStrainRgdId()%></td>--%>
<%--                        </tr>--%>
<%--                        <% } %>--%>

<%--                        <% if (s.getSequencedBy() != null) { %>--%>
<%--                        <tr>--%>
<%--                            <td valign="top" style="font-size:14px; font-weight:700; color:white;background: #2865A3;">Sequenced By:</td>--%>
<%--                            <td style="font-size:14px; color:white;background: #2865A3;"><%=s.getSequencedBy()%></td>--%>
<%--                        </tr>--%>
<%--                        <% } %>--%>
<%--                        <% if (s.getSequencer() != null) { %>--%>
<%--                        <tr>--%>
<%--                            <td style="font-size:14px; font-weight:700; color:white;background: #2865A3;">Platform:</td>--%>
<%--                            <td style="font-size:14px; color:white;background: #2865A3;"><%=s.getSequencer()%></td>--%>
<%--                        </tr>--%>
<%--                        <% } %>--%>
<%--                        <% if (s.getSecondaryAnalysisSoftware() != null) { %>--%>
<%--                        <tr>--%>
<%--                            <td style="font-size:14px; font-weight:700; color:white;background: #2865A3;">Secondary Analysis:</td>--%>
<%--                            <td style="font-size:14px; color:white;background: #2865A3;"><%=s.getSecondaryAnalysisSoftware()%></td>--%>
<%--                        </tr>--%>
<%--                        <% } %>--%>
<%--                        <% if (s.getWhereBred() != null) { %>--%>
<%--                        <tr>--%>
<%--                            <td style="font-size:14px; font-weight:700; color:white;background: #2865A3;">Breeder:</td>--%>
<%--                            <td style="font-size:14px; color:white;background: #2865A3;"><%=s.getWhereBred()%></td>--%>
<%--                        </tr>--%>
<%--                        <% } %>--%>
<%--                        <% if (s.getGrantNumber() != null) { %>--%>
<%--                        <tr>--%>
<%--                            <td style="font-size:14px; font-weight:700;color:white;background: #2865A3;">Grant Information:</td>--%>
<%--                            <td style="font-size:14px; color:white;background: #2865A3;"><%=s.getGrantNumber()%></td>--%>
<%--                        </tr>--%>
<%--                        <% } %>--%>
<%--                    </table>--%>
<%--                </div>--%>
<%--            </td>--%>

            <%}%>

            </tr>
        </table>
    </div>

    <div class="modelsViewContent" >
        <div class="pager variantSamplesPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
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
</div>
<script>
    function displayVariant(sid, vid) {
        var url = "/rgdweb/report/variants/transcripts.html?sid=" + sid + "&vid=" + vid;
        var googlewin=dhtmlwindow.open("ajaxbox", "ajax", url,"Variant Details", "width=740px,height=400px,resize=1,scrolling=1,center=1", "recal");
        document.getElementById("ajaxbox").scrollTop=0;
    }
</script>
<%@ include file="../sectionFooter.jsp"%>