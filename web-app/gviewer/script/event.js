
function gviewer_mouseOverEvent(e) {
    gview().focus = true;
}

function gviewer_mouseOutEvent(e) {
    gview().focus = false;        
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

    if (firedDiv.className == "chr") {
        if (gview().isActiveChr(obj.number)) {
            if (gview().frozen) {
                gview().thaw();
            }else {
                gview().freeze();
            }
        }else {
            gview().moveTo(obj,e.clientY);
        }
    }
}

function gviewer_object_mouseMoveEvent(e) {
    if (!e) e = window.event;
    var obj = getTarget(e).obj;

    if (gview().frozen) return;

    if (obj && gview().isActiveChr(obj.chr.number)) {
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
