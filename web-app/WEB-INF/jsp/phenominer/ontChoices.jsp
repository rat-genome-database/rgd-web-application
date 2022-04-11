<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.phenominer.frontend.OTrees" %>
<%@ page import="org.springframework.web.servlet.ModelAndView" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
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
        <td align="right">
            <input style="visibility: hidden;" type="button" id="continue" name="continue" value="Generate Report" onClick="location.href='/phenotypes/dataTable/retrieveData?terms=RS%3A29%2CRS%3A1860%2CRS%3A1381%2CCMO%3A371%2CCMO%3A374%2CCMO%3A368%2CCMO%3A369%2CCMO%3A27%2CCMO%3A171%2CCMO%3A149%2CMMO%3A145%2CMMO%3A225%2CMMO%3A6%2CXCO%3A87'" />
        </td>
    </tr>
    <tr>
        <td>&nbsp;</td>
    </tr>
</table>

<div id="phenominer" >

<table cellspacing='0' border='0'>
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
                        <td valign="top" align="center"><input style="font-weight: 700;" type="button" value="Select Sources" onClick="location.href='/rgdweb/phenominer/selectTerms.html?terms=<%=termString%>&ont=CS&species=<%=speciesTypeKey%>'" /><br><br></td>
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




        <td valign='top' style='padding: 5px ;vertical-align: top; background-color: #d7e4bd; border-top: 1px solid black;border-left: 1px solid black;border-right: 3px outset black;border-bottom: 3px outset black;'>
            <div style='font-weight: 700;'>
                <table border="0"  width="100%" style="background-color: #d7e4bd">
                    <tr>
                        <td  height="60" style="font-size:20px; background-color: #d7e4bd; " valign="top"><div style="height:50px; width:100%; border-bottom: 3px solid white">Rat Strains<br><span style="font-size:11px; ">Search for data related to one or more rat strains.</span></div></td>
                    </tr>
                </table>
            </div>
            <div style='background-color: white; padding: 5px; border: 2px black inset;height:200px;overflow:scroll;'>

                <!--
                <% for (String sample: sampleIds) { %>
                    <li><%=ot.getTermName(sample,sex,speciesTypeKey)%> (<%=rsTree.getRecordCountForTermOnly(sample)%>)</li>
                <% } %>
                -->



                <table>
                    <tr v-for="(key, value) in selectedStrains">
                        <td width="15"><img style="padding-right:3px;cursor:pointer;" @click="remove(key,'RS')" src="/rgdweb/common/images/del.jpg"/></td>

                                <!--<td>{{key}}</td>-->
                                <td style="font-size:12px;" align="left">{{value}}</td>
                            </tr>
                        </table>


            </div>
        </td>

        <%
            OTrees.OTree cmoTree = ot.getFilteredTree("CMO", sex, speciesTypeKey, termString); %>
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
                        <td style="font-size:12px;" align="left">{{value}}</td>
                    </tr>
                </table>

            </div>
        </td>


        <%
            OTrees.OTree mmoTree = ot.getFilteredTree("MMO", sex, speciesTypeKey, termString); %>
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
                        <td style="font-size:12px;" align="left">{{value}}</td>
                    </tr>
                </table>

            </div>
        </td>


        <%
            OTrees.OTree xcoTree = ot.getFilteredTree("XCO", sex, speciesTypeKey, termString); %>
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
                        <td style="font-size:12px;" align="left">{{value}}</td>
                    </tr>
                </table>

            </div>
        </td>
        <td valign='top'>
            <!--
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
                -->
        </td>
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

    int species = 3;

    /*
    speciesTypeKey = "3";
    String spParam = request.getParameter("species");
    if( spParam!=null ) {
        speciesTypeKey = spParam;
    }
*/
    String terms =  Utils.defaultString(request.getParameter("terms"));

    //System.out.println(" selectTerms.jsp  sex="+sex+" species="+species);
    String ontName = ont.equals("RS") ? "Rat Strains" :
            ont.equals("CS") ? "Chinchilla" :
                    ont.equals("MMO") ? "Measurement Methods" :
                            ont.equals("CMO") ? "Clinical Measurements" :
                                    ont.equals("XCO") ? "Experimental Conditions" : "";
