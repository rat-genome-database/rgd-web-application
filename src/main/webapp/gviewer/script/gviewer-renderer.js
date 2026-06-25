/**
 * SVG Renderer for GViewer - replaces DIV-based chromosome rendering with SVG
 */

var SVG_NS = "http://www.w3.org/2000/svg";

function createSVGElement(tag, attrs, parent) {
    var el = document.createElementNS(SVG_NS, tag);
    if (attrs) {
        for (var key in attrs) {
            if (attrs.hasOwnProperty(key)) {
                el.setAttribute(key, attrs[key]);
            }
        }
    }
    if (parent) {
        parent.appendChild(el);
    }
    return el;
}

// Stain color mapping - converts CSS class names to fill colors
var STAIN_COLORS = {
    "gneg": "#ffffff",
    "gpos": "#000000",
    "gpos100": "#000000",
    "gpos75": "#444444",
    "gpos66": "#666666",
    "gpos50": "#888888",
    "gpos33": "#aaaaaa",
    "gpos25": "#cccccc",
    "gvar": "#cccccc",
    "stalk": "#cccccc",
    "acen": "#cccccc"
};

function getStainColor(stain) {
    return STAIN_COLORS[stain] || "#ffffff";
}

/**
 * Renders the main genome view as SVG
 */
