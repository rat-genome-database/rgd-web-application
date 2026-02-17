
function gviewer_mouseOverEvent(e) {
    gviewForEvent(e).focus = true;
}

function gviewer_mouseOutEvent(e) {
    gviewForEvent(e).focus = false;
}

function zoompane_mouseDownEvent(e) {
    if (!e) e = window.event;

    var fired = findTarget(e, "zoom-pane");
    if (fired == null) {
        return;
    }

    gview().zoomPane.dragStart(e.clientX, e.clientY);
    return cancelEvents(e);
}

function zoompane_mouseMoveEvent(e) {
    if (!e) e = window.event;

    fired = findTarget(e, "zoom-pane");
    if (fired == null) {
        return true;
    }

    gview().zoomPane.move(e.clientX, e.clientY);
    return cancelEvents(e);
}

function zoompane_mouseUpEvent(e) {
    if (!e) e = window.event;

    var fired = findTarget(e, "zoom-pane");
    if (fired == null) {
        return true;
    }

    gview().zoomPane.dragStop();
    return cancelEvents(e);
}

function zoompane_mouseOverEvent(e) {
    if (!e) e = window.event;
    gview().focus = true;
    return cancelEvents(e);
}

function zoompane_mouseOutEvent(e) {
    if (!e) e = window.event;
    gview().focus = false;
    return cancelEvents(e);
}

function zoompane_annotation_mouseOutEvent(e) {
    if (!e) e = window.event;
    var firedDiv = getTarget(e);
    var obj = firedDiv.obj;

    this.currentAnnotation = null;
    gview().zoomPane.hideModel();
    return cancelEvents(e);

}
function zoompane_annotation_clickEvent(e) {
    if (!e) e = window.event;
    var firedDiv = getTarget(e);
    var obj = firedDiv.obj;

    obj.showReport();

}

function zoompane_annotation_mouseOverEvent(e) {
    if (!e) e = window.event;
    var firedDiv = getTarget(e);
    var obj = firedDiv.obj;

    this.currentAnnotation = obj;
    if (obj.type == "gene") {
        gview().zoomPane.showModel(obj,e.clientX,e.clientY);
    }

    //if (firedDiv.label) {
    //    fireDiv.lable.style.border = "1px dashed red";
    //}else {
    //    firedDiv.style.border="1px dashed red";
    //}

    return cancelEvents(e);
}

function gviewer_chromosome_mouseOverEvent(e) {
    if (!e) e = window.event;
    var firedDiv = findTarget(e, "chr");

    if (gview().isActiveChr(firedDiv.obj.number)) {
        return;
    }

    gview().highlightChromosome(firedDiv.obj);
}

function gviewer_chromosome_mouseOutEvent(e) {
    if (!e) e = window.event;
    firedDiv = findTarget(e, "chr");

    if (gview().isActiveChr(firedDiv.obj.number)) {
        return;
    }

    gview().lowlightChromosome(firedDiv.obj);
}


function gviewer_chromosome_clickEvent(e) {


    if (!e) e = window.event;
    firedDiv = findTarget(e, "chr");
    var obj = firedDiv.obj;
    var elements= document.getElementsByClassName("chr");
    for(var i=0;i<elements.length;i++){
        elements[i].style.border="0px solid black";
        elements[i].style.borderRadius="10px"
    }
    if (firedDiv.className === "chr") {

        var chrNum=obj.number;
        if(chrNum==='Undefined' || chrNum===0){
            chrNum=1;
        }
      
       firedDiv.style.border="5px solid dodgerblue";
       firedDiv.style.borderRadius="10px";
        document.getElementById("chrNum").innerHTML="(Chromosome "+ chrNum+")";
        gview().chr=chrNum;
        gview().openGenomeBrowser();
  
    }
}
function gviewer_chromosome_clickEvent_jbrowse2(e) {
    if (!e) e = window.event;
    firedDiv = findTarget(e, "chr");
    var obj = firedDiv.obj;
    //  var URL="/jbrowse2/?loc=chr4:156553759-156652676&assembly=GRCr8&tracklist=true&tracks=Rat%20GRCr8%20(rn8)%20Genes%20and%20Transcripts-GRCr8"
    var chrNum=obj.number;
    var mapKey= $('#mapKey').val();
    var species=$('#species').val();
    var assembly= $('#assembly').val();
    var assemblyId=$('#assemblyId').val();
    var tracks='';
    if(assemblyId!=null && assemblyId!='null') {
     tracks+=  species+"%20"+assembly+ "%20(" + assemblyId + ")%20";
    }else{
        tracks+=assembly+"%20";
    }
    tracks+="Genes%20and%20Transcripts-" + assembly;
 //   var URL="https://rgd.mcw.edu/jbrowse2/?&tracklist=true&tracks="+tracks+"&assembly="+assembly;
   var URL="https://rgd.mcw.edu/jbrowse2/?&tracklist=true&"

        var end = obj.length
    var st =end-1000000 ;
        var loc="chr"+chrNum+":"+st+"-"+end
        URL  = URL+"&loc="+loc;
        URL+="&assembly="+assembly;
        URL +="&tracks="+tracks;
        console.log("URL:"+ URL);
        window.open(URL)


}

function gviewer_object_mouseMoveEvent(e) {
    if (!e) e = window.event;
    var obj = getTarget(e).obj;

    if (gview().frozen) return;

    if (obj && gview().isActiveChr(obj.chr.number)) {

        //var start = Math.round((parseInt(obj.chr.slider.div.style.top) / gview().scaleRatio));

        var st = gview().zoomPane.getWindowStartBP();
        var end = gview().zoomPane.getWindowEndBP();

        if (gview().vid!== "gviewer2") {
            gview("gviewer2").clearHighlights();
            gview().getSynteny(obj.chr.number, st, end);
        }

        //gview("gviewer2").highlightPosition(5,st,end);
        gview().moveTo(obj.chr, e.clientY);
    }

}

function window_contextMenuEvent(e) {
    if (!e) e = window.event;

    if (!gview().contextMenu) {
        gview().contextMenu = new ContextMenu();
    }

    gview().contextMenu.showmenuie5(e);
    return cancelEvents(e);
}

function window_mouseWheelEvent(e){
    if (!e) e = window.event;

    if (!gview().focus) {
        return true;
    }

    var delta = 0;
    if (e.wheelDelta) {
        delta = e.wheelDelta/120;
        if (window.opera) delta = -delta;
    } else if (e.detail) {
        delta = -e.detail/3;
    }

    if (delta) {
        if (delta <0) {
            gview().zoomOut();
        }else {
            gview().zoomIn();
        }
    }
    return cancelEvents(e);
}
