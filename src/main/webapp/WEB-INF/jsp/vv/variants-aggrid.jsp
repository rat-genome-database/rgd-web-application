<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.vv.SampleManager" %>
<%@ page import="edu.mcw.rgd.web.UI" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="edu.mcw.rgd.datamodel.MappedGene" %>
<%@ page import="edu.mcw.rgd.process.describe.DescriptionGenerator" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.vv.SNPlotyper" %>
<%@ page import="edu.mcw.rgd.datamodel.VariantSearchBean" %>
<%@ page import="edu.mcw.rgd.datamodel.VariantResult" %>
<%@ page import="edu.mcw.rgd.util.Zygosity" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="com.google.gson.Gson" %>
<%
    String pageTitle = "Variant Visualizer (AG Grid)";
    String headContent = "";
    String pageDescription = "View the Variants of selected position or genes - AG Grid Version";
%>
<%@ include file="/common/headerarea.jsp" %>
<%
    try {
        SNPlotyper snplotyper = (SNPlotyper) request.getAttribute("snplotyper");
        VariantSearchBean vsb = (VariantSearchBean) request.getAttribute("vsb");

        Set positions = snplotyper.getPositions();
        List samples = snplotyper.getSamples();
        int mapKey = vsb.getMapKey();
        int positionCount = positions.size();
        int cellWidth = 24;
        int xMenuWidth = 135;
        int yMenuHeight = 90;
        int horizontalWidth = (cellWidth + 1) * snplotyper.getPositions().size();
        int tableHeight = snplotyper.getSamples().size() * cellWidth;
        int heightOfOptionalGeneTracks = 0;

        // Build color maps
        HashMap<String, String> backColors = new HashMap<>();
        backColors.put("A","#0A224E");
        backColors.put("A/A","#0A224E");
        backColors.put("A/T","#652D34");
        backColors.put("T/A","#652D34");
        backColors.put("A/C","#557DA0");
        backColors.put("C/A","#557DA0");
        backColors.put("A/G","#754C3B");
        backColors.put("G/A","#754C3B");
        backColors.put("T","#BF381A");
        backColors.put("T/T","#BF381A");
        backColors.put("T/C","#B08886");
        backColors.put("C/T","#B08886");
        backColors.put("T/G","#D05721");
        backColors.put("G/T","#D05721");
        backColors.put("C","#A0D8F1");
        backColors.put("C/C","#A0D8F1");
        backColors.put("C/G","#C0A78D");
        backColors.put("G/C","#C0A78D");
        backColors.put("G","#E07628");
        backColors.put("G/G","#E07628");
        backColors.put("het", "#E9AF32");
        backColors.put("-", "purple");
        backColors.put("?", "black");

        for (int i=1; i< 1000; i++) {
            backColors.put(i + "","pink");
        }

        HashMap<String, String> fontColors = new HashMap<>();
        fontColors.put("A","white");
        fontColors.put("A/A","white");
        fontColors.put("T","white");
        fontColors.put("T/T","white");
        fontColors.put("C","black");
        fontColors.put("C/C","black");
        fontColors.put("G","white");
        fontColors.put("G/G","white");
        fontColors.put("het", "black");
        fontColors.put("-", "white");
        fontColors.put("?", "white");

        for (int i=1; i< 1000; i++) {
            fontColors.put(i + "","black");
        }

        // ========================================
        // Phase 1: Build JSON data for tracks
        // ========================================

        // Position list
        List<Long> positionList = new ArrayList<>();
        Iterator posIterator = positions.iterator();
        while (posIterator.hasNext()) {
            positionList.add((Long) posIterator.next());
        }

        // Conservation data
        List<Map<String, Object>> conservationData = new ArrayList<>();
        for (Long pos : positionList) {
            Map<String, Object> conData = new LinkedHashMap<>();
            BigDecimal score = snplotyper.getConservation(pos);
            int colorVal = score.multiply(new BigDecimal("1000")).intValue();
            String fontColor = "black";
            if (colorVal > 500) {
                fontColor = "white";
            }
            String con = score.toString().replace("0.",".");
            if (con.equals("-1")) {
                con = "--";
            }
            conData.put("position", pos);
            conData.put("score", con);
            conData.put("color", UI.getRGBValue(colorVal, 1000));
            conData.put("fontColor", fontColor);
            conservationData.add(conData);
        }

        // Plus strand gene data
        List<Map<String, Object>> plusGeneData = new ArrayList<>();
        List<Map<String, Object>> plusOverflowData = new ArrayList<>();
        TreeMap<Long, MappedGene> plusOverflow = new TreeMap<>();
        HashSet<Integer> plusIgnore = new HashSet<>();
        String currentPlusGene = "";

        for (int i = 0; i < positionList.size(); i++) {
            long pos = positionList.get(i);
            List<MappedGene> mgList = snplotyper.getPlusStrandGene(pos);

            Gene g = null;
            if (mgList.size() > 1) {
                int index1 = 0;
                int index2 = 1;
                if (plusIgnore.contains(mgList.get(index1).getGene().getRgdId())) {
                    index1 = 1;
                    index2 = 0;
                }
                plusOverflow.put(pos, mgList.get(index2));
                plusIgnore.add(mgList.get(index2).getGene().getRgdId());
                g = mgList.get(index1).getGene();
            } else if (mgList.size() == 1) {
                if (!plusIgnore.contains(mgList.get(0).getGene().getRgdId())) {
                    g = mgList.get(0).getGene();
                }
            }

            Map<String, Object> geneData = new LinkedHashMap<>();
            geneData.put("position", pos);
            if (g != null) {
                int colspan = snplotyper.getVariantSpan(g.getRgdId());
                geneData.put("symbol", g.getSymbol());
                geneData.put("rgdId", g.getRgdId());
                geneData.put("colspan", colspan);
                // Skip positions covered by this gene
                for (int skip = 1; skip < colspan && (i + skip) < positionList.size(); skip++) {
                    i++;
                }
            } else {
                geneData.put("symbol", null);
                geneData.put("colspan", 1);
            }
            plusGeneData.add(geneData);
        }

        // Plus overflow data (if conflict exists)
        if (snplotyper.hasPlusStrandConflict()) {
            heightOfOptionalGeneTracks += 25;
            for (Long pos : positionList) {
                Map<String, Object> overflowData = new LinkedHashMap<>();
                overflowData.put("position", pos);
                MappedGene mg = plusOverflow.get(pos);
                if (mg != null) {
                    Gene g = mg.getGene();
                    int colspan = snplotyper.getVariantSpan(g.getRgdId());
                    overflowData.put("symbol", g.getSymbol());
                    overflowData.put("rgdId", g.getRgdId());
                    overflowData.put("colspan", colspan);
                } else {
                    overflowData.put("symbol", null);
                    overflowData.put("colspan", 1);
                }
                plusOverflowData.add(overflowData);
            }
        }

        // Minus strand gene data
        List<Map<String, Object>> minusGeneData = new ArrayList<>();
        List<Map<String, Object>> minusOverflowData = new ArrayList<>();
        TreeMap<Long, MappedGene> minusOverflow = new TreeMap<>();
        HashSet<Integer> minusIgnore = new HashSet<>();

        for (int i = 0; i < positionList.size(); i++) {
            long pos = positionList.get(i);
            List<MappedGene> mgList = snplotyper.getMinusStrandGene(pos);

            Gene g = null;
            if (mgList.size() > 1) {
                int index1 = 0;
                int index2 = 1;
                if (minusIgnore.contains(mgList.get(index1).getGene().getRgdId())) {
                    index1 = 1;
                    index2 = 0;
                }
                minusOverflow.put(pos, mgList.get(index2));
                minusIgnore.add(mgList.get(index2).getGene().getRgdId());
                g = mgList.get(index1).getGene();
            } else if (mgList.size() == 1) {
                if (!minusIgnore.contains(mgList.get(0).getGene().getRgdId())) {
                    g = mgList.get(0).getGene();
                }
            }

            Map<String, Object> geneData = new LinkedHashMap<>();
            geneData.put("position", pos);
            if (g != null) {
                int colspan = snplotyper.getVariantSpan(g.getRgdId());
                geneData.put("symbol", g.getSymbol());
                geneData.put("rgdId", g.getRgdId());
                geneData.put("colspan", colspan);
                // Skip positions covered by this gene
                for (int skip = 1; skip < colspan && (i + skip) < positionList.size(); skip++) {
                    i++;
                }
            } else {
                geneData.put("symbol", null);
                geneData.put("colspan", 1);
            }
            minusGeneData.add(geneData);
        }

        // Minus overflow data (if conflict exists)
        if (snplotyper.hasMinusStrandConflict()) {
            heightOfOptionalGeneTracks += 25;
            for (Long pos : positionList) {
                Map<String, Object> overflowData = new LinkedHashMap<>();
                overflowData.put("position", pos);
                MappedGene mg = minusOverflow.get(pos);
                if (mg != null) {
                    Gene g = mg.getGene();
                    int colspan = snplotyper.getVariantSpan(g.getRgdId());
                    overflowData.put("symbol", g.getSymbol());
                    overflowData.put("rgdId", g.getRgdId());
                    overflowData.put("colspan", colspan);
                } else {
                    overflowData.put("symbol", null);
                    overflowData.put("colspan", 1);
                }
                minusOverflowData.add(overflowData);
            }
        }

        // Reference nucleotide data
        List<Map<String, Object>> refNucData = new ArrayList<>();
        for (Long pos : positionList) {
            Map<String, Object> refData = new LinkedHashMap<>();
            String refNuc = snplotyper.getRefNuc(pos) + "";
            if (refNuc.length() > 1 && !refNuc.equalsIgnoreCase("null")) {
                refNuc = refNuc.length() + "";
            }
            if (refNuc.equalsIgnoreCase("null")) {
                refNuc = "-";
            }
            refData.put("position", pos);
            refData.put("nucleotide", refNuc);
            refData.put("isExon", snplotyper.isInExon(pos));
            refNucData.add(refData);
        }

        // ========================================
        // Build AG Grid row and column data
        // ========================================
        List<Map<String, Object>> rowData = new ArrayList<>();
        List<Map<String, Object>> columnDefs = new ArrayList<>();

        // Drag handle column
        Map<String, Object> dragCol = new LinkedHashMap<>();
        dragCol.put("headerName", "");
        dragCol.put("pinned", "left");
        dragCol.put("lockPosition", true);
        dragCol.put("rowDrag", true);
        dragCol.put("width", 30);
        dragCol.put("maxWidth", 30);
        dragCol.put("suppressSizeToFit", true);
        columnDefs.add(dragCol);

        // Sample name column (pinned left)
        Map<String, Object> sampleCol = new LinkedHashMap<>();
        sampleCol.put("field", "sampleName");
        sampleCol.put("headerName", "Sample");
        sampleCol.put("pinned", "left");
        sampleCol.put("lockPosition", true);
        sampleCol.put("width", 180);
        sampleCol.put("minWidth", 180);
        sampleCol.put("cellStyle", java.util.Map.of("fontWeight", "bold", "fontSize", "11px"));
        columnDefs.add(sampleCol);

        // Create columns for each position
        for (Long pos : positionList) {
            Map<String, Object> col = new LinkedHashMap<>();
            col.put("field", "pos_" + pos);
            col.put("headerName", String.format("%,d", pos));
            col.put("width", cellWidth);
            col.put("minWidth", cellWidth);
            col.put("maxWidth", cellWidth);
            col.put("suppressSizeToFit", true);
            col.put("cellRenderer", "nucleotideCellRenderer");
            col.put("headerClass", "vertical-header");
            columnDefs.add(col);
        }

        // Build row data for each sample
        Iterator sampleIt = samples.iterator();
        while (sampleIt.hasNext()) {
            int sample = (Integer) sampleIt.next();
            String sampleAnalysisName = SampleManager.getInstance().getSampleName(sample).getAnalysisName();
            String sampleName = sampleAnalysisName.toLowerCase().contains("european")
                ? "EVA Release " + sampleAnalysisName.substring(sampleAnalysisName.length()-1)
                : sampleAnalysisName;

            Map<String, Object> row = new LinkedHashMap<>();
            row.put("sampleId", sample);
            row.put("sampleName", sampleName);
            row.put("sampleFullName", sampleAnalysisName);

            // Add variant data for each position
            for (Long pos : positionList) {
                List<VariantResult> variants = snplotyper.getNucleotide(sample, pos);

                Map<String, Object> cellData = new LinkedHashMap<>();

                if (variants.size() == 0) {
                    cellData.put("value", "-");
                    cellData.put("hasVariant", false);
                    cellData.put("bgColor", "#E8E4D5");
                    cellData.put("fontColor", "black");
                } else {
                    String variantID = "";
                    String var = "";
                    int count = 0;

                    for (VariantResult vr : variants) {
                        if (variantID.equals("")) {
                            variantID += vr.getVariant().getId();
                        } else {
                            variantID += "|" + vr.getVariant().getId();
                        }

                        if (count > 0) var += "/";

                        if (vr.getVariant().getVariantType() != null &&
                            (vr.getVariant().getVariantType().equals("del") ||
                             vr.getVariant().getVariantType().equals("deletion"))) {
                            var = "-";
                        } else {
                            if (var.length() > 2) {
                                var = var.length() + "";
                            } else {
                                var += vr.getVariant().getVariantNucleotide();
                            }
                        }

                        if (var.length() > 1) {
                            var = var.length() + "";
                        }

                        if (variants.size() > 1) {
                            var = "?";
                        }

                        if (variants.size() == 2) {
                            VariantResult vr1 = variants.get(0);
                            VariantResult vr2 = variants.get(1);
                            var = "";
                            if (vr1.getVariant().getVariantNucleotide() != null &&
                                vr1.getVariant().getVariantNucleotide().length() > 2) {
                                var += vr1.getVariant().getVariantNucleotide().length() + "/";
                            } else {
                                var += vr1.getVariant().getVariantNucleotide() + "/";
                            }
                            if (vr2.getVariant().getVariantNucleotide() != null &&
                                vr2.getVariant().getVariantNucleotide().length() > 2) {
                                var += vr2.getVariant().getVariantNucleotide().length();
                            } else {
                                var += vr2.getVariant().getVariantNucleotide();
                            }
                        }

                        count++;

                        if (variants.size() == 1 && vr.getVariant().getZygosityStatus() != null) {
                            if (vr.getVariant().getZygosityStatus().equals(Zygosity.HETEROZYGOUS)) {
                                String refNuc = Utils.NVL(snplotyper.getRefNuc(pos), "-");
                                String newVar;
                                if (refNuc.length() > 1) {
                                    newVar = refNuc.length() + "/" + var;
                                } else {
                                    newVar = refNuc + "/" + var;
                                }
                                var = newVar;
                            }
                        }
                    }

                    var = var.replace("null", "-");

                    String bgColor = backColors.getOrDefault(var, backColors.get("het"));
                    String fontColor = fontColors.getOrDefault(var, fontColors.get("het"));

                    cellData.put("value", var);
                    cellData.put("hasVariant", true);
                    cellData.put("variantId", variantID);
                    cellData.put("bgColor", bgColor);
                    cellData.put("fontColor", fontColor);
                    cellData.put("position", pos);
                }

                row.put("pos_" + pos, cellData);
            }

            rowData.add(row);
        }

        // Overview data (simplified for minimap)
        List<Map<String, Object>> overviewData = new ArrayList<>();
        sampleIt = samples.iterator();
        while (sampleIt.hasNext()) {
            int sample = (Integer) sampleIt.next();
            Map<String, Object> sampleRow = new LinkedHashMap<>();
            sampleRow.put("sampleId", sample);

            List<Map<String, Object>> posData = new ArrayList<>();
            for (Long pos : positionList) {
                List<VariantResult> variants = snplotyper.getNucleotide(sample, pos);
                Map<String, Object> cellData = new LinkedHashMap<>();

                if (variants.size() == 0) {
                    cellData.put("bgColor", "#E8E4D5");
                } else {
                    String var = "";
                    int count = 0;
                    for (VariantResult vr : variants) {
                        if (count > 0) var += "/";
                        var += vr.getVariant().getVariantNucleotide();
                        count++;
                        if (variants.size() == 1 && vr.getVariant().getZygosityStatus() != null) {
                            if (vr.getVariant().getZygosityStatus().equals(Zygosity.HETEROZYGOUS)) {
                                var += "/" + snplotyper.getRefNuc(pos);
                            } else if (vr.getVariant().getZygosityStatus().equals(Zygosity.HOMOZYGOUS) ||
                                       vr.getVariant().getZygosityStatus().equals(Zygosity.POSSIBLY_HOMOZYGOUS)) {
                                var += "/" + var;
                            }
                        }
                    }
                    String bgColor = backColors.getOrDefault(var, backColors.get("het"));
                    cellData.put("bgColor", bgColor);
                }
                posData.add(cellData);
            }
            sampleRow.put("positions", posData);
            overviewData.add(sampleRow);
        }

        Gson gson = new Gson();
        String rowDataJson = gson.toJson(rowData);
        String columnDefsJson = gson.toJson(columnDefs);
        String conservationJson = gson.toJson(conservationData);
        String plusGeneJson = gson.toJson(plusGeneData);
        String plusOverflowJson = gson.toJson(plusOverflowData);
        String minusGeneJson = gson.toJson(minusGeneData);
        String minusOverflowJson = gson.toJson(minusOverflowData);
        String refNucJson = gson.toJson(refNucData);
        String positionListJson = gson.toJson(positionList);
        String overviewJson = gson.toJson(overviewData);
%>

<!-- AG Grid CSS -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ag-grid-community@31.0.1/styles/ag-grid.css">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/ag-grid-community@31.0.1/styles/ag-theme-alpine.css">

<!-- DHTML Window for variant details popup -->
<link rel="stylesheet" href="/rgdweb/js/javascriptPopUpWindow/GAdhtmlwindow.css" type="text/css" />
<script type="text/javascript" src="/rgdweb/js/javascriptPopUpWindow/dhtmlwindow.js"></script>

<style>
    /* ========================================
       Track and Header Styles (from mapStyles.jsp)
       ======================================== */

    .track-container {
        display: flex;
        width: 100%;
        background-color: white;
    }

    .track-labels {
        flex-shrink: 0;
        width: 210px; /* Match AG Grid pinned columns: 30px drag + 180px sample */
        background-color: #EEEEEE;
    }

    .track-label-row {
        height: <%= cellWidth + 1 %>px;
        line-height: <%= cellWidth + 1 %>px;
        font-size: 11px;
        text-align: right;
        padding-right: 4px;
        overflow: hidden;
        border-top: 1px solid #E8E4D5;
        box-sizing: border-box;
    }

    .track-scroll-wrapper {
        flex-grow: 1;
        overflow-x: auto;
        overflow-y: hidden;
    }

    .track-content {
        display: inline-block;
        white-space: nowrap;
    }

    .track-row {
        height: <%= cellWidth + 1 %>px;
        line-height: <%= cellWidth + 1 %>px;
        display: flex;
        white-space: nowrap;
    }

    .track-cell {
        width: <%= cellWidth %>px;
        height: <%= cellWidth %>px;
        min-width: <%= cellWidth %>px;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-size: 9px;
        text-align: center;
        overflow: hidden;
        border-top: 1px solid white;
        border-right: 1px solid white;
        box-sizing: border-box;
    }

    .gene-cell {
        background-color: #42433E;
        color: white;
        font-weight: 700;
        font-size: 12px;
        cursor: pointer;
        overflow: hidden;
        text-overflow: ellipsis;
    }

    .gene-cell.empty {
        background-color: #E8E4D5;
        color: black;
        cursor: default;
    }

    .ref-nuc-cell {
        background-color: #E8E4De;
        color: black;
    }

    .ref-nuc-cell.exon {
        background-color: #42433E;
        color: white;
    }

    .position-header-row {
        height: <%= yMenuHeight %>px;
    }

    .position-cell {
        width: <%= cellWidth %>px;
        min-width: <%= cellWidth %>px;
        height: <%= yMenuHeight %>px;
        display: inline-block;
        background: #eee;
        border-right: 1px solid white;
        overflow: hidden;
        box-sizing: border-box;
    }

    .position-text {
        writing-mode: vertical-rl;
        text-orientation: mixed;
        transform: rotate(180deg);
        font-size: 12px;
        font-family: Arial;
        white-space: nowrap;
        padding-left: 3px;
        line-height: <%= cellWidth %>px;
    }

    /* ========================================
       AG Grid Theme Overrides
       ======================================== */
    .ag-theme-alpine {
        --ag-header-height: 0px;
        --ag-row-height: <%= cellWidth %>px;
        --ag-cell-horizontal-padding: 0px;
        --ag-row-border-width: 0px;
        --ag-borders: none;
        --ag-cell-horizontal-border: none;
        --ag-header-column-separator-display: none;
        --ag-header-column-resize-handle-display: none;
        --ag-grid-size: 0px;
        --ag-list-item-height: <%= cellWidth %>px;
        --ag-row-border-color: transparent;
        --ag-border-color: transparent;
    }

    .ag-theme-alpine .ag-header {
        display: none;
    }

    .ag-theme-alpine .ag-cell {
        padding: 0 !important;
        line-height: <%= cellWidth %>px;
        border: none !important;
        border-width: 0 !important;
    }

    .ag-theme-alpine .ag-row {
        border: none !important;
        border-width: 0 !important;
    }

    .ag-theme-alpine .ag-center-cols-viewport {
        border: none !important;
    }

    .ag-theme-alpine .ag-body-viewport {
        border: none !important;
    }

    .nucleotide-cell {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 100%;
        height: 100%;
        font-weight: bold;
        font-size: 11px;
        cursor: pointer;
        margin: 0;
        padding: 0;
        box-sizing: border-box;
    }

    .nucleotide-cell.no-variant {
        cursor: default;
    }

    .ag-row-drag {
        cursor: grab;
        min-width: 20px !important;
        width: 20px !important;
    }

    .ag-row-dragging {
        opacity: 0.5;
    }

    .ag-theme-alpine .ag-pinned-left-cols-container .ag-cell {
        padding-left: 2px !important;
        font-size: 11px;
    }

    .ag-theme-alpine .ag-drag-handle {
        min-width: 16px;
    }

    /* ========================================
       Layout Styles
       ======================================== */
    #mainContainer {
        border: 4px outset #eeeeee;
        background-color: white;
        padding: 10px;
        margin: 10px auto;
    }

    .grid-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 10px 0;
        border-bottom: 1px solid #e0e0e0;
        margin-bottom: 10px;
    }

    .grid-header h3 {
        margin: 0;
        color: #2865A3;
        font-size: 14px;
    }

    .grid-controls button {
        padding: 6px 12px;
        margin-left: 8px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        font-size: 12px;
    }

    .btn-primary {
        background: #2865A3;
        color: white;
    }

    .btn-secondary {
        background: #6c757d;
        color: white;
    }

    .btn-info {
        background: #17a2b8;
        color: white;
    }

    .btn-success {
        background: #28a745;
        color: white;
    }

    /* Position header area above the grid */
    .position-header-wrapper {
        overflow: hidden;
        height: <%= yMenuHeight %>px;
    }

    /* Scrollbar styling */
    .track-scroll-wrapper::-webkit-scrollbar,
    #gridScrollWrapper::-webkit-scrollbar {
        height: 14px;
    }

    .track-scroll-wrapper::-webkit-scrollbar-track,
    #gridScrollWrapper::-webkit-scrollbar-track {
        background: #f0f0f0;
    }

    .track-scroll-wrapper::-webkit-scrollbar-thumb,
    #gridScrollWrapper::-webkit-scrollbar-thumb {
        background: #2865A3;
        border-radius: 6px;
    }

    .track-scroll-wrapper::-webkit-scrollbar-thumb:hover,
    #gridScrollWrapper::-webkit-scrollbar-thumb:hover {
        background: #1e4a7a;
    }

    /* Firefox scrollbar styles */
    .track-scroll-wrapper,
    #gridScrollWrapper {
        scrollbar-width: auto;
        scrollbar-color: #2865A3 #f0f0f0;
    }

    /* ========================================
       Overview Map Styles
       ======================================== */
    #overview {
        border: 5px outset black;
        position: fixed;
        top: 150px;
        left: 30px;
        display: none;
        background-color: #ffffff;
        z-index: 1000;
        max-width: calc(90vw - 60px);
        max-height: 60vh;
        box-sizing: border-box;
    }

    #overview-header {
        background-color: #771428;
        text-align: right;
        padding: 5px 8px;
        cursor: move;
        user-select: none;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    #overview-header span {
        color: white;
        font-size: 12px;
        font-weight: bold;
    }

    #overview-header a {
        color: white;
    }

    #overview-region {
        padding: 10px;
        padding-bottom: 15px;
        overflow-x: auto;
        overflow-y: auto;
        box-sizing: border-box;
        flex: 1;
        min-height: 0;
    }

    .overview-row {
        height: 8px;
        display: flex;
        clear: both;
    }

    .overview-cell {
        width: 5px;
        height: 6px;
        float: left;
    }
