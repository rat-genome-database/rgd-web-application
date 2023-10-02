

function toggle(_this, groupClass){
    if(_this.checked){
        $('.'+groupClass).prop("checked", true);

    }

    else{
        $('.'+groupClass).prop("checked", false);
    }
}
function getSelectedOptions(){
    strainGroupId=$('#strainGroupId').val();
    trait=$('#trait').val();
    rangephenotypes=$('.rangephenotypes:checked').map(function () {
        return this.value;
    }).get().join(",");
    rangeage=$('.rangeage:checked').map(function () {
        return this.value;
    }).get().join(",");
    rangesex=$('.rangesex:checked').map(function () {
        return this.value;
    }).get().join(",");

    methods=$('.rangemethods:checked').map(function () {
        return this.value;
    }).get().join(",");
}
function getRangeData() {
    var $url="/rgdweb/phenominer/phenominerExpectedRanges/views/strainOptions.html?phenotypes="+rangephenotypes
        + "&sex="+rangesex+"&age="+rangeage +"&strainGroupId="+strainGroupId +"&trait="+ trait+"&methods="+methods;
    $.get($url, function (data, status) {
        $('#mainContent').html(data);
    })

}
$(function () {
    $("#erStrainSelect").on('change', function () {
        var strainGroupId=this.value;
        $("#strainGroupId").val(strainGroupId);
        $("#erStrainsSelectForm").submit();
    });
    $('.strainconditions').attr("disabled", true);
    $("input[name='phenotypes']").on('click', function () {
        var checked=$(this).val();
        getSelectedOptions();
        getRangeData();
    });
    $("input[name='age']").on('click', function () {
        var checked=$(this).val();
        getSelectedOptions();
        getRangeData();
    });
    $("input[name='sex']").on('click', function () {
        var checked=$(this).val();
        getSelectedOptions();
        getRangeData();
    });

    $("input[name='rangemethods']").on('click', function () {
        var checked=$(this).val();
        getSelectedOptions();
        getRangeData();
        
    });
})
