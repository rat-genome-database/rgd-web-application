var _popup_wnd = null;
function ontPopupGroup(callback, ontCode, cnt){
        if( _popup_wnd!=null ) {
            if( !_popup_wnd.closed ) {
                _popup_wnd.focus();
                return;
            }
        }
        _popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont="+ontCode.toUpperCase()+"&sel_term="+ontCode+cnt+"_term&sel_acc_id="+callback+cnt+"&curationTool=1&acc_id="
            +document.getElementById(callback+cnt+'').value, '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
        return false;

}
function ontPopup(callback, ontCode){
    if( _popup_wnd!=null ) {
        if( !_popup_wnd.closed ) {
            _popup_wnd.focus();
            return;
        }
    }
    _popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont="+ontCode.toUpperCase()+"&sel_term="+ontCode+"_term&sel_acc_id="+callback+"&curationTool=1&acc_id="
        +document.getElementById(callback+'').value, '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
    return false;

}
function lostFocus(ont) {
    setTimeout("checkForValidTerm('" + ont + "')", 200);
}
function checkForValidTerm(ont) {

    var term = document.getElementById(ont + "_term").value;
    var acc = document.getElementById(ont + "_acc_id").value;

    if (term !="" && acc == "") {
        alert("Please select a term from the list or browse ontology tree");
        document.getElementById(ont + "_term").value="";
    }


}