</style>

<%@ include file="carpeHeader.jsp"%>
<%
    geneList = snplotyper.getCommaDelimitedGeneSymbolList();
%>
<%@ include file="menuBar.jsp"%>
<br>

<div id="blueBackground" style="padding:15px; background-image: url(/rgdweb/common/images/bg3.png); min-height: 100vh;">

    <%@ include file="updateForm.jsp"%>

    <%
        Gene gene = (Gene) request.getAttribute("gene");
        DescriptionGenerator dg = new DescriptionGenerator();
        if (gene != null) {
    %>
    <table align="center" width="100%" cellpadding="0" cellspacing="0" style="background-color:#EEEEEE;">
        <tr>
            <td align="center">
                <div style="font-size:12px; padding: 6px; color:#063968;">
                    <span style="font-weight:700; font-size:12px;"><%=gene.getSymbol()%></span> : <%=dg.buildDescription(gene.getRgdId())%>
                </div>
            </td>
        </tr>
    </table>
    <%
        }
    %>

    <%
        if (positions.size() == 0) {
    %>
    <br>
    <table align="center">
        <tr>
            <td colspan="2" align="center" style="font-size:20px; color:white; font-weight:700">
                0 SNPs Found<br>(Please remove options or increase your region size)
            </td>
        </tr>
    </table>
    <%
        } else {
    %>

    <div id="mainContainer">
        <div class="grid-header">
            <h3>Variant Data - <%= positions.size() %> positions, <%= samples.size() %> samples</h3>
            <div class="grid-controls">
                <button class="btn-info" onclick="showOverview()">Overview</button>
                <button class="btn-success" onclick="groupBySimilarity()">Group by Similarity</button>
                <button class="btn-secondary" onclick="resetRowOrder()">Reset Order</button>
                <button class="btn-primary" onclick="exportToCSV()">Export CSV</button>
            </div>
        </div>

        <!-- ========================================
             Header Tracks Section
             ======================================== -->
        <div class="track-container">
            <!-- Track Labels (left side) -->
            <div class="track-labels">
                <% if (mapKey != 631 && mapKey != 372) { %>
                <div class="track-label-row">Conservation&nbsp;</div>
                <% } %>
                <div class="track-label-row">Genes <span style="color:blue;">( + )</span>&nbsp;</div>
                <% if (snplotyper.hasPlusStrandConflict()) { %>
                <div class="track-label-row">Genes <span style="color:blue;">( + )</span>&nbsp;</div>
                <% } %>
                <div class="track-label-row">Genes <span style="color:red;">( - )</span>&nbsp;</div>
                <% if (snplotyper.hasMinusStrandConflict()) { %>
                <div class="track-label-row">Genes <span style="color:red;">( - )</span>&nbsp;</div>
                <% } %>
                <div class="track-label-row">
                    <%if (mapKey==60) out.print("RGSC 3.4");%>
                    <%if (mapKey==70) out.print("Rnor 5.0");%>
                    <%if (mapKey==360) out.print("Rnor 6.0");%>
                    <%if (mapKey==372) out.print("mRatBN7.2");%>
                    <%if (mapKey==17) out.print("GRCh37");%>
                    &nbsp;
                </div>
                <!-- Position header label area -->
                <div style="height:<%= yMenuHeight %>px; background-color: white; display: flex; align-items: center; justify-content: center;">
                    <img src="/rgdweb/common/images/rgd.png" alt="RGD" />
                </div>
            </div>

            <!-- Track Content (scrollable) -->
            <div class="track-scroll-wrapper" id="trackScrollWrapper">
                <div class="track-content" id="trackContent">
                    <!-- Conservation Track -->
                    <% if (mapKey != 631 && mapKey != 372) { %>
                    <div class="track-row" id="conservationTrack"></div>
                    <% } %>

                    <!-- Plus Strand Gene Track -->
                    <div class="track-row" id="plusGeneTrack"></div>

                    <!-- Plus Strand Overflow Track (conditional) -->
                    <% if (snplotyper.hasPlusStrandConflict()) { %>
                    <div class="track-row" id="plusOverflowTrack"></div>
                    <% } %>

                    <!-- Minus Strand Gene Track -->
                    <div class="track-row" id="minusGeneTrack"></div>

                    <!-- Minus Strand Overflow Track (conditional) -->
                    <% if (snplotyper.hasMinusStrandConflict()) { %>
                    <div class="track-row" id="minusOverflowTrack"></div>
                    <% } %>

                    <!-- Reference Nucleotide Track -->
                    <div class="track-row" id="refNucTrack"></div>

                    <!-- Position Headers -->
                    <div class="position-header-row" id="positionHeaders"></div>
                </div>
            </div>
        </div>

        <!-- ========================================
             AG Grid Section
             ======================================== -->
        <div id="variantGrid" class="ag-theme-alpine" style="height: <%= Math.min(600, tableHeight + 50) %>px; width: 100%;"></div>
    </div>

    <!-- ========================================
         Overview Map
         ======================================== -->
    <div id="overview">
        <div id="overview-header">
            <span>Overview</span>
            <a href="javascript:closeOverview();">
                <img src="/rgdweb/js/windowfiles/close.gif" height="15" width="15" alt="Close"/>
            </a>
        </div>
        <div id="overview-region"></div>
    </div>

    <%
        } // end else (positions.size() > 0)
    %>
