<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 1/12/2026
  Time: 12:12 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    .heatmap-container {
        overflow-x: auto;
        margin: 20px 0;
    }
    .heatmap-table {
        border-collapse: collapse;
        font-size: 11px;
    }
    .heatmap-table th, .heatmap-table td {
        border: 1px solid #ddd;
        padding: 4px 8px;
        text-align: center;
        min-width: 60px;
    }
    .heatmap-table th {
        background-color: #2865A3;
        color: white;
        position: sticky;
        top: 0;
    }
    .heatmap-table th.gene-header {
        background-color: #1a4570;
        position: sticky;
        left: 0;
        z-index: 2;
    }
    .heatmap-table td.gene-cell {
        background-color: #f5f5f5;
        font-weight: bold;
        position: sticky;
        left: 0;
        z-index: 1;
    }
    .heatmap-cell {
        color: white;
        font-weight: bold;
    }
    .loading-spinner {
        text-align: center;
        padding: 40px;
        font-size: 14px;
        color: #666;
    }
    .controls {
        margin-bottom: 15px;
        display: flex;
        gap: 15px;
        align-items: center;
        flex-wrap: wrap;
    }
    .controls label {
        font-weight: bold;
        font-size: 12px;
    }
    .controls select, .controls input {
        padding: 5px 10px;
        border: 1px solid #ccc;
        border-radius: 3px;
    }
    .legend {
        display: flex;
        align-items: center;
        gap: 5px;
        margin-left: 20px;
        font-size: 11px;
    }
    .legend-gradient {
        width: 150px;
        height: 15px;
        background: linear-gradient(to right, #ffffcc, #ffeda0, #fed976, #feb24c, #fd8d3c, #fc4e2a, #e31a1c, #b10026);
        border: 1px solid #ccc;
    }
    .summary-stats {
        margin: 20px 0;
        padding: 15px;
        background: #f9f9f9;
        border-radius: 5px;
    }
    .summary-stats h5 {
        margin-top: 0;
        color: #2865A3;
    }
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
        gap: 10px;
    }
    .stat-item {
        background: white;
        padding: 10px;
        border-radius: 3px;
        border: 1px solid #ddd;
    }
    .stat-label {
        font-size: 11px;
        color: #666;
    }
    .stat-value {
        font-size: 18px;
        font-weight: bold;
        color: #2865A3;
    }
</style>

<h4>Expression Values: <span id="highValuesCount">Loading...</span></h4>

<div class="summary-stats" id="summaryStats" style="display: none;">
    <h5>Summary Statistics</h5>
    <div class="stats-grid">
        <div class="stat-item">
            <div class="stat-label">Total Records</div>
            <div class="stat-value" id="statTotal">-</div>
        </div>
        <div class="stat-item">
            <div class="stat-label">Unique Genes</div>
            <div class="stat-value" id="statGenes">-</div>
        </div>
        <div class="stat-item">
            <div class="stat-label">Unique Conditions</div>
            <div class="stat-value" id="statConditions">-</div>
        </div>
        <div class="stat-item">
            <div class="stat-label">Max TPM</div>
            <div class="stat-value" id="statMaxTpm">-</div>
        </div>
    </div>
</div>

<div class="controls">
    <div>
        <label for="topGenesSelect">Show Top Genes: </label>
        <select id="topGenesSelect">
            <option value="25">25</option>
            <option value="50" selected>50</option>
            <option value="100">100</option>
            <option value="200">200</option>
        </select>
    </div>
    <div>
        <label for="sortBySelect">Sort By: </label>
        <select id="sortBySelect">
            <option value="maxTpm" selected>Max TPM</option>
            <option value="meanTpm">Mean TPM</option>
            <option value="name">Gene Name</option>
        </select>
    </div>
    <div class="legend">
        <span>Low TPM</span>
        <div class="legend-gradient"></div>
        <span>High TPM</span>
    </div>
</div>

