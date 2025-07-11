<% if (edu.mcw.rgd.web.RgdContext.getHostname().equals("localhost") || edu.mcw.rgd.web.RgdContext.getHostname().equals("pipelines.rgd.mcw.edu") || edu.mcw.rgd.web.RgdContext.getHostname().equals("dev.rgd.mcw.edu") ) { %>

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
