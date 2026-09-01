<%--
    The report hero: the identity of the object this page is about, stated once at the top of
    #content-wrap, with the page-level actions on the right.

    Every report renders the same markup, so the panel is here rather than copied into each
    main.jsp. A page fills in the handful of variables declared with defaults in
    reportHeader.jsp, then includes this file as the first thing inside #content-wrap:

        heroEyebrow        the small label above the title, e.g. "QTL Report"
        heroTitle          the name the reader came here for - symbol, name, citation title
        heroTitleClass     "report-hero-title--long" when the title is a sentence, not a symbol
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
<%-- data-symbol feeds the sticky bar in reportModernUx.js; a report whose title is a
     sentence sets heroShortName so the bar gets something that fits --%>
<div class="report-hero" data-symbol="<%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(heroShortName.isEmpty() ? heroTitle : heroShortName)%>">
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
            <h1 class="report-hero-title <%=heroTitleClass%>"><%=org.apache.commons.text.StringEscapeUtils.escapeHtml4(heroTitle)%></h1>
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
