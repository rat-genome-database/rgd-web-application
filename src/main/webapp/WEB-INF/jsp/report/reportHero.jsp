<%--
    The report hero: the identity of the object this page is about, stated once at the top of
    #content-wrap, with the page-level actions on the right.

    Every report renders the same markup, so the panel is here rather than copied into each
    main.jsp. A page fills in the handful of variables declared with defaults in
    reportHeader.jsp, then includes this file as the first thing inside #content-wrap:

        heroEyebrow        the small label above the title, e.g. "QTL Report"
        heroTitle          the name the reader came here for - symbol, name, citation title
        heroTitleClass     "report-hero-title--long" when the title is a sentence, not a symbol
        heroTitleIsMarkup  true when heroTitle is markup to render, not text to escape (the
                           strain report is detected here instead, off its object key)
        heroSubtitle       optional second line, e.g. the full name behind a symbol
        heroSpeciesKey     > 0 draws the species portrait and a species chip
        heroIcon           font-awesome class for the portrait circle when there is no species
        heroRgdId          > 0 adds the RGD:nnnn chip
        heroChips          extra chips, each "faIcon|text" or "faIcon|text|title" ("|text" for
                           no icon) - the text is escaped here, so pass it raw
        heroShortName      what the sticky bar shows; defaults to heroTitle
        heroAnalyze        ng-click expression for an Analyze action; null for no action
        heroTutorialLink   href for a Tutorial action; null for no action
        heroExtraActions   raw HTML appended to the action row, for a page's own one-off link
        heroWatch          false to drop the Watch Object action

    Static includes share one translation unit, so these are ordinary scriptlet variables - the
    page assigns them, this file reads them, and nothing has to be threaded through the request.
