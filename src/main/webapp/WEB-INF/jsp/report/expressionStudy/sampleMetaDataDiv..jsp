<%@ page import="java.util.Set" %>
<%@ page import="java.util.LinkedHashSet" %>
<%--
  Created by IntelliJ IDEA.
  User: akundurthi
  Date: 7/21/2025
  Time: 3:19 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

  <style>
    .metadata-controls {
      display: flex;
      gap: 8px;
      align-items: center;
      margin-bottom: 15px;
    }

    .download-metadata-btn {
      padding: 6px 10px;
      background-color: #2865A3;
      color: white;
      border: none;
      border-radius: 3px;
      cursor: pointer;
      font-size: 11px;
      font-family: Arial, Helvetica, sans-serif;
    }

    .download-metadata-btn:hover {
      background-color: #1a4570;
    }

    /* Block display styles */
    .metadata-blocks-container {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
      gap: 15px;
      margin-top: 15px;
    }

    .metadata-block {
      background: #f9f9f9;
      border: 1px solid #ddd;
      border-radius: 5px;
      padding: 12px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    }

    .metadata-block-title {
      font-weight: bold;
      color: #2865A3;
      font-size: 13px;
      margin-bottom: 10px;
      padding-bottom: 5px;
      border-bottom: 2px solid #2865A3;
    }

    .metadata-values {
      display: flex;
      flex-wrap: wrap;
      gap: 6px;
    }

    .metadata-tag {
      background-color: #e7f1fa;
      color: #2865A3;
      padding: 4px 10px;
      border-radius: 15px;
      font-size: 12px;
      border: 1px solid #c5d9ed;
    }

    .metadata-tag.empty {
      background-color: #f5f5f5;
      color: #999;
      border-color: #ddd;
      font-style: italic;
    }

    .metadata-count {
      font-size: 11px;
      color: #666;
      margin-left: 5px;
    }
  </style>

