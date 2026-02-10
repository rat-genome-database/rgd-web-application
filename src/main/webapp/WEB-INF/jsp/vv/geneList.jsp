<%@ page import="edu.mcw.rgd.vv.SampleManager" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.dao.impl.SampleDAO" %>
<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>

<%
String pageTitle = "Variant Visualizer (Define Gene Symbol List)";
String headContent = "";
String pageDescription = "Define Gene Symbol List";
%>
<%@ include file="/common/headerarea.jsp" %>
<%@ include file="carpeHeader.jsp"%>
<%@ include file="menuBar.jsp" %>

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
        justify-content: flex-end;
        margin-top: 15px;
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
%>

<script>
    function checkGeneList() {
        document.optionForm.submit();
    }
</script>

<div class="typerMat">
    <div class="typerTitle"><div class="typerTitleSub">Variant&nbsp;Visualizer</div></div>

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
            Enter one or more <strong>gene symbols</strong> to search for variants.
            If entering multiple genes, separate them with <strong>commas</strong> or place each symbol on its own line.
        </div>

        <!-- Gene List Input Card -->
        <form action="config.html" name="optionForm" method="post">
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
                <div class="form-actions">
                    <input class="continueButtonPrimary" type="button" onClick="checkGeneList();" value="Continue..."/>
                </div>
            </div>

            <!-- Hidden fields -->
            <input type="hidden" name="mapKey" value="<%=request.getParameter("mapKey")%>"/>
            <%
            if (request.getParameter("sample1") != null && request.getParameter("sample1").equals("all") && !request.getParameter("mapKey").equals(String.valueOf(17))) {
                SampleDAO sdao = new SampleDAO();
                sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
                List<Sample> samples = new ArrayList<>();
                if (mapKey == 17) {
                    String population = "FIN";
                    samples = sdao.getSamplesByMapKey(mapKey, population);
                } else {
                    samples = sdao.getSamplesByMapKey(mapKey);
                }
                int count = 1;
                for (Sample s : samples) {
            %>
            <input type="hidden" name="sample<%=count++%>" value="<%=s.getId()%>"/>
            <%
                }
            } else {
                if (request.getParameter("sample1") != null && !req.getParameter("sample1").equalsIgnoreCase("all")) {
                    for (int i = 1; i < 100; i++) {
                        if (request.getParameter("sample" + i) != null) {
            %>
            <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
            <%
                        }
                    }
                }
            }
            %>
        </form>

        <!-- Strains Selected Card -->
        <div class="strains-card">
            <div class="strains-header">
                <div class="strains-title">Strains Selected</div>
                <div class="strains-count"><%=strainCount%> strain<%= strainCount != 1 ? "s" : "" %></div>
            </div>
            <div class="strains-list">
                <%
                boolean first = true;
                if (request.getParameter("sample1") != null && request.getParameter("sample1").equals("all") && !request.getParameter("mapKey").equals(String.valueOf(17))) {
                    SampleDAO sdao = new SampleDAO();
                    sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
                    List<Sample> samples = new ArrayList<>();
                    if (mapKey == 17) {
                        String population = "FIN";
                        samples = sdao.getSamplesByMapKey(mapKey, population);
                    } else {
                        samples = sdao.getSamplesByMapKey(mapKey);
                    }
                    for (Sample s : samples) {
                        if (!first) { %>, <% }
                        first = false;
                        out.print(SampleManager.getInstance().getSampleName(s.getId()).getAnalysisName());
                    }
                } else {
                    if (request.getParameter("sample1") != null && !req.getParameter("sample1").equalsIgnoreCase("all")) {
                        for (int i = 1; i < 100; i++) {
                            if (request.getParameter("sample" + i) != null) {
                                if (!first) { %>, <% }
                                first = false;
                                try {
                                    out.print(SampleManager.getInstance().getSampleName(Integer.parseInt(request.getParameter("sample" + i))).getAnalysisName());
                                } catch (Exception e) {}
                            }
                        }
                    }
                }
                if (first) { %>
                <span style="color: #667; font-style: italic;">No strains selected</span>
                <% } %>
            </div>
        </div>
    </div>
</div>

<%@ include file="/common/angularBottomBodyInclude.jsp" %>
<%@ include file="/common/footerarea.jsp" %>
