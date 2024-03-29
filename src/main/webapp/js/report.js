// used by report pages

var headerRefs = [];

function regHeader(title) {
    document.getElementById(title).onclick = showSection;
    document.getElementById(title + "_i").onclick = showSection;
    document.getElementById(title + "_content").style.display = "none";

    headerRefs.push(document.getElementById(title));
}

function openAll() {
    for (var i=0; i < headerRefs.length; i++) {
        if(headerRefs[i].id.substr(headerRefs[i].id.length -1) != "C"){
            openSection(headerRefs[i]);
        }
    }
}

function showSection(e) {
    if (!e) e = window.event;
    var obj = document.all ? e.srcElement : e.currentTarget;

    if (document.all) {
        if (obj.id.indexOf("_i") != -1) {
            var name = obj.id.substring(0,obj.id.indexOf("_i"));
            obj=document.getElementById(name);
        }
        window.event.cancelBubble = true;
    }else {

    }

    openSection(obj);
}


function openSection(obj) {
    var sister = null;
    if (obj.id.substr(obj.id.length -1) == "C") {
        sister = document.getElementById(obj.id.substr(0, obj.id.length - 1));
    }else {
        sister = document.getElementById(obj.id + "C");
    }

    for (i=0; i < 2; i++) {
        if (i==1) {
            obj=sister;
            if (!obj) return;
        }

        if (obj) {
            var content =  document.getElementById(obj.id + "_content");
            if (content) {
                if (content.style.display == "block") {
                    content.style.display="none";
                    document.getElementById(obj.id + "_i").src = "/rgdweb/common/images/add.png";
                }else {
                    content.style.display="block";
                    document.getElementById(obj.id + "_i").src = "/rgdweb/common/images/remove.png";
                }
            }
        }
    }
}

function removeHashLink(url){
    let hashLocation = url.indexOf('#');
    if(hashLocation !== -1){
        url = url.substring(0, hashLocation);
    }

    return url;
}

function addParam(name, value) {
    var re = new RegExp(name + "=[^\&]*");
    let url = removeHashLink(location.href);
    if (re.exec(url) != null) {
        location.href = url.replace(re, name + "=" + value)
    } else {
        location.href = url + "&" + name + "=" + value;
    }
}
function assignDetail() {
    let isDetail;
    if (sessionStorage.getItem('isDetail') === null) {
        isDetail = true;
    } else {
        isDetail = sessionStorage.getItem('isDetail') === 'true';
    }
    return isDetail;
}
function toggleAssociations(detailWindowLocation, summaryWindowLocation) {
    let url = window.location.href;
    let hashLocation = url.indexOf('#');
    let isDetail = assignDetail();
    let text;
    url = url.substring(0, hashLocation);

    if (!isDetail) {
        document.getElementById("associationsCurator").style.display="block";
        text = "Click to see Annotation Summary View";
        updateToggleText(text);
        location.assign(url + '#' + detailWindowLocation);
        sessionStorage.setItem('isDetail', 'true');
    }else {
       document.getElementById("associationsCurator").style.display="none";
    }

    if (isDetail) {
        document.getElementById("associationsStandard").style.display="block";
        text =  "Click to see Annotation Detail View";
        updateToggleText(text);

        location.assign(url + '#' + summaryWindowLocation);
        sessionStorage.setItem('isDetail', 'false');

    }else {
       document.getElementById("associationsStandard").style.display="none";
    }
}

function updateToggleText(text){
    let toggles = Array.from(document.getElementsByClassName("associationsToggle"));
    toggles.forEach( toggle => {
        if (toggle) {
            toggle.innerText = text;
        }
    })

}

function toggleDivs(id_hide, id_show) {
    $('#'+id_hide).hide(400);
    $('#'+id_show).show(900);
}

/**
 * detect IE
 * returns version of IE or false, if browser is not Internet Explorer
 * js code by: http://codepen.io/gapcode/pen/vEJNZN
 */
function detectIE() {
    var ua = window.navigator.userAgent;

    // test values
    // IE 10
    //ua = 'Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Trident/6.0)';
    // IE 11
    //ua = 'Mozilla/5.0 (Windows NT 6.3; Trident/7.0; rv:11.0) like Gecko';
    // IE 12 / Spartan
    //ua = 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.71 Safari/537.36 Edge/12.0';

    var msie = ua.indexOf('MSIE ');
    if (msie > 0) {
        // IE 10 or older => return version number
        return parseInt(ua.substring(msie + 5, ua.indexOf('.', msie)), 10);
    }

    var trident = ua.indexOf('Trident/');
    if (trident > 0) {
        // IE 11 => return version number
        var rv = ua.indexOf('rv:');
        return parseInt(ua.substring(rv + 3, ua.indexOf('.', rv)), 10);
    }

    var edge = ua.indexOf('Edge/');
    if (edge > 0) {
        // IE 12 => return version number
        return parseInt(ua.substring(edge + 5, ua.indexOf('.', edge)), 10);
    }

    // other browser
    return false;
}
