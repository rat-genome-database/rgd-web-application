/***********************************************
    * Context Menu script- © Dynamic Drive (http://www.dynamicdrive.com)
    * This notice MUST stay intact for legal use
    * Visit http://www.dynamicdrive.com/ for this script and 100s more.
***********************************************/

function ContextMenu() {
    this.div = appendDiv("ie5menu", "skin0", document.body);
    this.div.style.display = "block";
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
            document.onclick=gview().contextMenu.hidemenuie5
            obj.initialized = true;
        }

        obj.div.innerHTML = getTarget(e).obj.getContextMenu();

        //Find out how close the mouse is to the corner of the window
        var rightedge=document.all? document.body.clientWidth-event.clientX : window.innerWidth-e.clientX
        var bottomedge=document.all? document.body.clientHeight-event.clientY : window.innerHeight-e.clientY

        //if the horizontal distance isn't enough to accomodate the width of the context menu
        if (rightedge<obj.div.offsetWidth)
        //move the horizontal position of the menu to the left by it's width
        obj.div.style.left=document.all? document.body.scrollLeft+event.clientX-obj.div.offsetWidth : window.pageXOffset+e.clientX-obj.div.offsetWidth
        else
        //position the horizontal position of the menu where the mouse was clicked
        obj.div.style.left=document.all? document.body.scrollLeft+event.clientX : window.pageXOffset+e.clientX

        //same concept with the vertical position
        if (bottomedge<obj.div.offsetHeight)
        obj.div.style.top=document.all? document.body.scrollTop+event.clientY-obj.div.offsetHeight : window.pageYOffset+e.clientY-obj.div.offsetHeight
        else
        obj.div.style.top=document.all? document.body.scrollTop+event.clientY : window.pageYOffset+e.clientY

        obj.div.style.visibility="visible"
        return false
    }

    this.hidemenuie5 = function(e){
        gview().contextMenu.div.style.visibility="hidden"
    }

    this.highlightie5 = function(e){
        var firingobj=document.all? event.srcElement : e.target
        if (firingobj.className=="menuitems"||!document.all&&firingobj.parentNode.className=="menuitems"){
        if (!document.all&&firingobj.parentNode.className=="menuitems") firingobj=firingobj.parentNode //up one node
            firingobj.style.backgroundColor="highlight"
            firingobj.style.color="white"
            //if (display_url==1)
            window.status=firingobj.url
        }
    }

    this.lowlightie5 = function(e){
        var firingobj=document.all? event.srcElement : e.target
        if (firingobj.className=="menuitems"||!document.all&&firingobj.parentNode.className=="menuitems"){
        if (!document.all&&firingobj.parentNode.className=="menuitems") firingobj=firingobj.parentNode //up one node
            firingobj.style.backgroundColor=""
            firingobj.style.color="black"
            window.status=''
        }
    }

    this.jumptoie5 = function(e){
        var firingobj=document.all? event.srcElement : e.target
        if (firingobj.className=="menuitems"||!document.all&&firingobj.parentNode.className=="menuitems"){
        if (!document.all&&firingobj.parentNode.className=="menuitems") firingobj=firingobj.parentNode
        if (firingobj.getAttribute("target"))
            window.open(firingobj.getAttribute("url"),firingobj.getAttribute("target"))
        else
            window.location=firingobj.getAttribute("url")
        }
    }
}

