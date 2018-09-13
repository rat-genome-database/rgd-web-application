var lookup_intervalId = null;
var lookup_lastValue= null;
var lookup_currentId = null;
var lookup_currentWindow = null;
var lookup_speciesTypeKey = null;
var lookup_objectType = null;
var lookup_callbackfn = null;

function lookup_checkValue() {
    var box = document.getElementById("lookup_entry");
    if (!box) return;
    if (lookup_lastValue != box.value) {
        lookup_lastValue = box.value;
        if (box.value.length > 1) {
            var url = "/rgdweb/common/lookup/lookupList.jsp?search=" + box.value;

            if (lookup_speciesTypeKey != null) {
                url = url + "&speciesTypeKey=" + lookup_speciesTypeKey;
            }

            if (lookup_objectType != null) {
                url = url + "&objectType=" + lookup_objectType;
            }
            loadDiv(url, "myDiv");
        }
    }
}

function lookup_update(str) {
    document.getElementById(lookup_currentId).value=str;
    lookup_cancel();
    if( lookup_callbackfn!=null )
        lookup_callbackfn(lookup_currentId, str);
}

function lookup_cancel() {
    if (lookup_currentWindow != null && !lookup_currentWindow.closed) {
        lookup_currentWindow.close();
    }
    clearInterval(lookup_intervalId);
}

function lookup_render(oid, speciesTypeKey, objectType) {
    if (!objectType) {
        objectType=null;
    }

    if (!speciesTypeKey) {
        speciesTypeKey=null;
    }

    var seed = "";
    if (document.getElementById(oid)) {
        seed = document.getElementById(oid).value;    
    }


    lookup_currentId = oid;
    lookup_speciesTypeKey = speciesTypeKey;
    lookup_objectType = objectType;
    if (lookup_currentWindow != null && !lookup_currentWindow.closed) {
        lookup_currentWindow.close();
    }

    lookup_currentWindow=dhtmlwindow.open('ajaxbox', 'ajax', '/rgdweb/common/lookup/lookup.jsp?seed=' + seed, 'Symbol Lookup', 'width=400px,height=350px,left=300px,top=50px,resize=0,scrolling=1');
    //lookup_intervalId = setInterval("lookup_checkValue()", 3500);

}