--%>
<%
    // The title is escaped for every report but the ones whose names carry the markup that
    // spells out a substrain or an allele - superscripts and italics - and so have to reach the
    // browser as markup rather than as visible tags.
    //
    // Two ways in, because the two cases know different things. A strain is recognised here from
    // its object key, since every strain report wants this and none of them has to ask. An
    // allele is a gene, so its object key says nothing: only the page holds the Gene whose
    // getType() is "allele", so gene/main.jsp sets heroTitleIsMarkup and this file just honours
    // it. Any other page with a marked-up title can set the same flag.
    //
    // That object key is read off the RGD id, so a report page that has no RGD id of its own has
    // nothing to look up: the expression study, gene family and rsId reports are keyed by an
    // accession and leave heroRgdId at its default 0, and getRgdId2(0) came back null here, so
    // every one of the three died on objectRgdId.getObjectKey(). An id that does not resolve is
    // treated the same way.
    //
    // This runs before the hero element rather than next to the <h1> it feeds, because the
    // sticky bar's symbol is an attribute on that element and needs the same treatment.
    boolean heroTitleIsStrain = false;
    if( heroRgdId > 0 ) {
        try {
            RgdId heroObjectRgdId = new RGDManagementDAO().getRgdId2(heroRgdId);
            heroTitleIsStrain = heroObjectRgdId != null
                    && heroObjectRgdId.getObjectKey() == RgdId.OBJECT_KEY_STRAINS;
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    // Everything that is not already known to be markup goes out sanitized rather than flatly
    // escaped: escape it, then bring back just the handful of formatting tags RGD nomenclature
    // is written with. A symbol like P3h3<sup>Tn(sb-T2/Bart3)2.310Mcwi</sup> then renders as a
    // superscript even when nothing told this file that the page is about an allele, while
    // anything else the title happens to contain - a stray <script>, an attribute, a tag outside
    // this list - stays escaped and inert.
    //
    // This is what the two booleans above used to be the only route to, and it is why the two of
    // them are now a fast path rather than the thing correctness depends on: a report that
    // forgets to set heroTitleIsMarkup, or a page whose JSP has not recompiled since the flag was
    // added, still renders its symbol. Case-insensitively, because the curated markup is not
    // consistently lower case - 169 strain symbols spell it <I> or <SUP>.
    final String heroFormatTags = "(?i)&lt;(/?)(sup|sub|i|em|b|strong)&gt;";

    String heroTitleHtml;
    // What the sticky bar shows: the short name when the page set one, because a title that is a
    // sentence does not fit a one-line bar. Same markup treatment as the title - most strain
    // symbols carry <i> or <sup>, and the bar printed those as literal tags when it was handed
    // text instead of markup.
    String heroSymbolSource = heroShortName.isEmpty() ? heroTitle : heroShortName;
    // and the same symbol with the formatting taken out rather than escaped, for the plain-text
    // attribute: a reader of that one wants a label, so "<i>D8Mit5</i>" is worse than "D8Mit5"
    String heroSymbolText = heroSymbolSource.replaceAll("(?i)</?(sup|sub|i|em|b|strong)>", "");
    String heroSymbolHtml;
    if( heroTitleIsStrain || heroTitleIsMarkup ) {
        heroTitleHtml = heroTitle;
        heroSymbolHtml = heroSymbolSource;
    } else {
        heroTitleHtml = org.apache.commons.text.StringEscapeUtils.escapeHtml4(heroTitle)
                .replaceAll(heroFormatTags, "<$1$2>");
        heroSymbolHtml = org.apache.commons.text.StringEscapeUtils.escapeHtml4(heroSymbolSource)
                .replaceAll(heroFormatTags, "<$1$2>");
    }
%>
<%-- Both symbol attributes feed the sticky bar in reportModernUx.js: data-symbol-html is the
     markup to render, data-symbol the same thing as plain text for anything that wants a label
     rather than a fragment. --%>
<div class="report-hero"
     data-symbol="<%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(heroSymbolText)%>"
     data-symbol-html="<%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(heroSymbolHtml)%>">
    <div class="report-hero-main">
        <% if( heroSpeciesKey > 0 ) { %>
        <div class="report-hero-species">
            <img alt="<%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(SpeciesType.getCommonName(heroSpeciesKey))%>"
                 src="/rgdweb/common/images/species/<%=SpeciesType.getImageUrl(heroSpeciesKey)%>"/>
        </div>
        <% } else if( heroIcon != null && !heroIcon.isEmpty() ) { %>
        <div class="report-hero-species report-hero-species--icon">
            <i class="fa <%=heroIcon%>"></i>
        </div>
        <% } %>

        <div class="report-hero-text">
            <div class="report-hero-eyebrow"><%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(heroEyebrow)%></div>
            <h1 class="report-hero-title <%=heroTitleClass%>"><%=heroTitleHtml%></h1>
            <% if( heroSubtitle != null && !heroSubtitle.isEmpty() ) { %>
            <div class="report-hero-subtitle"><%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(heroSubtitle)%></div>
            <% } %>

            <div class="report-hero-chips">
                <% if( heroSpeciesKey > 0 ) { %>
                <span class="rgd-chip"><i class="fa fa-paw"></i><%=SpeciesType.getTaxonomicName(heroSpeciesKey)%></span>
                <% } %>
                <% if( heroRgdId > 0 ) { %>
                <span class="rgd-chip rgd-chip-neutral">RGD:<%=heroRgdId%></span>
                <% } %>
                <%
                    for( String heroChip: heroChips ) {
                        if( heroChip==null || heroChip.isEmpty() ) continue;
                        // "faIcon|text" or "faIcon|text|title"; the icon and the title may be empty
                        String[] heroChipParts = heroChip.split("\\|", 3);
                        String heroChipIcon  = heroChipParts.length>1 ? heroChipParts[0] : "";
                        String heroChipText  = heroChipParts.length>1 ? heroChipParts[1] : heroChipParts[0];
                        String heroChipTitle = heroChipParts.length>2 ? heroChipParts[2] : "";
                        if( heroChipText.isEmpty() ) continue;
                %>
                <span class="rgd-chip rgd-chip-neutral"<%=heroChipTitle.isEmpty() ? "" : " title=\"" + org.apache.commons.text.StringEscapeUtils.escapeHtml4(heroChipTitle) + "\""%>>
                    <% if( !heroChipIcon.isEmpty() ) { %><i class="fa <%=heroChipIcon%>"></i><% } %><%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(heroChipText)%>
                </span>
                <% } %>
            </div>
        </div>
    </div>

    <div class="report-hero-actions">
        <% if( heroWatch ) { %>
        <a href="javascript:void(0)" class="rgd-action" ng-click="rgd.addWatch(pageObject)">
            <img src="/rgdweb/common/images/binoculars.png" alt=""/>{{ watchLinkText }}
        </a>
        <% } %>
        <% if( heroAnalyze != null && !heroAnalyze.isEmpty() ) { %>
        <a href="javascript:void(0)" class="rgd-action rgd-action-primary" ng-click="<%=heroAnalyze%>">
            <i class="fa fa-cogs"></i>Analyze
        </a>
        <% } %>
        <%=heroExtraActions%>
        <% if( heroTutorialLink != null && !heroTutorialLink.isEmpty() && !RgdContext.isChinchilla(request) ) { %>
        <a class="rgd-action" href="<%=heroTutorialLink%>">
            <i class="fa fa-play-circle"></i>Tutorial
        </a>
        <% } %>
    </div>
</div>
