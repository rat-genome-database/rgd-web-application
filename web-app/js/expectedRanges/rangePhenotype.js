
function getPhenotypeSelectedOptions(){
    cmo=$('#cmoId').val();
    traitOntId=$('#trait').val();
    phenotypestrains=$('.phenotypestrains:checked').map(function () {
        return this.value;
    }).get().join(",");
    phenotypeage=$('.phenotypeage:checked').map(function () {
        return this.value;
    }).get().join(",");
    phenotypesex=$('.phenotypesex:checked').map(function () {
        return this.value;
    }).get().join(",");
    phenotypemethods=$('.phenotypemethods:checked').map(function () {
        return this.value;
    }).get().join(",");
}
function getPhenotypeRangeData() {
    var $url="/rgdweb/phenominer/phenominerExpectedRanges/views/selectedOptions.html?phenotypestrains="+phenotypestrains+"&phenotypeage="+phenotypeage+"&phenotypesex="+phenotypesex+"&cmo="+cmo+"&trait="+traitOntId+
        "&methods="+ phenotypemethods;
   console.log($url);
    $.get($url, function (data, status) {
        $('#mainContent').html(data);
    })

}

function toggle(_this, groupClass){
    if(_this.checked){
        $('.'+groupClass).prop("checked", true);

    }

    else{
        $('.'+groupClass).prop("checked", false);
    }
}
$(function () {
    $('.er-options-checkbox').on('click', function () {
        var optionsForm=$('#er-options-form');

       var cmo=$('#cmoId').val();
       var traitOntId=$('#trait').val();
      var  phenotypeage=$('.phenotypeage:checked').map(function () {
            return this.value;
        }).get().join(",");
      var  phenotypesex=$('.phenotypesex:checked').map(function () {
            return this.value;
        }).get().join(",");
     var   phenotypemethods=$('.phenotypemethods:checked').map(function () {
            return this.value;
        }).get().join(",");

        var  phenotypestrains=$('.phenotypestrains:checked').map(function () {
            return this.value;
        }).get().join(",");
    
        $("#phenotypestrains").val(phenotypestrains);
        $("#phenotypeage").val(phenotypeage);
        $("#phenotypesex").val(phenotypesex);
        $("#phenotypemethods").val(phenotypemethods);
  /*      var url="/rgdweb/phenominer/phenominerExpectedRanges/views/selectedMeasurement.html?phenotypestrains="+phenotypestrains+"&phenotypeage="+phenotypeage+"&phenotypesex="+phenotypesex+"&cmoId="+cmo+"&trait="+traitOntId+   "&methods="+ phenotypemethods+"&traitExists=true"+"&options=true";*/
        var url="/rgdweb/phenominer/phenominerExpectedRanges/views/selectedOptions.html";
        optionsForm.attr("action", url );
        optionsForm.submit();
    })
       $("#erPhenotypesSelect").on('change', function () {
            var phenotype=this.value;
            $("#cmoId").val(phenotype);
            $("#erPhenotypesSelectForm").submit();
        });
        $('.phenotypeconditions').attr("disabled", true);

 /*   $("input[name='phenotypestrains']").on('click', function () {
        var checked=$(this).val();
        getPhenotypeSelectedOptions();
        getPhenotypeRangeData();
    });
    $("input[name='phenotypeage']").on('click', function () {
        var checked=$(this).val();
        getPhenotypeSelectedOptions();
        getPhenotypeRangeData();
    });
    $("input[name='phenotypesex']").on('click', function () {
        var checked=$(this).val();
        getPhenotypeSelectedOptions();
       getPhenotypeRangeData();
    });
    $("input[name='phenotypemethods']").on('click', function () {
        var checked=$(this).val();
        getPhenotypeSelectedOptions();
        getPhenotypeRangeData();
       
    });*/
});