function renderGenomeSVG(gv) {
    gv.setScaleRatio();

    gv.regionWidth = Math.round(gv.pixelWidth / gv.chromosomes.length);

    if (!gv.chromosomeWidth) {
        gv.chromosomeWidth = Math.round(gv.regionWidth / 3);
    }

    var whiteSpace = (gv.annotationPadding * gv.annotationTypes.length) + (gv.regionPadding * 2);

    if (!gv.annotationWidth) {
        gv.annotationWidth = Math.floor((Math.round(gv.chromosomeWidth * 2) - whiteSpace) / gv.annotationTypes.length);
    }

    var svgWidth = gv.pixelWidth;
    var svgHeight = gv.pixelHeight - 46;

    // Create SVG element inside the canvas div
    var svg = createSVGElement("svg", {
        "width": svgWidth,
        "height": svgHeight + 20,
        "class": "gviewer-svg",
        "role": "img",
        "aria-label": "Genome visualization showing all chromosomes with gene, QTL, and strain annotations"
    });
    // Add title for screen readers
    var svgTitle = createSVGElement("title", {}, svg);
    svgTitle.textContent = "Genome Viewer - Click a chromosome to zoom in";
    gv.canvas.appendChild(svg);
    gv.svg = svg;

    // Shared defs: shine gradient + soft drop shadow for a polished look
    var defs = createSVGElement("defs", {}, svg);

    // Subtle left-to-right shine (white to transparent to soft shadow on right)
    var shine = createSVGElement("linearGradient", {
        "id": "chrShine", "x1": "0%", "y1": "0%", "x2": "100%", "y2": "0%"
    }, defs);
    createSVGElement("stop", { "offset": "0%",  "stop-color": "#ffffff", "stop-opacity": "0.55" }, shine);
    createSVGElement("stop", { "offset": "35%", "stop-color": "#ffffff", "stop-opacity": "0.15" }, shine);
    createSVGElement("stop", { "offset": "65%", "stop-color": "#000000", "stop-opacity": "0.00" }, shine);
    createSVGElement("stop", { "offset": "100%","stop-color": "#000000", "stop-opacity": "0.18" }, shine);

    // Soft drop shadow filter
    var filter = createSVGElement("filter", {
        "id": "chrShadow", "x": "-20%", "y": "-5%", "width": "140%", "height": "115%"
    }, defs);
    createSVGElement("feGaussianBlur", { "in": "SourceAlpha", "stdDeviation": "0.8" }, filter);
    createSVGElement("feOffset", { "dx": "0.8", "dy": "0.8", "result": "off" }, filter);
    var merge = createSVGElement("feMerge", {}, filter);
    createSVGElement("feMergeNode", { "in": "off" }, merge);
    createSVGElement("feMergeNode", { "in": "SourceGraphic" }, merge);

    for (var i = 1; i < gv.chromosomes.length; i++) {
        var chr = gv.chromosomes[i];
        var xOffset = ((i - 1) * gv.regionWidth) + 12;

        // Chromosome label
        createSVGElement("text", {
            "x": xOffset + gv.chromosomeWidth / 2,
            "y": 12,
            "text-anchor": "middle",
            "font-size": "13px",
            "font-weight": "700"
        }, svg).textContent = chr.name;

        var chrGroupY = 16;
        chr._svgOffsetY = chrGroupY;

        // Create a group for this chromosome
        var chrGroup = createSVGElement("g", {
            "transform": "translate(" + xOffset + "," + chrGroupY + ")",
            "class": "chr-svg-group",
            "data-chr": chr.number,
            "tabindex": "0",
            "role": "button",
            "aria-label": "Chromosome " + chr.name + " - click to zoom"
        }, svg);
        // Title for tooltip/screen reader
        var chrTitle = createSVGElement("title", {}, chrGroup);
        chrTitle.textContent = "Chromosome " + chr.name;

        // Keyboard support: Enter/Space to select chromosome
        chrGroup.addEventListener("keydown", function(e) {
            if (e.key === "Enter" || e.key === " ") {
                e.preventDefault();
                var chrObj = findChrObj(e);
                if (chrObj) {
                    var rect = e.currentTarget.getBoundingClientRect();
                    gview().moveTo(chrObj, rect.top + rect.height / 2);
                }
            }
        });

        // Pre-compute total chromosome height from bands, and detect centromere
        var capRadius = Math.min(gv.chromosomeWidth / 2, 6);
        var totalBandHeight = 0;
        var bandDims = [];
        var foundP = false;
        var foundQ = false;
        var centromereBandY = -1;
        for (var j = 0; j < chr.bands.length; j++) {
            var b = chr.bands[j];
            var bh = Math.round((b.end - b.start) * gv.scaleRatio);
            if (bh < 1) bh = 1;
            bandDims.push(bh);
            if (!foundP && b.name.substring(0, 1).toLowerCase() == "p") {
                foundP = true;
            } else if (foundP && !foundQ && b.name.substring(0, 1).toLowerCase() == "q") {
                centromereBandY = capRadius + totalBandHeight;
                foundQ = true;
            }
            totalBandHeight += bh;
        }
        var chrBodyHeight = totalBandHeight;
        var chrTotalHeight = capRadius * 2 + chrBodyHeight;
        // Expose the full visual height so the zoom slider can extend
        // through the bottom rounded cap, not just the band body.
        chr._svgTotalHeight = chrTotalHeight;
        chr._svgCapRadius = capRadius;

        // Pre-compute centromere Y for pinched chromosome outline
        var preCentromereY = -1;
        {
            var _y = capRadius;
            var _foundP = false, _foundQ = false;
            for (var _j = 0; _j < chr.bands.length; _j++) {
                var _b = chr.bands[_j];
                if (!_foundP && _b.name.substring(0, 1).toLowerCase() == "p") {
                    _foundP = true;
                } else if (_foundP && !_foundQ && _b.name.substring(0, 1).toLowerCase() == "q") {
                    preCentromereY = _y;
                    _foundQ = true;
                    break;
                }
                _y += bandDims[_j];
            }
        }

        // Build a chromosome-shaped path (rounded caps, pinched at centromere) used for clip + outline
        var chrW = gv.chromosomeWidth;
        var chrH = chrTotalHeight;
        var capH = Math.max(capRadius, chrW * 0.55);   // height of rounded cap (semi-ellipse)
        var rx = (chrW - 1) / 2;                        // cap horizontal radius
        var ry = capH;                                  // cap vertical radius
        var cLenOutline = gv.centromereLength;
        var cwPinch = Math.floor(gv.chromosomeWidth / 3);

        // Start at left side just below top cap
        var chrPath = "M 0.5 " + capH +
            " L 0.5 ";
        if (preCentromereY > 0) {
            chrPath += (preCentromereY - cLenOutline) +
                " L " + cwPinch + " " + preCentromereY +
                " L 0.5 " + (preCentromereY + cLenOutline) +
                " L 0.5 ";
        }
        chrPath += (chrH - capH) +
            // Bottom rounded cap (arc)
            " A " + rx + " " + ry + " 0 0 0 " + (chrW - 0.5) + " " + (chrH - capH) +
            " L " + (chrW - 0.5) + " ";
        if (preCentromereY > 0) {
            chrPath += (preCentromereY + cLenOutline) +
                " L " + (chrW - cwPinch) + " " + preCentromereY +
                " L " + (chrW - 0.5) + " " + (preCentromereY - cLenOutline) +
                " L " + (chrW - 0.5) + " ";
        }
        chrPath += capH +
            // Top rounded cap (arc)
            " A " + rx + " " + ry + " 0 0 0 0.5 " + capH +
            " Z";

        // Build a clipPath in the chromosome shape so bands & shine stay inside
        var clipId = "chrClip_" + chr.number + "_" + Math.floor(Math.random() * 100000);
        var clipPath = createSVGElement("clipPath", { "id": clipId }, defs);
        createSVGElement("path", { "d": chrPath }, clipPath);

        // Invisible body rect tracks the chromosome for events
        var chrRect = createSVGElement("rect", {
            "x": 0, "y": 0,
            "width": gv.chromosomeWidth,
            "height": chrTotalHeight,
            "fill": "transparent",
            "stroke": "none", "stroke-width": "0",
            "class": "chr-svg-body"
        }, chrGroup);
        chrRect.obj = chr;
        chr.div = chrRect;
        chr.svgGroup = chrGroup;

        // Everything visual (bands, shine) goes inside a clipped group so rounded caps look clean
        var clippedGroup = createSVGElement("g", { "clip-path": "url(#" + clipId + ")" }, chrGroup);

        // White background inside clip so caps show background where bands don't fully cover
        createSVGElement("rect", {
            "x": 0, "y": 0,
            "width": gv.chromosomeWidth,
            "height": chrTotalHeight,
            "fill": "#ffffff"
        }, clippedGroup);

        // Render bands
        var currentY = capRadius;
        var centromereY = -1;
        foundP = false; foundQ = false;
        for (var j = 0; j < chr.bands.length; j++) {
            var band = chr.bands[j];
            var bandHeight = bandDims[j];
            var fillColor = band.color || getStainColor(band.stain);

            var bandRect = createSVGElement("rect", {
                "x": 0, "y": currentY,
                "width": gv.chromosomeWidth,
                "height": bandHeight,
                "fill": fillColor,
                "stroke": "none",
                "shape-rendering": "crispEdges"
            }, clippedGroup);
            bandRect.obj = band;
            band.div = bandRect;

            if (!foundP && band.name.substring(0, 1).toLowerCase() == "p") {
                foundP = true;
            } else if (foundP && !foundQ && band.name.substring(0, 1).toLowerCase() == "q") {
                centromereY = currentY;
                foundQ = true;
            }

            currentY += bandHeight;
        }

        // Overlay a subtle shine for a polished 3D look
        createSVGElement("rect", {
            "x": 0, "y": 0,
            "width": gv.chromosomeWidth,
            "height": chrTotalHeight,
            "fill": "url(#chrShine)",
            "pointer-events": "none"
        }, clippedGroup);

        // (Centromere pinch is now part of the main chromosome path/outline)

        // Outer chromosome outline drawn last so it sits crisply on top
        chr.outlinePath = createSVGElement("path", {
            "d": chrPath,
            "fill": "none",
            "stroke": "#222", "stroke-width": "1",
            "filter": "url(#chrShadow)"
        }, chrGroup);

        // Slider (still a div, overlaid on SVG)
        chr.slider = new Slider(chr);
        chr.slider.div.style.left = (xOffset - gv.regionPadding - 1) + "px";
        chr.slider.div.style.width = gv.regionWidth + "px";
        chr.slider.div.style.height = "0px";
        chr.slider.div.style.top = chrGroupY + "px";
        gv.relate(chr.slider, chr.slider.div);

        // Event handlers on the chromosome group
        chrGroup.onclick = gviewer_chromosome_clickEvent;
        chrGroup.onmouseover = gviewer_chromosome_mouseOverEvent;
        chrGroup.onmouseout = gviewer_chromosome_mouseOutEvent;
        chrGroup.onmousemove = gviewer_object_mouseMoveEvent;
        chrGroup.style.cursor = "pointer";
    }
}

