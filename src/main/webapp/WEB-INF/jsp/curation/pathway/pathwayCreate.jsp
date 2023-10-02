<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.PathwayDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.XdbIdDAO" %>
<%@page import="edu.mcw.rgd.datamodel.Pathway" %>
<%@ page import="static org.apache.commons.io.FileUtils.*" %>
<%@ page import="edu.mcw.rgd.datamodel.PathwayObject" %>
<%@ page import="edu.mcw.rgd.datamodel.Reference" %>
<%@ page import="edu.mcw.rgd.datamodel.XdbId" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
    String pageTitle = "Rat Genome Database Pathway";
    String headContent = "Rat Gemnome Database Pathway";
    String pageDescription = "Rat Genome Database Pathway";
%>
<%@ include file="/common/headerarea.jsp"%>
<%

    HttpRequestFacade req= new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req, error);
            Term pwID = new Term();
            XdbId xdb = new XdbId();
            OntologyXDAO ontXdao = new OntologyXDAO();
            PathwayDAO pwdao = new PathwayDAO();
            XdbIdDAO xdbidDao = new XdbIdDAO();
            Term newTerm = null;
            Pathway newPW = new Pathway();
            String pwFilePath = "";
            String cacheFilePath = "";
            File pwf;
            int referenceRows = 1;
            int altpathRows = 1;
            int assocPathObjRows = 1;
            List<Reference> referencesList = new ArrayList<Reference>();
            List<String> pmids = new ArrayList<String>();
            List<String> altStringList= new ArrayList<String>();
            List<PathwayObject> newPObjectList = new ArrayList<PathwayObject>();



            //get directory for uplaoding pathya files.. and directory for creating cache files.

            String cacheFileDir = (String) request.getAttribute("dataDir");
            //System.out.println("here is where the cache files go!!" + cacheFileDir);

            String ourTempDirectory = (String) request.getAttribute("uploadingDir");
            //System.out.println("the uploading dir can also be accessed by pathwayCreate.JSP:" + ourTempDirectory);


            System.out.println("getting pathway Term" + req.getParameter("acc_id"));
            String pid = (String) req.getParameter("acc_id").trim();
            // if(!(request.getParameter("term_acc").equals(null))){
            //System.out.println("getting create pathway Object" + request.getAttribute("createPwObj"));

            if (request.getAttribute("createPwObj")!=null) {
                //pwID = request.getParameter("term_acc");
                System.out.println("getting pathway Object");
                pwID = (Term) request.getAttribute("createPwObj");
                //System.out.println("here is the Pathway ID:" + pwID.getAccId());
                Reference r = new Reference();
                PathwayObject po = new PathwayObject();
                String altPath = "";
                String pmid = "";

                referencesList.add(r);
                pmids.add(pmid);
                altStringList.add(altPath);
                newPObjectList.add(po);

            }else

            if(request.getAttribute("editPwObj")!=null){
                //pwID = request.getParameter("term_acc");
                //System.out.println("getting edit pathway Object");
                pwID = (Term) request.getAttribute("editPwObj");
                //System.out.println("here is the editing Pathway ID:" + pwID.getAccId());
                //System.out.println("here is the editing description.. "+ newPW.getDescription());

                if(pwID.getAccId()!=null) {
                    newPW = pwdao.getPathwayInfo(pwID.getAccId());
                    //System.out.println("here is the editing altered path y/n"+ newPW.getHasAlteredPath());

                    referencesList = newPW.getReferenceList();
                    referenceRows = referencesList.size();
                    for(int i=0; i<referenceRows; i++){
                        List<XdbId> pmid = xdbidDao.getPubmedIdsByRefRgdId(referencesList.get(i).getRgdId());
                        if(pmid.size()>0){
                            pmids.add(pmid.get(0).getAccId());
                        }else{
                            pmids.add("");
                        }

                    }

                    if(newPW.getHasAlteredPath().equals("Y")){
                        altStringList = pwdao.getAltPwIDs(pwID.getAccId());
                        altpathRows = altStringList.size();
                    }else if(newPW.getHasAlteredPath().equals("N")){
                        String altPath = "";
                        altStringList.add(altPath);
                    }

                    //System.out.println("###########newpwObjectList is here:" + newPW.getObjectList());

                    if(newPW.getObjectList()==null){
                        PathwayObject po = new PathwayObject();
                        newPObjectList.add(po);

                    }else{
                        newPObjectList = newPW.getObjectList();
                        assocPathObjRows = newPObjectList.size();
                    }


                }
            }else if(request.getAttribute("error")!=null){

                referenceRows = req.getParameterValues("RGDID").size();
                for(int k=0; k<referenceRows; k++){
                    Reference r = new Reference();
                    referencesList.add(r);
                    List<XdbId> pmid = xdbidDao.getPubmedIdsByRefRgdId(referencesList.get(k).getRgdId());
                    if(pmid.size()>0){
                        pmids.add(pmid.get(0).getAccId());
                    }else{
                        pmids.add("");
                    }
                }

                //System.out.println("here is the with error alt path"+ req.getParameterValues("AltPathAccID").get(0));
                altpathRows = req.getParameterValues("AltPathAccID").size();
                for(int i=0; i<altpathRows; i++){
                    String altPath = "";
                    altStringList.add(altPath);
                }

                assocPathObjRows = req.getParameterValues("obj_xdb_desc").size();
                //System.out.println("here is the editing assoc obj"+ req.getParameterValues("obj_xdb_desc").size());
                for(int j=0; j<assocPathObjRows; j++){
                    PathwayObject po = new PathwayObject();
                    newPObjectList.add(po);
                }
            }


            //System.out.println("here is our temp dir:" + ourTempDirectory);

            String pwNum[] = null;
            //session.setAttribute("tempDir", ourTempDirectory);
            //String ourTempDirectory = "/rgd/www/pathway"; //for the server..
            //System.out.println("here is the ID" + pid);
            if(pid.contains(":")){
                pwNum = pid.split(":");
            }else if(pid.contains("%3A")){
                pwNum = pid.split("%3A");
            }

            /*pwf = new File(ourTempDirectory + pwNum[0] + pwNum[1] + "\\");
            //System.out.println("here is the path of the folder that will be created" + pwf);*/

            pwFilePath = ourTempDirectory + pwNum[0] + pwNum[1];
            cacheFilePath = cacheFileDir + pwNum[0] + pwNum[1];
            //System.out.println("****here is the file path: "+ pwFilePath);
            session.setAttribute("flag", "0");
            //System.out.println("****flag is: "+ session.getAttribute("flag")+ "###############");
            /*if (pwf.exists() && pwf.isDirectory()) {
                //out.println("this directory exists!!!..cleaning directory");
                //System.out.println("this directory exists!!!..cleaning directory");
                cleanDirectory(pwf);
            } else {
                //out.println("new directory being created!!!..creating new directory");
                //System.out.println("new directory being created!!!..creating new directory");
                forceMkdir(pwf);
            }*/

    //System.out.println("ssup??");

            //out.println("here is the pathway location:" + pwf);

        %>





