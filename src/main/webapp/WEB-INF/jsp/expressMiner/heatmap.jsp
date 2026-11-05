<%--
  Expression Miner heatmap panel.

  This is a STATIC include (pulled into result.jsp via <%@ include file="heatmap.jsp" %>), so it is a
  bare fragment -- no page directive, no <html>/<head>/<body>. It shares result.jsp's page scope and
  relies on globals defined there: `filteredRecords`, `allRecords`, `MAP_KEY`, `esc()`, and the Plotly
  library (loaded by headerarea.jsp). The toggle button that shows/hides this panel lives in result.jsp
  and calls toggleHeatmap() defined below.
--%>
<style>
  /* Heatmap panel */
  .em-heatmap-controls {
    display: flex;
    flex-wrap: wrap;
    gap: 14px;
    align-items: flex-end;
    padding: 12px 18px;
    border-bottom: 1px solid #dde5ef;
    font-size: 12px;
    color: #1a3a5a;
  }
  .em-heatmap-controls label {
    display: flex;
    flex-direction: column;
    gap: 3px;
    font-weight: 600;
  }
  .em-heatmap-controls select {
    padding: 5px 8px;
    border: 1px solid #bccada;
    border-radius: 4px;
    background: #f8fafc;
    font-size: 12px;
    min-width: 130px;
    cursor: pointer;
  }
  .em-heatmap-controls select:focus {
    outline: none;
    border-color: #3a7aba;
    box-shadow: 0 0 0 2px rgba(58, 122, 186, 0.15);
    background: #fff;
  }
  #emHeatmap { width: 100%; min-height: 320px; padding: 6px; }
</style>

<!-- Heatmap (toggled from the toolbar; driven by the same filtered records as the table) -->
<div id="emHeatmapCard" class="em-table-card" style="display:none; margin-bottom:20px;">
  <div class="em-table-meta">
    <span style="font-weight:600;">Expression Heatmap</span>
    <span id="emHeatmapNote" style="color:#7a8a9a; font-weight:normal;"></span>
  </div>
  <div class="em-heatmap-controls">
    <label>Rows
      <select id="emHmY" onchange="renderHeatmap()">
        <option value="gene">Gene</option>
        <option value="tissue">Tissue</option>
        <option value="strain">Strain</option>
      </select>
    </label>
    <label>Columns
      <select id="emHmX" onchange="renderHeatmap()">
        <option value="gene">Gene</option>
        <option value="tissue">Tissue</option>
        <option value="strain">Strain</option>
      </select>
    </label>
    <label>Value
      <select id="emHmAgg" onchange="renderHeatmap()">
        <option value="mean">Mean</option>
        <option value="max">Max</option>
        <option value="median">Median</option>
      </select>
    </label>
    <label>Color
      <select id="emHmColor" onchange="renderHeatmap()">
        <option value="YlOrRd">Full color (Yellow-Orange-Red)</option>
        <option value="Cividis">Protanopia - Cividis</option>
        <option value="Viridis">Deuteranopia - Viridis</option>
        <option value="Blues">Tritanopia - Blues</option>
        <option value="Greys">Monochromacy - Greyscale</option>
      </select>
    </label>
    <!-- Unit is last: on most assemblies it renders as static text (no dropdown), so keeping it at the
         end of the row avoids a gap in the line of dropdowns. -->
    <label>Unit
      <select id="emHmUnit" onchange="renderHeatmap()"></select>
      <span id="emHmUnitText" style="display:none; font-weight:600;"></span>
    </label>
  </div>
  <div style="padding: 8px 18px 0 18px; font-size: 12px; color: #7a8a9a; font-style: italic;">
    Based on the records shown in the results table (the current page and active filters).
  </div>
  <div id="emHeatmap"></div>
</div>

