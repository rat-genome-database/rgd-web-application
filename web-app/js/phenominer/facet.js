
$.each($('input[name="cmoTerm"]'), function() {
    var _this = $(this);
    var val = _this.val();
    _this.prop('checked', false);
    console.log("SELECTED TYPE:" + selectedCmo);
    if (selectedCmo !== typeof undefined) {

        $.each(selectedCmo.split(","), function (i, selected) {
            if (selected === val) {
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
    if(selectedUnits!==typeof undefined)
        $.each(selectedUnits.split(","), function (i,selected) {
            if(selected===val){
                _this.prop('checked',true)
            }
        })
});
function removeFilter(filter) {

    $.each($('input[class="formCheckInput"]'),function () {
        var _this=$(this);
        var val=_this.val();
       if(val==filter){
           _this.prop('checked',false)
       }
    })
    $('#phenominerReportForm').submit()
}
