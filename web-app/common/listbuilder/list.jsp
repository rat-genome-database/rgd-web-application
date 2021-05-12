<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="org.apache.commons.collections.ListUtils" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.datamodel.QTL" %>
<%@ page import="edu.mcw.rgd.datamodel.MapData" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermWithStats" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>


<%
    String pageTitle = "OLGA Gene List Generator";
    String headContent = "";
    String pageDescription = "Build and analyze gene lists based on functional annotation";
%>

<%@ include file="/common/compactHeaderArea.jsp" %>

<!--
<script type="text/javascript"  src="/OntoSolr/files/jquery-1.4.3.min.js"></script>
<script type="text/javascript"  src="/OntoSolr/files/jquery.autocomplete.custom.js"></script>
<link rel="stylesheet" href="/OntoSolr/files/jquery.autocomplete.css" type="text/css" />
-->
<style>
.rootont {
    float:left;
    padding-left:5px;
    padding-right:20px;
    width:205px;
}

.credittext {
    font-size:11px;
    color:#808080;
}
.credittext A {
    font-size:11px;
    color:#505050;
}
</style>

<%

try {
    // default map key
    int mapKey = MapManager.getInstance().getReferenceAssembly(SpeciesType.RAT).getKey();

    try {
        mapKey = Integer.parseInt(request.getParameter("mapKey"));
    }catch(Exception e) {
    }

    int speciesType = MapManager.getInstance().getMap(mapKey).getSpeciesTypeKey();

    ObjectMapper om = new ObjectMapper();
%>


 <script>




jQuery_1_3_2(document).ready(function(){

    // handle to popup windows
    var rdo_popup_wnd = null;
    var chebi_popup_wnd = null;
    var mp_popup_wnd = null;
    var pw_popup_wnd = null;


    jQuery_1_3_2("#rdo_popup").click(function(){
        if( rdo_popup_wnd!=null ) {
            if( !rdo_popup_wnd.closed ) {
                rdo_popup_wnd.focus();
                return;
            }
        }
        rdo_popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=RDO&sel_term=rdo_term&sel_acc_id=rdo_acc_id&term="
               +document.getElementById("rdo_term").value,
               '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
        return false;
    });

    jQuery_1_3_2("input[name='rdo_term']").autocomplete('/OntoSolr/select', {
      extraParams:{
          'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
          'bf': 'term_len_l^.02',

          'fq': 'cat:(RDO)',
          'wt': 'velocity',
          'v.template': 'termidselect'
      },
      max: 100,
      'termSeparator': ' OR '
    }
    );

    jQuery_1_3_2('#rdo_term').result(function(data, value){
        document.getElementById("rdo_acc_id").value= value[1];
    });

   jQuery_1_3_2("#mp_popup").click(function(){
        if( mp_popup_wnd!=null ) {
            if( !mp_popup_wnd.closed ) {
                mp_popup_wnd.focus();
                return;
            }
        }
        mp_popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=MP&sel_term=mp_term&&sel_acc_id=mp_acc_id&term="
               +document.getElementById("mp_term").value,
               '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
       return false;

    });

    jQuery_1_3_2("input[name='mp_term']").autocomplete('/OntoSolr/select', {
      extraParams:{
          'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
          'bf': 'term_len_l^.02',

          'fq': 'cat:(MP)',
          'wt': 'velocity',
          'v.template': 'termidselect'
      },
      max: 100,
      'termSeparator': ' OR '
    }
    );

    jQuery_1_3_2('#mp_term').result(function(data, value){
        document.getElementById("mp_acc_id").value= value[1];
    });

    jQuery_1_3_2("#pw_popup").click(function(){
         if( pw_popup_wnd!=null ) {
             if( !pw_popup_wnd.closed ) {
                 pw_popup_wnd.focus();
                 return;
             }
         }
         pw_popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=PW&sel_term=pw_term&sel_acc_id=pw_acc_id&term="
                +document.getElementById("pw_term").value,
                '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
        return false;

     });

     jQuery_1_3_2("input[name='pw_term']").autocomplete('/OntoSolr/select', {
       extraParams:{
           'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
           'bf': 'term_len_l^.02',

           'fq': 'cat:(PW)',
           'wt': 'velocity',
           'v.template': 'termidselect'
       },
       max: 100,
       'termSeparator': ' OR '
     }
     );

    jQuery_1_3_2('#pw_term').result(function(data, value){
        document.getElementById("pw_acc_id").value= value[1];
    });

    jQuery_1_3_2("#chebi_popup").click(function(){
        if( chebi_popup_wnd!=null ) {
            if( !chebi_popup_wnd.closed ) {
                chebi_popup_wnd.focus();
                return;
            }
        }
        chebi_popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont=CHEBI&sel_term=chebi_term&sel_acc_id=chebi_acc_id&term="
               +document.getElementById("chebi_term").value,
               '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
        return false;

    });

    jQuery_1_3_2("input[name='chebi_term']").autocomplete('/OntoSolr/select', {
      extraParams:{
          'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
          'bf': 'term_len_l^.02',

          'fq': 'cat:(CHEBI)',
          'wt': 'velocity',
          'v.template': 'termidselect'
      },
      max: 100,
      'termSeparator': ' OR '
    }
    );

    jQuery_1_3_2('#chebi_term').result(function(data, value){
        document.getElementById("chebi_acc_id").value= value[1];
    });

});

    function getJsonFromUrl() {
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
        var item = part.split("=");
        result[item[0]] = decodeURIComponent(item[1]);
    });

    return result;
}
    function hideAll() {

        //document.getElementById("selectBox").style.display="none";
        document.getElementById("positionSelect").style.display="none";
        document.getElementById("geneSelect").style.display="none";
        document.getElementById("venn").style.display="none";
        document.getElementById("qtlSelect").style.display="none";
        document.getElementById("actionBox").style.display="none";
        document.getElementById("ontologySelect").style.display="none";
        document.getElementById("questionBox").style.display="none";
        document.getElementById("msgBox").style.display="none";
        //document.getElementById("positionBox").style.display="none";
        document.getElementById("toolsBox").style.display="none";
        document.getElementById("rdoSelect").style.display="none";
        document.getElementById("pwSelect").style.display="none";
        document.getElementById("mpSelect").style.display="none";
        document.getElementById("chebiSelect").style.display="none";


    }

    function showAll() {
        document.getElementById("positionSelect").style.display="block";
        document.getElementById("geneSelect").style.display="block";
        document.getElementById("venn").style.display="block";
        document.getElementById("qtlSelect").style.display="block";
        document.getElementById("actionBox").style.display="block";
        document.getElementById("ontologySelect").style.display="block";
        document.getElementById("questionBox").style.display="block";
        document.getElementById("msgBox").style.display="block";
        //document.getElementById("positionBox").style.display="none";
        document.getElementById("toolsBox").style.display="block";
        document.getElementById("rdoSelect").style.display="block";
        document.getElementById("pwSelect").style.display="block";
        document.getElementById("mpSelect").style.display="block";
        document.getElementById("chebiSelect").style.display="block";

    }


    function resetFormValues() {
        document.getElementById("rdo_acc_id").value="";
        document.getElementById("rdo_term").value="";
        document.getElementById("pw_acc_id").value="";
        document.getElementById("pw_term").value="";
        document.getElementById("mp_acc_id").value="";
        document.getElementById("mp_term").value="";
        document.getElementById("chebi_acc_id").value="";
        document.getElementById("chebi_term").value="";

        document.getElementById("geneSelectList").value="";

        //document.getElementById("chr").value="";
        document.getElementById("start").value="";
        document.getElementById("stop").value="";

        document.getElementById("qtl").value="";

    }

    function getVenn() {

        if (aAccIds.length ==0) {
            setLogic('union');
            return;
        }

        hideAll();
        document.getElementById("selectBox").style.display="block";
        document.getElementById("venn").style.display="block";

    }

    function showOntInput(ont) {
        resetFormValues();
        hideAll();
        document.getElementById("selectBox").style.display="block";
        document.getElementById(ont + "Select").style.display="block";
    }

    function showScreenBack(screenId) {
        hideAll();
        document.getElementById("selectBox").style.display="block";
        document.getElementById(screenId).style.display="block";
    }

    function showScreen(screenId, msg) {
        resetFormValues();
        hideAll();
        if (msg != null && msg != "") {
            displayMsg(msg);
        }
        document.getElementById("selectBox").style.display="block";
        document.getElementById(screenId).style.display="block";

        screens[screens.length] = screenId;
    }

    function back() {

        if (screens.length > 1) {
            showScreenBack(screens[screens.length - 2]);
            screens.length=screens.length-1;
        }
    }

    function getUserSelectedAccId() {

        if (document.getElementById("rdo_acc_id").value != "") {
            return document.getElementById("rdo_acc_id").value;
        }
        if (document.getElementById("pw_acc_id").value != "") {
            return document.getElementById("pw_acc_id").value;
        }
        if (document.getElementById("mp_acc_id").value != "") {
            return document.getElementById("mp_acc_id").value;
        }
        if (document.getElementById("chebi_acc_id").value != "") {
            return document.getElementById("chebi_acc_id").value;
        }

        if (document.getElementById("geneSelectList").value != "") {

            var genes = document.getElementById("geneSelectList").value.split(/[,\s\|]/);

            var geneStr = "";
            for (var i = 0; i< genes.length; i++) {
                if (i==0) {
                    geneStr += genes[i];

                }else {
                    geneStr += "[" + genes[i];
                }
            }

            return "lst:" + geneStr;
        }

        if (document.getElementById("qtl").value !="") {
            return "qtl:" + document.getElementById("qtl").value;
        }

        if (document.getElementById("chr").value != "" &&  document.getElementById("start").value != "" &&  document.getElementById("stop").value != "") {
            return "chr" + document.getElementById("chr").value + ":" + document.getElementById("start").value + ".." + document.getElementById("stop").value;
        }

    }

    function setLogic(operator) {

        if (operator == "union") {
            aOperators[aOperators.length] = "~";
        }else if (operator == "intersect") {
            aOperators[aOperators.length] = "!";
        }else if (operator == "subtract") {
            aOperators[aOperators.length] = "^";
        }

        aSubGenes[aSubGenes.length] = new Array();
        aAccIds[aAccIds.length] = getUserSelectedAccId();
        reloadPage();

    }

    var params = getJsonFromUrl();

    //var a = aArr[0];
    var accIdTmp = new Array();

    if (params.a) {
        accIdTmp = params.a.split("|");
    }

    if (params.vv) {
        alert("Welcome to the Gene List Generator.  Upon completion, you will have the option to submit back to Variant Visualizer with your custom list")
    }

    if (params.ga) {
        alert("Welcome to the Gene List Generator.  Upon completion, you will have the option to submit back to the GA Tool with your custom list")
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

    var b = params.b;

    function removeItemFromArray(arr, index) {

        var newArray = new Array();

        for (var i=0; i< arr.length; i++) {
            if (i != index) {
                newArray[newArray.length] = arr[i];
            }
        }

        return newArray;
    }

    function removeTerm(i) {

        aOperators = removeItemFromArray(aOperators, i);
        aAccIds = removeItemFromArray(aAccIds, i);
        aSubGenes = removeItemFromArray(aSubGenes, i);

        reloadPage();
    }

    function removeGene(accId, gene) {
       var index=-1;

       for (var i=0; i< aAccIds.length;i++) {
           if (aAccIds[i] == accId) {
               index=i;
           }
       }

       if (index > -1) {
           aSubGenes[index][aSubGenes[index].length] = gene;
       }

       reloadPage();
    }


    function reloadPage() {
        var urlString = "?a=";

        for (var i=0; i < aOperators.length; i++) {

            if (i !=0) {
                urlString += "|";
            }

            urlString += aOperators[i];
            urlString += aAccIds[i];

            for (var j=1; j < aSubGenes[i].length; j++) {
                urlString += "*" + aSubGenes[i][j];
            }

        }

        var locArr = location.href.split("?");
        location.href = locArr[0] + urlString + "&mapKey=" + document.getElementById("mapKey").options[document.getElementById("mapKey").selectedIndex].value;

    }

    function submitGenes() {
        if (document.getElementById("geneSelectList").value == "") {
            alert("Please enter one or more gene symbols");
            return false;
        }


        getVenn();
    }
    function submitTerm() {
        var d=document.getElementById("rdo_acc_id").value;
        var p=document.getElementById("pw_acc_id").value;
        var mp=document.getElementById("mp_acc_id").value;
        var c=document.getElementById("chebi_acc_id").value;

        var termCnt=0;
        if (d!="") {
            termCnt++;
        }
        if (p!="") {
            termCnt++;
        }
        if (mp!="") {
            termCnt++;
        }
        if (c!="") {
            termCnt++;
        }

        if (termCnt == 0) {
            alert("Please Select A Term.")
            return false;
        }

        if (termCnt > 1) {
            alert("Only ONE term may be selected.  You currently selected " + termCnt + " terms.")
            return false;
        }

        getVenn();
    }
    function submitPosition() {

        if (document.getElementById("chr").value != "" &&  document.getElementById("start").value != "" &&  document.getElementById("stop").value != "") {
            getVenn();
        } else {
            alert("Please enter a start and stop position");
        }
    }

    function submitQTL() {
        if (document.getElementById("qtl").value == "") {
            alert("Please enter a QTL symbol");
            return false;
        }

        getVenn();
    }


    function updateOperation(obj) {

        var index=obj.id.substring(3);
        aOperators[index] = obj.options[obj.selectedIndex].value;
        reloadPage();

    }

    function getResultSet() {
        var geneList = document.getElementById("resultSet").innerHTML;
        geneList = geneList.replace(/\s/g, "");
        geneList = geneList.replace(/<br>/g, "\n");
        return encodeURIComponent(geneList);

    }

    function submitToGA() {
        var url = "/rgdweb/ga/start.jsp?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=56&x=36&x=52&x=40&x=31&x=45&x=29&x=32&x=48&x=23&x=33&x=50&x=17&x=2&x=20&x=54&x=57&x=27&x=41&x=35&x=49&x=5&x=55&x=42&x=10&x=38&x=3&x=6&x=15&x=1&x=53&x=37&x=7&x=34&x=43&x=39&x=30&x=4&x=21&x=44&x=14&x=22&x=51&x=16&x=24&ortholog=1&ortholog=2&species=3&chr=1&start=&stop=";
        url += "&mapKey=" + document.getElementById("mapKey").options[document.getElementById("mapKey").selectedIndex].value;
        url += "&genes=" + getResultSet();

        location.href=url;
    }

    function submitToVV() {

        var url = "/rgdweb/front/geneList.html?chr=&start=&stop=&geneStart=&geneStop=&sample1=603&sample2=500&sample3=510&sample4=604&sample5=601&sample6=521&sample7=602&sample8=512&sample9=511&sample10=513&sample11=522&sample12=514&sample13=605&sample14=606&sample15=501&sample16=507&sample17=607&sample18=502&sample19=523&sample20=608&sample21=609&sample22=515&sample23=610&sample24=611&sample25=612&sample26=613&sample27=614&sample28=516&sample29=615&sample30=616&sample31=517&sample32=617&sample33=618&sample34=620&sample35=619&sample36=520&sample37=621&sample38=508&sample39=622&sample40=503&sample41=623&sample42=624&sample43=504&sample44=509&sample45=625&sample46=627&sample47=518&sample48=626&sample49=628&sample50=519";
        url += "&mapKey=" + document.getElementById("mapKey").options[document.getElementById("mapKey").selectedIndex].value;
        url += "&geneList=" + getResultSet();
        location.href=url;
    }

    function downloadResult() {
        alert("download result set");
    }

    function displayMsg(msg) {
        document.getElementById("msgBox").style.display="block";
        document.getElementById("msgBox").innerHTML=msg;
        document.getElementById("selectBox").style.display="block";
    }




</script>


<table width="95%">
    <tr>
        <td><div style="font-size:26px;color:#1A456F;margin-top:10px;">Gene List Generator</div></td>
        <td align="right"><a href="/rgdweb/common/listbuilder/list.jsp">Reset</a>&nbsp;&nbsp;&nbsp;
        <td align="right" width=10>
            <select id="mapKey" name="mapKey" onchange="reloadPage()">
            <option value='17' <% if (mapKey==17) out.print("selected");%>>Human Genome Assebmly GRCh37</option>
            <option value='360' <% if (mapKey==360) out.print("selected");%>>RGSC Genome Assembly v6.0</option>
            <option value='70' <% if (mapKey==70) out.print("selected");%>>RGSC Genome Assembly v5.0</option>
            <option value='60' <% if (mapKey==60) out.print("selected");%>>RGSC Genome Assembly v3.4</option>
            </select>
        </td>
</td>
    </tr>
</table>

<style>
    .multibox {
          order-left:1px solid black;
          order-top:1px solid black;
          order-rigth:1px solid black;
          background-color:#3F3F3F;
          padding-top:10px;
          height:200px;
    }
    .multibox td {
        padding:10px;
        color:#B7B7B7;
    }
    .multibox a {
        color:white;
    }

    .roundSelect {
        display:none;
        padding:15px;
        width:700;
        border-radius: 20px;
        margin-left: auto;
        margin-right:auto;

    }

    .roundSelect td{
        color:#B7B7B7;"

    }

    .roundSelect a{
        color:white;
    }

</style>

<div style="float:right; padding-right:10px; padding-top:10px;"><a href="javascript:back();" style="padding:5px; color:white; border:1px dotted white;font-size:13px;"><< Back</a></div>

<div id="selectBox" style="  background-color:#3F3F3F;height: 250px; idth:730; margin-left: auto; margin-right:auto;  border-radius: 20px; ">

<table width=100% height=250>
    <tr>
        <td valign="center">

<div id="msgBox" style=" width:700px; font-size:20px;padding-top:5px; padding-bottom:5px;display:none;padding-left:10px;color:#B7B7B7;text-align:center;"></div>


<div id="qtlSelect" align="center" class="roundSelect">
    <table >
        <tr>
            <td style="color:white;padding-bottom:10px;">Enter a QTL Symbol:</td>
        </tr>
        <tr>
            <td><input type="text" name="qtl" id="qtl" size=50/></td>
        </tr>
        <tr>
            <td align="center" colspan=2><br><input type="button" value="Continue" onClick="submitQTL()"/></td>
        </tr>
    </table>
</div>

<div id="toolsBox" class="roundSelect">
<table border=0 align="center" >
    <tr>
        <td><a href="javascript:submitToGA()"><img src="/rgdweb/common/images/gaTool.png" /></a></td>
        <% if (mapKey != 17) { %>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td><a href="javascript:submitToVV()"><img src="/rgdweb/common/images/variantVisualizer.png" /></a></td>
        <% } %>
    </tr>
    <tr>
        <td align="center"><a style=color:white; href="javascript:submitToGA()">GA Tool</a></td>
        <% if (mapKey != 17) { %>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
            <td align="center"><a style="color:white;" href="javascript:submitToVV()">Variant Visualizer</a></td>
        <% } %>
    </tr>
</table>
</div>

<div id="questionBox" class="roundSelect" >
    <table align="center" width=500 >
        <tr>
            <td valign="top" style="font-size:23px; font-weight:700; color:#B7B7B7;padding-right:25px; ">Next&nbsp;Action:</td>
            <td style="background-color:#B7B7B7;">&nbsp;</td>
            <td align="center" style="font-size:20px;padding-left: 25px; ">
                <a style="color:white;" href="javascript:showScreen('actionBox');">Add&nbsp;Another&nbsp;Gene&nbsp;List</a>
                <br><br>
                <a style="color:white" href="javascript:showScreen('toolsBox')">Submit&nbsp;result&nbsp;set&nbsp;to&nbsp;an&nbsp;RGD&nbsp;Tool</a></td>
        </tr>
    </table>
</div>

<div id="actionBox" style="padding-bottom:10px;display:none;position:relative;">
<table style="margin-left:auto; margin-right:auto;" border=0>
    <tr>
        <td>
            <!--<table style="border-left:1px solid black; border-top:1px solid black; border-rigth:1px solid black; background-color:#3F3F3F; padding:4px;">-->
            <table class="multibox">
                <tr>
                    <td width="150" valign="top" >
                        <a href="javascript:showScreen('ontologySelect')">Ontology&nbsp;Annotation</a><br>
                        Include all genes annotated to a term in one of the RGD Ontologies
                    </td>
                    <td style="background-color:#B7B7B7;">&nbsp;</td>
                    <td width="150" valign="top" >
                        <a href="javascript:showScreen('geneSelect')" style="color:white;mar">Symbol List</a><br>
                        Supply a comma or tab delimited list of gene symbols
                    </td>
                    <td style="background-color:#B7B7B7;">&nbsp;</td>
                    <td width="150" valign="top" >
                        <a href="javascript:showScreen('positionSelect')" style="color:white;">Genomic Region</a><br>
                        Supply a chromosome, start, and stop position to include all genes in a region of the genome.
                    </td>
                    <td style="background-color:#B7B7B7;">&nbsp;</td>
                    <td width="150" valign="top" >
                        <a href="javascript:showScreen('qtlSelect')" style="color:white;">QTL Region</a><br>
                        Include a list of genes that overlaps an individual QTL.
                    </td>
                </tr>
            </table>

        </td>
    </tr>
</table>
</div>

<div id="ontologySelect" style="padding-bottom:10px;display:none;">
    <table style="margin-left:auto; margin-right:auto;" border=0>
        <tr>
            <td>
                <table class="multibox">
                    <tr>
                        <td width="150" valign="top" >
                            <a href="javascript:showOntInput('rdo')" >Disease Ontology</a><br>
                            RGD's Disease Ontology (RDO) is the MEDIC vocabulary developed and maintained by the Comparative Toxicogenomics Database
                        </td>
                        <td style="background-color:#B7B7B7;">&nbsp;</td>
                        <td width="150" valign="top" >
                            <a href="javascript:showOntInput('pw')" style="color:white;">Pathway Ontology</a><br>
                            The Pathway Ontology is developed at the Rat Genome Database
                        </td>
                        <td style="background-color:#B7B7B7;">&nbsp;</td>
                        <td width="150" valign="top" >
                            <a href="javascript:showOntInput('mp')" style="color:white;">Mammalian Phenotype</a><br>
                            The Mammalian Phenotype Ontology is downloaded weekly from Mouse Genome Informatics
                        </td>
                        <td style="background-color:#B7B7B7;">&nbsp;</td>
                        <td width="150" valign="top" >
                            <a href="javascript:showOntInput('chebi')" style="color:white;">CHEBI</a><br>
                            Chemical Entities of Biological Interest Ontology provided by EMBL-EBI
                        </td>
                    </tr>
                </table>

            </td>
        </tr>
    </table>
</div>



<div id="positionSelect" align="center" class="roundSelect">
    <table >
    <tr>
        <td  style="color:white;">Chromosome:</td>
        <td>
        <select name="chr" id="chr">

            <% for (int i=1; i < 23; i++) { %>
                <option  value="<%=i%>" ><%=i%></option>
            <% } %>

        <option  value="X"  >X</option>
        <option  value="Y"  >Y</option>

        </select>
        </td>
    </tr>
    <tr>
        <td  style="color:white;">Start Position:</td>
        <td><input name="start" id="start" type='text' value=''/></td>
    </tr>
    <tr>
        <td  style="color:white;">Stop Position:</td>
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
        <td style="color:white;">Gene List:</td>
        <td><textarea id="geneSelectList" rows=9 cols=50></textarea></td>
    </tr>
    <tr>
        <td>&nbsp;</td>
        <td align="center"><br><input type="button" value="Continue" onClick="submitGenes()"/></td>
    </tr>
    </table>
</div>

<div id="rdoSelect" class="roundSelect">
<table align="center" >
<tr>
    <td style="color:white;">Enter a Disease Term or Browse the Ontolgoy Tree<br><br></td>
</tr>
<tr>
    <td colspan="2">
        <input type="text" id = "rdo_term" name="rdo_term" size="50" value="">
        <input type="hidden" id="rdo_acc_id" name="rdo_acc_id" value=""/>
        <a href="" id="rdo_popup" style="color:white;">Browse Ontology Tree</a>
    </td>
</tr>
<tr>
    <td colspan="2" align="center"><br> <input type="button" value="Continue" onClick="submitTerm()"/></td>
</tr>
</table>
</div>

<div id="pwSelect" class="roundSelect">
<table align="center" >
    <tr>
        <td style="color:white;">Enter a Pathway Term or Browse the Ontolgoy Tree<br><br></td>
    </tr>
    <tr>
        <td colspan="2">
            <input type="text" id = "pw_term" name="pw_term" size="50" value="">
            <input type="hidden" id="pw_acc_id" name="pw_acc_id" value=""/>
            <a href="" id="pw_popup">Browse Ontology Tree</a>
        </td>
    </tr>
<tr>
    <td colspan="2" align="center"><br> <input type="button" value="Continue" onClick="submitTerm()"/></td>
</tr>
</table>
</div>

<div id="mpSelect" class="roundSelect">
<table align="center" border=0  >
    <tr>
        <td style="color:white;">Enter a Phenotype Term or Browse the Ontolgoy Tree<br><br></td>
    </tr>
    <tr>
        <td colspan="2">
            <input type="text" id = "mp_term" name="mp_term" size="50" value="">
            <input type="hidden" id="mp_acc_id" name="mp_acc_id" value=""/>
            <a href="" id="mp_popup">Browse Ontology Tree</a>
        </td>
    </tr>
<tr>
    <td colspan="2" align="center"><br> <input type="button" value="Continue" onClick="submitTerm()"/></td>
</tr>
</table>
</div>

<div id="chebiSelect" class="roundSelect">
<table align="center" >
    <tr>
        <td style="color:white;">Enter a Chemical Term or Browse the Ontolgoy Tree<br><br></td>
    </tr>
    <tr>
        <td colspan="2">
            <input type="text" id = "chebi_term" name="chebi_term" size="50" value="">
            <input type="hidden" id="chebi_acc_id" name="chebi_acc_id" value=""/>
            <a href="" id="chebi_popup">Browse Ontology Tree</a>
        </td>
    </tr>
<tr>
    <td colspan="2" align="center"><br> <input type="button" value="Continue" onClick="submitTerm()"/></td>
</tr>
</table>
</div>

<div id="venn" align="center" class="roundSelect">
    <table >
        <tr><td colspan=3 style="color:white; font-weight:700;">How would you like to append this gene list?<br><br></td></tr>
        <tr>
            <td style="padding:5px;"><a href="javascript:setLogic('union')"><img src="/rgdweb/common/images/union.png"/></a></td>
            <td style="padding:5px;"><a href="javascript:setLogic('intersect')"><img src="/rgdweb/common/images/intersect.png"/></a></td>
            <td style="padding:5px;"><a href="javascript:setLogic('subtract')"><img src="/rgdweb/common/images/subtract.png"/></a></td>
        </tr>
        <tr>
            <td style="color:white;" align="center">Union</td>
            <td style="color:white;" align="center">Intersection</td>
            <td style="color:white;" align="center">Subtract</td>
        </tr>
    </table>
</div>

        </td>
    </tr>
</table>


</div>

<!--
        </td>
    </tr>
</table>
-->



<%

    HttpRequestFacade req = new HttpRequestFacade(request);
    String aValue = "";

    if (req.getParameter("a") != null) {
        aValue= req.getParameter("a");
    }

    ArrayList<String> aOperators = new ArrayList<String>();
    ArrayList<String> aAccIds = new ArrayList<String>();
    ArrayList<HashMap<String,String>> aSubGenes = new ArrayList<HashMap<String,String>>();
    ArrayList<ArrayList<String>> aGenes = new ArrayList<ArrayList<String>>();
    List newList = new ArrayList();
    String[] accIdsA = new String[0];

    if (!aValue.equals("")) {
        accIdsA = aValue.split("\\|");
    }

    HashMap exclude = new HashMap();

if (accIdsA.length > 0) {

    for (int i = 0; i< accIdsA.length; i++) {

        String accIdBlock = accIdsA[i];
        aOperators.add(accIdBlock.substring(0,1));

        //get the minus genes
        String[] minGenesArray = accIdBlock.split("\\*");

        HashMap minGenes = new HashMap();
        for (int j=1; j<minGenesArray.length; j++) {
            minGenes.put(minGenesArray[j],null);
        }

        String accId = minGenesArray[0].substring(1);
        aAccIds.add(accId);
        aSubGenes.add(minGenes);
    }


    List<String> allGenes = new ArrayList<String>();

    for (int i=0; i < aAccIds.size(); i++ ) {

        String accId = (String) aAccIds.get(i);
        String operation=accId.substring(0,1);

        if (accId.toLowerCase().startsWith("chr")) {
            String chr = "";
            String start = "";
            String stop="";
            if (accId.indexOf(":") != -1) {
                chr = accId.substring(3,accId.indexOf(":"));
                start = accId.substring(accId.indexOf(":") + 1, accId.indexOf(".."));
                stop = accId.substring(accId.indexOf("..") + 2);

                GeneDAO gdao = new GeneDAO();
                List<Gene> genes = gdao.getActiveGenesSortedBySymbol(chr, Long.parseLong(start), Long.parseLong(stop),mapKey);

                for (Gene gene: genes) {
                    allGenes.add(gene.getSymbol());
                }

            }else {


            }

        }else if (accId.toLowerCase().startsWith("lst")) {

            String lst = accId.substring(4);
            String[] genes = lst.split("\\[");

            List symbols=null;

            req=new HttpRequestFacade(request);

            List geneList = new ArrayList();
            for (int k=0; k<genes.length; k++) {
                geneList.add(genes[k]);
            }

            try {
                om.mapSymbols(geneList, speciesType);

                List<Gene> mappedGenes = om.getMapped();

                /*
                Iterator eit = om.getLog().iterator();
                while (eit.hasNext()) {
                    System.out.println(eit.next());
                }
                */


                Iterator it = mappedGenes.iterator();

                while (it.hasNext()) {
                    Object o = it.next();
                    if (o instanceof Gene) {
                        Gene g = (Gene) o;
                        allGenes.add(g.getSymbol());
                    }
                }

            }catch (Exception e) {
                e.printStackTrace();
            }

        }else if (accId.toLowerCase().startsWith("qtl")) {
            try {

                String symbol = accId.substring(4);

                QTLDAO qdao = new QTLDAO();
                QTL qtl = qdao.getQTLBySymbol(symbol,3);

                MapDAO mdao = new MapDAO();
                List<MapData> mdList = mdao.getMapData(qtl.getRgdId(),mapKey);
                MapData md = mdList.get(0);

                GeneDAO gdao = new GeneDAO();
                List<Gene> genes = gdao.getActiveGenesSortedBySymbol(md.getChromosome(), md.getStartPos(), md.getStopPos(),mapKey);

                for (Gene g: genes) {
                    allGenes.add(g.getSymbol());
                }

            }catch (Exception e) {
                System.out.println("QTL not found");
            }

        } else {

            ArrayList terms = new ArrayList();

            OntologyXDAO odao = new OntologyXDAO();
            TermWithStats tws = odao.getTermWithStatsCached(accId,null);

            AnnotationDAO adao = new AnnotationDAO();
            int count=tws.getAnnotObjectCountForSpecies(speciesType);

            terms.add(accId);

            //check the size first
            if (count < 2000) {
                allGenes = adao.getAnnotatedGeneSymbols(terms,speciesType);

            }else {


            }

        }

        ArrayList<String> genes = new ArrayList<String>();
        HashMap exclusions = (HashMap) aSubGenes.get(i);

        for (String gene: allGenes) {
            if (!exclusions.containsKey(gene)) {
                genes.add(gene);
            }
        }

        aGenes.add(genes);
        allGenes = new ArrayList<String>();
    }

    newList = aGenes.get(0);
    for (int i=1; i < aAccIds.size(); i++ ) {

        String operator = aOperators.get(i);

        if (operator.equals("~")) {
            newList = ListUtils.union(newList, aGenes.get(i));
        }

        if (operator.equals("^")) {
            newList = ListUtils.subtract(newList, aGenes.get(i));
        }

        if (operator.equals("!")) {
            newList = ListUtils.intersection(newList, aGenes.get(i));
        }
    }
    %>
       <script>showScreen("questionBox");</script>

    <%


}   else {
    //list was empty, show question
    %>
      <script>
          showScreen("actionBox","Welcome!  To get started, select root gene list from the options below" );
      </script>
    <%
}
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



<% if (aAccIds.size() > 0 ) { %>

<style>
.info {
    overflow-y: scroll;
    overflow-x: hidden;
    padding-right: 5px;
    visibility: visible;
    border: thin solid black;
    background-color:white;
    margin-top:15px;
    scrollbar-face-color: #336699; scrollbar-3dlight-color: #336699; scrollbar-base-color: #336699;
    scrollbar-track-color: #336699; scrollbar-darkshadow-color: #000; scrollbar-arrow-color: #000;
    scrollbar-shadow-color: #fff; scrollbar-highlight-color: #fff;
    height:57px;
    font-size:14px;
    width:500px;
}
</style>


<table width=100% border=0>
    <tr>
        <td>
            <div style="font-size:22;color:#1A456F;margin-top:10px;">WorkBench</div>
        </td>

        <% if (om.getLog().size() > 0) { %>
        <td align="right">
              Log:
        </td>
        <td align="right" width=10>
            <div id="warningBox" class=info>
                        <%
                            Iterator logIt = om.getLog().iterator();
                            String msg = "";
                            while (logIt.hasNext()) {
                                out.print(logIt.next() + "<br>");
                            }
                        %>
            </div>

        </td>
        <% } %>
    </tr>
</table>




<table border="0" style="margin-top:20px; margin-bottom:20px;">
    <tr>
        <td>

<%
    for (int i=0; i < aAccIds.size(); i++ ) {
        String accId = aAccIds.get(i);

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
        <b><%  if (aOperators.get(i).equals("~")) out.print("&nbsp;UNION&nbsp;"); %></b>
        <b><%  if (aOperators.get(i).equals("!")) out.print("&nbsp;INTERSECT&nbsp;"); %></b>
        <b><%  if (aOperators.get(i).equals("^")) out.print("&nbsp;SUBTRACT&nbsp;"); %></b>

    <% }else { %>
        <% for (int j=1; j< aAccIds.size(); j++) { %>
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
        for (int i=0; i < aAccIds.size(); i++ ) {
       %>
        <td>
            <%
            String accId = aAccIds.get(i);

            String op = "Union";
            if (aOperators.get(i).equals("^")) {
                op = "Subtract";
            }
            if (aOperators.get(i).equals("!")) {
                op = "Intersect";
            }

     %>
<% if (i > 0) { %>
    <td valign="top">
    <div style="float:left;">
        <br><br>
         <select id="op-<%=i%>" style="border:1px solid black;" onchange="updateOperation(this)">
            <option value="~" <%  if (aOperators.get(i).equals("~")) out.print("selected"); %>>Union</option>
            <option value="^" <%  if (aOperators.get(i).equals("^")) out.print("selected"); %>>Subtract</option>
            <option value="!" <%  if (aOperators.get(i).equals("!")) out.print("selected"); %>>Intersect</option>
        </select>
    </div>
</td>
<% } %>

<td valign="top">
<div style="border-right:1px solid <%=colors[i]%>; border-top:5px solid <%=colors[i]%>; padding:5px; margin: 5px; display: inline-block;">
<div style="text-align:right;"><a href="javascript:removeTerm(<%=i%>)"><img src="/rgdweb/common/images/del.jpg" border=0 /></a> </div>

<%  System.out.println("gene list size = " + aGenes.size()); %>

<% if (aGenes.get(i).size()==0) { %>
   Empty
<%
}

for (String gene: aGenes.get(i)) {
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
       <td><div style="font-weight:700; font-size:20px; background-color:#3F3F3F; color:white; padding-right:5px;">Result&nbsp;Set</div></td>
   </tr>
   <tr>
       <td>

<div id="resultSet" style="border:0px solid black; float:left; padding:7px; margin-left:5px;">
<%
    if (newList.size() == 0) {
        %>
      Empty&nbsp;Set
    <%
    }

    Iterator it = newList.iterator();
    while(it.hasNext()) {
        String gene = (String)it.next();
    %>
      <%=gene%><br>
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

<% }

} catch (Exception e) {
    e.printStackTrace();
}%>


<br><br><br>
<jsp:include page="/common/footerarea.jsp"/>