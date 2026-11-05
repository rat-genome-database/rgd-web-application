<%@ page buffer="none" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.stats.ScoreBoardManager" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdId" %>
<%
    String pageTitle = "Score Board - General";
    String headContent = "";
    String pageDescription = "";
    
%>
<%@ include file="/common/headerarea.jsp"%>

<%
    FormUtility fu = new FormUtility();

    ScoreBoardManager sbm = new ScoreBoardManager();

    SimpleDateFormat inDateFormat = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat outDateFormat = new SimpleDateFormat("MMM d yyyy");
    SimpleDateFormat restApiDateFormat = new SimpleDateFormat("yyyyMMdd");

    String inDateStr = request.getParameter("date");

    Date inDate = new Date();
    if ( inDateStr!=null && !inDateStr.equals("Today") ) {
        inDate = inDateFormat.parse(inDateStr);
    }else {
        inDateStr = "Today";
    }
    String inDateStrRest = restApiDateFormat.format(inDate);

    String compDateStr = request.getParameter("compare");
    Date compDate = null;
    if ( compDateStr!=null && !compDateStr.equals("None")) {
        compDate = inDateFormat.parse(compDateStr);
    }else {
        compDateStr="None";
    }
    String compDateStrRest = compDate==null ? null : restApiDateFormat.format(compDate);
%>

<h3>SCORE BOARD - GENERAL
 &nbsp; &nbsp;
 <a href="/rgdweb/score/boardAnnot.jsp?date=<%=inDateStr%>&compare=<%=compDateStr%>" title="View Score Board for Annotations">annotations</a>
 &nbsp; &nbsp;
 <a href="/rgdweb/score/boardPortal.jsp?date=<%=inDateStr%>&compare=<%=compDateStr%>" title="View Score Board for Portals">portals</a>
</h3>

<form action="">
<table style="background-color:#d6e7ff;">
    <tr>
<%@ include file="boardSpecies.jsp"%><%-- emits variables 'speciesTypeKey' and 'speciesType' --%>
        <td>&nbsp;</td>
        <td>Date</td>
        <td><select name="date" >
                <option value="Today">Today</option>
               <%  List<String> dates = sbm.getStatArchiveDates();
                   for( String date: dates ) {
               %>
                       <option value="<%=date%>" <%=fu.optionParams(inDateStr, date)%> ><%=outDateFormat.format(inDateFormat.parse(date))%></option>
               <% } %>
            </select>
        </td>
        <td>&nbsp;</td>
        <td>Compare With</td>
        <td><select name="compare" >
                <option value="None">None</option>
               <%
                   for( String date: dates ) {
               %>
                       <option value="<%=date%>" <%=fu.optionParams(compDateStr, date)%>><%=outDateFormat.format(inDateFormat.parse(date))%></option>
               <% } %>
            </select>
            <input type="submit" value="Submit"/>
        </td>
    </tr>
</table>
</form>

Species: <b><%=edu.mcw.rgd.datamodel.SpeciesType.getCommonName(Integer.parseInt(speciesType))%></b> , Date: <b><%=inDateStr%></b> , Compare Date: <b><%=compDateStr%></b>

<%
    String boardRowTitle = "RGD Objects";
    String boardRowId = "idObjStatus";
    String boardRowUri = compDate == null
            ? "/rgdws/stats/count/objectStatus/"+speciesTypeKey+"/"+inDateStrRest
            : "/rgdws/stats/diff/objectStatus/"+speciesTypeKey+"/"+inDateStrRest+"/"+compDateStrRest;
%>
<%@ include file="boardRowAjax.jsp"%>

<%
    boardRowTitle = "Active Objects";
    boardRowId = "idActiveObj";
    boardRowUri = compDate == null
            ? "/rgdws/stats/count/activeObject/"+speciesTypeKey+"/"+inDateStrRest
            : "/rgdws/stats/diff/activeObject/"+speciesTypeKey+"/"+inDateStrRest+"/"+compDateStrRest;
%>
<%@ include file="boardRowAjax.jsp"%>

<%
    boardRowTitle = "Withdrawn Objects";
    boardRowId = "idWithdrawnObj";
    boardRowUri = compDate == null
            ? "/rgdws/stats/count/withdrawnObject/"+speciesTypeKey+"/"+inDateStrRest
            : "/rgdws/stats/diff/withdrawnObject/"+speciesTypeKey+"/"+inDateStrRest+"/"+compDateStrRest;
%>
<%@ include file="boardRowAjax.jsp"%>

