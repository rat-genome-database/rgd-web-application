<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.phenominer.frontend.OTrees" %>
<%
    String pageTitle = "Phenominer";
    String headContent = "";
    String pageDescription = "";

    OTrees ot = OTrees.getInstance();

    String sex = (String) request.getAttribute("sex");;
    List<String> sampleIds = (List<String>) request.getAttribute("sampleIds");
    List<String> mmIds = (List<String>) request.getAttribute("mmIds");
    List<String> cmIds = (List<String>) request.getAttribute("cmIds");
    List<String> csIds = (List<String>) request.getAttribute("csIds");
    List<String> ecIds = (List<String>) request.getAttribute("ecIds");
    String termString = (String) request.getAttribute("termString");
    int speciesTypeKey = (int) request.getAttribute("speciesTypeKey");
    int filteredRecCount = (int) request.getAttribute("filteredRecCount");

    String sampleOnt = speciesTypeKey==3 ? "RS" : "CS";
    OTrees.OTree rsTree = ot.getFilteredTree(sampleOnt, sex, speciesTypeKey, termString);

%>

<%@ include file="/common/headerarea.jsp"%>

<script>
    function countDown (start, end) {
        var cd = document.getElementById("countDown");
        cd.innerHTML = start;
        var diff;

        if (start > end) {

            if (start - end > 2) {
                diff = Math.floor((start - end) / 2);
            }else {
                diff = 1;
            }

            var newStart = start - diff;
            if (newStart < end) {
                newStart = end;
            }
            setTimeout("countDown(" + newStart + "," + end + ")", 100);
        }
    }
</script>

<table width="95%" cellspacing="1px" border="0">
    <tr>
        <td style="color: #2865a3; font-size: 20px; font-weight:700;">PhenoMiner Database</td>
        <td align="right" colspan="2"><input type="button" value="New Query" onClick="location.href='/rgdweb/phenominer/home.jsp'"/></td>
    </tr>
    <tr>
        <td>
            <span style="">Select values from categories of interest and select <b>"Generate Report"</b> to build report</span>
        </td>
        <td>

            Matching&nbsp;Records&nbsp;<div id="countDown" style="display:inline; font-size: 25px; color: white; background-color: #1b456d; font-weight: 700; border: 1px dotted green; padding: 5px;">14</div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a id="hmurl" href="#both_sex">Heat maps</a>
            <script>
                var totalRecCount = <%=ot.getOTree(sampleOnt,sex,speciesTypeKey).getRecordCount()%>;
                countDown(totalRecCount, <%=filteredRecCount%>);
            </script>

        </td>
        <td align="right">
            <input style="visibility: hidden;" type="button" id="continue" name="continue" value="Generate Report" onClick="location.href='/phenotypes/dataTable/retrieveData?terms=RS%3A29%2CRS%3A1860%2CRS%3A1381%2CCMO%3A371%2CCMO%3A374%2CCMO%3A368%2CCMO%3A369%2CCMO%3A27%2CCMO%3A171%2CCMO%3A149%2CMMO%3A145%2CMMO%3A225%2CMMO%3A6%2CXCO%3A87'" />
        </td>
    </tr>
    <tr>
        <td>&nbsp;</td>
    </tr>
</table>

