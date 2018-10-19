<%@ page buffer="none" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.stats.ScoreBoardManager" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.datamodel.RgdId" %>
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

<h3>SCORE BOARD - ANNOTATIONS
 &nbsp; &nbsp;
 <a href="/rgdweb/score/board.jsp" title="View Score Board - General">general</a>
 &nbsp; &nbsp;
 <a href="/rgdweb/score/boardPortal.jsp" title="View Score Board for Portals">portal</a>
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

<%
    String boardRowTitle = "Ontology Term Count";
    if (compDate == null) {
        boardMap = sbm.getOntologyTermCount(inDate);
    }else {
        boardMap = sbm.mapSubtract(sbm.getOntologyTermCount(compDate), sbm.getOntologyTermCount(inDate));
    }
%>
<%@ include file="boardRow.jsp"%>

<%
    boardRowTitle = "Ontology Annotated Term Count";
    if (compDate == null) {
        boardMap = sbm.getAnnotatedOntologyTermCount(speciesTypeKey, inDate);
    }else {
        boardMap = sbm.mapSubtract(sbm.getAnnotatedOntologyTermCount(speciesTypeKey, compDate), sbm.getAnnotatedOntologyTermCount(speciesTypeKey, inDate));
    }
%>
<%@ include file="boardRow.jsp"%>


<%
    boardRowTitle = "References with Annotations";
    if (compDate == null) {
        boardMap = sbm.getAnnotatedReferencesCount(speciesTypeKey, inDate);
    }else {
        boardMap = sbm.mapSubtract(sbm.getAnnotatedReferencesCount(speciesTypeKey, compDate), sbm.getAnnotatedReferencesCount(speciesTypeKey, inDate));
    }
%>
<%@ include file="boardRow.jsp"%>


<%  int[] objKeys = {0, RgdId.OBJECT_KEY_GENES, RgdId.OBJECT_KEY_QTLS, RgdId.OBJECT_KEY_STRAINS};
    for( int objectKey: objKeys ) {

        boardRowTitle = "Ontology "+(objectKey==0?"":RgdId.getObjectTypeName(objectKey)+" ")+"Annotations";
        if (compDate == null) {
            boardMap = sbm.getOntologyAnnotationCount(speciesTypeKey, objectKey, inDate);
        }else {
            boardMap = sbm.mapSubtract(
                sbm.getOntologyAnnotationCount(speciesTypeKey, objectKey, compDate),
                sbm.getOntologyAnnotationCount(speciesTypeKey, objectKey, inDate));
        }
%>
<%@ include file="boardRow.jsp"%>
<%
    }
%>

<%
    for( int objectKey: objKeys ) {

        boardRowTitle = "Ontology "+(objectKey==0?"Object":RgdId.getObjectTypeName(objectKey))+"s Annotated";
        if (compDate == null) {
            boardMap = sbm.getOntologyAnnotatedObjectCount(speciesTypeKey, objectKey, inDate);
        }else {
            boardMap = sbm.mapSubtract(
                sbm.getOntologyAnnotatedObjectCount(speciesTypeKey, objectKey, compDate),
                sbm.getOntologyAnnotatedObjectCount(speciesTypeKey, objectKey, inDate));
        }
%>
<%@ include file="boardRow.jsp"%>
<%
    }
%>

<%
    for( int objectKey: objKeys ) {

        boardRowTitle = "Ontology "+(objectKey==0?"":RgdId.getObjectTypeName(objectKey)+" ")+"Manual Annotations";
        if (compDate == null) {
            boardMap = sbm.getOntologyManualAnnotationCount(speciesTypeKey, objectKey, inDate);
        }else {
            boardMap = sbm.mapSubtract(
                sbm.getOntologyManualAnnotationCount(speciesTypeKey, objectKey, compDate),
                sbm.getOntologyManualAnnotationCount(speciesTypeKey, objectKey, inDate));
        }
%>
<%@ include file="boardRow.jsp"%>
<%
    }
%>

<%
    for( int objectKey: objKeys ) {

        boardRowTitle = "Ontology "+(objectKey==0?"Object":RgdId.getObjectTypeName(objectKey))+"s Manually Annotated";
        if (compDate == null) {
            boardMap = sbm.getOntologyManualAnnotatedObjectCount(speciesTypeKey, objectKey, inDate);
        }else {
            boardMap = sbm.mapSubtract(
                sbm.getOntologyManualAnnotatedObjectCount(speciesTypeKey, objectKey, compDate),
                sbm.getOntologyManualAnnotatedObjectCount(speciesTypeKey, objectKey, inDate));
        }
%>
<%@ include file="boardRow.jsp"%>
<%
    }
%>

<p>
    Please note: manual annotations originate in RGD (data_src='RGD')
    and their evidence codes are anything else than ('IEA','ISO','ISM','ISA','ISS','IGC','IBA','IBD','IKR','IRD','RCA')
</p>
<%@ include file="/common/footerarea.jsp"%>

