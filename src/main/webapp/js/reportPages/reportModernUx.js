/* ==========================================================================
   RGD report pages - modern UX layer
   --------------------------------------------------------------------------
   Progressive enhancement for report pages whose #page-container carries the
   .rgd-modern-report class. Adds:

     - collapsible major sections (.subTitle) and data cards (.light-table-border)
     - collapse state remembered per report type in localStorage
     - a filter box + "collapse all" control on the sidebar table of contents
     - scroll-spy highlighting of the current section in the sidebar
     - a sticky context bar and a back-to-top button

   Nothing here is required for the report to work: if it throws, the page is
   still fully readable. It must load AFTER geneReport.js, which is what builds
   the sidebar entries and rewrites the annotation tables.
   ========================================================================== */

(function () {
    "use strict";

    var root = document.getElementById("page-container");
    if (!root || !root.classList.contains("rgd-modern-report")) {
        return;
    }

    var STORAGE_KEY = "rgd.report.collapsed." +
        (typeof reportTitle === "string" ? reportTitle : "report");
    var STICKY_OFFSET = 64;

    /* ---------------------------------------------------------------- state */

    var collapsed = readCollapsed();

    function readCollapsed() {
        try {
            var raw = window.localStorage.getItem(STORAGE_KEY);
            return raw ? JSON.parse(raw) : {};
        } catch (e) {
            return {};
        }
    }

    function saveCollapsed() {
        try {
            window.localStorage.setItem(STORAGE_KEY, JSON.stringify(collapsed));
        } catch (e) {
            /* private browsing / quota - collapsing still works for this visit */
        }
    }

    /* --------------------------------------------------------------- helpers */

    function makeCaret() {
        var caret = document.createElement("span");
        caret.className = "rgd-caret";
        caret.setAttribute("aria-hidden", "true");
        return caret;
    }

    // headings carry links (e.g. "Annotation Detail View"); those must still work
    function isInteractive(target) {
        return !!(target.closest && target.closest("a, button, input, select"));
    }

    function keyFor(el, fallback) {
        return el.id || fallback;
    }

    /* -------------------------------------------------- major sections group */
    /* The report body is a flat list of siblings: a .subTitle followed by the
       cards that belong to it, then the next .subTitle. Rather than re-parent
       (which would break the pager/search lookups in geneReport.js), each
       sibling is tagged so it can be hidden with its heading. */

    function buildSections() {
        var sections = [];
        var titles = root.querySelectorAll("#content-wrap .subTitle");

        Array.prototype.forEach.call(titles, function (title, index) {
            var key = keyFor(title, "section" + index);
            var members = [];
            var node = title.nextElementSibling;

            while (node && !node.classList.contains("subTitle")) {
                node.classList.add("rgd-section-member");
                node.setAttribute("data-rgd-section", key);
                members.push(node);
                node = node.nextElementSibling;
            }

            if (!members.length) {
                return;
            }

            title.classList.add("rgd-collapsible");
            title.setAttribute("role", "button");
            title.setAttribute("tabindex", "0");
            title.appendChild(makeCaret());

            // the annotation section ships both a summary and a detail view; only
            // one of them is on screen, so hidden branches must not be counted
            var cards = Array.prototype.filter.call(
                title.parentNode.querySelectorAll(
                    '[data-rgd-section="' + key + '"] .light-table-border, ' +
                    '[data-rgd-section="' + key + '"].light-table-border'),
                function (card) { return card.offsetParent !== null; });
            if (cards.length > 1) {
                var badge = document.createElement("span");
                badge.className = "rgd-section-count";
                badge.textContent = cards.length + " tables";
                title.appendChild(badge);
            }

            var section = { key: key, title: title, members: members };
            sections.push(section);

            setSection(section, collapsed[key] === true, false);

            title.addEventListener("click", function (event) {
                if (isInteractive(event.target)) {
                    return;
                }
                setSection(section, !isCollapsed(title), true);
            });
            title.addEventListener("keydown", function (event) {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    setSection(section, !isCollapsed(title), true);
                }
            });
        });

        return sections;
    }

    function isCollapsed(el) {
        return el.classList.contains("rgd-collapsed");
    }

    function setSection(section, collapse, persist) {
        section.title.classList.toggle("rgd-collapsed", collapse);
        section.title.setAttribute("aria-expanded", collapse ? "false" : "true");
        section.members.forEach(function (member) {
            member.classList.toggle("rgd-hidden", collapse);
        });
        if (persist) {
            collapsed[section.key] = collapse;
            saveCollapsed();
        }
    }

    /* ------------------------------------------------------------ data cards */

    function buildCards() {
        var cards = [];
        var nodes = root.querySelectorAll("#content-wrap .light-table-border");

        Array.prototype.forEach.call(nodes, function (card, index) {
            // only a heading that is a direct child can be kept visible while the
            // rest of the card is hidden, so anything else stays non-collapsible
            var heading = card.querySelector(":scope > .sectionHeading");
            if (!heading) {
                return;
            }

            var key = keyFor(card, keyFor(heading, "card" + index));
            heading.setAttribute("role", "button");
            heading.setAttribute("tabindex", "0");
            heading.appendChild(makeCaret());

            var entry = { key: key, card: card, heading: heading };
            cards.push(entry);

            setCard(entry, collapsed[key] === true, false);

            heading.addEventListener("click", function (event) {
                if (isInteractive(event.target)) {
                    return;
                }
                setCard(entry, !isCollapsed(card), true);
            });
            heading.addEventListener("keydown", function (event) {
                if (event.key === "Enter" || event.key === " ") {
                    event.preventDefault();
                    setCard(entry, !isCollapsed(card), true);
                }
            });
        });

        return cards;
    }

    function setCard(entry, collapse, persist) {
        entry.card.classList.toggle("rgd-collapsed", collapse);
        entry.heading.classList.toggle("rgd-collapsed", collapse);
        entry.heading.setAttribute("aria-expanded", collapse ? "false" : "true");
        if (persist) {
            collapsed[entry.key] = collapse;
            saveCollapsed();
        }
    }

    var sections = buildSections();
    var cards = buildCards();

    /* --------------------------------------------------------- value chips */
    /* Summary rows whose value is nothing but a run of links (related genes,
       alleles, genetic models, gene families, candidate QTLs...) render as one
       long smear of blue text held together by semicolons. Drop the separators
       and give every value its own chip so the individual entries read as
       distinct things. Cells that mix links with prose are left alone. */

    var SEPARATOR_ONLY = /^[\s;, |]*$/;

    function chipCell(cell) {
        var links = cell.querySelectorAll("a");
        if (links.length < 2 || cell.querySelector("table, div, ul, ol, img, br, b")) {
            return;
        }
        var nodes = Array.prototype.slice.call(cell.childNodes);
        var listOnly = nodes.every(function (node) {
            if (node.nodeType === 3) {
                return SEPARATOR_ONLY.test(node.nodeValue);
            }
            return node.nodeType === 1 && node.tagName === "A";
        });
        if (!listOnly) {
            return;
        }
        nodes.forEach(function (node) {
            if (node.nodeType === 3) {
                cell.removeChild(node);
            }
        });
        Array.prototype.forEach.call(links, function (link) {
            link.classList.add("rgd-value-chip");
        });
        cell.classList.add("rgd-value-list");
    }

    function buildValueChips() {
        Array.prototype.forEach.call(
            root.querySelectorAll("#info-table td:not(.label)"), chipCell);
    }

    buildValueChips();

    /* --------------------------------------------------------- expand / all */

    function setAll(collapse) {
        sections.forEach(function (section) { setSection(section, collapse, true); });
        cards.forEach(function (card) { setCard(card, collapse, true); });
        updateToggleAllLabel();
    }

    function everythingCollapsed() {
        var all = sections.concat(cards);
        return all.length > 0 && all.every(function (item) {
            return isCollapsed(item.title || item.card);
        });
    }

    /* Reveal a target that is inside a collapsed section or card, so sidebar
       links and #hash navigation never land on hidden content. */
    function revealTarget(target) {
        if (!target) {
            return;
        }
        cards.forEach(function (entry) {
            if (entry.card === target || entry.card.contains(target)) {
                setCard(entry, false, true);
            }
        });
        sections.forEach(function (section) {
            if (section.title === target) {
                setSection(section, false, true);
                return;
            }
            var inside = section.members.some(function (member) {
                return member === target || member.contains(target);
            });
            if (inside) {
                setSection(section, false, true);
            }
        });
    }

    function revealHash() {
        var hash = window.location.hash;
        if (hash && hash.length > 1) {
            try {
                revealTarget(document.getElementById(decodeURIComponent(hash.slice(1))));
            } catch (e) {
                /* malformed hash - ignore */
            }
        }
    }

    window.addEventListener("hashchange", revealHash);
    revealHash();

    /* ------------------------------------------------------- sidebar toolbar */

    var sidebar = document.getElementById("reportMainSidebar");
    var navList = document.getElementById("navbarUlId");
    var toggleAllBtn = null;
    var filterInput = null;

    function buildSidebarToolbar() {
        if (!sidebar || !navList) {
            return;
        }

        var head = document.createElement("div");
        head.className = "rgd-toc-head";

        var label = document.createElement("span");
        label.textContent = "On this page";
        head.appendChild(label);

        toggleAllBtn = document.createElement("button");
        toggleAllBtn.type = "button";
        toggleAllBtn.className = "rgd-toc-toggle-all";
        toggleAllBtn.addEventListener("click", function () {
            setAll(!everythingCollapsed());
        });
        head.appendChild(toggleAllBtn);

        filterInput = document.createElement("input");
        filterInput.type = "search";
        filterInput.className = "rgd-toc-filter";
        filterInput.placeholder = "Filter sections...";
        filterInput.setAttribute("aria-label", "Filter report sections");
        filterInput.addEventListener("input", applyFilter);

        sidebar.insertBefore(head, sidebar.firstChild);
        head.parentNode.insertBefore(filterInput, head.nextSibling);

        updateToggleAllLabel();
    }

    function updateToggleAllLabel() {
        if (toggleAllBtn) {
            toggleAllBtn.textContent = everythingCollapsed() ? "Expand all" : "Collapse all";
        }
    }

    function applyFilter() {
        if (!filterInput || !navList) {
            return;
        }
        var needle = filterInput.value.trim().toLowerCase();
        // while a filter is on, a hit inside a collapsed group still has to be reachable,
        // so the accordion stands down until the box is cleared
        navList.classList.toggle("rgd-toc-filtering", needle !== "");
        Array.prototype.forEach.call(navList.children, function (li) {
            var text = (li.textContent || "").toLowerCase();
            li.classList.toggle("rgd-toc-hidden", needle !== "" && text.indexOf(needle) === -1);
        });
    }

    /* -------------------------------------------------- sidebar accordion */
    /* geneReport.js builds the table of contents flat: one li per .subTitle
       (Annotation, Genomics, Expression, Sequence, Additional Information),
       then one li.sub-nav-item per section underneath it. The hierarchy is
       already in the classes, so grouping is only a matter of tagging each run
       of sub items with the heading above it - no re-parenting, which would
       break the filter and scroll-spy loops that walk navList.children.

       A group's state lives in the same map as the section/card state, under a
       "toc:" prefix so it cannot collide with an element id. */

    function tocGroupKey(head, index) {
        return "toc:" + (head.id || (head.textContent || "").trim() || index);
    }

    function setTocGroup(group, collapse) {
        group.head.classList.toggle("is-collapsed", collapse);
        group.items.forEach(function (li) {
            li.classList.toggle("rgd-toc-collapsed", collapse);
        });
        if (group.caret) {
            group.caret.setAttribute("aria-expanded", collapse ? "false" : "true");
        }
        collapsed[group.key] = collapse;
        saveCollapsed();
    }

    function buildSidebarAccordion() {
        if (!navList) {
            return;
        }

        var groups = [];
        var current = null;

        Array.prototype.forEach.call(navList.children, function (li) {
            li.classList.remove("rgd-toc-group", "rgd-toc-collapsed", "is-collapsed");
            if (li.classList.contains("sub-nav-item")) {
                if (current) {
                    current.items.push(li);
                }
                return;
            }
            current = { head: li, items: [], caret: null };
            groups.push(current);
        });

        groups.forEach(function (group, index) {
            // "Summary", and any major section whose cards all turned out empty,
            // has nothing to fold away - it stays an ordinary link
            if (group.items.length === 0) {
                return;
            }

            group.key = tocGroupKey(group.head, index);
            group.head.classList.add("rgd-toc-group");

            var caret = document.createElement("button");
            caret.type = "button";
            caret.className = "rgd-toc-caret";
            caret.setAttribute("aria-label",
                "Show or hide sections under " + (group.head.textContent || "").trim());
            caret.addEventListener("click", function (event) {
                // the heading is also a link to its section; the caret only folds
                event.preventDefault();
                event.stopPropagation();
                setTocGroup(group, !group.head.classList.contains("is-collapsed"));
            });
            group.head.appendChild(caret);
            group.caret = caret;

            setTocGroup(group, collapsed[group.key] === true);
        });
    }

    buildSidebarToolbar();
    buildSidebarAccordion();

    /* sidebar links must open whatever they point at */
    if (navList) {
        navList.addEventListener("click", function (event) {
            var link = event.target.closest ? event.target.closest("a") : null;
            if (!link) {
                return;
            }
            var href = link.getAttribute("href") || "";
            if (href.charAt(0) !== "#" || href.length < 2) {
                return;
            }
            var target = document.getElementById(href.slice(1));
            if (target) {
                revealTarget(target);
                updateToggleAllLabel();
            }
        });

        // geneReport.js rebuilds the list when the annotation view is toggled
        if (window.MutationObserver) {
            new MutationObserver(function () {
                buildSidebarAccordion();
                applyFilter();
                collectSpyTargets();
                updateSpy();
            }).observe(navList, { childList: true });
        }
    }

    /* ------------------------------------------------------------ sticky bar */

    var stickyBar = null;
    var stickySection = null;
    var toTopBtn = null;

    function buildChrome() {
        var hero = root.querySelector(".report-hero");
        var symbol = hero ? hero.getAttribute("data-symbol") : "";

        stickyBar = document.createElement("div");
        stickyBar.className = "rgd-stickybar";
        if (root.classList.contains("chinchilla")) {
            stickyBar.classList.add("chinchilla");
        }

        var symbolEl = document.createElement("span");
        symbolEl.className = "rgd-stickybar-symbol";
        symbolEl.textContent = symbol || "";
        stickyBar.appendChild(symbolEl);

        var sep = document.createElement("span");
        sep.className = "rgd-stickybar-sep";
        sep.textContent = "/";
        stickyBar.appendChild(sep);

        stickySection = document.createElement("span");
        stickySection.className = "rgd-stickybar-section";
        stickyBar.appendChild(stickySection);

        var actions = document.createElement("div");
        actions.className = "rgd-stickybar-actions";

        var collapseBtn = document.createElement("button");
        collapseBtn.type = "button";
        collapseBtn.className = "rgd-stickybar-btn";
        collapseBtn.textContent = "Collapse all";
        collapseBtn.addEventListener("click", function () {
            var next = !everythingCollapsed();
            setAll(next);
            collapseBtn.textContent = next ? "Expand all" : "Collapse all";
            window.scrollTo({ top: 0, behavior: "smooth" });
        });
        actions.appendChild(collapseBtn);
        stickyBar.appendChild(actions);

        document.body.appendChild(stickyBar);

        toTopBtn = document.createElement("button");
        toTopBtn.type = "button";
        toTopBtn.className = "rgd-to-top";
        toTopBtn.title = "Back to top";
        toTopBtn.setAttribute("aria-label", "Back to top");
        toTopBtn.innerHTML = "&#8593;";
        toTopBtn.addEventListener("click", function () {
            window.scrollTo({ top: 0, behavior: "smooth" });
        });
        document.body.appendChild(toTopBtn);
    }

    buildChrome();

    /* ------------------------------------------------------------ scroll spy */

    var spyTargets = [];

    function collectSpyTargets() {
        spyTargets = [];
        var headings = root.querySelectorAll("#content-wrap .subTitle, #content-wrap .sectionHeading");
        Array.prototype.forEach.call(headings, function (heading) {
            if (heading.id) {
                spyTargets.push(heading);
            }
        });
    }

    function currentHeading() {
        var current = null;
        for (var i = 0; i < spyTargets.length; i++) {
            var heading = spyTargets[i];
            if (heading.offsetParent === null) {
                continue; // inside a hidden branch (e.g. the detail view)
            }
            if (heading.getBoundingClientRect().top - STICKY_OFFSET <= 0) {
                current = heading;
            } else {
                break;
            }
        }
        return current;
    }

    var lastHeadingId = null;

    function updateSpy() {
        var heading = currentHeading();
        var id = heading ? heading.id : null;
        if (id === lastHeadingId) {
            return;
        }
        lastHeadingId = id;

        if (stickySection) {
            stickySection.textContent = heading ? headingLabel(heading) : "Summary";
        }
        if (!navList) {
            return;
        }
        // at the top of the page nothing has scrolled past yet - that is "Summary"
        var wanted = id !== null ? "#" + id : "#top";
        var links = navList.querySelectorAll("a");
        Array.prototype.forEach.call(links, function (link) {
            var isCurrent = (link.getAttribute("href") || "") === wanted;
            link.classList.toggle("rgd-toc-current", isCurrent);
            // keep Bootstrap's scrollspy class in sync so only one entry lights up
            link.classList.toggle("active", isCurrent);
        });
    }

    function headingLabel(heading) {
        var first = heading.childNodes[0];
        var text = first && first.textContent ? first.textContent.trim() : "";
        return text || (heading.textContent || "").trim();
    }

    collectSpyTargets();

    var ticking = false;

    function onScroll() {
        if (ticking) {
            return;
        }
        ticking = true;
        window.requestAnimationFrame(function () {
            ticking = false;
            var y = window.pageYOffset || document.documentElement.scrollTop;
            if (stickyBar) {
                stickyBar.classList.toggle("is-visible", y > 260);
            }
            if (toTopBtn) {
                toTopBtn.classList.toggle("is-visible", y > 700);
            }
            updateSpy();
        });
    }

    window.addEventListener("scroll", onScroll, { passive: true });
    window.addEventListener("resize", function () {
        lastHeadingId = null;
        onScroll();
    });
    onScroll();
}());
