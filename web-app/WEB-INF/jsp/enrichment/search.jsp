<%@ page import="edu.mcw.rgd.dao.impl.XdbIdDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Xdb" %>
<%@ page import="java.util.*" %>

<html>
<body>

<link href="/rgdweb/js/jsor-jcarousel-7bb2e0a/style.css" rel="stylesheet" type="text/css"/>

<%@ include file="../ga/gaHeader.jsp" %>
<%--@ include file="rgdHeader.jsp" --%>



<script>
    function toggle(name) {
        checkboxes = document.getElementsByName(name);

        var checked = "checked";
        if (checkboxes[0].checked) {
            checked=false;
        }

        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = checked;
        }
    }

    function viewReport(rgdId) {
        document.report.rgdId.value = rgdId;
        document.report.submit();

    }
</script>

<form action="/rgdweb/ga/analysis.html" name="report" method="<%=method%>">

    <table border=0 width="100%" style="margin-top:8px;">
        <tr><td style='background-color:#e6e6e6;padding:7px;' colspan="2"><b>Step Two: &nbsp;&nbsp;<span style="color:#205080;"></span></b>Select annotations to include in report<br></td></tr>
        <tr><td>&nbsp;</td></tr>
    </table>
    <table >
        <tr>
            <td valign="top">
                <input type="hidden" name="species" value="<%=req.getParameter("species")%>"/>
                <input type="hidden" name="rgdId" value=""/>
                <input type="hidden" name="idType" value="<%=req.getParameter("idType")%>"/>

                <table border="0" cellspacing=4 cellpadding=0 class="gaTable">
                    <tr>
                        <td class="gaLabel" colspan=2>Ontology Annotations &nbsp;&nbsp;<a href="javascript:void(0);" style="color:#4088b8;" onclick="toggle('o')">(toggle)</a></td>

               <%
                for( java.util.Map.Entry<String,String> aspect: aspects.entrySet() ) {
                %>
                    <tr>
                        <td><input type="checkbox" name="o" value="<%=aspect.getKey()%>" <% if (req.isInParameterValues("o",aspect.getKey())) out.print("checked"); %>>
                        </td>
                        <td><%=aspect.getValue()%>
                        </td>
                    </tr>

                    <% } %>
                </table>

            </td>
            <td>&nbsp;</td>
            <td valign="top">
            </td>
            <td>&nbsp;</td>
            <td valign="top" align="center">


                <br><br><br>
                <input type="submit" value="Submit"/>

            </td>
        </tr>


    </table>
    <input type="submit" value="Submit"/>
    <input type="hidden" name="genes" value="<%=req.getParameter("genes")%>"/>
    <input type="hidden" name="chr" value="<%=req.getParameter("chr")%>"/>
    <input type="hidden" name="start" value="<%=req.getParameter("start")%>"/>
    <input type="hidden" name="stop" value="<%=req.getParameter("stop")%>"/>
    <input type="hidden" name="mapKey" value="<%=req.getParameter("mapKey")%>"/>


</form>

   <script>
       toggle("o");
   </script>

</body>
</html>
