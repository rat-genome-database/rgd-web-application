<%@ page import="edu.mcw.rgd.*" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 30, 2008
  Time: 4:19:11 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String pageTitle = " Pipeline logs - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Records processed by the pipeline";

%>
<%@ include file="/common/headerarea.jsp"%>
<%@ include file="pipelineCss.jsp"%>

  <div class="searchBox">
    <%
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
    PipelineLog plog = (PipelineLog) request.getAttribute("pipelineLog");
    String pname = ""; // pipeline log name -- make it a link, co you can go back to pipeline log list
    if( plog!= null ) {
        pname = "<a href=\"list.html?pkey="+plog.getPipeline().getPipelineKey()
            +"\">"+plog.getPipeline().getFullName()+"</a>";
    }
    %>
    <h2 class="pip">Pipeline <%=pname%> Log Info:</h2>
      <table border="0" width="99%" class="pip">
      <tr>
          <th>Log info</th>
          <th>Properties</th>
          <th>Record flags</th>
          <th>Error</th>
      </tr>
    <%
        if( plog != null )  {
            //// COLUMN 1: GENERAL PIPELINE LOG INFO
            StringBuilder buf = new StringBuilder(1000);
            buf.append(plog.getPipeline().getFullName())
                    .append("\n log_key:").append(plog.getPipelineLogKey())
                    .append("\n run_mode:").append(plog.getRunMode())
                    .append("\n start time:\n  ").append(sdf.format(plog.getRunStartTime()))
                    .append("\n stop time:\n  ").append(plog.getRunStopTime()!=null?sdf.format(plog.getRunStopTime()):"???")
                    .append("\n\n success_ind:").append(plog.getSuccess().equals("Y")?"OK":"ERROR");
            String col1 = buf.toString();

            // COLUMN 2: PIPELINE LOG PROPERTIES not associated with particular pipeline record
            buf.setLength(0);
            buf.append("DATE-RANGE: ");
            PipelineLog.LogProp prop = plog.getLogProp(PipelineLog.LOGPROP_DATERANGE);
            if( prop!=null ) {
                buf.append(prop.getInfo()).append(" - ").append(prop.getValue());
            }
            buf.append("\nREC-COUNT:");
            prop = plog.getLogProp(PipelineLog.LOGPROP_RECCOUNT);
            if( prop!=null ) {
                buf.append(prop.getValue()).append(" (# of records read from source file)");
            }
            buf.append("\nTOTALS:");
            {
                // load totals into a string array and then sort it
                List<PipelineLog.LogProp> propts = plog.getLogProps(PipelineLog.LOGPROP_TOTAL);
                List<String> totals = new ArrayList<String>(propts.size());
                for( PipelineLog.LogProp propt: propts ) {
                    totals.add("\n  " + propt.getInfo() + ": " + propt.getValue());
                }
                Collections.sort(totals);
                for( String totalAsString: totals ) {
                    buf.append(totalAsString);
                }
            }
            String col2 = buf.toString();

            // COLUMN 3: PIPELINE LOG FLAG PROPERTIES associated with individual pipeline records
            buf.setLength(0);
            for( PipelineLog.LogProp propf: plog.getLogProps("CUSTOM_FLAG") ) {
                buf.append("<a href='reclist.html?plog=").append(plog.getPipelineLogKey())
                   .append("&flag=").append(propf.getValue()).append("#navtop'>")
                   .append(propf.getValue()).append("</a> - ").append(propf.getInfo()).append("\n");
            }
            String col3 = buf.toString();

            // COLUMN 4: PIPELINE LOG error messages
            buf.setLength(0);
            prop = plog.getLogProp(PipelineLog.LOGPROP_ERRORMESSAGE);
            if( prop!=null ) {
                if( prop.getValue()!=null )
                    buf.append(prop.getValue()).append("\n");
                if( prop.getInfo()!=null ) {
                    buf.append(prop.getInfo());
                }
            }
            String col4 = buf.toString();
    %>
        <% if( plog.getSuccess().equals("N") ) {%>
        <tr class="red">
        <% } else { %>
        <tr class="green">
        <% } %>
          <td><pre><%=col1%></pre></td>
          <td><pre><%=col2%></pre></td>
          <td><div id="buttonA">
              <ul><!--<li><a href='reclist.html?plog=<%=plog.getPipelineLogKey()%>'>RECORDS...</a></li>-->
             </ul>
             <pre><%=col3%></pre></div></td>
          <td class="wrapped"><%=col4%></td>
        </tr>
<%}%>
    </table>
   </div>

   <div class="searchbox">
    <h3>Selected property: flag=[${flag}]</h3>
    <div class="pipnav"><a name="navtop"/><!-- navigation links -->
      <c:if test="${pagenr gt 0}"><a href="reclist.html?plog=${plog}&flag=${flag}&pagenr=${pagenr-1}#navtop">&lt;&lt;PREV PAGE &lt;&lt;</a></c:if>
      <span class="navinfo">PAGE ${pagenr+1}, ROWS ${firstRecNo} - ${lastRecNo} out of ${recordCount} &nbsp; &nbsp;</span>
      <c:if test="${showNextPage}"><a href="reclist.html?plog=${plog}&flag=${flag}&pagenr=${pagenr+1}#navtop">&gt;&gt;NEXT PAGE &gt;&gt;</a></c:if>
    </div>
    <div class="piprecset">

        <c:forEach items="${records}" var="rec" varStatus="it">
          <c:if test="${!empty rec.autoload}"><div class="piprecyell"></c:if>
          <c:if test="${empty rec.autoload}"><div class="piprec"></c:if>
            <div class="piprecleft">
                ROW: ${it.index+1}.<br/>
                <a name="rec${rec.recno}"><b>RECNO: ${rec.recno}</b></a>
                <br/>
                ${rec.date}
                <br/>
            </div>
            <div class="piprecmain">
                <c:forEach items="${rec.props}" var="prop">
                    <div class="piprecrow">
                    <b>${prop.key}</b><br/>${prop.value}
                    </div>
                </c:forEach>
            </div>
          </div>
          <div style="clear:both"><hr style="border:solid 5px blue;width:100%"/></div>
        </c:forEach>

    </div><!--rec list-->
    <div class="pipnav"><a name="navbot"/><!-- navigation links -->
      <c:if test="${pagenr gt 0}"><a href="reclist.html?plog=${plog}&flag=${flag}&pagenr=${pagenr-1}#navbot">&lt;&lt;PREV PAGE &lt;&lt;</a></c:if>
        <span class="navinfo">PAGE ${pagenr+1}, ROWS ${firstRecNo} - ${lastRecNo} out of ${recordCount} &nbsp; &nbsp;</span>
      <c:if test="${showNextPage}"><a href="reclist.html?plog=${plog}&flag=${flag}&pagenr=${pagenr+1}#navbot">&gt;&gt;NEXT PAGE &gt;&gt;</a></c:if>
    </div>
   </div>
<%@ include file="/common/footerarea.jsp"%>