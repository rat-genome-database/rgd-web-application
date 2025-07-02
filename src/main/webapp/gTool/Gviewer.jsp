<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.datamodel.Chromosome" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=windows-1252" %>
<%
    String pageTitle = "Web Genome Viewer - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Gviewer provides users with complete genome view of gene and QTL annotated to a function, biological process, cellular component, phenotype, disease, or pathway. The tool will search for matching terms from the Gene Ontology, Mammalian Phenotype Ontology, Disease Ontology or Pathway Ontology.";
    
%>
<%@ include file="../common/headerarea.jsp" %>


    <script type="text/javascript" src="/rgdweb/gviewer/script/jkl-parsexml.js">
    // ================================================================
    //  jkl-parsexml.js ---- JavaScript Kantan Library for Parsing XML
    //  Copyright 2005-2007 Kawasaki Yusuke <u-suke@kawa.net>
    //  http://www.kawa.net/works/js/jkl/parsexml.html
    // ================================================================
    </script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/dhtmlwindow.js">
    /***********************************************
    * DHTML Window script- © Dynamic Drive (http://www.dynamicdrive.com)
    * This notice MUST stay intact for legal use
    * Visit http://www.dynamicdrive.com/ for this script and 100s more.
    ***********************************************/
    </script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/util.js"></script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/gviewer.js"></script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/domain.js"></script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/contextMenu.js">
    /***********************************************
    * Context Menu script- © Dynamic Drive (http://www.dynamicdrive.com)
    * This notice MUST stay intact for legal use
    * Visit http://www.dynamicdrive.com/ for this script and 100s more.
    ***********************************************/
    </script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/event.js"></script>
    <script type="text/javascript" src="/rgdweb/gviewer/script/ZoomPane.js"></script>
    <link rel="stylesheet" type="text/css" href="/rgdweb/gviewer/css/gviewer.css" />

<script src="/rgdweb/common/sorttable.js"></script>
<script type="text/javascript" src="/rgdweb/js/jquery/jquery-migrate-3.5.0.js"></script>
<script type="text/javascript" src="/QueryBuilder/js/jquery.autocomplete.js"></script>

<!--#F0F6FF    #E3EEFF -->

<style type="text/css">
.spiffy{display:block}
.spiffy *{
  display:block;
  height:1px;
  overflow:hidden;
  font-size:.01em;
  background:#E3EEFF;
}
.spiffy1{
  margin-left:3px;
  margin-right:3px;
  padding-left:1px;
  padding-right:1px;
  border-left:1px solid #E3EEFF;
  border-right:1px solid #E3EEFF;
  background:#E3EEFF;
}
.spiffy2{
  margin-left:1px;
  margin-right:1px;
  padding-right:1px;
  padding-left:1px;
  border-left:1px solid #E3EEFF;
  border-right:1px solid #E3EEFF;
  background:#E3EEFF;
}
.spiffy3{
  margin-left:1px;
  margin-right:1px;
  border-left:1px solid #E3EEFF;
  border-right:1px solid #E3EEFF;
}
.spiffy4{
  border-left:1px solid #E3EEFF;
  border-right:1px solid #E3EEFF;
}
.spiffy5{
  border-left:1px solid #E3EEFF;
  border-right:1px solid #E3EEFF;
}
.spiffyfg{
  background:#E3EEFF;
}
table.ontlist{
    font-size:11px;
    background-color:white;
    width:540px;
}
table.ontlist label{
    cursor:help;
}
</style>





<%
    String tutorialLink="/wg/home/rgd_rat_community_videos/gviewer_tutorial/";
    String pageHeader="GViewer: Genome Visualization";
%>
<%@ include file="/common/title.jsp" %>
<br>

<div id="loading"></div>

<form method="get" name="gviewerForm" action="javascript:runGviewer();void(0);">

<div style="width: 100%;">
  <b class="spiffy">
  <b class="spiffy1"><b></b></b>
  <b class="spiffy2"><b></b></b>
  <b class="spiffy3"></b>
  <b class="spiffy4"></b>
  <b class="spiffy5"></b></b>

