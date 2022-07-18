<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.phenominer.frontend.OTrees" %>
<%@ page import="org.springframework.web.servlet.ModelAndView" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%
    String pageTitle = "Phenominer";
    String headContent = "";
    String pageDescription = "";

    int species=3;
    if (request.getParameter("species") != null && !request.getParameter("species").equals("")) {
        species=Integer.parseInt(request.getParameter("species"));
    }


    OTrees ot = OTrees.getInstance();

    String sex = (String) request.getAttribute("sex");;
    List<String> sampleIds = (List<String>) request.getAttribute("sampleIds");
    List<String> mmIds = (List<String>) request.getAttribute("mmIds");
    List<String> cmIds = (List<String>) request.getAttribute("cmIds");
    List<String> csIds = (List<String>) request.getAttribute("csIds");
    List<String> ecIds = (List<String>) request.getAttribute("ecIds");

    OntologyXDAO odao = new OntologyXDAO();

    String selectedMeasurements = "{";
    String selectedStrains = "{";
    String selectedConditions = "{";
    String selectedMethods = "{";

    boolean first = true;
    for (String mmId: mmIds) {
        Term t = odao.getTermByAccId(mmId);

        if (!first) {
            selectedMethods+=",";
        }
        selectedMethods+= "\"" + t.getTerm() + "\":" + "\"" + t.getAccId() + "\"";
        first=false;
    }
    selectedMethods+="}";


    first=true;
    for (String cmId: cmIds) {
        Term t = odao.getTermByAccId(cmId);

        if (!first) {
            selectedMeasurements+=",";
        }
        selectedMeasurements+= "\"" + t.getTerm() + "\":" + "\"" + t.getAccId() + "\"";
        first=false;
    }
    selectedMeasurements+="}";

    first=true;
    for (String sampleId: sampleIds) {
        Term t = odao.getTermByAccId(sampleId);

        if (!first) {
            selectedStrains+=",";
        }
        selectedStrains+= "\"" + t.getTerm() + "\":" + "\"" + t.getAccId() + "\"";
        first=false;
    }
    selectedStrains+="}";

    first=true;
    for (String ecId: ecIds) {
        Term t = odao.getTermByAccId(ecId);

        if (!first) {
            selectedConditions+=",";
        }
        selectedConditions+= "\"" + t.getTerm() + "\":" + "\"" + t.getAccId() + "\"";
        first=false;
    }
    selectedConditions+="}";

    String termString = (String) request.getAttribute("termString");

    if (termString != null && !termString.equals("")) {
        out.print("<script>sessionStorage.clear()</script>");
    }
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

<script>

    function updateSpecies(species) {
        sessionStorage.clear();
        location.href = "/rgdweb/phenominer/ontChoices.html?species=" + species;
    }
</script>



<table width="95%" cellspacing="1px" border="0">
    <tr>
        <td style="color: #2865a3; font-size: 26px; font-weight:700;">PhenoMiner Database</td>
        <!--
        <td>
            <span style="font-size:18px">Species</span>
            <select name="species" style="font-size:18px" onChange="updateSpecies(this.value)">
                <option value="3" <% if (species==3) out.print("selected"); %> style="font-size:18px">Rat</option>
                <option value="4" <% if (species==4) out.print("selected"); %> style="font-size:18px">Chinchilla</option>
            </select>
        </td>
        -->
        <td align="right" colspan="2"><input style="padding-left:10px; padding-right:10px; border:1px solid white; color:white; font-size:16px;background-color:#2B84C8; border-radius:5px;" type="button" value="Clear" onClick="sessionStorage.clear();location.href='/rgdweb/phenominer/ontChoices.html'"/></td>
    </tr>
    <tr>
        <td>
            <span style="font-size:16px;">Select values from categories of interest and select <b>"Generate Report"</b> to build report</span>
        </td>
    </tr>
    <tr>
        <td>&nbsp;</td>
    </tr>
</table>

