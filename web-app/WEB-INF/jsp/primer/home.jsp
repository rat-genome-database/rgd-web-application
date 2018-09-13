<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="java.sql.Connection" %>

<%
    String pageTitle = "Rat Genome Database Primer Create";
    String headContent = "";
    String pageDescription = "Rat Genome Database Primer Create";
    List<String> pwList = new ArrayList<String>();

    Map<String, String> spMap = (Map)request.getAttribute("spMap");

%>
<%@ include file="/common/headerarea.jsp"%>
<%
    HttpRequestFacade req= new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req, error);

    /*DataSource ds= DataSourceFactory.getInstance().getEnsemblDataSource();
    Connection conn = ds.getConnection();
    System.out.println("conn open:"+ conn);
    conn.close();
    */
%>




<h1>Primer Designer</h1>



<form  action="primerCreate.html" method="GET">



<table align="left" border=0 style="border: 1px solid #2865A3; padding: 5px; background-color:#F0F2F1;">
    <tr>
        <td style="font-weight:700;">Species:</td>
        <td>
            <select id="Species" name="Species" class="source" onchange="updateSelectTarget()">
                <option value="1" >Human</option>
            </select>
        </td>
    </tr>
    <tr>
        <td>Assembly:</td>
        <td>
            <select id="assembly" name="assembly" >
              <option value="17">GRCh37</option>
            </select>

        </td>
    </tr>
     <tr><td >Gene&nbsp;Target:</td>
        <td colspan="3"><input type="text" id="gene_ens_id1" name="gene_ens_id" size="40" value="<%=dm.out("gene_ens_id", "")%>"></td>
     </tr>

     <tr>
         <td >Variant Position:</td>
         <td>
             <table>
                <tr>
                    <td>Chr:</td>
                   <td><input type="text" id="chr1" name="chr" size="3" value="<%=dm.out("chr", "")%>"></td>
                    <td>Location:</td>
                   <td><input type="text" id="start1" name="start" size="10" value="<%=dm.out("start", "")%>"></td>
                    <%--<td>Stop:</td>
                   <td><input type="text" id="stop1" name="stop" size="10" value="<%=dm.out("stop", "")%>"></td>--%>

                </tr>
             </table>
         </td>
     </tr>
    <tr>
        <td>&nbsp;</td>
    </tr>
     <tr>
        <td colspan="3" align="right"><input type="submit"  value="Create Primer Pairs" > </td>
     </tr>

</table>


<br><br><br><br><br><br><br>    <br><br><br><br>

<table border=0 style="border: 1px solid #2865A3; padding: 5px; background-color:#F0F2F1;">
    <tr>
        <td colspan=2 style="font-weight:700;">Primer 3 Options</td>
    </tr>
    <tr>
        <td>PRIMER_MIN_SIZE</td><td><input type="text" name="PRIMER_MIN_SIZE" value="18" size=10/></td>
        <td>&nbsp;</td>
        <td>PRIMER_OPT_SIZE</td><td><input type="text" name="PRIMER_OPT_SIZE" value="20" size=10/></td>
        <td>&nbsp;</td>
        <td>PRIMER_MAX_SIZE</td><td><input type="text" name="PRIMER_MAX_SIZE" value="25" size=10/></td>
    </tr>
    <tr>
        <td>PRIMER_MIN_TM</td><td><input type="text" name="PRIMER_MIN_TM" value="55.0" size=10/></td>
        <td>&nbsp;</td>
        <td>PRIMER_OPT_TM</td><td><input type="text" name="PRIMER_OPT_TM" value="60.0" size=10/></td>
        <td>&nbsp;</td>
        <td>PRIMER_MAX_TM</td><td><input type="text" name="PRIMER_MAX_TM" value="65.0" size=10/></td>
    </tr>
    <tr>
        <td>PRIMER_PRODUCT_SIZE_RANGE</td><td><input type="text" name="PRIMER_PRODUCT_SIZE_RANGE" value="300-600" size=10/></td>
        <td>&nbsp;</td>
        <td>PRIMER_MAX_END_STABILITY</td><td><input type="text" name="PRIMER_MAX_END_STABILITY" value="9.0" size=10/></td>
        <td>&nbsp;</td>
        <td>PRIMER_MAX_SELF_ANY</td><td><input type="text" name="PRIMER_MAX_SELF_ANY" value="8.00" size=10/></td>
    </tr>
    <tr>
        <td>PRIMER_MAX_SELF_END</td><td><input type="text" name="PRIMER_MAX_SELF_END" value="3.00" size=10/></td>
        <td>&nbsp;</td>
        <td>PRIMER_MAX_POLY_X</td><td><input type="text" name="PRIMER_MAX_POLY_X" value="4" size=10/></td>
        <td>&nbsp;</td>
        <td>PRIMER_GC_CLAMP</td><td><input type="text" name="PRIMER_GC_CLAMP" value="1" size=10/></td>
    </tr>
</table>





</form>




<%@ include file="/common/footerarea.jsp"%>
