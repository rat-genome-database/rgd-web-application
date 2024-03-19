<%@ page import="edu.mcw.rgd.*" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
  Created by IntelliJ IDEA.
  User: mtutaj
  Date: February 03, 2010
  Time: 4:19:11 PM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%
    String pageTitle = " Pipeline outcome - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Details about last run for every pipeline run.";

%>
<%@ include file="/common/headerarea.jsp"%>
<%@ include file="pipelineCss.jsp"%>

  <div class="searchBox">
    <h2>Pipeline Log List</h2>
      Pipeline: <select id="pkey" onchange="if (this.selectedIndex > 0) document.location.href='?pkey=' + this.value;">
      <%
      List<Pipeline> pipelines = (List<Pipeline>) request.getAttribute("pipelines");
      Integer pkey = (Integer) request.getAttribute("pkey");
      for( Pipeline pipeline: pipelines ) {
        if( pkey ==pipeline.getPipelineKey() ) {%>
        <option selected="selected" value="<%=pipeline.getPipelineKey()%>"><%=pipeline.getFullName()%></option>
      <% } else { %>
        <option value="<%=pipeline.getPipelineKey()%>"><%=pipeline.getFullName()%></option>
      <% }
      } %>
    </select>

    <table border="0" width="99%" class="pip">
    <tr>
        <th>Log info</th>
        <th>Properties</th>
        <th>Record flags</th>
        <th>Error</th>
    </tr>
    <%
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
    List<PipelineLog> plogs = (List<PipelineLog>) request.getAttribute("plogs");
    if( plogs != null )
    for( PipelineLog plog: plogs ) {

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
            buf.append(prop.getValue());
        }
        buf.append("\nTOTALS:");
        {
            // load totals into a string array and then sort it
            List<PipelineLog.LogProp> propts = plog.getLogProps(PipelineLog.LOGPROP_TOTAL);
            List<String> totals = new ArrayList<String>(propts.size());
            for( PipelineLog.LogProp propt: propts ) {
                totals.add("\n  "+propt.getInfo()+": "+propt.getValue());
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
               .append("&flag=").append(propf.getValue()).append("'>")
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
                <ul><li><a href='reclist.html?plog=<%=plog.getPipelineLogKey()%>'>RECORDS...</a></li>
               </ul>
               <pre><%=col3%></pre></div></td>
            <td class="wrapped"><%=col4%></td>
        </tr>
<%
    }%>
      <tr>
            <td colspan="5">NOTE! Only first dozen of pipeline logs is displayed (limitation of this version)</td>
      </tr>
    </table>
   </div>
<%@ include file="/common/footerarea.jsp"%>
