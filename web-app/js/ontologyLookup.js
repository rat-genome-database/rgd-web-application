var lookup_intervalId = null;
var lookup_lastValue= null;
var lookup_currentId = null;
var lookup_currentWindow = null;
var lookup_objectType = null;


function lookup_checkValue() {
    var box = document.getElementById("lookup_entry");
    if (!box) return;
    if (lookup_lastValue != box.value) {
        lookup_lastValue = box.value;
        if (box.value.length > 1) {
            var url = "/rgdweb/common/lookup/ontology/curationLookupList.jsp?search=" + box.value;

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
}

function lookup_cancel() {
    if (lookup_currentWindow != null && !lookup_currentWindow.closed) {
        lookup_currentWindow.close();
    }
    clearInterval(lookup_intervalId);
}

function lookup_render(oid, objectType) {
    if (!oid) {
        oid=null;
    }

    if (!objectType) {
        objectType=null;
    }

    var seed = "";
    if (document.getElementById(oid)) {
        seed = document.getElementById(oid).value;
    }

    lookup_currentId = oid;
    lookup_objectType = objectType;
    if (lookup_currentWindow != null && !lookup_currentWindow.closed) {
        lookup_currentWindow.close();
    }

    lookup_currentWindow=dhtmlwindow.open('ajaxbox', 'ajax', '/rgdweb/common/lookup/ontology/lookup.jsp?seed=' + seed, 'Ontology Lookup', 'width=800px,height=350px,left=100px,top=50px,resize=0,scrolling=1');
    //lookup_intervalId = setInterval("lookup_checkValue()", 3500);

}

function lookup_treeRender(oid, ontid, rootid) {
    if (!oid) {
        oid=null;
    }

    var seed = "";
    if (document.getElementById(oid)) {
        seed = document.getElementById(oid).value;
    }

    if (seed.length == 0) {
        window.open("/rgdweb/ontology/view.html?acc_id=" + rootid, '', 'scrollbars=1,top=50,left=50,width=900,height=600');
    } else if (seed.indexOf(':')>=0)
    {
        window.open("/rgdweb/ontology/view.html?acc_id=" + seed, '', 'scrollbars=1,top=50,left=50,width=900,height=600');
    } else {
        window.open("/rgdweb/ontology/search.html?term=" + seed + "&ont=" + ontid, '', 'scrollbars=1,top=50,left=50,width=900,height=600');
    }

}
