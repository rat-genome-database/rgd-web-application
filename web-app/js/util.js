

function cancelEvents(e) {
    if (e.cancelable){
        e.preventDefault()
    }
    return false;    
}

function getWindowScroll() {
    return window.scrollY ? window.scrollY : document.body.scrollTop;
}

function trim(stringToTrim) {
	if (!stringToTrim) {
        return "";
    }
    return stringToTrim.replace(/^\s+|\s+$/g,"");
}

var lastZIndex = 100;
function bringToFront(div) {
    div.style.zIndex = ++lastZIndex;
}

function getPosition(who){
    var T= 0,L= 0;
    while(who){
        L+= who.offsetLeft;
        T+= who.offsetTop;
        who= who.offsetParent;
    }
    return [L,T];
}

function getTop(who) {
    var pos = getPosition(who);
    return pos[1];
}

function getLeft(who) {
    var pos = getPosition(who);
    return pos[0];        
}

function checkMinMax(min, max, value) {
    if (value < min) {
        return min;
    }
    if (value > max) {
        return max;
    }
    return value;
}

function show(div) {
    div.style.visibility = "visible";
}

function hide(div) {
    div.style.visibility = "hidden";            
}

function getPixelLength(len, ratio) {
    return Math.round(len * ratio);        
}

function getTarget(e) {
    return document.all ? e.srcElement : e.currentTarget;
}

function findTarget(e, clsName) {
    var fired = getTarget(e);

    while (fired) {
        if (fired.className == clsName) {
            return fired;
        }
        fired = fired.offsetParent;
    }
    return null;
}

function remove(array, from, to) {
  var rest = array.slice((to || from) + 1 || array.length);
  array.length = from < 0 ? array.length + from : from;
  return array.push.apply(array, rest);
};

function appendDiv(divId, className, parentDiv) {
    var div = document.createElement("DIV");
    div.id = divId;
    div.className = className;
    parentDiv.appendChild(div);
    return div;
}

function appendInput(type,name,value,form) {
    var input = document.createElement("input");
    input.type=type;
    input.name = name;
    input.value=value;
    form.appendChild(input);
    return input;
}

function appendImage(src, div) {
    var img = document.createElement("img");
    img.src = src;
    div.appendChild(img);
    return img;
}

function getStyleSheet() {
	var theRules = new Array();
	if (document.styleSheets[0].cssRules) {
		return document.styleSheets[0].cssRules;
	} else if (document.styleSheets[0].rules) {
		return document.styleSheets[0].rules;
	}
}

// Cross browser remove event wrapper
function removeEvent(obj, evType, fn, useCapture){
  if (obj.removeEventListener){
    obj.removeEventListener(evType, fn, useCapture);
    return true;
  } else if (obj.detachEvent){
    var r = obj.detachEvent("on"+evType, fn);
    return r;
  } else {
    alert("Handler could not be removed");
  }
}

// Cross browser add event wrapper
function addEvent(elm, evType, fn, useCapture) {
    if (elm.addEventListener) {
        elm.addEventListener(evType, fn, useCapture);
        return true;
    }
    else if (elm.attachEvent) {
        var r = elm.attachEvent('on' + evType, fn);
        return r;
    }
    else {
        elm['on' + evType] = fn;
    }
}

//returns the contents of a form in a url encoded get string
function getFormString(theform) {
var formStr = "";
var amp = "";

for(i=0; i<theform.elements.length; i++){
	if (theform.elements[i].name != "module" && theform.elements[i].name != "func") {
		if(theform.elements[i].type == "text" || theform.elements[i].type == "textarea" || theform.elements[i].type == "hidden"){
			formStr += amp+theform.elements[i].name+"="+encodeURIComponent(theform.elements[i].value);
		} else if ((theform.elements[i].type == "checkbox" || theform.elements[i].type == "radio") && theform.elements[i].checked) {
			formStr += amp+theform.elements[i].name+"="+encodeURIComponent(theform.elements[i].value);
		} else if (theform.elements[i].type == "select-one") {
			formStr += amp+theform.elements[i].name+"="+theform.elements[i].options[theform.elements[i].selectedIndex].text;
		}
		amp = "&";
	}
}
return formStr;
}//end PostAform function

