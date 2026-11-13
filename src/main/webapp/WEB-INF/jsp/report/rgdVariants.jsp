<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.RgdVariantDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdVariant" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Arrays" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Set" %>
<%!
    // Long ref/var nucleotide sequences (deletions/insertions can be kb-scale)
    // are shown collapsed with a FASTA-wrapped expander.
    String formatNuc(String s) {
        if (s == null || s.isEmpty()) return "-";
        if (s.length() <= 60) return s;
        StringBuilder fasta = new StringBuilder(s.length() + s.length()/60 + 4);
        for (int i = 0; i < s.length(); i += 60) {
            fasta.append(s, i, Math.min(i + 60, s.length())).append('\n');
        }
        return "<details style=\"display:inline-block; vertical-align:top; max-width:520px;\">"
            + "<summary style=\"cursor:pointer; color:#24609c; font-family:monospace; font-size:11px;\">"
            + s.substring(0, 30) + "&hellip; <span style=\"color:#666; font-family:Arial; font-size:11px;\">("
            + s.length() + " bp)</span></summary>"
            + "<pre style=\"font-family:monospace; font-size:11px; margin:4px 0 0 0; white-space:pre; "
            + "max-height:240px; max-width:520px; overflow:auto; padding:4px; background:#f7f7f7; "
            + "border:1px solid #ddd;\">" + fasta + "</pre></details>";
    }

    // The viewer only has a marker shape for these; anything else is drawn as nothing at
    // all, so a variant typed with some other sequence ontology term gets no viewer rather
    // than an empty one. Matched case-insensitively because the track lowercases too, which
    // lets the ontology's own spelling ("SNV", "MNV") reach the tooltip intact.
    Set<String> drawableVariantTypes = new HashSet<String>(Arrays.asList(
            "snv", "point_mutation", "mnv", "deletion", "insertion", "delins",
            "substitution", "indel"));

    boolean isDrawableVariantType(String soTerm) {
        return soTerm != null && drawableVariantTypes.contains(soTerm.toLowerCase());
    }

    // A kb-scale allele would be unreadable in a tooltip and is already on the page in
    // full, in the table above, so the viewer gets an abbreviated form.
    String abbreviateNuc(String s) {
        if (s == null || s.isEmpty()) return "";
        if (s.length() <= 24) return s;
        return s.substring(0, 10) + "\u2026" + s.substring(s.length() - 10)
                + " (" + s.length() + " bp)";
    }

    // Quote a value as a JSON string literal. The markup-significant characters are escaped
    // as well as the JSON-significant ones because this lands inside a <script> element,
    // where an unescaped "</script>" in a value would end the block early.
    String jsonStr(String s) {
        if (s == null) return "\"\"";
        StringBuilder sb = new StringBuilder(s.length() + 16).append('"');
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '"':  sb.append("\\\""); break;
                case '\\': sb.append("\\\\"); break;
                case '\n': sb.append("\\n"); break;
                case '\r': sb.append("\\r"); break;
                case '\t': sb.append("\\t"); break;
                case '<':  sb.append("\\u003c"); break;
                case '>':  sb.append("\\u003e"); break;
                case '&':  sb.append("\\u0026"); break;
                default:
                    if (c < 0x20) sb.append(String.format("\\u%04x", (int) c));
                    else sb.append(c);
            }
        }
        return sb.append('"').toString();
    }
%>

