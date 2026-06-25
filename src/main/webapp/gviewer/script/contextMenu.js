/***********************************************
    * Context Menu script- � Dynamic Drive (http://www.dynamicdrive.com)
    * This notice MUST stay intact for legal use
    * Visit http://www.dynamicdrive.com/ for this script and 100s more.
***********************************************/

function ContextMenu() {
    this.div = appendDiv("ie5menu", "skin0", document.body);
    this.div.style.display = "block";
    this.div.setAttribute("role", "menu");
    this.div.setAttribute("aria-label", "Annotation context menu");
    var display_url=0
    this.initialized = false;

    this.showmenuie5 = function(e){
        if (!e) e = window.event;

        obj = gview().contextMenu;

        bringToFront(obj.div);

        if (!obj.initialized) {
            obj.div.onmouseover=gview().contextMenu.highlightie5;
            obj.div.onmouseout=gview().contextMenu.lowlightie5;
            obj.div.onclick=gview().contextMenu.jumptoie5;
            document.onclick=gview().contextMenu.hidemenuie5;
            // Keyboard support: Escape to close
            document.addEventListener("keydown", function(ke) {
                if (ke.key === "Escape") {
                    gview().contextMenu.hidemenuie5();
                }
            });
            obj.initialized = true;
        }

        var target = e.target || e.currentTarget;
        while (target && !target.obj) { target = target.parentElement || target.parentNode; }
        if (!target || !target.obj) return false;
        obj.div.innerHTML = target.obj.getContextMenu();

        //Find out how close the mouse is to the corner of the window
        var rightedge = window.innerWidth - e.clientX;
        var bottomedge = window.innerHeight - e.clientY;

        //if the horizontal distance isn't enough to accomodate the width of the context menu
        if (rightedge < obj.div.offsetWidth)
            obj.div.style.left = (window.pageXOffset + e.clientX - obj.div.offsetWidth) + "px";
        else
            obj.div.style.left = (window.pageXOffset + e.clientX) + "px";

        //same concept with the vertical position
        if (bottomedge < obj.div.offsetHeight)
            obj.div.style.top = (window.pageYOffset + e.clientY - obj.div.offsetHeight) + "px";
        else
            obj.div.style.top = (window.pageYOffset + e.clientY) + "px";

        obj.div.style.visibility="visible"
        return false
    }

    this.hidemenuie5 = function(e){
        gview().contextMenu.div.style.visibility="hidden"
    }

    this.highlightie5 = function(e){
        var firingobj = e.target;
        if (firingobj.parentNode && firingobj.parentNode.className == "menuitems") firingobj = firingobj.parentNode;
        if (firingobj.className == "menuitems") {
            firingobj.style.backgroundColor = "highlight";
            firingobj.style.color = "white";
        }
    }

    this.lowlightie5 = function(e){
        var firingobj = e.target;
        if (firingobj.parentNode && firingobj.parentNode.className == "menuitems") firingobj = firingobj.parentNode;
        if (firingobj.className == "menuitems") {
            firingobj.style.backgroundColor = "";
            firingobj.style.color = "black";
        }
    }

    this.jumptoie5 = function(e){
        var firingobj = e.target;
        if (firingobj.parentNode && firingobj.parentNode.className == "menuitems") firingobj = firingobj.parentNode;
        if (firingobj.className == "menuitems") {
            if (firingobj.getAttribute("target"))
                window.open(firingobj.getAttribute("url"), firingobj.getAttribute("target"));
            else
                window.location = firingobj.getAttribute("url");
        }
    }
}