<script language="JavaScript" type="text/javascript">

   /* var OptionsList =  new Array();
    OptionsList['select'] = "Select your Object Entity";
    OptionsList['protein'] = "Protein";
    OptionsList['smallMolecule'] = "Small molecule";
    OptionsList['treatment'] = "Treatment";
    OptionsList['cellProcess'] = "Cell Process";
    OptionsList['disease'] = "Disease";
    OptionsList['cellObject'] = "Cell Object" ;
    OptionsList['pathway'] = "Pathway";
    OptionsList['complex'] = "Complex";
    OptionsList['functionalClass'] = "Functional Class";
    OptionsList['geneGroup'] = "Gene Group";
    OptionsList['gene'] = "Gene";*/

    var OptionsList =  new Array();
    OptionsList['0'] = "Select your Object Entity";
    OptionsList['3'] = "Protein";
    OptionsList['1'] = "Small molecule";
    OptionsList['4'] = "Treatment";
    OptionsList['10'] = "Cell Process";
    OptionsList['5'] = "Disease";
    OptionsList['6'] = "Cell Object" ;
    OptionsList['7'] = "Pathway";
    OptionsList['2'] = "Complex";
    OptionsList['8'] = "Functional Class";
    OptionsList['9'] = "Gene Group";
    OptionsList['11'] = "Gene";

function getElementsByName_allBrowsers(formVal, name) {
    var arr = new Array();
    for(var i=0, iarr=0; i< formVal.elements.length; i++ ) {
        //alert(formVal.elements[i].name);
         //var att = elem[i].getAttribute("name");
        var att = formVal.elements[i].name;
        if(att == name) {
            arr[iarr] = formVal.elements[i];
            iarr++;
        }
    }
    return arr;
}


