<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.Chromosome" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>

<%
String pageTitle = "OLGA - Object List Generator & Analyzer";
String headContent = "";
String pageDescription = "Build lists based on RGD annotation";
%>
<%@ include file="/common/headerarea.jsp" %>



<script type="text/javascript" src="/rgdweb/js/jquery/jquery-1.12.4.min.js"></script>
<script>
    var jq14 = jQuery.noConflict(true);
</script>
<script type="text/javascript"  src="/rgdweb/common/jquery.autocomplete.custom.js"></script>
<link rel="stylesheet" href="/rgdweb/OntoSolr/jquery.autocomplete.css" type="text/css" />

<!--link rel="stylesheet" href="/rgdweb/generator/generator.css" type="text/css" /-->
<script type="text/javascript"  src="/rgdweb/generator/generator.js"></script>


<form name="submitForm" id="submitForm" action="list.html" method="post" target="_blank">
    <input type="hidden" name="a" id="a" value="" />
    <input type="hidden" name="mapKey" id="mapKey" value="" />
    <input type="hidden" name="oKey" id="oKey" value="" />
    <input type="hidden" name="vv" id="vv" value="" />
    <input type="hidden" name="ga" id="ga" value="" />
    <input type="hidden" name="act" id="act" value="" />

    <%
        int count = 1;
        String val = "";
        while ((val = request.getParameter("sample" + count)) != null) {
    %>
            <input type="hidden" name="sample<%=count%>" value="<%=val%>"/>

        <%
            count++;
        }
    %>


</form>

<%

