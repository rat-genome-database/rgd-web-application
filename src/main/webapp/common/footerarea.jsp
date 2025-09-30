</td>
</tr>
</table>

</div>
<br>
<footer id="footer">
    <div class="bottom-bar" >
        <table align=center class="headerTable"> <tr><td align="left" style="color:white;">
            <a href="/rgdweb/contact/contactus.html">Contact Us</a>&nbsp;|&nbsp;
            <a href="/wg/about-us">About Us</a>&nbsp;|&nbsp;
            <a href="https://creativecommons.org/licenses/by/4.0/">License CC BY 4.0</a>&nbsp;|&nbsp;
            <a href="/wg/home/disclaimer">Legal Disclaimer</a>&nbsp;|&nbsp;
            <a href="http://www.mcw.edu/">&copy; Medical College of Wisconsin</a>
        </td></tr></table>
    </div>
    <%--</div>--%>

    <table align="center">
        <tr>
            <td width=100 align="center"><a href="https://www.nhlbi.nih.gov/"><img src="/rgdweb/common/images/nhlbilogo.gif" alt="NHLBI Logo" title="National Heart Lung and Blood Institute"></a><br><br></td>
            <td width=100 align="center"><a href="https://www.nih.gov/"><img src="/rgdweb/common/images/nih.png" alt="NHLBI Logo" title="National Institue of Health"></a><br><br></td>
            <td width=100 align="center"><a href="http://alliancegenome.org"><img src="/rgdweb/common/images/alliance_logo.png" height="80" width="133" border=0/></a></td>
            <td width=100 align="center"><a href="https://globalbiodata.org/scientific-activities/global-core-biodata-resources"><img src="/rgdweb/common/images/gbc-main.svg" height="80" width="133" border=0/></a></td>
        </tr>
    </table>

    <p align="center"><a href="/wg/wp-admin/post.php?post=15&action=edit">RGD</a> is funded by grant HL64541 from the National Heart, Lung, and Blood Institute on behalf of the NIH.<br>


    <div id="copyright">

    </div>
</footer>
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

<!-- Cookie Consent -->
<link rel="stylesheet" href="/rgdweb/css/cookieConsent.css">
<script src="/rgdweb/js/cookieConsent.js"></script>

</body>
</html>