function validateForm(formVal){

// the validateForm function has another function that is called from within it.. the name of this function is "getElementsByName_allbrowsers"
// this is an alternative for the custom "getElementsByName" method that gets all elements with the same tag name as an array.
    // this method seems to work in IE only for static rows..
    //when rows are added dynamically. the DOM tree doesnt seem to update itself. hence thsi new method traverses through all teh tags in the page and creates an array that get added into each
    //"validateXXX() methods.. 


    var reason = "";
    var error = "";
    //alert(formVal +": form done!!!");
    //alert(getElementsByName_allBrowsers(formVal, "RGDID").length);
    //alert(document.pathwayForm.acc_id.name);
    //alert(getElementsByName_allBrowsers(formVal, "acc_id")[0].value);
    error += validatereferences(getElementsByName_allBrowsers(formVal, "RGDID"));
    error += validateAlteredPathways(getElementsByName_allBrowsers(formVal, "AltPathAccID"));
    error += validateAssocPathwayObjects(formVal);

    reason += error;
    if(reason.length>1){
        alert("Some Fields need correction:\n" + error);
        return false;
    }
    else{
        //alert("done entering all values..");
        return true;
    }
}

function validatereferences(inputElement){
    var error = "";
    //alert("###"+inputElement.length);
   // alert("*****"+inputElement.value);
    
    if (!inputElement.length) {
        //alert("i have an input"+ inputElement.value.length);
        //alert("here is the ID:" + inputElement.value);
        //alert("is this true"+ inputElement.value.search(/^\d+$/));
        if((inputElement.value.length>1)&&(inputElement.value.search(/^\d+$/)==-1)){
            //alert("entered rgdid value search condition!!");
            error += "RGD ID must be numeric in row: " +(1)+" \n";
        }else{
            //alert("did not enter rgdid value search condition!!");
        }
        if((inputElement.value.length<1)||(inputElement.value==null)||(inputElement.value==0)){
            //alert("entered rgdid length condition");
            error += "Reference RGD must not be empty/0 in row: "+(1)+" Enter a valid associated Reference RGDID\n";
        }
        else{
            //alert("did not enter rgdid length condition!!");
        }
    }else{
        //alert("I have an array\nhere is the reference length:" + inputElement.length);
        for(var i=0; i<inputElement.length; i++ ){
            //alert("here is the ID:" + inputElement[i].value);
            if((inputElement[i].value.length)&&(inputElement[i].value.search(/^\d+$/)==-1)){
                error += "RGD ID must be numeric in row: " +(i+1)+" \n";
            }
            if((inputElement[i].value.length<=1)||(inputElement[i].value==null)){
                error += "Reference RGD must not be empty in row: "+(i+1)+" Enter a valid associated Reference RGDID\n";
            }
        }
    }
    return error;
}

function validateAlteredPathways(inputAltPath){
    var error = "";
    //alert("entering validate altered paths");
    if(inputAltPath.length){
        //alert("i have an array");
        //alert("here is the alt Path:" + inputAltPath[0].value + "and length is:" + inputAltPath[0].length);
        for(var j=0; j<inputAltPath.length; j++ ){
            //alert("here is the alt Path:" + inputAltPath[j].value + "and length is:" + inputAltPath[j].value.length);
            if(inputAltPath[j].value.length){
                if(!(inputAltPath[j].value.search(/^PW\:\d+/)>-1)){
                    error += "alternate pathway must have a 'PW' and a ':' before the numbers in row.." +(j+1) +"\n";
                }
                if(!(inputAltPath[j].value.length==10)){
                    error += "the length of the Pathway Ontology ID must be 10 in row: "+(j+1) +"i.e PW:XXXXXXX must be 10 characters long\n";
                }
            }

        }
    }else{
        //alert("i have an input");
        //alert("here is the alt Path:" + inputAltPath.value + "and length is:" + inputAltPath.value.length);
        if(inputAltPath.value.length>1){
            if(!(inputAltPath.value.search(/^PW\:\d+/)>-1)){
                error += "alternate pathway must have a 'PW' and a ':' before the numbers in row.." +(1) +"\n";
            }
            if(!(inputAltPath.value.length==10)){
                error += "the length of the Pathway Ontology ID must be 10 in row: "+(1) +"i.e PW:XXXXXXX must be 10 characters long\n";
            }
        }

    }
    return error;
}

