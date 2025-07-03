<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.StrainDAO" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.datamodel.Strain" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%  String pageTitle =  "GERRC - Strain Submission Form";
    String pageDescription ="Altered Strains";
    String headContent = "";
    HttpRequestFacade req=null;
    FormUtility fu = new FormUtility();
    ArrayList errors= new ArrayList<>();
    DisplayMapper dm = new DisplayMapper(req,errors);
Strain strain= new Strain();%>
<%@ include file="headerarea.jsp"%>
<%--<link rel="stylesheet" href="//code.jquery.com/ui/1.12.0/themes/base/jquery-ui.css">--%>
<link rel="stylesheet" href="/rgdweb/common/jquery-ui/jquery-ui.css"/>
<script src="/rgdweb/js/jquery/jquery-3.7.1.min.js"></script>
<script src="/rgdweb/common/jquery-ui/jquery-ui.js"></script>
<script>

    $(function () {
        $('#verifyGene').on('click', function () {
            var g= $('#rs_term').val();
            alert(g);
            })
        $('#upload').click(function (e) {
          //  $("#action").val("upload");
          //  alert("upload");
            e.preventDefault();
            var file_data = $("#imageupload").prop("files")[0];   // Getting the properties of file from file field
            var form_data = new FormData();                  // Creating object of FormData class
            form_data.append("file", file_data)              // Appending parameter named file with properties of file_field to form_data
            form_data.append("user_id", 123)                 // Adding extra parameters to form_data
            $.ajax({
                url: "upload.html",
                dataType: 'script',
                cache: false,
                contentType: false,
                processData: false,
                data: form_data,                         // Setting the data attribute of ajax with file_data
                type: 'post',
                success:function () {
                    $("#div1").html("<span style='color:green'>Image Uploaded Successfully</span> ");
                }
            })

        })
        $('#formSubmit').click(function () {
            $("#action").val("submit");
         //   alert("submit")

        })
    })
</script>
<div id="mainHeader">
<h2>Rat Strain Submission</h2>
    <hr>
</div>