<script>
  // ---- Heatmap ---------------------------------------------------------------
  // Plotly is loaded globally by headerarea.jsp (cdn.plot.ly). The heatmap plots one chosen
  // dimension (gene/tissue/strain) on each axis, colored by an aggregate of the expression value.
  // It reads `filteredRecords` (defined in result.jsp), so it always matches what the table shows.

  var heatmapInited = false; // whether the row/column selects have been auto-picked yet

  var HEATMAP_DIMS = {
    gene:   { title: 'Gene',   keyOf: function (r) { return r.geneRgdId != null ? String(r.geneRgdId) : ''; },
                                labelOf: function (r) { return r.geneSymbol || r.geneSymbolWithRgdId || (r.geneRgdId != null ? String(r.geneRgdId) : ''); } },
    tissue: { title: 'Tissue', keyOf: function (r) { return r.tissueAcc || ''; },
                                labelOf: function (r) { return r.tissueTerm || r.tissueAcc || ''; } },
    strain: { title: 'Strain', keyOf: function (r) { return r.strainAcc || ''; },
                                labelOf: function (r) { return r.strainTerm || r.strainAcc || ''; } }
  };

  function isNumericValue(r) {
    return !(r.expressionValue === null || r.expressionValue === undefined || r.expressionValue === '' || isNaN(r.expressionValue));
  }

  function distinctDimCount(records, dim) {
    var seen = {};
    for (var i = 0; i < records.length; i++) {
      var k = HEATMAP_DIMS[dim].keyOf(records[i]);
      if (k) seen[k] = true;
    }
    return Object.keys(seen).length;
  }

  // Default the axes to the two dimensions with the most distinct values (a fuller grid).
  function autoPickDims(records) {
    var dims = ['gene', 'tissue', 'strain'];
    dims.sort(function (a, b) { return distinctDimCount(records, b) - distinctDimCount(records, a); });
    return { y: dims[0], x: dims[1] };
  }

  // Units can't be mixed in one aggregate (TPM vs counts), so the heatmap plots one unit at a time.
  function refreshUnitOptions(records) {
    var sel = document.getElementById('emHmUnit');
    var prev = sel.value;
    var counts = {};
    for (var i = 0; i < records.length; i++) {
      if (!isNumericValue(records[i])) continue;
      var u = records[i].expressionUnit || '';
      counts[u] = (counts[u] || 0) + 1;
    }
    var units = Object.keys(counts).sort(function (a, b) { return counts[b] - counts[a]; });
    sel.innerHTML = units.map(function (u) {
      return '<option value="' + esc(u) + '">' + esc(u || '(no unit)') + '</option>';
    }).join('');
    if (units.indexOf(prev) !== -1) sel.value = prev; // keep the user's unit across redraws when still present

    // A heatmap can only plot one unit at a time (TPM vs counts can't share a scale). Whenever the
    // current data actually spans more than one unit -- on ANY assembly -- offer the dropdown so every
    // unit's records (and the genes measured only in another unit) stay reachable. When there is just a
    // single unit, there is nothing to choose, so show it as static text with no dropdown.
    var txt = document.getElementById('emHmUnitText');
    if (units.length > 1) {
      sel.style.display = '';
      if (txt) txt.style.display = 'none';
      sel.disabled = false;
    } else {
      sel.style.display = 'none';
      var u = sel.value || units[0] || '';
      if (txt) { txt.style.display = ''; txt.innerText = u || '(no unit)'; }
    }
    return units;
  }

  function aggregate(values, mode) {
    if (mode === 'max') return Math.max.apply(null, values);
    if (mode === 'median') {
      var s = values.slice().sort(function (a, b) { return a - b; });
      var m = Math.floor(s.length / 2);
      return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2;
    }
    var sum = 0;
    for (var i = 0; i < values.length; i++) sum += values[i];
    return sum / values.length;
  }

  // Build the z-matrix: rows = yDim values, columns = xDim values, cell = aggregate of the
  // expression values for that (row, column) pair (only records matching the chosen unit).
  function buildHeatmap(records, yDim, xDim, unit, agg) {
    var Y = HEATMAP_DIMS[yDim], X = HEATMAP_DIMS[xDim];
    var yLabels = {}, xLabels = {}, cells = {};
    for (var i = 0; i < records.length; i++) {
      var r = records[i];
      if ((r.expressionUnit || '') !== (unit || '')) continue;
      if (!isNumericValue(r)) continue;
      var yk = Y.keyOf(r), xk = X.keyOf(r);
      if (!yk || !xk) continue;
      yLabels[yk] = Y.labelOf(r);
      xLabels[xk] = X.labelOf(r);
      var ck = yk + '' + xk;
      (cells[ck] || (cells[ck] = [])).push(Number(r.expressionValue));
    }
    var yKeys = Object.keys(yLabels).sort(function (a, b) { return String(yLabels[a]).localeCompare(String(yLabels[b])); });
    var xKeys = Object.keys(xLabels).sort(function (a, b) { return String(xLabels[a]).localeCompare(String(xLabels[b])); });
    var z = [], counts = [];
    for (var yi = 0; yi < yKeys.length; yi++) {
      var zRow = [], cRow = [];
      for (var xi = 0; xi < xKeys.length; xi++) {
        var arr = cells[yKeys[yi] + '' + xKeys[xi]];
        if (!arr || !arr.length) { zRow.push(null); cRow.push(0); }
        else { zRow.push(aggregate(arr, agg)); cRow.push(arr.length); }
      }
      z.push(zRow); counts.push(cRow);
    }
    return {
      x: xKeys.map(function (k) { return xLabels[k]; }),
      y: yKeys.map(function (k) { return yLabels[k]; }),
      z: z, counts: counts
    };
  }

  function toggleHeatmap() {
    var card = document.getElementById('emHeatmapCard');
    if (card.style.display !== 'none') { card.style.display = 'none'; return; }
    card.style.display = 'block';
    if (!heatmapInited) {
      var picks = autoPickDims(filteredRecords.length ? filteredRecords : allRecords);
      document.getElementById('emHmY').value = picks.y;
      document.getElementById('emHmX').value = picks.x;
      heatmapInited = true;
    }
    renderHeatmap();
  }

  // Redraw the heatmap only when its panel is open (keeps applyClientFilters cheap otherwise).
  function syncHeatmap() {
    if (document.getElementById('emHeatmapCard').style.display !== 'none') renderHeatmap();
  }

  function renderHeatmap() {
    var card = document.getElementById('emHeatmapCard');
    if (card.style.display === 'none') return;
    var note = document.getElementById('emHeatmapNote');

    if (typeof Plotly === 'undefined') { note.innerText = 'Charting library not available.'; return; }

    var records = filteredRecords || [];
    refreshUnitOptions(records);

    var yDim = document.getElementById('emHmY').value;
    var xDim = document.getElementById('emHmX').value;
    var unit = document.getElementById('emHmUnit').value;
    var agg  = document.getElementById('emHmAgg').value;
    var colorEl = document.getElementById('emHmColor');
    var colorscale = colorEl ? colorEl.value : 'YlOrRd';

    if (yDim === xDim) {
      note.innerText = 'Pick two different dimensions for rows and columns.';
      Plotly.purge('emHeatmap');
      return;
    }

    var d = buildHeatmap(records, yDim, xDim, unit, agg);
    if (!d.y.length || !d.x.length) {
      note.innerText = 'No numeric values to plot for this selection.';
      Plotly.purge('emHeatmap');
      return;
    }

    var aggLabel = agg.charAt(0).toUpperCase() + agg.slice(1);
    note.innerText = d.y.length + ' x ' + d.x.length + ' cells - ' + aggLabel + (unit ? ' ' + unit : '');

    var data = [{
      type: 'heatmap',
      z: d.z, x: d.x, y: d.y, customdata: d.counts,
      colorscale: colorscale,
      hoverongaps: false,
      xgap: 1, ygap: 1,
      colorbar: { title: { text: aggLabel + (unit ? ' ' + unit : ''), side: 'right' }, thickness: 14 },
      hovertemplate:
        HEATMAP_DIMS[yDim].title + ': %{y}<br>' +
        HEATMAP_DIMS[xDim].title + ': %{x}<br>' +
        aggLabel + ': %{z}<br>n = %{customdata}<extra></extra>'
    }];

    var height = Math.max(320, Math.min(28 * d.y.length + 160, 900));
    var layout = {
      margin: { l: 170, r: 20, t: 10, b: 130 },
      height: height,
      xaxis: { title: HEATMAP_DIMS[xDim].title, type: 'category', tickangle: -40, automargin: true },
      yaxis: { title: HEATMAP_DIMS[yDim].title, type: 'category', automargin: true },
      paper_bgcolor: 'rgba(0,0,0,0)',
      plot_bgcolor: '#f3f7fb'
    };

    // The stock camera button renders the PNG using the layout's paper background, which is transparent
    // here -- so a downloaded image comes out see-through (and reads as black in many viewers). Plotly's
    // toImageButtonOptions only forwards format/filename/width/height/scale, NOT the background, so swap
    // in our own button and call downloadImage directly with setBackground.
    var downloadBtn = {
      name: 'Download PNG',
      title: 'Download as PNG (white background)',
      icon: Plotly.Icons.camera,
      click: function (g) {
        Plotly.downloadImage(g, {
          format: 'png',
          filename: 'expression-heatmap-' + yDim + '-by-' + xDim,
          scale: 2,                 // 2x pixel density so the axis labels stay crisp
          setBackground: '#ffffff'  // opaque white instead of the transparent paper
        });
      }
    };

    Plotly.react('emHeatmap', data, layout, {
      responsive: true,
      displaylogo: false,
      modeBarButtonsToRemove: ['lasso2d', 'select2d', 'toImage'],
      modeBarButtonsToAdd: [downloadBtn]
    });
  }
</script>