try {
    Integer mapKey = (Integer) request.getAttribute("mapKey");
    Integer oKey= (Integer) request.getAttribute("oKey");
    Integer speciesTypeKey = SpeciesType.getSpeciesTypeKeyForMap(mapKey);


    String objectType = "Gene";

    if (oKey==5) {
        objectType="Strain";
    }

    if (oKey==6) {
        objectType="QTL";
    }

    ArrayList<String> accIds = (ArrayList<String>) request.getAttribute("accIds");
    List omLog = (List) request.getAttribute("omLog");
    ArrayList<String> operators = (ArrayList<String>) request.getAttribute("operators");
    ArrayList<ArrayList<String>> objectSymbols = (ArrayList<ArrayList<String>>) request.getAttribute("objectSymbols");
    LinkedHashMap<String,Object> resultSet = (LinkedHashMap<String,Object>) request.getAttribute("resultSet");
    HashMap exclude = (HashMap) request.getAttribute("exclude");
    HashMap messages = (HashMap) request.getAttribute("messages");


    String url = "";
    String a="";
    String vv="";
    String ga="";

    if (request.getParameter("a") != null) {
        url = "?a=" + request.getParameter("a") + "&mapKey" + request.getParameter("mapKey") + "&oKey=" + request.getParameter("oKey");
        a = request.getParameter("a");
    }
    if (request.getParameter("vv") != null) {
        vv = request.getParameter("vv");
    }
    if (request.getParameter("ga") != null) {
        ga = request.getParameter("ga");
    }

%>


 <script>

     (function ($) {



$(document).ready(function(){

    <% String ontId = "rdo"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "chebi"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "mp"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "pw"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "mf"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "bp"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "rs"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "hp"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "cmo"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "mmo"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "xco"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "cc"; %>
    <%@ include file="ontPopupConfig.jsp" %>
    <% ontId = "vt"; %>
    <%@ include file="ontPopupConfig.jsp" %>

});

     }(jq14));



 </script>



<script>
    var accIdTmp = new Array();

    if ("<%=a%>" != "") {
        accIdTmp = "<%=a%>".split("|");
    }

    if ("<%=vv%>" != "") {
        alert("Welcome to the List Generator.  Upon completion, you will have the option to submit back to Variant Visualizer with your custom list")
    }

    if ("<%=ga%>" != "") {
        alert("Welcome to the List Generator.  Upon completion, you will have the option to submit back to the GA Tool with your custom list")
    }

    var aOperators = new Array();
    var aAccIds = new Array();
    var aSubGenes = new Array();
    var screens = new Array();

    for (var i = 0; i< accIdTmp.length; i++) {

        var accIdBlock = accIdTmp[i];
        aOperators[i] = accIdBlock.substring(0,1);

        //get the minus genes
        var minGenes = accIdBlock.split("*");

        for (var j=0;j< minGenes.length; j++) {
            //alert(minGenes[j]);
        }

        aAccIds[i] = minGenes[0].substring(1);
        aSubGenes[i] = minGenes;
    }

</script>

<link rel="stylesheet" type="text/css" href="http://fonts.googleapis.com/css?family=Lato">

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading">OLGA - Object List Generator & Analyzer</div>
</div>
<!--Build Gene lists using annotations from multiple terms and ontologies-->

<table width="95%" style="border:1px solid #337AB7; background-color:#EBF2FA; ">
    <tr>
        <td></td>Options:
        <td align="right">
            <table border=0>
                <tr>
                    <td align="center" style="font-weight:700; color: #2865A3;">List Type:
                        <select id="oKey_tmp" name="oKey_tmp" onchange="reloadPage()" class="btn btn-primary" style="background-color:#2B84C8;" >
                        <option value='1' <% if (oKey==1) out.print("selected");%>>Gene</option>
                        <% if (speciesTypeKey == 3 || speciesTypeKey==2 || speciesTypeKey==1) { %>
                            <option value='6' <% if (oKey==6) out.print("selected");%>>QTL</option>
                            <% } %>
                        <% if (speciesTypeKey == 3) { %>
                            <option value='5' <% if (oKey==5) out.print("selected");%>>Strain</option>
                            <% } %>
                        </select>
                    </td>
                </tr>
            </table>
        </td>
        <td align="center">
            <table border=0>
                <tr>
                    <td style="font-weight:700; color: #2865A3;">Assembly Version:
                        <select id="mapKey_tmp" name="mapKey_tmp" onchange="reloadPage()"  class="btn btn-primary" style="background-color:#2B84C8;">
                            <option value='380' <% if (mapKey==380) out.print("selected");%>>GRCr8</option>
                            <option value='372' <% if (mapKey==372) out.print("selected");%>>RAT Genome Assembly v7.2</option>
                            <option value='360' <% if (mapKey==360) out.print("selected");%>>RAT Genome Assembly v6.0</option>
                            <option value='70' <% if (mapKey==70) out.print("selected");%>>RAT Genome Assembly v5.0</option>
                            <option value='60' <% if (mapKey==60) out.print("selected");%>>RAT Genome Assembly v3.4</option>
                            <option value='38' <% if (mapKey==38) out.print("selected");%>>Human Genome Assembly GRCh38</option>
                            <option value='17' <% if (mapKey==17) out.print("selected");%>>Human Genome Assembly GRCh37</option>
                            <option value='35' <% if (mapKey==35) out.print("selected");%>>Mouse Genome Assembly GRCm38</option>
                            <option value='18' <% if (mapKey==18) out.print("selected");%>>Mouse Genome Assembly Build 37</option>
                            <option value='44' <% if (mapKey==44) out.print("selected");%>>Chinchilla ChiLan1.0 Assembly</option>
                            <option value='511' <% if (mapKey==511) out.print("selected");%>>Bonobo panpan1.1 Assembly</option>
                            <option value='513' <% if (mapKey==513) out.print("selected");%>>Bonobo Mhudiblu PPA v0 Assembly</option>
                            <option value='631' <% if (mapKey==631) out.print("selected");%>>Dog CanFam3.1 Assembly</option>
                            <option value='720' <% if (mapKey==720) out.print("selected");%>>Squirrel SpeTri2.0 Assembly</option>
                            <option value='910' <% if (mapKey==910) out.print("selected");%>>Pig Sscrofa10.2 Assembly</option>
                            <option value='911' <% if (mapKey==911) out.print("selected");%>>Pig Sscrofa11.1 Assembly</option>
                            <option value='1311' <% if (mapKey==1311) out.print("selected");%>>Green Monkey 1.1 Assembly</option>
                            <option value='1313' <% if (mapKey==1313) out.print("selected");%>>Green Monkey Vero_WHO_p1.0 Assembly</option>
                            <option value='1410' <% if (mapKey==1410) out.print("selected");%>>Naked Mole-Rat female 1.0 Assembly</option>
                        </select>
                    </td>
                 </tr>
            </table>

        </td>
    </tr>
</table>

<br>
<div style="float:right; padding-right:10px; padding-top:10px;">
    <a href="javascript:back();"  class="btn btn-primary tn-sm" style="background-color:#2B84C8;">Back</a>
    <a href="/rgdweb/generator/list.html" class="btn btn-primary tn-sm" style="background-color:#2B84C8;">Reset</a>
</div>

<div id="selectBox" style="  background-color:white;height: 250px; width:730px; margin-left: auto; margin-right:auto;  border-radius: 20px; ">

<table width=100% height=250 border="0" style="background-color:#EBF2FA; border:2px solid #99BFE6; ">
    <tr>
        <td valign="center">

<div id="msgBox" style=" width:700px; font-size:20px;padding-top:5px; padding-bottom:5px;display:none;padding-left:10px;color:#24609C;text-align:center; "></div>


<div id="qtlSelect" align="center" class="roundSelect">
    <table >
        <tr>
            <td style="color:black;padding-bottom:10px;">Enter a QTL Symbol:</td>
        </tr>
        <tr>
            <td><input type="text" name="qtl" id="qtl" size=50/></td>
        </tr>
        <tr>
            <td align="center" colspan=2><br><input type="button" value="Continue" onClick="submitQTL()"/></td>
        </tr>
    </table>
</div>

<div id="saveBox" class="roundSelect">
<table align="center" >
<tr>
    <td style="color:white;">Enter a name for this list<br><br></td>
</tr>
<tr>
    <td colspan="2">
        <input type="text" id = "listName" name="listName" size="50" value="">
    </td>
</tr>
<tr>
    <td colspan="2" align="center"><br> <input type="button" value="Continue" onClick="toolSubmit('sv', '<%=speciesTypeKey%>')"/></td>
</tr>
</table>
</div>



<div id="toolsBox" class="roundSelect" >
<table border=0 align="center" >
    <tr>
        <%if (oKey==1) { %>
        <td><a href="javascript:toolSubmit('ga', '<%=speciesTypeKey%>');"><img src="/rgdweb/common/images/gaTool.png" /></a></td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <%}%>
        <% if (speciesTypeKey == 3 && oKey==1) { %>
            <td><a href="javascript:toolSubmit('vv','<%=speciesTypeKey%>');"><img src="/rgdweb/common/images/variantVisualizer.png" /></a></td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <% } %>
        <td><a href="javascript:toolSubmit('gv','<%=speciesTypeKey%>');"><img src="/rgdweb/common/images/gviewer.png" /></a></td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td><a href="javascript:toolSubmit('interviewer','<%=speciesTypeKey%>');"><img src="/rgdweb/common/images/interviewer.png" /></a></td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td><a href="javascript:toolSubmit('excel','<%=speciesTypeKey%>');"><img src="/rgdweb/common/images/excel.png" /></a></td>
    </tr>


    <tr>

        <% if (oKey==1) {%>
            <td align="center"><a style="color:white;" href="javascript:toolSubmit('ga','<%=speciesTypeKey%>');">Functional Annotation</a></td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <% }%>
        <% if (speciesTypeKey == 3 && oKey==1) { %>
            <td align="center"><a style="color:white;" href="javascript:toolSubmit('vv','<%=speciesTypeKey%>');">Genomic Variants</a></td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <% }%>
        <td align="center"><a href="javascript:toolSubmit('gv','<%=speciesTypeKey%>');">Genome Viewer</a></td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td align="center"><a  href="javascript:toolSubmit('interviewer','<%=speciesTypeKey%>');">Protein-Protein Interactions</a></td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td align="center"><a  href="javascript:toolSubmit('excel','<%=speciesTypeKey%>');">Excel (Download)</a></td>
    </tr>
</table>
</div>


<div id="questionBox" class="roundSelect"  >
    <table align="center" width=500 border="0">
        <tr>
            <td valign="top" style="font-size:23px; font-weight:700; color:black;padding-right:25px; ">Next&nbsp;Action:</td>
            <td style="background-color:black; width:1px; padding:3px;"></td>
            <td  style="font-size:20px;padding-left: 25px; " align="center">
                <a  href="javascript:showScreen('actionBox');" class="btn btn-primary" style="background-color:#2B84C8;">Add&nbsp;Another&nbsp;<%=objectType%>&nbsp;List</a>
                <br><br>

                <table>
                    <tr>

                        <td><img src="/rgdweb/common/images/tools-white-50.png" style="cursor:hand; border: 2px solid black;" border="0" ng-click="rgd.showTools('resultList',<%=speciesTypeKey%>,<%=mapKey%>,'<%=oKey%>','<%=a%>')"/></td>
                        <td><a  class="btn btn-primary" style="background-color:#2B84C8;" href="javascript:void(0)"; ng-click="rgd.showTools('resultList',<%=speciesTypeKey%>,<%=mapKey%>,'<%=oKey%>','<%=a%>')">Analyze&nbsp;Result&nbsp;Set</a></td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</div>

            <style>
                .multibox a {
                    color:#BE191F;
                    font-size:16px;
                }
            </style>

<div id="actionBox" style="padding-bottom:10px;display:none;position:relative; ">
<table style="margin-left:auto; margin-right:auto;" border=0>
    <tr>
        <td>
            <table class="multibox">
                <% if ((speciesTypeKey==2 || speciesTypeKey==1) && oKey==5) { %>
                <td  valign="center" style="font-size:20px; padding:10px;">
                    Strain is an invalid option for Human and Mouse.  Please change your object type or species

                </td>

                <% } else { %>

                <tr>
                    <td width="150" valign="top" style="padding:10px;">
                        <a href="javascript:showScreen('ontologySelect')" class="olgaOption">Ontology&nbsp;Annotation</a><br>
                        Generate a list of <%=objectType.toLowerCase()%>s annotated to a term in one of the RGD Ontologies
                    </td>
                    <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                    <td width="150" valign="top" style="padding:10px;" >
                        <a href="javascript:showScreen('positionSelect')" >Genomic Region</a><br>
                        Generate a list of  <%=objectType.toLowerCase()%>s  based on chromosome, start, and stop position
                    </td>
                    <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                    <td width="150" valign="top" style="padding:10px;" >
                        <a href="javascript:showScreen('qtlSelect')" >QTL Region</a><br>
                        Generate a list of <%=objectType.toLowerCase()%>s that overlap a QTL region
                    </td>
                    <% if (oKey==1) { %>
                    <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                    <td width="150" valign="top" style="padding:10px;" >
                        <a href="javascript:showScreen('geneSelect')" >Symbol List</a><br>
                        Upload a comma or line delimited list of gene symbols
                    </td>
                    <%} %>
                </tr>
                <% } %>
            </table>

        </td>
    </tr>
</table>
</div>

<div id="ontologySelect" style="padding-bottom:0px;display:none;">
    <table style="margin-left:auto; margin-right:auto;" border=0>
        <tr>
            <td>
                <table class="multibox" border=0>
                    <tr>

                        <% if (speciesTypeKey==1) { %>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('rdo')" >Disease Ontology</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('hp')" style="olor:white;">Human Phenotype</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('vt')" style="olor:white;">Vertebrate Trait</a><br>
                        </td>


                        <% if (oKey==1) { %>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('pw')" style="olor:white;">Pathway Ontology</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('bp')" style="olor:white;">GO: Biological Process</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('mf')" style="olor:white;">GO: Molecular Function</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('cc')" style="olor:white;">GO: Cellular Component</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('chebi')" style="olor:white;">CHEBI</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('mmo')" style="olor:white;">Measurement Method</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('nbo')" style="olor:white;">Neuro Behavioral</a><br>
                        </td>

                            <% } %>
                            <% if (oKey==6) { %>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('efo')" >Experimental Factor</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('cmo')" style="olor:white;">Clinical Measurement</a><br>
                        </td>


                            <% } %>



                        <% } %>

                        <% if (speciesTypeKey==2) { %>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('mp')" style="olor:white;">Mammalian Phenotype</a><br>
                        </td>

                        <% if (oKey==1) { %>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('rdo')" >Disease Ontology</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('pw')" style="olor:white;">Pathway Ontology</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('bp')" style="olor:white;">GO: Biological Process</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('mf')" style="olor:white;">GO: Molecular Function</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('cc')" style="olor:white;">GO: Cellular Component</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('chebi')" style="olor:white;">CHEBI</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('vt')" style="olor:white;">Vertebrate Trait</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('nbo')" style="olor:white;">Neuro Behavioral</a><br>
                        </td>

                        <% } %>
                        <% } %>


                        <% if (speciesTypeKey==3) { %>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('rdo')" >Disease Ontology</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('mp')" style="olor:white;">Mammalian Phenotype</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('nbo')" style="olor:white;">Neuro Behavioral</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('vt')" style="olor:white;">Vertebrate Trait</a><br>
                        </td>

                        <% if (oKey==1) { %>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('pw')" style="olor:white;">Pathway Ontology</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('bp')" style="olor:white;">GO: Biological Process</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('mf')" style="olor:white;">GO: Molecular Function</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('cc')" style="olor:white;">GO: Cellular Component</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('chebi')" style="olor:white;">CHEBI</a><br>
                        </td>

                        <% } %>
                        <% if (oKey==5) { %>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('bp')" style="olor:white;">GO: Biological Process</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('rs')" style="olor:white;">Strain Ontology</a><br>
                        </td>

                        <% } %>
                        <% if (oKey==6) { %>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('rs')" style="olor:white;">Strain Ontology</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('cmo')" style="olor:white;">Clinical Measurement</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('mmo')" style="olor:white;">Measurement Method</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('xco')" style="olor:white;">Experimental Condition</a><br>
                        </td>

                        <% } %>


                        <% } %>


                        <% if (speciesTypeKey == 4 || speciesTypeKey==5 || speciesTypeKey==7 || speciesTypeKey==13) { %>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('rdo')" >Disease Ontology</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('pw')" style="olor:white;">Pathway Ontology</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('bp')" style="olor:white;">GO: Biological Process</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('mf')" style="olor:white;">GO: Molecular Function</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('cc')" style="olor:white;">GO: Cellular Component</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('nbo')" style="olor:white;">Neuro Behavioral</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('vt')" style="olor:white;">Vertebrate Trait</a><br>
                        </td>

                        <% } %>

                        
                        <% if (speciesTypeKey == 6 || speciesTypeKey == 9 || speciesTypeKey==14) { %>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('rdo')" >Disease Ontology</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('pw')" style="olor:white;">Pathway Ontology</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('bp')" style="olor:white;">GO: Biological Process</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('mf')" style="olor:white;">GO: Molecular Function</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('cc')" style="olor:white;">GO: Cellular Component</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('nbo')" style="olor:white;">Neuro Behavioral</a><br>
                        </td>
                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('vt')" style="olor:white;">Vertebrate Trait</a><br>
                        </td>


                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('mp')" style="olor:white;">Mammalian Phenotype</a><br>
                        </td>

                        <td style="background-color:#B7B7B7; width:1px; padding:3px;"></td>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('chebi')" style="olor:white;">CHEBI</a><br>
                        </td>


                        <% } %>
                        <% if (speciesTypeKey == 8) { %>
                        <td width="150" valign="center" align="center" >
                            <a href="javascript:showOntInput('rdo')" >Disease Ontology</a><br>
                        </td>

                        <% } %>

                    </tr>
                </table>

            </td>
        </tr>
    </table>
</div>



<div id="positionSelect" align="center" class="roundSelect">
    <table >
    <tr>
        <td>Chromosome:</td>
        <td>
        <select name="chr" id="chr">


            <%
                FormUtility fu = new FormUtility();
                List<Chromosome> chromosomes = MapManager.getInstance().getChromosomes(mapKey);
                for (Chromosome ch: chromosomes) {
                    //for (int i = 1; i < 23; i++) { %>
            <option  value="<%=ch.getChromosome()%>" ><%=ch.getChromosome()%></option>

            <%  } %>

        </select>
        </td>
    </tr>
    <tr>
        <td>Start Position:</td>
        <td><input name="start" id="start" type='text' value=''/></td>
    </tr>
    <tr>
        <td>Stop Position:</td>
        <td><input name="stop" id="stop" type='text' value=''/></td>
    </tr>
    <tr>
        <td align="center" colspan=2><br><input type="button" value="Continue" onClick="submitPosition()"/></td>
    </tr>

</table>
</div>

<div id="geneSelect" class="roundSelect">
    <table align="center">
    <tr>
        <td style="olor:white;"><%=objectType%> Symbol List (Comma or new line delimited):</td>
        <td><textarea id="geneSelectList" rows=9 cols=50 ></textarea></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td align="center"><br><input type="button" value="Continue" onClick="submitGenes()"/></td>
    </tr>
    </table>
</div>


<% ontId = "rdo"; %>
<% String ontName = "Disease"; %>
<%@ include file="ontInput.jsp" %>
<% ontId = "rs"; %>
<% ontName = "Strain"; %>
<%@ include file="ontInput.jsp" %>
<% ontId = "hp"; %>
<% ontName = "Human Phenotype"; %>
<%@ include file="ontInput.jsp" %>
<% ontId = "cmo"; %>
<% ontName = "Clinical Measurement"; %>
<%@ include file="ontInput.jsp" %>
<% ontId = "mmo"; %>
<% ontName = "Measurement Method"; %>
<%@ include file="ontInput.jsp" %>
<% ontId = "xco"; %>
<% ontName = "Experimental Condition"; %>
<%@ include file="ontInput.jsp" %>
<% ontId = "bp"; %>
<% ontName = "Biological Process"; %>
<%@ include file="ontInput.jsp" %>
<% ontId = "cc"; %>
<% ontName = "Cellular Component"; %>
<%@ include file="ontInput.jsp" %>
<% ontId = "mf"; %>
<% ontName = "Molecular Function"; %>
<%@ include file="ontInput.jsp" %>
<% ontId = "pw"; %>
<% ontName = "Pathway"; %>
<%@ include file="ontInput.jsp" %>
<% ontId = "mp"; %>
<% ontName = "Mammalian Phenotype"; %>
<%@ include file="ontInput.jsp" %>
<% ontId = "chebi"; %>
<% ontName = "Chemical"; %>
<%@ include file="ontInput.jsp" %>
<% ontId = "vt"; %>
<% ontName = "Vertebrate Trait"; %>
<%@ include file="ontInput.jsp" %>



<div id="venn" align="center" class="roundSelect">
    <table >
        <tr><td colspan=3 style="olor:white; font-weight:700;">How would you like to append this list?<br><br></td></tr>
        <tr>
            <td style="padding:5px;"><a href="javascript:setLogic('union')"><img src="/rgdweb/common/images/union.png"/></a></td>
            <td style="padding:5px;"><a href="javascript:setLogic('intersect')"><img src="/rgdweb/common/images/intersect.png"/></a></td>
            <td style="padding:5px;"><a href="javascript:setLogic('subtract')"><img src="/rgdweb/common/images/subtract.png"/></a></td>
        </tr>
        <tr>
            <td style="olor:white;" align="center">Union</td>
            <td style="olor:white;" align="center">Intersection</td>
            <td style="olor:white;" align="center">Subtract</td>
        </tr>
    </table>
</div>

        </td>
    </tr>
</table>


</div>


<div id="preview" style="position:absolute; background-color:#E8E7E2; height:200px; max-width:300px; left:20px; top:127px; overflow:scroll; border:3px solid #B7B7B7;">

</div>


<%
    String[] colors = new String[8];

    colors[0] = "blue";
    colors[1] = "red";
    colors[2] = "green";
    colors[3] = "orange";
    colors[4] = "purple";
    colors[5] = "black";
    colors[6] = "gray";
    colors[7] = "yellow";

%>


<% if (accIds.size() > 0 ) { %>

<% if (omLog.size() > 0) { %>
<table align="center" style="margin-top: 15px; border: solid;border-color: black;border-width: thin;">
    <tr>
        <td align="left" >
            <div id="warningBox" class=info style="overflow: auto;height: 60px;margin: 3px;">
                <%
                    Iterator logIt = omLog.iterator();
                    String msg = "";
                    while (logIt.hasNext()) {
                        msg = logIt.next().toString();
//                        System.out.println(msg);
                        out.print(msg + "<br>");
                    }
                %>
            </div>

        </td>
    </tr>

</table>
<hr>
<% } %>
<table width=100% border=0>
    <tr>
        <td>
            <div style="font-size:22;color:#1A456F;margin-top:10px;">WorkBench</div>
        </td>

    </tr>
</table>

<!--
<div style="width:100%; margin:0 auto; background-color:white; margin-bottom:10px;">
    <div style="float:left;margin-right:10px; margin-left:5px;font-weight:700;">{{ listName }}</div><div>{{ listDescription }}</div>
</div>
-->


<table border="0" style="margin-top:5px; margin-bottom:20px;">
    <tr>
        <td>

<%
    for (int i=0; i < accIds.size(); i++ ) {
        String accId = accIds.get(i);

        String identifier = null;

        if (accId.toLowerCase().startsWith("chr")) {
            identifier=accId;
        }else if (accId.toLowerCase().startsWith("lst")) {
            identifier = "User&nbsp;List";
        } else if (accId.toLowerCase().startsWith("qtl")) {
            identifier = accId.substring(4);
        } else {
            OntologyXDAO odao = new OntologyXDAO();
            Term t = odao.getTermByAccId(accId);
            identifier = t.getTerm();
        }

%>

    <% if (i !=0) { %>
        <b><%  if (operators.get(i).equals("~")) out.print("&nbsp;UNION&nbsp;"); %></b>
        <b><%  if (operators.get(i).equals("!")) out.print("&nbsp;INTERSECT&nbsp;"); %></b>
        <b><%  if (operators.get(i).equals("^")) out.print("&nbsp;SUBTRACT&nbsp;"); %></b>

    <% }else { %>
        <% for (int j=1; j< accIds.size(); j++) { %>
            <span style="font-weight:700; font-size:16px;">(</span>
        <% } %>

    <% } %>

    <span style="padding:3px; border-top:1px solid <%=colors[i]%>; border-bottom: 1px solid <%=colors[i]%>"><%=identifier%></span>

    <% if (i !=0) { %>
        <b>)</b>
    <% } %>

<%
    }
%>
        </td>
    </tr>
</table>




<table border=0 cellpadding=0 cellspacing=0>
    <tr>

    <%
        for (int i=0; i < accIds.size(); i++ ) {
       %>
        <td>
            <%
            String accId = accIds.get(i);

            String op = "Union";
            if (operators.get(i).equals("^")) {
                op = "Subtract";
            }
            if (operators.get(i).equals("!")) {
                op = "Intersect";
            }

     %>
<% if (i > 0) { %>
    <td valign="top">
    <div style="float:left;">
        <br><br>
         <select id="op-<%=i%>" style="border:1px solid black;" onchange="updateOperation(this)">
            <option value="~" <%  if (operators.get(i).equals("~")) out.print("selected"); %>>Union</option>
            <option value="^" <%  if (operators.get(i).equals("^")) out.print("selected"); %>>Subtract</option>
            <option value="!" <%  if (operators.get(i).equals("!")) out.print("selected"); %>>Intersect</option>
        </select>
    </div>
</td>
<% } %>

<td valign="top">

<div style="padding-left:0px; border-top:1px solid <%=colors[i]%>; border-right:1px solid <%=colors[i]%>;  border-left:1px solid <%=colors[i]%>; text-align:center;"><%=objectSymbols.get(i).size()%></div>
<div style="border-right:1px solid <%=colors[i]%>; border-top:5px solid <%=colors[i]%>; padding:5px; margin: 5px; display: inline-block;">
<div style="float:right; text-align:right;"><a href="javascript:removeTerm(<%=i%>)"><img src="/rgdweb/common/images/del.jpg" border=0 /></a> </div>

<%
    if (messages.containsKey(accIds.get(i))) {
    %>
        <div style="padding-top:5px;padding-bottom:5px;font-weight:700; color:red;">Empty</div><div><%=messages.get(accIds.get(i))%></div>
    <%
    }else if (objectSymbols.get(i).size()==0) { %>
         <div style="text-decoration:underline; padding-top:5px;padding-bottom:5px;font-weight:700; color:red;">Empty</div>
<%
}

for (String gene: objectSymbols.get(i)) {
    if (!exclude.containsKey(gene)) {
%>
        <table cellpadding=0 cellspacing=0><tr><td><a href="javascript:removeGene('<%=accId%>','<%=gene%>')"><img height=10 width=10 src="/rgdweb/common/images/del.jpg" border=0 /></a>&nbsp;&nbsp;&nbsp;<%=gene%></td></tr></table>
<%
    }
}
%>
</div>
</td>

<%
    }

%>

<td style="width:15px;">&nbsp;&nbsp;</td>
<td valign="top" style="background-color:#3F3F3F; width:10px;">
      &nbsp;&nbsp;
</td>
 <td valign="top">
   <table cellpadding=0 cellspacing=0>
   <tr>
       <td><div style="font-weight:700; font-size:20px; background-color:#3F3F3F; color:white; padding-right:5px;">Result&nbsp;Set&nbsp;(<%=resultSet.keySet().size()%>)</div></td>
   </tr>
   <tr>
       <td>

           <div id="resultSet" style="border:0px solid black; float:left; padding:7px; margin-left:5px;">
               <%
                   if (resultSet.keySet().size() == 0) {
               %>
               Empty&nbsp;Set
               <%
                   }
                   Iterator it = resultSet.keySet().iterator();
                   while(it.hasNext()) {
                       String gene = (String)it.next();
               %>
               <span class="resultList"><%=gene.trim()%></span><br>
               <%
                   }
               %>

           </div>
</td>


</tr>
</table>

       </td>
</tr>
</table>



<script>

<%
//if (accIds.size()==1 && messages.containsKey(accIds.get(0))) {
if (accIds.size()==1 && objectSymbols.get(0).size() == 0) {

    String mess = "";
    if (messages.get(accIds.get(0)) != null) {
        mess = (String)messages.get(accIds.get(0));
        mess = mess.replaceAll("<br>","\\\\n");
    }else {
        mess = "0 objects are annotated to this term or region.\\n\\nPlease select again.";
    }


%>
    hideAll();
    showScreen("actionBox","Welcome!  To get started, select a list type from the options below" );
    alert("<%=mess%>");
    aAccIds.length=0;
    aOperators.length=0;
    reloadPage();

<%
    }

%>

</script>

<% }

} catch (Exception e) {
    e.printStackTrace();
}%>

<script>
    if (aAccIds.length > 0) {
        showScreen("questionBox");
    }else {
        showScreen("actionBox","Welcome!  To get started, select a list type from the options below" );
    }
</script>


<%@ include file="/common/angularBottomBodyInclude.jsp" %>
</body>
</html>

<script>
    //getResultSetJSON();
</script>