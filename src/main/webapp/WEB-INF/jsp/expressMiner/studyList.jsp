<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="java.util.List" %>

<%
    String pageTitle = "Expression Miner (Select Studies)";
    String headContent = "";
    String pageDescription = "Pick studies with expression data for the chosen genes";
%>
<%@ include file="/common/headerarea.jsp" %>

<style>
  .studylist-container {
    max-width: 950px;
    margin: 20px auto;
    padding: 0 20px 20px 20px;
  }

  .studylist-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 2px solid rgba(255,255,255,0.3);
  }

  .studylist-title {
    font-size: 18px;
    font-weight: bold;
    color: #ffffff;
  }

  .studylist-assembly {
    font-size: 14px;
    color: #1e5a96;
  }

  .studylist-summary {
    background: #e8f4fc;
    border-left: 4px solid #3a7aba;
    padding: 12px 15px;
    margin-bottom: 20px;
    border-radius: 0 4px 4px 0;
    color: #2a4a6a;
    font-size: 13px;
    line-height: 1.5;
  }

  .studylist-warning {
    background: #fdf3e7;
    border-left: 4px solid #d98c2b;
    padding: 12px 15px;
    margin-bottom: 20px;
    border-radius: 0 4px 4px 0;
    color: #6b4a1a;
    font-size: 13px;
    line-height: 1.5;
  }

  .studylist-empty {
    background: #f5e9e9;
    border-left: 4px solid #b34747;
    padding: 12px 15px;
    margin-bottom: 20px;
    border-radius: 0 4px 4px 0;
    color: #6b1a1a;
    font-size: 13px;
    line-height: 1.5;
  }

  .study-card {
    background: #e8f0f8;
    border: 1px solid #c0d0e0;
    border-radius: 6px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.08);
  }

  .study-card-title {
    font-size: 15px;
    font-weight: bold;
    color: #1a3a5a;
    margin-bottom: 15px;
    padding-bottom: 8px;
    border-bottom: 1px solid #dde5ef;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .study-card-actions {
    font-size: 12px;
  }

  .study-card-actions a {
    color: #3a7aba;
    cursor: pointer;
    text-decoration: none;
    margin-left: 12px;
  }

  .study-card-actions a:hover {
    text-decoration: underline;
  }

  .study-row {
    display: flex;
    align-items: flex-start;
    padding: 10px 8px;
    border-radius: 4px;
    border-bottom: 1px solid #dde5ef;
  }

  .study-row:last-child {
    border-bottom: none;
  }

  .study-row:hover {
    background: #f0f6fc;
  }

  .study-checkbox {
    margin-right: 12px;
    margin-top: 4px;
    transform: scale(1.15);
    cursor: pointer;
  }

  .study-info {
    flex: 1;
  }

  .study-name {
    font-size: 14px;
    font-weight: 600;
    color: #1a3a5a;
    margin-bottom: 4px;
  }

  .study-meta {
    font-size: 12px;
    color: #5a7a9a;
  }

  .study-meta span + span:before {
    content: " \2022 ";
    color: #b0c0d0;
  }

  .geo-link {
    color: #3a7aba;
    text-decoration: none;
  }

  .geo-link:hover {
    text-decoration: underline;
  }

  .form-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 15px;
  }

  /* Sticky action bar - keeps Continue button visible while scrolling the study list */
  .form-actions-sticky {
    position: sticky;
    bottom: 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #e8f0f8;
    border: 1px solid #c0d0e0;
    border-radius: 6px;
    padding: 12px 20px;
    margin-top: 15px;
    box-shadow: 0 -4px 12px rgba(0,0,0,0.12);
    z-index: 10;
  }

  .continueButtonPrimary {
    font-size: 14px;
    font-weight: bold;
    background: linear-gradient(to bottom, #28a745 0%, #1e7e34 100%);
    color: white;
    border: 1px solid #1e7e34;
    border-radius: 4px;
    padding: 10px 24px;
    cursor: pointer;
    box-shadow: 0 2px 4px rgba(0,0,0,0.15);
    transition: all 0.2s ease;
  }

  .continueButtonPrimary:hover {
    background: linear-gradient(to bottom, #34ce57 0%, #28a745 100%);
    transform: translateY(-1px);
    box-shadow: 0 3px 6px rgba(0,0,0,0.2);
  }

  .continueButtonPrimary[disabled] {
    background: #aab8c5;
    border-color: #93a2b0;
    cursor: not-allowed;
    transform: none;
    box-shadow: none;
  }

  .backLink {
    color: #0052a1;
    text-decoration: none;
    font-size: 13px;
  }

  .backLink:hover {
    color: #bd80ff;
    text-decoration: underline;
  }
</style>

<%
    int mapKey = (Integer) request.getAttribute("mapKey");
    String assemblyName = null;
    try {
        assemblyName = MapManager.getInstance().getMap(mapKey).getName();
    } catch (Exception ignore) {}

    String geneList = (String) request.getAttribute("geneList");
    List<Study> studies = (List<Study>) request.getAttribute("studies");
    List<String> unresolvedSymbols = (List<String>) request.getAttribute("unresolvedSymbols");
    Integer resolvedSymbolCount = (Integer) request.getAttribute("resolvedSymbolCount");
    Boolean genesFirstObj = (Boolean) request.getAttribute("genesFirst");
    boolean genesFirst = genesFirstObj != null && genesFirstObj;
    String nextAction = (String) request.getAttribute("nextAction");
    if (nextAction == null) nextAction = "/rgdweb/expressMiner/config.html";
%>

<div class="typerMat">
  <div class="studylist-container">
    <div class="studylist-header">
      <div class="studylist-title">Select Studies</div>
      <% if (assemblyName != null) { %>
      <div class="studylist-assembly"><%=assemblyName%> assembly</div>
      <% } %>
    </div>

    <div class="studylist-summary">
      <% if (genesFirst) { %>
        <% if (resolvedSymbolCount != null && resolvedSymbolCount > 0) { %>
          Showing studies with expression data for <strong><%=resolvedSymbolCount%></strong>
          gene<%=resolvedSymbolCount == 1 ? "" : "s"%> on this assembly.
          Studies with no matching expression data are hidden.
        <% } else { %>
          No gene symbols could be resolved on this assembly.
        <% } %>
      <% } else { %>
        Showing all studies with expression data on this assembly.
        Pick the studies you want, then provide a gene list on the next step.
      <% } %>
    </div>

    <% if (unresolvedSymbols != null && !unresolvedSymbols.isEmpty()) { %>
    <div class="studylist-warning">
      Could not resolve the following symbol<%=unresolvedSymbols.size() == 1 ? "" : "s"%>
      on this assembly:
      <strong><%
        for (int i = 0; i < unresolvedSymbols.size(); i++) {
          if (i > 0) out.print(", ");
          out.print(unresolvedSymbols.get(i));
        }
      %></strong>
    </div>
    <% } %>

    <% if (studies == null || studies.isEmpty()) { %>
      <div class="studylist-empty">
        <% if (genesFirst) { %>
          No studies have gene expression data for the supplied gene list on this assembly.
          Try a different gene list or a different assembly.
        <% } else { %>
          No studies have gene expression data on this assembly. Try a different assembly.
        <% } %>
      </div>
      <div class="form-actions">
        <a class="backLink" href="javascript:history.back()">&#8592; Back</a>
      </div>
    <% } else { %>

      <form action="<%=nextAction%>" name="optionForm" method="post">
        <input type="hidden" name="mapKey" value="<%=mapKey%>"/>
        <% if (genesFirst) { %>
        <input type="hidden" name="geneList" value="<%= geneList == null ? "" : geneList.replace("\"","&quot;") %>"/>
        <% } %>

        <div class="study-card">
          <div class="study-card-title">
            <span>Studies with Expression Data (<%=studies.size()%>)</span>
            <span class="study-card-actions">
              <a onclick="toggleAll(true)">Select all</a>
              <a onclick="toggleAll(false)">Clear</a>
            </span>
          </div>

          <% for (Study s : studies) {
            String geo = s.getGeoSeriesAcc();
            String type = s.getType();
            String dataType = s.getDataType();
            String source = s.getSource();
          %>
          <label class="study-row">
            <input class="study-checkbox" type="checkbox" name="studyId" value="<%=s.getId()%>" onchange="updateContinue()"/>
            <span class="study-info">
              <div class="study-name"><%= s.getName() == null ? "(unnamed study)" : s.getName() %></div>
              <div class="study-meta">
                <span>ID:
                  <a class="geo-link" target="_blank" onclick="event.stopPropagation()"
                     href="/rgdweb/report/expressionStudy/main.html?id=<%=s.getId()%>"><%=s.getId()%></a>
                </span>
                <% if (geo != null && !geo.isEmpty()) { %>
                  <span>GEO:
                    <a class="geo-link" target="_blank"
                       href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=<%=geo%>"><%=geo%></a>
                  </span>
                <% } %>
                <% if (type != null && !type.isEmpty()) { %><span>Type: <%=type%></span><% } %>
                <% if (dataType != null && !dataType.isEmpty()) { %><span>Data: <%=dataType%></span><% } %>
                <% if (source != null && !source.isEmpty()) { %><span>Source: <%=source%></span><% } %>
              </div>
            </span>
          </label>
          <% } %>
        </div>

        <div class="form-actions-sticky">
          <a class="backLink" href="javascript:history.back()">&#8592; Back</a>
          <input id="continueBtn" class="continueButtonPrimary" type="submit" value="Continue..." disabled/>
        </div>
      </form>

      <script>
        function toggleAll(checked) {
          var boxes = document.getElementsByName('studyId');
          for (var i = 0; i < boxes.length; i++) boxes[i].checked = checked;
          updateContinue();
        }
        function updateContinue() {
          var boxes = document.getElementsByName('studyId');
          var any = false;
          for (var i = 0; i < boxes.length; i++) { if (boxes[i].checked) { any = true; break; } }
          document.getElementById('continueBtn').disabled = !any;
        }
      </script>
    <% } %>

  </div>
</div>

<%@ include file="/common/footerarea.jsp" %>
