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

    <div class="footer-logos" style="display:flex; flex-wrap:wrap; justify-content:center; align-items:center; gap:15px; padding:15px 10px;">
        <a href="https://www.nhlbi.nih.gov/"><img src="/rgdweb/common/images/nhlbilogo.gif" alt="NHLBI Logo" title="National Heart Lung and Blood Institute" style="max-height:60px;"/></a>
        <a href="https://www.nih.gov/"><img src="/rgdweb/common/images/nih.png" alt="NIH Logo" title="National Institutes of Health" style="max-height:60px;"/></a>
        <a href="http://alliancegenome.org"><img src="/rgdweb/common/images/alliance_logo.png" alt="Alliance Logo" style="max-height:60px; max-width:133px;"/></a>
        <a href="https://globalbiodata.org/scientific-activities/global-core-biodata-resources"><img src="/rgdweb/common/images/gbc-main.svg" alt="GBC Logo" style="max-height:60px; max-width:133px;"/></a>
    </div>

    <p align="center" style="padding:0 10px;"><a href="/wg/wp-admin/post.php?post=15&action=edit">RGD</a> is funded by grant HL64541 from the National Heart, Lung, and Blood Institute on behalf of the NIH.<br>


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
