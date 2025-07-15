<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.vv.SampleManager" %>
<%@ page import="edu.mcw.rgd.web.UI" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="edu.mcw.rgd.datamodel.MappedGene" %>
<%@ page import="edu.mcw.rgd.process.describe.DescriptionGenerator" %>

<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.vv.SNPlotyper" %>
<%@ page import="edu.mcw.rgd.datamodel.VariantSearchBean" %>
<%@ page import="edu.mcw.rgd.datamodel.VariantResult" %>
<%@ page import="edu.mcw.rgd.util.Zygosity" %>
<%@ page import="java.io.StreamCorruptedException" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%
    String pageTitle = "Variant Visualizer (Variants)";
    String headContent = "";
    String pageDescription = "View the Variants of selected position or genes";

%>
<%@ include file="/common/headerarea.jsp" %>
<%
    try {

%>
<link rel="stylesheet" href="/rgdweb/js/javascriptPopUpWindow/GAdhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/rgdweb/js/javascriptPopUpWindow/dhtmlwindow.js">
</script>
<style>
    #colTable td{
        max-width: 25px;

    }
    #colTable .container{
        padding-left: 0;
    }

</style>
<%

    HashMap backColors = new HashMap();

    backColors.put("A","#0A224E");
    backColors.put("A/A","#0A224E");
    backColors.put("A/T","#652D34");
    backColors.put("T/A","#652D34");
    backColors.put("A/C","#557DA0");
    backColors.put("C/A","#557DA0");
    backColors.put("A/G","#754C3B");
    backColors.put("G/A","#754C3B");

    backColors.put("T","#BF381A");
    backColors.put("T/T","#BF381A");
    backColors.put("T/C","#B08886");
    backColors.put("C/T","#B08886");
    backColors.put("T/G","#D05721");
    backColors.put("G/T","#D05721");

    backColors.put("C","#A0D8F1");
    backColors.put("C/C","#A0D8F1");
    backColors.put("C/G","#C0A78D");
    backColors.put("G/C","#C0A78D");

    backColors.put("G","#E07628");
    backColors.put("G/G","#E07628");
    backColors.put("het", "#E9AF32");
    backColors.put("-", "purple");
    backColors.put("?", "black");

    for (int i=1; i< 1000; i++) {
        backColors.put(i + "","pink");
    }


    HashMap fontColors = new HashMap();

    fontColors.put("A","white");
    fontColors.put("A/A","white");
    fontColors.put("T","white");
    fontColors.put("T/T","white");
    fontColors.put("C","black");
    fontColors.put("C/C","black");
    fontColors.put("G","white");
    fontColors.put("G/G","white");
    fontColors.put("het", "black");
    fontColors.put("-", "white");
    fontColors.put("?", "white");

    for (int i=1; i< 1000; i++) {
        fontColors.put(i + "","black");
    }


    SNPlotyper snplotyper = (SNPlotyper) request.getAttribute("snplotyper");
    VariantSearchBean vsb = (VariantSearchBean) request.getAttribute("vsb");

    Set positions = snplotyper.getPositions();
    List samples = snplotyper.getSamples();

    int mapKey=vsb.getMapKey();
    int cellWidth=24;
    int xMenuWidth=135;
    int yMenuHeight=90;

    int horizontalWidth=(cellWidth +1) * snplotyper.getPositions().size();
    int tableHeight = snplotyper.getSamples().size() * cellWidth;
    int heightOfOptionalGeneTracks = 0;
%>

<%@ include file="mapStyles.jsp"%>

<%
    boolean overviewMap = true;
%>



<script>
    function getTarget(e) {
        return document.all ? e.srcElement : e.currentTarget;
    }

    function displayVariant(e) {
        if (!e) e = window.event;
        var firedDiv = getTarget(e);
        var url = "/rgdweb/front/detail.html?chr=<%=vsb.getChromosome()%>&start=" + firedDiv.pos + "&stop=" + (parseInt(firedDiv.pos) + 1) + "&sid=" + firedDiv.sid + "&vid=" + firedDiv.vid + "&mapKey=<%=vsb.getMapKey()%>";
        var googlewin=dhtmlwindow.open("ajaxbox", "ajax", url,"Variant Details", "width=740px,height=400px,resize=1,scrolling=1,center=1", "recal");
        document.getElementById("ajaxbox").scrollTop=0;
    }
