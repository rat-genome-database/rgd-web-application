<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 1/21/2026
  Time: 12:22 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    .manhattan-container {
        margin: 20px 0;
        background: white;
        border-radius: 5px;
        padding: 15px;
    }
    .manhattan-controls {
        margin-bottom: 15px;
        display: flex;
        gap: 15px;
        align-items: center;
        flex-wrap: wrap;
    }
    .manhattan-controls label {
        font-weight: bold;
        font-size: 12px;
    }
    .manhattan-controls select, .manhattan-controls input {
        padding: 5px 10px;
        border: 1px solid #ccc;
        border-radius: 3px;
    }
    .manhattan-loading {
        text-align: center;
        padding: 40px;
        font-size: 14px;
        color: #666;
    }
    .manhattan-stats {
        margin: 15px 0;
        padding: 10px 15px;
        background: #f9f9f9;
        border-radius: 5px;
        font-size: 12px;
        display: flex;
        gap: 20px;
        flex-wrap: wrap;
    }
    .manhattan-stats span {
        color: #2865A3;
        font-weight: bold;
    }
    #manhattanPlotChart {
        width: 100%;
        min-height: 500px;
    }
    .manhattan-legend {
        margin-top: 10px;
        padding: 10px;
        background: #f9f9f9;
        border-radius: 5px;
        font-size: 11px;
    }
    .manhattan-legend-item {
        display: inline-flex;
        align-items: center;
        margin-right: 15px;
    }
    .manhattan-legend-color {
        width: 12px;
        height: 12px;
        border-radius: 50%;
        margin-right: 5px;
    }
</style>

<h2>Gene Expression Plot - High Level TPM Values</h2>

<div class="manhattan-stats" id="manhattanStats" style="display: none;">
    <div>Total Genes: <span id="mpStatGenes">-</span></div>
    <div>Chromosomes: <span id="mpStatChromosomes">-</span></div>
    <div>Conditions: <span id="mpStatConditions">-</span></div>
    <div>Data Points: <span id="mpStatPoints">-</span></div>
    <div>TPM Range: <span id="mpStatTpmRange">-</span></div>
</div>

<div class="manhattan-controls">
    <div>
        <label for="mpCondition">Condition: </label>
        <select id="mpCondition">
            <option value="all">All Conditions</option>
        </select>
    </div>
    <div>
        <label for="mpChromosome">Chromosome: </label>
        <select id="mpChromosome">
            <option value="all">All Chromosomes</option>
        </select>
    </div>
    <div>
        <label for="mpMinTpm">Min TPM: </label>
        <input type="number" id="mpMinTpm" value="0" min="0" step="1" style="width: 70px;">
    </div>
    <div>
        <label for="mpLogScale">Y-Axis: </label>
        <select id="mpLogScale">
            <option value="log" selected>Log10(TPM+1)</option>
            <option value="linear">Linear TPM</option>
        </select>
    </div>
    <div>
        <label for="mpHighlight">Highlight TPM > </label>
        <input type="number" id="mpHighlight" value="1000" min="0" step="100" style="width: 80px;">
    </div>
</div>

<div class="manhattan-container">
    <div id="manhattanLoading" class="manhattan-loading">Loading expression data...</div>
    <div id="manhattanPlotChart" style="display: none;"></div>
</div>