</div>

<!-- AG Grid JS -->
<script src="https://cdn.jsdelivr.net/npm/ag-grid-community@31.0.1/dist/ag-grid-community.min.js"></script>

<!-- Store data safely in script tags with type application/json -->
<script id="rowDataJson" type="application/json"><%= rowDataJson.replace("</", "<\\/") %></script>
<script id="columnDefsJson" type="application/json"><%= columnDefsJson.replace("</", "<\\/") %></script>
<script id="conservationJson" type="application/json"><%= conservationJson.replace("</", "<\\/") %></script>
<script id="plusGeneJson" type="application/json"><%= plusGeneJson.replace("</", "<\\/") %></script>
<script id="plusOverflowJson" type="application/json"><%= plusOverflowJson.replace("</", "<\\/") %></script>
<script id="minusGeneJson" type="application/json"><%= minusGeneJson.replace("</", "<\\/") %></script>
<script id="minusOverflowJson" type="application/json"><%= minusOverflowJson.replace("</", "<\\/") %></script>
<script id="refNucJson" type="application/json"><%= refNucJson.replace("</", "<\\/") %></script>
<script id="positionListJson" type="application/json"><%= positionListJson.replace("</", "<\\/") %></script>
<script id="overviewJson" type="application/json"><%= overviewJson.replace("</", "<\\/") %></script>