<table cellspacing='0' border='0'>
    <tr>

        <% if (csIds.size() > 0) { %>

        <td valign='top' style='padding: 5px ;vertical-align: top; background-color: #d7e4bd; border-top: 1px solid black;border-left: 1px solid black;border-right: 3px outset black;border-bottom: 3px outset black;'>
            <div style='font-weight: 700;'>
                <table border="0"  width="100%" style="background-color: #d7e4bd">
                    <tr>
                        <td  height="90" style="font-size:24px; background-color: #d7e4bd; " valign="top"><div style="height:90px; width:100%; border-bottom: 3px solid white">Chinchilla Sources<br><span style="font-size:11px; ">Search for data related to one or more chinchilla sources.</span></div></td>
                    </tr>
                    <tr>
                        <td valign="top" height=45 style="font-size:12px; font-style: italic; color: black;"><b>Examples:</b> <span style="">Bbcdw:Chin, Rrcjo:Chin</span></td>
                    </tr>
                    <tr>
                        <td valign="top" align="center"><input style="font-weight: 700;" type="button" value="Edit Sources" onClick="location.href='/rgdweb/phenominer/selectTerms.html?terms=<%=termString%>&ont=CS&species=<%=speciesTypeKey%>'" /><br><br></td>
                    </tr>
                </table>
            </div>
            <div style='background-color: white; padding: 5px; border: 2px black inset;'>

                <% for (String sample: csIds) { %>
                <li><%=ot.getTermName(sample,sex,speciesTypeKey)%> (<%=rsTree.getRecordCountForTermOnly(sample)%>)</li>
                <% } %>

            </div>
        </td>
        <% } %>


        <% if (sampleIds.size() > 0) { %>

        <td valign='top' style='padding: 5px ;vertical-align: top; background-color: #d7e4bd; border-top: 1px solid black;border-left: 1px solid black;border-right: 3px outset black;border-bottom: 3px outset black;'>
            <div style='font-weight: 700;'>
                <table border="0"  width="100%" style="background-color: #d7e4bd">
                    <tr>
                        <td  height="90" style="font-size:24px; background-color: #d7e4bd; " valign="top"><div style="height:90px; width:100%; border-bottom: 3px solid white">Rat Strains<br><span style="font-size:11px; ">Search for data related to one or more rat strains.</span></div></td>
                    </tr>
                    <tr>
                        <td valign="top" height=45 style="font-size:12px; font-style: italic; color: black;"><b>Examples:</b> <span style="">congenic strain, ACI, BN</span></td>
                    </tr>
                    <tr>
                        <td valign="top" align="center"><input style="font-weight: 700;" type="button" value="Edit Strains" onClick="location.href='/rgdweb/phenominer/selectTerms.html?terms=<%=termString%>&ont=RS&species=<%=speciesTypeKey%>'" /><br><br></td>
                    </tr>
                </table>
            </div>
            <div style='background-color: white; padding: 5px; border: 2px black inset;'>

                <% for (String sample: sampleIds) { %>
                    <li><%=ot.getTermName(sample,sex,speciesTypeKey)%> (<%=rsTree.getRecordCountForTermOnly(sample)%>)</li>
                <% } %>

            </div>
        </td>
        <% } %>

        <% if (cmIds.size() > 0) {
            OTrees.OTree cmoTree = ot.getFilteredTree("CMO", sex, speciesTypeKey, termString); %>
        <td valign='top'><br><br><br><br><br><img src="/rgdweb/common/images/phenoRightArrow.gif" ></td>
        <td valign='top' style='padding: 5px ;vertical-align: top; background-color: #ccc1da; border-top: 1px solid black;border-left: 1px solid black;border-right: 3px outset black;border-bottom: 3px outset black;'>
            <div style='font-weight: 700;'>
                <table border="0"  width="100%" style="background-color: #ccc1da">
                    <tr>
                        <td  height="90" style="font-size:24px; background-color: #ccc1da; " valign="top"><div style="height:90px; width:100%; border-bottom: 3px solid white">Clinical Measurements<br><span style="font-size:11px; ">Query the database by clinical measurement.</span></div></td>
                    </tr>
                    <tr>
                        <td valign="top" height=45 style="font-size:12px; font-style: italic; color: black;"><b>Examples:</b> <span style="">heart rate, blood cell count</span></td>
                    </tr>
                    <tr>
                        <td valign="top" align="center"><input style="font-weight: 700;" type="button" value="Edit Measurements" onClick="location.href='/rgdweb/phenominer/selectTerms.html?terms=<%=termString%>&ont=CMO&species=<%=speciesTypeKey%>'" /><br><br></td>
                    </tr>
                </table>
            </div>
            <div style='background-color: white; padding: 5px; border: 2px black inset;'>
                <% for (String cm: cmIds) { %>
                     <li><%=ot.getTermName(cm,sex,speciesTypeKey)%> (<%=cmoTree.getRecordCountForTermOnly(cm)%>)</li>
                <% } %>
            </div>
        </td>
        <% } %>

        <% if (mmIds.size() > 0) {
            OTrees.OTree mmoTree = ot.getFilteredTree("MMO", sex, speciesTypeKey, termString); %>
        <td valign='top'><br><br><br><br><br><img src="/rgdweb/common/images/phenoRightArrow.gif" ></td>
        <td valign='top' style='padding: 5px ;vertical-align: top; background-color: #fcd5b5; border-top: 1px solid black;border-left: 1px solid black;border-right: 3px outset black;border-bottom: 3px outset black;'>
            <div style='font-weight: 700;'>
                <table border="0"  width="100%" style="background-color: #fcd5b5">
                    <tr>
                        <td  height="90" style="font-size:24px; background-color: #fcd5b5; " valign="top"><div style="height:90px; width:100%; border-bottom: 3px solid white">Measurement Methods<br><span style="font-size:11px; ">Base your query on a list of Measurement methods.</span></div></td>
                    </tr>
                    <tr>
                        <td valign="top" height=45 style="font-size:12px; font-style: italic; color: black;"><b>Examples:</b> <span style="">fluid filled catheter, blood chemistry panel </span></td>
                    </tr>
                    <tr>
                        <td valign="top" align="center"><input style="font-weight: 700;" type="button" value="Edit Methods" onClick="location.href='/rgdweb/phenominer/selectTerms.html?terms=<%=termString%>&ont=MMO&species=<%=speciesTypeKey%>'" /><br><br></td>
                    </tr>
                </table>
            </div>
            <div style='background-color: white; padding: 5px; border: 2px black inset;'>
                <% for (String mm: mmIds) { %>
                    <li><%=ot.getTermName(mm,sex,speciesTypeKey)%> (<%=mmoTree.getRecordCountForTermOnly(mm)%>)</li>
                <% } %>
            </div>
        </td>
        <% } %>

        <% if (ecIds.size() > 0) {
            OTrees.OTree xcoTree = ot.getFilteredTree("XCO", sex, speciesTypeKey, termString); %>
        <td valign='top'><br><br><br><br><br><img src="/rgdweb/common/images/phenoRightArrow.gif" ></td>
        <td valign='top' style='padding: 5px ;vertical-align: top; background-color: #b9cde5; border-top: 1px solid black;border-left: 1px solid black;border-right: 3px outset black;border-bottom: 3px outset black;'>
            <div style='font-weight: 700;'>
                <table border="0"  width="100%" style="background-color: #b9cde5">
                    <tr>
                        <td  height="90" style="font-size:24px; background-color: #b9cde5; " valign="top"><div style="height:90px; width:100%; border-bottom: 3px solid white">Experimental Conditions<br><span style="font-size:11px; ">Find data based on a list of a conditions.</span></div></td>
                    </tr>
                    <tr>
                        <td valign="top" height=45 style="font-size:12px; font-style: italic; color: black;"><b>Examples:</b> <span style="">diet, atmosphere composition</span></td>
                    </tr>
                    <tr>
                        <td valign="top" align="center"><input style="font-weight: 700;" type="button" value="Edit Conditions" onClick="location.href='/rgdweb/phenominer/selectTerms.html?terms=<%=termString%>&ont=XCO&species=<%=speciesTypeKey%>'" /><br><br></td>
                    </tr>
                </table>
            </div>
            <div style='background-color: white; padding: 5px; border: 2px black inset;'>
                <% for (String ec: ecIds) { %>
                    <li><%=ot.getTermName(ec,sex,speciesTypeKey)%> (<%=xcoTree.getRecordCountForTermOnly(ec)%>)</li>
                <% } %>
            </div>
        </td>
        <% } %>
        <td valign='top'>
            <table cellspacing='0' border='0'>
                <tr>
                    <td valign='top'><br><br><br><br><br><img src="/rgdweb/common/images/phenoRightArrow.gif" ></td>
                    <td valign='top'><br><br><br><br><br><img src="/rgdweb/common/images/phenoRightArrow.gif" ></td>
                    <td valign='top'><br><br><br><br><br><img src="/rgdweb/common/images/phenoRightArrow.gif" ></td>
                    <td valign='top'></td>
                    <td valign='top' style='padding: 5px ;vertical-align: top; border-left: 1px solid black;border-top: 1px solid black;'><b>Additional Options...</b><br><br>
                        <% if (sampleIds.size()==0 && csIds.size()==0) { %>

                            <% if (speciesTypeKey ==3) {%>
                                <input style="font-weight: 700;" type="button" value="Limit By Rat Strains" onClick="location.href='/rgdweb/phenominer/selectTerms.html?ont=RS&species=<%=speciesTypeKey%>&terms=<%=termString%>'" /><br><br>
                            <% } else { %>
                                <input style="font-weight: 700;" type="button" value="Limit By Chinchilla Sources" onClick="location.href='/rgdweb/phenominer/selectTerms.html?ont=CS&species=<%=speciesTypeKey%>&terms=<%=termString%>'" /><br><br>

                            <% } %>

                        <% }
                           if (cmIds.size()==0) {
                        %>
                        <input style="font-weight: 700;" type="button" value="Limit By Clinical Measurements" onClick="location.href='/rgdweb/phenominer/selectTerms.html?ont=CMO&species=<%=speciesTypeKey%>&terms=<%=termString%>'" /><br><br>
                        <% }
                            if (ecIds.size()==0) {
                        %>
                        <input style="font-weight: 700;" type="button" value="Limit By Experimental Conditions" onClick="location.href='/rgdweb/phenominer/selectTerms.html?ont=XCO&species=<%=speciesTypeKey%>&terms=<%=termString%>'" /><br><br>
                        <% }
                            if (mmIds.size()==0) {
                        %>
                        <input style="font-weight: 700;" type="button" value="Limit By Measurement Methods" onClick="location.href='/rgdweb/phenominer/selectTerms.html?ont=MMO&species=<%=speciesTypeKey%>&terms=<%=termString%>'" /><br><br>
                        <% } %>
                        <b>I'm Done..</b><br><br><input type=button value="Generate Report" onClick="location.href='/rgdweb/phenominer/table.html?species=<%=speciesTypeKey%>&terms=<%=request.getParameter("terms")%>'"/></td>
                </tr>
            </table>
        </td>
    </tr>
