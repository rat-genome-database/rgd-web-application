<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-2739107-4', 'auto');
  ga('send', 'pageview');

</script>
<link rel="stylesheet" href="/rgdweb/css/webFeedback.css" type="text/css"/>
<script src="https://cdn.jsdelivr.net/npm/vue@2.6.12/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="/rgdweb/js/webFeedback.js"></script>

<% if( !RgdContext.isChinchilla(request) ) { %>
<table border=0 cellpadding=0 cellspacing=0 style="border-bottom: 1px solid #24609C; color:white; font-size:12px; background-image: url('/common/images/gradient.jpg');" border="0" width="100%">
<tbody><tr>
    <td style="color:white;" align="left">
        <a href="/"><img src="/rgdweb/common/images/rgd_LOGO_small.gif" border=0/></a>
    </td>
    <td align="right"><a style="color:white;" href="http://rgd.mcw.edu/wg/home/rgd_rat_community_videos/gene-annotator-tutorial">Play Video Tutorial</a>&nbsp;&nbsp;&nbsp;</td>
    <td width=50><a  href="http://rgd.mcw.edu/wg/home/rgd_rat_community_videos/gene-annotator-tutorial"><img src="/rgdweb/common/images/gaarrow_small.png" border=0/></a></td>
    <td width=150 style="color:white;" align="right">
		<a style="color:white;" href="http://rgd.mcw.edu/wg/citing-rgd">Citing RGD</a>&nbsp;|&nbsp;
				<a style="color:white;" href="/rgdweb/contact/contactus.html">Contact Us</a>&nbsp;&nbsp;&nbsp;
</td></tr></tbody></table>
<%@include file="/common/helpFeedbackChat.jsp"%>
<% } %>
