<%@ page import="edu.mcw.rgd.dao.impl.VariantDAO" %>
<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.SampleDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="edu.mcw.rgd.datamodel.Variant" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="java.util.LinkedHashSet" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>

<style>
    /* One block per assembly, each a compact table in the same style as the Nucleotide and
       Protein Sequences sections. This used to be a bare <table id="variants"> repeated once
       per assembly - the same DOM id several times over - with <td><b>..</b></td> standing in
       for a header row. */
    .damagingVariantsAssembly {
        margin: 14px 0 6px;
        font-size: 13px;
        font-weight: 700;
        color: #1f2933;
    }
    .damagingVariantsAssembly .damagingVariantsAssemblyName { color: #2865a3; }
    #damagingVariantsTableDiv .rgdCompactTable { margin-bottom: 4px; }
    /* these tables are not wired to tablesorter, so the shared compact-table rule that offers a
       pointer on every header would be promising a sort that does not happen */
    #damagingVariantsTableDiv .rgdCompactTable > thead > tr > th { cursor: default; }
    /* the shared even/odd tint is painted by tablesorter's zebra widget so that striping survives
       paging; nothing pages here, so nth-child gives the same look with no widget */
    #damagingVariantsTableDiv .rgdCompactTable > tbody > tr:nth-child(even) > td { background: #fafbfc; }
    /* the strain list is the widest cell by far; let it wrap rather than stretch the table */
    #damagingVariantsTableDiv td.damagingVariantsStrains {
        white-space: normal;
        line-height: 1.9;
    }

    /* An allele carried by most of the panel lists ~100 strains - 20-odd wrapped lines in a
       single cell, and six such rows on a gene like A2m - so the list is collapsed to the first
       couple of lines with a toggle. The clamp is applied by script, not here: the cell is
       rendered open so that with no JS it still shows every strain, and only the script knows
       whether a given cell actually overflows two lines at the current width. */
    #damagingVariantsTableDiv .dvStrainList.is-clamped {
        overflow: hidden;
    }
    #damagingVariantsTableDiv .dvStrainsToggle {
        display: inline-block;
        margin-left: 6px;
        padding: 1px 8px;
        border: 1px solid #cfd6de;
        border-radius: 4px;
        background: #fff;
        font-size: 11px;
        font-weight: 700;
        line-height: 1.5;
        color: #5b6672;
        cursor: pointer;
        white-space: nowrap;
    }
    #damagingVariantsTableDiv .dvStrainsToggle:hover {
        border-color: #a9b4c0;
        background: #f4f6f9;
        color: #1f2933;
    }
    /* sits on its own line under the clamped chips rather than inline among them, so it does not
       read as one more strain */
    #damagingVariantsTableDiv .dvStrainsToggleWrap {
        margin-top: 2px;
        line-height: 1.5;
    }
