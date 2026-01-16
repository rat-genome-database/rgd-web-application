<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%
HttpRequestFacade rq = (HttpRequestFacade) request.getAttribute("requestFacade");
SimpleDateFormat sdf = new SimpleDateFormat("mm/dd/yyyy");
FormUtility fu = new FormUtility();
DisplayMapper dm = new DisplayMapper(rq, error);

%>


<style type="text/css">
    .updateTile {
        border-top: 1px solid #2865a3;
        padding: 2px;
        background-color:#f9f9f9;
    }
</style>

<script type="text/javascript" src="/rgdweb/js/util.js"></script>

<link rel="stylesheet" href="/rgdweb/js/windowfiles/dhtmlwindow.css" type="text/css"/>
<script type="text/javascript" src="/rgdweb/js/windowfiles/dhtmlwindow.js">
    /***********************************************
     * DHTML Window Widget- � Dynamic Drive (www.dynamicdrive.com)
     * This notice must stay intact for legal use.
     * Visit http://www.dynamicdrive.com/ for full source code
     ***********************************************/
</script>
<script type="text/javascript" src="/rgdweb/js/lookup.js"></script>


<%
    boolean isClone = (Boolean) request.getAttribute("isClone");
    boolean isNew = (Boolean) request.getAttribute("isNew");
    int speciesTypeKey;

    if (isNew) {
        speciesTypeKey = SpeciesType.parse(request.getParameter("speciesType"));
    } else {
        RGDManagementDAO dao = new RGDManagementDAO();
        RgdId id = dao.getRgdId(Integer.parseInt(request.getParameter("rgdId")));
        speciesTypeKey = id.getSpeciesTypeKey();
    }

%>

