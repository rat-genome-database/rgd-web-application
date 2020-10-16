<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="m" uri="/WEB-INF/tld/geneticModel.tld" %>

<%  String pageTitle =  "All Models";
    String pageDescription ="All Genetic Models";
    String headContent = "";%>
<%@ include file="/common/headerarea.jsp"%>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">
<link href="/rgdweb/css/geneticModels.css" rel="stylesheet" type="text/css"/>

<script src="/rgdweb/common/tablesorter-2.18.4/js/tablesorter.js"> </script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.widgets.js"></script>


<script src="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.js"></script>
<link href="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.css"/>

<link href="/rgdweb/common/tablesorter-2.18.4/css/filter.formatter.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.jui.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>

<link rel="stylesheet" href="/rgdweb/common/bootstrap/css/bootstrap.css">
<script src="/rgdweb/common/bootstrap/js/bootstrap.js"></script>
<script src="/rgdweb/js/knockout.js"></script>
<script> function myModal(strainRgdId) {
    var rgdId= strainRgdId;
    var form_data= new FormData;
    var content=$('#refDiv');
    // form_data.append("rgdId", rgdId);
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
    #refModal {
        margin-top:20%

    }
    .modal-footer {
        background-color: #f9f9f9;
    }

    #modelsViewContent{
    width:80%;margin-left:10%;
    }
    #modelsView{
        width:80%;margin-left:10%;
    }
</style>
<%@include file="modelsView.jsp"%>
<div>&nbsp;</div>
&nbsp;
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
<%@ include file="/common/footerarea.jsp"%>