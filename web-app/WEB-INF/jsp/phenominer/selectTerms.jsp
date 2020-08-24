<%
    String pageTitle = "Phenominer";
    String headContent = "";
    String pageDescription = "";

    String sex = request.getAttribute("sex").toString();
    String species = request.getAttribute("species").toString();
    System.out.println(" selectTerms.jsp  sex="+sex+" species="+species);
    String ont = request.getAttribute("ont").toString();
    String ontName = ont.equals("RS") ? "Rat Strains" :
        ont.equals("CS") ? "Chinchilla" :
        ont.equals("MMO") ? "Measurement Methods" :
        ont.equals("CMO") ? "Clinical Measurements" :
        ont.equals("XCO") ? "Experimental Conditions" : "";
    String terms = request.getAttribute("terms").toString();
%>

<%@ include file="/common/headerarea.jsp"%>


<script type="text/javascript" src="/rgdweb/js/dhtmlxTree/dhtmlxcommon.js"></script>
<script type="text/javascript" src="/rgdweb/js/dhtmlxTree/dhtmlxtree.js"></script>
<link rel="stylesheet" type="text/css" href="/rgdweb/js/dhtmlxTree/dhtmlxtree.css"/>

<h1>PhenoMiner Database</h1>


<% if( ont.equals("RS") ) { %>
<div class="strain-article-title" style="color: black; background-color: #d7e4bd;">Rat Strains Selection</div>
<ul><li>Select 1 or more Rat Strains from the list below. </li>
    <li>Each selection will be used to filter remaining categories.</li>
    <li>Click the plus (+) sign to expand sub topics.</li>
    <li>To search for a strain, enter key words in the search box, e.g. "consomic ss bn", "inbred ss jr".</li>
</ul>

<% } else if( ont.equals("CMO") ) { %>

<div class="strain-article-title" style="color: black; background-color: #ccc1da;">Clinical Measurements Selection</div>
<ul><li>Select 1 or more Clinical Measurements from the list below. </li>
    <li>Each selection will be used to filter remaining categories.</li>
    <li>Click the plus (+) sign to expand sub topics.</li>
    <li>To search for a strain, enter key words in the search box, e.g. "blood pressure", "wet weight".</li>
</ul>

<% } else if( ont.equals("XCO") ) { %>

<div class="strain-article-title" style="color: black; background-color: #b9cde5;">Experimental Conditions Selection</div>
<ul><li>Select 1 or more Experimental Conditions from the list below. </li>
    <li>Each selection will be used to filter remaining categories.</li>
    <li>Click the plus (+) sign to expand sub topics.</li>
    <li>To search for a strain, enter key words in the search box, e.g. "oxygen", "sodium diet".</li>
</ul>

<% } else if( ont.equals("MMO") ) { %>

<div class="strain-article-title" style="color: black; background-color: #fcd5b5;">Measurement Methods Selection</div>
<ul><li>Select 1 or more Measurement Methods from the list below. </li>
    <li>Each selection will be used to filter remaining categories.</li>
    <li>Click the plus (+) sign to expand sub topics.</li>
    <li>To search for a strain, enter key words in the search box, e.g. "indwelling", "volume pressure".</li>
</ul>

<% } %>

<p>
    Search: <input id="termSearch" size="40" style="border: 2px groove" class="ont-auto-complete"/>
    <span id="dataStatus" style="color:red"></span>
</p>
<div id="extra" style="color:blue;background-color:yellow;">
</div>

