/***********************************************
 * DHTML Window Widget- � Dynamic Drive (www.dynamicdrive.com)
 * This notice must stay intact for legal use.
 * Visit http://www.dynamicdrive.com/ for full source code
 ***********************************************/

var gviewerRef = null;

//returns the current gviewer reference
var gview = function (id) {

    if (document.getElementById(id) != null) {
        return document.getElementById(id).gviewer;
    }

    return gviewerRef;
}

var gviewForEvent = function (e) {
    if (e != null) {

        var obj = getTarget(e);

        if (obj.gviewer != null) {
            gviewerRef=obj.gviewer;
            return obj.gviewer;
        }
    }

    return gviewerRef;

}


function Gviewer(viewerId, height, width, mapKey) {

    gviewerRef = this;

    document.getElementById(viewerId).gviewer = this;

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
    this.colorScheme["gene"] = ["#7e131d","#f37200"];
    this.colorScheme["qtl"] = ["#3294d3", "#f37200"];
    this.colorScheme["sslp"] = ["#76ac1a", "#f37200"];
    this.colorScheme["snp"] = ["purple","#f37200"];
    this.colorScheme["probeset"] = ["#7e131d","#f37200"];
    this.colorScheme["eqtl"] = ["#7e131d","#f37200"];
    this.colorScheme["strain"] = ["#76ac1a","#f37200"];
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
    if(mapKey==1701) {
        this.pixelHeight = 300;
    }else {
        this.pixelHeight=height;
    }
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
    this.mapKey=mapKey;

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
        //    this.div.onmouseover = gviewer_mouseOverEvent;
        //   this.div.onmouseout = gviewer_mouseOutEvent;
        this.div.style.width = this.pixelWidth;
        this.div.obj = this;

        this.loadingBar = appendDiv(this.vid + "loadingBar", "loading-bar", this.div);
        this.canvas = appendDiv(this.vid + "canvas", "canvas", this.div);
        //this.canvas.style.height = (this.pixelHeight - 46);
        this.statusBar = appendDiv(this.vid + "status", "status-bar", this.div);
        this.positionDiv = appendDiv(this.vid + "position", "position-bar", this.div);
        var controlBar = appendDiv(this.vid + "controlBar", "control-bar", this.div);
        //  var jbrowser= appendDiv(this.vid+"jbrowseWrapper", "jbrowseWrapper", this.div);

        this.canvas.style.height = (this.pixelHeight - 46);

        this.loadingBar.innerHTML = "&nbsp;Loading Annotations...&nbsp;";
        console.log("mapKey:"+ this.mapKey);
        if (this.mapKey!=1701) {
           var jbrowser= appendDiv(this.vid+"jbrowseWrapper", "jbrowseWrapper", this.div);
        var cStr = '<table width="100%" border="0" cellpadding="0" cellspacing="0" style="font-size:10px;"><tr><td>';
        cStr += '<strong style="color:blue">' + this.genomeBrowserName + ' <span id="chrNum">(Chromosome 1)</span></strong>';
        cStr += '</td></tr></table>';

        controlBar.innerHTML = cStr;

        var url = this.genomeBrowserURL + "&loc=Chr1&highlight=&tracklist=0&nav=0&overview=0";
     jbrowser.innerHTML="";
        var iframe = document.createElement("IFRAME");
        iframe.setAttribute("width", 600);
        iframe.setAttribute("height", 200);
        iframe.setAttribute("src", url);
   jbrowser.appendChild(iframe);
    }
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

            var xml = new JKL.ParseXML( url );
            var func = function ( data , id) {                  // define call back function

                gview(id).loadAnnotationData(data, color);

                if (term) {
                    gview(id).windowManager.open(term ,"<br><b><div style='padding:3px;'>" + gview(id).lastLoad.length + " objects found for term \"" + term + "\".</div></b>(<span style=\"font-size:12px;padding:3px;\">&nbsp;Hover over the symbol to show the objects location)</span><br>" + gview(id).annotationArrayToList(gview(id).lastLoad));
                }

                if (gview().zoomPaneActive()) {
                    gview(id).zoomPane.refresh();
                }
                hide(gview(id).loadingBar);
            }

            var errorFunc = function(status) {
                alert("An error occured in fetch of data. Server returned stats code " + status);
                hide(gview().loadingBar);
            }

            xml.async( func , gview().div.id);
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
        if (!species) {
            species = "3";
        }
        this.species = species;
        this.init();

        this.bandURL = url;




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
        // chr.div.style.borderTop = "1px solid red";
        //  chr.div.style.borderBottom = "25px solid red";
    }

    //removes highlight from a chromosome
    this.lowlightChromosome = function (chr) {
        // chr.div.style.borderBottom="0px solid black";
        //chr.div.style.borderRight = "0px solid black";
        //chr.div.style.borderLeft = "0px solid black";
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

           var cdiv = appendDiv(this.vid + "_c_" + chr.number, "chr", wrapper);
            cdiv.style.height=0;
           this.relate(chr,cdiv);

            cdiv.style.border="0px solid black";
            cdiv.style.borderRadius="10px";

            cdiv.offsetParent.style.left=(((i - 1) * this.regionWidth) + 12);
            cdiv.style.width = this.chromosomeWidth;
            if(chr.number==1){
                  cdiv.style.border="6px solid dodgerblue";
            }
            cdiv.onclick = gviewer_chromosome_clickEvent;


            var foundP = false;
            var foundQ = false;
            var bdiv2 = null;

            for (j=0;j<chr.bands.length; j++) {



                var band   = chr.bands[j];

                var bdiv = appendDiv(cdiv.id + "b" + j, band.stain,cdiv);
                this.relate(band, bdiv);

                bdiv.style.width = this.chromosomeWidth;

                bdiv.style.height= Math.round((band.end - band.start) * this.scaleRatio);
                cdiv.style.height = (parseInt(cdiv.style.height) + parseInt(bdiv.style.height));
                bdiv.onmousemove = gviewer_object_mouseMoveEvent;

                bdiv.style.borderLeft="1px solid black"
                bdiv.style.borderRight="1px solid black"


                if (band.color) {
                    bdiv.style.backgroundColor = band.color;
                }

                if (!foundP && band.name.substring(0,1).toLowerCase() == "p") {
                    foundP = true;
                }else if (foundP && !foundQ && band.name.substring(0,1).toLowerCase() == "q") {

                    bdiv.style.borderTopLeftRadius="10px";
                    bdiv.style.borderTopRightRadius="10px";
                    bdiv2.style.borderBottomLeftRadius="10px";
                    bdiv2.style.borderBottomRightRadius="10px";

                    foundQ = true;
                }


                if (j=== (chr.bands.length -1)) {
                    bdiv.style.borderBottomLeftRadius="10px";
                    bdiv.style.borderBottomRightRadius="10px";
                    // bdiv.style.borderBottom = "2px solid black";
                    bdiv.style.borderBottom="1px solid black";

                }

                if (j===0) {
                    //bdiv.style.borderTop = "2px solid black";
                    bdiv.style.borderTopLeftRadius="10px";
                    bdiv.style.borderTopRightRadius="10px";
                    bdiv.style.borderTop="1px solid black";
                }
                bdiv2 = bdiv;


            }

            /*
             var bottomBand = appendDiv(this.vid + "bottom", chr.bands[chr.bands.length-1].stain, wrapper);
             bottomBand.style.width = topBand.style.width;
             bottomBand.innerHTML = "<img width='" + bottomBand.style.width + "' src='" + this.imagePath + "/roundedBottom.png' class='roundedImage'/>";
             */
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
            if (this.annotationTypes[i] === annot.type) {
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
                if (this.chromosomes[i].annotations[j].type === type) {
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

    this.highlights= new Array();

    this.clearHighlights = function() {
        for (i=0; i< this.highlights.length; i++) {
            this.highlights[i].style.display="none";
        }
        this.highlights=new Array();

    }

    this.highlightRegion = function(chromosome, start, stop) {

        chr = this.chromosomes[chromosome];

        var div = document.createElement("div");
        div.style.backgroundColor="orange";
        div.style.height= ((stop - start) * this.scaleRatio);
        div.style.width=20;
        div.style.top = Math.round(start * this.scaleRatio);

        div.style.position="absolute";

        this.highlights[this.highlights.length] = div;
        chr.div.appendChild(div);

    }


    this.getSynteny = function(chr, start, stop) {
        $.get('synteny.jsp?chr=' + chr + '&start=' + start + '&stop=' + stop, function(data) {
            var obj = eval(data);

            var curChr = '-1';
            var curStart=-1;
            var curStop=-1


            for (i=0; i< obj.length; i++) {
                gview("gviewer2").highlightRegion(obj[i].chromosome, obj[i].start, obj[i].stop);
            }


        });


    }


    this.setPosition = function (chromosome, start, stop) {

        chr = this.chromosomes[chromosome];
           d.out(this.scaleRatio);

         }


    //sets a new location for the slider and zoom pane
    this.moveTo = function(chr, y) {

        // d.out(y);

        if (!chr || !y) {
            return;
        }

        this.chr = chr;
        this.y = y;

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

        var url = this.genomeBrowserURL + "&loc=Chr" + this.chr;
     window.open(url);
    }

    this.openGenomeBrowser = function() {
     
        if (!gview().chr) {
            alert("You must select a chromosome to use this feature");
            return;
        }

      var url = this.genomeBrowserURL + "&loc=Chr" + gview().chr+"&highlight=&tracklist=0&nav=0&overview=0";
      var $jbrowseWrapper=document.getElementById("gviewerjbrowseWrapper");
        $jbrowseWrapper.innerHTML="";
        var iframe=document.createElement("IFRAME");
        iframe.setAttribute("width",600);
        iframe.setAttribute("height", 200);
        iframe.setAttribute("src", url);
      $jbrowseWrapper.appendChild(iframe);
      // window.open(url);
    }

    this.displayExportList = function() {
        alert("working");
        this.windowManager.open("Export Annotation File","<br><b>What type of file would you like?</b><br><ul><li><a href='javascript:gview().exportData(\"or\");void(0);'>All Objects</a><li><a href='javascript:gview().exportData(\"and\");void(0);'>Shared Objects</a><br><span style='font-size:11px'>(Objects in yellow)</span><li><a href='javascript:gview().exportData(\"xor\");void(0);'>Unique Objects</a><br><span style='font-size:11px;'>(Objects NOT in yellow)</span></ul>");
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
//            this.windowManager.openExternal("Search: " + term ,"/plf/plfRGD/?module=gviewer&func=getxml&term[]=" + term + "&gview=1&go[]=4&do[]=7&bo[]=8&po[]=5&wo[]=6&cmo[]=10&mmo[]=11&xco[]=12&rs[]=13&vt[]=14&chebi[]=15&speciesType=" + this.species + "&color=" + escape(color));
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


