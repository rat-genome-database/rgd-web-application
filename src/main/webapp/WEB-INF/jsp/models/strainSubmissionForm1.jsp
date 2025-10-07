
<%@ page import="edu.mcw.rgd.dao.impl.StrainDAO" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="java.io.FileInputStream" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.datamodel.Strain" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.ArrayList" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%  String pageTitle =  "Strain Submission ";
    String pageDescription ="Altered Strains";
    String headContent = "";
    HttpRequestFacade req=null;
    FormUtility fu = new FormUtility();
    ArrayList errors= new ArrayList<>();
    DisplayMapper dm = new DisplayMapper(req,errors);
    Strain strain= new Strain();%>

<%@ include file="/common/headerarea.jsp"%>
<link rel="stylesheet" href="/rgdweb/css/bootstrap.min.css">
<script src="/rgdweb/js/bootstrap.min.js"></script>
<link rel="stylesheet" type="text/css" href="/rgdweb/common/jquery-ui/jquery-ui.css">
<script src="/rgdweb/common/jquery-ui/jquery-ui.js"></script>
<link href="/rgdweb/css/geneticModels.css" rel="stylesheet" type="text/css"/>
<script src="/rgdweb/js/submission.js"></script>

<!--script src='https://www.google.com/recaptcha/api.js'></script-->
<div style="background:#eee;text-align: center" >
    <h3>Strain Submission</h3>
</div>

