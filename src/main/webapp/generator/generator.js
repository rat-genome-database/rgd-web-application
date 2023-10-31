function getJsonFromUrl() {
    var query = location.search.substr(1);
    var result = {};
    query.split("&").forEach(function(part) {
        var item = part.split("=");
        result[item[0]] = decodeURIComponent(item[1]);
    });

    return result;
}


function lostFocus(ont) {
    setTimeout("checkForValidTerm('" + ont + "')", 200);
}

function checkForValidTerm(ont) {

    var term = document.getElementById(ont + "_term").value;
    var acc = document.getElementById(ont + "_acc_id").value;

    if (term !="" && acc == "") {
        alert("Please select a term from the list or browse ontology tree");
        document.getElementById(ont + "_term").value="";
    }


}


function loadPreview(accId) {

    document.getElementById("preview").style.display="block";
    document.getElementById("preview").innerHTML="&nbsp;&nbsp;Loading Preview...&nbsp;&nbsp;&nbsp;";

    var mapKey = document.getElementById("mapKey_tmp").options[document.getElementById("mapKey_tmp").selectedIndex].value;
    var oKey = document.getElementById("oKey_tmp").options[document.getElementById("oKey_tmp").selectedIndex].value;

    $.ajax(
        {
            url: "preview.html",

            type: "get",
            data: {accId:accId,oKey:oKey,mapKey:mapKey},
            dataType: "html",
            contentType: 'application/json; charset=utf-8',
            error: function (xhr, ajaxOptions, thrownError,err,textStatus) {
                alert(xhr.error());
                alert( "<p>Page Not Found!!</p>" );
            },

            beforeSend: function(){
                //alert("accid = " + accId);
            },

            complete: function(){
            },

            success: function( strData ){
                //alert( "AJAX - success()" );

                if (strData.indexOf("Preview Count") == -1) {
                    document.getElementById("preview").style.display="none";
                    alert(strData.trim());
                    back();
                }

                document.getElementById("preview").innerHTML=strData;

            }
        }
    );
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
    document.getElementById("toolsBox").style.display="none";
    document.getElementById("rdoSelect").style.display="none";
    document.getElementById("rsSelect").style.display="none";
    document.getElementById("hpSelect").style.display="none";
    document.getElementById("cmoSelect").style.display="none";
    document.getElementById("mmoSelect").style.display="none";
    document.getElementById("xcoSelect").style.display="none";
    document.getElementById("pwSelect").style.display="none";
    document.getElementById("mpSelect").style.display="none";
    document.getElementById("chebiSelect").style.display="none";
    document.getElementById("bpSelect").style.display="none";
    document.getElementById("mfSelect").style.display="none";
    document.getElementById("ccSelect").style.display="none";
    document.getElementById("vtSelect").style.display="none";
    document.getElementById("preview").style.display="none";
    document.getElementById("saveBox").style.display="none";

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
    document.getElementById("toolsBox").style.display="block";
    document.getElementById("rdoSelect").style.display="block";
    document.getElementById("ccSelect").style.display="block";
    document.getElementById("vtSelect").style.display="block";
    document.getElementById("rsSelect").style.display="block";
    document.getElementById("pwSelect").style.display="block";
    document.getElementById("mpSelect").style.display="block";
    document.getElementById("chebiSelect").style.display="block";

}


function resetFormValues() {
    document.getElementById("rdo_acc_id").value="";
    document.getElementById("rdo_term").value="";
    document.getElementById("rs_acc_id").value="";
    document.getElementById("rs_term").value="";
    document.getElementById("hp_acc_id").value="";
    document.getElementById("hp_term").value="";
    document.getElementById("cmo_acc_id").value="";
    document.getElementById("cmo_term").value="";
    document.getElementById("mmo_acc_id").value="";
    document.getElementById("mmo_term").value="";
    document.getElementById("xco_acc_id").value="";
    document.getElementById("xco_term").value="";
    document.getElementById("pw_acc_id").value="";
    document.getElementById("pw_term").value="";
    document.getElementById("mp_acc_id").value="";
    document.getElementById("mp_term").value="";
    document.getElementById("chebi_acc_id").value="";
    document.getElementById("chebi_term").value="";
    document.getElementById("cc_acc_id").value="";
    document.getElementById("cc_term").value="";
    document.getElementById("vt_acc_id").value="";
    document.getElementById("vt_term").value="";

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

    loadPreview(getUserSelectedAccId());

    document.getElementById("selectBox").style.display="block";
    document.getElementById("venn").style.display="block";
}