function validateAssocPathwayObjects(pathObj){
    //alert("entering pathwayObjects:");

    var error = "";
    var objName = getElementsByName_allBrowsers(pathObj, "obj_xdb_name");
    var selectedObj = getElementsByName_allBrowsers(pathObj, "selectedObject");
    var objDesc = getElementsByName_allBrowsers(pathObj, "obj_xdb_desc");
    var objXdbKey = getElementsByName_allBrowsers(pathObj, "obj_xdb_xdb_key");
    var objXdbUrl = getElementsByName_allBrowsers(pathObj, "obj_xdb_url");

    if(objName.length){
        //alert("i have an array in assoc pathway Objects: " + objName.length);
        //alert("here is the selected index:"+ selectedObj[0].selectedIndex);
        //alert("here is the select option.. " + selectedObj[0].value);

        //alert("entering select options for select");
        //alert("here is the length of select object: " + selectedObj.length);
        for(var k=0; k<selectedObj.length; k++ ){
           // alert("here is the select option.. " + pathObj.selectObject[k].value);
            //if(pathObj.selectObject[k].value.search(/\bselect\b/)>-1){
            if((objDesc[m].value.length>1)&&(objName[l].value.length>1)&&(selectedObj[k].selectedIndex==0)){
                error += "You havent yet selected an option from the dropdown box."+
                "Please pick an option from the Dropdown Box in row: " +(k+1)+ "\n";
            }
        }
        for(var l=0; l<objName.length; l++ ){
            if((selectedObj[k].selectedIndex!=0)&&(objDesc[m].value.length>1)&&(!(objName[l].value.length>1))){
                error += "please add in a name for your pathway Object in row: " + (l+1) + "\n";
            }
        }
        for(var m=0; m<objDesc.length; m++ ){
            if((selectedObj[k].selectedIndex!=0)&&(objName[l].value.length>1)&&(!(objDesc[m].value.length>1))){
                error += "please add in a description for your pathway Object in row: "+ (m+1)+ "\n";
            }
        }
        for(var n=0; n<objXdbKey.length; n++ ){
            if((objXdbKey[n].value.length>1)&&(!(objXdbKey[n].value.search(/[0-9]+/)>-1))){
                error += "Error in row:"+ (n+1)+"if you have entered an XDB key, it need to be numerical and between 1 and 45."+
                "Else please leave this field blank and enter the URL of the link you need to add\n";
            }
            if((objXdbUrl[n].value.length>1)&&(objXdbUrl[n].value.length>1)){
                error += "You do not need both, the Key and the URL. Either one of the entries is good to create link. Error caught in row: "+ (n+1)+ "\n";
            }
        }
    }else{
        //alert("i have an input in aooc pathway objects");
        //alert("if you hav eonly one input then length of selectObject becomes length of array that contains all options!:" + selectedObj.length);
        //alert("here is the selected index:"+ selectedObj.selectedIndex);
        //alert("here is the select option.. " + selectedObj.value);
        if(selectedObj.selectedIndex==0){
            error += "You havent yet selected an option from the dropdown box."+
            "Please pick an option from the Dropdown Box in row: " +(1)+ "\n";
        }

        if(!(objName.value.length>1)){
            error += "please add in a name for your pathway Object in row: " + (1) + "\n";
        }

        if(!(objDesc.value.length>1)){
            error += "please add in a description for your pathway Object in row: "+ (1)+ "\n";
        }
        if((objXdbKey.value.length>1)&&(!(objXdbKey.value.search(/[0-9]+/)>-1))){
            error += "Error in row"+ (1)+"if you have entered an XDB key, it need to be numerical and between 1 and 45."+
            "Else please leave this field blank and enter the URL of the link you need to add\n";
        }
        if((objXdbUrl.value.length>1)&&(objXdbUrl.value.length>1)){
            error += "You do not need both, the Key and the URL. Either one of the entries is good to create link: "+ (1)+ "\n";
        }
    }
    return error;
}

function addAltRow(tableID) {

    var table = document.getElementById(tableID);

    var rowCount = table.rows.length;
    //alert("There are:" + (rowCount) + "rows")

    var row = table.insertRow(rowCount);

    var cell1 = row.insertCell(0);
    var element1 = document.createElement("input");
    element1.type = "checkbox";
    element1.id = "checkAlt"+rowCount;
    element1.name = "checkAlt";
    cell1.appendChild(element1);

    var cell3 = row.insertCell(1);
    var element3 = document.createElement("input");
    element3.type = "text";
    element3.name = "AltPathAccID";
    element3.id = "AltPathAccID"+rowCount;
    cell3.appendChild(element3);
}