/*
  name - name of the desired cookie
  return string containing value of specified cookie or null
  if cookie does not exist
*/

function getCookie(name) {
  var dc = document.cookie;
  var prefix = name + "=";
  var begin = dc.indexOf("; " + prefix);
  if (begin == -1) {
    begin = dc.indexOf(prefix);
    if (begin != 0) return null;
  } else
    begin += 2;
  var end = document.cookie.indexOf(";", begin);
  if (end == -1)
    end = dc.length;
  return unescape(dc.substring(begin + prefix.length, end));
}

 /*
   name - name of the cookie
   value - value of the cookie
   [expires] - expiration date of the cookie
     (defaults to end of current session)
   [path] - path for which the cookie is valid
     (defaults to path of calling document)
   [domain] - domain for which the cookie is valid
     (defaults to domain of calling document)
   [secure] - Boolean value indicating if the cookie transmission requires
     a secure transmission
   * an argument defaults when it is assigned null as a placeholder
   * a null placeholder is not required for trailing omitted arguments
*/

function setCookie(name, value, expires, path, domain, secure) {
  var curCookie = name + "=" + escape(value) +
      ((expires) ? "; expires=" + expires.toGMTString() : "") +
      ((path) ? "; path=" + path : "") +
      ((domain) ? "; domain=" + domain : "") +
      ((secure) ? "; secure" : "");
  document.cookie = curCookie;
}

/***********************************************
* Dynamic Ajax Content- � Dynamic Drive DHTML code library (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code
***********************************************/

var bustcachevar=1; //bust potential caching of external pages after initial request? (1=yes, 0=no)
var loadedobjects="";
var rootdomain="http://"+window.location.hostname;
var bustcacheparameter="";
var loadDiv_callbackfn = null;

function loadDiv(url, containerid){
    var page_request = false
    if (window.XMLHttpRequest) {
        page_request = new XMLHttpRequest()
    } else if (window.ActiveXObject){ // if IE
        try {
            page_request = new ActiveXObject("Msxml2.XMLHTTP")
        }
        catch (e){
            try{
                page_request = new ActiveXObject("Microsoft.XMLHTTP")
            }
            catch (e){}
        }
    } else {
        return false
    }

    page_request.onreadystatechange=function(){
        loadDiv_loadpage(page_request, containerid)
    }

    if (bustcachevar) //if bust caching of external page
        bustcacheparameter=(url.indexOf("?")!=-1)? "&"+new Date().getTime() : "?"+new Date().getTime()
        page_request.open('GET', url+bustcacheparameter, true)
        page_request.send(null)
    }

    function loadDiv_loadpage(page_request, containerid){
        if (page_request.readyState == 4 && (page_request.status==200 || window.location.href.indexOf("http")==-1)) {

        if (document.getElementById(containerid)) {
            if (page_request.responseText.indexOf("resultBar") == -1) {
                document.getElementById(containerid).innerHTML=page_request.responseText;
            }else {
                document.getElementById(containerid).innerHTML="";
            }
            if( loadDiv_callbackfn!=null )
                loadDiv_callbackfn(containerid);
        }
    }
}

function Debugger(top, left) {

    var debug = appendDiv("gviewer_debug", "debug" ,document.body);
    debug.style.top = top;
    debug.style.left = left;
    debug.style.position = "absolute";

    var str = '<form name="debug">';
    str +='<textarea name="out" rows="8" cols="70"></textarea>';
    str +="<input type=\"button\" value=\"clear\" onClick=\"this.form.out.value = ''\"/>";
    str +='</form>';

    debug.innerHTML = str;

    this.out = function(msg) {
        if (document.debug) {
            document.debug.out.value = msg + "\n" + document.debug.out.value;
        }
    }
}

function addMouseWheelEvent(func) {
    if (window.addEventListener) {
        window.addEventListener('DOMMouseScroll', func, true);
    }
    window.onmousewheel = document.onmousewheel = func;    
}

function prereq(str, condition) {
    return condition ? str : "";
}