<div class="spiffyfg">
<table border="0" bgcolor="#E3EEFF" align="center" width="100%">
    <tbody id="expressionTable">
    <tr>
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td style="font-size:12px; font-weight:700;" valign="bottom">Search Term</td>
        <td>&nbsp;</td>
        <td style="font-size:12px; font-weight:700;" valign="bottom">Select Ontology Type/s</td>
        <td>&nbsp;</td>
        <td align="right"><Input type="submit" Value="Run GViewer"></td>
    </tr>
    <tr id="rootExpression">
        <td>&nbsp;</td>
        <td>&nbsp;</td>
        <td style="font-size:11px;">
            <input name="term[]" class="ont-auto-complete" value="" size="32"/>
        </td>
        <td>&nbsp;</td>
        <td>
            <table cellpadding=1 cellspacing=0 border=1 class="ontlist">
                <tr>
                    <td>
                        <label title="GO Ontologies: Biological Process, Cellular Component, Molecular Function">&nbsp;GO&nbsp;<input name="go[]" type="checkbox" value="CC,MF,BP" checked></label>
                        <label title="RGD Disease Ontology">&nbsp; &nbsp;Disease&nbsp;<input name="do[]" type="checkbox" value="RDO" checked></label>
                        <label title="Neuro behavioral Ontology">&nbsp; &nbsp;Behavioral&nbsp;<input name="bo[]" type="checkbox" value="NBO" checked></label>
                        <label title="Mammalian Phenotype Ontology">&nbsp; &nbsp;Phenotype&nbsp;<input name="po[]" type="checkbox" value="MP" checked></label>
                        <label title="Pathway Ontology">&nbsp; &nbsp;Pathway&nbsp;<input name="wo[]" type="checkbox" value="PW" checked></label>
                    </td>
                    <td align="center"><input type="button" value="Select All" style="font-size:smaller;" onclick="selectAllOntologies(this);"></td>
               </tr>
                <tr>
                    <td>
                        <label title="Clinical Measurement Ontology">&nbsp;CMO&nbsp;<input name="cmo[]" type="checkbox" value="CMO" checked></label>
                        <label title="Measurement Method Ontology">&nbsp; &nbsp;MMO&nbsp;<input name="mmo[]" type="checkbox" value="MMO" checked></label>
                        <label title="Experimental Condition Ontology">&nbsp; &nbsp;XCO&nbsp;<input name="xco[]" type="checkbox" value="XCO" checked></label>
                        <label title="Rat Strain Ontology">&nbsp; &nbsp;Strain&nbsp;<input name="rs[]" type="checkbox" value="RS" checked></label>
                        <label title="Vertebrate Trait Ontology">&nbsp; &nbsp;Trait&nbsp;<input name="vt[]" type="checkbox" value="VT" checked></label>
                        <label title="Chemical Entities of Biological Interest Ontology">&nbsp; &nbsp;ChEBI&nbsp;<input name="chebi[]" type="checkbox" value="CHEBI" checked></label>
                    </td>
                    <td align="center"><input type="button" value="Unselect All" style="font-size:smaller;" onclick="unselectAllOntologies(this);"></td>
               </tr>
            </table>
        </td>
        <td  colspan="2" align="center"><a href="javascript:appendExpression()" style="font-size:11px; color:blue; font-weight:700;">Add Search Term</a></td>

    </tr>
    </tbody>
</table>

</div>
<b class="spiffy">
  <b class="spiffy5"></b>
  <b class="spiffy4"></b>
  <b class="spiffy3"></b>
  <b class="spiffy2"><b></b></b>
  <b class="spiffy1"><b></b></b></b>
</div>
</form>