</table>






<table id="heatmaptable">
    <tr>
        <td> <a name="both_sex">Both female and male</a> </td>
        <td align="right">Go to:&nbsp<a href="#female_only">Female</a>&nbsp&nbsp<a href="#male_only">Male</a>&nbsp&nbsp<a href="#difference">Difference</a></td>
    </tr>
    <tr>
        <td colspan="2">
            <div id="resize" style="width:980px; height:750px; padding: 10px; display: block">
                <div id='summary-chart' name='summary-chart' style="width:1000px; height:800px"></div>
            </div>
        </td>
    </tr>
    <tr>
        <td><a name="female_only">Female only</a></td>
        <td align="right">Go to:&nbsp<a href="#both_sex">Both</a>&nbsp&nbsp<a href="#male_only">Male</a>&nbsp&nbsp<a href="#difference">Difference</a></td>
    </tr>
    <tr>
        <td colspan="2">
            <div id="resizeF" style="width:980px; height:750px; padding: 10px; display: block">
                <div id='summary-chartF' name='summary-chartF' style="width:1000px; height:800px"></div>
            </div>
        </td>
    </tr>
    <tr>
        <td><a name="male_only">Male only</a></td>
        <td align="right">Go to:&nbsp<a href="#both_sex">Both</a>&nbsp&nbsp<a href="#female_only">Female</a>&nbsp&nbsp<a href="#difference">Difference</a></td>
    </tr>
    <tr>
        <td colspan="2">
            <div id="resizeM" style="width:980px; height:750px; padding: 10px; display: block">
                <div id='summary-chartM' name='summary-chartM' style="width:1000px; height:800px"></div>
            </div>
        </td>
    </tr>
    <tr>
        <td><a name="difference">Difference: Female - Male</a></td>
        <td align="right">Go to:&nbsp<a href="#both_sex">Both</a>&nbsp&nbsp<a href="#female_only">Female</a>&nbsp&nbsp<a href="#male_only">Male</a></td>
    </tr>
    <tr>
        <td colspan="2">
            <div id="resizeDiff" style="width:980px; height:750px; padding: 10px; display: block">
                <div id='summary-chartDiff' name='summary-chartDiff' style="width:1000px; height:800px"></div>
            </div>
        </td>
    </tr>
