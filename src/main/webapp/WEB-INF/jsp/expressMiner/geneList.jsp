
<%@ page import="edu.mcw.rgd.vv.SampleManager" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.dao.impl.SampleDAO" %>
<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.List" %>

<%
  String pageTitle = "Expression Miner (Define Gene Symbol List)";
  String headContent = "";
  String pageDescription = "Define Gene Symbol List";

  HttpRequestFacade req = new HttpRequestFacade(request);
  DisplayMapper dm = new DisplayMapper(req,  new ArrayList());
%>
<%@ include file="/common/headerarea.jsp" %>

<style>
  /* Modern Gene List Page Styles - Light Theme */
  .typerTitle {
    margin-top: 20px;
  }

  .genelist-container {
    max-width: 900px;
    margin: 20px auto;
    padding: 0 20px 20px 20px;
  }

  .genelist-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
    padding-bottom: 10px;
    border-bottom: 2px solid rgba(255,255,255,0.3);
  }

  .genelist-title {
    font-size: 18px;
    font-weight: bold;
    color: #ffffff;
  }

  .genelist-assembly {
    font-size: 14px;
    color: #b8d4f0;
  }

  .genelist-instructions {
    background: #e8f4fc;
    border-left: 4px solid #3a7aba;
    padding: 12px 15px;
    margin-bottom: 20px;
    border-radius: 0 4px 4px 0;
    color: #2a4a6a;
    font-size: 13px;
    line-height: 1.5;
  }

  .genelist-card {
    background: #e8f0f8;
    border: 1px solid #c0d0e0;
    border-radius: 6px;
    padding: 20px;
    margin-bottom: 20px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.08);
  }

  .card-title {
    font-size: 15px;
    font-weight: bold;
    color: #1a3a5a;
    margin-bottom: 15px;
    padding-bottom: 8px;
    border-bottom: 1px solid #dde5ef;
  }

  .gene-textarea {
    width: 100%;
    min-height: 250px;
    padding: 12px 15px;
    border: 1px solid #bccada;
    border-radius: 6px;
    background: #f8fafc;
    color: #333;
    font-size: 14px;
    font-family: 'Consolas', 'Monaco', monospace;
    line-height: 1.5;
    resize: vertical;
  }

  .gene-textarea:focus {
    outline: none;
    border-color: #3a7aba;
    box-shadow: 0 0 0 3px rgba(58, 122, 186, 0.15);
    background: #fff;
  }

  .gene-textarea::placeholder {
    color: #8899aa;
    font-family: inherit;
  }

  .form-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 15px;
  }

  .backLink {
    color: #0052a1;
    text-decoration: none;
    font-size: 13px;
  }

  /* Continue Button */
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

  .continueButtonSecondary {
    font-size: 14px;
    font-weight: bold;
    background: linear-gradient(to bottom, #4a8ac9 0%, #3a7aba 100%);
    color: white;
    border: 1px solid #2f6699;
    border-radius: 4px;
    padding: 10px 20px;
    cursor: pointer;
    box-shadow: 0 2px 4px rgba(0,0,0,0.15);
    transition: all 0.2s ease;
  }

  .continueButtonSecondary:hover {
    background: linear-gradient(to bottom, #5a9ada 0%, #4a8ac9 100%);
    transform: translateY(-1px);
    box-shadow: 0 3px 6px rgba(0,0,0,0.2);
  }

  .gene-actions {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .gene-action-buttons {
    display: flex;
    gap: 10px;
  }

  .gene-error {
    display: none;
    color: #b34747;
    font-size: 12px;
    text-align: right;
    margin-top: 8px;
  }

  /* Strains Selected Card */
  .strains-card {
    background: #dce8f4;
    border: 1px solid #c0d0e0;
    border-radius: 6px;
    padding: 15px 20px;
  }

  .strains-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
  }

  .strains-title {
    font-size: 14px;
    font-weight: bold;
    color: #1a3a5a;
  }

  .strains-count {
    font-size: 12px;
    color: white;
    background: #3a7aba;
    padding: 2px 8px;
    border-radius: 10px;
  }

  .strains-list {
    color: #445566;
    font-size: 13px;
    line-height: 1.6;
  }

  /* Example genes hint */
  .input-hint {
    font-size: 12px;
    color: #6a7a8a;
    margin-top: 8px;
  }
</style>

<%
  String assemblyName = null;
  int mapKey = 0;
  try {
    mapKey = Integer.parseInt(request.getParameter("mapKey"));
    assemblyName = MapManager.getInstance().getMap(mapKey).getName();
  } catch (Exception ignore) {}

  // Count selected strains
  int strainCount = 0;
  for (int i = 1; i < 100; i++) {
    if (request.getParameter("sample" + i) != null) {
      strainCount++;
    }
  }

  List<String> selectedStudyIds = (List<String>) request.getAttribute("selectedStudyIds");
  Boolean studiesFirstObj = (Boolean) request.getAttribute("studiesFirst");
  boolean studiesFirst = studiesFirstObj != null && studiesFirstObj;

  List<String> selectedStrainIds = (List<String>) request.getAttribute("selectedStrainIds");
  if (selectedStrainIds == null) selectedStrainIds = new ArrayList<String>();
  List<String> selectedTissueIds = (List<String>) request.getAttribute("selectedTissueIds");
  if (selectedTissueIds == null) selectedTissueIds = new ArrayList<String>();

  String nextAction = (String) request.getAttribute("nextAction");
  if (nextAction == null) nextAction = "/rgdweb/expressMiner/config.html";

  Boolean genesEntryObj = (Boolean) request.getAttribute("genesEntry");
  boolean genesEntry = genesEntryObj != null && genesEntryObj;
%>

<script>
  // Submit the gene list to the chosen next step. When requireGenes is true (going straight
  // to the genes-only results), at least one gene symbol must be entered first.
  function proceedGeneList(action, requireGenes) {
    if (requireGenes) {
      var v = document.getElementById('geneList').value.trim();
      if (!v) {
        document.getElementById('geneListError').style.display = 'block';
        document.getElementById('geneList').focus();
        return;
      }
    }
    var form = document.optionForm;
    form.action = action;
    form.submit();
  }
</script>

<div class="typerMat">
  <div class="genelist-container">
    <!-- Header -->
    <div class="genelist-header">
      <div class="genelist-title">Enter Gene Symbols</div>
      <% if (assemblyName != null) { %>
      <div class="genelist-assembly"><%=assemblyName%> assembly</div>
      <% } %>
    </div>

    <!-- Instructions -->
    <div class="genelist-instructions">
      Enter one or more <strong>gene symbols</strong> to search for expression data.
      If entering multiple genes, separate them with <strong>commas</strong> or place each symbol on its own line.
      <% if (studiesFirst) { %>
      <br/><strong><%=selectedStudyIds.size()%></strong> <%=selectedStudyIds.size() == 1 ? "study" : "studies"%> selected on the previous step will be carried forward.
      <% } %>
      <% int stCount = selectedStrainIds.size() + selectedTissueIds.size();
         if (stCount > 0) { %>
      <br/><strong><%=stCount%></strong> strain/tissue selection<%=stCount == 1 ? "" : "s"%> from the previous step will be carried forward.
      <% } %>
    </div>

    <!-- Gene List Input Card -->
    <form action="<%=nextAction%>" name="optionForm" method="post">
      <input type="hidden" name="mapKey" value="<%=mapKey%>"/>
      <% if (studiesFirst) {
           for (String sid : selectedStudyIds) { %>
      <input type="hidden" name="studyId" value="<%=sid%>"/>
      <% }
         } %>
      <% for (String strainId : selectedStrainIds) { %>
      <input type="hidden" name="strainId" value="<%=strainId%>"/>
      <% } %>
      <% for (String tissueId : selectedTissueIds) { %>
      <input type="hidden" name="tissueId" value="<%=tissueId%>"/>
      <% } %>
      <div class="genelist-card">
        <div class="card-title">Gene Symbol List</div>
        <textarea
                class="gene-textarea"
                name="geneList"
                id="geneList"
                placeholder="Enter gene symbols here...&#10;&#10;Examples:&#10;Brca1&#10;Tp53, Egfr, Myc&#10;Pten"
        ><%=dm.out("geneList", req.getParameter("geneList"))%></textarea>
        <div class="input-hint">
          Tip: You can paste a list of genes directly from a spreadsheet or text file
        </div>
        <% if (genesEntry) { %>
        <div class="gene-actions">
          <a class="backLink" href="javascript:history.back()">&#8592; Back</a>
          <div class="gene-action-buttons">
            <input class="continueButtonSecondary" type="button"
                   onClick="proceedGeneList('/rgdweb/expressMiner/strainTissue.html', false);"
                   value="Add Strains / Tissues..."/>
            <input class="continueButtonPrimary" type="button"
                   onClick="proceedGeneList('<%=nextAction%>', true);"
                   value="View Results"/>
          </div>
        </div>
        <div id="geneListError" class="gene-error">Enter at least one gene symbol to view results.</div>
        <% } else { %>
        <div class="form-actions">
          <a class="backLink" href="javascript:history.back()">&#8592; Back</a>
          <input class="continueButtonPrimary" type="button"
                 onClick="proceedGeneList('<%=nextAction%>', false);" value="Continue..."/>
        </div>
        <% } %>
      </div>

    </form>

  </div>
</div>

<%@ include file="/common/angularBottomBodyInclude.jsp" %>
<%@ include file="/common/footerarea.jsp" %>