<table border="" style="visibility:hidden; position:absolute;">
    <tbody>
    <tr id="baseExpression" name="baseExpression">
        <td align="right" style="font-size:11px;">
           <select name="op[]">
                <option value="OR">OR
               <option value="AND">AND
                <option value="AND NOT">NOT
            </select>
        </td>
        <td>&nbsp;</td>
        <td  style="font-size:11px;">
            <input name="term[]" value="" size="32"/>
        </td>
        <td>&nbsp;</td>
        <td style="font-size:11px;">
            <table cellpadding=1 cellspacing=0 border=1 class="ontlist">
                <tr>
                    <td>
                        <label title="GO Ontologies: Biological Process, Cellular Component, Molecular Function">&nbsp;GO&nbsp;<input id="go" name="go[]" type="checkbox" value="CC,MF,BP" checked></label>
                        <label title="RGD Disease Ontology">&nbsp; &nbsp;Disease&nbsp;<input id="rdo" name="do[]" type="checkbox" value="RDO" checked></label>
                        <label title="Neuro behavioral Ontology">&nbsp; &nbsp;Behavioral&nbsp;<input id="bo" name="bo[]" type="checkbox" value="NBO" checked></label>
                        <label title="Mammalian Phenotype Ontology">&nbsp; &nbsp;Phenotype&nbsp;<input id="mp" name="po[]" type="checkbox" value="MP" checked></label>
                        <label title="Pathway Ontology">&nbsp; &nbsp;Pathway&nbsp;<input name="wo[]" type="checkbox" value="PW" checked></label>
                    </td>
                    <td align="center"><input type="button" value="Select All" style="font-size:smaller;" onclick="selectAllOntologies(this);"></td>
               </tr>
                <tr>
                    <td>
                        <label title="Clinical Measurement Ontology">&nbsp;CMO&nbsp;<input name="cmo[]" type="checkbox" value="CMO" checked></label>
                        <label title="Measurement Method Ontology">&nbsp; &nbsp;MMO&nbsp;<input name="mmo[]" type="checkbox" value="MMO" checked></label>
                        <label title="Experimental Condition Ontology">&nbsp; &nbsp;XCO&nbsp;<input name="xco[]" type="checkbox" value="XCO" checked></label>
                        <label title="Rat Strain Ontology">&nbsp; &nbsp;Strain&nbsp;<input name="rs[]" type="checkbox" value="RS" checked></label>
                        <label title="Vertebrate Trait Ontology">&nbsp; &nbsp;Trait&nbsp;<input name="vt[]" type="checkbox" value="VT" checked></label>
                        <label title="Chemical Entities of Biological Interest Ontology">&nbsp; &nbsp;ChEBI&nbsp;<input name="chebi[]" type="checkbox" value="CHEBI" checked></label>
                    </td>
                    <td align="center"><input type="button" value="Unselect All" style="font-size:smaller;" onclick="unselectAllOntologies(this);"></td>
               </tr>
            </table>
            </td>
        <td  colspan="2" align="center"><a id="hey2" href="javascript:removeExpression(this)" style="font-size:11px;color:red; font-weight:700;">Remove Search Term</a></td>
    </tr>
   </tbody>
</table>

<div id="content" style="width: 100%; visibility: hidden; ">
<!--
  <b class="spiffy">
  <b class="spiffy1"><b></b></b>
  <b class="spiffy2"><b></b></b>
  <b class="spiffy3"></b>
  <b class="spiffy4"></b>
  <b class="spiffy5"></b></b>

<div class="spiffyfg">
 -->
         <!--#E3EEFF-->
<table  cellpadding=0 cellspacing=0 align="center" border="0" width="100%">
    <tr><td>&nbsp;</td></tr>
    <tr>
        <td align="center"><div id="gviewer" class="gviewer"></div><div id="zoomWrapper" class="zoom-pane"></div></td>
    </tr>
    <tr>
        <td align="center" valign="top" colspan="3" >
            <div id="gviewerDiv" style="height:960;overflow:auto;"></div>
        </td>
    </tr>
</table>

</div>


<div>Gviewer provides users with complete genome view of gene and QTL annotated to a function, biological process, cellular component, phenotype, disease, or pathway. The tool will search for matching terms from the Gene Ontology, Mammalian Phenotype Ontology, Disease Ontology or Pathway Ontology.</div>   


<script type="text/javascript">

var activeElement = null;

function selected(e) {
    if(!e) {
        activeElement=event.srcElement;
    }else {
        activeElement=e.target;
    }
}

function appendExpression() {
    //var rootExpression = document.getElementById("rootExpression");
  var baseExpression = document.getElementById("baseExpression").cloneNode(true);
  var expressionTable = document.getElementById("expressionTable");
  baseExpression.id =  baseExpression.id + new Date().getTime();
  expressionTable.appendChild(baseExpression);
  //activeObjects[activeObjects.lenght] = baseExpression;
  baseExpression.onmouseover=selected;

  setupAutoComplete();
}


function removeExpression(obj) {

 //obj = document.getElementById(objId);
  obj=activeElement;
  var expressionTable = document.getElementById("expressionTable");

  while (obj) {
      if (obj.id) {
          if (obj.id.indexOf("baseExpression") != -1) {
              expressionTable.removeChild(obj);
          }

      }

      obj=obj.parentNode;
   }
}

