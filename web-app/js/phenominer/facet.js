
$(function () {
    if(selectAllRsCheckbox !== typeof undefined && selectAllRsCheckbox=='on'){
        $('input[name="rsAll"]').prop('checked', true)
    }
    if(selectAllCmoCheckbox !== typeof undefined && selectAllCmoCheckbox=='on'){
        $('input[name="cmoAll"]').prop('checked', true)
    }
    if(selectAllMmoCheckbox !== typeof undefined && selectAllMmoCheckbox=='on'){
        $('input[name="mmoAll"]').prop('checked', true)
    }
    if(selectAllXcoCheckbox !== typeof undefined && selectAllXcoCheckbox=='on'){
        $('input[name="xcoAll"]').prop('checked', true)
    }
    if(selectAllSexCheckbox !== typeof undefined && selectAllSexCheckbox=='on'){
        $('input[name="sexAll"]').prop('checked', true)
    }
    if(selectAllUnitsCheckbox !== typeof undefined && selectAllUnitsCheckbox=='on'){
        $('input[name="unitsAll"]').prop('checked', true)
    }
})

    $('#rsAll').change(function() {
        if($(this).is(":checked")) {
            $.each($('input[name="rsTerm"]'), function(){
                var _this=$(this);
                _this.prop('checked', true);

            });
        }else {
            $.each($('input[name="rsTerm"]'), function(){
                var _this=$(this);
                _this.prop('checked', false);

            });
        }
        $('#phenominerReportForm').submit()
    });

/*$('#cmoAll').change(function() {
    if($(this).is(":checked")) {
        $.each($('input[name="cmoTerm"]'), function(){
            var _this=$(this);
            _this.prop('checked', true);

        });
    }else {
        $.each($('input[name="cmoTerm"]'), function(){
            var _this=$(this);
            _this.prop('checked', false);

        });
    }
    $('#phenominerReportForm').submit()
});*/
$('#mmoAll').change(function() {
    if($(this).is(":checked")) {
        $.each($('input[name="mmoTerm"]'), function(){
            var _this=$(this);
            _this.prop('checked', true);

        });
    }else {
        $.each($('input[name="mmoTerm"]'), function(){
            var _this=$(this);
            _this.prop('checked', false);

        });
    }
    $('#phenominerReportForm').submit()
});
$('#xcoAll').change(function() {
    if($(this).is(":checked")) {
        $.each($('input[name="xcoTerm"]'), function(){
            var _this=$(this);
            _this.prop('checked', true);

        });
    }else {
        $.each($('input[name="xcoTerm"]'), function(){
            var _this=$(this);
            _this.prop('checked', false);

        });
    }
    $('#phenominerReportForm').submit()
});
$('#sexAll').change(function() {
    if($(this).is(":checked")) {
        $.each($('input[name="sex"]'), function(){
            var _this=$(this);
            _this.prop('checked', true);

        });
    }else {
        $.each($('input[name="sex"]'), function(){
            var _this=$(this);
            _this.prop('checked', false);

        });
    }
    $('#phenominerReportForm').submit()
});
$('#unitsAll').change(function() {
    if($(this).is(":checked")) {
        $.each($('input[name="units"]'), function(){
            var _this=$(this);
            _this.prop('checked', true);

        });
        $.each($('input[name="experimentName"]'), function(){
            var _this=$(this);
            _this.prop('checked', true);

        });
        $.each($('input[name="cmoTerm"]'), function(){
            var _this=$(this);
            _this.prop('checked', true);

        });
    }else {
        $.each($('input[name="units"]'), function(){
            var _this=$(this);
            _this.prop('checked', false);

        });
        $.each($('input[name="experimentName"]'), function(){
            var _this=$(this);
            _this.prop('checked', false);

        });
        $.each($('input[name="cmoTerm"]'), function(){
            var _this=$(this);
            _this.prop('checked', false );

        });
    }
    $('#phenominerReportForm').submit()
});

$.each($('input[name="cmoTerm"]'), function() {

    var _this = $(this);
    var val = _this.val();
    _this.prop('checked', false);
    console.log("SELECTED CMO:" + selectedCmo);
    if (selectedCmo !== typeof undefined) {

        $.each(selectedCmo.split(","), function (i, selected) {
            if (selected ==val) {
                console.log("SELECTED:"+ selected+"\tval:"+ val)

                _this.prop('checked', true)
            }
        })
    }
});

