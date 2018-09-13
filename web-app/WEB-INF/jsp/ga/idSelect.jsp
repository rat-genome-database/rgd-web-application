<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%
    HttpRequestFacade req = new HttpRequestFacade(request);
%>
<br><br><br>
<table align="center" style="background-color:rgb(230, 230, 230); padding: 5px;" >

<form action='search.html'>
    <input type="hidden" name="species" value="<%=req.getParameter("species")%>"/>
    <input type="hidden" name="genes" value="<%=req.getParameter("genes")%>"/>
    <input type="hidden" name="chr" value="<%=req.getParameter("chr")%>"/>
    <input type="hidden" name="start" value="<%=req.getParameter("start")%>"/>
    <input type="hidden" name="stop" value="<%=req.getParameter("stop")%>"/>
    <input type="hidden" name="mapKey" value="<%=req.getParameter("mapKey")%>"/>
    <tr>
        <td></td><td></td>
    </tr>
    <tr>
        <td></td><td></td>
    </tr>
    <tr>
        <td colspan=2>Numeric values have been submitted in the gene list.  Please specify the identifier type.</td>
    </tr>
    <tr>
        <td></td><td></td>
    </tr>

    <tr>
        <td width='5%'><input type="radio" name="idType" value="rgd" /></td><td>RGD ID</td>
    </tr>
    <tr>
        <td><input type="radio" name="idType" value="entrez"/></td><td>EntrezGene ID</td>
    </tr>
    <tr>
        <td><input type="radio" name="idType" value="affy"/></td><td>Affymetrix Array ID</td>
    </tr>
    <tr>
        <td><input type="radio" name="idType" value="kegg"/></td><td>Kegg Pathway</td>
    </tr>
    <tr>
        <td></td><td></td>
    </tr>
    <tr>
        <td colspan=2 align="center"><input type="submit" value="Continue"/></td>
    </tr>
</form>


</table>