<div id="phenominer" >

    <table cellspacing='0' border='0' style="border:0px solid black" width="95%">
    <tr>

        <% if (false) { %>
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
                        <td valign="top" align="center"><input style="font-weight: 700;" type="button" value="Select Sources" onClick="location.href='/rgdweb/phenominer/selectTerms.html?terms=<%=termString%>&ont=CS&species=<%=species%>'" /><br><br></td>
                    </tr>
                </table>
            </div>
            <div style='background-color: white; padding: 5px; border: 2px black inset;'>

            </div>
        </td>
        <% } %>

        <% if (species==3) { %>
        <td valign='top' style='padding: 5px ;vertical-align: top; background-color: #d7e4bd; border-top: 1px solid black;border-left: 1px solid black;border-right: 3px outset black;border-bottom: 3px outset black;'>
            <div style='font-weight: 700;'>
                <table border="0"  width="100%" style="background-color: #d7e4bd">
                    <tr>
                        <td  height="60" style="font-size:20px; background-color: #d7e4bd; " valign="top"><div style="height:50px; width:100%; border-bottom: 3px solid white">Rat Strains<br><span style="font-size:11px; ">Search for data related to one or more rat strains.</span></div></td>
                    </tr>
                </table>
            </div>
            <div style='background-color: white; padding: 5px; border: 2px black inset;height:200px;overflow:scroll;'>

                <table>
                    <tr v-for="(key, value) in selectedStrains">
                        <td width="15"><img style="padding-right:3px;cursor:pointer;" @click="remove(key,'RS')" src="/rgdweb/common/images/del.jpg"/></td>

                        <!--<td>{{key}}</td>-->

                        <td style="font-size:12px;" align="left" ><span v-if="value.indexOf('(0)') > 0"><s style="color:grey;">{{value}}</s></span><span v-else><b>{{value}}</b></span></td>
                    </tr>
                </table>


            </div>
        </td>
        <% } else { %>

        <td valign='top' style='padding: 5px ;vertical-align: top; background-color: #d7e4bd; border-top: 1px solid black;border-left: 1px solid black;border-right: 3px outset black;border-bottom: 3px outset black;'>
            <div style='font-weight: 700;'>
                <table border="0"  width="100%" style="background-color: #d7e4bd">
                    <tr>
                        <td  height="60" style="font-size:20px; background-color: #d7e4bd; " valign="top"><div style="height:50px; width:100%; border-bottom: 3px solid white">Chinchilla Sources<br><span style="font-size:11px; ">Search for data related to one or more chinchilla sources.</span></div></td>
                    </tr>
                </table>
            </div>
            <div style='background-color: white; padding: 5px; border: 2px black inset;height:200px;overflow:scroll;'>

                <table>
                    <tr v-for="(key, value) in selectedStrains">
                        <td width="15"><img style="padding-right:3px;cursor:pointer;" @click="remove(key,'RS')" src="/rgdweb/common/images/del.jpg"/></td>

                        <!--<td>{{key}}</td>-->
                        <td style="font-size:12px;" align="left" ><span v-if="value.indexOf('(0)') > 0"><s style="color:grey;">{{value}}</s></span><span v-else><b>{{value}}</b></span></td>
                    </tr>
                </table>


            </div>
        </td>

        <%}%>




        <td valign='top' style='padding: 5px ;vertical-align: top; background-color: #ccc1da; border-top: 1px solid black;border-left: 1px solid black;border-right: 3px outset black;border-bottom: 3px outset black;'>
            <div style='font-weight: 700;'>
                <table border="0"  width="100%" style="background-color: #ccc1da">
                    <tr>
                        <td  height="60" style="font-size:20px; background-color: #ccc1da; " valign="top"><div style="height:50px; width:100%; border-bottom: 3px solid white">Clinical Measurements<br><span style="font-size:11px; ">Query by clinical measurement.</span></div></td>
                    </tr>
                </table>
            </div>
            <div style='background-color: white; padding: 5px; border: 2px black inset;height:200px;overflow:scroll;'>
                <table>
                    <tr v-for="(key, value) in selectedMeasurements">
                        <td width="15"><img style="padding-right:3px;cursor:pointer;" @click="remove(key,'CMO')" src="/rgdweb/common/images/del.jpg"/></td>
                        <!--<td>{{key}}</td>-->
                        <td style="font-size:12px;" align="left" ><span v-if="value.indexOf('(0)') > 0"><s style="color:grey;">{{value}}</s></span><span v-else><b>{{value}}</b></span></td>
                    </tr>
                </table>

            </div>
        </td>


        <td valign='top' style='padding: 5px ;vertical-align: top; background-color: #fcd5b5; border-top: 1px solid black;border-left: 1px solid black;border-right: 3px outset black;border-bottom: 3px outset black;'>
            <div style='font-weight: 700;'>
                <table border="0"  width="100%" style="background-color: #fcd5b5">
                    <tr>
                        <td  height="60" style="font-size:20px; background-color: #fcd5b5; " valign="top"><div style="height:50px; width:100%; border-bottom: 3px solid white">Measurement Methods<br><span style="font-size:11px; ">Filter results by Measurement method.</span></div></td>
                    </tr>
                </table>
            </div>
            <div style='background-color: white; padding: 5px; border: 2px black inset;height:200px;overflow:scroll;'>
                <table>
                    <tr v-for="(key, value) in selectedMethods">
                        <td width="15"><img style="padding-right:3px;cursor:pointer;" @click="remove(key,'MMO')" src="/rgdweb/common/images/del.jpg"/></td>
                        <!--<td>{{key}}</td>-->
                        <td style="font-size:12px;" align="left" ><span v-if="value.indexOf('(0)') > 0"><s style="color:grey;">{{value}}</s></span><span v-else><b>{{value}}</b></span></td>
                    </tr>
                </table>

            </div>
        </td>


        <td valign='top' style='padding: 5px ;vertical-align: top; background-color: #b9cde5; border-top: 1px solid black;border-left: 1px solid black;border-right: 3px outset black;border-bottom: 3px outset black;'>
            <div style='font-weight: 700;'>
                <table border="0"  width="100%" style="background-color: #b9cde5">
                    <tr>
                        <td  height="60" style="font-size:20px; background-color: #b9cde5; " valign="top"><div style="height:50px; width:100%; border-bottom: 3px solid white">Experimental Conditions<br><span style="font-size:11px; ">Filter based condition.</span></div></td>
                    </tr>
                </table>
            </div>
            <div style='background-color: white; padding: 5px; border: 2px black inset;height:200px;overflow:scroll;'>
                <table>
                    <tr v-for="(key, value) in selectedConditions">
                        <td width="15"><img style="padding-right:3px;cursor:pointer;" @click="remove(key,'XCO')" src="/rgdweb/common/images/del.jpg"/></td>
                        <!--<td>{{key}}</td>-->
                        <td style="font-size:12px;" align="left" ><span v-if="value.indexOf('(0)') > 0"><s style="color:grey;">{{value}}</s></span><span v-else><b>{{value}}</b></span></td>
                    </tr>
                </table>

            </div>
        </td>
        </tr>
        <tr>
            <td  colspan=4 align="center"><input type="button" style="margin-top:20px; width:300px; border:1px solid white; color:white; font-size:26px;background-color:#2B84C8; border-radius:5px;" @click="generateReport()" value="Generate Report"/></td>
        </tr>
</table>

<!--- other page  -->