%>




    <br>
    <table align="left" width="1000">
        <tr>
            <td colspan="2"style="font-size:24px;">{{title}}</td>
        </tr>
        <tr>
            <td colspan="2"><input id="termSearch" :placeholder="examples" v-model="searchTerm" size="45" style="border: 3px solid black;height:38px;width:700px;" v-on:input="search()"/></td>
            <td valign="center" align="center"><input style="position:relative; top:5px; border-top-left-radius:10px; background-color:#D7E4BD; font-weight: 700;height:35px;width:80px; font-size:12px;" type="button" value="Strains" @click="update('RS',<%=speciesTypeKey%>)" /></td>
            <td valign="center" align="center"><input style="position:relative; top:5px;  background-color:#CCC1DA; font-weight: 700;height:35px;width:150px; font-size:12px;" type="button" value="Clinical Measurements" @click="update('CMO',<%=speciesTypeKey%>)"  /></td>
            <td valign="center" align="center"><input style="position:relative; top:5px;  background-color:#FCD5B5; font-weight: 700;height:35px;width:150px; font-size:12px;" type="button" value="Measurement Methods" @click="update('MMO',<%=speciesTypeKey%>)"  /></td>
            <td valign="center" align="center"><input style="position:relative; top:5px;  border-top-right-radius:10px; background-color:#B9CDE5; font-weight: 700;height:35px;width:160px; font-size:12px;" type="button" value="Experimental Conditions"  @click="update('XCO',<%=speciesTypeKey%>)"  /></td>

            <input type="button" @click="update()" value="init"/>
            <input type="button" @click="doStuff()" value="test"/>

        </tr>
        <tr>
            <td width="700">
                <div style="overflow:scroll;height:450px;width:700px;border: 1px solid black;">
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
                <div id="placeholder" style="position:absolute;"></div>
            </td>
        </tr>
    </table>

    <span id="dataStatus" style="color:red"></span>
    <div id="extra" style="color:blue;background-color:yellow;">
    </div>

</div>

<div id="treebox" style="z-index:1000;float:right; padding: 7px; width:700px; height:450px; font: 14px verdana, arial, helvetica, sans-serif; border: 5px solid black;" tabindex="0">
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




<div style="width: 500px; height: 40px">
    <div style="float: right; position: relative; top: 10px">
        <input type="button" value="Select <%=ontName%>" onClick="makeSelection();"/>
        <input type="button" value="Cancel" onClick="window.history.back()"/>
    </div>
