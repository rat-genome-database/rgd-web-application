
<%
   String pageDescription="hello";
   String pageTitle="hello";
   String headContent="";
%>

<%@ include file="headerarea.jsp" %>

<br>

<span style="font-weight:700; font-size:18px;">Welcome to the Resitory Disease Portal. Select an area to explore...</span>
<br><br>
<table border=0 align="center" cellpadding=4>
    <tr>
        <td>
            <table style="border: 3px ridge black;">
                <tr>
                    <td><a href="content.jsp?key=181"><img src="/rgdweb/portals/images/disease.jpg" width=175 height=175 /></a></td>
                </tr>
                <tr>
                    <td align="center" style="font-weight:700;font-size:18px;">Disease Annotations</td>
                </tr>
            </table>
        </td>
        <td>
            <table style="border: 3px ridge black;">
                <tr>
                    <td><a href="content.jsp?key=182"><img src="/rgdweb/portals/images/phenotype.jpg" width=175  height=175 /></a></td>
                </tr>
                <tr>
                    <td align="center" style="font-weight:700;font-size:18px;">Disease Phenotypes</td>
                </tr>
            </table>
        </td>
        <td>
            <table style="border: 3px ridge black;">
                <tr>
                    <td><img src="/rgdweb/portals/images/biologicalProcess.jpg" width=175  height=175 /></td>
                </tr>
                <tr>
                    <td align="center" style="font-weight:700;font-size:18px;">Biological Processes</td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td colspan=3 align="center">
            <table cellpadding=4>
                <tr>
                    <td>
                        <table style="border: 3px ridge black;">
                            <tr>
                                <td><img src="/rgdweb/portals/images/strainModels.jpg" width=175 height=175 /></td>
                            </tr>
                            <tr>
                                <td align="center" style="font-weight:700;font-size:18px;">Strain Models</td>
                            </tr>
                        </table>
                    </td>
                    <td>
                        <table style="border: 3px ridge black;">
                            <tr>
                                <td><img src="/rgdweb/portals/images/pathway.jpg" width=175 height=175 /></td>
                            </tr>
                            <tr>
                                <td align="center" style="font-weight:700;font-size:18px;">Disease Pathways</td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>

        </td>
    </tr>
</table>


<%@ include file="footerarea.jsp" %>
