
       var http_request = false;
       var lastForm = null;
       function makePOSTRequest(theForm) {

          //theForm.submit();
          //return;

          http_request = false;
          lastForm = theForm;
          if (window.XMLHttpRequest) { // Mozilla, Safari,...
             http_request = new XMLHttpRequest();
             if (http_request.overrideMimeType) {
                 // set type accordingly to anticipated content type
                //http_request.overrideMimeType('text/xml');
                http_request.overrideMimeType('text/html');
             }
          } else if (window.ActiveXObject) { // IE
             try {
                http_request = new ActiveXObject("Msxml2.XMLHTTP");
             } catch (e) {
                try {
                   http_request = new ActiveXObject("Microsoft.XMLHTTP");
                } catch (e) {}
             }
          }
          if (!http_request) {
             alert('Cannot create XMLHTTP instance');
             return false;
          }

          http_request.onreadystatechange = alertContents;
          var parameters = create_request_string(theForm);
          http_request.open('POST', theForm.action, true);
          http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
          http_request.setRequestHeader("Content-length", parameters.length);
          http_request.setRequestHeader("Connection", "close");
          http_request.send(parameters);
       }

       function alertContents() {
          if (http_request.readyState == 4) {
             //if (http_request.status == 200) {
                //alert(http_request.responseText);
                result = http_request.responseText;

                if (result.indexOf("Update Successful") != -1) {
                    setUpdated(lastForm);
                }

                document.getElementById('myspan').innerHTML = result;
             //} else {
             //   alert(http_request.responseText);
             //}
          }
       }

    function enableOnChangeEvents(form) {
        for (var j=0; j< form.elements.length; j++) {
            form.elements[j].onchange = function() {
                this.style.backgroundColor = "#FFCCCC";
                this.style.border="1px solid #7f9db9"
                this.style.padding="2px";
                this.isSet = true;
            }
        }

    }

    function enableAllOnChangeEvents() {
        for (var i=0; i< document.forms.length; i++) {
            enableOnChangeEvents(document.forms[i]);
        }
    }       

    function setUpdated(form) {
        for (var j=0; j< form.elements.length; j++) {
            if (form.elements[j].isSet == true) {
                form.elements[j].style.backgroundColor = "#E6FFCC";
                form.elements[j].style.border ="1px solid #7f9db9";
                form.elements[j].style.padding = "2px";
                form.elements[j].isSet = false;
            }
        }
    }

    function setChanged(form) {
        for (var j=0; j< form.elements.length; j++) {
            var elm = form.elements[j];
            if (elm.value != "" && elm.type != "button" && elm.name != "objectStatus" && elm.name != "speciesType") {
                form.elements[j].style.backgroundColor = "#FFCCCC";
                form.elements[j].style.border ="1px solid #7f9db9";
                form.elements[j].style.padding = "2px";
                form.elements[j].isSet = true;
            }
        }
    }

    /*
    function setAllChanged(form) {
        for (var j=0; j< form.elements.length; j++) {
            if (form.elements[j].isSet == true) {
                form.elements[j].style.backgroundColor = "#FFCCCC";
                form.elements[j].style.border ="1px solid #7f9db9";
                form.elements[j].style.padding = "2px";
                form.elements[j].isSet = false;
            }
        }
    }
    */

    function create_request_string(theForm) {
        var reqStr = "";

        for (i = 0; i < theForm.elements.length; i++) {
            isFormObject = false;

            switch (theForm.elements[i].tagName){
                case "INPUT":
                    switch (theForm.elements[i].type){
                        case "text":
                        case "hidden":
                            reqStr += theForm.elements[i].name + "=" + encodeURIComponent(theForm.elements[i].value);
                            isFormObject = true;
                            break;
                        case "checkbox":
                            if (theForm.elements[i].checked) {
                                reqStr += theForm.elements[i].name + "=" + theForm.elements[i].value;
                            } else {
                                reqStr += theForm.elements[i].name + "=";
                            }
                            isFormObject = true;
                            break;
                        case "radio":
                            if (theForm.elements[i].checked) {
                                reqStr += theForm.elements[i].name + "=" + theForm.elements[i].value;
                                isFormObject = true;
                            }
                    }
                    break;
                case "TEXTAREA":
                    reqStr += theForm.elements[i].name + "=" + encodeURIComponent(theForm.elements[i].value);
                    isFormObject = true;
                    break;
                case "SELECT":
                    var sel = theForm.elements[i];
                    reqStr += sel.name + "=" + sel.options[sel.selectedIndex].value;
                    isFormObject = true;
                    break;
            }

            if ((isFormObject) && ((i + 1) != theForm.elements.length)) {
                reqStr += "&";
            }
        }
        return reqStr;
    }

    var areaCount = 1;
    function addTextArea(idVal) {

        var obj = document.getElementById(idVal + "TD");

        var input = document.createElement("input");

        input.type = "hidden";
        input.name = "notesKey";
        input.value = "";
        obj.appendChild(input);


        input = document.createElement("input");

        input.type = "text";
        input.id = idVal + "c" + areaCount;
        input.name = idVal;
        input.size = 9;

        obj.appendChild(input)

        var lookup = document.createElement("a");
        lookup.border = "0";
        lookup.innerHTML = '<img src="/rgdweb/common/images/glass.jpg" border="0"/>';

        lookup.href = "javascript:lookup_render('" + idVal + "c" + areaCount + "', " + areaCount + ");void(0);";
        obj.appendChild(lookup);

        var del = document.createElement("a");
        del.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
        del.border="0";
        del.href = "javascript:removeAssociation('" + idVal + "c" + areaCount + "');void(0);";
        obj.appendChild(del);
        areaCount++;

        enableAllOnChangeEvents();
    }

    function removeAssociation(associationId) {
        var d = document.getElementById(associationId);
        var pd = d.parentNode;

        pd.removeChild(d.nextSibling);
        pd.removeChild(d.nextSibling);
        pd.removeChild(d);

    }

    var aliasCreatedCount = 1;
    function addAlias() {

        var tbody = document.getElementById("aliasTable").getElementsByTagName("TBODY")[0];

        var row = document.createElement("TR");
        row.id = "aliasRowc" + aliasCreatedCount
        row.innerHTML = '<input type="hidden" name="aliasKey" value="0" />';
        var td = document.createElement("TD");
        td.innerHTML = '<input type="text" id="aliasTypeName" name="aliasTypeName" value="" />';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" name="aliasValue" value="" />';
        row.appendChild(td);

        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:removeAlias('aliasRowc" + aliasCreatedCount + "') ;void(0);";

        rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';

        td = document.createElement("TD");
        td.align = "right";
        td.appendChild(rLink);
        row.appendChild(td);

        tbody.appendChild(row);

        aliasCreatedCount++;
        enableAllOnChangeEvents();
    }

    function removeAlias(aliasId) {
        var d = document.getElementById(aliasId);
        d.parentNode.removeChild(d);
    }


   /* genomic element attribute management */
   var attrCreatedCount = 1;
   function addElementAttr() {

       var tbody = document.getElementById("attrTable").getElementsByTagName("TBODY")[0];

       var row = document.createElement("TR");
       row.id = "attrRowc" + attrCreatedCount;
       row.innerHTML = '<input type="hidden" name="attrKey" value="0" />';
       var td = document.createElement("TD");
       td.innerHTML = '<input type="text" id="attrName" name="attrName" value="" />';
       row.appendChild(td);

       td = document.createElement("TD");
       td.innerHTML = '<input type="text" name="attrValue" value="" />';
       row.appendChild(td);

       rLink = document.createElement("A");
       rLink.border="0";
       rLink.href = "javascript:removeElementAttr('attrRowc" + attrCreatedCount + "') ;void(0);";

       rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';

       td = document.createElement("TD");
       td.align = "right";
       td.appendChild(rLink);
       row.appendChild(td);

       tbody.appendChild(row);

       attrCreatedCount++;
       enableAllOnChangeEvents();
   }

   function removeElementAttr(attrId) {
       var d = document.getElementById(attrId);
       d.parentNode.removeChild(d);
   }


