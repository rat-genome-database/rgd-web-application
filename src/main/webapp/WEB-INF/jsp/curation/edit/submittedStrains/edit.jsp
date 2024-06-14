<%  String pageTitle =  "Strain Editor";
    String pageDescription ="Strain Editor";
    String headContent = "";
    String msg = (String) request.getAttribute("msg");
%>

<%@include file="/common/headerarea.jsp"%>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">
<link href="/rgdweb/css/bootstrap.min.css" rel="stylesheet" type="text/css"/>
<script src="/rgdweb/js/bootstrap.min.js"></script>
<script>
    $(function () {
        $('.edit-sub').on('click' ,function (e) {
            var action=this.innerHTML;
            var URL="";
            var msg="";
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
<div class="card-header" style="background:#EEEEEE">
    <h3 style="text-align: center;color:#24609c">Edit Submitted Strains</h3>
</div>

<div class="container-fluid"    style="padding-left:5%;padding-right: 5%">

    <div>
        <button class="btn btn-sm btn-primary edit-sub">Submitted Strains</button>
        <button class="btn btn-sm btn-primary edit-sub">Completed Strains</button>
        <button class="btn btn-sm btn-primary edit-sub">New Strain</button>
        <button class="btn btn-sm btn-primary edit-sub">Curator Instructions</button>

    </div>


    <hr>

    <div id="div1">
        <%@include file="submittedStrains.jsp"%>
    </div>
</div>

<%@include file="/common/footerarea.jsp"%>