/**
 * Renders an annotation as an SVG rect
 */
function renderAnnotationSVG(gv, chr, annot) {
    if (!chr.svgGroup) return;

    var svg = gv.svg;
    var chrGroup = chr.svgGroup;

    var len = Math.ceil((annot.end - annot.start) * gv.scaleRatio);
    var top = Math.round(parseInt(annot.start * gv.scaleRatio)) + Math.min(gv.chromosomeWidth / 2, 6); // offset for top cap

    if (len < 4) {
        len = 4;
    }

    var leftPos = 0;
    for (var i = 0; i < gv.annotationTypes.length; i++) {
        if (gv.annotationTypes[i] == annot.type) {
            leftPos = gv.chromosomeWidth + gv.regionPadding + ((gv.annotationWidth + gv.annotationPadding) * i);
            break;
        }
    }

    var annotRect = createSVGElement("rect", {
        "x": leftPos,
        "y": top,
        "width": gv.annotationWidth,
        "height": len,
        "fill": annot.color,
        "class": "annot-svg " + annot.type,
        "role": "img",
        "aria-label": annot.type + ": " + annot.name + " (chr" + chr.number + ":" + annot.start + "-" + annot.end + ")"
    }, chrGroup);

    // Tooltip title for hover
    var annotTitle = createSVGElement("title", {}, annotRect);
    annotTitle.textContent = annot.name + " (" + annot.type + ")";

    annotRect.obj = annot;
    annot.div = annotRect;

    annotRect.oncontextmenu = window_contextMenuEvent;
    annotRect.onmousemove = gviewer_object_mouseMoveEvent;
    annotRect.style.cursor = "pointer";
}