<script type="text/javascript">

    //onload=enableAllOnChangeEvents;
        

    onload= function () {
        for (var i=0; i< document.forms.length; i++) {
            enableOnChangeEvents(document.forms[i]);
        }

        <% if (isClone) { %>
        for (var j=0; j< document.forms.length; j++) {
            setChanged(document.forms[j]);
        }


        <% }  %>
    }

    var http_request = false;
    var lastForm = null;
    var altAlertObjId = null; // id of an alternate object to be alerted when ajax request completes

    function makePOSTRequest(theForm) {
        makePOSTRequest(theForm, null);
    }

    function makePOSTRequest2(theForm, alertObjId) {
        altAlertObjId = alertObjId;
        makePOSTRequest(theForm);
    }

    function makePOSTRequest(theForm, fnCallback) {

       http_request = false;
       lastForm = theForm;
       onRequestCompleteCallback = fnCallback;

       if (window.XMLHttpRequest) { // Mozilla, Safari,...
          http_request = new XMLHttpRequest();
          if (http_request.overrideMimeType) {
              // set type accordingly to anticipated content type
             //http_request.overrideMimeType('text/xml');
             http_request.overrideMimeType('text/html');
          }
       } else if (window.ActiveXObject) { // IE
          try {
             http_request = new ActiveXObject("Msxml2.XMLHTTP");
          } catch (e) {
             try {
                http_request = new ActiveXObject("Microsoft.XMLHTTP");
             } catch (e) {}
          }
       }

       if (!http_request) {
          alert('Cannot create XMLHTTP instance');
          return false;
       }

       http_request.onreadystatechange = alertContents;
       var parameters = create_request_string(theForm);
       http_request.open('POST', theForm.action, true);
       http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
       //http_request.setRequestHeader("Content-length", parameters.length);
       //http_request.setRequestHeader("Connection", "close");
       http_request.send(parameters);
    }

    function alertContents() {
       if (http_request.readyState == 4) {
          //if (http_request.status == 200) {
             //alert(http_request.responseText);
             result = http_request.responseText;

             if (result.indexOf("Update Successful") != -1) {
                 setUpdated(lastForm);
             }
             document.getElementById('msg').innerHTML=result;
             document.getElementById('myspan').innerHTML = result;

             if( altAlertObjId!=null ) {
               document.getElementById(altAlertObjId).innerHTML = result;
               altAlertObjId = null;
             }
       }
    }

 function enableOnChangeEvents(form) {
     for (var j=0; j< form.elements.length; j++) {
         form.elements[j].onchange = function() {
             this.style.backgroundColor = "#FFCCCC";
             this.style.border="1px solid #7f9db9";
             this.style.padding="2px";
             this.isSet = true;
         }
     }
 }

 function enableAllOnChangeEvents() {
     for (var i=0; i< document.forms.length; i++) {
         enableOnChangeEvents(document.forms[i]);
     }
 }

 function setUpdated(form) {
     for (var j=0; j< form.elements.length; j++) {
         if (form.elements[j].isSet) {
             form.elements[j].style.backgroundColor = "#E6FFCC";
             form.elements[j].style.border ="1px solid #7f9db9";
             form.elements[j].style.padding = "2px";
             form.elements[j].isSet = false;
         }
     }
     if( onRequestCompleteCallback!=null )
        onRequestCompleteCallback();
 }

 function setChanged(form) {
     for (var j=0; j< form.elements.length; j++) {
         var elm = form.elements[j];
         if (elm.value != "" && elm.type != "button" && elm.type != "submit" && elm.name != "objectStatus" && elm.name != "speciesType") {
             setElementChanged(form.elements[j]);
         }
     }
 }

    function setElementChanged(elm) {
        elm.style.backgroundColor = "#FFCCCC";
        elm.style.border ="1px solid #7f9db9";
        elm.style.padding = "2px";
        elm.isSet = true;
    }

 function create_request_string(theForm) {
     var reqStr = "";

     for (i = 0; i < theForm.elements.length; i++) {
         isFormObject = false;

         switch (theForm.elements[i].tagName){
             case "INPUT":
                 switch (theForm.elements[i].type){
                     case "text":
                     case "hidden":
                         reqStr += theForm.elements[i].name + "=" + encodeURIComponent(theForm.elements[i].value);
                         isFormObject = true;
                         break;
                     case "checkbox":
                         if (theForm.elements[i].checked) {
                             reqStr += theForm.elements[i].name + "=" + theForm.elements[i].value;
                         } else {
                             reqStr += theForm.elements[i].name + "=";
                         }
                         isFormObject = true;
                         break;
                     case "radio":
                         if (theForm.elements[i].checked) {
                             reqStr += theForm.elements[i].name + "=" + theForm.elements[i].value;
                             isFormObject = true;
                         }
                 }
                 break;
             case "TEXTAREA":
                 reqStr += theForm.elements[i].name + "=" + encodeURIComponent(theForm.elements[i].value);
                 isFormObject = true;
                 break;
             case "SELECT":
                 var sel = theForm.elements[i];
                 reqStr += sel.name + "=" + sel.options[sel.selectedIndex].value;
                 isFormObject = true;
                 break;
         }

         if ((isFormObject) && ((i + 1) != theForm.elements.length)) {
             reqStr += "&";
         }
     }
     return reqStr;
 }

 var areaCount = 1;
 function addTextArea(idVal, speciesTypeKey, objectKey) {

     var obj = document.getElementById(idVal + "TD");

     var input = document.createElement("input");

     input.type = "hidden";
     input.name = "notesKey";
     input.value = "";
     obj.appendChild(input);

     input = document.createElement("input");

     input.type = "text";
     input.id = idVal + "c" + areaCount;
     input.name = idVal;
     input.size = 9;

     setElementChanged(input);

     obj.appendChild(input)

     var lookup = document.createElement("a");
     lookup.border = "0";
     lookup.innerHTML = '<img src="/rgdweb/common/images/glass.jpg" border="0"/>';

     var hrefStr = "javascript:";

     if (objectKey) {
        hrefStr = hrefStr + "lookup_render('" + idVal + "c" + areaCount + "', 3,'" + objectKey + "')";
     } else {
        hrefStr = hrefStr + "lookup_render('" + idVal + "c" + areaCount + "',3)"; 
     }

     //lookup.href=hrefStr;
     lookup.href =  hrefStr + ";void(0);";
     obj.appendChild(lookup);

     var del = document.createElement("a");
     del.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
     del.border="0";
     del.href = "javascript:removeAssociation('" + idVal + "c" + areaCount + "');void(0);";
     obj.appendChild(del);
     areaCount++;

     enableAllOnChangeEvents();
 }

 function removeAssociation(associationId) {
     var d = document.getElementById(associationId);
     var pd = d.parentNode;

     pd.removeChild(d.nextSibling);
     pd.removeChild(d.nextSibling);
     pd.removeChild(d);

 }

 var aliasCreatedCount = 1;
 function addAlias() {

     var tbody = document.getElementById("aliasTable").getElementsByTagName("TBODY")[0];

     var row = document.createElement("TR");
     row.id = "aliasRowc" + aliasCreatedCount;
     row.innerHTML = '<input type="hidden" name="aliasKey" value="0" />';
     var td = document.createElement("TD");
     //td.innerHTML = '<input type="text" id="aliasTypeName" name="aliasTypeName" value="" />';

     td.innerHTML = '<%=fu.buildSelectList("aliasTypeName", new AliasDAO().getAliasTypesExcludingArrayIds(), dm.out("aliasTypeName",""))%>';

     row.appendChild(td);

     td = document.createElement("TD");
     td.innerHTML = '<input size="66" type="text" name="aliasValue" value="" />'+
        '<a style="color:red; font-weight:700;" href="javascript:removeAlias(\'aliasRowc'+aliasCreatedCount+'\') ;void(0);"><img '+
            'src="/rgdweb/common/images/del.jpg" border="0"/></a>';
     row.appendChild(td);

     tbody.appendChild(row);

     aliasCreatedCount++;
     enableAllOnChangeEvents();
 }

 function removeAlias(aliasId) {
     var d = document.getElementById(aliasId);
     d.parentNode.removeChild(d);
 }
    

</script>

<span id="myspan"></span>
