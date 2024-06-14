<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.nomenclatureinterface.*" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.dao.impl.NomenclatureDAO" %>

<script type="text/javascript" src="../../js/calendarDateInput.js">
/***********************************************
* Jason's Date Input Calendar- By Jason Moon http://calendar.moonscript.com/dateinput.cfm
* Script featured on and available at http://www.dynamicdrive.com
* Keep this notice intact for use.
***********************************************/
</script>
<%
    String pageTitle = "Nomenclature Search";
    String headContent = "";
    String pageDescription = "";
    
%>
<%@ include file="/common/headerarea.jsp"%>
<%
    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
    NomenclatureManager nomenclatureManager = (NomenclatureManager) request.getAttribute("NomenclatureManager");
%>
<br>
<form action="nomenEdit.html" method="get">
<table border=0>
<tr>
    <td></td><h1>Nomenclature Search</h1></td>
</tr>
<tr><td>&nbsp;</td></tr>
<tr>
    <td width="150">Search by Name/Symbol/RGD ID:</td>
    <td colspan=2><input type="text" value="" name="keyword" size="35"></td>
    <td colspan="3"><input type="submit" name="keywordSearch" value="Run keyword search"/></td>
</tr>
<tr><td>&nbsp;</td></tr>    
<tr>
    <td>Search by Date Range:</td>
    <td>From </td><td><script>DateInput('from', true, 'MM/DD/YYYY', '01/01/2000')</script></td>
    <td>To </td><td><script>DateInput('to', true, 'MM/DD/YYYY', '<%=sdf.format(new Date())%>')</script></td>
    <td colspan="2"><input type="submit" name="dateSearch" value="Run Date Search"/></td>
</tr>
</table>
</form>

<br>
<table>
    <tr>
        <td><b>Totals</b></td>
    </tr>
    <tr>
        <td><a href="nomenEdit.html?keyword=&from=<%=sdf.format(NomenclatureDAO.NOMENDATE_START)%>&to=<%=sdf.format(NomenclatureDAO.NOMENDATE_TODAY)%>&dateSearch=Run+Date+Search">Genes with new nomenclature:</a></td>
        <td><%=nomenclatureManager.countGenesByNomenclatureReviewDate(NomenclatureDAO.NOMENDATE_START, NomenclatureDAO.NOMENDATE_TODAY)%></td>
    </tr>
    <tr>
        <td><a href="nomenEdit.html?keyword=&from=<%=sdf.format(NomenclatureDAO.NOMENDATE_REVIEWABLE)%>&to=<%=sdf.format(NomenclatureDAO.NOMENDATE_REVIEWABLE)%>&dateSearch=Run+Date+Search">Genes with no good ortholog or no change</a>:</td>
        <td><%=nomenclatureManager.countGenesByNomenclatureReviewDate(NomenclatureDAO.NOMENDATE_REVIEWABLE,NomenclatureDAO.NOMENDATE_REVIEWABLE)%></td>
    </tr>
    <tr>
        <td><a href="nomenEdit.html?keyword=&from=<%=sdf.format(NomenclatureDAO.NOMENDATE_UNTOUCHABLE)%>&to=<%=sdf.format(NomenclatureDAO.NOMENDATE_UNTOUCHABLE)%>&dateSearch=Run+Date+Search">Untouchable nomenclature</a>:</td>
        <td><%=nomenclatureManager.countGenesByNomenclatureReviewDate(NomenclatureDAO.NOMENDATE_UNTOUCHABLE,NomenclatureDAO.NOMENDATE_UNTOUCHABLE)%></td>
    </tr>
    <tr>
        <td><a href="nomenEdit.html?keyword=&from=<%=sdf.format(NomenclatureDAO.NOMENDATE_TOMORROW)%>&to=<%=sdf.format(NomenclatureDAO.NOMENDATE_ONEYEAR)%>&dateSearch=Run+Date+Search">Set for review in next year:</a></td>
        <td><%=nomenclatureManager.countGenesByNomenclatureReviewDate(NomenclatureDAO.NOMENDATE_TOMORROW, NomenclatureDAO.NOMENDATE_ONEYEAR)%></td>
    </tr>
</table>
<%@ include file="/common/footerarea.jsp"%>