function showOntInput(ont) {
    resetFormValues();
    hideAll();
    document.getElementById("selectBox").style.display="block";

    document.getElementById(ont + "Select").style.display="block";
    document.getElementById(ont + "_term").focus();
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

    if (screenId=="qtlSelect") {
        document.getElementById("qtl").focus();
    }else if (screenId=="positionSelect") {
        document.getElementById("start").focus();
    }else if (screenId=="geneSelect") {
        document.getElementById("geneSelectList").focus();
    }



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
    if (document.getElementById("cc_acc_id").value != "") {
        return document.getElementById("cc_acc_id").value;
    }
    if (document.getElementById("vt_acc_id").value != "") {
        return document.getElementById("vt_acc_id").value;
    }
    if (document.getElementById("rs_acc_id").value != "") {
        return document.getElementById("rs_acc_id").value;
    }
    if (document.getElementById("hp_acc_id").value != "") {
        return document.getElementById("hp_acc_id").value;
    }
    if (document.getElementById("cmo_acc_id").value != "") {
        return document.getElementById("cmo_acc_id").value;
    }
    if (document.getElementById("xco_acc_id").value != "") {
        return document.getElementById("xco_acc_id").value;
    }
    if (document.getElementById("mmo_acc_id").value != "") {
        return document.getElementById("mmo_acc_id").value;
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
    if (document.getElementById("bp_acc_id").value != "") {
        return document.getElementById("bp_acc_id").value;
    }
    if (document.getElementById("mf_acc_id").value != "") {
        return document.getElementById("mf_acc_id").value;
    }

    if (document.getElementById("geneSelectList").value != "") {

        var genes = document.getElementById("geneSelectList").value.split(/[,\s\|]/);

        var geneStr = "";

        for (var i = 0; i< genes.length; i++) {
            if(genes[i]=='' || genes[i]==null)
                continue;
            if (geneStr=="") {
                geneStr += genes[i].trim();

            }else {
                geneStr += "[" + genes[i].trim();
            }
        }

        return "lst:" + geneStr;
    }

    if (document.getElementById("qtl").value !="") {
        return "qtl:" + document.getElementById("qtl").value;
    }

    if (document.getElementById("chr").value != "" &&  document.getElementById("start").value != "" &&  document.getElementById("stop").value != "") {
        return "chr" + document.getElementById("chr").value + ":" + document.getElementById("start").value.trim() + ".." + document.getElementById("stop").value.trim();
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
    var urlString = "";

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

    document.getElementById("a").value=urlString;
    document.getElementById("mapKey").value= document.getElementById("mapKey_tmp").options[document.getElementById("mapKey_tmp").selectedIndex].value;
    document.getElementById("oKey").value= document.getElementById("oKey_tmp").options[document.getElementById("oKey_tmp").selectedIndex].value;
    document.getElementById("act").value="";
    document.submitForm.target="_self";
    document.getElementById("a").value=urlString;
    document.submitForm.submit();

}


function saveList() {
    var urlString = "";

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

    document.submitForm.action="save.html";

    document.getElementById("a").value=urlString;
    document.getElementById("mapKey").value= document.getElementById("mapKey_tmp").options[document.getElementById("mapKey_tmp").selectedIndex].value;
    document.getElementById("oKey").value= document.getElementById("oKey_tmp").options[document.getElementById("oKey_tmp").selectedIndex].value;
    document.submitForm.submit();

}



function processList(act) {
    var urlString = "";

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

    document.submitForm.action="process.html";

    document.getElementById("a").value=urlString;
    document.getElementById("act").value=act;
    document.getElementById("mapKey").value= document.getElementById("mapKey_tmp").options[document.getElementById("mapKey_tmp").selectedIndex].value;
    document.getElementById("oKey").value= document.getElementById("oKey_tmp").options[document.getElementById("oKey_tmp").selectedIndex].value;
    document.submitForm.submit();

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
    var cc=document.getElementById("cc_acc_id").value;
    var vt=document.getElementById("vt_acc_id").value;
    var rs=document.getElementById("rs_acc_id").value;
    var hp=document.getElementById("hp_acc_id").value;
    var cmo=document.getElementById("cmo_acc_id").value;
    var mmo=document.getElementById("mmo_acc_id").value;
    var xco=document.getElementById("xco_acc_id").value;
    var p=document.getElementById("pw_acc_id").value;
    var mp=document.getElementById("mp_acc_id").value;
    var c=document.getElementById("chebi_acc_id").value;
    var bp=document.getElementById("bp_acc_id").value;
    var mf=document.getElementById("mf_acc_id").value;

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
    if (bp!="") {
        termCnt++;
    }
    if (mf!="") {
        termCnt++;
    }
    if (rs!="") {
        termCnt++;
    }
    if (hp!="") {
        termCnt++;
    }
    if (cmo!="") {
        termCnt++;
    }
    if (mmo!="") {
        termCnt++;
    }
    if (xco!="") {
        termCnt++;
    }
    if (cc!="") {
        termCnt++;
    }
    if (vt!="") {
        termCnt++;
    }

    if (termCnt == 0) {
        alert("Term not found.  The browse link can be used to browse the ontology tree.")
        return false;
    }

    if (termCnt > 1) {
        alert("Only ONE term may be selected.  You currently selected " + termCnt + " terms.")
        return false;
    }

    getVenn();
}
function submitPosition() {

    var start = document.getElementById("start").value.trim();
    var stop = document.getElementById("stop").value.trim();

    if (start < 1 || start > 1000000000) {
        alert("Please enter a valid start position");
    }else if (stop < 1 || stop > 1000000000) {
        alert("Please enter a valid stop position");
    } else if (start >= stop) {
        alert("Start position can not be greater than stop position.");
    }else {
        getVenn();
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
    if (document.getElementById("resultSet").innerHTML.trim() == "Empty&nbsp;Set") {
        return "";
    }else {
        var geneList = document.getElementById("resultSet").innerHTML;
        geneList = geneList.replace(/\s/g, "");
        geneList = geneList.replace(/<br>/g, "\n");
        return encodeURIComponent(geneList);
    }
}

function getResultSetArray() {
    if (document.getElementById("resultSet").innerHTML.trim() == "Empty&nbsp;Set") {
        return "";
    }else {
        var geneList = document.getElementById("resultSet").innerHTML;
        geneList = geneList.replace(/\s/g, "");
        geneList = geneList.replace(/<br>/g, ",");

        var symbols = geneList.split(",");
        var geneArray = new Array();

        for (var i=0; i< symbols.length; i++) {
            if (symbols[i].trim() != "") {
                geneArray[geneArray.length] = new function() {
                    this.gene = symbols[i];
                }
            }

        }
        return geneArray;
        //return JSON.stringify(geneArray);

    }
}


function toolSubmit(tool,speciesTypeKey) {
    if (getResultSet().length ==0) {
        alert("Result set is empty");
    } else {

        var url="#";
        if (tool == "vv") {
            var url = "/rgdweb/front/geneList.html?&chr=&start=&stop=&geneStart=&geneStop=";
            url += "&mapKey=" + document.getElementById("mapKey_tmp").options[document.getElementById("mapKey_tmp").selectedIndex].value;
            url += "&geneList=" + getResultSet();
            window.open(url);
        }else if (tool == "ga") {
            var url = "/rgdweb/ga/start.jsp?o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=56&x=36&x=52&x=40&x=31&x=45&x=29&x=32&x=48&x=23&x=33&x=50&x=17&x=2&x=20&x=54&x=57&x=27&x=41&x=35&x=49&x=5&x=55&x=42&x=10&x=38&x=3&x=6&x=15&x=1&x=53&x=37&x=7&x=34&x=43&x=39&x=30&x=4&x=21&x=44&x=14&x=22&x=51&x=16&x=24&ortholog=1&ortholog=2&species=" + speciesTypeKey + "&chr=1&start=&stop=";
            url += "&mapKey=" + document.getElementById("mapKey_tmp").options[document.getElementById("mapKey_tmp").selectedIndex].value;
            url += "&genes=" + getResultSet();
            window.open(url);
        }else if (tool=="excel") {
            //var url = "/rgdweb/gviewer/download.html?";
            //url += "mapKey=" + document.getElementById("mapKey_tmp").options[document.getElementById("mapKey_tmp").selectedIndex].value;
            //url += "&genes=" + getResultSet();

            processList("excel");
        }else if (tool == "gv") {

            /*
             var url = "/rgdweb/generator/process.html?";
             url += "mapKey=" + document.getElementById("mapKey_tmp").options[document.getElementById("mapKey_tmp").selectedIndex].value;
             url += "&genes=" + getResultSet();
             */
            processList("browse");
        }else if (tool == "sv") {
            //alert("saving list");
            saveList();
        }else if (tool == "interviewer") {
            var url = "/rgdweb/cytoscape/cy.html?browser=12&species=" + speciesTypeKey + "&identifiers=" + getResultSet();
            window.open(url);
        }

        //location.href=url;

    }

}

function displayMsg(msg) {
    document.getElementById("msgBox").style.display="block";
    document.getElementById("msgBox").innerHTML=msg;
    document.getElementById("selectBox").style.display="block";
}