</script>



<%@ include file="carpeHeader.jsp"%>
<%
    geneList=snplotyper.getCommaDelimitedGeneSymbolList();
%>
<%@ include file="menuBar.jsp"%>
<br>

<div id="blueBackground" style="padding:15px;background-image: url(/rgdweb/common/images/bg3.png);height:100%">
    <%
        int positionCount = snplotyper.getPositions().size();
    %>

    <%@ include file="updateForm.jsp"%>


    <%
        Gene gene = (Gene) request.getAttribute("gene");
        DescriptionGenerator dg = new DescriptionGenerator();
        if (gene != null) {
    %>
    <table align="center" width="100%" cellpading=0 cellspacing=0 style="background-color:#EEEEEE;">
        <tr>
            <td align="center">
                <div style="font-size:12px; padding: 6px; color:#063968;">
                    <span style=" font-weight:700; font-size:12px;"><%=gene.getSymbol()%></span> : <%=dg.buildDescription(gene.getRgdId())%>
                </div>
            </td>
        </tr>
    </table>
        <%
            }
        %>


    <%
        if (positions.size()==0) {
    %>
    <br>
    <table align="center">
        <tr>
            <td colspan=2 align=center style="font-size:20px; color:white;font-weight:700">O SNPs Found<br>(Please remove options or increase your region size)</td>
        </tr>
    </table>

    <%
    } else {
    %>


    <style>
        #mainTable td {
        <!--font-size:5px;-->
        }
        
        /* Custom scrollbar styles for better visibility */
        #topScrollWrapper::-webkit-scrollbar,
        #wrapperRegion::-webkit-scrollbar {
            height: 16px;
            background-color: #f0f0f0;
        }
        
        #topScrollWrapper::-webkit-scrollbar-track,
        #wrapperRegion::-webkit-scrollbar-track {
            background: #e0e0e0;
            border: 1px solid #ccc;
            border-radius: 8px;
        }
        
        #topScrollWrapper::-webkit-scrollbar-thumb,
        #wrapperRegion::-webkit-scrollbar-thumb {
            background: #2865A3;
            border-radius: 8px;
            border: 2px solid #e0e0e0;
        }
        
        #topScrollWrapper::-webkit-scrollbar-thumb:hover,
        #wrapperRegion::-webkit-scrollbar-thumb:hover {
            background: #1e4a7a;
        }
        
        /* Firefox scrollbar styles */
        #topScrollWrapper,
        #wrapperRegion {
            scrollbar-width: thick;
            scrollbar-color: #2865A3 #e0e0e0;
        }
        
        /* Add border to make scroll areas more visible */
        #topScrollWrapper {
            border: 2px solid #2865A3;
            border-radius: 4px;
            background-color: #f5f5f5;
        }
        
        #wrapperRegion {
            border: 2px solid #2865A3;
            border-top: none;
            border-radius: 0 0 4px 4px;
        }
    </style>



    <table id="mainTable" border=0 cellpadding=0 cellspacing=0 align="center" style="z-index:2; border:  4px outset #eeeeee;  background-color:white; padding-top:10px;  padding-bottom:20px; margin-top: 10px;margin-bottom:10px;">
        <tr>
            <td valign=top>
                <table class="snpHeader" align="center" cellpadding=0 cellspacing=0 style="border-top:1px solid white; margin-top:17px;">
                    <%   if(mapKey != 631 && mapKey != 372) { %>
                    <tr>
                        <td><img src="/rgdweb/common/images/dot_clear.png" height=25 /></td>
                        <td width="<%=xMenuWidth%>" ><div style="border-top:1px solid #E8E4D5;" class="snpLabel">Conservation&nbsp;</div></td>
                    </tr>
                    <%   } %>
                    <tr>
                        <td><img src="/rgdweb/common/images/dot_clear.png" alt="" height=25/></td>
                        <td ><div class="snpLabel">Genes <span style="color:blue;">( + )</span>&nbsp;</div></td>
                    </tr>
                    <% if (snplotyper.hasPlusStrandConflict()) {
                        heightOfOptionalGeneTracks+=25;
                    %>
                    <tr>
                        <td><img src="/rgdweb/common/images/dot_clear.png" alt="" height=25/></td>
                        <td ><div class="snpLabel">Genes <span style="color:blue;">( + )</span>&nbsp;</div></td>
                    </tr>
                    <% } %>
                    <tr>
                        <td><img src="/rgdweb/common/images/dot_clear.png" alt="" height=25/></td>
                        <td ><div class="snpLabel">Genes <span style="color:red;">( - )</span>&nbsp;</div></td>
                    </tr>
                    <% if (snplotyper.hasMinusStrandConflict()) {
                        heightOfOptionalGeneTracks+=25;
                    %>
                    <tr>
                        <td><img src="/rgdweb/common/images/dot_clear.png" alt="" height=25/></td>
                        <td ><div class="snpLabel">Genes <span style="color:red;">( - )</span>&nbsp;</div></td>
                    </tr>
                    <% } %>

                    <tr>
                        <td><img src="/rgdweb/common/images/dot_clear.png" alt="" height=25/></td>
                        <td ><div class="snpLabel">
                            <%if (mapKey==60) out.print("RGSC 3.4");%>
                            <%if (mapKey==70) out.print("Rnor 5.0");%>
                            <%if (mapKey==360) out.print("Rnor 6.0");%>
                            <%if (mapKey==372) out.print("mRatBN7.2");%>
                            <%if (mapKey==17) out.print("GRCh37");%>
                            &nbsp;</div></td>
                    </tr>
                    <tr>
                        <td><img src="/rgdweb/common/images/dot_clear.png" alt="" height=26/></td>
                        <td valign="center" style="height:<%=yMenuHeight + 10 %>px; background-color:white;">
                            <table width="<%=xMenuWidth -5%>" border=0 style="background-color:white; ">
                                <tr>
                                    <td align="center" style="background-color:white;"><img src="/rgdweb/common/images/rgd.png" /></td>
                                </tr>
                            </table>
                        </td>
                    </tr>

                    <%
                        int j=0;
                        int k=0;
                        Iterator it = samples.iterator();
                        while(it.hasNext()) {
                            int sample = (Integer) it.next();
                            String sampleAnalysisName=SampleManager.getInstance().getSampleName(sample).getAnalysisName();
                            String sampleName=null;
                            if(sampleAnalysisName.toLowerCase().contains("european")){
                                sampleName="EVA Release " + sampleAnalysisName.substring(sampleAnalysisName.length()-1);
                            }else sampleName=sampleAnalysisName;
                    %>
                    <tr>

                        <td><img src="/rgdweb/common/images/dot_clear.png" height=25/></td>
                        <td  valign="center">
                            <div class="snpLabel"><a style="text-decoration:none;" title="<%=sampleAnalysisName%>" href="javascript:void(0);"><%=sampleName%></a>&nbsp;</div>
                        </td>
                    </tr>
                    <% } %>

                </table>
                <%
                    } //end else
                %>

            </td>
            <td>
                <script></script>

                <%
                    int divWidth= horizontalWidth;

                %>




                <script>
                    document.getElementById("blueBackground").style.height=<%=tableHeight + 500 + heightOfOptionalGeneTracks%>
                    // alert("set height to " + document.getElementById("blueBackground").style.height) ;
                </script>

                <!-- Top scroll bar -->
                <div id="topScrollWrapper" style="margin-right:20px; overflow-x:scroll; overflow-y:hidden; width:<%=divWidth%>px; height:20px; margin-bottom:2px;">
                    <div style="height:1px; width:<%=horizontalWidth%>px;"></div>
                </div>

                <div id="wrapperRegion" style="margin-right:20px; overflow-x:scroll; width:<%=divWidth%>px; height:<%=tableHeight + 250 + samples.size() + heightOfOptionalGeneTracks%>">
                    <%
                        Iterator cit;
                    %>
                    <table id="colTable" cellpadding=0 cellspacing=0 border=0 style="background-color: #eeeeee; border-top:1px solid #E8E4D5;">
                        <tr>
                            <%
                                if(mapKey != 631 && mapKey != 372) {
                                    cit = snplotyper.getPositions().iterator();
                                    while (cit.hasNext()) {
                                        long pos = (Long) cit.next();

                                        BigDecimal score = snplotyper.getConservation(pos);
                                        int colorVal = score.multiply(new BigDecimal("1000")).intValue();

                                        String fontColor="black";
                                        if (colorVal > 500) {
                                            fontColor="white";
                                        }

                                        String con =score.toString().replace("0.",".");

                                        if (con.equals("-1") ) {
                                            con = "--";

                                        }

                            %>

                            <td style="font-size:10px;"><div class="conCell" style="color:<%=fontColor%>;background-color:<%=UI.getRGBValue(colorVal, 1000)%>"><%=con%></div></td>

                            <%
                                    }
                                }
                            %>

                            <td></td>
                        </tr>


                        <tr>
                            <%
                                cit = snplotyper.getPositions().iterator();
                                String currentGene = "";

                                TreeMap<Long, MappedGene> overflow = new TreeMap();
                                HashSet ignore = new HashSet();

                                while (cit.hasNext()) {
                                    long pos = (Long) cit.next();
                                    List<MappedGene> mgList = snplotyper.getPlusStrandGene(pos);

                                    Gene g = null;

                                    if (mgList.size() > 1) {

                                        int index1=0;
                                        int index2 = 1;

                                        if (ignore.contains(mgList.get(index1).getGene().getRgdId())) {
                                            index1=1;
                                            index2 = 0;
                                        }

                                        overflow.put(pos, mgList.get(index2));
                                        ignore.add(mgList.get(index2).getGene().getRgdId());
                                        g = mgList.get(index1).getGene();
                                    }else if (mgList.size()==1) {
                                        if (!ignore.contains(mgList.get(0).getGene().getRgdId())) {
                                            g = mgList.get(0).getGene();
                                        }
                                    }
                                    String uniqueId="plus";
                            %>
                            <%@ include file="trackHelper.jsp"%>

                            <%
                                }
                            %>
                            <td></td>
                        </tr>


                        <!-- plus overflow  -->
                            <% if (snplotyper.hasPlusStrandConflict()) { %>

                        <tr>
                            <%
                                cit = snplotyper.getPositions().iterator();
                                currentGene = "";
                                while (cit.hasNext()) {
                                    long pos = (Long) cit.next();
                                    MappedGene mg = overflow.get(pos);

                                    Gene g = null;

                                    if (mg != null) {
                                        g = mg.getGene();

                                    }
                                    String uniqueId="poverflow";
                            %>
                            <%@ include file="trackHelper.jsp"%>

                            <%
                                }
                            %>
                            <td></td>
                        </tr>
                            <% }%>

                        <!-- minus strand -->

                        <tr>
                            <%
                                cit = snplotyper.getPositions().iterator();
                                currentGene = "";

                                overflow = new TreeMap();
                                ignore = new HashSet();

                                while (cit.hasNext()) {
                                    long pos = (Long) cit.next();
                                    List<MappedGene> mgList = snplotyper.getMinusStrandGene(pos);

                                    Gene g = null;

                                    if (mgList.size() > 1) {
                                        //check to make sure neither are already in overflow

                                        int index1=0;
                                        int index2 = 1;

                                        if (ignore.contains(mgList.get(index1).getGene().getRgdId())) {
                                            index1=1;
                                            index2 = 0;
                                        }

                                        overflow.put(pos, mgList.get(index2));
                                        ignore.add(mgList.get(index2).getGene().getRgdId());
                                        g = mgList.get(index1).getGene();

                                    }else if (mgList.size()==1) {
                                        if (!ignore.contains(mgList.get(0).getGene().getRgdId())) {
                                            g = mgList.get(0).getGene();
                                        }
                                    }
                                    String uniqueId="minus";
                            %>
                            <%@ include file="trackHelper.jsp"%>

                            <%
                                }
                            %>
                            <td></td>
                        </tr>


                        <!-- minus overflow  -->
                            <% if (snplotyper.hasMinusStrandConflict()) { %>

                        <tr>
                            <%
                                cit = snplotyper.getPositions().iterator();
                                currentGene = "";
                                while (cit.hasNext()) {
                                    long pos = (Long) cit.next();
                                    MappedGene mg = overflow.get(pos);

                                    Gene g = null;
                                    if (mg != null) {
                                        g = mg.getGene();
                                    }
                                    String uniqueId="moverflow";
                            %>
                            <%@ include file="trackHelper.jsp"%>

                            <% } %>
                            <td></td>
                        </tr>
                            <% }%>

                        <tr>
                            <%

                                cit = snplotyper.getPositions().iterator();

                                while (cit.hasNext()) {
                                    long pos = (Long) cit.next();
                                    String score = snplotyper.getRefNuc(pos) + "";

                                    String backColor="#E8E4De";
                                    String fontColor="black";
                                    int border=1;
                                    if (snplotyper.isInExon(pos)) {
                                        backColor="#42433E";
                                        fontColor = "white";
                                        border=0;
                                    }

                                    if (score.length() > 1 && !score.equalsIgnoreCase("null")) {
                                        score = score.length() + "";
                                    }
                                    if(score.equalsIgnoreCase("null")){
                                        score="-";
                                    }
                            %>
                            <td style="font-size:9px;"><div class="conCell" style="border-top: <%=border%>px solid white;color:<%=fontColor%>; background-color:<%=backColor%>;" ><%=score%></div></td>
                            <%
                                }
                            %>

                            <td></td>
                        </tr>

                        <tr>
                            <%  Iterator kit = positions.iterator();
                                while (kit.hasNext() ) {
                                    long key = (Long) kit.next(); %>

                            <td height=100>
                                <div class="iewrap">
                                    <div class="container">
                                        <div class="head" style="border-right: 1px solid white;min-width:<%=cellWidth%>">
                                            <div id="h" class="vert" style="font-family:arial;">
                                                &nbsp;&nbsp;<%=Utils.formatThousands((int) key)%>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </td>
                            <% } %>
                        </tr>

                            <%
         int j=0;
         int k=0;
         Iterator it = samples.iterator();
        while(it.hasNext()) {
            int sample = (Integer) it.next();
        %>
                        <tr>

                                <%

            Iterator pit = positions.iterator();
            while (pit.hasNext()) {
                    long pos = (Long) pit.next();

                    List<VariantResult> varients = snplotyper.getNucleotide(sample,pos);

                    String variantID="";
                    if (varients.size() ==0) {
                        String base = Utils.NVL(snplotyper.getRefNuc(pos), "");
                        if (base.length() > 1) {
                            base = base.length() + "";
                        }
                    %>
                            <td  width=24 height=10><div id="cell<%=k%>-<%=j%>" class="heatCell" style="cursor: auto; color: black; background-color:#E8E4D5;vertical-align: middle;">-</div></td>
                                <%
                    }  else {
                    %>
                            <td valign="center" width=24 height=10 ><div id="cell<%=k%>-<%=j%>" class="heatCell" style="color:white; cursor: pointer; background-color:#96151D" >

                                    <%
                    int count=0;

                    String zygosity = null;
                    String var = "";
                    for (VariantResult vr: varients) {

                         if (variantID.equals("")) {
                             variantID += vr.getVariant().getId();
                         }else {
                             variantID += "|" + vr.getVariant().getId();

                         }

                         if (count > 0 ) {
                            var +="/";
                         }

                         if (vr.getVariant().getVariantType() != null && (vr.getVariant().getVariantType().equals("del") || vr.getVariant().getVariantType().equals("deletion")) ) {
                            var="-";
                         //}else if (vr.getVariant().getVariantType() != null && vr.getVariant().getVariantType().equals("ins")) {
                         //   var="+";
                         }else {
                             if (var.length() > 2) {
                                var = var.length() + "";
                             }
                             else{
                                var += vr.getVariant().getVariantNucleotide();
                             }
                         }

                         if (var.length() > 1) {
                            var = var.length() + "";
                         }

                         if (varients.size() > 1) {
                            var = "?";
                         }
                         if (varients.size() == 2) {
                            VariantResult vr1 = varients.get(0);
                            VariantResult vr2 = varients.get(1);
                            var = "";
                            if (vr1.getVariant().getVariantNucleotide() != null && vr1.getVariant().getVariantNucleotide().length()>2){
                                var += vr1.getVariant().getVariantNucleotide().length() + "/";
                            }
                            else {
                                var += vr1.getVariant().getVariantNucleotide() + "/";
                            }
                            if (vr2.getVariant().getVariantNucleotide() != null && vr2.getVariant().getVariantNucleotide().length()>2){
                                var += vr2.getVariant().getVariantNucleotide().length();
                            }
                            else {
                                var += vr2.getVariant().getVariantNucleotide();
                            }
//                            var = vr1.getVariant().getVariantNucleotide() + "/" + vr2.getVariant().getVariantNucleotide();

                         }

                         count++;

                         if (varients.size()==1 && vr.getVariant().getZygosityStatus() != null ) {
                            if (vr.getVariant().getZygosityStatus().equals(Zygosity.HETEROZYGOUS) ) {
                               String refNuc = Utils.NVL(snplotyper.getRefNuc(pos), "-");
                               String newVar;
                               if (refNuc.length() > 1) {
                                    newVar = refNuc.length() + "/" + var;
                               }else {
                                    newVar = refNuc + "/" + var;
                               }
                               var = newVar;
                            }else  if (vr.getVariant().getZygosityStatus().equals(Zygosity.HOMOZYGOUS) || vr.getVariant().getZygosityStatus().equals(Zygosity.POSSIBLY_HOMOZYGOUS) ) {
                               //var += "/" + var;
                            }
                         }

                        %>

                                    <% }var = var.replace("null", "-"); %>
                                    <%=var%>
                            </td>

                </div>

                <%
                    String backColor= (String) backColors.get("het");
                    String fontColor=(String) fontColors.get("het");

                    if (backColors.containsKey(var)) {
                        backColor= (String) backColors.get(var);
                        fontColor=(String) fontColors.get(var);
                    }

                %>

                <script>
                    document.getElementById('cell<%=k%>-<%=j%>').onclick=displayVariant;
                    document.getElementById('cell<%=k%>-<%=j%>').pos=<%=pos%>;
                    document.getElementById('cell<%=k%>-<%=j%>').vid='<%=URLEncoder.encode(variantID,StandardCharsets.UTF_8)%>';
                    document.getElementById('cell<%=k%>-<%=j%>').sid=<%=sample%>;
                    document.getElementById('cell<%=k%>-<%=j%>').style.backgroundColor="<%=backColor%>";
                    document.getElementById('cell<%=k%>-<%=j%>').style.color="<%=fontColor%>";
                </script>

                <% } %>
            </td>
            <% k++;
            } %>
        </tr>
        <%  j++;
        } %>

    </table>