function addRow(tableID) {
    var table = document.getElementById(tableID);

    var rowCount = table.rows.length;
    //alert("There are:" + (rowCount) + "rows")

    var row = table.insertRow(rowCount);

    var cell1 = row.insertCell(0);
    var element1 = document.createElement("input");
    element1.type = "checkbox";
    element1.id = "check"+rowCount;
    element1.name = "check";
    cell1.appendChild(element1);

    var cell2 = row.insertCell(1);
    var element2 = document.createElement("input");
    element2.type = "text";
    element2.name = "pmid_list";
    element2.value="";
    element2.id = "pmid_list"+rowCount;
    cell2.appendChild(element2);

    //alert("adding cellB");
    var cellb = row.insertCell(2);
    var elementb = document.createElement("input");
    elementb.id = "getPMID"+rowCount;
    elementb.name = "getPMID";
    elementb.type = "button";
    elementb.value = "Get Reference RGDID";
    elementb.onclick = CreateEventOnClick;   //check: http://www.howtocreate.co.uk/tutorials/javascript/domevents
    cellb.appendChild(elementb);

    var cell3 = row.insertCell(3);
    var element3 = document.createElement("input");
    element3.type = "text";
    element3.name = "RGDID";
    element3.id = "RGDID"+rowCount;
    cell3.appendChild(element3);
}

function CreateEventOnClick(e) {
    if (!e) e = window.event;
    var obj = document.all ? e.srcElement : e.currentTarget;
    //alert(obj.id);
    fnGetRefRGDId(obj.id);
}

function addObjectRow(tableID) {

    var table = document.getElementById(tableID);

    var rowCount = table.rows.length;
    //alert("There are:" + (rowCount) + "rows")

    var rowx = table.insertRow(rowCount);

    var cell1 = rowx.insertCell(0);
    var element1 = document.createElement("input");
    element1.type = "checkbox";
    element1.id = "checkObj"+rowCount;
    element1.name = "checkObj";
    cell1.appendChild(element1);

    var cell2 = rowx.insertCell(1);
    var element2 = document.createElement("select");
    element2.id = "selectObject"+rowCount;
    element2.name = "selectObject";
    //element2.id = "select";

    //alert("***" + OptionsList['select'] + "####");

    for(var i in OptionsList){
        var elementO = document.createElement("option");
        //var element = addOption(elementO, i, OptionsList[i]);
        elementO.text = OptionsList[i];
        //alert("this is the text in OptionsList" + OptionsList[i]);
        elementO.value = i;
       // elementO.select(self);
        //elementO.id = OptionsList.index;
        if(document.all){
            //alert("all");
            element2.add(elementO);
        }else{
            //alert("not IE");
            element2.add(elementO, null);
        }

    }
    cell2.appendChild(element2);

    var cell3 = rowx.insertCell(2);
    var element3 = document.createElement("input");
    element3.type = "text";
    element3.name = "obj_xdb_name";
    element3.id = "obj_xdb_name"+rowCount;
    element3.size = "20";
    cell3.appendChild(element3);

    var cell4 = rowx.insertCell(3);
    var element4= document.createElement("input");
    element4.type = "text";
    element4.name = "obj_xdb_desc";
    element4.id = "obj_xdb_desc"+rowCount;
    element4.size = "20";
    cell4.appendChild(element4);

    var cell5 = rowx.insertCell(4);
    var element5= document.createElement("input");
    element5.type = "text";
    element5.name = "obj_xdb_accession";
    element5.id = "obj_xdb_accession"+rowCount;
    element5.size = "20";
    cell5.appendChild(element5);

    var cell7 = rowx.insertCell(5);
    var element7= document.createElement("input");
    element7.type = "text";
    element7.name = "obj_xdb_key";
    element7.id = "obj_xdb_key"+rowCount;
    element7.size = "20";
    cell7.appendChild(element7);

    var cell6 = rowx.insertCell(6);
    var element6= document.createElement("input");
    element6.type = "text";
    element6.name = "obj_xdb_url";
    element6.id = "obj_xdb_url"+rowCount;
    element6.size = "20";
    cell6.appendChild(element6);
}

function delRow(tableID) {
    try {
    var table = document.getElementById(tableID);
    var rowCount = table.rows.length;
    //alert("there are"+rowCount+"number of rows before deleting");
        
    for(var i=0; i<rowCount; i++) {
        var row = table.rows[i];
        var chkbox = row.cells[0].childNodes[0];
        if(null != chkbox && true == chkbox.checked) {
            table.deleteRow(i);
            rowCount--;
            i--;
        }

    }
    }catch(e) {
        alert(e);
    }
}

var http = getHTTPObject();
function getHTTPObject() {
	var xmlhttp;
	if (window.XMLHttpRequest) {
		xmlhttp = new XMLHttpRequest();
	}
	else if (window.ActiveXObject) {
 		xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
 	}
 	else{
        //Error for an old browser
        alert('Your browser is not IE 5 or higher, or Firefox or Safari or Opera');
    }
    return xmlhttp;
}

