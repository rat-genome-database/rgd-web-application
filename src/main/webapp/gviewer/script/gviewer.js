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
    //enables use of the mouse wheel to control zoom (disabled by default - too aggressive on trackpads)
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
        
        var btnStyle = 'display:inline-block; padding:3px 8px; margin:2px 3px; border-radius:3px; font-size:11px; font-weight:600; text-decoration:none; cursor:pointer; border:1px solid ';
        var btnBlue = btnStyle + '#3274a5; background:#3274a5; color:#fff;';
        var btnGreen = btnStyle + '#5a9e3f; background:#5a9e3f; color:#fff;';
        var btnGray = btnStyle + '#888; background:#6c757d; color:#fff;';
        var btnRed = btnStyle + '#c9302c; background:#c9302c; color:#fff;';
        var btnOutline = btnStyle + '#3274a5; background:#fff; color:#3274a5;';

        var cStr = '<div style="display:flex; flex-wrap:wrap; align-items:center; justify-content:space-between; padding:4px 6px;">';
        cStr += '<div>';
        cStr += '<a href="javascript: gview().display()" style="' + btnBlue + '">List All Objects</a>';
        cStr += '<a href="javascript: gview().exportCSV()" style="' + btnGreen + '">CSV Export</a>';
        cStr += '<a href="javascript: gview().exportImage()" style="' + btnGreen + '">Export Image</a>';
        cStr += '<a href="javascript: gview().getShareableURL()" style="' + btnOutline + '">Share</a>';
        cStr += prereq('<a href="javascript: gview().add()" style="' + btnOutline + '">Add Objects</a>', this.enableAdd);
        cStr += '<a href="javascript: gview().reset()" style="' + btnRed + '">Clear</a>';
        cStr += '</div>';
        cStr += '<div id="gview_zoomOptions" style="display:none;">';
        cStr += '<a href="javascript: gview().zoomIn()" style="' + btnBlue + '">Zoom In</a>';
        cStr += '<a href="javascript: gview().zoomOut()" style="' + btnBlue + '">Zoom Out</a>';
        cStr += prereq('<a href="javascript: gview().openGenomeBrowser()" style="' + btnGreen + '">Send to ' + this.genomeBrowserName + '</a>',this.genomeBrowserURL);
        cStr += '<a href="javascript: gview().closeZoomPane()" style="' + btnGray + '">Close Zoom</a>';
        cStr += '</div></div>';

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

            $.getJSON(url, function(data) {
                gview().loadAnnotationData(data, color);

                if (term) {
                    gview().windowManager.open(term ,"<br><b><div style='padding:3px;'>" + gview().lastLoad.length + " objects found for term \"" + term + "\".</div></b>(<span style=\"font-size:12px;padding:3px;\">&nbsp;Hover over the symbol to show the objects location)</span><br>" + gview().annotationArrayToList(gview().lastLoad));
                }

                if (gview().zoomPaneActive()) {
                    gview().zoomPane.refresh();
                }
                hide(gview().loadingBar);
                hideLoadingOverlay();
            }).fail(function(jqXHR) {
                alert("An error occurred in fetch of data. Server returned status code " + jqXHR.status);
                hide(gview().loadingBar);
                hideLoadingOverlay();
            });
        }catch (e) {
            alert("Error: " + e + " could not load objects");
        }
    }



    //retrieves data from url via POST and loads objects into the viewer
    //this endpoint returns XML, so we parse it into the expected JSON-like structure
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

            $.ajax({
                url: parts[0],
                type: "POST",
                data: parts[1],
                dataType: "xml",
                success: function(xml) {
                    var data = gview().parseAnnotationXml(xml);
                    gview().loadAnnotationData(data, color);

                    if (term) {
                        gview().windowManager.open(term ,"<br><b><div style='padding:3px;'>" + gview().lastLoad.length + " objects found for term \"" + term + "\".</div></b>(<span style=\"font-size:12px;padding:3px;\">&nbsp;Hover over the symbol to show the objects location)</span><br>" + gview().annotationArrayToList(gview().lastLoad));
                    }

                    if (gview().zoomPaneActive()) {
                        gview().zoomPane.refresh();
                    }
                    hide(gview().loadingBar);
                hideLoadingOverlay();
                },
                error: function(jqXHR) {
                    alert("An error occurred in fetch of data. Server returned status code " + jqXHR.status);
                    hide(gview().loadingBar);
                hideLoadingOverlay();
                }
            });
        }catch (e) {
            alert("Error: " + e + " could not load objects");
        }
    }

    //Parses annotation XML into the object format expected by loadAnnotationData
    this.parseAnnotationXml = function(xml) {
        var data = { genome: { feature: [] } };
        $(xml).find("feature").each(function() {
            data.genome.feature.push({
                chromosome: $(this).find("chromosome").text(),
                start: $(this).find("start").text(),
                end: $(this).find("end").text(),
                type: $(this).find("type").text(),
                label: $(this).find("label").text(),
                link: $(this).find("link").text(),
                color: $(this).find("color").text() || null
            });
        });
        return data;
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
        var self = this;

        $.ajax({
            url: url,
            dataType: "xml",
            async: false,
            success: function(xml) {
                var data = self.parseIdeoXml(xml);
                self.loadBandData(data);
            },
            error: function(jqXHR) {
                alert("An error occurred in load of banding data. Server returned status code " + jqXHR.status);
            }
        });
    }

    //Parses ideogram XML into the object format expected by loadBandData
    this.parseIdeoXml = function(xml) {
        var data = { genome: { chromosome: [] } };
        $(xml).find("chromosome").each(function() {
            var chr = {
                index: $(this).attr("index"),
                number: $(this).attr("number"),
                length: $(this).attr("length"),
                band: []
            };
            $(this).find("band").each(function() {
                chr.band.push({
                    name: $(this).find("name").text() || $(this).attr("name"),
                    start: $(this).find("start").text(),
                    end: $(this).find("end").text(),
                    stain: $(this).find("stain").text(),
                    color: $(this).find("color").text() || null
                });
            });
            data.genome.chromosome.push(chr);
        });
        return data;
    }

    //Visually highlights an object in the viewer
    this.highlight = function(chrNumber, annotName, color) {
        if (!color) color = "red";

        var chr = this.getChromosome(chrNumber);
        for (var i=0; i< chr.annotations.length; i++) {
            var annot = chr.annotations[i];
            if (annot.div && annot.name == annotName) {
                // SVG element - use stroke for highlight
                if (annot.div.setAttribute) {
                    annot.div._origStroke = annot.div.getAttribute("stroke") || "none";
                    annot.div.setAttribute("stroke", color);
                    annot.div.setAttribute("stroke-width", this.highlightBorderWidth);
                }
                return;
            }
        }
    }

    //Removes highlight from an object in the viewer
    this.lowlight = function(chrNumber, annotName) {
        var chr = this.getChromosome(chrNumber);
        for (var i=0; i< chr.annotations.length; i++) {
            var annot = chr.annotations[i];
            if (annot.div && annot.name == annotName) {
                if (annot.div.setAttribute) {
                    annot.div.setAttribute("stroke", annot.div._origStroke || "none");
                    annot.div.setAttribute("stroke-width", "0");
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
        var target = chr.outlinePath || chr.div;
        if (target && target.setAttribute) {
            target.setAttribute("stroke", "red");
            target.setAttribute("stroke-width", "2");
        }
    }

    //removes highlight from a chromosome
    this.lowlightChromosome = function (chr) {
        var target = chr.outlinePath || chr.div;
        if (target && target.setAttribute) {
            target.setAttribute("stroke", "#222");
            target.setAttribute("stroke-width", "1");
        }
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

    //renders the viewer using SVG
    this.render = function() {
        renderGenomeSVG(this);
    }

    //renders an annotation using SVG
    this.renderAnnotation = function(chr, annot) {
        renderAnnotationSVG(this, chr, annot);
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
                    var el = this.chromosomes[i].annotations[j].div;
                    if (el && el.setAttribute) {
                        el.setAttribute("visibility", checked ? "visible" : "hidden");
                    } else if (el && el.style) {
                        el.style.display = checked ? "block" : "none";
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

        // Use getBoundingClientRect for SVG elements, getTop for HTML elements
        var chrTop;
        if (chr.div && chr.div.getBoundingClientRect) {
            chrTop = chr.div.getBoundingClientRect().top + getWindowScroll();
        } else {
            chrTop = getTop(chr.div);
        }
        mouseY = parseInt(y) - parseInt(chrTop) + getWindowScroll();

        // Offset for SVG-based rendering (slider is in canvas div, not inside chr)
        var sliderOffsetY = chr._svgOffsetY || 0;

        if (mouseY < (parseInt(slider.style.height) / 2)){
            slider.style.top = sliderOffsetY + "px";
        }else if (mouseY > (len - (parseInt(slider.style.height) / 2))) {
            slider.style.top = (sliderOffsetY + len - parseInt(slider.style.height)) + "px";
        }else {
            slider.style.top = (sliderOffsetY + parseInt(mouseY - parseInt(slider.style.height) / 2)) + "px";
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
        var url = this.genomeBrowserURL + "&loc=" + encodeURIComponent(name);
        window.open(url);
    }

    this.openGenomeBrowser = function() {
        if (!gview().chr) {
            alert("You must select a chromosome to use this feature");
            return;
        }

        var loc = "chr" + gview().chr.number + ":" + gview().zoomPane.getWindowStartBP() + ".." + gview().zoomPane.getWindowEndBP();
        var url = this.genomeBrowserURL + "&loc=" + encodeURIComponent(loc);
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

    //Client-side CSV export - downloads directly without server round-trip
    this.exportCSV = function() {
        var csv = "Symbol,Chromosome,Start,End,Type\n";
        for (var i=1; i<this.chromosomes.length; i++) {
            var chr = this.chromosomes[i];
            for (var j=0; j< chr.annotations.length; j++) {
                var annot = chr.annotations[j];
                csv += '"' + annot.name + '",' + chr.number + ',' + annot.start + ',' + annot.end + ',' + annot.type + "\n";
            }
        }
        var blob = new Blob([csv], {type: "text/csv;charset=utf-8;"});
        var url = URL.createObjectURL(blob);
        var link = document.createElement("a");
        link.href = url;
        link.download = "gviewer_annotations.csv";
        link.click();
        URL.revokeObjectURL(url);
        this.status("CSV exported");
    }

    //Export the genome view as a PNG image
    this.exportImage = function() {
        var svgEl = this.svg;
        if (!svgEl) {
            alert("No genome view to export");
            return;
        }
        this.status("Exporting image...");
        var serializer = new XMLSerializer();
        var svgString = serializer.serializeToString(svgEl);
        // Add XML declaration and namespace
        if (svgString.indexOf('xmlns=') === -1) {
            svgString = svgString.replace('<svg', '<svg xmlns="http://www.w3.org/2000/svg"');
        }
        var canvas = document.createElement("canvas");
        canvas.width = svgEl.getAttribute("width") * 2;
        canvas.height = svgEl.getAttribute("height") * 2;
        var ctx = canvas.getContext("2d");
        ctx.scale(2, 2);
        var img = new Image();
        var blob = new Blob([svgString], {type: "image/svg+xml;charset=utf-8"});
        var url = URL.createObjectURL(blob);
        var self = this;
        img.onload = function() {
            ctx.fillStyle = "white";
            ctx.fillRect(0, 0, canvas.width, canvas.height);
            ctx.drawImage(img, 0, 0);
            URL.revokeObjectURL(url);
            var pngUrl = canvas.toDataURL("image/png");
            var link = document.createElement("a");
            link.href = pngUrl;
            link.download = "gviewer_genome.png";
            link.click();
            self.status("Image exported");
        };
        img.onerror = function() {
            // Fallback: offer SVG download
            var link = document.createElement("a");
            link.href = url;
            link.download = "gviewer_genome.svg";
            link.click();
            self.status("SVG exported");
        };
        img.src = url;
    }

    //Generate a shareable URL encoding the current search state
    this.getShareableURL = function() {
        var params = new URLSearchParams(window.location.search);
        var form = document.gviewerForm;
        if (form) {
            var formStr = getFormString(form);
            // Parse the form string and set as URL params
            var baseUrl = window.location.origin + window.location.pathname;
            var shareUrl = baseUrl + "?" + formStr + "&autorun=1";
            // Copy to clipboard
            if (navigator.clipboard) {
                navigator.clipboard.writeText(shareUrl).then(function() {
                    gview().status("Shareable URL copied to clipboard");
                });
            } else {
                prompt("Copy this URL to share:", shareUrl);
            }
        }
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
            showLoadingOverlay();
            var mapKey = this.mapKey || (document.getElementById('assemblyVersion') ? document.getElementById('assemblyVersion').value : '');
            var dest = "/rgdweb/gviewer/addObjects.html?type=" + encodeURIComponent(type)
                     + "&term=" + encodeURIComponent(term)
                     + "&mapKey=" + encodeURIComponent(mapKey);
            this.loadAnnotationsGET(dest, color, term);
        }

        if (this.zoomPaneActive()) {
            this.zoomPane.refresh();
        }
        this.clearStatus();
    }
}