</div>


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
            selectedStrains: {},
            selectedMeasurements: {},
            selectedConditions: {},
            selectedMethods: {},
            currentOnt: "RS",
            examples: "",

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
                v.options={};

                v.optionsNotEmpty = true;
                for (var key in v.symbolHash) {
                    if (key.indexOf(v.searchTerm) != -1) {
                        //console.log(key.indexOf(v.searchTerm));
                        v.options[key] = v.symbolHash[key];
                        v.optionsNotEmpty=false;
                    }
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
                        var children = root.getElementsByTagName("item");

                        var tmpHash = {};
                        for (let i = 0; i < children.length; i++) {
                            let item = children[i];

                            for (var key in v.selectedConditions) {
                                var idArr = (item.getAttribute("id") + "").split("_");
                                var id = idArr[0];

                                if (v.selectedConditions[key] === id) {
                                    tmpHash[item.getAttribute("text")] = id;
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
            updateStrainBox: function() {
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
                        var children = root.getElementsByTagName("item");

                        var tmpHash = {};
                        for (let i = 0; i < children.length; i++) {
                            let item = children[i];

                            for (var key in v.selectedStrains) {
                                var idArr = (item.getAttribute("id") + "").split("_");
                                var id = idArr[0];

                                if (v.selectedStrains[key] === id) {
                                    tmpHash[item.getAttribute("text")] = id;
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
                        var children = root.getElementsByTagName("item");

                        var tmpHash = {};
                        for (let i = 0; i < children.length; i++) {
                            let item = children[i];

                            for (var key in v.selectedMethods) {
                                var idArr = (item.getAttribute("id") + "").split("_");
                                var id = idArr[0];

                                if (v.selectedMethods[key] === id) {
                                    tmpHash[item.getAttribute("text")] = id;
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
                        var children = root.getElementsByTagName("item");

                        var tmpHash = {};
                        for (let i = 0; i < children.length; i++) {
                            let item = children[i];

                            for (var key in v.selectedMeasurements) {
                                var idArr = (item.getAttribute("id") + "").split("_");
                                var id = idArr[0];

                                if (v.selectedMeasurements[key] === id) {
                                    tmpHash[item.getAttribute("text")] = id;
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

            remove: function (accId, ont) {
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


            },

            getAllTerms: function () {
                var termString="";

                var first=true;
                for (const key in v.selectedStrains) {
                    if (!first) {
                        termString += ",";
                    }else {
                        first=false;
                    }

                    termString +=v.selectedStrains[key];
                }

                for (const key in v.selectedMeasurements) {
                    if (!first) {
                        termString += ",";
                    }else {
                        first=false;
                    }

                    termString +=v.selectedMeasurements[key];
                }

                for (const key in v.selectedConditions) {
                    if (!first) {
                        termString += ",";
                    }else {
                        first=false;
                    }

                    termString +=v.selectedConditions[key];
                }

                for (const key in v.selectedMethods) {
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

                document.getElementById("treebox").innerHTML="";

                tree = new dhtmlXTreeObject("treebox","100%","100%",0);
                tree.enableCheckBoxes(1);
                tree.enableThreeStateCheckboxes(1);
                tree.setImagePath("/rgdweb/js/dhtmlxTree/imgs/");

                tree.attachEvent("onCheck", handleCheckbox);
                tree.attachEvent("onCheck",passToVue);

                tree.setXMLAutoLoading("/rgdweb/phenominer/treeXml.html?ont=" + ont + "&sex=both&species=" + species + "&terms=" + terms);
                tree.loadXML("/rgdweb/phenominer/treeXml.html?ont=" + ont + "&sex=both&species=" + species + "&terms=" + terms);


                document.getElementById("treebox").style.position="absolute";
                document.getElementById("treebox").style.top=getElementTopLeft("placeholder").top + "px";
                document.getElementById("treebox").style.left=getElementTopLeft("placeholder").left + "px"

                v.options={};

                axios
                    .get(this.hostName + '/rgdweb/phenominer/treeXml.html?ont=' + ont + '&sex=both&species=' + species + '&terms=' + terms,
                        {
                            species: "hell",
                        })
                    .then(function (response) {
                        var parser = new DOMParser();
                        xmlDoc = parser.parseFromString(response.data + "","text/xml");

                        var root = xmlDoc.getRootNode();
                        //var root = xmlDoc.getElementsByTagName("tree");
                        var children = root.getElementsByTagName("item");

                        var tmpHash={};
                        for (let i = 0; i < children.length; i++) {
                            let item = children[i];
                            tmpHash[item.getAttribute("text")] = item.getAttribute("id");
                        }


                        var keys = Object.keys(tmpHash);

                        //v.symbolHash["HR Donors"]="HR";
                        //v.symbolHash["HDRP Strains"]="HDRP";
                        //v.symbolHash["HS Founder Strains"]="HS";

                        keys.sort();
                        v.options={};
                        v.symbolHash={};
                        v.keyMap={};
                        for (i=0; i< keys.length; i++) {
                            v.options[keys[i]] = tmpHash[keys[i]];
                            v.symbolHash[keys[i]] = tmpHash[keys[i]];
                            v.keyMap[tmpHash[keys[i]].split("_")[0]] = keys[i];
                        }


                    })
                    .catch(function (error) {
                        console.log(error)
                        v.errored = true
                    })
            },

        },
    })


    setTimeout(v.update, 10);
</script>



<%@ include file="/common/footerarea.jsp"%>
