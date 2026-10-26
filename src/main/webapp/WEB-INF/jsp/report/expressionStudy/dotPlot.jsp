<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 1/20/2026
  Time: 11:37 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    .dotplot-container {
        margin: 20px 0;
        background: white;
        border-radius: 5px;
        padding: 15px;
    }
    .dotplot-controls {
        margin-bottom: 15px;
        display: flex;
        gap: 15px;
        align-items: center;
        flex-wrap: wrap;
    }
    .dotplot-controls label {
        font-weight: bold;
        font-size: 12px;
    }
    .dotplot-controls select, .dotplot-controls input {
        padding: 5px 10px;
        border: 1px solid #ccc;
        border-radius: 3px;
    }
    .dotplot-loading {
        text-align: center;
        padding: 40px;
        font-size: 14px;
        color: #666;
    }
    .dotplot-stats {
        margin: 15px 0;
        padding: 10px 15px;
        background: #f9f9f9;
        border-radius: 5px;
        font-size: 12px;
        display: flex;
        gap: 20px;
        flex-wrap: wrap;
    }
    .dotplot-stats span {
        color: #2865A3;
        font-weight: bold;
    }
    #dotPlotChart {
        width: 100%;
        min-height: 600px;
    }
</style>

<h4>Expression Dot Plot</h4>

<div class="dotplot-stats" id="dotPlotStats" style="display: none;">
    <div>Genes displayed: <span id="dpStatGenes">-</span></div>
    <div>Conditions: <span id="dpStatConditions">-</span></div>
    <div>TPM range: <span id="dpStatTpmRange">-</span></div>
</div>

<div class="dotplot-controls">
    <div>
        <label for="dpTopGenes">Top Genes: </label>
        <select id="dpTopGenes">
            <option value="15">15</option>
            <option value="25" selected>25</option>
            <option value="50">50</option>
            <option value="75">75</option>
        </select>
    </div>
    <div>
        <label for="dpSortBy">Sort By: </label>
        <select id="dpSortBy">
            <option value="maxTpm" selected>Max TPM</option>
            <option value="meanTpm">Mean TPM</option>
            <option value="name">Gene Name</option>
        </select>
    </div>
    <div>
        <label for="dpSizeBy">Dot Size: </label>
        <select id="dpSizeBy">
            <option value="meanTpm" selected>Mean TPM</option>
            <option value="percentExpressed">% Samples Expressed</option>
        </select>
    </div>
    <div>
        <label for="dpMinTpm">Min TPM: </label>
        <input type="number" id="dpMinTpm" value="1" min="0" step="0.5" style="width: 70px;">
    </div>
</div>

