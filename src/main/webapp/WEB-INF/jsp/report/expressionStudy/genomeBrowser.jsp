<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 1/20/2026
  Time: 2:15 PM
  Interactive Genome Browser for Expression Data
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    .genome-browser-container {
        margin: 20px 0;
        background: white;
        border-radius: 5px;
        padding: 15px;
        font-family: Arial, sans-serif;
    }
    .gb-controls {
        display: flex;
        gap: 15px;
        align-items: center;
        flex-wrap: wrap;
        margin-bottom: 15px;
        padding: 10px;
        background: #f5f5f5;
        border-radius: 5px;
    }
    .gb-controls label {
        font-weight: bold;
        font-size: 12px;
        color: #333;
    }
    .gb-controls select, .gb-controls input, .gb-controls button {
        padding: 6px 12px;
        border: 1px solid #ccc;
        border-radius: 3px;
        font-size: 12px;
    }
    .gb-controls button {
        background: #2865A3;
        color: white;
        cursor: pointer;
        border: none;
        transition: background 0.2s;
    }
    .gb-controls button:hover {
        background: #1a4570;
    }
    .gb-controls button:disabled {
        background: #ccc;
        cursor: not-allowed;
    }
    .gb-nav-buttons {
        display: flex;
        gap: 5px;
    }
    .gb-nav-buttons button {
        padding: 6px 10px;
        min-width: 40px;
    }
    .gb-stats {
        display: flex;
        gap: 20px;
        margin-bottom: 15px;
        padding: 10px 15px;
        background: #e8f4fc;
        border-radius: 5px;
        font-size: 12px;
    }
    .gb-stats span {
        color: #2865A3;
        font-weight: bold;
    }
    .gb-chromosome-bar {
        height: 30px;
        background: linear-gradient(to right, #f0f0f0, #ddd);
        border-radius: 15px;
        margin-bottom: 10px;
        position: relative;
        border: 1px solid #ccc;
        overflow: hidden;
    }
    .gb-viewport-indicator {
        position: absolute;
        height: 100%;
        background: rgba(40, 101, 163, 0.3);
        border: 2px solid #2865A3;
        border-radius: 15px;
        cursor: move;
        transition: left 0.2s, width 0.2s;
    }
    .gb-track-container {
        border: 1px solid #ddd;
        border-radius: 5px;
        overflow: hidden;
        background: #fafafa;
    }
    .gb-track-header {
        background: #2865A3;
        color: white;
        padding: 8px 15px;
        font-weight: bold;
        font-size: 13px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .gb-track-content {
        position: relative;
        height: 400px;
        overflow: hidden;
    }
    #genomeBrowserCanvas {
        display: block;
        width: 100%;
        height: 400px;
        background: #fafafa;
    }
    .gb-gene-tooltip {
        position: absolute;
        background: rgba(0, 0, 0, 0.85);
        color: white;
        padding: 10px 15px;
        border-radius: 5px;
        font-size: 12px;
        pointer-events: none;
        z-index: 1000;
        max-width: 350px;
        display: none;
        box-shadow: 0 2px 10px rgba(0,0,0,0.3);
    }
    .gb-gene-tooltip h4 {
        margin: 0 0 8px 0;
        color: #7cb5ec;
        font-size: 14px;
    }
    .gb-gene-tooltip .tooltip-row {
        margin: 4px 0;
    }
    .gb-gene-tooltip .tooltip-label {
        color: #aaa;
    }
    .gb-loading {
        text-align: center;
        padding: 40px;
        font-size: 14px;
        color: #666;
    }
    .gb-legend {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-top: 15px;
        font-size: 11px;
    }
    .gb-legend-gradient {
        width: 150px;
        height: 15px;
        background: linear-gradient(to right, #ffffcc, #ffeda0, #fed976, #feb24c, #fd8d3c, #fc4e2a, #e31a1c, #b10026);
        border: 1px solid #ccc;
        border-radius: 2px;
    }
    .gb-position-input {
        display: flex;
        align-items: center;
        gap: 5px;
    }
    .gb-position-input input {
        width: 100px;
    }
    .gb-ruler {
        height: 25px;
        background: #f9f9f9;
        border-bottom: 1px solid #ddd;
        position: relative;
    }
    .gb-ruler-tick {
        position: absolute;
        top: 0;
        height: 100%;
        border-left: 1px solid #ccc;
        font-size: 9px;
        padding-left: 3px;
        color: #666;
    }
    .gb-gene-details-panel {
        margin-top: 15px;
        padding: 15px;
        background: #f9f9f9;
        border-radius: 5px;
        display: none;
    }
    .gb-gene-details-panel h4 {
        margin: 0 0 10px 0;
        color: #2865A3;
    }
    .gb-gene-details-panel table {
        width: 100%;
        border-collapse: collapse;
        font-size: 12px;
    }
    .gb-gene-details-panel th, .gb-gene-details-panel td {
        padding: 6px 10px;
        text-align: left;
        border-bottom: 1px solid #ddd;
    }
    .gb-gene-details-panel th {
        background: #e8f4fc;
        font-weight: bold;
    }
</style>

<h2>Interactive Genome Browser</h2>

<div class="genome-browser-container">
    <div id="gbLoading" class="gb-loading">Loading genomic expression data...</div>
    <div id="gbDebug" style="background:#ffffd0; padding:10px; margin:10px 0; font-size:11px; font-family:monospace; border:1px solid #ccc; display:none;"></div>

    <div id="gbContent" style="display: none;">
        <div class="gb-controls">
            <div>
                <label for="gbChromosome">Chromosome: </label>
                <select id="gbChromosome"></select>
            </div>
            <div class="gb-position-input">
                <label>Position: </label>
                <input type="text" id="gbStartPos" placeholder="Start">
                <span>-</span>
                <input type="text" id="gbEndPos" placeholder="End">
                <button id="gbGoBtn">Go</button>
            </div>
            <div class="gb-nav-buttons">
                <button id="gbPanLeft" title="Pan Left">&larr;</button>
                <button id="gbZoomIn" title="Zoom In">+</button>
                <button id="gbZoomOut" title="Zoom Out">-</button>
                <button id="gbPanRight" title="Pan Right">&rarr;</button>
                <button id="gbReset" title="Reset View">Reset</button>
            </div>
            <div>
                <label for="gbColorBy">Color By: </label>
                <select id="gbColorBy">
                    <option value="tpm" selected>TPM Level</option>
                    <option value="level">Expression Level</option>
                    <option value="length">Gene Length</option>
                </select>
            </div>
            <div>
                <label for="gbMinTpm">Min TPM: </label>
                <input type="number" id="gbMinTpm" value="0" min="0" step="1" style="width: 70px;">
            </div>
        </div>

        <div class="gb-stats">
            <div>Chromosome: <span id="gbStatChr">-</span></div>
            <div>View Range: <span id="gbStatRange">-</span></div>
            <div>Genes in View: <span id="gbStatGenes">-</span></div>
            <div>Max TPM: <span id="gbStatMaxTpm">-</span></div>
        </div>

        <div class="gb-chromosome-bar" id="gbChromosomeBar">
            <div class="gb-viewport-indicator" id="gbViewportIndicator"></div>
        </div>

        <div class="gb-track-container">
            <div class="gb-track-header">
                <span>Gene Expression Track</span>
                <span id="gbTrackInfo"></span>
            </div>
            <div class="gb-ruler" id="gbRuler"></div>
            <div class="gb-track-content" id="gbTrackContent">
                <canvas id="genomeBrowserCanvas"></canvas>
            </div>
        </div>

        <div class="gb-legend">
            <span>Low TPM</span>
            <div class="gb-legend-gradient"></div>
            <span>High TPM</span>
            <span style="margin-left: 20px;">Click on a gene for details</span>
        </div>

        <div class="gb-gene-details-panel" id="gbGeneDetails">
            <h4>Gene Details: <span id="gbSelectedGene">-</span></h4>
            <table>
                <thead>
                    <tr>
                        <th>Sample</th>
                        <th>Condition</th>
                        <th>TPM</th>
                        <th>Level</th>
                    </tr>
                </thead>
                <tbody id="gbGeneDetailsBody"></tbody>
            </table>
        </div>
    </div>

    <div class="gb-gene-tooltip" id="gbTooltip"></div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    var rawData = [];
    var chromosomeData = {};
    var chromosomeLengths = {};
    var currentChr = null;
    var viewStart = 0;
    var viewEnd = 0;
    var canvas, ctx;
    var geneRects = [];
    var hoveredGene = null;
    var isDragging = false;
    var dragStartX = 0;
    var dragStartViewStart = 0;

    function debug(msg) {
        // console.log(msg);
        // var dbgDiv = document.getElementById('gbDebug');
        // if (dbgDiv) {
        //     dbgDiv.style.display = 'block';
        //     dbgDiv.innerHTML += msg + '<br>';
        // }
    }

    // debug('Script started, fetching data...');

    // Fetch data
    fetch('/rgdweb/data/expression_observations_positions.json')
        .then(function(response) {
            return response.json();
        })
        .then(function(data) {
            debug('Data loaded: ' + data.length + ' records');
            rawData = data;
            processData();
            document.getElementById('gbLoading').style.display = 'none';
            document.getElementById('gbContent').style.display = 'block';
            // Initialize UI after content is visible so canvas gets proper dimensions
            setTimeout(function() {
                debug('Initializing UI...');
                initializeUI();
            }, 100);
        })
        .catch(function(error) {
            debug('ERROR loading data: ' + error.message);
            document.getElementById('gbLoading').textContent = 'Error loading data: ' + error.message;
        });

    function processData() {
        debug('Processing data, raw data count: ' + rawData.length);

        if (rawData.length === 0) {
            debug('ERROR: No data loaded!');
            return;
        }

        // Log first item to verify structure
        debug('First item - gene: ' + rawData[0].gene + ', chr: ' + rawData[0].chr + ', start: ' + rawData[0].geneStart);

        // Group data by chromosome
        rawData.forEach(function(item) {
            var chr = item.chr;
            if (!chromosomeData[chr]) {
                chromosomeData[chr] = [];
                chromosomeLengths[chr] = 0;
            }
            chromosomeData[chr].push(item);
            chromosomeLengths[chr] = Math.max(chromosomeLengths[chr], item.geneStop);
        });

        // Sort genes within each chromosome by position
        Object.keys(chromosomeData).forEach(function(chr) {
            chromosomeData[chr].sort(function(a, b) {
                return a.geneStart - b.geneStart;
            });
        });

        debug('Processed chromosomes: ' + Object.keys(chromosomeData).join(', '));
    }

    function initializeUI() {
        // Populate chromosome dropdown
        var chrSelect = document.getElementById('gbChromosome');
        var chromosomes = Object.keys(chromosomeData).sort(function(a, b) {
            var numA = parseInt(a) || 999;
            var numB = parseInt(b) || 999;
            if (numA !== numB) return numA - numB;
            return a.localeCompare(b);
        });

        chromosomes.forEach(function(chr) {
            var option = document.createElement('option');
            option.value = chr;
            option.textContent = 'Chr ' + chr + ' (' + chromosomeData[chr].length + ' genes)';
            chrSelect.appendChild(option);
        });

        // Initialize canvas
        canvas = document.getElementById('genomeBrowserCanvas');
        ctx = canvas.getContext('2d');
        resizeCanvas();

        // Test draw to verify canvas is working
        debug('Canvas initialized: ' + canvas.width + 'x' + canvas.height);
        ctx.fillStyle = 'red';
        ctx.fillRect(10, 10, 100, 50);
        ctx.fillStyle = 'blue';
        ctx.fillRect(120, 10, 100, 50);
        debug('Test rectangles drawn (red and blue) - if you see them, canvas works!');

        debug('Chromosomes available: ' + chromosomes.length);

        // Set initial chromosome
        if (chromosomes.length > 0) {
            currentChr = chromosomes[0];
            chrSelect.value = currentChr;
            debug('Selected chr ' + currentChr + ' with ' + chromosomeData[currentChr].length + ' genes, length: ' + chromosomeLengths[currentChr]);
            resetView();
        } else {
            debug('ERROR: No chromosomes found in data');
        }

        // Event listeners
        chrSelect.addEventListener('change', function() {
            currentChr = this.value;
            resetView();
        });

        document.getElementById('gbGoBtn').addEventListener('click', goToPosition);
        document.getElementById('gbPanLeft').addEventListener('click', function() { pan(-0.25); });
        document.getElementById('gbPanRight').addEventListener('click', function() { pan(0.25); });
        document.getElementById('gbZoomIn').addEventListener('click', function() { zoom(0.5); });
        document.getElementById('gbZoomOut').addEventListener('click', function() { zoom(2); });
        document.getElementById('gbReset').addEventListener('click', resetView);
        document.getElementById('gbColorBy').addEventListener('change', render);
        document.getElementById('gbMinTpm').addEventListener('change', render);

        // Canvas mouse events
        canvas.addEventListener('mousemove', handleMouseMove);
        canvas.addEventListener('mousedown', handleMouseDown);
        canvas.addEventListener('mouseup', handleMouseUp);
        canvas.addEventListener('mouseleave', handleMouseLeave);
        canvas.addEventListener('click', handleClick);
        canvas.addEventListener('wheel', handleWheel);

        // Window resize
        window.addEventListener('resize', function() {
            resizeCanvas();
            render();
        });
    }

    function resizeCanvas() {
        var container = document.getElementById('gbTrackContent');
        var width = container.clientWidth || container.offsetWidth || 800;
        var height = container.clientHeight || container.offsetHeight || 400;
        // Ensure minimum dimensions
        canvas.width = Math.max(width, 400);
        canvas.height = Math.max(height, 300);
    }

    function resetView() {
        if (!currentChr) return;
        viewStart = 0;
        viewEnd = chromosomeLengths[currentChr];
        render();
    }

    function goToPosition() {
        var start = parseInt(document.getElementById('gbStartPos').value);
        var end = parseInt(document.getElementById('gbEndPos').value);
        if (!isNaN(start) && !isNaN(end) && start < end) {
            viewStart = Math.max(0, start);
            viewEnd = Math.min(chromosomeLengths[currentChr], end);
            render();
        }
    }

    function pan(factor) {
        var viewWidth = viewEnd - viewStart;
        var shift = viewWidth * factor;
        viewStart = Math.max(0, viewStart + shift);
        viewEnd = Math.min(chromosomeLengths[currentChr], viewEnd + shift);

        // Adjust if hitting boundaries
        if (viewStart === 0) {
            viewEnd = Math.min(chromosomeLengths[currentChr], viewWidth);
        }
        if (viewEnd === chromosomeLengths[currentChr]) {
            viewStart = Math.max(0, viewEnd - viewWidth);
        }
        render();
    }

    function zoom(factor) {
        var viewWidth = viewEnd - viewStart;
        var center = (viewStart + viewEnd) / 2;
        var newWidth = viewWidth * factor;

        // Minimum zoom: 1000 bp
        newWidth = Math.max(1000, newWidth);
        // Maximum zoom: full chromosome
        newWidth = Math.min(chromosomeLengths[currentChr], newWidth);

        viewStart = Math.max(0, center - newWidth / 2);
        viewEnd = Math.min(chromosomeLengths[currentChr], center + newWidth / 2);

        // Adjust for boundaries
        if (viewStart === 0) {
            viewEnd = Math.min(chromosomeLengths[currentChr], newWidth);
        }
        if (viewEnd === chromosomeLengths[currentChr]) {
            viewStart = Math.max(0, viewEnd - newWidth);
        }
        render();
    }

    function handleWheel(e) {
        e.preventDefault();
        var factor = e.deltaY > 0 ? 1.2 : 0.8;
        zoom(factor);
    }

    function handleMouseDown(e) {
        isDragging = true;
        dragStartX = e.offsetX;
        dragStartViewStart = viewStart;
        canvas.style.cursor = 'grabbing';
    }

    function handleMouseUp(e) {
        isDragging = false;
        canvas.style.cursor = 'default';
    }

    function handleMouseLeave(e) {
        isDragging = false;
        canvas.style.cursor = 'default';
        document.getElementById('gbTooltip').style.display = 'none';
    }

    function handleMouseMove(e) {
        if (isDragging) {
            var dx = e.offsetX - dragStartX;
            var bpPerPixel = (viewEnd - viewStart) / canvas.width;
            var shift = -dx * bpPerPixel;
            var newStart = dragStartViewStart + shift;
            var viewWidth = viewEnd - viewStart;

            newStart = Math.max(0, Math.min(chromosomeLengths[currentChr] - viewWidth, newStart));
            viewStart = newStart;
            viewEnd = newStart + viewWidth;
            render();
            return;
        }

        // Check for gene hover
        var rect = canvas.getBoundingClientRect();
        var x = e.offsetX;
        var y = e.offsetY;

        var found = null;
        for (var i = 0; i < geneRects.length; i++) {
            var gr = geneRects[i];
            if (x >= gr.x && x <= gr.x + gr.width && y >= gr.y && y <= gr.y + gr.height) {
                found = gr;
                break;
            }
        }

        if (found) {
            canvas.style.cursor = 'pointer';
            showTooltip(found, e.clientX, e.clientY);
            hoveredGene = found;
        } else {
            canvas.style.cursor = 'default';
            document.getElementById('gbTooltip').style.display = 'none';
            hoveredGene = null;
        }
    }

    function handleClick(e) {
        if (hoveredGene) {
            showGeneDetails(hoveredGene.gene);
        }
    }

    function showTooltip(geneRect, clientX, clientY) {
        var tooltip = document.getElementById('gbTooltip');
        var gene = geneRect.data;

        tooltip.innerHTML =
            '<h4>' + gene.gene + '</h4>' +
            '<div class="tooltip-row"><span class="tooltip-label">Position:</span> Chr' + gene.chr + ':' + formatNumber(gene.geneStart) + '-' + formatNumber(gene.geneStop) + '</div>' +
            '<div class="tooltip-row"><span class="tooltip-label">Length:</span> ' + formatNumber(gene.geneStop - gene.geneStart) + ' bp</div>' +
            '<div class="tooltip-row"><span class="tooltip-label">TPM:</span> ' + gene.tpm.toFixed(2) + '</div>' +
            '<div class="tooltip-row"><span class="tooltip-label">Level:</span> ' + gene.level + '</div>' +
            '<div class="tooltip-row"><span class="tooltip-label">Sample:</span> ' + gene.sample + '</div>' +
            '<div class="tooltip-row" style="font-size:10px; color:#888; margin-top:5px;">Click for all samples</div>';

        tooltip.style.display = 'block';
        tooltip.style.left = (clientX + 15) + 'px';
        tooltip.style.top = (clientY + 15) + 'px';

        // Keep tooltip on screen
        var tooltipRect = tooltip.getBoundingClientRect();
        if (tooltipRect.right > window.innerWidth) {
            tooltip.style.left = (clientX - tooltipRect.width - 15) + 'px';
        }
        if (tooltipRect.bottom > window.innerHeight) {
            tooltip.style.top = (clientY - tooltipRect.height - 15) + 'px';
        }
    }

    function showGeneDetails(geneName) {
        var panel = document.getElementById('gbGeneDetails');
        var tbody = document.getElementById('gbGeneDetailsBody');
        document.getElementById('gbSelectedGene').textContent = geneName;

        // Find all entries for this gene
        var geneEntries = rawData.filter(function(item) {
            return item.gene === geneName;
        }).sort(function(a, b) {
            return b.tpm - a.tpm;
        });

        var html = '';
        geneEntries.forEach(function(entry) {
            var condShort = entry.condition.length > 60 ? entry.condition.substring(0, 60) + '...' : entry.condition;
            html += '<tr>' +
                '<td>' + entry.sample + '</td>' +
                '<td title="' + entry.condition + '">' + condShort + '</td>' +
                '<td>' + entry.tpm.toFixed(2) + '</td>' +
                '<td>' + entry.level + '</td>' +
                '</tr>';
        });

        tbody.innerHTML = html;
        panel.style.display = 'block';
    }

    function render() {
        if (!currentChr || !ctx) {
            debug('Render aborted: currentChr=' + currentChr + ', ctx=' + ctx);
            return;
        }

        debug('Rendering chr ' + currentChr + ' from ' + viewStart + ' to ' + viewEnd);

        var minTpm = parseFloat(document.getElementById('gbMinTpm').value) || 0;
        var colorBy = document.getElementById('gbColorBy').value;

        // Clear canvas
        ctx.fillStyle = '#fafafa';
        ctx.fillRect(0, 0, canvas.width, canvas.height);

        // Get genes in view
        var genes = chromosomeData[currentChr].filter(function(gene) {
            return gene.geneStop >= viewStart && gene.geneStart <= viewEnd && gene.tpm >= minTpm;
        });

        debug('Genes in view (before dedup): ' + genes.length);

        // Aggregate genes by name (take max TPM for display)
        var geneMap = {};
        genes.forEach(function(gene) {
            if (!geneMap[gene.gene] || gene.tpm > geneMap[gene.gene].tpm) {
                geneMap[gene.gene] = gene;
            }
        });
        var uniqueGenes = Object.values(geneMap);
        debug('Unique genes to render: ' + uniqueGenes.length);

        // Calculate max values for scaling
        var maxTpm = 1;
        var maxLength = 1;
        uniqueGenes.forEach(function(gene) {
            maxTpm = Math.max(maxTpm, gene.tpm);
            maxLength = Math.max(maxLength, gene.geneStop - gene.geneStart);
        });

        // Calculate positions and render genes
        geneRects = [];
        var viewWidth = viewEnd - viewStart;
        var bpPerPixel = viewWidth / canvas.width;
        var trackHeight = canvas.height - 40; // Leave space for labels
        var laneHeight = 35;
        var lanes = [];

        // Sort genes by start position
        uniqueGenes.sort(function(a, b) { return a.geneStart - b.geneStart; });

        debug('Canvas: ' + canvas.width + 'x' + canvas.height + ', viewWidth: ' + viewWidth + 'bp, bpPerPixel: ' + bpPerPixel.toFixed(2));

        // Assign genes to lanes to avoid overlap
        uniqueGenes.forEach(function(gene, index) {
            var geneX = (gene.geneStart - viewStart) / bpPerPixel;
            var geneWidth = Math.max(3, (gene.geneStop - gene.geneStart) / bpPerPixel);
            var geneEnd = geneX + geneWidth;

            // Find available lane
            var laneIndex = 0;
            for (var i = 0; i < lanes.length; i++) {
                if (lanes[i] < geneX - 5) {
                    laneIndex = i;
                    break;
                }
                laneIndex = i + 1;
            }
            lanes[laneIndex] = geneEnd;

            var geneY = 20 + (laneIndex % Math.floor(trackHeight / laneHeight)) * laneHeight;
            var geneHeight = 25;

            // Log first few genes for debugging
            if (index < 3) {
                debug('Drawing gene ' + gene.gene + ' at x:' + geneX.toFixed(1) + ' y:' + geneY + ' w:' + geneWidth.toFixed(1) + ' h:' + geneHeight);
            }

            // Determine color
            var color;
            if (colorBy === 'tpm') {
                color = getTpmColor(gene.tpm, maxTpm);
            } else if (colorBy === 'level') {
                color = getLevelColor(gene.level);
            } else {
                color = getLengthColor(gene.geneStop - gene.geneStart, maxLength);
            }

            // Draw gene rectangle
            ctx.fillStyle = color;
            ctx.fillRect(geneX, geneY, geneWidth, geneHeight);

            // Draw border
            ctx.strokeStyle = '#333';
            ctx.lineWidth = 1;
            ctx.strokeRect(geneX, geneY, geneWidth, geneHeight);

            // Draw gene label if there's space
            if (geneWidth > 30) {
                ctx.fillStyle = '#fff';
                ctx.font = 'bold 10px Arial';
                ctx.textAlign = 'center';
                ctx.textBaseline = 'middle';
                var label = gene.gene;
                if (ctx.measureText(label).width > geneWidth - 4) {
                    label = label.substring(0, 3) + '..';
                }
                ctx.fillText(label, geneX + geneWidth / 2, geneY + geneHeight / 2);
            }

            // Store rect for interaction
            geneRects.push({
                x: geneX,
                y: geneY,
                width: geneWidth,
                height: geneHeight,
                gene: gene.gene,
                data: gene
            });
        });

        // Draw scale bar
        ctx.fillStyle = '#333';
        ctx.font = '10px Arial';
        ctx.textAlign = 'left';
        var scaleText = 'Scale: ' + formatNumber(Math.round(viewWidth)) + ' bp';
        ctx.fillText(scaleText, 10, canvas.height - 5);

        // Update ruler
        renderRuler();

        // Update stats
        document.getElementById('gbStatChr').textContent = 'Chr ' + currentChr;
        document.getElementById('gbStatRange').textContent = formatNumber(Math.round(viewStart)) + ' - ' + formatNumber(Math.round(viewEnd));
        document.getElementById('gbStatGenes').textContent = uniqueGenes.length;
        document.getElementById('gbStatMaxTpm').textContent = maxTpm.toFixed(2);

        // Update viewport indicator
        updateViewportIndicator();

        // Update position inputs
        document.getElementById('gbStartPos').value = Math.round(viewStart);
        document.getElementById('gbEndPos').value = Math.round(viewEnd);

        // Update track info
        document.getElementById('gbTrackInfo').textContent = uniqueGenes.length + ' genes displayed';
    }

    function renderRuler() {
        var ruler = document.getElementById('gbRuler');
        var viewWidth = viewEnd - viewStart;
        var rulerWidth = ruler.clientWidth;

        // Calculate nice tick intervals
        var targetTicks = 10;
        var rawInterval = viewWidth / targetTicks;
        var magnitude = Math.pow(10, Math.floor(Math.log10(rawInterval)));
        var normalized = rawInterval / magnitude;
        var niceInterval;
        if (normalized <= 1) niceInterval = magnitude;
        else if (normalized <= 2) niceInterval = 2 * magnitude;
        else if (normalized <= 5) niceInterval = 5 * magnitude;
        else niceInterval = 10 * magnitude;

        var html = '';
        var firstTick = Math.ceil(viewStart / niceInterval) * niceInterval;
        for (var pos = firstTick; pos <= viewEnd; pos += niceInterval) {
            var x = ((pos - viewStart) / viewWidth) * rulerWidth;
            html += '<div class="gb-ruler-tick" style="left:' + x + 'px;">' + formatNumber(pos) + '</div>';
        }
        ruler.innerHTML = html;
    }

    function updateViewportIndicator() {
        var indicator = document.getElementById('gbViewportIndicator');
        var bar = document.getElementById('gbChromosomeBar');
        var chrLength = chromosomeLengths[currentChr];
        var barWidth = bar.clientWidth;

        var left = (viewStart / chrLength) * barWidth;
        var width = ((viewEnd - viewStart) / chrLength) * barWidth;
        width = Math.max(width, 10); // Minimum width for visibility

        indicator.style.left = left + 'px';
        indicator.style.width = width + 'px';
    }

    function getTpmColor(tpm, maxTpm) {
        var ratio = Math.min(tpm / maxTpm, 1);
        var colors = [
            [255, 255, 204],
            [255, 237, 160],
            [254, 217, 118],
            [254, 178, 76],
            [253, 141, 60],
            [252, 78, 42],
            [227, 26, 28],
            [177, 0, 38]
        ];
        var index = Math.min(Math.floor(ratio * (colors.length - 1)), colors.length - 2);
        var localRatio = (ratio * (colors.length - 1)) - index;
        var c1 = colors[index];
        var c2 = colors[index + 1];
        var r = Math.round(c1[0] + (c2[0] - c1[0]) * localRatio);
        var g = Math.round(c1[1] + (c2[1] - c1[1]) * localRatio);
        var b = Math.round(c1[2] + (c2[2] - c1[2]) * localRatio);
        return 'rgb(' + r + ',' + g + ',' + b + ')';
    }

    function getLevelColor(level) {
        switch (level.toLowerCase()) {
            case 'high': return '#e31a1c';
            case 'medium': return '#fd8d3c';
            case 'low': return '#ffffcc';
            default: return '#ccc';
        }
    }

    function getLengthColor(length, maxLength) {
        var ratio = Math.min(length / maxLength, 1);
        var r = Math.round(50 + ratio * 150);
        var g = Math.round(100 + (1 - ratio) * 100);
        var b = Math.round(200 - ratio * 100);
        return 'rgb(' + r + ',' + g + ',' + b + ')';
    }

    function formatNumber(num) {
        if (num >= 1000000) {
            return (num / 1000000).toFixed(2) + 'M';
        } else if (num >= 1000) {
            return (num / 1000).toFixed(1) + 'K';
        }
        return num.toString();
    }
});
</script>
