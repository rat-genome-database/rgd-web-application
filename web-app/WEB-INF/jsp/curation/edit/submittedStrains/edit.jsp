<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="m" uri="/WEB-INF/tld/geneticModel.tld" %>
<%  String pageTitle =  "Strain Editor";
    String pageDescription ="Strain Editor";
    String headContent = "";%>

<%@include file="/common/headerarea.jsp"%>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">
<link href="/rgdweb/css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
<script src="/rgdweb/js/bootstrap.min.js"></script>
<script>
    $(function () {
        $('.edit-sub a').on('click' ,function (e) {
            var action=this.text;
            var URL;
            var msg;
          //alert("Success" + action);
            if(action=="Submitted Strains"){
                URL="submittedStrains.html";
                msg="submitted strains";
            }
            if(action=="Completed Strains"){
                URL="completedStrains.html";
                msg="completed strains";
            }
            if(action=="New Strain"){
             //   URL="/rgdweb/curation/edit/editStrain.html?act=new&speciesType=Rat&objectType=editStrian.html&objectStatus=ACTIVE";
                URL="createStrain.html";
                msg="create strain page"
            }
            if(action=="Curator Instructions"){
                //   URL="/rgdweb/curation/edit/editStrain.html?act=new&speciesType=Rat&objectType=editStrian.html&objectStatus=ACTIVE";
                URL="curatorInstructions.html";
                msg="curator instructions"
            }
            var $content=$("#div1");
            $content.html("<p>uploadig " + msg +" please wait..</p>");
            e.preventDefault();
          /*  var file_data = $("#imageupload").prop("files")[0];   // Getting the properties of file from file field
            var form_data = new FormData();                  // Creating object of FormData class
            form_data.append("file", file_data)              // Appending parameter named file with properties of file_field to form_data
            form_data.append("user_id", 123)      */           // Adding extra parameters to form_data
            $.ajax({
                url: URL,
                //  dataType: 'script',
                cache: false,
                contentType: false,
                processData: false,
               // data: form_data,                         // Setting the data attribute of ajax with file_data
                type: 'post',
                success:function (data) {
                    // $("#div1").html("<span style='color:green'>Image file uploaded successfully </span> ");
                    $content.html(data);
                    //  $("#upload").attr("disabled", true);
                }
            })
        })
    })
</script>
<div style="width:100%;background:#EEEEEE">
    <h3 style="text-align: center;color:#24609c">Edit Submitted Strains</h3>
</div>
<div class="container" style="border:1px solid #eee">

    <div style="width:15%;float:left">
        <ul class="nav nav-pills nav-stacked edit-sub">
        <li role="presentation" class="edit-sub active" ><a class="edit" href="#">Submitted Strains</a></li>
        <li role="presentation" class="edit-sub"><a class="edit" href="#">Completed Strains</a></li>
        <li role="presentation"class="edit-sub"><a class="edit" href="#">New Strain</a></li>
        <li role="presentation"class="edit-sub"><a class="edit" href="#">Curator Instructions</a></li>
    </ul>
    </div>
    <div id="div1" style="margin-left:16%;">
        <%@include file="submittedStrains.jsp"%>
    </div>


</div>
<%@include file="/common/footerarea.jsp"%>