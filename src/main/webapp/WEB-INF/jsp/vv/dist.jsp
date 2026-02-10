<%@ page import="edu.mcw.rgd.vv.SampleManager" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.web.UI" %>
<%@ page import="java.util.Map" %>
<%@ page import="edu.mcw.rgd.datamodel.VariantSearchBean" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%
    String pageTitle = "Variant Visualizer (Dist)";
    String headContent = "";
    String pageDescription = "Dist";

%>
<%@ include file="/common/headerarea.jsp" %>
<%
    VariantSearchBean vsb = (VariantSearchBean) request.getAttribute("vsb");
    int mapKey = (Integer) request.getAttribute("mapKey");

    Map<String, Map<String, Integer>> resultHash = (Map<String, Map<String, Integer>>) request.getAttribute("resultHash");
    Integer maxValue = (Integer) request.getAttribute("maxValue");
    List<String> sampleIds = (List<String>) request.getAttribute("sampleIds");
    List<String> regionList = (List<String>) request.getAttribute("regionList");

    int cellWidth = 24;
    int xMenuWidth = 135;
    int yMenuHeight = 100;

    int horizontalWidth = (cellWidth + 1) * regionList.size();
    int tableHeight = sampleIds.size() * cellWidth;

    String rdoColor = "#9F000F";
    String pwColor = "#6AA121";
    String mpColor = "#4B0082";
    String chebiColor = "#C58917";

    List<String> rdoGenes = (List<String>) request.getAttribute("rdoGenes");

    List<String> pwGenes = (List<String>) request.getAttribute("pwGenes");
    List<String> mpGenes = (List<String>) request.getAttribute("mpGenes");
    List<String> chebiGenes = (List<String>) request.getAttribute("chebiGenes");

%>
<style>
    #distTable td{
        max-width: 25px;

    }
    #distTable .container{
        padding-left: 0;
    }

</style>
<%@ include file="mapStyles.jsp" %>
<%@ include file="carpeHeader.jsp" %>

<%@ include file="menuBar.jsp" %>

<br>

<%
    boolean hasAnnotation = false;
    int annotationHeightAdjustment =0;
    if (!(req.getParameter("rdo_acc_id").equals("") && req.getParameter("pw_acc_id").equals("")
            && req.getParameter("mp_acc_id").equals("") && req.getParameter("chebi_acc_id").equals(""))) {
        hasAnnotation = true;
        annotationHeightAdjustment=25;

    }



%>


<style>
    .dist-instructions {
        background: #e8f4fc;
        border-left: 4px solid #3a7aba;
        padding: 12px 15px;
        margin: 15px 20px 15px 20px;
        border-radius: 0 4px 4px 0;
        color: #2a4a6a;
        font-size: 13px;
        line-height: 1.5;
    }
</style>

