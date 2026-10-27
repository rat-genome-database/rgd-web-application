$(function () {
    $("#elasticSearchForm").submit(function () {
        var $content = $("#mainBody");
        $content.html('<div style="margin-left:50%"><i class="fa fa-spinner fa-spin" style="font-size:24px;color:dodgerblue"></i></div>');

        // The report pages' floating chrome - the sticky bar naming the report and its section,
        // and the back to top button - is appended to document.body by reportModernUx.js, which
        // puts it OUTSIDE #mainBody. Blanking #mainBody therefore took the report away and left
        // those two behind, and because they are shown and hidden only from a scroll handler,
        // searching from a page that had been scrolled down left "A2m / Summary", "Collapse all"
        // and an up arrow stranded on top of the spinner until the next page arrived.
        $('.rgd-stickybar, .rgd-to-top').remove();

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