<div class="manhattan-legend" id="manhattanLegend" style="display: none;">
    <strong>Expression Level:</strong>
    <span class="manhattan-legend-item"><span class="manhattan-legend-color" style="background: #e31a1c;"></span>High</span>
    <span class="manhattan-legend-item"><span class="manhattan-legend-color" style="background: #fd8d3c;"></span>Medium</span>
    <span class="manhattan-legend-item"><span class="manhattan-legend-color" style="background: #2865A3;"></span>Low</span>
    <span class="manhattan-legend-item"><span class="manhattan-legend-color" style="background: #999;"></span>Below Detection</span>
    <span style="margin-left: 20px;"><strong>Chromosomes:</strong> Alternating colors (odd: blue tones, even: yellow tones)</span>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        var rawData = null;
        var conditions = [];
        var chromosomes = [];
        var chromosomeOffsets = {};
        var chromosomeSizes = {};
        var totalGenomeLength = 0;

        // Chromosome order (numeric first, then X, Y, MT)
        var chrOrder = ['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','X','Y','MT'];

        // Alternating chromosome colors for Manhattan plot
        var chrColors = {
            odd: '#2865A3',   // Blue for odd chromosomes
            // even: '#7f7f7f'   // Gray for even chromosomes
            even: 'yellow'
        };

        // Level colors for expression levels
        var levelColors = {
            'high': '#e31a1c',
            'medium': '#fd8d3c',
            'low': '#2865A3',
            'below_detection': '#999999'
        };
        var url='/rgdweb/data/expression_observations_'+objectId+'.json'
        // Fetch JSON data with chromosome positions
        fetch(url)
            .then(function(response) {
                return response.json();
            })
            .then(function(data) {
                rawData = data;
                processInitialData();
                populateDropdowns();
                renderManhattanPlot();

                // Add event listeners
                document.getElementById('mpCondition').addEventListener('change', renderManhattanPlot);
                document.getElementById('mpChromosome').addEventListener('change', renderManhattanPlot);
                document.getElementById('mpMinTpm').addEventListener('change', renderManhattanPlot);
                document.getElementById('mpLogScale').addEventListener('change', renderManhattanPlot);
                document.getElementById('mpHighlight').addEventListener('change', renderManhattanPlot);
            })
            .catch(function(error) {
                console.error('Error loading expression data:', error);
                document.getElementById('manhattanLoading').textContent = 'Error loading data: ' + error.message;
            });

        function sortChromosomes(chrList) {
            return chrList.sort(function(a, b) {
                var aIdx = chrOrder.indexOf(a);
                var bIdx = chrOrder.indexOf(b);
                if (aIdx === -1) aIdx = 999;
                if (bIdx === -1) bIdx = 999;
                return aIdx - bIdx;
            });
        }

        function processInitialData() {
            if (!rawData) return;

            var conditionSet = new Set();
            var chrSet = new Set();
            var chrMaxPos = {};

            // First pass: find all chromosomes, conditions, and max positions
            rawData.forEach(function(item) {
                conditionSet.add(item.condition);
                if (item.chr) {
                    chrSet.add(item.chr);
                    var pos = item.geneStop || item.geneStart || 0;
                    if (!chrMaxPos[item.chr] || pos > chrMaxPos[item.chr]) {
                        chrMaxPos[item.chr] = pos;
                    }
                }
            });

            conditions = Array.from(conditionSet).sort();
            chromosomes = sortChromosomes(Array.from(chrSet));

            // Calculate chromosome offsets for linear x-axis
            var offset = 0;
            chromosomes.forEach(function(chr) {
                chromosomeOffsets[chr] = offset;
                chromosomeSizes[chr] = chrMaxPos[chr] || 0;
                offset += chromosomeSizes[chr];
            });
            totalGenomeLength = offset;
        }

        function populateDropdowns() {
            // Populate conditions dropdown
            var condSelect = document.getElementById('mpCondition');
            conditions.forEach(function(cond) {
                var option = document.createElement('option');
                option.value = cond;
                option.textContent = cond.length > 50 ? cond.substring(0, 50) + '...' : cond;
                option.title = cond;
                condSelect.appendChild(option);
            });

            // Populate chromosomes dropdown
            var chrSelect = document.getElementById('mpChromosome');
            chromosomes.forEach(function(chr) {
                var option = document.createElement('option');
                option.value = chr;
                option.textContent = 'Chr ' + chr;
                chrSelect.appendChild(option);
            });
        }

        function getGenomicX(chr, position) {
            // Calculate x position on the genome-wide scale
            var offset = chromosomeOffsets[chr] || 0;
            return offset + (position || 0);
        }

        function renderManhattanPlot() {
            if (!rawData) return;

            var selectedCondition = document.getElementById('mpCondition').value;
            var selectedChromosome = document.getElementById('mpChromosome').value;
            var minTpm = parseFloat(document.getElementById('mpMinTpm').value) || 0;
            var logScale = document.getElementById('mpLogScale').value === 'log';
            var highlightThreshold = parseFloat(document.getElementById('mpHighlight').value) || 1000;

            // Filter data
            var filteredData = rawData.filter(function(item) {
                if (selectedCondition !== 'all' && item.condition !== selectedCondition) {
                    return false;
                }
                if (selectedChromosome !== 'all' && item.chr !== selectedChromosome) {
                    return false;
                }
                if (!item.chr) return false; // Skip items without chromosome data
                return item.tpm >= minTpm;
            });

            var traces = [];
            var maxTpm = 0;
            var minTpmVal = Infinity;
            var totalPoints = 0;
            var displayedGenes = new Set();
            var displayedChromosomes = new Set();

            // Determine which chromosomes to display
            var displayChromosomes = selectedChromosome === 'all' ? chromosomes : [selectedChromosome];

            // Create one trace per chromosome (for alternating colors)
            displayChromosomes.forEach(function(chr, chrIndex) {
                var chrData = filteredData.filter(function(item) {
                    return item.chr === chr;
                });

                if (chrData.length === 0) return;

                var xData = [];
                var yData = [];
                var textData = [];
                var sizeData = [];
                var colorData = [];

                chrData.forEach(function(item) {
                    var xPos = selectedChromosome === 'all'
                        ? getGenomicX(item.chr, item.geneStart)
                        : item.geneStart;
                    var yVal = logScale ? Math.log10(item.tpm + 1) : item.tpm;

                    xData.push(xPos);
                    yData.push(yVal);

                    // Color by expression level
                    var color = levelColors[item.level] || levelColors['low'];
                    colorData.push(color);

                    sizeData.push(item.tpm >= highlightThreshold ? 10 : 5);

                    textData.push(
                        '<b>' + item.gene + '</b><br>' +
                        'Chr' + item.chr + ':' + item.geneStart.toLocaleString() + '-' + item.geneStop.toLocaleString() + '<br>' +
                        'Sample: ' + item.sample + '<br>' +
                        'TPM: ' + item.tpm.toFixed(2) + '<br>' +
                        'Level: ' + item.level + '<br>' +
                        'Condition: ' + (item.condition.length > 50 ? item.condition.substring(0, 50) + '...' : item.condition)
                    );

                    maxTpm = Math.max(maxTpm, item.tpm);
                    minTpmVal = Math.min(minTpmVal, item.tpm);
                    totalPoints++;
                    displayedGenes.add(item.gene);
                    displayedChromosomes.add(item.chr);
                });

                // Determine chromosome color (alternating)
                var chrIndexInOrder = chrOrder.indexOf(chr);
                if (chrIndexInOrder === -1) chrIndexInOrder = chromosomes.indexOf(chr);
                var baseColor = chrIndexInOrder % 2 === 0 ? chrColors.odd : chrColors.even;

                traces.push({
                    x: xData,
                    y: yData,
                    mode: 'markers',
                    type: 'scatter',
                    name: 'Chr ' + chr,
                    text: textData,
                    hoverinfo: 'text',
                    marker: {
                        size: sizeData,
                        color: colorData,
                        opacity: 0.7,
                        line: { color: baseColor, width: 1 }
                    },
                    showlegend: false
                });
            });

            // Add highlight threshold line
            var thresholdY = logScale ? Math.log10(highlightThreshold + 1) : highlightThreshold;
            var xMax = selectedChromosome === 'all' ? totalGenomeLength : (chromosomeSizes[selectedChromosome] || 0);
            traces.push({
                x: [0, xMax],
                y: [thresholdY, thresholdY],
                mode: 'lines',
                type: 'scatter',
                name: 'Threshold (' + highlightThreshold + ' TPM)',
                line: {
                    color: '#ff0000',
                    width: 1.5,
                    dash: 'dash'
                },
                hoverinfo: 'name',
                showlegend: true
            });

            // Update stats
            document.getElementById('manhattanStats').style.display = 'flex';
            document.getElementById('mpStatGenes').textContent = displayedGenes.size;
            document.getElementById('mpStatChromosomes').textContent = displayedChromosomes.size;
            document.getElementById('mpStatConditions').textContent = selectedCondition === 'all' ? conditions.length : 1;
            document.getElementById('mpStatPoints').textContent = totalPoints.toLocaleString();
            document.getElementById('mpStatTpmRange').textContent = (minTpmVal === Infinity ? 0 : minTpmVal.toFixed(2)) + ' - ' + maxTpm.toFixed(2);

            // Generate chromosome tick positions and labels
            var tickVals = [];
            var tickText = [];

            if (selectedChromosome === 'all') {
                // Show chromosome labels at center of each chromosome
                displayChromosomes.forEach(function(chr) {
                    var chrStart = chromosomeOffsets[chr];
                    var chrSize = chromosomeSizes[chr];
                    var chrCenter = chrStart + chrSize / 2;
                    tickVals.push(chrCenter);
                    tickText.push(chr);
                });
            } else {
                // Show position labels for single chromosome
                var chrSize = chromosomeSizes[selectedChromosome] || 0;
                var step = Math.pow(10, Math.floor(Math.log10(chrSize / 5)));
                for (var pos = 0; pos <= chrSize; pos += step) {
                    tickVals.push(pos);
                    tickText.push((pos / 1000000).toFixed(0) + 'M');
                }
            }

            // Create chromosome boundary shapes
            var shapes = [];
            if (selectedChromosome === 'all') {
                displayChromosomes.forEach(function(chr, idx) {
                    var chrStart = chromosomeOffsets[chr];
                    var chrEnd = chrStart + chromosomeSizes[chr];
                    var chrIndexInOrder = chrOrder.indexOf(chr);
                    if (chrIndexInOrder === -1) chrIndexInOrder = idx;

                    // Add alternating background color
                    shapes.push({
                        type: 'rect',
                        xref: 'x',
                        yref: 'paper',
                        x0: chrStart,
                        x1: chrEnd,
                        y0: 0,
                        y1: 1,
                        fillcolor: chrIndexInOrder % 2 === 0 ? 'rgba(40, 101, 163, 0.05)' : 'rgba(127, 127, 127, 0.05)',
                        line: { width: 0 }
                    });
                });
            }

            var layout = {
                title: {
                    text: selectedChromosome === 'all'
                        ? 'Gene Expression High Level TPM Values - All Chromosomes'
                        : 'Gene Expression High Level TPM Values - Chromosome ' + selectedChromosome,
                    font: { size: 16, color: '#2865A3' }
                },
                xaxis: {
                    title: selectedChromosome === 'all' ? 'Chromosome' : 'Position on Chr ' + selectedChromosome + ' (bp)',
                    tickmode: 'array',
                    tickvals: tickVals,
                    ticktext: tickText,
                    tickangle: selectedChromosome === 'all' ? 0 : -45,
                    tickfont: { size: 10 },
                    showgrid: false,
                    zeroline: false
                },
                yaxis: {
                    title: logScale ? 'Log10(TPM + 1)' : 'TPM',
                    gridcolor: '#eee',
                    showgrid: true,
                    zeroline: true,
                    zerolinecolor: '#ccc'
                },
                height: 500,
                margin: {
                    l: 80,
                    r: 50,
                    t: 60,
                    b: 80
                },
                paper_bgcolor: 'white',
                plot_bgcolor: 'white',
                hovermode: 'closest',
                showlegend: true,
                legend: {
                    x: 1,
                    y: 1,
                    bgcolor: 'rgba(255,255,255,0.8)',
                    bordercolor: '#ccc',
                    borderwidth: 1
                },
                shapes: shapes
            };

            var config = {
                responsive: true,
                displayModeBar: true,
                modeBarButtonsToRemove: ['lasso2d', 'select2d']
            };

            // Hide loading, show chart and legend
            document.getElementById('manhattanLoading').style.display = 'none';
            document.getElementById('manhattanPlotChart').style.display = 'block';
            document.getElementById('manhattanLegend').style.display = 'block';

            Plotly.newPlot('manhattanPlotChart', traces, layout, config);
        }
    });
</script>
