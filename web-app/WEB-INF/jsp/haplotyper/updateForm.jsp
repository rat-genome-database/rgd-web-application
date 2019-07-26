<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.dao.impl.SampleDAO" %>

<script>

 /*   function updatePage() {

        var queryString = "?<-%=request.getQueryString()%>";
        queryString = addParam("chr",document.getElementById("chr").value,queryString);
        queryString = addParam("start",document.getElementById("start").value,queryString);
        queryString = addParam("stop",document.getElementById("stop").value,queryString);
        queryString = addParam("geneList","",queryString);
        queryString = addParam("geneStart","",queryString);
        queryString = addParam("geneStop","",queryString);

        location.href = "variants.html" + queryString;

    }*/
</script>
<style>
     .updateForm {
         font-size: 13px;
         font-weight:700;
         color:#2865A3;
         background-color:#EEEEEE;

     }
     .updateForm input{
         font-size:13px;
         margin-right:10px;
     }
     .updateForm td{
         font-size:13px;
         font-weight:700;
         color:#2865A3;
     }
</style>
<%
    int regionSize = (int)(vsb.getStopPosition() - vsb.getStartPosition() +1);
%>
<form action="dist.html">
<%
    String chr = vsb.getChromosome();
    if (chr == null) {
        chr = "";
    }

    String start = "";
    String stop = "";

    if (vsb.getStartPosition() > -1) {
        start =  FormUtility.formatThousands(vsb.getStartPosition());
    }

    if (vsb.getStopPosition() > -1) {
        stop =  FormUtility.formatThousands(vsb.getStopPosition());
    }
%>

    <%
        for (int i=1; i<100; i++) {
            if (request.getParameter("sample" + i) != null) {

    %>

    <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
    <%
                }
            }

    %>
<table width="100%" class="updateForm" >
    <tr>
        <td>
            <table border=0 align="center" >
            <tr>
                <td align="center">Chromosome</td>
                <td><input type="text" name="chr" size=2 id="chr" value="<%=chr%>"/></td>
                <td align="center">Start Position</td>
                <td><input type="text" name="start" id="start" size="15" value="<%=start%>"/></td>
                <td align="center">Stop Position</td>
                <td><input type="text" name="stop" id="stop"  size="15" value="<%=stop%>"/></td>
                <td><input type="hidden" name="mapKey" id="mapKey"  size="15" value="<%=req.getParameter("mapKey")%>"/></td>
                <td><input type="submit" value="Update"/></td>
            </tr>
            </table>
        </td>
        <td >
            <% if (regionSize > 0) { %>
            <table border=0 align="center">
            <tr>
                <td style="font-weight:700;  color:#2865A3;" align="center">Region Size:</td>
                <td align="center" ><%=FormUtility.formatThousands(regionSize)%> (bp)</td>
                <td>&nbsp;</td>
                <td style="font-weight:700;  color:#2865A3;" align="center">Positions:</td>
                <td align="center" ><%=positionCount%></td>
            </tr>
            </table>
            <% } %>
        </td>
    </tr>
</table>
</form>

