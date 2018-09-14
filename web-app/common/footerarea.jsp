<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<% if( RgdContext.isChinchilla(request) ) { %>
<%@include file="ngcfooterarea.jsp" %>
<%} else { %>

<!-- end position 1 -->
</div>

<div class="wg-clear"></div>

<!--/layout3f7342bad77460be364638b044032ac2 /layout default-->
</div>
		</div>
		<br>
 		<div class="bottom-bar" >
<table align=center class="headerTable"> <tr><td align="left" style="color:white;">
		<a href="/contact/index.shtml">Contact Us</a>&nbsp;|&nbsp;
		<a href="/wg/about-us">About Us</a>&nbsp;|&nbsp;
		<a href="/wg/jobs">Jobs at RGD</a>

</td></tr></table>
		</div>
	</div>
</div>

<!-- end page wrapper -->
</div>
</td></tr>
</table>

<div id="copyright">
    <p><a href="https://creativecommons.org/licenses/by/4.0/">License CC BY 4.0</a></p>
    <p>&copy; <a href="http://www.mcw.edu/">Medical
        College of Wisconsin</a></p>
    <p><a href="/wg/home/disclaimer">Legal Disclaimer</a></p>
    <p align="center">RGD is funded by grant HL64541 from the National Heart, Lung, and Blood Institute on behalf of the NIH.<br><img src="/common/images/nhlbilogo.gif" alt="NHLBI Logo" title="National Heart Lung and Blood Institute logo"><br><br>

</div>

<script language="javascript" src="/common/js/killerZebraStripes.js" type="text/javascript"></script>
<script>
var arr = document.getElementsByTagName("table");
for (i=0; i< arr.length; i++) {
	if (arr[i].className == "striped-table") {
		if (!arr[i].id) {
			arr[i].id = "striped-table-" + i;
		}
		stripeTables(arr[i].id);
      }
}

</script>

<script type="text/javascript">
var uservoiceOptions = {
   /* required */
   key: 'rgd',
   host: 'rgd.uservoice.com',
   forum: '33675',
   showTab: true,
   /* optional */
   alignment: 'left',
   background_color:'#f00',
   text_color: 'white',
   hover_color: '#06C',
   lang: 'en'
};

function _loadUserVoice() {
   var s = document.createElement('script');
   s.setAttribute('type', 'text/javascript');
   s.setAttribute('src', ("https:" == document.location.protocol ? "https://" : "http://") + "cdn.uservoice.com/javascripts/widgets/tab.js");
   document.getElementsByTagName('head')[0].appendChild(s);
}
_loadSuper = window.onload;
window.onload = (typeof window.onload != 'function') ? _loadUserVoice : function() { _loadSuper(); _loadUserVoice(); };
</script>

<%@ include file="/common/angularBottomBodyInclude.jsp" %>
</body>
</html>

<% } %>