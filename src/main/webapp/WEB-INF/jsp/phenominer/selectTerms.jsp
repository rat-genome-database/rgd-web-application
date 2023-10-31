<%
    String pageTitle = "Phenominer";
    String headContent = "";
    String pageDescription = "";

    String sex = request.getAttribute("sex").toString();
    String species = request.getAttribute("species").toString();
    //System.out.println(" selectTerms.jsp  sex="+sex+" species="+species);
    String ont = request.getAttribute("ont").toString();
    String ontName = ont.equals("RS") ? "Rat Strains" :
        ont.equals("CS") ? "Chinchilla" :
        ont.equals("MMO") ? "Measurement Methods" :
        ont.equals("CMO") ? "Clinical Measurements" :
        ont.equals("XCO") ? "Experimental Conditions" : "";
    String terms = request.getAttribute("terms").toString();
%>

<%@ include file="/common/headerarea.jsp"%>

<script type="text/javascript" src="/rgdweb/js/xml2json.js"></script>




<script>
    var gviewer = null;
</script>

<script type="text/javascript" src="/rgdweb/js/dhtmlxTree/dhtmlxcommon.js"></script>
<script type="text/javascript" src="/rgdweb/js/dhtmlxTree/dhtmlxtree.js?1"></script>
<link rel="stylesheet" type="text/css" href="/rgdweb/js/dhtmlxTree/dhtmlxtree.css?3"/>

<h1>PhenoMiner Database</h1>


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


<div id="phenominer" >

    <br>
    <table align="left" width="1000">
        <tr>
            <td colspan="2"style="font-size:24px;">Rat Strain Selection</td>
        </tr>
        <tr>
            <td colspan="2"><input id="termSearch" placeholder="Enter Strain Symbol Here" v-model="searchTerm" size="45" style="border: 3px solid black;height:38px;width:800px;" v-on:input="search()"/></td>
                        <input type="button" @click="update()" value="init"/>

        </tr>
        <tr>
            <td width="700">
                <div style="overflow:scroll;height:450px;width:700px;border: 1px solid black;">
                    <h3 v-if="optionsNotEmpty"><br>&nbsp;0 Records found for Term: <b>{{searchTerm}}</b></h3>
                    <ul >
                        <li v-for="(key, value) in options" >
                            <table width="98%" border="1">
                                <tr>
                                    <td width="15"><input type="button" value="select" @click="selectByTermId(key)" style="height:17px;padding-left:5px;"/></td>
                                    <!--<td>{{key}}</td>-->
                                    <td style="font-size:12px;" align="left">{{value}}</td>
                                </tr>
                            </table>

                        </li>
                    </ul>
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

<div id="treebox" style="float:right; padding: 7px; width:700px; height:450px; font: 14px verdana, arial, helvetica, sans-serif; border: 1px solid black;" tabindex="0">
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



<script type="text/javascript">
    var tree = new dhtmlXTreeObject("treebox","100%","100%",0);
    tree.enableCheckBoxes(1);
    tree.enableThreeStateCheckboxes(1);
    tree.setImagePath("/rgdweb/js/dhtmlxTree/imgs/");

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

    tree.attachEvent("onCheck", handleCheckbox);

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




    tree.setXMLAutoLoading("/rgdweb/phenominer/treeXml.html?ont=<%=ont%>&sex=<%=sex%>&species=<%=species%>&terms=<%=terms%>");
    tree.loadXML("/rgdweb/phenominer/treeXml.html?ont=<%=ont%>&sex=<%=sex%>&species=<%=species%>&terms=<%=terms%>");


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



    function loadMap() {

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
            title: "Hello World",
            searchTerm: "",
            hostName: host,
            options:{},
            symbolHash: {},
        },
        methods: {
            selectByTermId: function(val) {
                goToNode(val);
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

            update: function (aspect, s) {

                document.getElementById("treebox").style.position="absolute";
                document.getElementById("treebox").style.top=getElementTopLeft("placeholder").top + "px";
                document.getElementById("treebox").style.left=getElementTopLeft("placeholder").left + "px"


                axios
                    .get(this.hostName + '/rgdweb/phenominer/treeXml.html?ont=RS&sex=both&species=3&terms=',
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
                        for (i=0; i< keys.length; i++) {
                            v.options[keys[i]] = tmpHash[keys[i]];
                            v.symbolHash[keys[i]] = tmpHash[keys[i]];
                        }



                        v.title="hello";
                    })
                    .catch(function (error) {
                        console.log(error)
                        v.errored = true
                    })
            },

        },
    })


setTimeout(v.update, 1000);
</script>



<%@ include file="/common/footerarea.jsp"%>