<%
    pageTitle = "Phenominer";
    headContent = "";
    pageDescription = "";


    String ont = "RS";
    String ontParam = request.getParameter("ont");
    if( ontParam!=null ) {
        ont = ontParam;
    }

    // 'sex' param only valid for 'RS' ontology
    sex = "";
    if( ont.equals("RS") ) {
        sex = "both";
        String sexParam = request.getParameter("sex");
        if( sexParam!=null && (sexParam.equals("male") || sexParam.equals("female")) ) {
            sex = sexParam;
        }
    }

    String terms =  Utils.defaultString(request.getParameter("terms"));

    String ontName = ont.equals("RS") ? "Rat Strains" :
            ont.equals("CS") ? "Chinchilla" :
                    ont.equals("MMO") ? "Measurement Methods" :
                            ont.equals("CMO") ? "Clinical Measurements" :
                                    ont.equals("XCO") ? "Experimental Conditions" : "";
%>




    <br>
    <div id="ontologyLoadingMessage" style="position:absolute; top:20; padding:20px; background-color:#D7E4BD; color:black;font-size:30px; border-radius:20px;">Loading Rat Strain Ontology....</div>
    <table align="left" width="1000" border="0" id="selectionWindow" style="visibility:hidden;">
        <tr>
            <td colspan="2"style="font-size:24px;">{{title}}</td>
        </tr>
        <tr>
            <td colspan="2"><input id="termSearch" :placeholder="examples" v-model="searchTerm" size="40" style="border: 3px solid black;height:38px;width:600px;" v-on:input="search()"/></td>
            <td valign="center" align="center"><input style="position:relative; top:5px; border-top-left-radius:10px; background-color:#D7E4BD; font-weight: 700;height:35px;width:80px; font-size:12px;" type="button" value="Strains" @click="update('RS',<%=species%>)" /></td>
            <td valign="center" align="center"><input style="position:relative; top:5px;  background-color:#CCC1DA; font-weight: 700;height:35px;width:150px; font-size:12px;" type="button" value="Clinical Measurements" @click="update('CMO',<%=species%>)"  /></td>
            <td valign="center" align="center"><input style="position:relative; top:5px;  background-color:#FCD5B5; font-weight: 700;height:35px;width:150px; font-size:12px;" type="button" value="Measurement Methods" @click="update('MMO',<%=species%>)"  /></td>
            <td valign="center" align="center"><input style="position:relative; top:5px;  border-top-right-radius:10px; background-color:#B9CDE5; font-weight: 700;height:35px;width:160px; font-size:12px;" type="button" value="Experimental Conditions"  @click="update('XCO',<%=species%>)"  /></td>
        </tr>
        <tr>
            <td width="50">
                <div style="overflow:scroll;height:450px;width:600px;border: 1px solid black;">
                    <h3 v-if="optionsNotEmpty"><br>&nbsp;0 Records found for Term: <b>{{searchTerm}}</b></h3>
                    <table>
                        <tr v-for="(key, value) in options" >
                                    <td width="15"><input type="button" value="select" @click="selectByTermId(key)" style="height:17px;padding-left:5px;"/></td>
                                    <!--<td>{{key}}</td>-->
                                    <td style="font-size:12px;" align="left">{{value}}</td>
                                </tr>
                            </table>
                </div>

            </td>
            <td align="left" valign="top" width="500">
                <div id="placeholder" style="position:absolute;">&nbsp;</div>
            </td>
        </tr>
    </table>

    <span id="dataStatus" style="color:red"></span>
    <div id="extra" style="color:blue;background-color:yellow;">
    </div>

</div>

<div id="treebox" style="visibility:hidden; z-index:1000;float:right; padding: 7px; width:580px; height:450px; font: 14px verdana, arial, helvetica, sans-serif; border-left: 5px solid black;border-right: 5px solid black;border-bottom: 5px solid black;border-top: 10px solid black;" tabindex="0">
    <div id="loading" style="font-size:14px; font-weight:700;">&nbsp;Loading Available <%=ontName%> ... (Please Wait)</div>
</div>


<table width="95%">
    <tr>
        <td width="50%">
        </td>
        <td>
        </td>
    </tr>
</table>


<script type="text/javascript" src="/rgdweb/js/xml2json.js"></script>

<script>
    var gviewer = null;
</script>

<script type="text/javascript" src="/rgdweb/js/dhtmlxTree/dhtmlxcommon.js"></script>
<script type="text/javascript" src="/rgdweb/js/dhtmlxTree/dhtmlxtree.js?1"></script>
<link rel="stylesheet" type="text/css" href="/rgdweb/js/dhtmlxTree/dhtmlxtree.css?3"/>