</table>

<script>
    var SWF_URL = "../plugins/ofchart-0.6.3/open-flash-chart.swf?60";
    var json_xofcdata;
    var xofcdata="";
    var cmoIDs = "'CMO:0000368','CMO:0000369','CMO:0000371','CMO:0000374','CMO:0000149','CMO:0000171','CMO:0000027'";
    var colType = ""
    var colIDs = "";

    function setOfcData(xdata) { // text jquery instead of prototype.load
        json_xofcdata=xdata;
        xofcdata=xdata;
    }
    function setOfcDataF(xdata) { // text jquery instead of prototype.load
        json_xofcdataF=xdata;
        xofcdataF=xdata;
    }
    function setOfcDataM(xdata) { // text jquery instead of prototype.load
        json_xofcdataM=xdata;
        xofcdataM=xdata;
    }
    function setOfcDataDiff(xdata) { // text jquery instead of prototype.load
        json_xofcdataDiff=xdata;
        xofcdataDiff=xdata;
    }
    function open_flash_chart_data1(id) {
        return xofcdata;
    }
    function open_flash_chart_data2(id) {
        return xofcdataF;
    }
    function open_flash_chart_data3(id) {
        return xofcdataM;
    }
    function open_flash_chart_data4(id) {
        return xofcdataDiff;
    }
    if (colType != "") {
        $.ajax({type:'POST', url:'../dataTable/twoOntoHeatMap',data:{'colType':colType, 'colIDs':colIDs, 'cmoIDs':cmoIDs, 'sex':'b'}, async:false, datatype:'text', success:function(msg){setOfcData(msg);}});
        $.ajax({type:'POST', url:'../dataTable/twoOntoHeatMap',data:{'colType':colType, 'colIDs':colIDs, 'cmoIDs':cmoIDs, 'sex':'f'}, async:false, datatype:'text', success:function(msg){setOfcDataF(msg);}});
        $.ajax({type:'POST', url:'../dataTable/twoOntoHeatMap',data:{'colType':colType, 'colIDs':colIDs, 'cmoIDs':cmoIDs, 'sex':'m'}, async:false, datatype:'text', success:function(msg){setOfcDataM(msg);}});
        $.ajax({type:'POST', url:'../dataTable/twoOntoHeatMapSexDiff',data:{'colType':colType, 'colIDs':colIDs, 'cmoIDs':cmoIDs}, async:false, datatype:'text', success:function(msg){setOfcDataDiff(msg);}});
        setTimeout(function() {swfobject.embedSWF(SWF_URL, "summary-chart", "100%", "100%","9.0.0", "expressInstall.swf", {"get-data":"open_flash_chart_data1","id":"#resize"});},550);
        setTimeout(function() {swfobject.embedSWF(SWF_URL, "summary-chartF", "100%", "100%","9.0.0", "expressInstall.swf", {"get-data":"open_flash_chart_data2","id":"#resizeF"});},550);
        setTimeout(function() {swfobject.embedSWF(SWF_URL, "summary-chartM", "100%", "100%","9.0.0", "expressInstall.swf", {"get-data":"open_flash_chart_data3","id":"#resizeM"});},550);
        setTimeout(function() {swfobject.embedSWF(SWF_URL, "summary-chartDiff", "100%", "100%","9.0.0", "expressInstall.swf", {"get-data":"open_flash_chart_data4","id":"#resizeDiff"});},550);
    } else {
        document.getElementById('heatmaptable').style.display='none';
        document.getElementById('hmurl').style.display='none';
    }

    function labelMouseHandler(type, axis, value) {
//        alert(type + " " + axis + " " + value);
    }

    function boxClickHandler(id, type, row, col) {
        if (type == "boxMouseClick")
        {
            if (id == '#resize') {
                $.ajax({type:'POST', url:'heatMapGivenCmoRs',data:{'rsTerm': col, 'cmoTerm': row, 'sex':'b'}, async:false, datatype:'text', success:function(msg){popupChart(msg);}});
            } else if (id == '#resizeF') {
                $.ajax({type:'POST', url:'heatMapGivenCmoRs',data:{'rsTerm': col, 'cmoTerm': row, 'sex':'f'}, async:false, datatype:'text', success:function(msg){popupChart(msg);}});
            } if (id == '#resizeM') {
            $.ajax({type:'POST', url:'heatMapGivenCmoRs',data:{'rsTerm': col, 'cmoTerm': row, 'sex':'m'}, async:false, datatype:'text', success:function(msg){popupChart(msg);}});
        }
        }
    }

    function popupChart(chartData) {
        $.ajax({type:'POST', url:'singleChart',data:{'chartData':chartData, 'width':$('#resize').width(), 'height':$('#resize').height()}, async:false, datatype:'text', success:function(msg){showPopup(msg, "a_win");}});
    }

    function showPopup(data, win_name) {
//        alert(xofcdata);
//        alert(data);
        var popup_win = window.open("", win_name, 'toolbar=no,location=no,status=no,menubar=no,resizeable=yes,scrollbars=no,resizable=yes,width=600,height=600');
        popup_win.document.write(data);
        popup_win.document.close();
        popup_win.focus();
    }

    function ofc_resize1(id, width, height)
    {
//        $(id).width(width);
        $(id).height(height);
    }
</script>


<%@ include file="/common/footerarea.jsp"%>
