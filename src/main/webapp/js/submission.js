$(function () {
    $('#verifyGene').on('click', function () {
        var g= $('#rs_term').val();
        alert(g);
    })
    $('#imageupload').on('change' ,function (e) {
        //  $("#action").val("upload");
        //   alert("upload");
        var $content=$("#div1");
        var $content2=$("#uploadContainer");
        var $fileLocation= $("#fileLocation");
        e.preventDefault();
        var file_data = $("#imageupload").prop("files")[0];   // Getting the properties of file from file field
        var form_data = new FormData();                  // Creating object of FormData class
        form_data.append("file", file_data)              // Appending parameter named file with properties of file_field to form_data
        // form_data.append("user_id", 123)                 // Adding extra parameters to form_data
        $.ajax({
            url: "upload.html",
            //  dataType: 'script',
            cache: false,
            contentType: false,
            processData: false,
            data: form_data,                         // Setting the data attribute of ajax with file_data
            type: 'post',
            success:function (data) {
                //   $content.html(data);
                var $data=data.toString();
                console.log($data);
                if($data=='false'){
                    $content.html("<span style='color:red'>File upload incomplete. Please make sure the  file format is  \".PNG\" or \".JPEG\" or \".GIF\" and file size less than 5MB.</span>");
                }else{
                    $fileLocation.val($data);
                    $content2.html("<span style='color:green'>Successfully uploaded the image file.</span>");
                }

            }
        })
    });
    $('#formSubmit').click(function () {
        $("#action").val("submit");
        //   alert("submit")
        var _this=$("#myForm");
        var $content=$('#test');
        var $container=$('#submissionWrapper');

        var symbol = $('#symbol').val();
        var lastname = $('#lastname').val();
        var firstname = $('#firstname').val();
        var email = $('#email').val();
        var source = $('#source').val();

        var bool = (symbol && lastname && firstname && email && source);
        if (bool) {
            $.ajax({
                type: _this.attr('method'),
                url: "strainSubmissionForm.html",
                data: _this.serialize(),
                success: function (data) {
                    var $successData= data.toString();
                    if($successData=='false'){
                        $content.html("ReCaptcha Validation Failed.  Please try again.")
                    }else{
                    // window.location.href=$successUrl;
                        let words = $successData +"";
                        if (~words.indexOf("Strain Symbol you tried to submit is already in the RGD")) {
                            alert("Strain Symbol is in RGD. Please use another Strain Symbol.");
                        }
                        else
                            $container.html($successData + "<br><p style='color:grey'>Thank you for your interest in strain submission</p>");

                    }

                }

            })
        }

    });
    /*    $("#myForm").submit(function () {
     var $content=$('#test');
     $.ajax({
     type:this.attr('method'),
     url:this.attr('action'),
     data:this.serialize(),
     success:function (data) {
     $content.html(data)
     }

     })
     })*/
    // $("#geneRgdid").keydown(function (e) {
    //     restrictToNumber(e)
    // });
    //
    // $("#alleleRgdid").keydown(function (e) {
    //     restrictToNumber(e);
    //
    // });
    function restrictToNumber(e) {
        // Allow: backspace, delete, tab, escape, enter and .
        if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110, 190]) !== -1 ||
            // Allow: Ctrl+A
            (e.keyCode == 65 && e.ctrlKey === true) ||
            // Allow: Ctrl+C
            (e.keyCode == 67 && e.ctrlKey === true) ||
            // Allow: Ctrl+X
            (e.keyCode == 88 && e.ctrlKey === true) ||
            // Allow: home, end, left, right
            (e.keyCode >= 35 && e.keyCode <= 39)) {
            // let it happen, don't do anything
            return;
        }
        // Ensure that it is a number and stop the keypress
        if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
            e.preventDefault();
        }
    }
})