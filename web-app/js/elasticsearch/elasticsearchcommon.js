$(function () {
    $("#elasticSearchForm").submit(function () {
        var $content = $("#mainBody");
        $content.html('<div style="margin-left:50%"><i class="fa fa-spinner fa-spin" style="font-size:24px;color:dodgerblue"></i></div>');
        this.closest('form').submit();
    });
     var cat=$('#category').val();
    $("#term").autocomplete({

               delay:500,
               source: function(request, response) {
                   $.ajax({
                       url:"/rgdweb/autocompleteList.html",
                       type: "POST",
                       data: {term: request.term,
                           category:cat},
                       max: 100,
                       dataType: "json",
                       success: function(data) {

                           response(data);
                       }
                   });
               }

           });
   // var objectSearchCat=$('#objectSearchCat').val();
    var objectSearchCat='General';
    $("#objectSearchTerm").autocomplete({

        delay:500,
        source: function(request, response) {
            $.ajax({
                url:"/rgdweb/autocompleteList.html",
                type: "POST",
                data: {term: request.term,
                    category:objectSearchCat},
                max: 100,
                dataType: "json",
                success: function(data) {

                    response(data);
                }
            });
        }

    });

});