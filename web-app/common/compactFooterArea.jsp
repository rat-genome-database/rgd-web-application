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
	<p>&copy; <a href="http://www.mcw.edu/bioinformatics.htm">Bioinformatics Program, HMGC</a> at the <a href="http://www.mcw.edu/">Medical
        College of Wisconsin</a></p>

	<p align="center">RGD is funded by grant HL64541 from the National Heart, Lung, and Blood Institute on behalf of the NIH.<br><img src="/common/images/nhlbilogo.gif" alt="NHLBI Logo" title="National Heart Lung and Blood Institute logo">
<br><br>

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



<%@ include file="/common/angularBottomBodyInclude.jsp" %>
</body>
</html>

<% } %>