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


    <% if (req.getParameter("geneList").equals("")) { %>

    <% int positionCount = regionList.size(); %>
    <%@ include file="updateForm.jsp" %>

    <% } %>

    <% if (regionList.size() == 0) { %>
    <br>
    <table align="center">
        <tr>
            <td colspan=2 align=center style="font-size:20px; color:white;font-weight:700">O SNPs Found<br>(Please remove options or increase your region size)</td>
        </tr>
    </table>

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