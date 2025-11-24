<%--
  Created by IntelliJ IDEA.
  User: akundurthi
  Date: 7/21/2025
  Time: 3:19 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <style>
        .metadata-controls {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .download-metadata-btn, .column-selection-btn {
            padding: 6px 10px;
            background-color: #2865A3;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            font-size: 11px;
            font-family: Arial, Helvetica, sans-serif;
        }

        .download-metadata-btn:hover, .column-selection-btn:hover {
            background-color: #1a4570;
        }

        .dropdown-arrow {
            margin-left: 4px;
            transition: transform 0.2s ease;
            display: inline-block;
        }

        .dropdown-arrow.rotated {
            transform: rotate(180deg);
        }

        .column-panel {
            display: none;
            background: #f9f9f9;
            border: 1px solid #ddd;
            border-radius: 3px;
            padding: 10px;
            margin-bottom: 8px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .panel-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 8px;
            font-weight: bold;
            color: #2865A3;
            font-size: 12px;
        }

        .panel-controls {
            display: flex;
            gap: 6px;
        }

        .select-all-btn, .hide-all-btn {
            padding: 4px 8px;
            background-color: #f1f1f1;
            border: 1px solid #ccc;
            border-radius: 2px;
            cursor: pointer;
            font-size: 10px;
        }

        .select-all-btn:hover, .hide-all-btn:hover {
            background-color: #e0e0e0;
        }

        .checkbox-list {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 6px;
            margin-top: 6px;
        }

        .checkbox-item {
            display: flex;
            align-items: center;
            gap: 4px;
            padding: 2px;
        }

        .checkbox-item input[type="checkbox"] {
            margin: 0;
        }

        .checkbox-item label {
            font-size: 11px;
            cursor: pointer;
            margin: 0;
        }

        /* Hide new columns by default */
        .col-experiment-id { display: none; }
        .col-cell-type { display: none; }
        .col-dose { display: none; }
        .col-duration { display: none; }
        .col-application-method { display: none; }
        .col-notes { display: none; }
    </style>
</head>
<body>
<%
    StudySampleMetadataDAO dao = new StudySampleMetadataDAO();
    List<StudySampleMetadata>metadata = dao.getStudySampleMetadata(obj.getId());
    if(metadata!=null&&!metadata.isEmpty()){
%>
<hr>
<div id="sampleMetadata" class="subTitle"><h2>Sample Metadata</h2></div>

<!-- Pagination and Control Buttons -->
<div class="search-and-pager">
    <div class="modelsViewContent">
        <div class="pager sampleMetadataPager">
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option value="40">40</option>
                    <option value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
<%--        <input class="search table-search" id="sampleDataSearch" type="search" data-column="all" placeholder="Search table">--%>
    </div>

    <div class="metadata-controls">
        <button class="download-metadata-btn" id="downloadBtn">Download Metadata</button>
        <button class="column-selection-btn" id="columnBtn">
            Column Selection <span class="dropdown-arrow" id="dropdownArrow">▼</span>
        </button>
    </div>
</div>

<!-- Column Selection Panel -->
<div id="columnPanel" class="column-panel">
    <div class="panel-header">
        <span>Select Columns to Display</span>
        <div class="panel-controls">
            <button class="select-all-btn" id="selectAllBtn">Select All</button>
            <button class="hide-all-btn" id="hideAllBtn">Clear All</button>
        </div>
    </div>

    <div class="checkbox-list">
        <div class="checkbox-item">
            <input type="checkbox" id="col-geo-accession" checked>
            <label for="col-geo-accession">GEO Accession</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-experiment-id">
            <label for="col-experiment-id">Experiment ID</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-tissue" checked>
            <label for="col-tissue">Tissue</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-strain" checked>
            <label for="col-strain">Strain</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-sex" checked>
            <label for="col-sex">Sex</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-computed-sex" checked>
            <label for="col-computed-sex">Computed Sex</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-age" checked>
            <label for="col-age">Age (in days)</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-life-stage" checked>
            <label for="col-life-stage">Life Stage</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-experimental-conditions" checked>
            <label for="col-experimental-conditions">Experimental Conditions</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-ordinality" checked>
            <label for="col-ordinality">Ordinality</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-cell-type">
            <label for="col-cell-type">Cell Type</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-dose">
            <label for="col-dose">Dose</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-duration">
            <label for="col-duration">Duration</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-application-method">
            <label for="col-application-method">Application Method</label>
        </div>
        <div class="checkbox-item">
            <input type="checkbox" id="col-notes">
            <label for="col-notes">Notes</label>
        </div>
    </div>
</div>

<div id="sampleMetadataTableDiv" class="annotation-detail">
    <table>
        <tr>
            <th class="col-geo-accession">geo_accession</th>
            <th class="col-experiment-id">Experiment ID</th>
            <th class="col-tissue">Tissue</th>
            <th class="col-cell-type">Cell Type</th>
            <th class="col-strain">Strain</th>
            <th class="col-sex">Sex</th>
            <th class="col-computed-sex">Computed Sex</th>
            <th class="col-age">Age(in days)</th>
            <th class="col-life-stage">Life Stage</th>
            <th class="col-experimental-conditions">Experimental_Conditions</th>
            <th class="col-ordinality">Ordinality</th>
            <th class="col-dose">Dose</th>
            <th class="col-duration">Duration</th>
            <th class="col-application-method">Application Method</th>
            <th class="col-notes">Notes</th>
        </tr>
        <%for(StudySampleMetadata data:metadata){%>
        <tr>
            <td class="col-geo-accession"><%=data.getGeoSampleAcc()!=null?data.getGeoSampleAcc():""%></td>
            <td class="col-experiment-id"><%=data.getExperimentId()!=null?data.getExperimentId():""%></td>
            <td class="col-tissue"><%=data.getTissue()!=null?data.getTissue():""%></td>
            <!-- non default column cell type -->
            <td class="col-cell-type"><%=data.getCellType()!=null?data.getCellType():""%></td>
            <td class="col-strain"><%=data.getStrain()!=null?data.getStrain():""%></td>
            <td class="col-sex"><%=data.getSex()!=null?data.getSex():""%></td>
            <td class="col-computed-sex"><%=data.getComputedSex()!=null?data.getComputedSex():""%></td>
            <%
                Double lowBound = data.getAgeDaysFromDobLowBound();
                Double highBound = data.getAgeDaysFromDobHighBound();
                if(lowBound != null && highBound != null && lowBound.equals(highBound)){
            %>
            <td class="col-age"><%=lowBound.intValue()%></td>
            <%}else if(lowBound != null && highBound != null){%>
            <td class="col-age"><%=lowBound.intValue()%>-<%=highBound.intValue()%></td>
            <%}else{%>
            <td class="col-age"></td>
            <%}%>
            <td class="col-life-stage"><%=data.getLifeStage()!=null?data.getLifeStage():""%></td>
            <td class="col-experimental-conditions"><%=data.getExperimentalConditions()!=null?data.getExperimentalConditions():""%></td>
            <td class="col-ordinality"><%=data.getOrdinality()!=null?data.getOrdinality():""%></td>
            <!-- non default columns -->
            <!-- Dose column -->
            <td class="col-dose">
                <%
                    Double minVal = data.getExpCondAssocValueMin();
                    Double maxVal = data.getExpCondAssocValueMax();
                    String units = data.getExpCondAssocUnits();
                    String doseText = "";

                    if(minVal != null && maxVal != null && units != null) {
                        if(minVal.equals(maxVal)) {
                            doseText = minVal + " " + units;
                        } else {
                            doseText = minVal + " " + units + " - " + maxVal + " " + units;
                        }
                    }
                %>
                <%=doseText%>
            </td>

            <!-- Duration column -->
            <td class="col-duration">
                <%
                    Double durLow = data.getExpCondDurSecLowBound();
                    Double durHigh = data.getExpCondDurSecHighBound();

                    String durationText = "";
                    if (durLow != null && durHigh != null && durLow != 0.0) {
                        // Determine the maximum value to decide unit
                        double maxDuration = Math.max(durLow, durHigh);

                        String unit;
                        double divisor;

                        if (maxDuration >= 31536000) { // ≥ 1 year
                            unit = "years";
                            divisor = 31536000.0;
                        }
                        else if (maxDuration >= 86400) { // ≥ 1 day
                            unit = "days";
                            divisor = 86400.0;
                        }
                        else if (maxDuration >= 3600) { // ≥ 1 hour
                            unit = "hours";
                            divisor = 3600.0;
                        }
                        else if (maxDuration >= 60) { // ≥ 1 minute
                            unit = "minutes";
                            divisor = 60.0;
                        }
                        else {
                            unit = "secs";
                            divisor = 1.0;
                        }

                        // Convert values to above unit
                        double convertedLow = durLow / divisor;
                        double convertedHigh = durHigh / divisor;

                        // kept single decimal value for now
                        if (convertedLow == convertedHigh) {
                            durationText = String.format("%.1f %s", convertedLow, unit);
                        }
                        else {
                            durationText = String.format("%.1f - %.1f %s", convertedLow, convertedHigh, unit);
                        }
                    }
                %>
                <%=durationText%>
            </td>
<%--            <td class="col-duration">--%>
<%--                <%--%>
<%--                    Double durLow = data.getExpCondDurSecLowBound();--%>
<%--                    Double durHigh = data.getExpCondDurSecHighBound();--%>

<%--                    String durationText = "";--%>
<%--                    if (durLow != null && durHigh != null && durLow != 0.0) {--%>
<%--                        durationText = durLow.equals(durHigh)--%>
<%--                                ? durLow.toString()--%>
<%--                                : durLow + " - " + durHigh;--%>
<%--                    }--%>
<%--                %>--%>
<%--                <%=durationText%>--%>
<%--            </td>--%>

            <td class="col-application-method"><%=data.getExpCondApplicationMethod()!=null?data.getExpCondApplicationMethod():""%></td>
            <td class="col-notes"><%=data.getExpCondNotes()!=null?data.getExpCondNotes():""%></td>
        </tr>
        <%}%>
    </table>
    <%}%>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const columnBtn = document.getElementById('columnBtn');
        const columnPanel = document.getElementById('columnPanel');
        const dropdownArrow = document.getElementById('dropdownArrow');

        // Panel show/hide with arrow rotation
        columnBtn.addEventListener('click', function() {
            if (columnPanel.style.display === 'none' || columnPanel.style.display === '') {
                columnPanel.style.display = 'block';
                dropdownArrow.classList.add('rotated');
            } else {
                columnPanel.style.display = 'none';
                dropdownArrow.classList.remove('rotated');
            }
        });

        // Column mapping
        const columnMapping = {
            'col-geo-accession': '.col-geo-accession',
            'col-experiment-id': '.col-experiment-id',
            'col-tissue': '.col-tissue',
            'col-strain': '.col-strain',
            'col-sex': '.col-sex',
            'col-computed-sex': '.col-computed-sex',
            'col-age': '.col-age',
            'col-life-stage': '.col-life-stage',
            'col-experimental-conditions': '.col-experimental-conditions',
            'col-ordinality': '.col-ordinality',
            'col-cell-type': '.col-cell-type',
            'col-dose': '.col-dose',
            'col-duration': '.col-duration',
            'col-application-method': '.col-application-method',
            'col-notes': '.col-notes'
        };

        // Individual checkbox functionality
        for (let checkboxId in columnMapping) {
            const cssSelector = columnMapping[checkboxId];
            const checkbox = document.getElementById(checkboxId);

            checkbox.addEventListener('change', function() {
                const columns = document.querySelectorAll(cssSelector);
                if (checkbox.checked) {
                    columns.forEach(column => {
                        column.style.display = 'table-cell';
                    });
                } else {
                    columns.forEach(column => {
                        column.style.display = 'none';
                    });
                }
            });
        }

        // When Experimental Conditions is checked, also check Ordinality
        const experimentalConditionsCheckbox = document.getElementById('col-experimental-conditions');
        const ordinalityCheckbox = document.getElementById('col-ordinality');

        experimentalConditionsCheckbox.addEventListener('change', function() {
            if (experimentalConditionsCheckbox.checked) {
                ordinalityCheckbox.checked = true;
                const ordinalityColumns = document.querySelectorAll('.col-ordinality');
                ordinalityColumns.forEach(column => {
                    column.style.display = 'table-cell';
                });
            }
        });

        // Select All functionality
        const selectAllBtn = document.getElementById('selectAllBtn');
        selectAllBtn.addEventListener('click', function() {
            for (let checkboxId in columnMapping) {
                const checkbox = document.getElementById(checkboxId);
                const columns = document.querySelectorAll(columnMapping[checkboxId]);
                checkbox.checked = true;
                columns.forEach(col => {
                    col.style.display = 'table-cell';
                });
            }
        });

        // Hide All functionality
        const hideAllBtn = document.getElementById('hideAllBtn');
        hideAllBtn.addEventListener('click', function() {
            for (let checkboxId in columnMapping) {
                const checkbox = document.getElementById(checkboxId);
                const columns = document.querySelectorAll(columnMapping[checkboxId]);
                checkbox.checked = false;
                columns.forEach(col => {
                    col.style.display = 'none';
                });
            }
        });

        // Download button
        const downloadBtn = document.getElementById('downloadBtn');
        downloadBtn.addEventListener('click', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const studyId = urlParams.get('id');

            if (studyId) {
                window.location.href = '/rgdweb/report/expressionStudy/downloadMetadata.html?id=' + studyId;
            } else {
                alert('Study ID not found');
            }
        })
    });
</script>

</body>
</html>