<%@ include file="sectionHeader.jsp"%>
<%
    RgdVariantDAO variantDAO = new RgdVariantDAO();
    OntologyXDAO odao = new OntologyXDAO();
    List<RgdVariant> variants = new ArrayList<>();
    if(title.equals("Genes"))
        variants = variantDAO.getVariantsFromGeneRgdId(obj.getRgdId());
    else if (title.equals("Strains"))
        variants = variantDAO.getVariantsFromStrainKey(obj.getKey());

    // Each variant is drawn in its own viewer, on one assembly: the table below repeats a
    // variant once per assembly it is mapped to, while a viewer needs a single coordinate
    // system to place the variant against a gene model. Which one is picked per variant,
    // below. Only the strain report
    // gets these - the gene report already carries a viewer of its own for the gene region,
    // in gene/info.jsp, and a second set of them would load the same scripts twice.
    boolean drawVariantViewers = title.equals("Strains") && variants.size() > 0;
    StringBuilder variantViewerJs = new StringBuilder();
    StringBuilder variantViewerHtml = new StringBuilder();

    if(variants.size()>0){
%>
<%--<%=ui.dynOpen("rgdVariants", "Rat Variants")%>--%>
<div class="light-table-border">
<div class="sectionHeading" id="rgdVariants">Allelic Variants</div>
<table id="variants" border="1" cellspacing="0" width="95%">
    <tr>
        <td align="center"><b>Name</b></td>
        <td align="center"><b>Chromosome</b></td>
        <td align="center"><b>Start Pos</b></td>
        <td align="center"><b>End Pos</b></td>
        <td align="Left"><b>Reference Nucleotide</b></td>
        <td align="Left"><b>Variant Nucleotide</b></td>
        <td align="center"><b>Variant Type</b></td>
        <td align="center"><b>Assembly</b></td>

    </tr>
    <%
        edu.mcw.rgd.datamodel.Map variantRefMap = null;
        if( drawVariantViewers ) {
            variantRefMap = mapDAO.getPrimaryRefAssembly(obj.getSpeciesTypeKey());
        }

        String rowClass="oddRow";
        for (RgdVariant variant : variants)
        {
            // alternate rows {even,odd}
            if( rowClass.equals("oddRow") )
                rowClass = "evenRow";
            else
                rowClass = "oddRow";

            Term so = odao.getTermByAccId(variant.getType());
            String soTerm = so==null ? variant.getType() : so.getTerm();

            // hoisted out of the row loop: the same positions pick the one the viewer draws
            List<MapData> variantPositions = mapDAO.getMapData(variant.getRgdId());

            for(MapData var : variantPositions) {
            %>
            <tr>
            <td align="center"><a href="/rgdweb/report/rgdvariant/main.html?id=<%=var.getRgdId()%>"><%=variant.getName()%></a></td>
            <td align="center"><%="chr"+var.getChromosome()%></td>
            <td align="center"><%=var.getStartPos()%></td>
            <td align="center"><%=var.getStopPos()%></td>
            <td align="left" style="vertical-align:top; word-break:break-all;"><%= formatNuc(variant.getRefNuc()) %></td>
            <td align="left" style="vertical-align:top; word-break:break-all;"><%= formatNuc(variant.getVarNuc()) %></td>
            <td align="center"><%= soTerm %></td>
                <td><%=mapDAO.getMap(var.getMapKey()).getName()%></td>
        </tr>
            <% } // end varData for

            if( drawVariantViewers && isDrawableVariantType(soTerm) ) {
                // The primary reference assembly is preferred, but a variant that was never
                // mapped to it - older curated ones often stop at mRatBN7.2 - falls back to
                // the best assembly it does have rather than getting no viewer at all. Maps
                // rank lowest-is-newest, the same order MapDataFormatter sorts positions in.
                // Nothing is claimed that isn't drawn: the caption and the tooltip both name
                // the assembly the viewer is actually built on.
                MapData viewerPos = null;
                edu.mcw.rgd.datamodel.Map viewerMap = null;
                int bestRank = Integer.MAX_VALUE;
                for(MapData var : variantPositions) {
                    edu.mcw.rgd.datamodel.Map posMap = mapDAO.getMap(var.getMapKey());
                    if( posMap==null )
                        continue;
                    int rank = variantRefMap!=null && var.getMapKey()==variantRefMap.getKey()
                            ? Integer.MIN_VALUE : posMap.getRank();
                    if( rank < bestRank ) {
                        bestRank = rank;
                        viewerPos = var;
                        viewerMap = posMap;
                    }
                }

                if( viewerPos!=null ) {
                    MapData var = viewerPos;
                    String divId = "variantViewer" + variant.getRgdId() + "_" + var.getKey();
                    String location = "chr" + var.getChromosome() + ":" + var.getStartPos()
                            + (var.getStartPos()==var.getStopPos() ? "" : ".." + var.getStopPos());

                    variantViewerHtml.append("<div class=\"variantViewerBlock\" id=\"")
                        .append(divId).append("Block\">")
                        .append("<div class=\"variantViewerTitle\">")
                        .append("<a href=\"/rgdweb/report/rgdvariant/main.html?id=").append(variant.getRgdId()).append("\">")
                        .append(variant.getName()).append("</a> &ndash; ").append(location)
                        .append(" (").append(viewerMap.getName()).append(")</div>")
                        .append("<div class=\"variantViewerRange\" id=\"").append(divId).append("Range\"></div>")
                        .append("<svg class=\"viewer\" id=\"").append(divId).append("\"></svg>")
                        .append("</div>\n");

                    if( variantViewerJs.length()>0 )
                        variantViewerJs.append(",\n");
                    variantViewerJs.append("    {divId: ").append(jsonStr(divId))
                        .append(", rgdId: ").append(variant.getRgdId())
                        .append(", name: ").append(jsonStr(variant.getName()))
                        .append(", chr: ").append(jsonStr(var.getChromosome()))
                        .append(", start: ").append(var.getStartPos())
                        .append(", stop: ").append(var.getStopPos())
                        .append(", mapKey: ").append(var.getMapKey())
                        .append(", assembly: ").append(jsonStr(viewerMap.getName()))
                        .append(", species: ").append(jsonStr(SpeciesType.getShortName(variant.getSpeciesTypeKey())))
                        .append(", type: ").append(jsonStr(soTerm))
                        .append(", refNuc: ").append(jsonStr(abbreviateNuc(variant.getRefNuc())))
                        .append(", varNuc: ").append(jsonStr(abbreviateNuc(variant.getVarNuc())))
                        .append("}");
                }
            }
        } //end variant for %>
</table>

<% if( variantViewerJs.length()>0 ) { %>
<style>
    /* no background here: an <svg> has none of its own, but these sit inside the Allelic
       Variants card, and the white comes from that - the CNV report needed .light-table-border
       on its viewer only because that viewer stood on the page ground with no card around it */
    .variantViewerBlock { margin:12px 0 0 0; padding:8px; }
    .variantViewerTitle { font-weight:bold; padding-bottom:2px; }
    .variantViewerRange { color:#555; font-size:11px; padding-bottom:4px; }
</style>
<div id="variantViewers">
<%= variantViewerHtml %>
</div>

<script src="https://unpkg.com/react@17/umd/react.development.js" crossorigin></script>
<script src="https://unpkg.com/react-dom@17/umd/react-dom.development.js" crossorigin></script>
<link rel="stylesheet" href="/rgdweb/js/sequenceViewer/GenomeFeatureViewer.css">

<script src="/rgdweb/js/sequenceViewer/RenderFunctions.js"></script>
<script src="/rgdweb/js/sequenceViewer/services/ApolloService.js"></script>
<script src="/rgdweb/js/sequenceViewer/services/ConsequenceService.js"></script>
<script src="/rgdweb/js/sequenceViewer/services/LegenedService.js"></script>
<script src="/rgdweb/js/sequenceViewer/services/TrackService.js"></script>
<script src="/rgdweb/js/sequenceViewer/services/VariantService.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/IsoformAndVariantTrack.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/IsoformEmbeddedVariantTrack.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/IsoformTrack.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/ReferenceTrack.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/TrackTypeEnum.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/VariantTrack.js"></script>
<script src="/rgdweb/js/sequenceViewer/tracks/VariantTrackGlobal.js"></script>
<script src="/rgdweb/js/sequenceViewer/Drawer.js"></script>
<script src="/rgdweb/js/sequenceViewer/GenomeFeatureViewer.js"></script>
<script src="https://d3js.org/d3.v7.min.js"></script>
<script src="/rgdweb/js/sequenceViewer/strainVariantViewers.js?v=1"></script>

<script>
    var strainVariants = [
<%= variantViewerJs %>
    ];
    document.addEventListener("DOMContentLoaded", function() {
        drawStrainVariantViewers(strainVariants);
    });
</script>
<% } %>
</div>
<%--<%=ui.dynClose("rgdVariants")%>--%>
<% } // end if variants is not empty%>
<%@ include file="sectionFooter.jsp"%>
