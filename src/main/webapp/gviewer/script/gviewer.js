/***********************************************
* DHTML Window Widget- � Dynamic Drive (www.dynamicdrive.com)
* This notice must stay intact for legal use.
* Visit http://www.dynamicdrive.com/ for full source code
***********************************************/

var gviewerRef = null;

//returns the current gviewer reference
var gview = function () {
    return gviewerRef;
}

function Gviewer(viewerId, height, width) {

    gviewerRef = this;

    //---------------------------------------------------
    //USER CONFIGURATION SETTINGS
    //---------------------------------------------------

    //relative or absolute path the the images directory
    this.imagePath = "images";

    //will post data to this url to allow for a serverside download of the data
    this.exportURL = "/rgdweb/report/format.html";

    //set the color scheme used for the annotations in the viewer. array[0] is the initial color.
    //array[1] is used for added objects
    this.colorScheme = new Array();
    this.colorScheme["gene"] = ["#7e131d","#7e131d"];
    this.colorScheme["qtl"] = ["#3294d3", "#3294d3"];
    this.colorScheme["sslp"] = ["#76ac1a", "#76ac1a"];
    this.colorScheme["snp"] = ["purple","#f37200"];
    this.colorScheme["probeset"] = ["#7e131d","#f37200"];
    this.colorScheme["eqtl"] = ["#7e131d","#f37200"];
    this.colorScheme["strain"] = ["#76ac1a","#76ac1a"];
    //this line added by JTHOTA
    this.colorScheme["variant"] = ["#f49b42","#f4af41"];

    //Set the available annotatoin types to be displayed by the viewer
    //this.annotationTypes = new Array("gene","qtl");
    this.annotationTypes = new Array("gene","qtl","strain");
    //enables use of the mouse wheel to control zoom
    this.enableMouseWheelZoom = false;
    //url to jbrowse instance. If not set, jbrowse is not used
    this.genomeBrowserURL = "";
    //url to jbrowse http image api.  If not set, gene models are not available
    this.imageViewerURL = "";
    //Genome browser name.  Used for display purposes only
    this.genomeBrowserName = "JBrowse";
    //number of pixels vertically the centromere should span
    this.centromereLength = 5;
    //default size of the slider
    this.defaultZoomRatio = .00002;
    //The calculation may be off a little bit vertically. This setting can be used as a dial to tweak
    //the amount of vertical space used by the viewer.
    this.padFactor = 53;
    //space in pixels between the annotation tracks and chromosomes.  A larger number means narrower annotation tracks
    this.regionPadding=4;
    //space in pixels between annotations
    this.annotationPadding = 2;
    //default species type.  This can be an arbitrary number or string.
    this.speciesType="3";
    //color used to show objects that have been loaded twice. Shows object in common.
    this.conflictColor = "yellow";
    //the add functionality is RGD specific. External sites will need to reimplement this function
    this.enableAdd = true;

    //border width used when highlighting an objects
    this.highlightBorderWidth=2;

    //DO NOT MODIFY BELOW THIS LINE----------------------------------------------
    this.chr; this.div; this.windowManager; this.typesManager
    this.annotationWidth; this.chromosomeWidth; this.annotationPadding;
    this.contextMenu; this.positionDiv; this.statusBar; this.canvas; this.regionWidth; this.regionPadding

    this.vid = viewerId;
    this.chromosomes = new Array();
    this.frozen = false;
    this.zoomPane = false;
    this.pixelHeight = height;
    this.pixelWidth = width;
    this.currentColorScheme = 0;
    this.x = 0;
    this.y = 0;
    this.scaleRatio = 0;
    this.focus = false;
    this.chromosomeIndexXref = new Array();
    this.lastLoad = new Array();
    this.loaded = new Array();
    this.bandURL = "";

    //searches chromosomes to return the longest one.
    this.getLongestChromosome = function() {
        var longest = this.chromosomes[1];
        for (var i = 1; i < this.chromosomes.length; i++) {
            if (parseInt(this.chromosomes[i].length) > parseInt(longest.length)) {
                longest = this.chromosomes[i];
            }
        }
        return longest;
    }

    this.init = function() {
        this.div = document.getElementById(viewerId);
        this.div.onmouseover = gviewer_mouseOverEvent;
        this.div.onmouseout = gviewer_mouseOutEvent;        
        this.div.style.width = this.pixelWidth;
        this.div.obj = this;
        
        this.loadingBar = appendDiv(this.vid + "loadingBar", "loading-bar", this.div);
        this.canvas = appendDiv(this.vid + "canvas", "canvas", this.div);
        //this.canvas.style.height = (this.pixelHeight - 46);
        this.statusBar = appendDiv(this.vid + "status", "status-bar", this.div);
        this.positionDiv = appendDiv(this.vid + "position","position-bar", this.div);
        var controlBar = appendDiv(this.vid + "controlBar","control-bar", this.div);

       this.canvas.style.height = (this.pixelHeight - 46);

        this.loadingBar.innerHTML = "&nbsp;Loading Annotations...&nbsp;";
        
        var cStr = '<table width="100%" border="0" cellpadding="0" cellspacing="0" style="font-size:10px;"><tr><td>&nbsp;&nbsp;<a href="javascript: gview().display()">List&nbsp;All&nbsp;Objects</a>&nbsp;|&nbsp;';
        cStr += prereq('<a href="javascript: gview().displayExportList()">CSV&nbsp;Export</a>&nbsp;|&nbsp;', this.exportURL);
        cStr += prereq('<a href="javascript: gview().add()">Add&nbsp;Objects</a>&nbsp;|&nbsp;', this.enableAdd);
        cStr += '<a href="javascript: gview().reset()">Clear</a>';
        cStr += '</td><td align=right id="gview_zoomOptions" style="display:none;"><a href="javascript: gview().zoomIn()">Zoom In</a>&nbsp;|&nbsp;';
        cStr += '<a href="javascript: gview().zoomOut()">Zoom&nbsp;Out</a>&nbsp;|&nbsp;';
        cStr += prereq('<a href="javascript: gview().openGenomeBrowser()">Send&nbsp;to&nbsp;' + this.genomeBrowserName + '</a>&nbsp;|&nbsp;',this.genomeBrowserURL);
        cStr += '<a href="javascript: gview().closeZoomPane()">Close&nbsp;Zoom&nbsp;Pane</a>&nbsp;&nbsp;</td></tr></table>';

       controlBar.innerHTML = cStr;

        this.zoomOptions = document.getElementById("gview_zoomOptions");
        this.windowManager = new DHTMLWindowManager();
        this.typesManager = new AnnotationTypesManager();

        if (this.enableMouseWheelZoom) {
            addMouseWheelEvent(window_mouseWheelEvent);
        }
    }

    //returns true if chr number passed in is currently displayed in the zoom pane
    this.isActiveChr = function(chrNumber) {
        return (this.chr && chrNumber == this.chr.number);
    }

    //removes an object from the viewer
    this.removeAnnotation = function (chrName, annotName) {
        var chr = this.getChromosome(chrName);
        var annot = chr.getAnnotation(annotName);

        hide(annot.div);
        if (this.zoomPaneActive()) {
            this.zoomPane.removeAnnotation(annot);            
        }

        chr.removeAnnotation(annot);
        this.status("Removed " + annotName);
    }

    //Removes all objects from the viewer
    this.reset = function (url, species) {
        this.div.innerHTML = "";
        this.closeZoomPane();
        this.chromosomes = new Array();        
        this.loaded = new Array();
        this.status("Loading Bands");

        if (!url) {
            url = this.bandURL;
        }
        this.loadBands(url, species);
        this.status("");
        this.currentColorScheme=0;
    }

    //prints a status msg to the screen
    this.status = function(msg) {
        if (!this.statusBar) return;
        bringToFront(this.statusBar);
        this.statusBar.innerHTML = msg;
    }

    //clears the status msg from the screen
    this.clearStatus = function() {
        if (!this.statusBar) return;
        this.statusBar.innerHTML = "";
    }

    //loads an object into the viewer
    this.loadAnnotation = function(start,end,type,label,link,color,chrNumber) {

        var chr = this.getChromosome(chrNumber);
        if (chr == null) return;

        var annot = chr.getAnnotation(label);
        if (annot) {
            this.highlight(chr.number, annot.name, this.conflictColor);
            annot.conflict=true;
            this.lastLoad[this.lastLoad.length]= annot;
            return;
        }

        // object type could be like that: 'gene, protein-coding, PROVISIONAL [RefSeq]'
        // or like that: 'strain'; just use 1st word only  --MT
        var annotType = type.toLowerCase();
        var commaPos = annotType.indexOf(',');
        type = commaPos>0 ? annotType.substring(0, commaPos) : annotType;

        annot = new Annotation(start,end,type,label,link,color);

        if (!color) {
            annot.color = this.colorScheme[type][this.currentColorScheme];
        }else {
            annot.color = color;
        }

        chr.addAnnotation(annot);
        this.lastLoad[this.lastLoad.length]= annot;

        this.renderAnnotation(chr, annot);
        this.typesManager.update(annot.type);

        return annot;
    }

    //loads an jklparsexml data object into the viewer
    this.loadAnnotationData = function (data, color) {
        if (data && data.genome && data.genome.feature) {
            if (!data.genome.feature.length) {
                var obj = data.genome.feature;
                data.genome.feature = new Array(1);
                data.genome.feature[0] = obj;
            }

            for (var i=0; i< data.genome.feature.length; i++) {
                feature = data.genome.feature[i];

                if (feature.chromosome) {
                    //queue.add(this.loadAnnotation,"'" + feature.start + "','" + feature.end + "','" + feature.type + "','" + feature.label + "','" + feature.link + "','" + feature.color + "','" + feature.chromosome + "'",1);
                    this.loadAnnotation(feature.start,feature.end,feature.type,feature.label,feature.link,color,feature.chromosome);
                }
            }

            this.currentColorScheme=1;
            this.status(this.typesManager.getStatus(this.colorScheme));
        }else {
            this.status("0 Results Found")
        }
    }

    this.loadAnnotationsGET = function(url, color, term) {

        try {

            show(this.loadingBar);
            this.lastLoad = new Array();
            var index = this.loaded.length;

            var obj = new Object();
            obj.url = url;
            obj.color = color;
            obj.term = term;

            this.loaded[index] = obj;

            var xml = new JKL.ParseXML( url );
            var func = function ( data ) {                  // define call back function
                gview().loadAnnotationData(data, color);

                if (term) {
                    gview().windowManager.open(term ,"<br><b><div style='padding:3px;'>" + gview().lastLoad.length + " objects found for term \"" + term + "\".</div></b>(<span style=\"font-size:12px;padding:3px;\">&nbsp;Hover over the symbol to show the objects location)</span><br>" + gview().annotationArrayToList(gview().lastLoad));
                }

                if (gview().zoomPaneActive()) {
                    gview().zoomPane.refresh();
                }
                hide(gview().loadingBar);
            }

            var errorFunc = function(status) {
                alert("An error occured in fetch of data. Server returned stats code " + status);
                hide(gview().loadingBar);
            }

            xml.async( func );
            xml.onerror( errorFunc );
            xml.parse();
        }catch (e) {
            alert("Error: " + e + " could not load objects");
        }
    }



    //retrieves xml file from url and loads objects into the viewer
    this.loadAnnotations = function(url, color, term) {
        try {

        show(this.loadingBar);
        this.lastLoad = new Array();
        var index = this.loaded.length;

        var obj = new Object();
        obj.url = url;
        obj.color = color;
        obj.term = term;

        this.loaded[index] = obj;

          var parts = url.split("?");
            //alert(parts[0]);
            //alert(parts[1]);


        var xml = new JKL.ParseXML( parts[0],parts[1],"POST" );
        var func = function ( data ) {                  // define call back function
           gview().loadAnnotationData(data, color);

           if (term) {
                gview().windowManager.open(term ,"<br><b><div style='padding:3px;'>" + gview().lastLoad.length + " objects found for term \"" + term + "\".</div></b>(<span style=\"font-size:12px;padding:3px;\">&nbsp;Hover over the symbol to show the objects location)</span><br>" + gview().annotationArrayToList(gview().lastLoad));
           }

           if (gview().zoomPaneActive()) {
              gview().zoomPane.refresh();
           }
           hide(gview().loadingBar);
        }

        var errorFunc = function(status) {
            alert("An error occured in fetch of data. Server returned stats code " + status);
            hide(gview().loadingBar);
        }

        xml.async( func );
        xml.onerror( errorFunc );
        xml.parse();
      }catch (e) {
          alert("Error: " + e + " could not load objects");    
      }
    }

    //loads jklparsexml data object representing banding and chromosomes into the viewer
    this.loadBandData = function (data) {
        if (!data.genome.chromosome.length) {
            var obj1 = data.genome.chromosome;
            data.genome.chromosome = new Array(1);
            data.genome.chromosome[0] = obj1;
        }

        for (i=0; i< data.genome.chromosome.length; i++) {
            var chr = data.genome.chromosome[i];
            this.addChromosome(chr.index, new Chromosome(chr.number));

            if (!chr.band.length) {
                var obj = chr.band;
                chr.band = new Array(1);
                chr.band[0] = obj;
            }

            for (var j=0; j< chr.band.length; j++) {
                var band = chr.band[j];

                //this viewer supports files from the flash gviewer.  must convert flash color codes
                if (band.color && band.color.substring(0,2) == "0x") {
                    band.color = "#" + band.color.substring(2);
                }
                this.getChromosome(chr.number).addBand(new Band(band.name,band.start,band.end,band.stain, band.color));
            }
        }
        this.render();
    }

    //Retrieves xml document containing chromosome definitions and loads into viewer
    this.loadBands = function(url, species) {
        this.init();
        
        this.bandURL = url;

        if (!species) {
            species = "3";
        }

        this.species = species;
        var xml = new JKL.ParseXML( url );

        var errorFunc = function(status) {
            alert("An error occured in load of banding data. Server returned stats code " + status);
        }

        xml.onerror(errorFunc);
        var data = xml.parse();
        gview().loadBandData(data);
    }

    //Visually highlights an object in the viewer
    this.highlight = function(chrNumber, annotName, color) {
        if (!color) color = "red";

        var chr = this.getChromosome(chrNumber);
        for (var i=0; i< chr.annotations.length; i++) {
            var annot = chr.annotations[i];
            if (annot.div.style && annot.name == annotName) {
                annot.div.style.lastBorder = annot.div.style.border;                
                annot.div.style.border= this.highlightBorderWidth + "px solid " + color;

                if (document.all) {
                    annot.div.style.width= parseInt(annot.div.style.width) + (this.highlightBorderWidth * 2);
                    annot.div.style.height = parseInt(annot.div.style.height) + (this.highlightBorderWidth * 2);
                }

                annot.div.style.marginLeft = (this.highlightBorderWidth * -1);
                annot.div.style.marginTop = (this.highlightBorderWidth * -1);
                bringToFront(annot.div);

                return;
            }
        }
    }

    //Removes highlight from an object in the viewer
    this.lowlight = function(chrNumber, annotName) {
        var chr = this.getChromosome(chrNumber);
        for (var i=0; i< chr.annotations.length; i++) {
            var annot = chr.annotations[i];
            if (annot.div.style && annot.name == annotName) {

                if (annot.div.style.lastBorder) {
                    annot.div.style.border = annot.div.style.lastBorder;
                }else {
                    annot.div.style.border= "0px solid red";
                }
                
                if (document.all) {
                    annot.div.style.width= parseInt(annot.div.style.width) - (this.highlightBorderWidth * 2);
                    annot.div.style.height = parseInt(annot.div.style.height) - (this.highlightBorderWidth * 2);
                }

                if (parseInt(annot.div.style.borderWidth) == 0) {
                    annot.div.style.marginLeft = 0;
                    annot.div.style.marginTop = 0;
                }

                if (this.zoomPaneActive() && this.isActiveChr(chrNumber)) {
                    this.zoomPane.lowlight(annot);
                }

                return;
            }
        }
    }

    //returns true if the zoom pane is open
    this.zoomPaneActive = function() {
        return (this.zoomPane && this.zoomPane.chr && this.chr);
    }

    //adds a zoom pane to the viewer
    this.addZoomPane = function(divId, height, width) {
        this.zoomPane = new ZoomPane(divId, height, width, this);
    }

    //add a chromosome to the viewer
    this.addChromosome = function(index, chromosome) {
            this.chromosomes[index] =  chromosome;
            this.chromosomeIndexXref[chromosome.number] = index;
    }

    //visually highlights a chromosome
    this.highlightChromosome = function (chr) {
        chr.div.style.borderRight = "1px solid red";
        chr.div.style.borderLeft = "1px solid red";
    }

    //removes highlight from a chromosome
    this.lowlightChromosome = function (chr) {
        chr.div.style.borderRight = "1px solid black";
        chr.div.style.borderLeft = "1px solid black";
    }

    //removes all active sliders
    this.clearSliders = function() {
        for (i=1; i<this.chromosomes.length; i++) {
            this.lowlightChromosome(this.chromosomes[i]);
            this.chromosomes[i].slider.hide();
        }
    }

    //returns a chromosome for name passed in
    this.getChromosome = function(chromosomeNumber) {
        return this.chromosomes[this.chromosomeIndexXref[chromosomeNumber]];
    }

    //sets the scale ratio
    this.setScaleRatio = function() {
        this.scaleRatio = (this.pixelHeight - this.padFactor) / this.getLongestChromosome().length;
    }

    //creates a mapping between an object and div
    this.relate= function(obj,div) {
        obj.div = div;
        div.obj = obj;
    }

    //renders the viewer
    this.render = function() {
        this.setScaleRatio();

        this.regionWidth = Math.round((this.pixelWidth) / this.chromosomes.length);

        if (!this.chromosomeWidth) {
            this.chromosomeWidth = Math.round(this.regionWidth / 3);
        }

        var whiteSpace = (this.annotationPadding * this.annotationTypes.length) + (this.regionPadding * 2);

        if (!this.annotationWidth) {
            this.annotationWidth = Math.floor((Math.round(this.chromosomeWidth * 2) - whiteSpace) / this.annotationTypes.length);
        }

        for (i=1; i<this.chromosomes.length; i++) {
            var chr = this.chromosomes[i];

            var wrapper = appendDiv(this.vid + "wrap", "chr-wrapper", this.canvas);
            wrapper.innerHTML = chr.name + "<br>";

            var topBand = appendDiv(this.vid + "tb", chr.bands[0].stain, wrapper);
            topBand.style.width = this.chromosomeWidth + 2;
            topBand.innerHTML = "<img  width=" + topBand.style.width + " src='" + this.imagePath + "/roundedTop.png' class='roundedImage'/>";

            var cdiv = appendDiv(this.vid + "_c_" + chr.number, "chr", wrapper);
            cdiv.style.height=0;
            this.relate(chr,cdiv);

            cdiv.offsetParent.style.left=(((i - 1) * this.regionWidth) + 12);
            cdiv.style.width = this.chromosomeWidth;

            chr.slider = new Slider(chr);
            chr.slider.div.style.left = (this.regionPadding + 1) * -1;
            chr.slider.div.style.width = this.regionWidth;
            chr.slider.div.style.height = 0;
            this.relate(chr.slider, chr.slider.div);

            cdiv.onclick = gviewer_chromosome_clickEvent;
            cdiv.onmouseover = gviewer_chromosome_mouseOverEvent;
            cdiv.onmouseout = gviewer_chromosome_mouseOutEvent;
            chr.slider.onmousemove=gviewer_object_mouseMoveEvent;

            var foundP = false;
            var foundQ = false;
            for (j=0;j<chr.bands.length; j++) {
                var band   = chr.bands[j];
                
                var bdiv = appendDiv(cdiv.id + "b" + j, band.stain,cdiv);
                this.relate(band, bdiv);

                bdiv.style.width = this.chromosomeWidth;
                bdiv.style.height= Math.round((band.end - band.start) * this.scaleRatio);
                cdiv.style.height = (parseInt(cdiv.style.height) + parseInt(bdiv.style.height));
                bdiv.onmousemove = gviewer_object_mouseMoveEvent;

                if (band.color) {
                    bdiv.style.backgroundColor = band.color;
                }

                if (!foundP && band.name.substring(0,1).toLowerCase() == "p") {
                    foundP = true;
                }else if (foundP && !foundQ && band.name.substring(0,1).toLowerCase() == "q") {
                    var lc = appendDiv(cdiv.id + "lc" + j, "centromere-left",cdiv);
                    var rc = appendDiv(cdiv.id + "rc" + j, "centromere-right",cdiv);

                    lc.style.height = this.centromereLength;
                    lc.style.top = (getTop(bdiv) - getTop(cdiv) - (Math.round(parseInt(lc.style.height) / 2)));
                    rc.style.height = lc.style.height;
                    rc.style.top = lc.style.top;

                    if (document.all) {
                        rc.style.width = Math.floor(this.chromosomeWidth / 2);
                        rc.style.left= this.chromosomeWidth - parseInt(rc.style.width) + 1;
                    }else {
                        rc.style.width = Math.floor(this.chromosomeWidth / 3);
                        rc.style.left= this.chromosomeWidth - parseInt(rc.style.width) ;
                    }

                    lc.style.width=rc.style.width;

                    lc.style.left="-1px";
                    foundQ = true;
                }

                if (j== (chr.bands.length -1)) {
                    bdiv.style.border = "0px solid white";
                }
            }

            var bottomBand = appendDiv(this.vid + "bottom", chr.bands[chr.bands.length-1].stain, wrapper);
            bottomBand.style.width = topBand.style.width;
            bottomBand.innerHTML = "<img width='" + bottomBand.style.width + "' src='" + this.imagePath + "/roundedBottom.png' class='roundedImage'/>";

          }
    }

    //renders an object in the viewer
    this.renderAnnotation = function(chr, annot) {
        var adiv = document.getElementById(chr.div.id + "_" + annot.name);

        adiv = appendDiv(chr.div.id + "_" + annot.name, annot.type, chr.div);
        this.relate(annot,adiv);
        adiv.style.width = this.annotationWidth;

        var len = Math.ceil((annot.end - annot.start) * this.scaleRatio);
        adiv.style.top = Math.round(parseInt(annot.start * this.scaleRatio));

        if (len < 4) {
            len=4;
        }

        for (i=0; i< this.annotationTypes.length; i++) {
            if (this.annotationTypes[i] == annot.type) {
                adiv.style.height=len;
                adiv.style.left = this.chromosomeWidth + this.regionPadding + ((this.annotationWidth + this.annotationPadding) * i);
            }
        }

        adiv.style.backgroundColor = annot.color;
        adiv.oncontextmenu=window_contextMenuEvent;
        adiv.onmousemove = gviewer_object_mouseMoveEvent;
    }

    //freezes the slider and zoom pane
    this.freeze = function() {
        this.status("...Slider Locked...");
        this.chr.slider.freeze();
        this.frozen = true;
    }

    //un-freezes the slider and zoom pane
    this.thaw = function() {
        this.status("");
        this.chr.slider.thaw();
        this.frozen = false;
    }

    //turns a track on or off
    this.toggleAnnotation = function(checked, type)  {
        for (var i=1; i< this.chromosomes.length; i++) {
            for (var j=0; j< this.chromosomes[i].annotations.length; j++) {
                if (this.chromosomes[i].annotations[j].type == type) {
                    if (checked) {
                        this.chromosomes[i].annotations[j].div.style.display = "block";
                    }else {
                        this.chromosomes[i].annotations[j].div.style.display = "none";
                    }
                }
            }
        }
    }

    this.zoomIn = function () {
        if (this.zoomPaneActive()) {
            this.zoomPane.zoomIn();
        }
        this.moveTo(this.chr,this.y);
    }

    this.zoomOut = function () {
        if (this.zoomPaneActive()) {
            this.zoomPane.zoomOut();
        }
        this.moveTo(this.chr, this.y);
    }

    //sets a new location for the slider and zoom pane
    this.moveTo = function(chr, y) {

        if (!chr || !y) {
            return;
        }

        this.chr = chr;
        this.y = y;
        var slider = chr.slider.div;

        var len = chr.getLength(this.scaleRatio);
        sliderHeight = Math.round(len * (this.zoomPane.width / chr.getLength(this.zoomPane.scaleRatio)));
        slider.style.height = checkMinMax(2, len, sliderHeight);
        mouseY = parseInt(y) - parseInt(getTop(chr.div)) + getWindowScroll();

        if (mouseY < (parseInt(slider.style.height) / 2)){
            slider.style.top=0;
        }else if (mouseY > (len - (parseInt(slider.style.height) / 2))) {
            slider.style.top= len- parseInt(slider.style.height);
        }else {
            slider.style.top=parseInt(mouseY - parseInt(slider.style.height) / 2);
        }

        if (slider.style.visibility != "visible") {

            if (this.zoomPane) {
                this.zoomPane.draw(chr);
            }
            this.clearSliders();
            chr.slider.show();

            this.highlightChromosome(chr);
            this.thaw();
        }

        this.zoomPane.moveTo(chr,mouseY);
        if (this.zoomOptions) this.zoomOptions.style.display="block";

        this.writePosition(this.positionDiv);
    }

    //displays base pair location information
    this.writePosition = function(div) {
        div.innerHTML = "&nbsp;Chromosome&nbsp;" + this.chr.number + "&nbsp;(&nbsp;" + this.zoomPane.getWindowStartBP() + "&nbsp;..&nbsp;" + this.zoomPane.getWindowEndBP() + "&nbsp;)&nbsp;";
    }

    
    this.synchSliderToZoomPane = function(zoomPane) {
        this.y=Math.round((parseInt(zoomPane.div.scrollLeft) / zoomPane.scaleRatio) * this.scaleRatio);
        this.chr.slider.div.style.top = this.y;
    }

    this.add = function() {
        this.windowManager.open("Add Objects To the Viewer","<br><b>What type of object would you like to add?</b><br><ul><li><a href='javascript:gview().requestSearchTerm(\"gene\");void(0);'>Gene</a><li><a href='javascript:gview().requestSearchTerm(\"qtl\");void(0);'>QTL</a><li><a href='javascript:gview().requestSearchTerm(\"strain\");void(0);'>Strain</a><li><a href='javascript:gview().requestOntologyTerm();void(0);'>Ontology Term Annotations</a></ul>");
        return;
    }

    this.addObjectsByURL = function(url,  color, term) {
        this.windowManager.closeLast();
        if (!term) {
            term="Search Result";
        }
        
        this.loadAnnotations(url,  color, term);

        if (this.zoomPaneActive()) {
            this.zoomPane.refresh();
        }
        this.clearStatus();
    }


    this.annotationArrayToList = function(loaded) {
        var output = "<ul>";
        for (var i=0; i< loaded.length; i++) {
            if (loaded[i] && loaded[i].chr) {
                output += "<li><a href='javascript:gview().moveTo(gview().getChromosome(\"" + loaded[i].chr.number + "\"),\"" + (getTop(loaded[i].div) - getWindowScroll()) + "\");gview().lowlight(\"" + loaded[i].chr.number + "\",\"" + loaded[i].name + "\");gview().windowManager.closeLast();void(0);' onMouseOut='gview().lowlight(\"" + loaded[i].chr.number + "\",\"" + loaded[i].name + "\")' onMouseOver='javascript:gview().highlight(\"" + loaded[i].chr.number + "\",\"" + loaded[i].name + "\")'>" + loaded[i].name + "</a><br>";
            }
        }
        output +="</ul>";
        return output;
    }

    this.display = function() {
        var out = ""
        var count = 0;
        for (var i=1; i<this.chromosomes.length; i++) {
            var chr = this.chromosomes[i];
            if (chr.annotations.length > 0) {
                out += "<br><b>Chromosome " + chr.number + "</b>" + this.annotationArrayToList(chr.annotations)
                count += chr.annotations.length;
            }
        }

        this.windowManager.open("List All Annotations","<br><b><div style='padding:3px;'>" + count + " objects loaded.</div></b>(<span style=\"font-size:12px;padding:3px;\">&nbsp;Hover over the symbol to show the objects location)</span><br>" + out);
        this.clearStatus();

    }

    this.openGenomeBrowserForObject = function (name) {
        var url = this.genomeBrowserURL + "&loc=" + name;
        window.open(url);        
    }

    this.openGenomeBrowser = function() {
        if (!gview().chr) {
            alert("You must select a chromosome to use this feature");
            return;
        }

        var url = this.genomeBrowserURL + "&loc=Chr" + gview().chr.number + "%3A" + gview().zoomPane.getWindowStartBP() + ".." + gview().zoomPane.getWindowEndBP();
        for (var i=0; i< gview().chr.annotations.length; i++) {
            var annot = gview().chr.annotations[i];
            url = url + "&add=chr" + gview().chr.number + "+GViewer+" + annot.name + "+chr" + gview().chr.number + ":"+ annot.start + ".." + annot.end;
        }
        window.open(url);
    }

    this.displayExportList = function() {
        this.windowManager.open("Export Annotation File","<br><b>What type of file would you like?</b><br><ul><li><a href='javascript:gview().exportData(\"or\");void(0);'>All Objects</a><li><a href='javascript:gview().exportData(\"and\");void(0);'>Shared Objects</a><br><span style='font-size:11;'>(Objects in yellow)</span><li><a href='javascript:gview().exportData(\"xor\");void(0);'>Unique Objects</a><br><span style='font-size:11;'>(Objects NOT in yellow)</span></ul>");
        return;
    }

    //exports and annotations file.  Requires the use of a server.
    this.exportData = function(type) {
        this.status("Exporting Annotations");

        var f = document.createElement("form");
        document.body.appendChild(f);
        f.action = this.exportURL;
        f.method = "POST";
        f.target = "_blank";

        appendInput("hidden", "fmt", "1", f);

        var count = 0;
        for (var i=1; i<this.chromosomes.length; i++) {
            var chr = this.chromosomes[i];
            for (var j=0; j< chr.annotations.length; j++) {
                var annot = chr.annotations[j];

                if (type == "or" || (type=="xor" && !annot.conflict) || (type=="and" && annot.conflict)) {                
                    appendInput("hidden", "v" + count + "_0", annot.name, f);
                    appendInput("hidden", "v" + count + "_1", chr.number, f);
                    appendInput("hidden", "v" + count + "_2", annot.start, f);
                    appendInput("hidden", "v" + count + "_3", annot.end, f);
                    appendInput("hidden", "v" + count + "_4", annot.type, f);
                    count++;
                }
            }
        }

        appendInput("hidden", "height", count, f);
        appendInput("hidden", "width", "5", f);

        f.submit();
    }

    this.closeZoomPane = function() {
        this.chr = null;
        this.zoomPane.chr= null;
        this.clearStatus();
        this.zoomPane.div.style.display = "none";
        this.clearSliders();

        if (this.zoomOptions) {
            this.zoomOptions.style.display="none";
        }
    }

//--------------------------------------------------------------------------
// The following functions are used by the rgd web site.  They should be removed from this file.
// Similar funtionality for other web sites could replace these  THESE FUNCTIONS ARE NOT USED IF enableAdd IS SET TO FALSE
// -------------------------------------------------------------------------
    this.addOntologyAnnotations = function(color, term) {
        this.windowManager.closeLast();

        if (term && term != "") {
            this.windowManager.openExternal("Search: " + term ,"/rgdweb/gviewer/getXmlTool.html?gviewer=addObjTerm&term[]=" + term + "&go[]=CC,MF,BP,RDO,NBO,PW,MP,CMO,MMO,XCO,RS,VT,CHEBI&speciesType=" + this.species + "&color=" + escape(color));
         }

         if (this.zoomPaneActive()) {
             this.zoomPane.refresh();
         }
         this.clearStatus();
    }

    this.requestOntologyTerm = function () {
        this.windowManager.closeLast();
        var colorSelect =' <select name="gvcolor"><option value="#000080">Navy</option><option value="#00FFFF">Cyan</option><option value="#7e131d">Crimson</option><option value="#808000">Olive</option><option value="#000080">Navy</option><option value="#545454">Grey</option><option value="#0000FF">Blue</option><option value="#080800">Teal</option><option value="#5C4033">Brown</option><option value="#D2B48C">Tan</option><option value="#00FF00">Green</option></select>';
        this.windowManager.open("Enter Keyword","<br><b>Enter an ontology search term</b><br><br><form name='gvform' onSubmit='return false;'><table border=0><tr><td>Term:</td><td><input type='text' size='30' name='gvterm'></td></tr><tr><td>Color:</td><td>" + colorSelect + "</td></tr><tr><td align='center' colspan='2'><br><input type='submit' value='submit' onClick='gview().addOntologyAnnotations(this.form.gvcolor[this.form.gvcolor.selectedIndex].value,this.form.gvterm.value)'></td></tr></table></form>");
        return;
    }

    this.requestSearchTerm = function (type) {
        this.windowManager.closeLast();
        var colorSelect =' <select name="gvcolor"><option value="#000080">Navy</option><option value="#00FFFF">Cyan</option><option value="#7e131d">Crimson</option><option value="#808000">Olive</option><option value="#000080">Navy</option><option value="#545454">Grey</option><option value="#0000FF">Blue</option><option value="#080800">Teal</option><option value="#5C4033">Brown</option><option value="#D2B48C">Tan</option><option value="#00FF00">Green</option></select>';
        this.windowManager.open("Enter Keyword","<br><b>Enter a search term or " + type + " symbol</b><br><br><form name='gvform' onSubmit='return false;'><table border=0><tr><td>Keyword:</td><td><input type='text' size='30' name='gvterm'></td></tr><tr><td>Color:</td><td>" + colorSelect + "</td></tr><tr><td align='center' colspan='2'><br><input type='submit' value='submit' onClick='gview().addObjects(\"" + type + "\",this.form.gvcolor[this.form.gvcolor.selectedIndex].value,this.form.gvterm.value)'></td></tr></table></form>");
        return;
    }

    this.addObjects = function(type, color, term) {
        this.windowManager.closeLast();
        if (term && term != "") {
             this.status("Loading Annotations...  (This may take a moment)");
            var dest = "/rgdweb/search/" + type + "s.html?term=" + term + "&gview=1&speciesType=" + this.species + "&fmt=6";
            this.loadAnnotations(dest, color, term);
         }

         if (this.zoomPaneActive()) {
             this.zoomPane.refresh();
         }
         this.clearStatus();
    }
}


