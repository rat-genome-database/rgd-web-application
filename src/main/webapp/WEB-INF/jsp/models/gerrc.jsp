<%--<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>--%>
<%--<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>--%>
<%--<%@ taglib prefix="m" uri="/WEB-INF/tld/geneticModel.tld" %>--%>

<%  String pageTitle =  " GERRC";
    String pageDescription ="Genetic Models";
    String headContent = "";%>
<%@ include file="/common/headerarea.jsp"%>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">
<link href="/rgdweb/css/geneticModels.css" rel="stylesheet" type="text/css"/>

<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.js"> </script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.widgets.js"></script>


<script src="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.js"></script>
<link href="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.css"/>

<link href="/rgdweb/common/tablesorter-2.18.4/css/filter.formatter.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.jui.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>


<link rel="stylesheet" href="/rgdweb/common/bootstrap/css/bootstrap.css">
<script src="/rgdweb/common/bootstrap/js/bootstrap.js"></script>
<script src="/rgdweb/js/knockout.js"></script>
<script>

     function myModal(strainRgdId) {
         var rgdId= strainRgdId;
         var content=$('#refDiv');
         $.ajax({

             url: "references.html?rgdId="+rgdId,
             cache: false,
             contentType: false,
             processData: false,
             //data:form_data,
             type:'post',
             success: function(data){
                 content.html(data);
             }
         });
         $( "#refModal" ).modal();
     }



</script>

<style>
    #refModal .modal-header, h4, .close {
        background-color: #24609c;
        color:white !important;
        text-align: center;
        font-size: 20px;
    }
    .modal-footer {
        background-color: #f9f9f9;
    }


    #refModal {
        margin-top:20%

    }

    #modelsViewContent{
        width:80%;margin-left:16%;
    }
    #modelsView{
        width:80%;margin-left:16%;
        margin-right:15%
    }
</style>
<div id="container"style="width:100%">
    <div>
        <div id="description" style="float:right;width:79%;margin-right:5%">
            <table>
                <tbody>
                <tr>
                    <td valign="top">
                        <h2>Genetic Models at MCW</h2>
                        <p style="font-size:9pt;color:grey">If interested in obtaining any of these strains, please contact  <a href="mailto:mcwcustomrats@mcw.edu" style="color:steelblue">mcwcustomrats@mcw.edu
                        </a>.&nbsp;&nbsp;&nbsp;</p>
                       </td>
                    <td>&nbsp;&nbsp;</td>
                   </tr>
                </tbody>
            </table>
        </div>
        <div id="sidebar" style="float:left;width:15%;height:800px">
            <div style="margin-left: 5px;margin-right:5px; margin-top:5px;background:white;">
                <table style="width: 90%;" cellpadding="5">
                    <tbody>
                    <tr>
                        <td><a href="/wg/gerrc"><img src="/common/images/gerrc/RGERC-logo-sm.jpg" border="0/&lt;/td;" style="border-radius:30px;height:100%;width:100%" /></a></td>
                    </tr>
                    <tr>
                        <td><span style="font-size: 8pt; color:#24609c;font-weight:normal">The
                                    National Heart, Lung, and Blood Institute (NHLBI) has awarded Melinda Dwinell, Ph.D., Aron Geurts, Ph.D.
                                    and the Medical College of Wisconsin an R24HL114474 Resource grant to
                                     make ~200 genetically modified rat strains over the next five years.
                                    Click <a href="/wg/gerrc" style="color:blue">here</a> for more information.</span></td>
                    </tr>
                    </tbody>
                </table>
            </div>
            <p  style="color:#1f65ac;font-weight:bold;font-size:10pt;margin-left:15px;text-decoration:underline">Resources/Links:</p>
            <ul>
                <li><a href="strainSubmissionForm.html?new=true">Strain Submission</a></li>
                <li><a href="download.html">Excel Download</a></li>
                <li>Contact Us</li>
            </ul>
            <p  style="color:#1f65ac;font-weight:bold;font-size:10pt;margin-left:15px;text-decoration:underline">Key Personnel:</p>
            <ul>
                <li><a href="mailto:mrdwinel@mcw.edu">Melinda Dwinell, Ph.D.</a></li>
                <li><a href="mailto:ageurts@mcw.edu">Aron Geurts, Ph.D.</a></li>
                <li><a href="mailto:dmattson@mcw.edu">David Mattson, Ph.D.</a></li>
            </ul>
        </div>
    </div>

    <%@include file="modelsView.jsp"%>
    <div class="content" ><div id="articlec197e9b4a369e2e9c4a70440b25b0995" class="article default">

        <a name="idwZfptKNp4unEpwRAslsJlQ" id="idwZfptKNp4unEpwRAslsJlQ"></a>
        <h3>Funding</h3>
        <div class="articleContent">
            <div class="description">
                <p>This project was funded by the National Heart, Lung and Blood Institute of the NIH (5RC2HL101681-02).&nbsp;&nbsp;</p>
                <p>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <img border="0" src="/common/images/ARRA_101x101.gif" width="101" height="101" /></p>

            </div>


        </div>
        <div class="wg-clear"></div>

    </div>
    </div>
    <!-- Modal -->
    <div class="modal fade" id="refModal" role="dialog">
        <div class="modal-dialog">

            <!-- Modal content-->
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">References</h4>
                </div>
                <div class="modal-body">
                    <div id="refDiv">Some text in the modal.</div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                </div>
            </div>

        </div>
    </div>

</div>

<%@ include file="/common/footerarea.jsp"%>