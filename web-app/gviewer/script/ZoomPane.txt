

function ZoomPane(divId, h, w, parentGviewer) {

    this.parentViewer = parentGviewer;
    this.key = divId;
    this.div = document.getElementById(divId);
    this.height = h;
    this.width = w;
    this.chr;
    this.dragActive = false;
    this.objToDivXRef = new Array();
    this.currentAnnotation;

    this.init = function() {
        this.div.style.height = h;
        this.div.style.width = w;
        this.div.obj = this;
        this.scaleRatio = this.parentViewer.defaultZoomRatio;
        
        this.imageViewer = appendDiv(this.key + "imageViewer","image-viewer",document.body);
        hide(this.imageViewer);
        this.content = appendDiv(divId + "_content","zoom-pane-content",this.div);

        this.div.onmousedown = zoompane_mouseDownEvent;
        this.div.onmouseover = zoompane_mouseOverEvent;
        this.div.onmouseup = zoompane_mouseUpEvent;
        this.div.onmousemove = zoompane_mouseMoveEvent;
        this.div.onmouseout = zoompane_mouseOutEvent;      
    }
    this.init();

    this.highlight = function(annot) {
        this.getDiv(annot).label.style.color= "red";
    }

    this.lowlight = function(annot) {
        this.getDiv(annot).label.style.color= "black";
    }

    this.removeAnnotation = function(annot) {
        hide(this.getDiv(annot));
        hide(this.getDiv(annot).label);
    }

    this.getWindowWidthBP = function() {
        return Math.round(parseInt(this.div.style.width) / this.scaleRatio);
    }

    this.getWindowStartBP = function() {
        return Math.round(parseInt(this.div.scrollLeft) / this.scaleRatio);
    }

    this.getWindowEndBP = function() {
        return Math.round(this.getWindowStartBP() + this.getWindowWidthBP());
    }

    this.mapXRef = function (obj, div) {
        this.objToDivXRef[obj.name + ""] = div;
        div.obj = obj;
    }

    this.getDiv = function(object) {
        return this.objToDivXRef[object.name];
    }

    this.boundScaleRatio = function(chr) {
        maxScaleRatio = (this.width -30) / chr.length;
        if (this.scaleRatio < maxScaleRatio) {
            this.scaleRatio = maxScaleRatio ;
        }
    }

    this.render = function (chr) {
       var key = this.content.id;
       this.content.innerHTML = "";

       var cdiv = appendDiv(key + "_c_" + chr.number,"chr-zoom", this.content);
       cdiv.style.height = 16;
       cdiv.style.width=0;

       var left = 0;
       for (j=0; j<chr.bands.length; j++) {
           band = chr.bands[j];

           var bdiv = appendDiv(cdiv.id + "b" + j,band.stain + "-zoom", cdiv);
           bdiv.innerHTML = "&nbsp;&nbsp;" + band.name;
           len = Math.round((band.end - band.start) * this.scaleRatio);
           bdiv.style.width=len;

           if (band.color) {
               bdiv.style.backgroundColor = band.color;
           }
                               
           cdiv.style.width = parseInt(cdiv.style.width) + len;
           this.mapXRef(band, bdiv);
       }

        this.content.style.height = this.height - 80;
        this.div.style.height = this.height ;

        var annotTop = 27;

        //sort alphabetically by type
        var sortFunc = function (a, b) {
            var x = a.type;
            var y = b.type;
            return ((x < y) ? -1 : ((x > y) ? 1 : 0));
        }
        chr.annotations.sort(sortFunc);

        for (var j=0;j<chr.annotations.length; j++) {
            var annot   = chr.annotations[j];
            var adiv = appendDiv(cdiv.id + "a" + j, annot.type, this.content);

            var len = Math.round((annot.end - annot.start) * this.scaleRatio);

            adiv.style.left = Math.round(annot.start * this.scaleRatio);
            adiv.style.backgroundColor =  annot.color;
            adiv.style.height = 10;

            if (len == 0 || len==1) {
              len=2;
            }

            adiv.style.width=len;
            adiv.viewWidth = len;
            this.mapXRef(annot, adiv);

            adivLabel = appendDiv(adiv.id + "_l", "annotation-label", this.content);
            adivLabel.obj = annot;
            adiv.label = adivLabel;

            if (annot.conflict) {
                adivLabel.style.backgroundColor = this.parentViewer.conflictColor;
            }

            adiv.oncontextmenu=window_contextMenuEvent;
            adivLabel.oncontextmenu=window_contextMenuEvent;

            adiv.onmouseover = zoompane_annotation_mouseOverEvent;
            adiv.onmouseout=zoompane_annotation_mouseOutEvent;
            adivLabel.onmouseover=zoompane_annotation_mouseOverEvent;
            adivLabel.onmouseout=zoompane_annotation_mouseOutEvent;

            adiv.onclick = zoompane_annotation_clickEvent;
            adivLabel.onclick = zoompane_annotation_clickEvent;

            adivLabel.innerHTML = annot.name;
            if ((annot.name.length * 7) > len) {                
                adiv.viewWidth = annot.name.length * 7;
            }

            var level = 1;
            for (var k=0; k < chr.annotations.length; k++) {
                if (annot == chr.annotations[k]) {
                    break;
                }

                var divStart = parseInt(adiv.style.left);
                var divEnd = parseInt(adiv.style.left) + adiv.viewWidth;

                var checkStart = parseInt(this.getDiv(chr.annotations[k]).style.left);
                var checkEnd = parseInt(this.getDiv(chr.annotations[k]).style.left) + this.getDiv(chr.annotations[k]).viewWidth;

                if (divStart < checkEnd && divEnd > checkStart) {
                    if (chr.annotations[k].level >= level) {
                        level = chr.annotations[k].level + 1;
                    }
                }
            }

            chr.annotations[j].level = level;
            var top = 25 + (level * annotTop);
            adiv.style.top = top;
            bringToFront(adiv);
            bringToFront(adivLabel);
            adivLabel.style.top = parseInt(adiv.style.top) + 9;
            adivLabel.style.left = adiv.style.left;

            if ((top + 80) > parseInt(this.div.style.height)) {
                this.content.style.height = top + "px";
                 this.div.style.height = (top + 80) + "px";
            }
        }

        if (document.all) {
            cdiv.style.width = parseInt(cdiv.style.width) + 2;
        }

        this.mapXRef(chr, cdiv);
        this.buildScale(0, chr.length , Math.ceil(chr.length * this.scaleRatio));
   }

    this.draw = function(chr) {

        this.boundScaleRatio(chr);
        this.div.style.display = "block";

        this.render(chr);
        this.chr = chr;
    }

    this.moveDivTo = function() {    
        for (var i=0; i< 75; i++) {
            setTimeout("down1()", i * 10);
        }
    }

    this.zoomIn = function () {
        if (!this.chr) {
            return;
        }

        if (this.scaleRatio + (this.scaleRatio * .33) > .00025) {
            if (confirm("Maximum zoom has been reached.  Select OK to view this region in GBrowse.\n")) {
                goToGBrowse();
            }else {
                return;
            }
        }

        this.scaleRatio = this.scaleRatio + (this.scaleRatio * .33);
        this.draw(this.chr);
    }

    this.refresh = function() {
        this.draw(this.chr);
    }

    this.zoomOut = function () {
        if (!this.chr) {
            return;
        }
       
        this.scaleRatio = this.scaleRatio - (this.scaleRatio / 3);
        this.draw(this.chr);
    }

    this.buildScale = function(start, stop, width) {

        var markerSep=Math.round((stop / ((width / 800) * 15)) / 100000)*100000;

        var step = 1;
        if (markerSep <= 1300000) {
            markerSep = 1000000;
        }else if (markerSep > 1300000 && markerSep <= 7000000) {
            step = 5;
            markerSep = 1000000;
        }else if (markerSep > 7000000 && markerSep <= 10000000) {
            step=10
            markerSep = 1000000;
        }else if (markerSep > 10000000) {
            markerSep = 25000000;
        }

        var markerCount = Math.floor(width / (markerSep * this.scaleRatio));

        for (i=1; i<=markerCount; i++) {
            if (i % step == 0) {
                var tmarker = appendDiv("blackPixel" + i,"scale-pixel",this.content);
                tmarker.style.left =   Math.ceil(markerSep * i * this.scaleRatio);

                var label = appendDiv("scaleLabel" + i,"scale-label",this.content);
                label.innerHTML = (Math.round(markerSep * i) / 1000000) + "&nbsp;Mb";
                label.style.left = Math.ceil(markerSep * i * this.scaleRatio) + 3;
            }

            var grid = appendDiv("grid" + i, "scale-grid", this.content);
            grid.style.left =   Math.ceil(markerSep * i * this.scaleRatio);

            nextLeft = Math.ceil(markerSep * i * this.scaleRatio) + 3;
        }
    }

    this.moveTo = function(chr, y) {
        if (!chr || !y) {
            return;
        }
                
        var p = y / Math.floor((chr.length) * gview().scaleRatio);
        var newLeft = (Math.round(Math.ceil((chr.length) * this.scaleRatio) * p) - (parseInt(this.div.style.width) / 2));
        this.div.scrollLeft = (Math.round(Math.ceil((chr.length) * this.scaleRatio) * p) - (parseInt(this.div.style.width) / 2));
    }

    this.dragStart = function(x,y) {
        this.div.style.cursor = "move";
        this.dragActive = true;
        this.y = y;
        this.x = x;
    }

    this.dragStop = function() {
        this.div.style.cursor = "pointer";
        this.dragActive = false;        
    }

    this.move = function(x, y) {
        if (this.dragActive) {
            this.div.scrollLeft = this.div.scrollLeft + (this.x - x );
            this.div.scrollTop = this.div.scrollTop + (this.y - y);
            this.parentViewer.synchSliderToZoomPane(this);
        }

        this.y = y;
        this.x = x;
    }

    this.hideModel = function() {
        hide(this.imageViewer);
        this.parentViewer.clearStatus();
    }

    //shows gene model retrieved from gbrowse
    this.showModel = function(obj, x, y) {
        if (this.parentViewer.imageViewerURL && this.parentViewer.imageViewerURL !="") {

            this.parentViewer.status("Loading " + obj.type + " model for " + obj.name);

            this.imageViewer.innerHTML = "<div>&nbsp;&nbsp;GBrowse Gene Model&nbsp;&nbsp;</div>";
            bringToFront(this.imageViewer);

            this.imageViewer.style.top = y + 25 + getWindowScroll();
            this.imageViewer.style.left = getLeft(this.div) + 25;

            var img = appendImage(this.parentViewer.imageViewerURL + obj.name, this.imageViewer);
            show(this.imageViewer);
        }

    }
}