</style>
<%
    int objRgdId = (int) request.getAttribute("id");
    String objSymbol = (String) request.getAttribute("symbol");

    VariantDAO vdao = new VariantDAO();
    vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
    List<String> assemblies = vdao.getGeneAssemblyOfDamagingVariants(objRgdId);
    SampleDAO sdao = new SampleDAO();
    sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

    // A sample is looked up once for the whole section instead of once per variant row: the same
    // handful of strains carry every variant, so the old per-row getSample() was the same few
    // queries repeated hundreds of times.
    java.util.Map<Integer, Sample> sampleCache = new HashMap<>();

    String encodedSymbol = URLEncoder.encode(Utils.defaultString(objSymbol), "UTF-8");

    if(assemblies.size() != 0) { %>
<div id="damagingVariantsTableDiv" class="light-table-border">

<div class="sectionHeading" id="damagingVariants">Damaging Variants</div>

<%
    for(int i = assemblies.size()-1; i >=0  ; i--){
        String a = assemblies.get(i);
        List<Variant> assembly = vdao.getDamagingVariantsForGeneByAssembly(objRgdId,a);
        Map m = MapManager.getInstance().getMap(Integer.valueOf(a));
        if( !assembly.isEmpty() && m!=null ) {

            // One row per distinct allele, listing every strain that carries it. The rows used to
            // be merged only while consecutive rows matched, by comparing each variant with the one
            // before it and building the strain cell by hand - which dropped the closing </a> of
            // every strain after the first, so the links ran into each other. Keying the whole
            // assembly keeps the same one-row-per-allele result without depending on row order.
            LinkedHashMap<String, List<Variant>> byAllele = new LinkedHashMap<>();
            for( Variant v: assembly ) {
                String alleleKey = Utils.defaultString(v.getChromosome())
                        + "|" + v.getStartPos() + "|" + v.getEndPos()
                        + "|" + Utils.defaultString(v.getReferenceNucleotide()).toUpperCase()
                        + "|" + Utils.defaultString(v.getVariantNucleotide()).toUpperCase();
                byAllele.computeIfAbsent(alleleKey, k -> new ArrayList<Variant>()).add(v);
            }
%>

<div class="damagingVariantsAssembly">Assembly: <span class="damagingVariantsAssemblyName"><%=m.getName()%></span></div>

<table border="0" class="rgdCompactTable">
    <thead>
        <tr>
            <th>Chr</th>
            <th>Position</th>
            <th>Reference</th>
            <th>Variant</th>
            <th>Type</th>
            <th>Strains</th>
            <th class="rgdColRight">Variant Page</th>
        </tr>
    </thead>
    <tbody>
<%
            for( List<Variant> allele: byAllele.values() ) {

                Variant v = allele.get(0);   // every variant in the group has the same position and alleles

                // start and stop are the same base for a substitution, so show one position there
                // and a range only where there really is one
                String position = v.getStartPos()==v.getEndPos()
                        ? FormUtility.formatThousands(v.getStartPos())
                        : FormUtility.formatThousands(v.getStartPos()) + "&nbsp;-&nbsp;" + FormUtility.formatThousands(v.getEndPos());

                // the strains carrying this allele, each linked to its own variant search; a strain
                // that appears twice in the group is listed once
                StringBuilder strains = new StringBuilder();
                LinkedHashSet<Integer> seenSamples = new LinkedHashSet<>();
                int strainCount = 0;   // chips actually written, which is not seenSamples.size():
                                       // a sample id with no Sample row is skipped below
                for( Variant av: allele ) {
                    if( !seenSamples.add(av.getSampleId()) ) {
                        continue;
                    }
                    Sample s = sampleCache.get(av.getSampleId());
                    if( s==null ) {
                        s = sdao.getSample(av.getSampleId());
                        if( s==null ) {
                            continue;
                        }
                        sampleCache.put(av.getSampleId(), s);
                    }
                    String url = "/rgdweb/front/variants.html?chr=&start=&stop=&geneStart=&geneStop=&mapKey="
                            + m.getKey() + "&geneList=" + encodedSymbol
                            + "&con=&probably=true&possibly=true&depthLowBound=8&depthHighBound=&excludePossibleError=true"
                            + "&sample1=" + s.getId();
                    strains.append("<a class=\"rgdChipLink\" href=\"")
                            .append(StringEscapeUtils.escapeHtml4(url))
                            .append("\" title=\"Damaging variants in this gene for this strain\">")
                            .append(StringEscapeUtils.escapeHtml4(Utils.defaultString(s.getAnalysisName())))
                            .append("</a> ");
                    strainCount++;
                }
%>
    <tr>
        <td><%=Utils.defaultString(v.getChromosome())%></td>
        <td class="rgdCellNowrap"><%=position%></td>
        <td class="rgdCellNowrap"><%=Utils.defaultString(v.getReferenceNucleotide())%></td>
        <td class="rgdCellNowrap"><%=Utils.defaultString(v.getVariantNucleotide())%></td>
        <td><%=Utils.defaultString(v.getVariantType())%></td>
        <%-- the chips go in their own box so the clamp below has something to bound: an allele
             carried by most of the panel lists ~100 strains, which ran to 20-odd lines in this
             one cell. Rendered unclamped; the script at the foot of this fragment is what
             collapses it, so with no JS the cell still shows every strain. --%>
        <td class="damagingVariantsStrains"><%
            if( strains.length()==0 ) {
                %>&nbsp;<%
            } else {
                %><div class="dvStrainList" data-strain-count="<%=strainCount%>"><%=strains.toString()%></div><%
            }
        %></td>
        <td class="rgdColRight">
            <a class="rgdChipLink" href="/rgdweb/report/variants/main.html?id=<%=v.getId()%>"
               title="see more information in the variant page">Variant Report</a>
        </td>
    </tr>
<%
            }
%>
    </tbody>
</table>
<%
        }
    }
%>

<%-- Collapses each strain cell to the first couple of lines. This fragment is injected with
     jQuery .html(), which runs the scripts it contains, so this executes once the rows are in
     the document and can be measured - the clamp depends on how many chips happen to fit on a
     line at the current width, which is not known server side. --%>
<script>
(function () {
    var LINES_SHOWN = 2;

    function lineHeightOf(el) {
        var lh = parseFloat(window.getComputedStyle(el).lineHeight);
        if (lh > 0) {
            return lh;
        }
        // computed lineHeight comes back "normal" in a few browsers; the cell sets 1.9
        var fs = parseFloat(window.getComputedStyle(el).fontSize) || 11;
        return fs * 1.9;
    }

    // Decide for one cell whether it needs collapsing, and leave it in the right state. Called
    // again on resize, because a cell that needed a toggle at one width may not at another.
    function apply(list) {
        var wrap = list.nextElementSibling;
        var hasWrap = wrap && wrap.classList.contains('dvStrainsToggleWrap');
        var expanded = hasWrap && wrap.firstChild.getAttribute('aria-expanded') === 'true';

        // measure unclamped
        list.classList.remove('is-clamped');
        list.style.maxHeight = '';
        var max = lineHeightOf(list) * LINES_SHOWN;

        // A cell inside a collapsed section measures 0 and would look like it fits. Leave it
        // exactly as it is rather than concluding there is nothing to collapse; the resize pass
        // settles it once the section is open again.
        if (list.scrollHeight === 0) {
            if (expanded === false && hasWrap) {
                setState(list, wrap.firstChild, false);
            }
            return;
        }

        var overflows = list.scrollHeight > max + 2;

        if (!overflows) {
            if (hasWrap) {
                wrap.parentNode.removeChild(wrap);
            }
            return;
        }

        if (!hasWrap) {
            wrap = document.createElement('div');
            wrap.className = 'dvStrainsToggleWrap';
            var btn = document.createElement('button');
            btn.type = 'button';
            btn.className = 'dvStrainsToggle';
            btn.setAttribute('aria-expanded', 'false');
            btn.onclick = function () {
                var open = btn.getAttribute('aria-expanded') === 'true';
                setState(list, btn, !open);
            };
            wrap.appendChild(btn);
            list.parentNode.insertBefore(wrap, list.nextSibling);
        }
        setState(list, wrap.firstChild, expanded);
    }

    function setState(list, btn, open) {
        var total = list.getAttribute('data-strain-count') || '';
        if (open) {
            list.classList.remove('is-clamped');
            list.style.maxHeight = '';
            btn.textContent = 'less';
            btn.title = 'Show fewer strains';
        } else {
            list.style.maxHeight = (lineHeightOf(list) * LINES_SHOWN) + 'px';
            list.classList.add('is-clamped');
            btn.textContent = 'more';
            btn.title = total ? 'Show all ' + total + ' strains' : 'Show all strains';
        }
        btn.setAttribute('aria-expanded', open ? 'true' : 'false');
    }

    function applyAll() {
        var lists = document.querySelectorAll('#damagingVariantsTableDiv .dvStrainList');
        for (var i = 0; i < lists.length; i++) {
            apply(lists[i]);
        }
    }

    applyAll();

    var t = null;
    window.addEventListener('resize', function () {
        if (t) {
            clearTimeout(t);
        }
        t = setTimeout(applyAll, 150);
    });
})();
</script>
</div>
<%}%>
