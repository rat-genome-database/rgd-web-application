
function Annotation(aStart, aEnd, aType, aLabel, aLink, aColor) {

    this.chr;
    this.start = aStart;
    this.end = aEnd;
    this.type = aType;
    this.name = aLabel;
    this.link = aLink;
    this.color = aColor;
    this.div=new Array();

    this.getContextMenu = function () {
        var menu = "";
        menu += '<div style="background-color: gray;">' + this.type + " : " + this.name + '</div>';
        menu += '<div class="menuitems" url="' + this.link + '">View ' + this.type + ' Report</div>';
        menu += prereq("<div class=\"menuitems\" url=\"javascript:gview().openGenomeBrowserForObject('" + this.name + "')\">View in " + gview().genomeBrowserName + "</div>", gview().genomeBrowserURL);
        menu += '<hr>';
        menu += prereq("<div class=\"menuitems\" url=\"javascript:gview().removeAnnotation('" + this.chr.name + "','" + this.name + "')\">Remove From Display</div>",this.link);
        return menu;
    }

    this.showReport = function() {
        window.open(this.link);
    }
}

function Chromosome(chrNumber) {
	this.bands = new Array();
    this.annotations = new Array();
    this.length = 0;
	this.number = chrNumber;
    this.name = chrNumber;
    this.div = new Array();
    this.slider;

    this.getLength = function(scale) {
        if (!scale) {
           return this.length;
        }else {
            return Math.round(this.length * scale);
        }
    }

    this.addBand = function(band) {
        band.chr = this;
        this.bands[this.bands.length] = band;
        this.length = band.end;
    }

    this.addAnnotation = function (annotation) {
        annotation.chr = this;
        this.annotations.splice(0,0,annotation)
    }

    this.getAnnotation = function(name) {
        for (var i=0; i< this.annotations.length; i++) {
            if (this.annotations[i].name == name) {
                return this.annotations[i];
            }
        }
    }

    this.removeAnnotation = function (annotation) {
        for (var i=0; i< this.annotations.length; i++) {
            if (this.annotations[i].name == annotation.name) {
                remove(this.annotations, i, i);
            }
        }
    }
}

function Band(bName, bStart, bEnd, bStain, bColor){
	this.name = bName;
	this.start = bStart;
	this.end = bEnd;
	this.stain = bStain;
    this.chr;
    this.color = bColor;
    this.div = new Array();
}

function Slider(chr) {

    this.div = appendDiv(chr.div.id + "_slider", "slider", chr.div);
    //this.div.obj = new Object();
    this.chr = chr;
    this.div.onmousemove=gviewer_object_mouseMoveEvent;

    this.hide = function() {
        hide(this.div);
    }

    this.show = function() {
        show(this.div);
    }

    this.freeze = function() {
        this.div.style.backgroundColor="red";
    }

    this.thaw = function() {
        this.div.style.backgroundColor="gray";
    }
}

var queue = {
    _timer: null,
    _queue: [],
    add: function(fn, context, time) {
        var setTimer = function(time) {
            queue._timer = setTimeout(function() {
                time = queue.add();
                if (queue._queue.length) {
                    setTimer(time);
                }
            }, time || 2);
        }

        if (fn) {
            queue._queue.push([fn, context, time]);
            if (queue._queue.length == 1) {
                setTimer(time);
            }
            return;
        }

        var next = queue._queue.shift();
        if (!next) {
            return 0;
        }

        eval("next[0].call(gview()," + next[1] + "  );");
        return next[2];
    },
    clear: function() {
        clearTimeout(queue._timer);
        queue._queue = [];
    }
};

function DHTMLWindowManager() {

    this.window;

    this.open = function(title, msg) {
           this.window = dhtmlwindow.open("wm" + new Date().getTime(), "inline", msg, title, "width=300px,height=250px,resize=1,scrolling=1,center=1", "recal");
    }

    this.openExternal = function(title, url) {
           this.window = dhtmlwindow.open("wm" + new Date().getTime(), "ajax", url, title, "width=700px,height=250px,resize=1,scrolling=1,center=1", "recal");
    }

    this.closeLast = function() {
        try {
            this.window.close();
        }catch (e) {
        }
    }

    this.minimizeLast = function() {
        this.window.minimize();
    }
}

function AnnotationTypesManager() {

    this.types = new Array();
    this.typeCounts = new Array();

    this.update = function(type) {
        if (!this.typeCounts[type]) {
            this.types[this.types.length] = type;
            this.typeCounts[type] = 0;
        }
        this.typeCounts[type]++;
    }
        
    this.getStatus = function(color_scheme) {
        if (true) return "";
        var msg = "";
        for (var j=0; j < this.types.length; j++) {
            var span = "<span style='color:" + color_scheme[this.types[j]][0]+"'>"
                    + this.typeCounts[this.types[j]] + " " + this.types[j] + "s</span>";

            if (j == 0) {
                msg += span + " ";
            }else if (j == (this.types.length -1)) {
                msg += " and " + span + " loaded ";
            }else {
                msg += ", " + span + ", ";
            }
        }

        if (this.types.length == 1) {
            msg += "loaded";
        }

        return msg;
    }

 }