<h5>Mean TPM Heatmap (Gene vs Condition)</h5>
<div class="heatmap-container">
    <div id="heatmapLoading" class="loading-spinner">Loading data and generating heatmap...</div>
    <table class="heatmap-table" id="heatmapTable" style="display: none;">
        <thead id="heatmapHeader"></thead>
        <tbody id="heatmapBody"></tbody>
    </table>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        var allData = null;
        var aggregatedData = null;
        var conditions = [];
        var maxTpmValue = 0;

        // Fetch JSON data from file
        fetch('/rgdweb/data/expression_observations.json')
            .then(function(response) {
                return response.json();
            })
            .then(function(data) {
                allData = data;
                document.getElementById('highValuesCount').textContent = data.length + ' records';

                // Aggregate data: calculate mean TPM per gene-condition pair
                var geneConditionMap = {};
                var conditionSet = new Set();
                var geneSet = new Set();

                data.forEach(function(item) {
                    var key = item.gene + '|' + item.condition;
                    if (!geneConditionMap[key]) {
                        geneConditionMap[key] = {
                            gene: item.gene,
                            condition: item.condition,
                            tpmSum: 0,
                            count: 0,
                            maxTpm: 0
                        };
                    }
                    geneConditionMap[key].tpmSum += item.tpm;
                    geneConditionMap[key].count++;
                    geneConditionMap[key].maxTpm = Math.max(geneConditionMap[key].maxTpm, item.tpm);
                    conditionSet.add(item.condition);
                    geneSet.add(item.gene);
                });

                // Calculate mean and find max TPM for color scaling
                conditions = Array.from(conditionSet).sort();
                var genes = Array.from(geneSet);

                // Build gene data with aggregated values
                var geneData = {};
                Object.keys(geneConditionMap).forEach(function(key) {
                    var entry = geneConditionMap[key];
                    var meanTpm = entry.tpmSum / entry.count;
                    if (!geneData[entry.gene]) {
                        geneData[entry.gene] = {
                            gene: entry.gene,
                            conditions: {},
                            maxTpm: 0,
                            meanTpm: 0,
                            totalSum: 0,
                            totalCount: 0
                        };
                    }
                    geneData[entry.gene].conditions[entry.condition] = {
                        mean: meanTpm,
                        max: entry.maxTpm,
                        count: entry.count
                    };
                    geneData[entry.gene].maxTpm = Math.max(geneData[entry.gene].maxTpm, entry.maxTpm);
                    geneData[entry.gene].totalSum += entry.tpmSum;
                    geneData[entry.gene].totalCount += entry.count;
                    maxTpmValue = Math.max(maxTpmValue, meanTpm);
                });

                // Calculate overall mean for each gene
                Object.keys(geneData).forEach(function(gene) {
                    geneData[gene].meanTpm = geneData[gene].totalSum / geneData[gene].totalCount;
                });

                aggregatedData = geneData;

                // Update summary stats
                document.getElementById('summaryStats').style.display = 'block';
                document.getElementById('statTotal').textContent = data.length.toLocaleString();
                document.getElementById('statGenes').textContent = genes.length.toLocaleString();
                document.getElementById('statConditions').textContent = conditions.length;
                document.getElementById('statMaxTpm').textContent = maxTpmValue.toFixed(2);

                // Render heatmap
                renderHeatmap();

                // Add event listeners for controls
                document.getElementById('topGenesSelect').addEventListener('change', renderHeatmap);
                document.getElementById('sortBySelect').addEventListener('change', renderHeatmap);
            })
            .catch(function(error) {
                console.error('Error loading expression data:', error);
                document.getElementById('highValuesCount').textContent = 'Error loading data';
                document.getElementById('heatmapLoading').textContent = 'Error loading data: ' + error.message;
            });

        function renderHeatmap() {
            if (!aggregatedData) return;

            var topN = parseInt(document.getElementById('topGenesSelect').value);
            var sortBy = document.getElementById('sortBySelect').value;

            // Sort genes
            var sortedGenes = Object.keys(aggregatedData).sort(function(a, b) {
                if (sortBy === 'maxTpm') {
                    return aggregatedData[b].maxTpm - aggregatedData[a].maxTpm;
                } else if (sortBy === 'meanTpm') {
                    return aggregatedData[b].meanTpm - aggregatedData[a].meanTpm;
                } else {
                    return a.localeCompare(b);
                }
            });

            // Take top N genes
            var displayGenes = sortedGenes.slice(0, topN);

            // Build header
            var headerHtml = '<tr><th class="gene-header">Gene</th>';
            conditions.forEach(function(cond) {
                headerHtml += '<th title="' + cond + '">' + (cond.length > 15 ? cond.substring(0, 15) + '...' : cond) + '</th>';
            });
            headerHtml += '</tr>';
            document.getElementById('heatmapHeader').innerHTML = headerHtml;

            // Build body
            var bodyHtml = '';
            displayGenes.forEach(function(gene) {
                bodyHtml += '<tr><td class="gene-cell">' + gene + '</td>';
                conditions.forEach(function(cond) {
                    var cellData = aggregatedData[gene].conditions[cond];
                    if (cellData) {
                        var color = getHeatmapColor(cellData.mean, maxTpmValue);
                        bodyHtml += '<td class="heatmap-cell" style="background-color: ' + color + ';" ' +
                                    'title="Gene: ' + gene + '\nCondition: ' + cond + '\nMean TPM: ' + cellData.mean.toFixed(2) + '\nMax TPM: ' + cellData.max.toFixed(2) + '\nSamples: ' + cellData.count + '">' +
                                    cellData.mean.toFixed(1) + '</td>';
                    } else {
                        bodyHtml += '<td style="background-color: #f0f0f0; color: #999;">-</td>';
                    }
                });
                bodyHtml += '</tr>';
            });
            document.getElementById('heatmapBody').innerHTML = bodyHtml;

            // Show table, hide loading
            document.getElementById('heatmapLoading').style.display = 'none';
            document.getElementById('heatmapTable').style.display = 'table';
        }

        function getHeatmapColor(value, maxValue) {
            // Color scale from yellow to red
            var ratio = Math.min(value / maxValue, 1);
            var colors = [
                [255, 255, 204],  // light yellow
                [255, 237, 160],
                [254, 217, 118],
                [254, 178, 76],
                [253, 141, 60],
                [252, 78, 42],
                [227, 26, 28],
                [177, 0, 38]      // dark red
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
    });
</script>