<%
    boardRowTitle = "Retired Objects";
    boardRowId = "idRetiredObj";
    boardRowUri = compDate == null
            ? "/rgdws/stats/count/retiredObject/"+speciesTypeKey+"/"+inDateStrRest
            : "/rgdws/stats/diff/retiredObject/"+speciesTypeKey+"/"+inDateStrRest+"/"+compDateStrRest;
%>
<%@ include file="boardRowAjax.jsp"%>

<%
    boardRowTitle = "Protein Interactions";
    boardRowId = "idProteinInteraction";
    boardRowUri = compDate == null
            ? "/rgdws/stats/count/proteinInteraction/"+speciesTypeKey+"/"+inDateStrRest
            : "/rgdws/stats/diff/proteinInteraction/"+speciesTypeKey+"/"+inDateStrRest+"/"+compDateStrRest;
%>
<%@ include file="boardRowAjax.jsp"%>

<%
    boardRowTitle = "Gene Types";
    boardRowId = "idGeneTypes";
    boardRowUri = compDate == null
            ? "/rgdws/stats/count/geneType/"+speciesTypeKey+"/"+inDateStrRest
            : "/rgdws/stats/diff/geneType/"+speciesTypeKey+"/"+inDateStrRest+"/"+compDateStrRest;
%>
<%@ include file="boardRowAjax.jsp"%>

<%
    boardRowTitle = "Strain Types";
    boardRowId = "idStrainTypes";
    boardRowUri = compDate == null
            ? "/rgdws/stats/count/strainType/"+speciesTypeKey+"/"+inDateStrRest
            : "/rgdws/stats/diff/strainType/"+speciesTypeKey+"/"+inDateStrRest+"/"+compDateStrRest;
%>
<%@ include file="boardRowAjax.jsp"%>

<%
    boardRowTitle = "QTL Inheritance Types";
    boardRowId = "idQtlInheritanceTypes";
    boardRowUri = compDate == null
            ? "/rgdws/stats/count/qtlInheritanceType/"+speciesTypeKey+"/"+inDateStrRest
            : "/rgdws/stats/diff/qtlInheritanceType/"+speciesTypeKey+"/"+inDateStrRest+"/"+compDateStrRest;
%>
<%@ include file="boardRowAjax.jsp"%>

<%
    boardRowTitle = "Objects with Reference";
    boardRowId = "idObjWithRef";
    boardRowUri = compDate == null
            ? "/rgdws/stats/count/objectWithReference/"+speciesTypeKey+"/"+inDateStrRest
            : "/rgdws/stats/diff/objectWithReference/"+speciesTypeKey+"/"+inDateStrRest+"/"+compDateStrRest;
%>
<%@ include file="boardRowAjax.jsp"%>

<%
    boardRowTitle = "Objects With Reference Sequence";
    boardRowId = "idObjWithRefSeq";
    boardRowUri = compDate == null
            ? "/rgdws/stats/count/objectWithRefSeq/"+speciesTypeKey+"/"+inDateStrRest
            : "/rgdws/stats/diff/objectWithRefSeq/"+speciesTypeKey+"/"+inDateStrRest+"/"+compDateStrRest;
%>
<%@ include file="boardRowAjax.jsp"%>

<%
    int[] objKeys = {0, RgdId.OBJECT_KEY_GENES, RgdId.OBJECT_KEY_QTLS, RgdId.OBJECT_KEY_STRAINS};
    for( int objectKey: objKeys ) {

        boardRowTitle = (objectKey==0?"Objects":RgdId.getObjectTypeName(objectKey)+"s")+" With XDB";
        boardRowId = "idObjWithXdb"+objectKey;
        boardRowUri = compDate == null
                ? "/rgdws/stats/count/objectWithXdb/"+speciesTypeKey+"/"+objectKey+"/"+inDateStrRest
                : "/rgdws/stats/diff/objectWithXdb/"+speciesTypeKey+"/"+objectKey+"/"+inDateStrRest+"/"+compDateStrRest;
%>
<%@ include file="boardRowAjax.jsp"%>
<% } %>

<%
    boardRowTitle = "XDBs Count";
    boardRowId = "idXdbs";
    boardRowUri = compDate == null
            ? "/rgdws/stats/count/xdb/"+speciesTypeKey+"/"+inDateStrRest
            : "/rgdws/stats/diff/xdb/"+speciesTypeKey+"/"+inDateStrRest+"/"+compDateStrRest;
%>
<%@ include file="boardRowAjax.jsp"%>

<%@ include file="/common/footerarea.jsp"%>