function handleHttpResponse() {
    //var row = rowNum;
    //alert("****state: "+http.readyState);
    if (http.readyState==4) {
        //alert("(ready state) "+http.readyState + " (status: )" + http.status);
        if(http.status==200) {
            //alert("status = 200"+ http.status);
            //alert("=> "+http.responseXML.getElementsByTagName("rgdid")[0].childNodes[0].nodeValue);
            //var response2 = http.responseJSON.getElementById("rgdid");
            var response = http.responseXML.getElementsByTagName("rgdid")[0].childNodes[0].nodeValue;
            var resp = response.split("\t", -1);
            //alert("^^^^"+resp[0]+"%%%");

            document.getElementById("RGDID"+resp[1]).value=resp[0];

        } else {
        alert("Error loading page"+ http.status +
        ":"+http.statusText);
            alert ( "Not able to retrieve RGDID" );
        }
    }
}

function fnGetRefRGDId(fld) {
    var row = fld;
    row = row.replace(/getPMID/ig,"");
    var id = "pmid_list"+row;
    var pmid = document.getElementById(id).value;
    var error="";
    if(!(pmid.search(/^\d+$/)>-1)){
        error = "you need to enter in a valid number greater than 0";
        //alert("Error validating PubmedID: "+error);
        return false;
    }else{
        var rowNum = row;
        var url = '/rgdweb/pubmed/importReferences.html?action=pathway&pmid_list='+pmid+'&row='+row;

        http.open("GET", url, true);
        http.onreadystatechange = handleHttpResponse;
        http.send(url);
        return true;
    }
}
</script>



<form id="pathwayForm" name="pathwayForm" action="/rgdweb/pathway/pathwayRecord.html" method="POST" onsubmit="return validateForm(this)">
<input name="processType" type="hidden" id="processType" <c:choose><c:when test='<%=(newPW.getId()!=null) || (req.getParameter("processType").equals("update"))%>'>
       value="update" </c:when><c:otherwise>value="create"</c:otherwise></c:choose>/>