$.each($('input[name="rsTerm"]'), function(){
    //    console.log(selectedSubtype+"\tthis.Val="+ $(this).val())
    var _this=$(this);
    var val=_this.val();
    _this.prop('checked', false);
    console.log("SELECTED SUB TYPE:" + selectedRs);
    if(selectedRs !== typeof undefined){
        $.each(selectedRs.split(","), function (i,selected) {
            if(selected===val){
                _this.prop('checked',true)
            }
        })}
    if(selectAllRsCheckbox !== typeof undefined && selectAllRsCheckbox=='on') {
        _this.prop('checked', true)

    }

});

$.each($('input[name="mmoTerm"]'), function(){
    var _this=$(this);
    var val=_this.val();
    _this.prop('checked', false);
    console.log("SELECTED EDITOR TYPE:" + selectedMmo);
    if(selectedMmo !== typeof undefined) {
        $.each(selectedMmo.split(","), function (i, selected) {
            if (selected === val) {
                _this.prop('checked', true)
            }
        })
    }
});
$.each($('input[name="xcoTerm"]'), function(){
    var _this=$(this);
    var val=_this.val();
    if(selectedXco!==typeof undefined)
        $.each(selectedXco.split(","), function (i,selected) {
            if(selected===val){
                _this.prop('checked',true)
            }
        })
});
$.each($('input[name="sex"]'), function(){

    var _this=$(this);
    var val=_this.val();
    _this.prop('checked', false);
    if(selectedSex!==typeof  undefined)
        $.each(selectedSex.split(","), function (i,selected) {
            if(selected===val){
                _this.prop('checked',true)
            }
        })
});

$.each($('input[name="units"]'), function(){

    var _this=$(this);
    var val=_this.val();
    _this.prop('checked', false);
    if(val.includes('%'))
        $('.'+val.replace('%','percent').replace(/\s/g, "").replace(/\//g,'')).prop('checked', false);
    else{
        $('.'+val.replace(/\//g,'').replace(/\s/g, "")).prop('checked', false);

    }
    if(selectedUnits!==typeof undefined)
        $.each(selectedUnits.split(","), function (i,selected) {
            if(selected===val){
                _this.prop('checked',true);
                if(val.includes('%'))
                $('.'+val.replace('%','percent').replace(/\s/g, "").replace(/\//g,'')).prop('checked', true);
                else{
                    $('.'+val.replace(/\//g,'').replace(/\s/g, "")).prop('checked', true);

                }
            }
        })
});
if(selectedExperimentName!==typeof undefined && selectedExperimentName!="") {
    $.each($('input[name="experimentName"]'), function () {

        var _this = $(this);
        var val = _this.val();
        _this.prop('checked', false);

        $('.formCheckInput.' + val.replace(/\s/g, "")).prop('checked', false);


        if (selectedExperimentName !== typeof undefined)
            $.each(selectedExperimentName.split(","), function (i, selected) {

                if (selected == val) {
                    _this.prop('checked', true);

                    $('.formCheckInput.' + val.replace(/\s/g, "")).prop('checked', true);

                    //     $('.'+val.replace(/\//g,'').replace(/\s/g, "")).prop('checked', true);


                }
            })
    });
}
function removeFilter(filter, key) {

    $.each($('input[type="checkbox"]'),function () {
        var _this=$(this);
        var val=_this.val();
   //     alert('VAL:'+ val+"\tFILTER:"+ filter);
       if(val==filter){
           _this.prop('checked',false)
       }
       if(key=='experimentName' || key=='rsTerm'){
           $('.formCheckInput.'+filter.replace(/\s/g, "").replace(/\//g,'')).prop('checked', false);
       }
    });
    $('#phenominerReportForm').submit()
}
function updateSelection(bkt) {

    var _this = $('.' + bkt.replace(/\s/g, "").replace(/\//g,''));
   // alert(_this.is(":checked")+"\t"+ bkt+ "\t"+ _this);
    if (_this.is(":checked")) {
        _this.prop('checked', false)
        $('.' + bkt.replace(/\s/g, "")).prop('checked', false);
    }else{
        _this.prop('checked', true)
        $('.' + bkt.replace(/\s/g, "")).prop('checked', true);

    }
    $('#phenominerReportForm').submit()
}