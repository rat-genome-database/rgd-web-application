$(function () {


    $(document).ready(function(){

    $('#approve').click(function (e) {
        $("#a").val("approve");
      })
    $('#delete').click(function (e) {
        $("#a").val("delete");
       })
    $('#cancel').click(function (e) {
        $("#a").val("cancel");
       })
   
   var $table1=jQuery("#modelTable").tablesorter({
       theme: 'blue',
       widthFixed: false,
       widgets: ['zebra',"filter"],

       headers: {
           0: {sorter: false},
           10: {sorter: false},
           11: {sorter: false}
       },
        sortList:[[1,0]],
       cssChildRow:"tablesorter-childRow",

            widgetOptions:{
                filter_columnFilters:false,
                filter_anyMatch:true,
                filter_reset : 'button.reset'

            }})
            .tablesorterPager({container: $(".pager"),
                page:0,
                size:9999,
                savePages:true
            });

    $table1.find( '.tablesorter-childRow td' ).addClass( 'hidden' );

   
    $(".toggle").on('click', function () {
        if($(this).find('.fa').hasClass("fa-plus-circle")){
            $(this).find('.fa').removeClass("fa-plus-circle");
            $(this).find('.fa').addClass("fa-minus-circle");
            $(this).find('.fa').css('color', 'red');
            $(this).find('.fa').prop('title', 'Click to collapse');
        }else{
            $(this).find('.fa').removeClass("fa-minus-circle");
            $(this).find('.fa').addClass("fa-plus-circle");
            $(this).find('.fa').css('color', 'green');
            $(this).find('.fa').prop('title', 'Click to expand');
        }
       if($(this).closest( 'tr' )
            .nextUntil( 'tr.header1' )
            .find( 'td' ).hasClass('hidden')){
           $(this).closest( 'tr' )
               .nextUntil( 'tr.header1' )
               .find( 'td' ).removeClass('hidden');
           $(this).closest( 'tr' )
               .nextUntil( 'tr.header1' )
               .find( 'td' ).show()
       }else{
           $(this).closest( 'tr' )
               .nextUntil( 'tr.header1' )
               .find( 'td' ).addClass('hidden');
           $(this).closest( 'tr' )
               .nextUntil( 'tr.header1' )
               .find( 'td' ).hide()
       }
    })



    var acc = document.getElementsByClassName("accordion");
    var i;

    for (i = 0; i < acc.length; i++) {
        acc[i].onclick = function(){
            this.classList.toggle("active");
            this.nextElementSibling.classList.toggle("show");
        }
    }
    var $childRows=$('.tablesorter tr.tablesorter-childRow');

$(".expandCollapseAll").on('click', function () {
   var object= $(this).find('.fa');
 if(object.hasClass("expandAll")){
    if($(document).find('.expand').hasClass("fa-plus-circle")) {
        $(document).find('.expand').removeClass("fa-plus-circle");
        $(document).find('.expand').addClass("fa-minus-circle");
        $(document).find('.expand').css('color', 'red');
        $(document).find('.expand').prop('title', 'Click to collapse');
    }
     object.removeClass('fa-plus-circle').addClass('fa-minus-circle').css('color', 'red');
     object.prop('title', 'Click to collapse all');
     object.removeClass('expandAll');
     object.addClass('collapseAll');
    $childRows.find('td').removeClass('hidden');
    $childRows.find('td').show();

    }else {
        if ($(document).find('.expand').hasClass("fa-minus-circle")) {
         $(document).find('.expand').removeClass("fa-minus-circle");
         $(document).find('.expand').addClass("fa-plus-circle");
         $(document).find('.expand').css('color', 'green');
         $(document).find('.expand').prop('title', 'Click to expand');
     }
     object.removeClass('fa-minus-circle').addClass("fa-plus-circle").css('color', 'green');
     object.prop('title', 'Click to expand all');
     object.removeClass('collapseAll');
     object.addClass('expandAll');
     $childRows.find('td').addClass('hidden');
     $childRows.find('td').hide();
    }

  })

    $('input[name="geneSearch"]').keyup(function(){
        /*** first method *** data-filter-column="1" data-filter-text="!son"
         add search value to Discount column (zero based index) input */
       var filters = [],
            $t = $(this),
            col = $t.data('filter-column'), // zero-based index
            txt =  this.value; // text to add to filter

        filters[col] = txt;
        // using "table.hasFilters" here to make sure we aren't targeting a sticky header
        $.tablesorter.setFilters( $('.tablesorter'), filters, true ); // new v2.9
        return false;
    });
 
});

    $("#gene-filter-reset-button").on('click', function () {
        $("#geneSearch").val("")
    })


});

