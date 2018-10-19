<%@ page buffer="none" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.stats.ScoreBoardManager" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdId" %>
<%@ page import="edu.mcw.rgd.dao.impl.StatisticsDAO" %>

<%
    String pageTitle = "Score Board - Annotations";
    String headContent = "";
    String pageDescription = "";

%>

<%@ include file="/common/headerarea.jsp"%>

<%
    String speciesType = request.getParameter("species");
    if (speciesType == null) {
        speciesType="3";
    }
    int speciesTypeKey = Integer.parseInt(speciesType);

    FormUtility fu = new FormUtility();

    ScoreBoardManager sbm = new ScoreBoardManager();

    Map boardMap = null;

    SimpleDateFormat inDateFormat = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat outDateFormat = new SimpleDateFormat("MMM d yyyy");

    String inDateStr = request.getParameter("date");

    Date inDate = new Date();
    if ( inDateStr!=null && !inDateStr.equals("Today") ) {
        //System.out.println("inDateStr = !" + inDateStr + "!" );
        inDate = inDateFormat.parse(inDateStr);
    }else {
        inDateStr = "Today";
    }

    String compDateStr = request.getParameter("compare");
    Date compDate = null;
    if ( compDateStr!=null && !compDateStr.equals("None")) {
        compDate = inDateFormat.parse(compDateStr);
    }else {
        compDateStr="None";
    }
%>

<h3>SCORE BOARD - PORTALS
 &nbsp; &nbsp;
 <a href="/rgdweb/score/board.jsp" title="View Score Board - General">general</a>
 &nbsp; &nbsp;
 <a href="/rgdweb/score/boardAnnot.jsp" title="View Score Board for Annotations">annotations</a>
</h3>

<form action="">
<table style="background-color:#d6e7ff;">
    <tr>
        <td><label id="lbl_species" for="sel_species" accesskey="S">Species:</label></td>
        <td><select name="species" id="sel_species">
            <option value="0" <%=fu.optionParams(speciesType, "0")%>>ALL</option>
            <option value="1" <%=fu.optionParams(speciesType, "1")%>>Human</option>
            <option value="2" <%=fu.optionParams(speciesType, "2")%>>Mouse</option>
            <option value="3" <%=fu.optionParams(speciesType, "3")%>>Rat</option>
            <option value="4" <%=fu.optionParams(speciesType, "4")%>>Chinchilla</option>
            <option value="5" <%=fu.optionParams(speciesType, "5")%>>Bonobo</option>
            <option value="6" <%=fu.optionParams(speciesType, "6")%>>Dog</option>
            <option value="7" <%=fu.optionParams(speciesType, "7")%>>Squirrel</option>
            </select>
        </td>
        <td>&nbsp;</td>
        <td>Date</td>
        <td><select name="date" >
                <option value="Today">Today</option>
               <%  List<String> dates = sbm.getStatArchiveDates();
                   for( String date: dates ) {
               %>
                       <option value="<%=date%>" <%=fu.optionParams(inDateStr, date)%> ><%=outDateFormat.format(inDateFormat.parse(date))%></option>
               <%
                   }
               %>

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
               <%
                   }
               %>

            </select>
            <input type="submit" value="Submit"/>
        </td>
    </tr>
</table>
</form>

<%
    out.println("Species: <b>" + edu.mcw.rgd.datamodel.SpeciesType.getCommonName(Integer.parseInt(speciesType)) +"</b> , Date: <b>" + inDateStr + "</b> , Compare Date: <b>" + compDateStr + "</b>");
%>

<%  int[] objKeys = {0, RgdId.OBJECT_KEY_GENES, RgdId.OBJECT_KEY_QTLS, RgdId.OBJECT_KEY_STRAINS};
    for( int objectKey: objKeys ) {

        String boardRowTitle = StatisticsDAO.getPortalStatName(speciesTypeKey, objectKey);
        if (compDate == null) {
            boardMap = sbm.getPortalAnnotatedObjectCount(speciesTypeKey, objectKey, inDate);
        }else {
            boardMap = sbm.mapSubtract(
                sbm.getPortalAnnotatedObjectCount(speciesTypeKey, objectKey, compDate),
                sbm.getPortalAnnotatedObjectCount(speciesTypeKey, objectKey, inDate));
        }
%>
<%@ include file="boardRow.jsp"%>
<%
    }
%>
<%@ include file="/common/footerarea.jsp"%>