<% if( ont.equals("RS") ) { %>
<div>
    <table cellspacing='0' style='background-color: #eff1f0;border: 1px solid #2865a3;'>
        <tr>
            <td style='font-weight:700;'>Sex:</td>
            <td>&nbsp;&nbsp;&nbsp;male<input type="radio" name="sexSelect" value="male" <%=sex.equals("male")?"checked":""%>
                onClick="location.href='/rgdweb/phenominer/selectTerms.html?sex=male&ont=RS'" /></td>
            <td>&nbsp;&nbsp;&nbsp;female<input type="radio" name="sexSelect" value="female" <%=sex.equals("female")?"checked":""%>
                onClick="location.href='/rgdweb/phenominer/selectTerms.html?sex=female&ont=RS'" /></td>
            <td>&nbsp;&nbsp;&nbsp;both<input type="radio" name="sexSelect" value="both" <%=sex.equals("both")?"checked":""%>
                onClick="location.href='/rgdweb/phenominer/selectTerms.html?sex=both&ont=RS'"/></td>
        </tr>
    </table>
</div>
<% } %>


<!--script type="text/javascript"  src="/OntoSolr/files/jquery-1.4.3.min.js"></script>
<script type="text/javascript"  src="/OntoSolr/files/jquery.autocomplete.js"></script-->
<!--script type="text/javascript" src="/rgdweb/js/jquery/jquery-migrate-1.2.0.js"></script-->
<script type="text/javascript" src="/rgdweb/js/jquery/jquery-1.12.4.min.js"></script>
<script type="text/javascript" src="/rgdweb/js/jquery/jquery-migrate-1.2.0.js"></script>
<script type="text/javascript"  src="https://rgd.mcw.edu/OntoSolr/files/jquery.autocomplete.js"></script>

<!--script>
  var jq14 = jQuery.noConflict(true);
</script>
<script type="text/javascript"  src="/rgdweb/common/jquery.autocomplete.custom.js"></script-->
<!--script type="text/javascript" src="/QueryBuilder/js/jquery.autocomplete.js"></script-->

<script>
    $(document).ready(function(){

       $.get("/rgdweb/phenominer/treeXml.html?ont=<%=ont%>&sex=<%=sex%>", {}, function(data){
            //$("#extra").html(data);
            //alert("x:"+data);
          //  console.log(data);
            $("#termSearch").autocomplete('/OntoSolr/select', {
                    extraParams:{
                        <% if( ont.equals("RS") ) { %>
                        'qf': 'term_en^1 term_en_sp^3 term_str^2 term^1 synonym_en^1 synonym_en_sp^3 synonym_str^2 synonym^1 def^1 anc^20',
                        'bf': 'term_len_l^8',
                        <% } else { %>
                        'qf': 'term_en^5 term_en_sp^2 term_str^3 term^3 synonym_en^4.5 synonym_en_sp^1.5 synonym_str^2 synonym^2 def^1',
                        'bf': 'term_len_l^2',
                        <% } %>

                        // original query, that does not work
                        //   'fq': 'cat:<%=ont%> AND id_l:(' + data + ')',
                        // that works, but has limited functionality
                        'fq': 'cat:<%=ont%>',

                        'wt': 'velocity',
                        'v.template': 'termidselect'
                    },
                    max: 100,
                    'termSeparator': ' OR '
                }
            );
       }) ;

        $('#termSearch').focus(function()
        {
            $("#dataStatus").html("");
        });

        $('#termSearch').result(function(data, value){

            $("#dataStatus").html("");
            selectByTermId(value[1]);
        });
        $("#termSearch").keyup(function(event){
            if (event.which == 27) $(this).val("");
        });

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

<div id="treebox" style="padding: 7px; width:500px; height:250px; font: 14px verdana, arial, helvetica, sans-serif; border: 1px solid black;" tabindex="0">
    <div id="loading" style="font-size:14px; font-weight:700;">&nbsp;Loading Available <%=ontName%> ... (Please Wait)</div>
</div>

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
</script>





<div style="width: 500px; height: 40px">
    <div style="float: right; position: relative; top: 10px">
        <input type="button" value="Select <%=ontName%>" onClick="makeSelection();"/>
        <input type="button" value="Cancel" onClick="window.history.back()"/>
    </div>
</div>




<%@ include file="/common/footerarea.jsp"%>