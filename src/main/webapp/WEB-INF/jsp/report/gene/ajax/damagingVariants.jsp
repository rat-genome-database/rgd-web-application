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
                }
%>
    <tr>
        <td><%=Utils.defaultString(v.getChromosome())%></td>
        <td class="rgdCellNowrap"><%=position%></td>
        <td class="rgdCellNowrap"><%=Utils.defaultString(v.getReferenceNucleotide())%></td>
        <td class="rgdCellNowrap"><%=Utils.defaultString(v.getVariantNucleotide())%></td>
        <td><%=Utils.defaultString(v.getVariantType())%></td>
        <td class="damagingVariantsStrains"><%=strains.length()==0 ? "&nbsp;" : strains.toString()%></td>
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
</div>
<%}%>
