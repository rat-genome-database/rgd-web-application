/* ==========================================================================
   RGD report pages - links that leave RGD open in a new tab
   --------------------------------------------------------------------------
   Report pages are dense with links out to NCBI, Ensembl, UniProt, AlphaFold,
   PubMed, MGI and a long tail of other resources, and following one used to
   take the reader off the report they were in the middle of reading. Anything
   that points at another site now opens in a new tab; RGD's own links keep
   navigating in place.

   This is a pass over the rendered page rather than a target attribute on each
   anchor because most of those links are never written in the JSPs: they come
   out of the external-database tables, the Link helpers in rgdcore, and the
   tables geneReport.js builds from other tables. One rule here covers all of
   them, plus whatever is injected after load (MutationObserver below).

   An anchor that already names a target keeps the one it asked for.
   ========================================================================== */

(function () {
    "use strict";

    // Everything under rgd.mcw.edu is still us, whichever host is serving this
    // page: dev and test builds carry absolute links to production URLs, and
    // download.* / pipeline.* are ours as well.
    var INTERNAL_HOST = /(^|\.)rgd\.mcw\.edu$/i;

    // Only real navigations. Leaves "#section" jumps, mailto:, tel: and the
    // javascript: links the older annotation tabs still use alone.
    var LEAVES_THE_PAGE = /^(https?|ftp|ftps):$/i;

    function isExternal(link) {
        if (!LEAVES_THE_PAGE.test(link.protocol)) {
            return false;
        }
        var host = link.hostname;
        return !!host && host !== window.location.hostname && !INTERNAL_HOST.test(host);
    }

    function markExternal(link) {
        // an anchor that asked for a particular target - a named JBrowse window,
        // a frame, an explicit _self - is honoured as written
        if (link.getAttribute("target") || !isExternal(link)) {
            return;
        }

        link.setAttribute("target", "_blank");

        // the new tab must not get a handle on this one through window.opener.
        // The referrer is deliberately left intact: the resources we link out to
        // use it to see that the traffic came from RGD.
        var rel = (link.getAttribute("rel") || "").split(/\s+/).filter(Boolean);
        if (rel.indexOf("noopener") === -1) {
            rel.push("noopener");
        }
        link.setAttribute("rel", rel.join(" "));

        // carries no styling today; it is what an "opens elsewhere" marker would
        // hang off, and it makes the pass visible when inspecting a page
        link.classList.add("rgd-external-link");
    }

    function scan(node) {
        if (node.nodeType !== 1) {
            return;
        }
        if (node.tagName === "A" && node.hasAttribute("href")) {
            markExternal(node);
        }
        Array.prototype.forEach.call(node.querySelectorAll("a[href]"), markExternal);
    }

    function start() {
        // #page-container is the modern report shell; the older annotation and
        // protein-domain reports only have the site's own #contentArea. Either
        // way the shared header and footer sit outside it, so site chrome goes
        // on behaving the way it does on every other page.
        var root = document.getElementById("page-container") ||
                   document.getElementById("contentArea");
        if (!root) {
            return;
        }

        scan(root);

        // annotation views, expression data and the association tables all arrive
        // after load, as do the tables geneReport.js rebuilds
        if (window.MutationObserver) {
            new MutationObserver(function (records) {
                records.forEach(function (record) {
                    Array.prototype.forEach.call(record.addedNodes, scan);
                });
            }).observe(root, { childList: true, subtree: true });
        }
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", start);
    } else {
        start();
    }
}());