<table id="pathwayCreate" title="New Pathway Record">
    <tr>
        <h1><%
            if(req.getParameter("pathwayName").equals("")){
                if(newPW.getId()!=null){
                    out.println("Editing "+ dm.out("pathwayName", newPW.getName()));
                }else{
                     out.println("Creating " + dm.out("acc_id", pid));
                }
            }else{
                if(req.getParameter("processType").equals("update")){
                    out.println("Editing "+ dm.out("pathwayName", newPW.getName()));
                }
                out.println("Creating " + dm.out("acc_id", pid));
            }
        %></h1>
    </tr>
    <tr>
        <td style="color:#d2691e;text-decoration:blink;font-weight:bolder;">** indicates required fields</td>
    </tr>
    <tr>
        <td><b>Enter Pathway ID</b></td>
        <td><input id="acc_id" name="acc_id" type="text" size="94" align="left"
                   value="<%=dm.out("acc_id", pid)%>" readonly="readonly"></td>
    </tr>
    <%
        System.out.println("done with pathway ID");
    %>
    <tr>
        <td><b>Enter Pathway Ontology Term</b></td>
        <td colspan="4"><input id="pathwayName" size="94" name="pathwayName" type="text" align="left"
                               value="<%=dm.out("pathwayName", pwID.getTerm())%>" readonly="readonly"></td>
    </tr>
    <%
        System.out.println("done with pathway term");
    %>
    <tr>
        <td><b>Enter Description for Pathway</b></td>
        <td>
            <textarea rows="20" cols="70" name="pathwayDesc"><%=dm.out("pathwayDesc", newPW.getDescription())%></textarea>
        </td>
    </tr>
    <%
        System.out.println("done with pathway description");
    %>
    <tr>
        <td><br /><b>Associated References ** </b></td>
        <td colspan="2">
            <br />
            <input type="button" value="Add Row" onclick="addRow('RefRGDID')">
            <input type="button" value="Delete Row" onclick="delRow('RefRGDID')">
        </td>
    </tr>
    <tr>
        <td>Please Input Reference RGDID: </td>
        <td>
        <table id="RefRGDID">
            <tr>
                <td align="center"><b>Check</b></td>
                <td align="center"><b>Reference PubmedID</b></td>
                <td align="center"><b>Get Reference RGDID</b></td>
                <td align="center"><b>Reference RGDID</b></td>
            </tr>

            <%
                    System.out.println("references adding");

                    for(int r=0;r<referenceRows;r++){
            %>
                <tr>
                    <td><input id="<%="check"+(r+1)%>" name="check" type="checkbox"></td>
                    <!--<td>1</td>-->
                    <td>
                        <input id="<%="pmid_list"+(r+1)%>" name="pmid_list" type="text"
                    value="<%=dm.out("pmid_list", pmids.get(r), r)%>">
                    </td>
                    <td>
                        <input id="<%="getPMID"+(r+1)%>" name="getPMID" type="button" value="Get Reference RGD ID"
                               onclick="fnGetRefRGDId(this.id);"/>
                    </td>
                    <td>
                        <input id="<%="RGDID"+(r+1)%>" name="RGDID" type="text"
                               value="<%=dm.out("RGDID",referencesList.get(r).getRgdId(),r)%>">
                    </td>

                </tr>
            <%
                    }

                System.out.println("done with references : " + referenceRows);
            %>



        </table>
        </td>
    </tr>
    <tr>
        <td><br /><b>Altered Pathways</b></td>
        <td colspan="2">
            <br />
            <input type="button" value="Add Row" onclick="addAltRow('AltPath')">
            <input type="button" value="Delete Row" onclick="delRow('AltPath')">
        </td>
    </tr>
    <tr>
        <td>Enter the Accession ID of the Altered Pathway: </td>
        <td>
        <table id="AltPath">
            <tr>
                <td align="center"><b>Check</b></td>
                <td align="center"><b>Altered Pathway Accession ID</b></td>
            </tr>

            <%
                            for(int a=0;a<altpathRows;a++){
                %>
                                <tr>
                                    <td><input id="<%="check"+(a+1)%>" name="check" type="checkbox"/></td>
                                    <td>
                                        <input id="<%="AltPathAccID"+(a+1)%>" name="AltPathAccID" type="text" value="<%=dm.out("AltPathAccID",altStringList.get(a),a)%>">
                                    </td>
                                </tr>
                <%
                            }
                        //System.out.println("done with altered pathways");
                %>
        </table>
        </td>
    </tr>
    <tr>
        <td><br /><b>Associated Pathway Objects</b></td>
        <td>
            <br />
            <input type="button" value="Add More Objects" onclick="addObjectRow('pathwayObject')">
            <input type="button" value="Delete Objects" onclick="delRow('pathwayObject')">
        </td>
    </tr>
    <tr>
        <td>Please enter the following details to associate wih Pathway</td>
        <td>
            <table id="pathwayObject">
            <tr>
                <td align="center"><b>Check</b></td>
                <td align="center"><b>Select Object Entity</b></td>
                <td align="center"><b>Associated Object Name</b></td>
                <td align="center"><b>Associated Description</b></td>
                <td align="center"><b>DBXRef AccessionID</b></td>
                <td align="center"><b>DBXRef Key</b></td>
                <td align="center"><b>DBXRef URL for Object</b></td>

            </tr>
            <%
                //}else if(newPW.getObjectList().size()>0){
                    //System.out.println("adding pathway objects list with size: " + assocPathObjRows);
                    
                    for(int o=0; o<assocPathObjRows; o++){
                        //System.out.println("adding object rows:" + o);
                        //System.out.println("hello:" + dm.out("selectObject",newPObjectList.get(o).getTypeId(), o));
            %>
            <tr>
                <td><input id="<%="checkObj"+(o+1)%>" name="checkObj" type="checkbox"></td>
                <td>
                    <select id="<%="selectObject"+(o+1)%>" name="selectObject">
                        <option value="0" <c:if test='<%=dm.out("selectObject",newPObjectList.get(o).getTypeId(), o).equals("0")%>' >selected="selected"</c:if>>Select Your Object Entity</option>
                        <option value="3" <c:if test='<%=dm.out("selectObject",newPObjectList.get(o).getTypeId(), o).equals("3")%>'>selected="selected"</c:if>>Protein</option>
                        <option value="1" <c:if test='<%=dm.out("selectObject",newPObjectList.get(o).getTypeId(), o).equals("1")%>'>selected="selected"</c:if>>Small Molecule</option>
                        <option value="4" <c:if test='<%=dm.out("selectObject",newPObjectList.get(o).getTypeId(), o).equals("4")%>'>selected="selected"</c:if>>Treatment</option>
                        <option value="10" <c:if test='<%=dm.out("selectObject",newPObjectList.get(o).getTypeId(), o).equals("10")%>'>selected="selected"</c:if>>Cell Process</option>
                        <option value="5" <c:if test='<%=dm.out("selectObject",newPObjectList.get(o).getTypeId(), o).equals("5")%>'>selected="selected"</c:if>>Disease</option>
                        <option value="6" <c:if test='<%=dm.out("selectObject",newPObjectList.get(o).getTypeId(), o).equals("6")%>'>selected="selected"</c:if>>Cell Object</option>
                        <option value="7" <c:if test='<%=dm.out("selectObject",newPObjectList.get(o).getTypeId(), o).equals("7")%>'>selected="selected"</c:if>>Pathway</option>
                        <option value="2" <c:if test='<%=dm.out("selectObject",newPObjectList.get(o).getTypeId(), o).equals("2")%>'>selected="selected"</c:if>>Complex</option>
                        <option value="8" <c:if test='<%=dm.out("selectObject",newPObjectList.get(o).getTypeId(), o).equals("8")%>'>selected="selected"</c:if>>Functional Class</option>
                        <option value="9" <c:if test='<%=dm.out("selectObject",newPObjectList.get(o).getTypeId(), o).equals("9")%>'>selected="selected"</c:if>>Gene Group</option>
                        <option value="11" <c:if test='<%=dm.out("selectObject",newPObjectList.get(o).getTypeId(), o).equals("11")%>'>selected="selected"</c:if>>Gene</option>
                    </select>
                </td>
                <td>
                    <input type="text" id="<%="obj_xdb_name"+(o+1)%>" name="obj_xdb_name" size="20"
                           value="<%=dm.out("obj_xdb_name", newPObjectList.get(o).getObjName(), o)%>">
                </td>
                <td>
                    <input type="text" id="<%="obj_xdb_desc"+(o+1)%>" name="obj_xdb_desc" size="20"
                           value="<%=dm.out("obj_xdb_desc", newPObjectList.get(o).getObjDesc(), o)%>">
                </td>
                <td>
                    <input type="text" id="<%="obj_xdb_accession"+(o+1)%>" name="obj_xdb_accession" size="20"
                           value="<%=dm.out("obj_xdb_accession", newPObjectList.get(o).getAccId(), o)%>">
                </td>
                <td>
                <input type="text" id="<%="obj_xdb_key"+(o+1)%>" name="obj_xdb_key" size="20"
                            value="<%=dm.out("obj_xdb_key", newPObjectList.get(o).getXdb_key(), o)%>">
                </td>
                <td>
                    <input type="text" id="<%="obj_xdb_url"+(o+1)%>" name="obj_xdb_url" size="20"
                           value="<%=dm.out("obj_xdb_url", newPObjectList.get(o).getUrl(), o)%>">
                </td>
            </tr>
            <%
                    //System.out.println("done with select objects........"+ o);
                    }
                //}
            %>

            </table>
        </td>
    </tr>
    <tr>
        <td><br /><b>Pathway File Upload ** </b></td>
        <td><br />Choose Pathway File for upload</td>
        
    </tr>
    <tr>
        <td colspan="5">
            <APPLET
                    CODE="wjhk.jupload2.JUploadApplet"
                    CODEBASE="/rgdweb/pathway/"
                    NAME="JUpload"
                    ARCHIVE="wjhk.jupload.jar"
                    WIDTH="740"
                    HEIGHT="500"
                    MAYSCRIPT="true"
                    ALT="The java plugin must be installed.">
            <param name="postURL" value="/rgdweb/pathway/parseRequest2_mod.jsp" />
            <param name="formdata" value="uploadPathwayForm" />
                
            <param name="error" value="true" />
            <!-- Optionnal, see code comments -->
            <param name="showLogWindow" value="true" />
            <param name="debugLevel" value="99" />
            <!--<param name="ftpCreateDirectoryStructure" value="true" />-->

            Java 1.5 or higher plugin required.
        </APPLET>
        </td>
        
    </tr>
    <tr></tr>
    <tr>
        <td>
            <br />
            <h4>Compile Results..<input type="submit" size="100" <c:choose><c:when test='<%=(newPW.getId()!=null) || (req.getParameter("processType").equals("update"))%>'>value="Update Pathway Record"</c:when>
               <c:otherwise>value="Create New Pathway Record"</c:otherwise></c:choose>></h4>
        </td>
    </tr>
    </table>
</form>

<form name="uploadPathwayForm" id="uploadPathwayForm" action="">
      <input name="pathwayLoc" id ="pathwayLoc" type="hidden" value="<%=pwFilePath%>">
      <input name="cacheImageLoc" id ="cacheImageLoc" type="hidden" value="<%=cacheFilePath%>">
    <%--<input name="pathwayLoc" id ="pathwayLoc" type="hidden" value="<%=ourTempDirectory%>--%>
</form>


<%@ include file="/common/footerarea.jsp"%>