function checkForm(theform) {
    var atLeastOneTerm = false;
    var atLeastOneOntology = false;
    for(i=0; i<theform.elements.length; i++){
        if (theform.elements[i].name != "module" && theform.elements[i].name != "func") {
            if(theform.elements[i].type == "text" || theform.elements[i].type == "textarea" || theform.elements[i].type == "hidden"){
                if (theform.elements[i].name == "term[]" && theform.elements[i].value != "" && theform.elements[i].value.replace("*", "").length < 3) {
                    alert("Search terms must be at lease 3 characters long.");
                    return false;
                }else if (theform.elements[i].value != "") {
                    atLeastOneTerm = true;
                }
            } else if ((theform.elements[i].type == "checkbox" || theform.elements[i].type == "radio")) {
                if (theform.elements[i].checked) {
                    atLeastOneOntology = true;
                }else {

                }
            } else if (theform.elements[i].type == "select-one") {

            }
        }
    }

    if (!atLeastOneOntology) {
        alert("Please select an ontology");
        return false;
    }

    return atLeastOneTerm;
}//end PostAform function


function getFormString(theform) {
    var formStr = "";
    var amp = "";

    for(i=0; i<theform.elements.length; i++){
        if (theform.elements[i].name != "module" && theform.elements[i].name != "func") {
            if(theform.elements[i].type == "text" || theform.elements[i].type == "textarea" || theform.elements[i].type == "hidden"){
                formStr += amp+theform.elements[i].name+"="+encodeURIComponent(theform.elements[i].value);
            } else if ((theform.elements[i].type == "checkbox" || theform.elements[i].type == "radio")) {
                if (theform.elements[i].checked) {
                    formStr += amp+theform.elements[i].name+"="+encodeURIComponent(theform.elements[i].value);
                }else {
                    formStr += amp+theform.elements[i].name+"=-1";
                }
            } else if (theform.elements[i].type == "select-one") {
                formStr += amp+theform.elements[i].name+"="+theform.elements[i].options[theform.elements[i].selectedIndex].value;
            }
            amp = "&";
        }
    }
    return formStr;
}//end PostAform function

var gviewer = null;
function runGviewer() {
    if (checkForm(document.gviewerForm)) {
        document.getElementById("content").style.visibility = "visible";
        document.getElementById("loading").innerHTML ="<img src='/common/images/loading_2.gif' />";

        if (!gviewer) {
            gviewer = new Gviewer("gviewer", 300, 1000);

            gviewer.imagePath = "/rgdweb/gviewer/images";
            gviewer.exportURL = "/rgdweb/report/format.html";
            gviewer.annotationTypes = new Array("gene","qtl","strain");
            gviewer.genomeBrowserURL = "/jbrowse/?data=data_rgd6&tracks=ARGD_curated_genes";
            //gviewer.imageViewerURL = "/fgb2/gbrowse_img/rgd_5/?width=500&name=";
            gviewer.genomeBrowserName = "JBrowse";
            gviewer.regionPadding=2;
            gviewer.annotationPadding = 1;

            gviewer.loadBands("/rgdweb/gviewer/data/rgd_rat_ideo.xml");
            gviewer.addZoomPane("zoomWrapper", 250, window.screen.availWidth * .8);
        }else {
            gviewer.reset();
        }
        gviewer.loadAnnotationsGET("/rgdweb/gviewer/getAnnotationXml.html?z=" + getFormString(document.gviewerForm));

        //alert(getFormString(document.gviewerForm));
        //alert("/rgdweb/gviewer/getXmlTool.html?z=" + getFormString(document.gviewerForm));
        setTimeout("pageRequest('/rgdweb/gviewer/getXmlTool.html?z=" + getFormString(document.gviewerForm) + "', 'gviewerDiv')",500);
    }
    return false;
}

var http_request = false;