<%
//  StudySampleMetadataDAO dao = new StudySampleMetadataDAO();
//  List<StudySampleMetadata> metadata = dao.getStudySampleMetadata(obj.getId());
  if(metadata != null && !metadata.isEmpty()){
    // Collect unique values for each field
    Set<String> uniqueSamples = new LinkedHashSet<>();
    Set<String> uniqueTissues = new LinkedHashSet<>();
    Set<String> uniqueStrains = new LinkedHashSet<>();
    Set<String> uniqueSex = new LinkedHashSet<>();
    Set<String> uniqueComputedSex = new LinkedHashSet<>();
    Set<String> uniqueAges = new LinkedHashSet<>();
    Set<String> uniqueLifeStages = new LinkedHashSet<>();
    Set<String> uniqueConditions = new LinkedHashSet<>();
    Set<String> uniqueCellTypes = new LinkedHashSet<>();
    Set<String> uniqueOrdinalities = new LinkedHashSet<>();

    for(StudySampleMetadata data : metadata) {
      if(data.getGeoSampleAcc() != null && !data.getGeoSampleAcc().trim().isEmpty()) {
        uniqueSamples.add(data.getGeoSampleAcc().trim());
      }
      if(data.getTissue() != null && !data.getTissue().trim().isEmpty()) {
        uniqueTissues.add(data.getTissue().trim());
      }
      if(data.getStrain() != null && !data.getStrain().trim().isEmpty()) {
        uniqueStrains.add(data.getStrain().trim());
      }
      if(data.getSex() != null && !data.getSex().trim().isEmpty()) {
        uniqueSex.add(data.getSex().trim());
      }
      if(data.getComputedSex() != null && !data.getComputedSex().trim().isEmpty()) {
        uniqueComputedSex.add(data.getComputedSex().trim());
      }
      if(data.getLifeStage() != null && !data.getLifeStage().trim().isEmpty()) {
        uniqueLifeStages.add(data.getLifeStage().trim());
      }
      if(data.getExperimentalConditions() != null && !data.getExperimentalConditions().trim().isEmpty()) {
        uniqueConditions.add(data.getExperimentalConditions().trim());
      }
      if(data.getCellType() != null && !data.getCellType().trim().isEmpty()) {
        uniqueCellTypes.add(data.getCellType().trim());
      }
      if(data.getOrdinality() != null && !data.getOrdinality().toString().isEmpty()) {
        uniqueOrdinalities.add(data.getOrdinality().toString());
      }
      // Handle age
      Double lowBound = data.getAgeDaysFromDobLowBound();
      Double highBound = data.getAgeDaysFromDobHighBound();
      if(lowBound != null && highBound != null) {
        if(lowBound.equals(highBound)) {
          uniqueAges.add(String.valueOf(lowBound.intValue()));
        } else {
          uniqueAges.add(lowBound.intValue() + "-" + highBound.intValue());
        }
      }
    }
%>
<hr>
<div id="sampleMetadata" class="subTitle"><h2>Sample Metadata Summary</h2></div>

<div class="metadata-controls">
<%--  <button class="download-metadata-btn" id="downloadBtn">Download Metadata</button>--%>
  <span class="metadata-count">Total Samples: <%=uniqueSamples.size()%></span>
</div>

<div class="metadata-blocks-container">
  <!-- Samples Block -->
  <div class="metadata-block">
    <div class="metadata-block-title">Samples (GEO Accession) <span class="metadata-count">(<%=uniqueSamples.size()%>)</span></div>
    <div class="metadata-values">
      <% if(uniqueSamples.isEmpty()) { %>
      <span class="metadata-tag empty">No data</span>
      <% } else { for(String sample : uniqueSamples) { %>
      <span class="metadata-tag"><%=sample%></span>
      <% }} %>
    </div>
  </div>

  <!-- Tissue Block -->
  <div class="metadata-block">
    <div class="metadata-block-title">Tissue <span class="metadata-count">(<%=uniqueTissues.size()%>)</span></div>
    <div class="metadata-values">
      <% if(uniqueTissues.isEmpty()) { %>
      <span class="metadata-tag empty">No data</span>
      <% } else { for(String tissue : uniqueTissues) { %>
      <span class="metadata-tag"><%=tissue%></span>
      <% }} %>
    </div>
  </div>

  <!-- Strain Block -->
  <div class="metadata-block">
    <div class="metadata-block-title">Strain <span class="metadata-count">(<%=uniqueStrains.size()%>)</span></div>
    <div class="metadata-values">
      <% if(uniqueStrains.isEmpty()) { %>
      <span class="metadata-tag empty">No data</span>
      <% } else { for(String strain : uniqueStrains) { %>
      <span class="metadata-tag"><%=strain%></span>
      <% }} %>
    </div>
  </div>

  <!-- Sex Block -->
  <div class="metadata-block">
    <div class="metadata-block-title">Sex <span class="metadata-count">(<%=uniqueSex.size()%>)</span></div>
    <div class="metadata-values">
      <% if(uniqueSex.isEmpty()) { %>
      <span class="metadata-tag empty">No data</span>
      <% } else { for(String sex : uniqueSex) { %>
      <span class="metadata-tag"><%=sex%></span>
      <% }} %>
    </div>
  </div>

  <!-- Computed Sex Block -->
  <div class="metadata-block">
    <div class="metadata-block-title">Computed Sex <span class="metadata-count">(<%=uniqueComputedSex.size()%>)</span></div>
    <div class="metadata-values">
      <% if(uniqueComputedSex.isEmpty()) { %>
      <span class="metadata-tag empty">No data</span>
      <% } else { for(String compSex : uniqueComputedSex) { %>
      <span class="metadata-tag"><%=compSex%></span>
      <% }} %>
    </div>
  </div>

  <!-- Age Block -->
  <div class="metadata-block">
    <div class="metadata-block-title">Age (in days) <span class="metadata-count">(<%=uniqueAges.size()%>)</span></div>
    <div class="metadata-values">
      <% if(uniqueAges.isEmpty()) { %>
      <span class="metadata-tag empty">No data</span>
      <% } else { for(String age : uniqueAges) { %>
      <span class="metadata-tag"><%=age%></span>
      <% }} %>
    </div>
  </div>

  <!-- Life Stage Block -->
  <div class="metadata-block">
    <div class="metadata-block-title">Life Stage <span class="metadata-count">(<%=uniqueLifeStages.size()%>)</span></div>
    <div class="metadata-values">
      <% if(uniqueLifeStages.isEmpty()) { %>
      <span class="metadata-tag empty">No data</span>
      <% } else { for(String lifeStage : uniqueLifeStages) { %>
      <span class="metadata-tag"><%=lifeStage%></span>
      <% }} %>
    </div>
  </div>

  <!-- Experimental Conditions Block -->
  <div class="metadata-block">
    <div class="metadata-block-title">Experimental Conditions <span class="metadata-count">(<%=uniqueConditions.size()%>)</span></div>
    <div class="metadata-values">
      <% if(uniqueConditions.isEmpty()) { %>
      <span class="metadata-tag empty">No data</span>
      <% } else { for(String condition : uniqueConditions) { %>
      <span class="metadata-tag"><%=condition%></span>
      <% }} %>
    </div>
  </div>

  <!-- Ordinality Block -->
  <div class="metadata-block">
    <div class="metadata-block-title">Ordinality <span class="metadata-count">(<%=uniqueOrdinalities.size()%>)</span></div>
    <div class="metadata-values">
      <% if(uniqueOrdinalities.isEmpty()) { %>
      <span class="metadata-tag empty">No data</span>
      <% } else { for(String ordinality : uniqueOrdinalities) { %>
      <span class="metadata-tag"><%=ordinality%></span>
      <% }} %>
    </div>
  </div>

  <!-- Cell Type Block -->
  <% if(!uniqueCellTypes.isEmpty()) { %>
  <div class="metadata-block">
    <div class="metadata-block-title">Cell Type <span class="metadata-count">(<%=uniqueCellTypes.size()%>)</span></div>
    <div class="metadata-values">
      <% for(String cellType : uniqueCellTypes) { %>
      <span class="metadata-tag"><%=cellType%></span>
      <% } %>
    </div>
  </div>
  <% } %>
</div>
<%}%>

<script>
  document.addEventListener('DOMContentLoaded', function() {
    // Download button
    const downloadBtn = document.getElementById('downloadBtn');
    if (downloadBtn) {
      downloadBtn.addEventListener('click', function() {
        const urlParams = new URLSearchParams(window.location.search);
        const studyId = urlParams.get('id');

        if (studyId) {
          window.location.href = '/rgdweb/report/expressionStudy/downloadMetadata.html?id=' + studyId;
        } else {
          alert('Study ID not found');
        }
      });
    }
  });
</script>

