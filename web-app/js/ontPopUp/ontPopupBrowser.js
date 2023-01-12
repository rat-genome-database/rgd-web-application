var _popup_wnd = null;
function ontPopup(callback, ontCode, selTerm){
    if( _popup_wnd!=null ) {
        if( !_popup_wnd.closed ) {
            _popup_wnd.focus();
            return;
        }
    }
    _popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont="+ontCode.toUpperCase()+"&sel_term="+selTerm+"&sel_acc_id="+callback+"&curationTool=1&acc_id="
        +document.getElementById(callback+'').value, '', "width=900,height=500,resizable=1,scrollbars=1,center=1,toolbar=1");
    return false;

}
function ontPopupPublic(callback, ontCode, selTerm){
    if( _popup_wnd!=null ) {
        if( !_popup_wnd.closed ) {
            _popup_wnd.focus();
            return;
        }
    }
    _popup_wnd = window.open("/rgdweb/ontology/view.html?mode=popup&ont="+ontCode.toUpperCase()+"&sel_term="+selTerm+"&sel_acc_id="+callback+"&acc_id="
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