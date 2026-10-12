<%-- Google Analytics only on the public site, decided by the host the browser used, so dev, newdev, pipelines and
     localhost are not counted and their links don't get analytics parameters (_gl=...). No variables are declared here:
     some pages include this file twice. --%>
<% if (!edu.mcw.rgd.web.RgdContext.isPublicSiteRequest(request)) { %>

<% } else { %>
<script src="https://www.google-analytics.com/urchin.js" type="text/javascript"></script>
<script type="text/javascript">
    _uacct = "UA-2739107-2";
    urchinTracker();
</script>
<!-- Google tag (gtag.js) -->
<script async src="https://www.googletagmanager.com/gtag/js?id=G-BTF869XJFG"></script>
<script>
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());

    gtag('config', 'G-BTF869XJFG');
</script>
<% } %>