<script>
    // ========================================
    // Configuration
    // ========================================
    const cellWidth = <%= cellWidth %>;
    const chromosome = '<%= vsb.getChromosome() %>';
    const mapKey = <%= vsb.getMapKey() %>;
    const hasPlusConflict = <%= snplotyper.hasPlusStrandConflict() %>;
    const hasMinusConflict = <%= snplotyper.hasMinusStrandConflict() %>;
    const showConservation = <%= mapKey != 631 && mapKey != 372 %>;

    // ========================================
    // Data from server
    // ========================================
    const rowData = JSON.parse(document.getElementById('rowDataJson').textContent);
    const columnDefs = JSON.parse(document.getElementById('columnDefsJson').textContent);
    const conservationData = JSON.parse(document.getElementById('conservationJson').textContent);
    const plusGeneData = JSON.parse(document.getElementById('plusGeneJson').textContent);
    const plusOverflowData = JSON.parse(document.getElementById('plusOverflowJson').textContent);
    const minusGeneData = JSON.parse(document.getElementById('minusGeneJson').textContent);
    const minusOverflowData = JSON.parse(document.getElementById('minusOverflowJson').textContent);
    const refNucData = JSON.parse(document.getElementById('refNucJson').textContent);
    const positionList = JSON.parse(document.getElementById('positionListJson').textContent);
    const overviewData = JSON.parse(document.getElementById('overviewJson').textContent);

    // Store original order for reset
    const originalRowData = JSON.parse(JSON.stringify(rowData));

    // ========================================
    // Track Rendering Functions
    // ========================================

    function renderConservationTrack(container, data) {
        if (!container) return;
        container.innerHTML = '';

        data.forEach(item => {
            const cell = document.createElement('div');
            cell.className = 'track-cell';
            cell.style.backgroundColor = item.color;
            cell.style.color = item.fontColor;
            cell.textContent = item.score;
            cell.title = 'Conservation: ' + item.score + ' at position ' + item.position.toLocaleString();
            container.appendChild(cell);
        });
    }

    function renderGeneTrack(container, data) {
        if (!container) return;
        container.innerHTML = '';

        let i = 0;
        while (i < data.length) {
            const item = data[i];

            if (item.symbol) {
                const colspan = item.colspan || 1;
                const width = (cellWidth * colspan) + (colspan - 1);

                const cell = document.createElement('div');
                cell.className = 'track-cell gene-cell';
                cell.style.width = width + 'px';
                cell.style.minWidth = width + 'px';
                cell.textContent = item.symbol;
                cell.title = item.symbol;
                cell.dataset.rgdId = item.rgdId;
                cell.dataset.symbol = item.symbol;
                cell.onclick = function() {
                    navigateToGene(this.dataset.symbol);
                };
                container.appendChild(cell);

                // Skip the covered positions in the data
                i += colspan;
            } else {
                const cell = document.createElement('div');
                cell.className = 'track-cell gene-cell empty';
                cell.textContent = '--';
                container.appendChild(cell);
                i++;
            }
        }
    }

    function renderRefNucTrack(container, data) {
        if (!container) return;
        container.innerHTML = '';

        data.forEach(item => {
            const cell = document.createElement('div');
            cell.className = 'track-cell ref-nuc-cell' + (item.isExon ? ' exon' : '');
            cell.textContent = item.nucleotide;
            cell.title = 'Reference: ' + item.nucleotide + (item.isExon ? ' (Exon)' : '') + ' at position ' + item.position.toLocaleString();
            container.appendChild(cell);
        });
    }

    function renderPositionHeaders(container, positions) {
        if (!container) return;
        container.innerHTML = '';

        positions.forEach(pos => {
            const cell = document.createElement('div');
            cell.className = 'position-cell';

            const text = document.createElement('div');
            text.className = 'position-text';
            text.textContent = pos.toLocaleString();

            cell.appendChild(text);
            container.appendChild(cell);
        });
    }

    function navigateToGene(geneSymbol) {
        if (!geneSymbol) return;

        // Use the navigate function from carpeHeader.jsp
        if (typeof navigate === 'function') {
            navigate(geneSymbol, null);
        } else {
            // Fallback if navigate function is not available
            const gene = geneSymbol.replace(/\|/g, '%7C');
            let queryString = '?<%= request.getQueryString() != null ? request.getQueryString() : "" %>';
            queryString = addParam('chr', '', queryString);
            queryString = addParam('start', '', queryString);
            queryString = addParam('stop', '', queryString);
            queryString = addParam('geneList', gene, queryString);
            queryString = addParam('geneStart', '', queryString);
            queryString = addParam('geneStop', '', queryString);
            queryString = addParam('mapKey', '<%= mapKey %>', queryString);
            queryString = addParam('view', 'aggrid', queryString);
            location.href = 'variants.html' + queryString;
        }
    }

    // ========================================
    // AG Grid Setup
    // ========================================

    class NucleotideCellRenderer {
        init(params) {
            this.eGui = document.createElement('div');

            if (params.value && typeof params.value === 'object') {
                const data = params.value;
                this.eGui.className = 'nucleotide-cell' + (data.hasVariant ? '' : ' no-variant');
                this.eGui.style.backgroundColor = data.bgColor || '#E8E4D5';
                this.eGui.style.color = data.fontColor || 'black';
                this.eGui.textContent = data.value || '-';

                if (data.hasVariant) {
                    this.eGui.onclick = () => this.showVariantDetails(data, params.data);
                }
            } else {
                this.eGui.className = 'nucleotide-cell no-variant';
                this.eGui.textContent = '-';
            }
        }

        getGui() {
            return this.eGui;
        }

        showVariantDetails(cellData, rowData) {
            const url = '/rgdweb/front/detail.html?chr=' + chromosome +
                '&start=' + cellData.position +
                '&stop=' + (parseInt(cellData.position) + 1) +
                '&sid=' + rowData.sampleId +
                '&vid=' + encodeURIComponent(cellData.variantId) +
                '&mapKey=' + mapKey;
            const googlewin = dhtmlwindow.open("ajaxbox", "ajax", url, "Variant Details",
                "width=740px,height=400px,resize=1,scrolling=1,center=1", "recal");
            document.getElementById("ajaxbox").scrollTop = 0;
        }

        refresh() {
            return false;
        }
    }

    let gridApi;

    const gridOptions = {
        columnDefs: columnDefs,
        rowData: rowData,
        rowDragManaged: true,
        animateRows: true,
        suppressMoveWhenRowDragging: false,
        defaultColDef: {
            sortable: false,
            resizable: false,
            suppressMovable: true,
        },
        suppressCellFocus: true,
        suppressRowHoverHighlight: false,
        components: {
            nucleotideCellRenderer: NucleotideCellRenderer
        },
        rowSelection: 'multiple',
        suppressRowDrag: false,
        onRowDragEnd: (event) => {
            console.log('Row order changed');
        },
        onGridReady: (params) => {
            gridApi = params.api;
            setupScrollSync();
        }
    };

    // Initialize grid
    const gridDiv = document.getElementById('variantGrid');
    if (gridDiv) {
        const grid = agGrid.createGrid(gridDiv, gridOptions);
    }

    // ========================================
    // Scroll Synchronization
    // ========================================

    function setupScrollSync() {
        const trackWrapper = document.getElementById('trackScrollWrapper');
        const gridViewport = document.querySelector('.ag-center-cols-viewport');
        const gridHScroll = document.querySelector('.ag-body-horizontal-scroll-viewport');

        if (!trackWrapper) return;

        // Sync track scroll to grid
        trackWrapper.addEventListener('scroll', function() {
            if (gridViewport) {
                gridViewport.scrollLeft = trackWrapper.scrollLeft;
            }
            if (gridHScroll) {
                gridHScroll.scrollLeft = trackWrapper.scrollLeft;
            }
        });

        // Sync grid to track scroll
        if (gridViewport) {
            gridViewport.addEventListener('scroll', function() {
                trackWrapper.scrollLeft = gridViewport.scrollLeft;
            });
        }

        if (gridHScroll) {
            gridHScroll.addEventListener('scroll', function() {
                trackWrapper.scrollLeft = gridHScroll.scrollLeft;
            });
        }
    }

    // ========================================
    // Control Functions
    // ========================================

    function resetRowOrder() {
        if (gridApi) {
            gridApi.setGridOption('rowData', JSON.parse(JSON.stringify(originalRowData)));
        }
    }

    // ========================================
    // Similarity Grouping Functions
    // ========================================

    /**
     * Compute similarity score between two sample rows
     * Returns the number of positions where both samples have the same variant value
     */
    function computeSimilarity(row1, row2) {
        let matches = 0;
        let total = 0;

        positionList.forEach(pos => {
            const key = 'pos_' + pos;
            const val1 = row1[key];
            const val2 = row2[key];

            if (val1 && val2) {
                total++;
                // Compare the variant values (A, T, C, G, A/T, etc.)
                if (val1.value === val2.value) {
                    matches++;
                }
            }
        });

        // Return similarity as a ratio (0 to 1)
        return total > 0 ? matches / total : 0;
    }

    /**
     * Check if a row has any variation (i.e., has at least one actual variant)
     * Returns true if the row has variation, false if all positions are "-" or empty
     */
    function hasVariation(row) {
        for (const pos of positionList) {
            const key = 'pos_' + pos;
            const cell = row[key];
            if (cell && cell.hasVariant) {
                return true;
            }
        }
        return false;
    }

    /**
     * Group rows by similarity using greedy neighbor-joining algorithm
     * Rows with zero variation are moved to the bottom first
     * Then starts with first row with variation, repeatedly adds the most similar remaining row
     */
    function groupBySimilarity() {
        if (!gridApi) return;

        // Get current row data from grid
        const currentRows = [];
        gridApi.forEachNode(node => {
            currentRows.push(node.data);
        });

        if (currentRows.length <= 1) return;

        // Separate rows with variation from those without
        const rowsWithVariation = [];
        const rowsWithoutVariation = [];

        currentRows.forEach(row => {
            if (hasVariation(row)) {
                rowsWithVariation.push(row);
            } else {
                rowsWithoutVariation.push(row);
            }
        });

        // If no rows have variation, just keep original order
        if (rowsWithVariation.length === 0) {
            console.log('No rows with variation found');
            return;
        }

        // Build similarity matrix for rows with variation only
        const n = rowsWithVariation.length;
        const similarity = [];
        for (let i = 0; i < n; i++) {
            similarity[i] = [];
            for (let j = 0; j < n; j++) {
                if (i === j) {
                    similarity[i][j] = 1; // Perfect similarity with self
                } else if (j < i) {
                    similarity[i][j] = similarity[j][i]; // Symmetric
                } else {
                    similarity[i][j] = computeSimilarity(rowsWithVariation[i], rowsWithVariation[j]);
                }
            }
        }

        // Greedy ordering: start with first row, repeatedly add most similar
        const ordered = [];
        const used = new Set();

        // Start with the first row that has variation
        ordered.push(rowsWithVariation[0]);
        used.add(0);

        // Keep adding the most similar remaining row to the last added row
        while (ordered.length < n) {
            const lastIdx = rowsWithVariation.indexOf(ordered[ordered.length - 1]);
            let bestIdx = -1;
            let bestSim = -1;

            for (let i = 0; i < n; i++) {
                if (!used.has(i)) {
                    if (similarity[lastIdx][i] > bestSim) {
                        bestSim = similarity[lastIdx][i];
                        bestIdx = i;
                    }
                }
            }

            if (bestIdx >= 0) {
                ordered.push(rowsWithVariation[bestIdx]);
                used.add(bestIdx);
            }
        }

        // Append rows without variation at the bottom
        const finalOrder = ordered.concat(rowsWithoutVariation);

        // Update grid with new order
        gridApi.setGridOption('rowData', finalOrder);
        console.log('Rows grouped by similarity (' + rowsWithVariation.length + ' with variation, ' + rowsWithoutVariation.length + ' without)');
    }

    function exportToCSV() {
        if (gridApi) {
            // Generate human-readable filename with date
            const now = new Date();
            const dateStr = now.getFullYear() + '-' +
                String(now.getMonth() + 1).padStart(2, '0') + '-' +
                String(now.getDate()).padStart(2, '0');
            const geneList = '<%= request.getParameter("geneList") != null ? request.getParameter("geneList") : "" %>';
            const region = 'chr' + chromosome;
            const prefix = geneList ? geneList.replace(/[^a-zA-Z0-9]/g, '_') : region;
            const fileName = 'variants_' + prefix + '_' + dateStr + '.csv';

            gridApi.exportDataAsCsv({
                fileName: fileName,
                processCellCallback: (params) => {
                    if (params.value && typeof params.value === 'object') {
                        return params.value.value;
                    }
                    return params.value;
                }
            });
        }
    }

    // ========================================
    // Overview Map Functions
    // ========================================

    function showOverview() {
        document.getElementById('overview').style.display = 'flex';
        document.getElementById('overview').style.flexDirection = 'column';
        renderOverview();
    }

    function closeOverview() {
        document.getElementById('overview').style.display = 'none';
    }

    // ========================================
    // Overview Drag Functionality
    // ========================================

    function initOverviewDrag() {
        const overview = document.getElementById('overview');
        const header = document.getElementById('overview-header');

        if (!overview || !header) return;

        let isDragging = false;
        let offsetX = 0;
        let offsetY = 0;

        header.addEventListener('mousedown', function(e) {
            // Don't start drag if clicking on the close button
            if (e.target.tagName === 'A' || e.target.tagName === 'IMG') return;

            isDragging = true;
            offsetX = e.clientX - overview.offsetLeft;
            offsetY = e.clientY - overview.offsetTop;

            // Prevent text selection while dragging
            e.preventDefault();
        });

        document.addEventListener('mousemove', function(e) {
            if (!isDragging) return;

            let newX = e.clientX - offsetX;
            let newY = e.clientY - offsetY;

            // Keep within viewport bounds
            newX = Math.max(0, Math.min(newX, window.innerWidth - overview.offsetWidth));
            newY = Math.max(0, Math.min(newY, window.innerHeight - overview.offsetHeight));

            overview.style.left = newX + 'px';
            overview.style.top = newY + 'px';
        });

        document.addEventListener('mouseup', function() {
            isDragging = false;
        });
    }

    function renderOverview() {
        const container = document.getElementById('overview-region');
        if (!container) return;
        container.innerHTML = '';
        // Don't set width on container - let it be constrained by parent

        // Build a map of sampleId to overview data for quick lookup
        const overviewMap = {};
        overviewData.forEach(sample => {
            overviewMap[sample.sampleId] = sample;
        });

        // Render in current grid row order
        if (gridApi) {
            gridApi.forEachNodeAfterFilterAndSort(node => {
                const sampleId = node.data.sampleId;
                const sample = overviewMap[sampleId];
                if (!sample) return;

                const row = document.createElement('div');
                row.className = 'overview-row';
                row.style.width = (positionList.length * 5) + 'px';

                sample.positions.forEach(pos => {
                    const cell = document.createElement('div');
                    cell.className = 'overview-cell';
                    cell.style.backgroundColor = pos.bgColor;
                    row.appendChild(cell);
                });

                container.appendChild(row);
            });
        } else {
            // Fallback to original order if grid not ready
            overviewData.forEach(sample => {
                const row = document.createElement('div');
                row.className = 'overview-row';
                row.style.width = (positionList.length * 5) + 'px';

                sample.positions.forEach(pos => {
                    const cell = document.createElement('div');
                    cell.className = 'overview-cell';
                    cell.style.backgroundColor = pos.bgColor;
                    row.appendChild(cell);
                });

                container.appendChild(row);
            });
        }
    }

    // ========================================
    // Responsive Width Handling
    // ========================================

    function checkWidth() {
        const newWidth = window.innerWidth - 250;
        const trackWrapper = document.getElementById('trackScrollWrapper');
        const mainContainer = document.getElementById('mainContainer');

        if (trackWrapper) {
            trackWrapper.style.maxWidth = newWidth + 'px';
        }

        const overview = document.getElementById('overview');
        const overviewRegion = document.getElementById('overview-region');
        if (overview && overviewRegion) {
            const maxOverviewWidth = Math.min(newWidth + 150, window.innerWidth - 60);
            overview.style.maxWidth = maxOverviewWidth + 'px';
        }
    }

    // ========================================
    // Initialization
    // ========================================

    window.onload = function() {
        // Render tracks
        if (showConservation) {
            renderConservationTrack(document.getElementById('conservationTrack'), conservationData);
        }
        renderGeneTrack(document.getElementById('plusGeneTrack'), plusGeneData);
        if (hasPlusConflict) {
            renderGeneTrack(document.getElementById('plusOverflowTrack'), plusOverflowData);
        }
        renderGeneTrack(document.getElementById('minusGeneTrack'), minusGeneData);
        if (hasMinusConflict) {
            renderGeneTrack(document.getElementById('minusOverflowTrack'), minusOverflowData);
        }
        renderRefNucTrack(document.getElementById('refNucTrack'), refNucData);
        renderPositionHeaders(document.getElementById('positionHeaders'), positionList);

        // Setup responsive width
        checkWidth();

        // Initialize overview drag functionality
        initOverviewDrag();
    };

    window.onresize = checkWidth;
</script>

<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<div style="padding: 20px; background: #f8d7da; color: #721c24; margin: 20px;">
    <strong>Error:</strong> <%= e.getMessage() %>
</div>
<%
    }
%>
<%@ include file="/common/footerarea.jsp" %>
