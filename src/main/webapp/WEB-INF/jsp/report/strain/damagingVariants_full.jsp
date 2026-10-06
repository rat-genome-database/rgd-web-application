<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="java.util.Iterator" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String sample = request.getAttribute("sample").toString();
    String title = "Damaging Variants Report for strain "+sample;
    String pageDescription = title;
    String headContent = "";
    String pageTitle = title;

    Report report = (Report) request.getAttribute("report");
    Set geneList = (Set) request.getAttribute("geneList");
    int sampleId = (int) request.getAttribute("sampleId");
    int mapKey = (int) request.getAttribute("mapKey");
    int species = (int) request.getAttribute("species");
    String assembly = (String) request.getAttribute("assembly");
    String a= new String();

    // The class that turns the report skin on, computed the same way reportHeader.jsp does it.
    String reportSkinClass = RgdContext.isChinchilla(request) ? "rgd-modern-report chinchilla" : "rgd-modern-report";
%>
<%@ include file="/common/compactHeaderArea.jsp" %>

<%-- The three sheets the report look is built from. reportHeader.jsp is deliberately not
     included: as well as these it pulls in tablesorter, jQuery UI, report.js and the report
     hero defaults, and it reads a "requestFacade" request attribute that DamagingVariantController
     never sets. This page needs the styling, not the report machinery.

     rgd_styles-3.css is here because compactHeaderArea only loads bootstrap - so .rgdChipLink
     and .rgdCompactTable, which headerarea.jsp gives every other report page, were missing. --%>
<link href="/rgdweb/common/rgd_styles-3.css" rel="stylesheet" type="text/css" />
<link href="/rgdweb/css/report.css?v=4" rel="stylesheet" type="text/css" />
<link href="/rgdweb/css/reportModern.css?v=36" rel="stylesheet" type="text/css" />

<style>
    /* compactHeaderArea sets background-color:#E8E7E2 inline on <body>, so the gutters either
       side of the max-width container would keep the old grey. An inline style needs
       !important to override, and the skin's --rgd-bg is declared on .rgd-modern-report
       rather than :root, so it cannot be read from here - hence the literal. */
    body { background-color: #f4f6f9 !important; }

    /* .rgd-modern-report is a "sidebar + content" grid. This report has no sidebar, so it
       collapses to a single column; the id makes this outrank the skin's own rule. */
    #page-container.rgd-modern-report { grid-template-columns: minmax(0, 1fr); }

    /* The skin gives .sectionHeading a pointer because reportModernUx.js makes the cards
       collapsible. That script is not loaded here (it needs the sidebar geneReport.js builds),
       so the headings are not clickable and should not claim to be. */
    #page-container .sectionHeading { cursor: default; }

    /* Actions sit at the right hand end of the card heading. */
    .dvHeadingActions { margin-left: auto; display: flex; align-items: center; gap: 8px; }

    /* The gene symbols. "geneList" was the class on each symbol, but it is not defined in any
       stylesheet, so they rendered as unstyled text inside a fixed 100px scroll box. They are
       a wrapping run of chips now, in a box that grows to the content up to a cap. */
    .dvGeneChips {
        display: flex;
        flex-wrap: wrap;
        gap: 4px 6px;
        max-height: 148px;
        overflow-y: auto;
        padding: 2px 0;
    }
    .dvGeneChips .geneList {
        display: inline-block;
        padding: 1px 7px;
        border-radius: 4px;
        background: var(--rgd-accent-soft);
        color: var(--rgd-blue-dark);
        font-size: 11.5px;
        white-space: nowrap;
    }
    .dvCount {
        font-size: 12px;
        font-weight: 400;
        color: var(--rgd-text-muted);
    }
    /* The variant table comes from HTMLTableReportStrategy, which emits a bare
       <table border=0 cellpadding=2 cellspacing=2> plus headerRow/evenRow/oddRow classes.
       reportModern.css already restyles those rows; this only collapses the cell spacing the
       strategy asks for and lets a wide table scroll inside its card. */
    .dvVariantTable { overflow-x: auto; }
    .dvVariantTable table { border-collapse: collapse; width: 100%; }
    .dvVariantTable table td { padding: 4px 9px; }
</style>

<div id="page-container" class="<%=reportSkinClass%>">
    <div id="content-wrap">

        <%-- card order is the order the page had: the gene set, then the variants --%>
        <div class="light-table-border">
            <div class="sectionHeading">
                Genes in Set
                <span class="dvCount"><%= geneList.size() %></span>
                <span class="dvHeadingActions">
                    <a class="rgdChipLink" href="javascript:void(0)"
                       ng-click="rgd.showTools('geneList',<%=species%>,<%=mapKey%>,'<%=1%>','<%=a%>')"
                       title="open these genes in the analysis tools">Analyze Gene Set</a>
                </span>
            </div>

            <div class="dvGeneChips">
                <% Iterator itr = geneList.iterator();
                    while(itr.hasNext()) {
                        String symbol = (String)itr.next();
                %><span class="geneList"><%=symbol%></span><% }%>
            </div>
        </div>

        <div class="light-table-border">
            <div class="sectionHeading">
                Damaging Variants
                <span class="dvCount">
                    <%=sample%><% if( assembly!=null && !assembly.isEmpty() ) { %> &middot; <%=assembly%><% } %>
                </span>
                <span class="dvHeadingActions">
                    <a class="rgdChipLink" href="/rgdweb/report/strain/damagingVariants.html?id=<%=sampleId%>&fmt=csv&map=<%=mapKey%>"
                       title="download these variants as CSV">Download Variants</a>
                </span>
            </div>

            <div class="dvVariantTable"><%=report.format(new HTMLTableReportStrategy())%></div>
        </div>

    </div>
</div>
