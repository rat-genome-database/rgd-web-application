$(document).ready(function(){

    $('ul.tabs li').click(function(){
        var tab_id = $(this).attr('data-tab');

        $('ul.tabs li').removeClass('current');
        $('.tab-content').removeClass('current');

        $(this).addClass('current');
        $("#"+tab_id).addClass('current');
    });

    $("input[name='searchTableNet']").keyup(function(){
        // alert("working");
        var value= this.value.toLowerCase();
        var table= $("#dTable");
        $.each(table.find("tr"), function() {
            var id= $(this).find("td").text().toLowerCase();
            if(id.indexOf(value) === -1)
                $(this).hide();
            else
                $(this).show();
        });
    });
    $("input[name='searchTableNode']").keyup(function(){
        //  alert("working");
        var value= this.value.toLowerCase();
        var table= $("#ntable tbody");
        $.each(table.find("tr"), function(index) {
            //  if(index!=0){
            var id= $(this).find("td").text().toLowerCase();
            if(id.indexOf(value) === -1)
                $(this).hide();
            else
                $(this).show();
            //    }

        });
    });
});