<table>

    <tr>
        <td>
            <form action="strainSubmissionForm.html" method="post"  onsubmit="return verify(this)" >
                <input type="hidden" name="imageUrl" value="${model.imageUrl}"/>
                <input type="hidden" id="action" name="action" />
                <h3>Strain Information: </h3>
                <table style="margin-left:10%">
                    <tr>
                        <td class="label"><a href="javascript:help('strain_symbol')">Strain Symbol:</a></td>
                        <td><input type="text"  name="symbol"  size="45" value=""  />&nbsp;<font color=red>*</font></td>
                    </tr>

                    <tr>
                        <td class="label"><a href="javascript:help('strain_type')">Type:</a></td>
                        <td><%=fu.buildSelectList("strainTypeName",new StrainDAO().getStrainTypes(), dm.out("strainTypeName","mutant"))%></td>
                    </tr>

                    <tr>
                        <td class="label"><a href="javascript:help('genetic_status')">Genetic Status:</a></td>
                        <td><select name="status"><option  value="Heterozygous" >Heterozygous</option><option  value="Homozygous" selected >Homozygous</option><option  value="Hemizygous" >Hemizygous</option><option  value="Wild Type" >Wild Type</option></select></td>
                    </tr>

                    <tr>
                        <td class="label"><a href="javascript:help('strain_origin')">Origin:</a></td>
                        <td><textarea rows="4" name="origin" cols="45" ></textarea></td>
                    </tr>

                    <tr>
                        <td class="label"><a href="javascript:help('reference')">Pubmed ID (If published):</a></td>
                        <td><input type="text" name="reference" size="45" value="" /></td>
                    </tr>

                    <tr>
                        <td class="label"><a href="javascript:help('research_use')">Research Use:</a><br><span style="font-weight:normal">Eg: Cardiovascular, Cancer, etc.<span></span></td>
                        <td><input type="text" name="researchUse" size="45" value="" /></td>
                    </tr>
                    <tr>
                        <td class="label"><a href="javascript:help('strain_code')">ILAR Code:</a></td>
                        <td><input type="text" name="ilarcode" size="45" value="" /></td>
                    </tr>

                            <tr>
                                <td class="label"><a href="javascript:help('notes')">Additional Information:</a></td>
                                <td><textarea rows="6" name="notes" cols="45" ></textarea></td>
                            </tr>
                    <tr><td class="label">Upload image file if available.</td>
                    <td><input type="file" name="file" id="imageupload" size="45"/>&nbsp;&nbsp;<input type="submit" id="upload" name="upload" value="Upload"/><div id="div1"></div></td></tr>

                    <tr>
                        <td></td>
                    </tr>

                </table>
                <h3>Gene/Allele Information:</h3>
                <table style="margin-left:10%">
                   <tr> <td class="label"><a href="javascript:help('gene_symbol')">Gene Symbol</a>  </td><td><input  id="rs_term"  class="ui-widget gene" name="rs_term" size="45"/></td><!--td><button id="verifyGene">Verify</button></td--></tr>
                   <tr> <td class="label"><a href="javascript:help('gene_rgdid')">Gene RGD ID (if known) </a> </td><td><input type="text" name="geneRgdid" size="45" value="" /></td></tr>
                    <tr><td class="label"><a href="javascript:help('allele_symbol')">Allele Symbol</a></td>
                        <td><input type="text" name="allele" size="45" value="" /></td></tr>
                    <tr> <td class="label"><a href="javascript:help('allele_rgdid')">Allele RGD ID (if known) </a> </td><td><input type="text" name="alleleRgdid" size="45" value="" /></td></tr>
                </table>
                <h3>Strain Availabiltiy:</h3>
                <table style="margin-left:10%">
                   <tr> <td class="label"><a href="javascript:help('availability_type')">Current Status:</a>  </td>
                        <td><input type="checkbox" name="availType" value="Embryo">Cryopreserved Embryo
                            <input type="checkbox" name="availType" value="Live animals">Live animals
                            <input type="checkbox" name="availType" value="Sperm">Cryopreserved Sperm
                         </td></tr>
                    <tr>
                        <td class="label"><a href="javascript:help('source')">Where could this Strain be obtained?:</a></td>
                        <td><textarea cols="45" rows="5" name="source"></textarea></td>
                    </tr>
                    <tr> <td class="label"><a href="javascript:help('availability_contact_email')">Availability Contact Email: </a> </td><td><input type="text" name="availablecontactemail" size="45"> </td></tr>
                    <tr> <td class="label"><a href="javascript:help('availability_contact_url')">Availability Contact URL: </a> </td><td><input type="text" name="availablecontacturl" size="45"> </td></tr>

                </table>
                <h3>Submitter Contact Details:</h3>
                <table style="margin-left:10%">
                    <tr><td class="label"><a href="javascript:help('userLName')">Last Name/Surname:</a></td><td><input type="text" name="lastname" size="45"> <font color=red>*</font></td></tr>
                    <tr><td class="label"><a href="javascript:help('userFName')">First Name/Given Name:</a></td><td><input type="text" name="firstname" size="45"> <font color=red>*</font></td></tr>
                    <tr><td class="label"><a href="javascript:help('userMail')">Email Address:</a></td><td><input type="text" name="email" size="45"> <font color=red>*</font></td></tr>
                    <tr><td class="label"><a href="javascript:help('authorName')">Laboratory PI:</a></td><td><input type="text" name="pi" size="45"> <font color=red>*</font></td></tr>
                    <tr><td class="label"><a href="javascript:help('authorOrg')">Institution/Organization:</a></td><td><input type="text" name="org" size="45"> <font color=red>*</font></td></tr>

                </table>

                <table style="margin-left:10%">
                    <tr><td colspan=2><font color='black' size=3>Please let us know if you want this strain to be displayed on the RGD website. If not, check Non Public (we can hold a strain until instructed by you to release it).</font></td></tr>
                    <tr><td colspan=2>
                        <p>
                            <input type=radio name=public value="Public" >&nbsp;Public
                           <input type=radio name=public value="nonPublic" checked>&nbsp;Non Public
                        </p>
                    </td>
                    </tr>
                </table>
                <table>
                    <tr>
                    <td colspan="2" align="center">
                        <input type="submit" id="formSubmit" name="submit" value="Submit Strain"/>&nbsp;<INPUT type="reset"></td>

                    </tr>
                </table>
            </form>

        </td>

        <td>&nbsp;&nbsp;</td>
        <td valign="top"></td>

    </tr>
    <tr>
    <div class="bottom-bar" >
        <table align=center class="headerTable"> <tr><td align="left" style="color:white;">
            <a href="/contact/index.shtml">Contact Us</a>&nbsp;|&nbsp;
            <a href="/wg/about-us">About Us</a>&nbsp;|&nbsp;
            <a href="/wg/jobs">Jobs at RGD</a>

        </td></tr></table>
    </div>
    </tr>
</table>


<div id="copyright">
    <p>&copy; <a href="http://hmgc.mcw.edu/bp">Bioinformatics Program, HMGC</a> at the <a href="http://www.mcw.edu/">Medical
        College of Wisconsin</a></p>

    <p align="center">RGD is funded by grant HL64541 from the National Heart, Lung, and Blood Institute on behalf of the NIH.<br><img src="/common/images/nhlbilogo.gif" alt="NHLBI Logo" title="National Heart Lung and Blood Institute logo">
    </p>
    </div>

<script>
    jQuery(function () {
        jQuery(document).ready(function() {
            jQuery(function() {
                jQuery("#rs_term").autocomplete({
                    delay:500,
                    source: function(request, response) {
                        $.ajax({
                            url: "getGenes.html",
                            type: "POST",
                            data: {term: request.term},
                            dataType: "json",
                            success: function(data) {
                                response(data);
                            }
                        });
                    },

                })


            });
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

</html>





