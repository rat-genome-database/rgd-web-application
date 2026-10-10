<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<% try { %>

<%
    String pageTitle = " Pipeline logs home page - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Access database logs of any pipeline";

%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="pipelineCss.jsp"%>

  <div class="searchBox">
    <h2><a href="/rgdweb/curation/pipeline/list.html">View Pipeline Logs</a></h2>
  </div>

  <div class="searchBox">
    <h2><a href="/rgdweb/curation/pipeline/ensembl.html">View Ensembl Pipeline Report for Rat</a></h2>
  </div>
<%@ include file="/common/footerarea.jsp"%>

<% }catch (Exception e) {
    e.printStackTrace();
   }
%>