<div class="typerMat" id="blueBackground">
    <div class="typerTitle">
        <div class="typerTitleSub">Variant Distribution</div>
    </div>

    <table width="100%" class="stepLabel" cellpadding=0 cellspacing=0>
        <tr>
            <td>Select a gene or region to view the visual haplotype</td>
            <td align="right"><%=MapManager.getInstance().getMap(mapKey).getName()%> assembly</td>
        </tr>
    </table>

    <div class="dist-instructions">
        The table below displays <strong>variant counts</strong> for each gene and intergenic region in your selected strains.
        Click any cell to view detailed variant information for that region.
    </div>


    <% if (req.getParameter("geneList").equals("")) { %>

    <% int positionCount = regionList.size(); %>
    <%@ include file="updateForm.jsp" %>

    <% } %>

    <% if (regionList.size() == 0) { %>
    <style>
        .no-results-container {
            max-width: 600px;
            margin: 40px auto;
            padding: 0 20px 40px 20px;
        }
        .no-results-card {
            background: #ffffff;
            border: 1px solid #ccd9e8;
            border-radius: 8px;
            padding: 40px;
            text-align: center;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        .no-results-icon {
            font-size: 48px;
            color: #6c757d;
            margin-bottom: 20px;
        }
        .no-results-title {
            font-size: 24px;
            font-weight: bold;
            color: #1a3a5a;
            margin-bottom: 12px;
        }
        .no-results-message {
            font-size: 15px;
            color: #5a6a7a;
            margin-bottom: 25px;
            line-height: 1.6;
        }
        .no-results-suggestions {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            padding: 20px;
            margin-bottom: 25px;
            text-align: left;
        }
        .no-results-suggestions-title {
            font-size: 14px;
            font-weight: 600;
            color: #1a3a5a;
            margin-bottom: 12px;
        }
        .no-results-suggestions ul {
            margin: 0;
            padding-left: 20px;
            color: #4a5a6a;
            font-size: 14px;
        }
        .no-results-suggestions li {
            margin-bottom: 8px;
        }
        .no-results-buttons {
            display: flex;
            justify-content: center;
            gap: 15px;
            flex-wrap: wrap;
        }
        .btn-adjust-search {
            font-size: 14px;
            font-weight: bold;
            background: linear-gradient(to bottom, #3a7aba 0%, #2a5a8a 100%);
            color: white;
            border: 1px solid #2a5a8a;
            border-radius: 6px;
            padding: 12px 24px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
        }
        .btn-adjust-search:hover {
            background: linear-gradient(to bottom, #4a8aca 0%, #3a7aba 100%);
            transform: translateY(-1px);
            box-shadow: 0 3px 6px rgba(0,0,0,0.15);
            color: white;
            text-decoration: none;
        }
        .btn-change-region {
            font-size: 14px;
            font-weight: bold;
            background: linear-gradient(to bottom, #6c757d 0%, #545b62 100%);
            color: white;
            border: 1px solid #545b62;
            border-radius: 6px;
            padding: 12px 24px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: all 0.2s ease;
        }
        .btn-change-region:hover {
            background: linear-gradient(to bottom, #7a8288 0%, #6c757d 100%);
            transform: translateY(-1px);
            box-shadow: 0 3px 6px rgba(0,0,0,0.15);
            color: white;
            text-decoration: none;
        }
    </style>

    <div class="no-results-container">
        <div class="no-results-card">
            <div class="no-results-icon">&#128269;</div>
            <div class="no-results-title">No Variants Found</div>
            <div class="no-results-message">
                Your search did not return any variants in the specified region with the current filter settings.
            </div>
            <div class="no-results-suggestions">
                <div class="no-results-suggestions-title">Try the following:</div>
                <ul>
                    <li>Remove or adjust filter options to broaden your search</li>
                    <li>Increase the region size to include more genomic positions</li>
                    <li>Select different strains that may have more variant data</li>
                    <li>Check that the chromosome and coordinates are correct</li>
                </ul>
            </div>
            <div class="no-results-buttons">
                <a class="btn-adjust-search" href="config.html?<%=request.getQueryString()%>">Adjust Filter Options</a>
                <a class="btn-change-region" href="region.html?<%=request.getQueryString()%>">Change Region</a>
            </div>
        </div>
    </div>

    <% return;
    } %>


    <table border=0 cellpadding=0 cellspacing=0 align="center"
           style="border: 4px outset #eeeeee; background-color:white; padding-top:15px;  padding-bottom:20px; margin-top: 10px;margin-bottom:10px;">

        <tr>
            <td valign=top>
                <table border=0 class="snpHeader" align="center" cellpadding=0 cellspacing=0 style="padding-top: 1px;">
                    <tr>
                        <td><img src="/rgdweb/common/images/dot_clear.png" height=25/></td>
                        <td valign="top" style="height:<%=yMenuHeight -1  + annotationHeightAdjustment%>px; background-color:white;">
                            <table width="<%=xMenuWidth -5%>" border=0 style="background-color:white;">
                                <tr>
                                    <td><img src="/rgdweb/common/images/dot_clear.png" height=15/></td>
                                </tr>
                                <tr>
                                    <td align="center" style="background-color:white;"><img src="/rgdweb/common/images/rgd.png"/>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    <%
                        int j = 0;
                        int k = 0;
                        Iterator it = sampleIds.iterator();
                        while (it.hasNext()) {
                            j++;
                            String sample = String.valueOf( it.next());
                    %>
                    <tr>

                        <td><img src="/rgdweb/common/images/dot_clear.png" height=25/></td>
                        <td valign="center">
                            <div class="snpLabel" style="height: 25px">
                                <!--form action="dist.html" method="post" target="_blank" -->
                                    <%if(request.getParameter("geneList")!=null){%>
                                    <input type="hidden" name="geneList" value="<%=request.getParameter("geneList")%>"/>
                                    <%}%>
                                    <input type="hidden" name="sample1" value="<%=sample%>"/>
                                    <%if(request.getParameter("mapKey")!=null){%>
                                    <input type="hidden" name="mapKey" value="<%=request.getParameter("mapKey")%>"/>
                                    <%}%>
                                    <%if(request.getParameter("start")!=null){%>
                                    <input type="hidden" name="start" value="<%=request.getParameter("start")%>"/>
                                    <%}%>
                                    <%if(request.getParameter("stop")!=null){%>
                                    <input type="hidden" name="stop" value="<%=request.getParameter("stop")%>"/>
                                    <%}%>
                                    <%if(request.getParameter("chr")!=null){%>
                                    <input type="hidden" name="chr" value="<%=request.getParameter("chr")%>"/>
                                    <%}%>
                                    <%if(request.getParameter("showDifferences")==null || !request.getParameter("showDifferences").equals("true")){%>
                                    <button class="button" type="submit" style="border:0;font-size: 10px"><%=SampleManager.getInstance().getSampleName(Integer.parseInt(sample)).getAnalysisName()%></button>
                                    <%}else{%>
                                    <p><%=SampleManager.getInstance().getSampleName(Integer.parseInt(sample)).getAnalysisName()%></p>
                                    <%}%>
                                <!--/form-->
                                <!--a style="cursor:default;"
                                                     title="<--%=SampleManager.getInstance().getSampleName(Integer.parseInt(sample)).getAnalysisName()%>"
                                                     href="javascript:navigate('<-%=request.getParameter("geneList")%>', <-%=sample%>);"><-%=SampleManager.getInstance().getSampleName(Integer.parseInt(sample)).getAnalysisName()%-->
                                <!--/a-->&nbsp;</div>
                        </td>
                    </tr>
                    <% } %>

                </table>
            </td>
            <td>
                <%
                    int divWidth = horizontalWidth + 50;
                %>

                <script>
                    document.getElementById("blueBackground").style.height =
                    <%=tableHeight + 500 + sampleIds.size()%>
                </script>

                <div id="wrapperRegion"
                     style="overflow:auto; width:<%=divWidth%>px; height:<%=tableHeight + 145 + sampleIds.size()%>; top: -1; position: relative;">

                    <table id="distTable" cellpadding=0 cellspacing=0 border=0 style="background-color: #eeeeee;">

                        <tr>
                            <%

                                Iterator genesIt = regionList.iterator();
                                while (genesIt.hasNext()) {

                                    String region = (String) genesIt.next();
                                    String displayRegion = "";
                                    displayRegion += region;
                                    if (region.contains("|")) {

                                        if (regionList.size() == 1) {
                                            displayRegion = "intergenic";
                                        } else {
                                            displayRegion = "";
                                        }

                                    }


                            %>
                            <td height=100>
                                <div class="iewrap">
                                    <div class="container">
                                        <div class="head" style="border-left: 2px solid white;min-width:<%=cellWidth%>">
                                            <div id="h" class="vert">

                                                &nbsp;<a title="<%=region%>"
                                                         href="javascript:navigate('<%=region%>', '');"><%=displayRegion%>
                                            </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </td>

                            <%
                                }
                            %>
                        </tr>

                        <%
                            j = 0;
                            k = 0;
                            it = sampleIds.iterator();

                            while (it.hasNext()) {%>
                        <tr>
                            <%      String sample = String.valueOf( it.next());
                                Map<String, Integer> results = (Map<String, Integer>) resultHash.get(sample);
                                if (results == null) {
                                    results = Collections.emptyMap();
                                }

                                Iterator pit = regionList.iterator();
                                while (pit.hasNext()) {
                                    String region = (String) pit.next();

                                    Integer count = results.get(region.toLowerCase());
                                    if (count == null) {
                                        count=results.get(region);
                                        if(count==null)
                                            count = 0;
                                    }
                                    String color = UI.getRGBValue(count, maxValue);
                                    String fontColor = "black";

                                    if ((double) count / maxValue > .5) {
                                        fontColor = "white";
                                    }

                                    String cursor = "default";
                                    if (count > 0) {
                                        cursor = "pointer";
                                    }

                            %>
                            <td width=24 height=25>
                                <div id="cell<%=k%>-<%=j%>" class="heatCell"
                                     style="cursor: <%=cursor%>; color: <%=fontColor%>; background-color:<%=color%>; vertical-align: middle; display:table-cell;"><%=count%>
                                </div>
                            </td>

                            <script>
                                document.getElementById("cell<%=k%>-<%=j%>").gene = "<%=region%>";
                                <%if(req.getParameter("showDifferences")==null || !req.getParameter("showDifferences").equals("true")){%>
                                document.getElementById("cell<%=k%>-<%=j%>").sample = "<%=sample%>";
                                <%}else{%>
                                document.getElementById("cell<%=k%>-<%=j%>").sample = "";
                                <% }%>
                                document.getElementById("cell<%=k%>-<%=j%>").onclick = showVariants;
                            </script>
                            <%k++;%>
                            <% } %>

                        </tr>
                        <% j++; %>
                        <% } %>
                    </table>
                </div>
            </td>
        </tr>
    </table>

</div>


<br><br>

<script>

    window.onload = checkWidth;
    window.onresize = checkWidth;

    function getWidth() {
        return window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth || 0;
    }
    function getHeight() {
        return window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight || 0;
    }

    function checkWidth() {
        var newWidth = getWidth() - 230;
        var divWidth = <%=divWidth%>;

        if (divWidth > newWidth) {
            document.getElementById("wrapperRegion").style.width = newWidth;
        }
    }
</script>

<%@ include file="/common/footerarea.jsp" %>