<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.datamodel.MiRnaTarget" %>
<%@ page import="edu.mcw.rgd.dao.impl.MiRnaTargetDAO" %>
<%@ page import="edu.mcw.rgd.reporting.Record" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<script>
    $(document).ready(function(){
        var IEversion = detectIE();
        if( IEversion !== false && IEversion<11 ) {
            // cytoscape is not supported in IE lower than IE 11
            $('#cyChart').html('<div style="border: 1 solid red;padding: 5px;margin-top:10px;font-weight:bold;font-size:13px;">' +
                'Note! Cytoscape chart is available in Internet Explorer 11, or higher!' +
                '</div>');
        } else {
            $('#cyChart').html('<iframe id="cyIFrame" name="cyIFrame" width="800" height="800" '+
                'src="/rgdweb/ontology/cy.html?aspect=D&geneRgdId=<%=obj.getRgdId()%>&domContainerId=xyz&title=Gene+targets+with+annotations+to+main+disease+categories">' +
                '</iframe>');
        }
    });
</script>
<%
    // detect if this gene is a mirna gene or not
    boolean isMirnaGene = Utils.stringsAreEqualIgnoreCase(obj.getType(), "ncrna") &&
            Utils.defaultString(obj.getName()).startsWith("microRNA");

    List<MiRnaTarget> miRnaTargetsConfirmed;
    MiRnaTargetDAO miRnaTargetDAO = new MiRnaTargetDAO();
    if( isMirnaGene ) {
        miRnaTargetsConfirmed = miRnaTargetDAO.getTargets(obj.getRgdId(), "confirmed");
    } else {
        miRnaTargetsConfirmed = miRnaTargetDAO.getMiRnaGenes(obj.getRgdId(), "confirmed");
    }

    java.util.Map<String,String> miRnaPredictedStats = new HashMap<String,String>();
    for( MiRnaTargetStat stat: miRnaTargetDAO.getStats(obj.getRgdId()) ) {
        miRnaPredictedStats.put(stat.getName(), stat.getValue());
    }

    int confirmedCount = miRnaTargetsConfirmed.size();
    int predictedCount = miRnaPredictedStats.size();

    if( confirmedCount+predictedCount > 0 ) {
%>
<%@ include file="sectionHeader.jsp"%>
<%//ui.dynOpen("miRnaTargets", "miRNA Target Status")%>
<div class="light-table-border">
<div class="sectionHeading" id="miRnaTargetStatus">miRNA Target Status<%--
     the qualifier is a footnote about the data, not part of the section name; as bracketed
     text it also pushed the sidebar entry past its length cap and got cut mid-bracket --%><span class="rgdInfoDot" title="No longer updated" aria-label="miRNA Target Status is no longer updated" role="img">i</span></div>
    <% if( confirmedCount>0 ) {

        String pubmedUrl = xdbDAO.getXdbUrl(XdbId.XDB_KEY_PUBMED, obj.getSpeciesTypeKey());

        Report report = new Report();
        Record rec = new Record();
        rec.append(isMirnaGene ? "Gene Target" : "miRNA Gene");
        rec.append("Mature miRNA");
        rec.append("Method Name");
        rec.append("Result Type");
        rec.append("Data Type");
        rec.append("Support Type");
        rec.append("PMID");
        report.append(rec);

        for( MiRnaTarget t: miRnaTargetsConfirmed ) {
            Gene miGene = geneDAO.getGene(isMirnaGene ? t.getGeneRgdId() : t.getMiRnaRgdId());

            rec = new Record();
            rec.append("<a href=\""+Link.gene(miGene.getRgdId())+"\">"+miGene.getSymbol()+"</a>");
            rec.append(t.getMiRnaSymbol());
            rec.append(t.getMethodName());
            rec.append(t.getResultType());
            rec.append(t.getDataType());
            rec.append(t.getSupportType());
            if( Utils.NVL(t.getPmid(),"0").equals("0") ) {
                rec.append("");
            } else {
                rec.append("<a href=\""+pubmedUrl+t.getPmid()+"\">"+t.getPmid()+"</a>");
            }
            report.append(rec);
        }
    %>
    <div class="annotGroup"><%= isMirnaGene?"Confirmed Targets":"Confirmed Target Of"%></div>
    <%=report.format(new HTMLTableReportStrategy())%>
    <% if( isMirnaGene ) { // initial iframe %>
<div id="cyChart">
</div>
        <% } %>
    <% } %>

<% if( predictedCount>0 ) {

    Report report = new Report();
    Record rec = new Record();
    rec.append("");
    rec.append("Summary Value");
    report.append(rec);

    rec = new Record();
    rec.append("Count of predictions:");
    rec.append(miRnaPredictedStats.get("Count of predictions"));
    report.append(rec);

    if( isMirnaGene ) {
        rec = new Record();
        rec.append("Count of gene targets:");
        rec.append(miRnaPredictedStats.get("Count of gene targets"));
        report.append(rec);

        rec = new Record();
        rec.append("Count of transcripts:");
        rec.append(miRnaPredictedStats.get("Count of transcripts"));
        report.append(rec);

        rec = new Record();
        rec.append("Interacting mature miRNAs:");
        rec.append(miRnaPredictedStats.get("Interacting mature miRNAs"));
        report.append(rec);
    } else {
        rec = new Record();
        rec.append("Count of miRNA genes:");
        rec.append(miRnaPredictedStats.get("Count of miRNA genes"));
        report.append(rec);

        rec = new Record();
        rec.append("Interacting mature miRNAs:");
        rec.append(miRnaPredictedStats.get("Interacting mature miRNAs"));
        report.append(rec);

        rec = new Record();
        rec.append("Transcripts:");
        rec.append(miRnaPredictedStats.get("Transcripts"));
        report.append(rec);
    }

    rec = new Record();
    rec.append("Prediction methods:");
    rec.append(miRnaPredictedStats.get("Prediction methods"));
    report.append(rec);

    rec = new Record();
    rec.append("Result types:");
    rec.append(miRnaPredictedStats.get("Result types"));
    report.append(rec);
    String miRnaReportUrl = "/rgdweb/genes/mirnaTargets.html?id=" + obj.getRgdId() + "&fmt=";
%>
    <div class="annotGroup"><%= isMirnaGene?"Predicted Targets":"Predicted Target Of"%></div>
    <%=report.format(new HTMLTableReportStrategy())%>

    <%-- four links to one report in four formats. This was a nine column table: a lead-in
         cell, then a green bullet image and a link, four times over. The bullets carried no
         meaning the links did not already carry. --%>
    <div class="rgdLinkRow">
        <span class="rgdLinkRowLead">Detailed report:</span>
        <a class="rgdChipLink" href="<%=miRnaReportUrl%>full">Full report</a>
        <a class="rgdChipLink" href="<%=miRnaReportUrl%>csv">CSV</a>
        <a class="rgdChipLink" href="<%=miRnaReportUrl%>tab">TAB</a>
        <a class="rgdChipLink" href="<%=miRnaReportUrl%>print">Printer</a>
    </div>

    <%-- the attribution used to live in a colspan="9" cell of that same table, behind a <br> --%>
    <p class="rgdSourceNote">
        miRNA Target Status data imported from miRGate
        (<a href="http://mirgate.bioinfo.cnio.es/">mirgate.bioinfo.cnio.es</a>).
        For more information about miRGate see <a href="https://www.ncbi.nlm.nih.gov/pubmed/25858286">PMID:25858286</a>,
        or read the full paper <a href="http://database.oxfordjournals.org/content/2015/bav035.full.pdf+html">here</a>.
    </p>
<% } %>
<%-- the card is opened before the confirmed-targets branch, so it has to be closed after both
     branches: closing it inside `if (predictedCount > 0)` left a gene that has confirmed
     targets but no prediction stats with an open card that swallowed the rest of the page --%>
</div>
<%//ui.dynClose("miRnaTargets")%>
<%@ include file="sectionFooter.jsp"%>
<%}%>