function pageRequest(url, divId) {
    //document.write(url);
    //return;
    http_request = false;

    if (window.XMLHttpRequest) // if Mozilla, Safari etc
        http_request = new XMLHttpRequest();
    else if (window.ActiveXObject){ // if IE
        try {
            http_request = new ActiveXObject("Msxml2.XMLHTTP");
        } catch (e){
            try{
                http_request = new ActiveXObject("Microsoft.XMLHTTP");
            } catch (e){}
        }
    }

    if (http_request.overrideMimeType) {
        http_request.overrideMimeType('text/xml');
    }
    if (!http_request) {
        alert('Cannot create XMLHTTP instance');
        return false;
    }

    http_request.onreadystatechange = function () {
    document.getElementById(divId).innerHTML = "";
    if (http_request.readyState == 4) {
        if (http_request.status == 200) {
            document.getElementById(divId).innerHTML =http_request.responseText;

            //forEach(document.getElementsByTagName('table'), function(table) {
            //    if (table.className.search(/\bsortable\b/) != -1) {
            //        sorttable.makeSortable(table);
            //    }
            //});

        } else {
            alert(http_request.responseText);
            alert('There was a problem with the request.');
        }
        document.getElementById("loading").innerHTML ="";
    }
}
http_request.open('GET', url + "&s=" + new Date().getTime(), true);
http_request.send(null);

}




function init() {
    runGviewer();
}

function selectAllOntologies(obj) {
    // obj is a button -- go to the parent table element, and find all checkboxes contained within
    $(obj).closest('table').find(':checkbox')
    // check all checkboxes
    .attr('checked','checked');
}

function unselectAllOntologies(obj) {
    // obj is a button -- go to the parent table element, and find all checkboxes contained within
    $(obj).closest('table').find(':checkbox')
    // uncheck all checkboxes
    .removeAttr('checked');
}

$(document).ready(function(){
    setupAutoComplete();
    $("input[name='term[]']")
        .closest('input')
        .result(function(data, value){

            $("#dataStatus").html("");
            //selectByTermId(value[1]);
        });

});

function setupAutoComplete() {

/*      <!--
<label title="GO Ontologies: Biological Process, Cellular Component, Molecular Function">&nbsp;GO&nbsp;<input name="go[]" type="checkbox" value="CC,MF,BP" checked></label>
<label title="RGD Disease Ontology">&nbsp; &nbsp;Disease&nbsp;<input name="do[]" type="checkbox" value="RDO" checked></label>
<label title="Neuro behavioral Ontology">&nbsp; &nbsp;Behavioral&nbsp;<input name="bo[]" type="checkbox" value="NBO" checked></label>
<label title="Mammalian Phenotype Ontology">&nbsp; &nbsp;Phenotype&nbsp;<input name="po[]" type="checkbox" value="MP" checked></label>
<label title="Pathway Ontology">&nbsp; &nbsp;Pathway&nbsp;<input name="wo[]" type="checkbox" value="PW" checked></label>
</td>
<td align="center"><input type="button" value="Select All" style="font-size:smaller;" onclick="selectAllOntologies(this);"></td>
   </tr>
<tr>
<td>
<label title="Clinical Measurement Ontology">&nbsp;CMO&nbsp;<input name="cmo[]" type="checkbox" value="CMO" checked></label>
<label title="Measurement Method Ontology">&nbsp; &nbsp;MMO&nbsp;<input name="mmo[]" type="checkbox" value="MMO" checked></label>
<label title="Experimental Condition Ontology">&nbsp; &nbsp;XCO&nbsp;<input name="xco[]" type="checkbox" value="XCO" checked></label>
<label title="Rat Strain Ontology">&nbsp; &nbsp;Strain&nbsp;<input name="rs[]" type="checkbox" value="RS" checked></label>
<label title="Vertebrate Trait Ontology">&nbsp; &nbsp;Trait&nbsp;<input name="vt[]" type="checkbox" value="VT" checked></label>
<label title="Chemical Entities of Biological Interest Ontology">&nbsp; &nbsp;ChEBI&nbsp;<input name="chebi[]" type="checkbox" value="CHEBI" checked></label>
        -->
  */
    $("input[name='term[]']").autocomplete('/solr/OntoSolr/select', {
            extraParams:{
                'qf': 'term_en^5 term_str^3 term^3 synonym_en^4.5 synonym_str^2 synonym^2 def^1 anc^1',
                'bf': 'term_len_l^.02',
                'fq': 'cat:(BP CC MF RDO NBO MP PW CMO MMO XCO VT CHEBI)',
                //'fq': cats,
                'wt': 'velocity',
                //'v.template': 'termidterm'
                'v.template': 'termidselect'
            },
            max: 100,
            'termSeparator': ' OR '
        }
    );


}
</script>

<jsp:include page="../common/footerarea.jsp" flush="true"/>

