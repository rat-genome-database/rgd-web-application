<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<% try { %>

<%
    String pageTitle = " Ensembl Pipeline Report - Rat Genome Database";
    String headContent = "";
    String pageDescription = "Summary report for Ensembl Rat Pipeline";

%>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="pipelineCss.jsp"%>

  <div class="searchBox">
    <h2>Rat Ensembl Pipeline Report</h2>
  </div>

  <div class="searchBox">

      <table class="infobox_wrapper">
          <tr>
              <td colspan="2" class="infobox_header">Rat Ensembl Pipeline Summary</td>
          </tr>
          <%
              Map<String, String> summaryMap = (Map<String,String>) request.getAttribute("summaryMap");
              for( Map.Entry<String,String> entry: summaryMap.entrySet() ) {
          %>
          <tr>
              <td class="label"><%= entry.getKey()%></td>
              <td><%=entry.getValue()%></td>
          </tr>
          <% } %>
      </table>
  </div>

  <div class="searchBox">
      <h3>RAT - CONFLICTS BIN1</h3>
      <h5>All Ensembl genes that have multiple RGD ids and/or Gene Ids that match multiple active genes in RGD.
          Only one of matching RGD genes could have a valid position on reference assembly.</h5>

      <h5>There are <%=request.getAttribute("bin1_count")%> genes in bin1.</h5>

      <style>
            table.conflict_bin1 {
                font: 11px/24px Verdana, Arial, Helvetica, sans-serif;
                border-collapse: collapse;
                border: 1px solid #FB7A31;
                background: #FFC;
                width: 800px;
                }
            table.conflict_bin1 th {
                border: 1px solid #FB7A31;
                background-color: white;
                font-weight: bold;
                padding: 0.5em 0.5em;
                text-align: left;
                }
            td {
                border: 1px solid #CCC;
                padding: 0 0.5em;
                }
      </style>
      <div>
          <%=request.getAttribute("bin1")%>
      </div>
  </div>
<%@ include file="/common/footerarea.jsp"%>

<% }catch (Exception e) {
    e.printStackTrace();
   }
%>