<div id="recapthaDiv" style="color:red">${model.error}</div>
<div class="container" id="submissionWrapper" style="border:1px solid lightgrey;border-radius:4px;padding:10px">
    <div style="background:#eee;margin-top:20px">
        <legend>Strain Information</legend>
    </div>
    <form id="myForm"  method="post"  onsubmit="return verify(this)">
        <input type="hidden" id="action" name="action" />
        <div class="form-group">
            <label for="symbol">Strain Symbol</label>&nbsp;&nbsp;<span style="color:red">*</span>
            <input type="text" class="form-control" id="symbol" name="symbol" aria-describedby="emailHelp" placeholder="Enter strain symbol" required>
            <small id="symbolHelp" class="form-text text-muted">
                Please enter a symbol for the strain being submitted, for example: BN/Crl, or SHR.BN-(D13Arb5-Ren)/Ipcv. For more information, please refer to the <a href="https://www.informatics.jax.org/mgihome/nomen/strains.shtml">rules for strain nomenclature</a> and the <a href="https://www.informatics.jax.org/mgihome/nomen/gene.shtml#endim">rules for naming  endonuclease-mediated mutants</a> for strains produced using CRISPR/Cas, TALEN or ZFN mutagenesis. For help naming your strain please contact <a href="mailto:RGD.Data@mcw.edu">RGD.Data@mcw.edu</a>.

            </small>
        </div>
        <div class="form-group" style="width:100%">
        <div class="form-group" style="width:30%;float:left">
            <label for="strainTypeName">Type</label>
            <select class="form-control" id="strainTypeName" name="strainTypeName">
            <% List strainTypes= new ArrayList<>();
                try {
                 strainTypes= new StrainDAO().getStrainTypes();
            } catch (Exception e) {
                e.printStackTrace();
            }
            for(Object type:strainTypes){
            if(type.toString().equals("mutant")){%>
               <option selected=<%=type.toString()%>><%=type.toString()%></option>
           <% }else{%>
                <option><%=type.toString()%></option>
                <%}}%>
            </select>
        </div>
            <div class="form-group" style="width:30%;float:right">
                <label for="method">Method</label>
                <select class="form-control" id="method" name="method">
                    <%
                    List methods= new ArrayList<>();
                        try {
                            methods= new StrainDAO().getModificationMethods();
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        for(Object m:methods){
                            if(m.toString().equalsIgnoreCase("crispr/cas9")){
                     %><option selected><%=m.toString()%></option>
                    <%}else{%>
                    <option><%=m.toString()%></option>
                  <%  }}%>
                  
                </select>
            </div>

        <div class="form-group" style="width:30%;margin-left:35%">
            <label for="status">Genetic Status</label>
            <select class="form-control" id="status" name="status">
                <option  value="Heterozygous" >Heterozygous</option><option  value="Homozygous" selected >Homozygous</option><option  value="Hemizygous" >Hemizygous</option><option  value="Wild Type" >Wild Type</option>
            </select>
        </div>

        </div>
        <div class="form-group">
            <label for="methodOther">Other Method</label>
            <input type="text" class="form-control" id="methodOther" name="methodOther" aria-describedby="methodOtherHelp" placeholder="Enter modification method">
            <small id="methodOtherHelp" class="form-text text-muted">If you selected "other" as the method above, please specify the method you used here. </small>
        </div>
        <div class="form-group">
            <label for="backgroundstrain">Background Strain</label>
            <input type="text" class="form-control" id="backgroundstrain" name="backgroundstrain" aria-describedby="backgroundstrainHelp" placeholder="Enter background strain symbol">
            <small id="backgroundstrainHelp" class="form-text text-muted"></small>
        </div>

        <div class="form-group">
            <label for="origin">Provide a description of strain's origin</label>
            <textarea class="form-control" id="origin" name="origin" rows="3"></textarea>
            <small id="originHelp" class="form-text text-muted">Example:"The CRISPR/Cas9 system was used to introduce a 5-bp deletion in exon 3 of the Spp1 gene of SHRSP/A3NCrl rat embryos.</small>
        </div>
        <div class="form-group">
            <label for="reference">Reference/Pubmed ID</label>
            <input type="text" class="form-control" id="reference" name="reference" aria-describedby="referenceHelp" placeholder="Enter reference/pubmed id">
            <small id="referenceHelp" class="form-text text-muted">If this strain has been mentioned in any published paper please give that citation here. ( author, journal, vol, page number, or PMID).</small>
        </div>
        <div class="form-group">
            <label for="researchUse">Research Use</label>
            <input type="text" class="form-control" id="researchUse" name="researchUse" aria-describedby="researchUseHelp" placeholder="Eg: Cancer, Cardiovascular, etc.">
            <small id="researchUseHelp" class="form-text text-muted">Optional.  If this strain has been or could be used for research in a particular area, please indicate this.  For example, this could be a disease area such as cardiovascular or cancer, or a phenotype category such as reproduction.</small>
        </div>
        <div class="form-group">
            <label for="ilarcode">ILAR Code</label>
            <input type="text" class="form-control" id="ilarcode" name="ilarcode" aria-describedby="ilarcodeHelp" placeholder="Enter ILAR code">
            <small id="ilarcodeHelp" class="form-text text-muted">This is the laboratory code assigned by <a href="http://dels.nas.edu/ilar/codes.asp?id=codes">The Institute of Laboratory and Animal Research</a>
                to each lab or group. Registering a group at ILAR identifies the group as a place where this strain was originated and maintained.</small>
        </div>
        <input type="hidden" name="fileLocation" id="fileLocation"/>
        <div class="form-group" id="uploadContainer">
            <label for="imageupload">Upload image file if available</label>
            <input type="file" class="form-control-file" id="imageupload" name="file" aria-describedby="fileHelp">
            <small id="fileHelp" class="form-text text-muted">Upload image of size less than 5MB. Acceptable file formats: .PNG, .JPEG, .GIF</small>
        </div>
        <div id="div1"></div>
        <div>
            <div class="form-group" style="background:#eee">
                <legend>Gene/Allele Information</legend>
            </div>
            <div style="width:100%">
            <div class="form-group" style="float:left;width:50%">
                <label for="symbol">Gene Symbol</label>
                <input type="text" class="form-control" id="rs_term" name="rs_term" aria-describedby="geneSymbolHelp" placeholder="Enter gene symbol">
                <small id="geneSymbolHelp" class="form-text text-muted"></small>
            </div>
            <div class="form-group" style="float:right;width:49%">
                <label for="geneRgdid">Gene RGD ID (if known)</label>
                <input type="number" class="form-control" id="geneRgdid" name= "geneRgdid" aria-describedby="geneRgdidHelp" placeholder="Enter gene RGD ID">
                <small id="geneRgdidHelp" class="form-text text-muted"></small>
            </div>
            </div>
            <div class="form-group" style="width:100%">
            <div class="form-group" style="float:left;width:50%">
                <label for="allele">Allele Symbol</label>
                <input type="text" class="form-control" id="allele" name="allele" aria-describedby="alleleHelp" placeholder="Enter allele symbol">
                <small id="alleleHelp" class="form-text text-muted"></small>
            </div>
            <div class="form-group" style="float:right;width:49%">
                <label for="alleleRgdid">Allele RGD ID (if known)</label>
                <input type="number" class="form-control" id="alleleRgdid" name="alleleRgdid" aria-describedby="alleleRgdidHelp" placeholder="Enter allele RGD ID ">
                <small id="alleleRgdidHelp" class="form-text text-muted"></small>
            </div>
            </div>
        </div>

        <div class="form-group">
            <legend style="background:#eee">Availability</legend>
            <div class="form-check">
                <label class="form-check-label">Current Status: &nbsp;&nbsp;
                    <input type="checkbox" class="form-check-input" name="availType" id="availType1" value="Live Animals">
                    <span style="font-weight:normal">Live Animals</span>&nbsp;&nbsp;
                    <input type="checkbox" class="form-check-input" name="availType" id="availType2" value="Cryopreserved Embryo">
                    <span style="font-weight:normal">Cryopreserved Embryo</span>&nbsp;&nbsp;
                    <input type="checkbox" class="form-check-input" name="availType" id="availType3" value="Cryopreserved Sperm">
                    <span style="font-weight:normal">Cryopreserved Sperm</span>
                </label>

            </div>

        </div>
        <div class="form-group">
            <label for="source">Where could this strain be obtained?</label>&nbsp;&nbsp;<span style="color:red">*</span>
            <textarea class="form-control" id="source" name="source" rows="3" required></textarea>
        </div>
        <div class="form-group">
            <label for="availablecontactemail">Availability Contact Email</label>
            <input type="text" class="form-control" id="availablecontactemail" name="availablecontactemail" aria-describedby="availablecontactHelp" placeholder="">
            <small id="availablecontactHelp" class="form-text text-muted"></small>
        </div>
        <div class="form-group">
            <label for="availablecontacturl">Availability Contact URL</label>
            <input type="text" class="form-control" id="availablecontacturl" name="availablecontacturl" aria-describedby="availablecontacturlHelp" placeholder="">
            <small id="availablecontacturlHelp" class="form-text text-muted"></small>
        </div>
        <div class="form-group">
            <legend style="background:#eee">Submitter Contact Details</legend>
        </div>
        <div class="form-group" style="width:100%">
        <div class="form-group" style="width:50%;float:left">
            <label for="lastname">Last Name/Surname</label>&nbsp;&nbsp;<span style="color:red">*</span>
            <input type="text" class="form-control" id="lastname" name="lastname" aria-describedby="lastnameHelp" placeholder="Enter submitter last name/surname" required>
            <small id="lastnameHelp" class="form-text text-muted"></small>
        </div>
        <div class="form-group" style="width:49%;float:right">
            <label for="firstname">First Name</label>&nbsp;&nbsp;<span style="color:red">*</span>
            <input type="text" class="form-control" id="firstname" name="firstname" aria-describedby="firstnameHelp" placeholder="Enter submitter first name/given name" required>
            <small id="firstnameHelp" class="form-text text-muted"></small>
        </div>
        </div>
        <div class="form-group">
            <label for="email">Email Address</label>&nbsp;&nbsp;<span style="color:red">*</span>
            <input type="text" class="form-control" id="email"  name="email" aria-describedby="submitteremailHelp" placeholder="Enter submitter email address" required>
            <small id="submitteremailHelp" class="form-text text-muted"></small>
        </div>
        <div class="form-group">
            <label for="pi">Laboratory PI</label>
            <input type="text" class="form-control" id="pi" name="pi" aria-describedby="piHelp" placeholder="Enter PI First Name & Last Name">
            <small id="piHelp" class="form-text text-muted"></small>
        </div>
        <div class="form-group">
            <label for="piemail">PI Email Address</label>
            <input type="text" class="form-control" id="piemail" name="piemail" aria-describedby="piemailHelp" placeholder="Enter PI email address">
            <small id="piemailHelp" class="form-text text-muted"></small>
        </div>
        <div class="form-group">
            <label for="org">Institution/Orgainzation</label>
            <input type="text" class="form-control" id="org" name="org" aria-describedby="orgHelp" placeholder="Enter Institution or Organization name">
            <small id="orgHelp" class="form-text text-muted"></small>
        </div>
        <div class="form-group">
            <label for="notes">Additional Information</label>
            <textarea class="form-control" id="notes" name="notes"  rows="3"></textarea>
            <small id="notesHelp" class="form-text text-muted">Additional Information about the STRAIN or ALLELE or GENE or any information you want to provide.</small>
        </div>
        <fieldset class="form-group">
            <legend style="font-size:small">Please let us know if you want this strain to be displayed on the RGD website. If not, check Non Public (we can hold a strain until instructed by you to release it).</legend>
            <div class="form-check form-check-inline">

                    <input type="radio" class="form-check-input" name="public" id="optionsRadios1" value="Public" >
                    <label class="form-check-label" for="optionsRadios1"> Public</label>
            </div>
            <div class="form-check form-check-inline" >
                    <input type="radio" class="form-check-input" name="public" id="optionsRadios2" value="nonPublic" checked>
                <label class="form-check-label" for="optionsRadios2">Non Public </label>
            </div>

        </fieldset>
        <p id="test" style="color:red"></p>

                <div style="margin-top:5px;margin-bottom:10px" class="g-recaptcha" data-sitekey="6LccGxITAAAAAKxaUj88wOc-ueTuVU2njjOHmBqW"></div>


        <button type="submit" id="formSubmit" class="btn btn-primary" style="margin-bottom:20px">Submit</button>
        <div class="form-group">
            <small id="note" class="form-text text-muted">Note: <span style="color:red">*</span>&nbsp; fields are mandatory.</small>
        </div>
    </form>

</div>
<script src='https://www.google.com/recaptcha/api.js'></script>


<script>
    jQuery(function () {
             jQuery("#rs_term").autocomplete({
                    delay:500,
                    source: function(request, response) {
                        $.ajax({
                            url: "getGenes.html",
                            type: "POST",
                            data: {term: request.term},
                                    max: 100,
                            dataType: "json",
                            success: function(data) {
                                response(data);
                            }
                        });
                    }

                });

    })


</script>

<script language="javascript">
    function verify(field){
        var message;
        var msg1;
        var msg2;
        var need_field="";
        var error_field1="";
        var error_field2="";
        var display_name;

        for(var i=0; i<field.length; i++){

            var e=field.elements[i];
            if(e.name=="lastname"){
                display_name="Last name of the submitter";
            }
            if(e.name=="firstname"){
                display_name="First name of the submitter";
            }
            if(e.name=="email"){
                display_name="E-mail address of the submitter";
            }
            if(e.name=="symbol"){
                display_name="Strain Symbol";
            }
            if(e.name=="source"){
                display_name="Source/group where available";
            }

            if((e.name=="lastname")||(e.name=="firstname")||(e.name=="email")||(e.name=="symbol")||(e.name=="source")){
                if((e.value==null)||(e.value=="")||isblank(e.value)){
                    need_field += "\n          " + display_name;
                }
            }

            if(e.name=="email"){
                error_field1=checkFormat1(e.value);
            }


        }

        if(need_field){
            message="The form can not be submitted because the following fields must be filled in:\n\n"	+ need_field+"\n";
            alert(message);
            return false;
        }
        if(error_field1){
            msg1="-" + error_field1;
            alert(msg1);
            return false;
        }
        if(error_field2){
            msg2="-" + error_field2;
            alert(msg2);
            return false;
        }
    }

    function isblank(s){
        for(var i=0; i<s.length; i++){
            var c=s.charAt(i);
            if((c !=' ')&&(c !='\n')&&(c !='\t')) return false;
        }

        return true;
    }

    function checkFormat1(value){
        if((value!=null)||(value!="")||!isblank(value)){
            var error="";
            var invalidChars = " /:,;";
            for (i=0; i<invalidChars.length;i++){
                var badChar = invalidChars.charAt(i);
                if (value.indexOf(badChar,0) > -1){
                    error="You have not entered a valid email address. Please do so and re-submit";
                }
            }

            atPos = value.indexOf("@",1);
            if (atPos== -1){
                error="You have not entered a valid email(miss @). Please do so and re-submit.";
            }
            if (atPos+1 == value.length){
                error="You have not entered a domain name. Please do so and re-submit.";
            }

            return error;
        }
    }

    function checkFormat2(value){
        //alert("value="+value);
        if((value!=null)||(value!="")||!isblank(value)){
            var error="";
            var invalidChars = " /:,;";
            for (i=0; i<invalidChars.length;i++){
                var badChar = invalidChars.charAt(i);
                if (value.indexOf(badChar,0) > -1){
                    error="You have not entered a valid email address. Please do so and re-submit";
                }
            }

            atPos = value.indexOf("@",1);
            if (atPos== -1){
                error="You have not entered a valid email(miss @). Please do so and re-submit.";
            }
            if (atPos+1 == value.length){
                error="You have not entered a domain name. Please do so and re-submit.";
            }

            return error;
        }
    }
    function help(anchor) {

        top.strainhelp=open("strainSubmissionFormHelp.html#"+anchor,"helpwindow","scrollbars=yes,toolbar=no,directories=no,menubar=no,status=no,resizable=yes,width=400, height=200");

        top.strainhelp.focus();
    }




</script>



<%@ include file="/common/footerarea.jsp"%>