<div class="dotplot-container">
    <div id="dotPlotLoading" class="dotplot-loading">Loading expression data...</div>
    <div id="dotPlotChart" style="display: none;"></div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        var rawData = null;
        var processedData = null;
        var conditions = [];
        var globalMaxTpm = 0;
        var globalMinTpm = Infinity;

        // Fetch JSON data
        fetch('/rgdweb/data/expression_observations.json')
            .then(function(response) {
                return response.json();
            })
            .then(function(data) {
                rawData = data;
                processData();
                renderDotPlot();

                // Add event listeners
                document.getElementById('dpTopGenes').addEventListener('change', renderDotPlot);
                document.getElementById('dpSortBy').addEventListener('change', renderDotPlot);
                document.getElementById('dpSizeBy').addEventListener('change', renderDotPlot);
                document.getElementById('dpMinTpm').addEventListener('change', renderDotPlot);
            })
            .catch(function(error) {
                console.error('Error loading expression data:', error);
                document.getElementById('dotPlotLoading').textContent = 'Error loading data: ' + error.message;
            });

        function processData() {
            if (!rawData) return;

            var geneConditionMap = {};
            var conditionSet = new Set();
            var conditionSampleCounts = {};

            // First pass: count total samples per condition
            rawData.forEach(function(item) {
                conditionSet.add(item.condition);
                if (!conditionSampleCounts[item.condition]) {
                    conditionSampleCounts[item.condition] = new Set();
                }
                conditionSampleCounts[item.condition].add(item.sample);
            });

            conditions = Array.from(conditionSet).sort();

            // Convert sample sets to counts
            var conditionTotalSamples = {};
            Object.keys(conditionSampleCounts).forEach(function(cond) {
                conditionTotalSamples[cond] = conditionSampleCounts[cond].size;
            });

            // Second pass: aggregate by gene-condition
            rawData.forEach(function(item) {
                var key = item.gene + '|' + item.condition;
                if (!geneConditionMap[key]) {
                    geneConditionMap[key] = {
                        gene: item.gene,
                        condition: item.condition,
                        tpmSum: 0,
                        count: 0,
                        maxTpm: 0,
                        samples: new Set()
                    };
                }
                geneConditionMap[key].tpmSum += item.tpm;
                geneConditionMap[key].count++;
                geneConditionMap[key].maxTpm = Math.max(geneConditionMap[key].maxTpm, item.tpm);
                geneConditionMap[key].samples.add(item.sample);
            });

            // Build gene data
            var geneData = {};
            Object.keys(geneConditionMap).forEach(function(key) {
                var entry = geneConditionMap[key];
                var meanTpm = entry.tpmSum / entry.count;
                var totalSamplesInCondition = conditionTotalSamples[entry.condition] || 1;
                var percentExpressed = (entry.samples.size / totalSamplesInCondition) * 100;

                if (!geneData[entry.gene]) {
                    geneData[entry.gene] = {
                        gene: entry.gene,
                        conditions: {},
                        maxTpm: 0,
                        totalSum: 0,
                        totalCount: 0
                    };
                }
                geneData[entry.gene].conditions[entry.condition] = {
                    meanTpm: meanTpm,
                    maxTpm: entry.maxTpm,
                    sampleCount: entry.samples.size,
                    totalSamples: totalSamplesInCondition,
                    percentExpressed: percentExpressed
                };
                geneData[entry.gene].maxTpm = Math.max(geneData[entry.gene].maxTpm, entry.maxTpm);
                geneData[entry.gene].totalSum += entry.tpmSum;
                geneData[entry.gene].totalCount += entry.count;
                globalMaxTpm = Math.max(globalMaxTpm, meanTpm);
                globalMinTpm = Math.min(globalMinTpm, meanTpm);
            });

            // Calculate overall mean for each gene
            Object.keys(geneData).forEach(function(gene) {
                geneData[gene].meanTpm = geneData[gene].totalSum / geneData[gene].totalCount;
            });

            processedData = geneData;
        }

        function renderDotPlot() {
            if (!processedData) return;

            var topN = parseInt(document.getElementById('dpTopGenes').value);
            var sortBy = document.getElementById('dpSortBy').value;
            var sizeBy = document.getElementById('dpSizeBy').value;
            var minTpm = parseFloat(document.getElementById('dpMinTpm').value) || 0;

            // Sort genes
            var sortedGenes = Object.keys(processedData).sort(function(a, b) {
                if (sortBy === 'maxTpm') {
                    return processedData[b].maxTpm - processedData[a].maxTpm;
                } else if (sortBy === 'meanTpm') {
                    return processedData[b].meanTpm - processedData[a].meanTpm;
                } else {
                    return a.localeCompare(b);
                }
            });

            var displayGenes = sortedGenes.slice(0, topN);

            // Truncate condition labels for display
            var conditionLabels = conditions.map(function(cond) {
                return cond.length > 30 ? cond.substring(0, 30) + '...' : cond;
            });

            // Prepare data for Plotly
            var xData = [];
            var yData = [];
            var sizeData = [];
            var colorData = [];
            var hoverText = [];

            // Find max values for scaling
            var maxMeanTpm = 0;
            var maxPercent = 0;
            displayGenes.forEach(function(gene) {
                conditions.forEach(function(cond) {
                    var cellData = processedData[gene].conditions[cond];
                    if (cellData && cellData.meanTpm >= minTpm) {
                        maxMeanTpm = Math.max(maxMeanTpm, cellData.meanTpm);
                        maxPercent = Math.max(maxPercent, cellData.percentExpressed);
                    }
                });
            });

            displayGenes.forEach(function(gene) {
                conditions.forEach(function(cond, condIndex) {
                    var cellData = processedData[gene].conditions[cond];
                    if (cellData && cellData.meanTpm >= minTpm) {
                        xData.push(condIndex);
                        yData.push(gene);
                        colorData.push(cellData.meanTpm);

                        // Calculate size based on selected metric
                        var sizeValue;
                        if (sizeBy === 'percentExpressed') {
                            sizeValue = (cellData.percentExpressed / Math.max(maxPercent, 1)) * 30 + 5;
                        } else {
                            sizeValue = (cellData.meanTpm / Math.max(maxMeanTpm, 1)) * 30 + 5;
                        }
                        sizeData.push(sizeValue);

                        hoverText.push(
                            '<b>' + gene + '</b><br>' +
                            'Condition: ' + cond + '<br>' +
                            'Mean TPM: ' + cellData.meanTpm.toFixed(2) + '<br>' +
                            'Max TPM: ' + cellData.maxTpm.toFixed(2) + '<br>' +
                            'Samples: ' + cellData.sampleCount + '/' + cellData.totalSamples + '<br>' +
                            '% Expressed: ' + cellData.percentExpressed.toFixed(1) + '%'
                        );
                    }
                });
            });

            // Update stats
            document.getElementById('dotPlotStats').style.display = 'flex';
            document.getElementById('dpStatGenes').textContent = displayGenes.length;
            document.getElementById('dpStatConditions').textContent = conditions.length;
            document.getElementById('dpStatTpmRange').textContent = globalMinTpm.toFixed(2) + ' - ' + globalMaxTpm.toFixed(2);

            // Create Plotly trace
            var trace = {
                x: xData,
                y: yData,
                mode: 'markers',
                marker: {
                    size: sizeData,
                    color: colorData,
                    colorscale: [
                        [0, '#ffffcc'],
                        [0.125, '#ffeda0'],
                        [0.25, '#fed976'],
                        [0.375, '#feb24c'],
                        [0.5, '#fd8d3c'],
                        [0.625, '#fc4e2a'],
                        [0.75, '#e31a1c'],
                        [1, '#b10026']
                    ],
                    colorbar: {
                        title: 'Mean TPM',
                        thickness: 15,
                        len: 0.5
                    },
                    line: {
                        color: '#333',
                        width: 0.5
                    }
                },
                text: hoverText,
                hoverinfo: 'text',
                type: 'scatter'
            };

            var layout = {
                title: {
                    text: 'Gene Expression Dot Plot',
                    font: { size: 16, color: '#2865A3' }
                },
                xaxis: {
                    title: 'Condition',
                    tickmode: 'array',
                    tickvals: conditions.map(function(_, i) { return i; }),
                    ticktext: conditionLabels,
                    tickangle: -45,
                    tickfont: { size: 10 },
                    gridcolor: '#eee'
                },
                yaxis: {
                    title: 'Gene',
                    tickfont: { size: 10 },
                    gridcolor: '#eee',
                    autorange: 'reversed'
                },
                height: Math.max(600, displayGenes.length * 20 + 200),
                margin: {
                    l: 100,
                    r: 100,
                    t: 60,
                    b: 150
                },
                paper_bgcolor: 'white',
                plot_bgcolor: 'white',
                hovermode: 'closest'
            };

            var config = {
                responsive: true,
                displayModeBar: true,
                modeBarButtonsToRemove: ['lasso2d', 'select2d']
            };

            // Hide loading, show chart
            document.getElementById('dotPlotLoading').style.display = 'none';
            document.getElementById('dotPlotChart').style.display = 'block';

            Plotly.newPlot('dotPlotChart', [trace], layout, config);
        }
    });
</script>
