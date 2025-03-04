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
<div class="sectionHeading" id="miRnaTargetStatus">miRNA Target Status (No longer updated)</div>
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
    %><p>
    <div style="font-weight:bold"><%= isMirnaGene?"Confirmed Targets":"Confirmed Target Of"%></div>
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
%><p>
    <div style="font-weight:bold"><%= isMirnaGene?"Predicted Targets":"Predicted Target Of"%></div>
    <%=report.format(new HTMLTableReportStrategy())%><p>
    <table>
    <tr><td>The detailed report is available here:</td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/genes/mirnaTargets.html?id=<%=obj.getRgdId()%>&fmt=full">Full Report</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/genes/mirnaTargets.html?id=<%=obj.getRgdId()%>&fmt=csv">CSV</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/genes/mirnaTargets.html?id=<%=obj.getRgdId()%>&fmt=tab">TAB</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/genes/mirnaTargets.html?id=<%=obj.getRgdId()%>&fmt=print">Printer</a></span></td>
    </tr>
    <tr><td colspan="9"><br>miRNA Target Status data imported from miRGate (<a href="http://mirgate.bioinfo.cnio.es/">http://mirgate.bioinfo.cnio.es/</a>).<br>
        For more information about miRGate, see <a href="https://www.ncbi.nlm.nih.gov/pubmed/25858286">PMID:25858286</a>
        or access the full paper <a href="http://database.oxfordjournals.org/content/2015/bav035.full.pdf+html">here</a>.</td>
    </tr>
    </table>
</div>
<% } %>
<%//ui.dynClose("miRnaTargets")%>
<%@ include file="sectionFooter.jsp"%>
<%}%>