<script>
    $(document).ready(function(){

        keyFilterFunc = function(event){
            if (event.target.tagName == "INPUT") return true;
            if (event.which == 27 || event.which==8) {
                $("#termSearch").val("");
                $("#termSearch").focus();
                return false;
            }
            return true;
        }

        $("#treebox").keydown(keyFilterFunc);
        $("#treebox").keypress(keyFilterFunc);
        document.onkeydown =  keyFilterFunc;
        document.onkeypress = keyFilterFunc;
    });

    function selectByTermId(termId) {
        var patt1=/(.+):(\d+)/;
        var matched = termId.match(patt1);
        if (matched != null) {
            tree.closeAllItems();
            var ontId = termId;
            var list = tree.getAllSubItems("0");
            var idExist = selectNode(list, ontId);
            goToNode(ontId+"_1");
            if (!idExist) $("#dataStatus").html("No data available for this term!");
        }
    }


    function hello() {

        var list = tree.getAllSubItems("0");

        var idArray = (list.toString().split(","));
        for(var i in idArray) {
            var newNodeOnt = idArray[i].match(/\w+:\d+/);
            if(newNodeOnt === null) {
                continue;
            } else {
                var treeNode = tree._idpull[idArray[i]].htmlNode;
                //alert(treeNode.innerHTML);
            }
        }





    }

    /*
    function selectByTermId_orig(termId) {
        var patt1=/(.+):(\d+)/;
        var matched = termId.match(patt1);
        if (matched[2] != null) {
            tree.closeAllItems();
            var numTermId = parseFloat(matched[2]);
            var ontId = matched[1] + ":" + String(numTermId);
            var list = tree.getAllSubItems("0");
            var idExist = selectNode(list, ontId);
            goToNode(ontId+"_1");
            if (!idExist) $("#dataStatus").html("No data available for this term!");
        }
    }
*/
    function goToNode(nodeId) {
        tree.selectItem(nodeId);
        var treeNode = tree._idpull[nodeId].htmlNode;
        var y = 0;
        var x = 0;
        var startNode = treeNode;
        while (treeNode.tagName != "DIV") {
            if (treeNode.tagName == "TR") y += treeNode.offsetTop;
            if (treeNode.tagName == "TD") x += treeNode.offsetLeft;
            treeNode = treeNode.parentElement;
        }
        if (y > 180) {
            y -= 180;
        } else {
            y = 0;
        }
        $($("#treebox").children().get(1)).animate({scrollTop: y},'normal');
    }

    function selectNode(list, ontId) {
        var idArray = (list.toString().split(","));
        var idExist = false;
        for(var i in idArray) {
            var newNodeOnt = idArray[i].match(/\w+:\d+/);
            if(newNodeOnt === null) {
                continue;
            }
            if(ontId == newNodeOnt.toString()) {
                tree.selectItem(idArray[i]);
                idExist = true;
            }
        }
        return idExist;
    }

</script>




<script type="text/javascript">
    var tree="";


    function initTree() {
        tree = new dhtmlXTreeObject("treebox","100%","100%",0);
        tree.enableCheckBoxes(1);
        tree.enableThreeStateCheckboxes(1);
        tree.setImagePath("/rgdweb/js/dhtmlxTree/imgs/");

        tree.attachEvent("onCheck", handleCheckbox);
        tree.attachEvent("onCheck",passToVue);

        tree.setXMLAutoLoading("/rgdweb/phenominer/treeXml.html?ont=<%=ont%>&sex=<%=sex%>&species=<%=species%>&terms=<%=terms%>");
        tree.loadXML("/rgdweb/phenominer/treeXml.html?ont=<%=ont%>&sex=<%=sex%>&species=<%=species%>&terms=<%=terms%>");

    }
    function handleCheckbox(nodeId, checkedState) {
        var ontId = nodeId.toString();
        ontId = ontId.match(/\w+:\d+/);
        var list;
        if(checkedState == 0) {
            list = tree.getAllChecked();
        }
        if(checkedState == 1) {
            list = tree.getAllUnchecked();
        }
        var idArray = (list.toString().split(","));
        for(var i in idArray) {
            var newNodeOnt = idArray[i].match(/\w+:\d+/);
            if(newNodeOnt === null) {
                continue;
            }
            if(ontId == newNodeOnt.toString() && (tree.hasChildren(nodeId) == tree.hasChildren(idArray[i]))) {
                tree.setCheck(idArray[i], checkedState);
                if(checkedState == 1){
                    // openAllParents(idArray[i]);
                }
            }
        }

        // need to handle the redundant children of a term too
        var children = tree.getSubItems(nodeId);
        if(children) {
            children = children.toString().split(",");
            for(var j in children) {
                handleCheckbox(children[j], checkedState);
            }
        }
    }

    function openAllParents(id) {
        tree.openItem(id);
        if(id != tree.getParentId(id)){ // stop at root
            openAllParents(tree.getParentId(id))
        }
    }

    function passToVue() {
        v.doStuff();
    }

    function determineChecked() {
        var hash = {};
        var list = tree.getAllChecked();
        // hacky but I don't have the real API of what list is
        var idArray = (list.toString().split(","));
        for(var i in idArray){
            // only include leaf elements
            if(!tree.hasChildren(idArray[i])){
                var ontId = idArray[i].match(/\w+:\d+/);
                if(ontId !== null) {
                    hash[ontId] = true;
                }
            }

            //but hidden leafs don't count as checked so we
            // have to add them manually.
            var children = tree.getSubItems(idArray[i]);
            if(children) {
                children = children.toString().split(",");
                for(var j in children) {
                    if(!tree.hasChildren(children[j])){
                        ontId = children[j].match(/\w+:\d+/);
                        if(ontId !== null) {
                            hash[ontId] = true;
                        }
                    }
                }
            }
        }

        var ids = [];
        for(var oid in hash) {
            ids.push(oid);
        }
        return ids;
    }

    function makeSelection() {
        var checkedTerms = determineChecked();
        var paramTermString = decodeURI("<%=terms%>");
        var sexLimit = "<%=sex%>";

        var ont = "<%=ont%>";
        var href = "/rgdweb/phenominer/ontChoices.html";
        var newParamTermString;

        var nonOntTerms = [];
        var paramTerms = paramTermString.split(",");


        for (var i in paramTerms) {
            var t = paramTerms[i]
            var paramPrefix = t.split(":")[0];
            if(t && (ont != paramPrefix)) { // have the case where paramTerms is empty and we get a null t
                nonOntTerms.push(t);
            }
        }

        var termArray = nonOntTerms.concat(checkedTerms);

        newParamTermString = termArray.join(",");
        if(newParamTermString || sexLimit) {
            href = href + "?"
        }
        if(sexLimit) {
            href = href + "sex=" + sexLimit;
        }
        if(newParamTermString) {
            href= href + (sexLimit ? "&" : "") + "terms=" + newParamTermString;
        }

        href=href + "&species=<%=species%>";

        location.href = href;
    }






    function getElementTopLeft(id) {

        var ele = document.getElementById(id);
        var top = 0;
        var left = 0;

        while(ele.tagName != "BODY") {
            top += ele.offsetTop;
            left += ele.offsetLeft;
            ele = ele.offsetParent;
        }

        return { top: top, left: left };

    }




