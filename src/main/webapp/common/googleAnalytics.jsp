<%
    // Google Analytics only on the public site. The host the browser used decides (behind the proxy, X-Forwarded-Host),
    // so dev, newdev, pipelines and localhost are not counted and their links don't get analytics parameters (_gl=...).
    String gaRequestHost = request.getHeader("X-Forwarded-Host");
    if (gaRequestHost == null || gaRequestHost.isEmpty()) {
        gaRequestHost = request.getServerName();
    }
    gaRequestHost = gaRequestHost.split(",")[0].trim().replaceFirst(":.*$", "");
    boolean gaEnabled = gaRequestHost.equalsIgnoreCase("rgd.mcw.edu") || gaRequestHost.equalsIgnoreCase("www.rgd.mcw.edu");
%>
<% if (!gaEnabled) { %>

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