</div>


</td>
</tr>
</table>







<br><br>


<script>
    function showOverview() {
        document.getElementById("overview").style.display="block";
    }
    function closeOverview() {
        document.getElementById("overview").style.display="none";
    }
</script>


<div align="center" id="overview" style="border:5px outset black; position:absolute;top:150; left:30; display:none; background-color:#ffffff;padding-top:5px; padding-bottom:25px; width:1000px;">
    <div style="background-color:#771428; margin: 3px;">
        <table width="100%" cellpadding=0 cellspacing=0><tr><td align="right"><a href="javascript:closeOverview();"><img src="/rgdweb/js/windowfiles/close.gif" height=15 width=15/></a>&nbsp;&nbsp;&nbsp;</td></tr></table>
    </div>
    <div id="overview-region" style="width:2000; padding-top:10px; overflow: auto; " >

        <%
            j=0;
            k=0;
            it = samples.iterator();
            int cnt = 0;
            while(it.hasNext()) {
                int sample = (Integer) it.next();
        %>
        <div id="row<%=cnt++%>" style="border:0px solid #EEEEEE; clear:both; height:8px; width:<%=(positions.size() * 5)%>;">
            <%

                Iterator pit = positions.iterator();
                while (pit.hasNext()) {
                    long pos = (Long) pit.next();

                    List<VariantResult> varients = snplotyper.getNucleotide(sample,pos);

                    String variantID="";
                    if (varients.size() ==0) {

            %>
            <div id="dcell<%=k%>-<%=j%>" lass="heatCell" style="height:6px; width:5px; cursor: auto; color: black; background-color:#E8E4D5;vertical-align: middle; float:left; font-size:8px; border-right:0px solid white;"></div>
            <%
            }  else {
            %>
            <div id="dcell<%=k%>-<%=j%>" lass="heatCell" style="height:6px; width:5px; color:white; cursor: pointer; background-color:#96151D; vertical-align: middle; float:left; font-size:8px; border-right:0px solid white;">

                <%
                    int count=0;

                    String zygosity = null;
                    String var = "";
                    for (VariantResult vr: varients) {

                        if (variantID.equals("")) {
                            variantID += vr.getVariant().getId();
                        }else {
                            variantID += "|" + vr.getVariant().getId();

                        }

                        if (count > 0 ) {
                            var +="/";
                        }

                        var += vr.getVariant().getVariantNucleotide();

                        count++;


                        if (varients.size()==1 && vr.getVariant().getZygosityStatus() != null ) {
                            if (vr.getVariant().getZygosityStatus().equals(Zygosity.HETEROZYGOUS) ) {
                                var +="/" + snplotyper.getRefNuc(pos);
                            }else  if (vr.getVariant().getZygosityStatus().equals(Zygosity.HOMOZYGOUS) || vr.getVariant().getZygosityStatus().equals(Zygosity.POSSIBLY_HOMOZYGOUS) ) {
                                var += "/" + var;
                            }
                        }

                %>

                <% } %>



            </div>

            <%
                String backColor= (String) backColors.get("het");
                String fontColor=(String) fontColors.get("het");

                if (backColors.containsKey(var)) {
                    backColor= (String) backColors.get(var);
                    fontColor=(String) fontColors.get(var);
                }

            %>

            <script>
                document.getElementById('dcell<%=k%>-<%=j%>').onclick=displayVariant;
                document.getElementById('dcell<%=k%>-<%=j%>').pos=<%=pos%>;
                document.getElementById('dcell<%=k%>-<%=j%>').vid=<%=variantID%>;
                document.getElementById('dcell<%=k%>-<%=j%>').sid=<%=sample%>;
                document.getElementById('dcell<%=k%>-<%=j%>').style.backgroundColor="<%=backColor%>";
                document.getElementById('dcell<%=k%>-<%=j%>').style.color="<%=fontColor%>";
            </script>

            <% } %>

            <% k++;
            } %>
        </div>
        <%  j++;
        } %>

    </div>



    <script>

        window.onload = function() {
            checkWidth();
            setupScrollSync();
        };
        window.onresize=checkWidth;

        function setupScrollSync() {
            var topScroll = document.getElementById("topScrollWrapper");
            var mainScroll = document.getElementById("wrapperRegion");
            
            // Sync main scroll to top scroll
            topScroll.onscroll = function() {
                mainScroll.scrollLeft = topScroll.scrollLeft;
            };
            
            // Sync top scroll to main scroll
            mainScroll.onscroll = function() {
                topScroll.scrollLeft = mainScroll.scrollLeft;
            };
        }

        function checkWidth() {

            var newWidth=  getWidth()-250;
            var divWidth= <%=divWidth%>;

            if (divWidth > newWidth) {
                document.getElementById("wrapperRegion").style.width=newWidth;
                document.getElementById("topScrollWrapper").style.width=newWidth;
            }

            document.getElementById("overview").style.width=newWidth + 150;
            document.getElementById("overview-region").style.width=newWidth + 150;


        }


    </script>

</div>
</div>
        <% } catch (Exception e)      {
    e.printStackTrace();
    }
 %>
<%@ include file="/common/footerarea.jsp" %>