</script>


<script>

    var div = '#phenominer';

    var host = window.location.protocol + window.location.host;

    if (window.location.host.indexOf('localhost') > -1) {
        host =  'http://localhost:8080';
    } else if (window.location.host.indexOf('dev.rgd') > -1) {
        host = window.location.protocol + '//dev.rgd.mcw.edu';
    }else if (window.location.host.indexOf('test.rgd') > -1) {
        host = window.location.protocol + '//test.rgd.mcw.edu';
    }else if (window.location.host.indexOf('pipelines.rgd') > -1) {
        host = window.location.protocol + '//pipelines.rgd.mcw.edu';
    }else {
        host = window.location.protocol + '//rest.rgd.mcw.edu';
    }

    var v = new Vue({
        el: div,
        data: {
            optionsNotEmpty:  false,
            title: "",
            searchTerm: "",
            hostName: host,
            options:{},
            symbolHash: {},
            keyMap: {},
            selectedStrains: <%=selectedStrains%>,
            selectedMeasurements: <%=selectedMeasurements%>,
            selectedConditions: <%=selectedConditions%>,
            selectedMethods: <%=selectedMethods%>,
            selectedStrainsRemoved: <%=selectedStrains%>,
            selectedMeasurementsRemoved: <%=selectedMeasurements%>,
            selectedConditionsRemoved: <%=selectedConditions%>,
            selectedMethodsRemoved: <%=selectedMethods%>,

            currentOnt: "RS",
            examples: "",
            axiosRequest: new AbortController(),
        },
        methods: {

            selectByTermId: function(val) {
                goToNode(val);
                handleCheckbox(val, 1);
                v.doStuff();
                //tree.selectItem(val);
                //selectByTermId(val);
            },
            search: function () {
                this.axiosRequest.abort();

                v.options={};

                v.optionsNotEmpty = true;

                var subCat = 'RS:%20Rat%20Strains';
                if (this.currentOnt === "MMO") {
                    var subCat = 'MMO:%20Measurement%20Methods';

                }else if (this.currentOnt === "XCO") {
                    var subCat = 'XCO:%20Experimental%20Condition';

                }else if (this.currentOnt === "CMO") {
                    var subCat = 'CMO:%20Clinical%20Measurement';

                }

               // alert(v.searchTerm);
                if (v.searchTerm === "") {
                    for (var key in v.symbolHash) {
                            v.options[key] = v.symbolHash[key];
                            v.optionsNotEmpty=false;
                    }
                }else {

                    axios
                        .get(this.hostName + '/rgdweb/phenominerTermSearch.html?term=' + v.searchTerm + '&category=Ontology&subCat=' + subCat + '&species=&cat1=General&sp1=&postCount=1',
                            {
                                species: "hell",
                            })
                        .then(function (response) {
                            for (var searchKey in response.data) {
                                for (var key in v.symbolHash) {
                                    if (v.symbolHash[key].indexOf(searchKey) != -1) {
                                        v.options[key] = v.symbolHash[key];
                                        v.optionsNotEmpty = false;
                                    }
                                }
                            }

                        })
                        .catch(function (error) {
                            console.log(error)
                            v.errored = true
                        })
                }


            },

            updateConditionBox: function() {
                if (JSON.stringify(v.selectedConditions) === "{}") {
                    return;
                }

                axios
                    .get(this.hostName + '/rgdweb/phenominer/treeXml.html?ont=XCO&sex=both&species=3&terms=' + v.getAllTerms(),
                        {
                            species: "hell",
                        })
                    .then(function (response) {
                        var parser = new DOMParser();
                        xmlDoc = parser.parseFromString(response.data + "", "text/xml");

                        var root = xmlDoc.getRootNode();
                        //var root = xmlDoc.getElementsByTagName("tree");
                        var childNodes = root.getElementsByTagName("item");

                        var children = v.getLeafNodes(childNodes);

                        //find out if a selection is now gone
                        var tmpHash = {};
                        for (var key in v.selectedConditions) {
                            var found=false;
                            for (let i = 0; i < children.length; i++) {
                                let item = children[i];
                                var idArr = (item.getAttribute("id") + "").split("_");
                                var id = idArr[0];

                                if (v.selectedConditions[key] === id) {
                                    tmpHash[item.getAttribute("text")] = id;
                                    found=true;
                                    // v.selectedStrains[key] == null;
                                    //break;
                                }
                            }
                            if (!found) {
                                if (key.indexOf("(0)") > 0) {
                                    tmpHash[key] = v.selectedConditions[key];
                                }else {
                                    tmpHash[key + "(0)"] = v.selectedConditions[key];
                                }

                            }
                        }


                        v.selectedConditions = {};
                        for (key in tmpHash) {
                            v.selectedConditions[key] = tmpHash[key];
                        }

                        //v.selectedConditions = tmpHash;


                    })
                    .catch(function (error) {
                        console.log(error)
                        v.errored = true
                    })

            },

            getLeafNodes: function(node) {

                var children=[];
                for (j=0; j< node.length; j++) {
                    //console.log("node list length " + node.length);
                    //console.log(node[j].hasChildNodes());
                    if (node[j].children.length == 0) {
                        //console.log("node = " + JSON.stringify(node[j]));
                        children[children.length] = node[j];
                    } else {
                        //v.getLeafNodes(node[j]);
                        //console.log("has children");
                        }

                }

                return children;

            },

            updateStrainBox: function() {
                //alert(JSON.stringify(v.selectedStrains));

                //alert(this.hostName + '/rgdweb/phenominer/treeXml.html?ont=RS&sex=both&species=3&terms=' + v.getAllTerms());

                if (JSON.stringify(v.selectedStrains) === "{}") {
                    return;
                }
                axios
                    .get(this.hostName + '/rgdweb/phenominer/treeXml.html?ont=RS&sex=both&species=3&terms=' + v.getAllTerms(),
                        {
                            species: "hell",
                        })
                    .then(function (response) {
                        var parser = new DOMParser();
                        xmlDoc = parser.parseFromString(response.data + "", "text/xml");

                        var root = xmlDoc.getRootNode();

                        //var root = xmlDoc.getElementsByTagName("tree");
                        var childNodes = root.getElementsByTagName("item");
                        var children = v.getLeafNodes(childNodes);

                        //find out if a selection is now gone
                        var tmpHash = {};
                        for (var key in v.selectedStrains) {
                            var found=false;
                            for (let i = 0; i < children.length; i++) {
                                let item = children[i];
                                var idArr = (item.getAttribute("id") + "").split("_");
                                var id = idArr[0];

                                if (v.selectedStrains[key] === id) {
                                    tmpHash[item.getAttribute("text")] = id;
                                    found=true;
                                    // v.selectedStrains[key] == null;
                                    //break;
                                }
                            }
                            if (!found) {
                                if (key.indexOf("(0)") > 0) {
                                    tmpHash[key] = v.selectedStrains[key];
                                }else {
                                    tmpHash[key + "(0)"] = v.selectedStrains[key];
                                }

                            }
                        }

                        v.selectedStrains = {};
                        for (key in tmpHash) {
                            v.selectedStrains[key] = tmpHash[key];
                        }

                        //v.selectedConditions = tmpHash;

                    })
                    .catch(function (error) {
                        console.log(error)
                        v.errored = true
                    })


            },
            updateMethodBox: function() {
                console.log("Called update method box");

                if (JSON.stringify(v.selectedMethods) === "{}") {
                    return;
                }
                axios
                    .get(this.hostName + '/rgdweb/phenominer/treeXml.html?ont=MMO&sex=both&species=3&terms=' + v.getAllTerms(),
                        {
                            species: "hell",
                        })
                    .then(function (response) {
                        var parser = new DOMParser();
                        xmlDoc = parser.parseFromString(response.data + "", "text/xml");

                        var root = xmlDoc.getRootNode();
                        //var root = xmlDoc.getElementsByTagName("tree");
                        var childNodes = root.getElementsByTagName("item");

                        var children = v.getLeafNodes(childNodes);


                        //find out if a selection is now gone
                        var tmpHash = {};
                        for (var key in v.selectedMethods) {
                            var found=false;
                            for (let i = 0; i < children.length; i++) {
                                let item = children[i];
                                var idArr = (item.getAttribute("id") + "").split("_");
                                var id = idArr[0];

                                if (v.selectedMethods[key] === id) {
                                    tmpHash[item.getAttribute("text")] = id;
                                    found=true;
                                    // v.selectedStrains[key] == null;
                                    //break;
                                }
                            }
                            if (!found) {
                                if (key.indexOf("(0)") > 0) {
                                    tmpHash[key] = v.selectedMethods[key];
                                }else {
                                    tmpHash[key + "(0)"] = v.selectedMethods[key];
                                }

                            }
                        }


                        v.selectedMethods = {};
                        for (key in tmpHash) {
                            v.selectedMethods[key] = tmpHash[key];
                        }

                        //v.selectedConditions = tmpHash;


                    })
                    .catch(function (error) {
                        console.log(error)
                        v.errored = true
                    })


            },
            updateMeasurementBox: function() {
                if (JSON.stringify(v.selectedMeasurements) === "{}") {
                    return;
                }
                alert("calling 3");

                axios
                    .get(this.hostName + '/rgdweb/phenominer/treeXml.html?ont=CMO&sex=both&species=3&terms=' + v.getAllTerms(),
                        {
                            species: "hell",
                        })
                    .then(function (response) {
                        var parser = new DOMParser();
                        xmlDoc = parser.parseFromString(response.data + "", "text/xml");

                        var root = xmlDoc.getRootNode();
                        //var root = xmlDoc.getElementsByTagName("tree");
                        var childNodes = root.getElementsByTagName("item");

                        var children = v.getLeafNodes(childNodes);


                        //find out if a selection is now gone
                        var tmpHash = {};
                        for (var key in v.selectedMeasurements) {
                            var found=false;
                            for (let i = 0; i < children.length; i++) {
                                let item = children[i];
                                var idArr = (item.getAttribute("id") + "").split("_");
                                var id = idArr[0];

                                if (v.selectedMeasurements[key] === id) {
                                    tmpHash[item.getAttribute("text")] = id;
                                    found=true;
                                    // v.selectedStrains[key] == null;
                                    //break;
                                }
                            }
                            if (!found) {
                                if (key.indexOf("(0)") > 0) {
                                    tmpHash[key] = v.selectedMeasurements[key];
                                }else {
                                    tmpHash[key + "(0)"] = v.selectedMeasurements[key];
                                }

                            }
                        }

                        v.selectedMeasurements = {};
                        for (key in tmpHash) {
                            v.selectedMeasurements[key] = tmpHash[key];
                        }

                        //v.selectedConditions = tmpHash;

                    })
                    .catch(function (error) {
                        console.log(error)
                        v.errored = true
                    })

            },

            updateOtherBoxes: function() {
                if (v.currentOnt !== "XCO") {

                    v.updateConditionBox();
                }
                if (v.currentOnt !== "CMO") {
                    v.updateMeasurementBox();
                }
                if (v.currentOnt !== "RS") {
                    v.updateStrainBox();
                }
                if (v.currentOnt !== "MMO") {
                    v.updateMethodBox();
                }

            },

            doStuff: function() {
                console.log("in doStuff");
                var checked = determineChecked();

                if (v.currentOnt==="RS") {
                    v.selectedStrains = {};
                    for (var i = 0; i < checked.length; i++) {
                        v.selectedStrains[v.keyMap[checked[i]]] = checked[i];
                    }
                }
                if (v.currentOnt==="CMO") {
                    v.selectedMeasurements = {};
                    for (var i = 0; i < checked.length; i++) {
                        v.selectedMeasurements[v.keyMap[checked[i]]] = checked[i];
                    }
                }
                if (v.currentOnt==="XCO") {
                    v.selectedConditions = {};
                    for (var i = 0; i < checked.length; i++) {
                        v.selectedConditions[v.keyMap[checked[i]]] = checked[i];
                    }
                }
                if (v.currentOnt==="MMO") {
                    v.selectedMethods = {};
                    for (var i = 0; i < checked.length; i++) {
                        v.selectedMethods[v.keyMap[checked[i]]] = checked[i];
                    }
                }

                v.updateOtherBoxes();

            },

            removeTerm: function (ont, term) {

                console.log("in remove Term ont=" + ont + " term = " + term);

                if (ont === "RS") {
                    for (const key in v.selectedStrains) {
                        if (v.selectedStrains[key] === term) {
                            delete v.selectedStrains[key];
                        }
                    }
                }

                if (ont === "CMO") {
                    for (const key in v.selectedMeasurements) {
                        if (v.selectedMeasurements[key] === term) {
                            delete v.selectedMeasurements[key];
                        }
                    }
                }

                if (ont === "MMO") {
                    for (const key in v.selectedMethods) {
                        if (v.selectedMethods[key] === term) {
                            delete v.selectedMethods[key];
                        }
                    }
                }

                if (ont === "XCO") {
                    for (const key in v.selectedConditions) {
                        if (v.selectedConditions[key] === term) {
                            delete v.selectedConditions[key];
                        }
                    }
                }

            },

            remove: function (accId, ont) {
                console.log("in remove ont=" + ont + " accId = " + term);

                if (ont != this.currentOnt) {
                    this.removeTerm(ont, accId);

                    this.update(this.currentOnt, this.species);
                }else {
                    if (ont === this.currentOnt) {
                        if (ont === "RS") {
                            for (var key in v.selectedStrains) {
                                if (v.selectedStrains[key] === accId) {
                                    handleCheckbox(accId, 0);
                                    v.doStuff()
                                }
                            }
                        }
                        if (ont === "CMO") {
                            for (var key in v.selectedMeasurements) {
                                if (v.selectedMeasurements[key] === accId) {
                                    handleCheckbox(accId, 0);
                                    v.doStuff()
                                }
                            }
                        }
                        if (ont === "MMO") {
                            for (var key in v.selectedMethods) {
                                if (v.selectedMethods[key] === accId) {
                                    handleCheckbox(accId, 0);
                                    v.doStuff()
                                }
                            }
                        }
                        if (ont === "XCO") {
                            for (var key in v.selectedConditions) {
                                if (v.selectedConditions[key] === accId) {
                                    handleCheckbox(accId, 0);
                                    v.doStuff()
                                }
                            }
                        }
                    } else {
                        console.log("need to remvoe fromt the terms");


                    }
                }
            },


            getAllTerms: function (excludeZeroRecordTerms) {
                var termString="";

                var first=true;
                for (const key in v.selectedStrains) {

                    if (excludeZeroRecordTerms && key.indexOf("(0)") > 1) {
                        continue;
                    }

                    if (!first) {
                        termString += ",";
                    }else {
                        first=false;
                    }

                    termString +=v.selectedStrains[key];
                }

                for (const key in v.selectedMeasurements) {

                    if (excludeZeroRecordTerms && key.indexOf("(0)") > 1) {
                        continue;
                    }

                    if (!first) {
                        termString += ",";
                    }else {
                        first=false;
                    }

                    termString +=v.selectedMeasurements[key];
                }

                for (const key in v.selectedConditions) {

                    if (excludeZeroRecordTerms && key.indexOf("(0)") > 1) {
                        continue;
                    }
                    if (!first) {
                        termString += ",";
                    }else {
                        first=false;
                    }

                    termString +=v.selectedConditions[key];
                }

                for (const key in v.selectedMethods) {
                    if (excludeZeroRecordTerms && key.indexOf("(0)") > 1) {
                        continue;
                    }

                    if (!first) {
                        termString += ",";
                    }else {
                        first=false;
                    }

                    termString +=v.selectedMethods[key];
                }

                //alert(termString);
                return termString;

            },

            generateReport: function () {
                var tString = v.getAllTerms(true);



                if (tString === "") {
                    alert("Please select one or more terms below to generate a Phenominer report.");

                }else {
                    this.updateSessionStorage();
                    location.href = "/rgdweb/phenominer/table.html?species=3&terms=" + tString;
                }
            },


            init: function () {
                if (sessionStorage.currentOnt) {
                    this.loadFromSessionStorage();
                }

                v.update();
                v.updateStrainBox();

            },

            loadFromSessionStorage: function() {

                //this.optionsNotEmpty=sessionStorage.optionsNotEmpty;
                this.title=sessionStorage.title;
                this.searchTerm=sessionStorage.searchTerm;
                this.hostName=sessionStorage.hostName;
                this.options=JSON.parse(sessionStorage.options);
                this.symbolHash=JSON.parse(sessionStorage.symbolHash);
                this.keyMap=JSON.parse(sessionStorage.keyMap);
                this.selectedStrains=JSON.parse(sessionStorage.selectedStrains);
                this.selectedConditions=JSON.parse(sessionStorage.selectedConditions);
                this.selectedMeasurements=JSON.parse(sessionStorage.selectedMeasurements);
                this.selectedMethods=JSON.parse(sessionStorage.selectedMethods);
                this.currentOnt=sessionStorage.currentOnt;
            },


            updateSessionStorage: function() {
                //sessionStorage.optionsNotEmpty=this.optionsNotEmpty;
                sessionStorage.title=this.title;
                sessionStorage.searchTerm=this.searchTerm;
                sessionStorage.hostName=this.hostName;
                sessionStorage.options = JSON.stringify(this.options);
                sessionStorage.symbolHash=JSON.stringify(this.symbolHash);
                sessionStorage.keyMap=JSON.stringify(this.keyMap);
                sessionStorage.selectedStrains=JSON.stringify(this.selectedStrains);
                sessionStorage.selectedConditions=JSON.stringify(this.selectedConditions);
                sessionStorage.selectedMeasurements=JSON.stringify(this.selectedMeasurements);
                sessionStorage.selectedMethods=JSON.stringify(this.selectedMethods);
                sessionStorage.currentOnt=this.currentOnt;



            },


            update: function (ont, species,terms) {
                if (!ont) {
                    ont="RS";
                    species=3;
                }
                if (!terms ) {
                    terms="";
                }

                v.currentOnt=ont;
                terms=v.getAllTerms();

                if (ont==="RS") {
                    v.title="Rat Strain Selection";
                    v.examples="Ex: congenic strain, ACI, WKY";
                    document.getElementById("treebox").style.borderColor="#D7E4BD";

                }
                if (ont==="CMO") {
                    v.title="Clinical Measurement Selection";
                    v.examples="Ex:  heart rate, blood cell count"
                    document.getElementById("treebox").style.borderColor="#CCC1DA";
                }
                if (ont==="MMO") {
                    v.title="Measurement Method Selection";
                    v.examples="Ex: fluid filled catheter, blood chemistry panel"
                    document.getElementById("treebox").style.borderColor="#FCD5B5";
                }
                if (ont==="XCO") {
                    v.title="Experimental Condition Selection";
                    v.examples="Ex: diet, atmosphere composition"
                    document.getElementById("treebox").style.borderColor="#B9CDE5";
                }

                v.searchTerm="";

                v.options={};

                document.getElementById("treebox").innerHTML="Loading...";
               // document.getElementById("selectionWindow").innerHTML="Loading...";



                axios
                    .get(this.hostName + '/rgdweb/phenominer/treeXml.html?ont=' + ont + '&sex=both&species=' + species + '&terms=' + terms,
                        {
                            species: "3",
                        })
                    .then(function (response) {



                        document.getElementById("treebox").innerHTML="";

                        tree = new dhtmlXTreeObject("treebox","100%","100%",0);
                        tree.enableCheckBoxes(1);
                        tree.enableThreeStateCheckboxes(1);
                        tree.setImagePath("/rgdweb/js/dhtmlxTree/imgs/");

                        tree.attachEvent("onCheck", handleCheckbox);
                        tree.attachEvent("onCheck",passToVue);

                        tree.loadXMLString(response.data);
                        //tree.setXMLAutoLoading("/rgdweb/phenominer/treeXml.html?ont=" + ont + "&sex=both&species=" + species + "&terms=" + terms);
                        //tree.loadXML("/rgdweb/phenominer/treeXml.html?ont=" + ont + "&sex=both&species=" + species + "&terms=" + terms);

                        var parser = new DOMParser();
                        xmlDoc = parser.parseFromString(response.data + "","text/xml");





                        var root = xmlDoc.getRootNode();
                        //var root = xmlDoc.getElementsByTagName("tree");
                        var childNodes = root.getElementsByTagName("item");

                        var children = v.getLeafNodes(childNodes);

                        var tmpHash={};
                        for (let i = 0; i < children.length; i++) {
                            let item = children[i];
                            tmpHash[item.getAttribute("text")] = item.getAttribute("id");
                        }


                        var keys = Object.keys(tmpHash);

                        keys.sort();
                        v.options={};
                        v.symbolHash={};
                        v.keyMap={};
                        for (i=0; i< keys.length; i++) {
                            v.options[keys[i]] = tmpHash[keys[i]];
                            v.symbolHash[keys[i]] = tmpHash[keys[i]];
                            v.keyMap[tmpHash[keys[i]].split("_")[0]] = keys[i];
                        }

                        document.getElementById("treebox").style.display="block";
                        document.getElementById("treebox").style.position="absolute";
                        document.getElementById("treebox").style.top=getElementTopLeft("placeholder").top + "px";
                        document.getElementById("treebox").style.left=getElementTopLeft("placeholder").left + "px"

                        document.getElementById("treebox").style.visibility="visible";
                        document.getElementById("selectionWindow").style.visibility="visible";
                        document.getElementById("ontologyLoadingMessage").style.display="none";


                    })
                    .catch(function (error) {
                        console.log(error)
                        v.errored = true
                    })
            },

        },
    })


    setTimeout(v.init, 10);



</script>



<%@ include file="/common/footerarea.jsp"%>
