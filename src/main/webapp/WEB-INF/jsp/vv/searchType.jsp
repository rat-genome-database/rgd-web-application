<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.vv.SampleManager" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%
String pageTitle = "Variant Visualizer";
String headContent = "";
String pageDescription = "Variant Visualizer - Analyze genomic variation across strains";
%>
<%@ include file="/common/headerarea.jsp" %>
<%@ include file="carpeHeader.jsp"%>

<style>
    /* Modern Config Page Styles - Light Theme */
    .config-container {
        max-width: 950px;
        margin: 20px auto;
        padding: 10px 20px 0 20px;
    }

    .config-header {
        text-align: center;
        margin-bottom: 30px;
    }

    .config-title {
        font-size: 28px;
        font-weight: bold;
        color: #ffffff;
        margin-bottom: 8px;
    }

    .config-subtitle {
        font-size: 14px;
        color: #b8d4f0;
    }

    /* Assembly Selector Card */
    .assembly-card {
        background: #e8f0f8;
        border: 1px solid #c0d0e0;
        border-radius: 8px;
        padding: 20px 25px;
        margin-bottom: 25px;
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-wrap: wrap;
        gap: 15px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.08);
    }

    .assembly-label {
        font-size: 15px;
        font-weight: 600;
        color: #1a3a5a;
    }

    .assembly-select {
        padding: 10px 15px;
        font-size: 15px;
        border: 1px solid #bccada;
        border-radius: 6px;
        background: #f8fafc;
        color: #333;
        min-width: 320px;
        cursor: pointer;
    }

    .assembly-select:focus {
        outline: none;
        border-color: #3a7aba;
        box-shadow: 0 0 0 3px rgba(58, 122, 186, 0.15);
        background: #fff;
    }

    /* Section Title */
    .section-title {
        font-size: 16px;
        font-weight: 600;
        color: #ffffff;
        margin-bottom: 20px;
        padding-bottom: 10px;
        border-bottom: 1px solid rgba(255,255,255,0.3);
    }

    /* Options Grid */
    .options-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 20px;
    }

    @media (max-width: 700px) {
        .options-grid {
            grid-template-columns: 1fr;
        }
    }

    /* Option Card */
    .option-card {
        background: #e8f0f8;
        border: 1px solid #c0d0e0;
        border-radius: 8px;
        padding: 25px;
        cursor: pointer;
        transition: all 0.2s ease;
        display: flex;
        flex-direction: column;
        align-items: center;
        text-align: center;
        box-shadow: 0 2px 4px rgba(0,0,0,0.08);
    }

    .option-card:hover {
        border-color: #3a7aba;
        background: #f0f6fc;
        transform: translateY(-3px);
        box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
    }

    .option-card:active {
        transform: translateY(-1px);
    }

    .option-icon {
        width: 60px;
        height: 60px;
        background: linear-gradient(135deg, #4a8ac9 0%, #3a7aba 100%);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin-bottom: 15px;
        font-size: 24px;
    }

    .option-card:hover .option-icon {
        background: linear-gradient(135deg, #5a9ada 0%, #4a8ac9 100%);
    }

    .option-title {
        font-size: 17px;
        font-weight: bold;
        color: #1a3a5a;
        margin-bottom: 10px;
    }

    .option-description {
        font-size: 13px;
        color: #5a7a9a;
        line-height: 1.5;
    }

    /* Primary option styling */
    .option-card.primary {
        border-color: #28a745;
        background: #e5f2e8;
    }

    .option-card.primary:hover {
        border-color: #34ce57;
        background: #eef8f0;
        box-shadow: 0 8px 20px rgba(40, 167, 69, 0.15);
    }

    .option-card.primary .option-icon {
        background: linear-gradient(135deg, #34ce57 0%, #28a745 100%);
    }

    /* Hidden form */
    .hidden-form {
        display: none;
    }
</style>

<% try { %>

<%
    int mapKey = (Integer) request.getAttribute("mapKey");
    Boolean positionSet = (Boolean) request.getAttribute("positionSet");
    Boolean strainSet = (Boolean) request.getAttribute("strainSet");
    Boolean genesSet = (Boolean) request.getAttribute("genesSet");

    String selectTitle = "Select Strains";
    String selectDesc = "Choose which strain sequences to compare and analyze";
    String selectIcon = "&#128202;"; // chart icon

    if (mapKey == 37 || mapKey == 38 || mapKey == 17) {
        selectTitle = "Select Sequences";
        selectDesc = "Choose which sequences to compare and analyze";
    }
    if (mapKey == 631) {
        selectTitle = "Select Breeds";
        selectDesc = "Choose which breed sequences to compare and analyze";
    }
    if (mapKey == 911 || mapKey == 1311 || mapKey == 35 || mapKey == 239 || mapKey == 634) {
        selectTitle = "View EVA Variants";
        selectDesc = "Explore variants from the European Variation Archive";
    }

    int samplesSize = 100;
    if (mapKey == 631 || mapKey == 600) {
        samplesSize = 250;
    }
%>

<div class="typerMat">
    <div class="config-container">
        <!-- Header -->
        <div class="config-header">
            <div class="config-title">Variant Visualizer</div>
            <div class="config-subtitle">Compare variants across strains, breeds, and samples from multiple species</div>
        </div>

        <!-- Assembly Selector -->
        <div class="assembly-card">
            <span class="assembly-label">Select Assembly</span>
            <select class="assembly-select" id="mapKey" name="mapKey" onChange='location.href="?mapKey=" + this.options[this.selectedIndex].value'>
                <option value='380' <% if (mapKey==380) out.print("selected");%>>Rat Genome Assembly GRCr8</option>
                <option value='372' <% if (mapKey==372) out.print("selected");%>>mRatBN7.2 Assembly</option>
                <option value='360' <% if (mapKey==360) out.print("selected");%>>RGSC Genome Assembly v6.0</option>
                <option value='70' <% if (mapKey==70) out.print("selected");%>>RGSC Genome Assembly v5.0</option>
                <option value='60' <% if (mapKey==60) out.print("selected");%>>RGSC Genome Assembly v3.4</option>
                <option value='38' <% if (mapKey==38) out.print("selected");%>>Human Genome Assembly GRCh38</option>
                <option value='17' <% if (mapKey==17) out.print("selected");%>>Human Genome Assembly GRCh37</option>
                <option value='631' <% if (mapKey==631) out.print("selected");%>>Dog CanFam3.1 Assembly</option>
                <option value='634' <% if (mapKey==634) out.print("selected");%>>ROS_Cfam_1.0 Assembly</option>
                <option value='911' <% if (mapKey==911) out.print("selected");%>>Pig Sscrofa11.1 Assembly</option>
                <option value='35' <% if (mapKey==35) out.print("selected");%>>Mouse Assembly GRCm38</option>
                <option value='239' <% if (mapKey==239) out.print("selected");%>>Mouse Assembly GRCm39</option>
                <option value='1311' <% if (mapKey==1311) out.print("selected");%>>Green Monkey Assembly Vervet 1.1</option>
            </select>
        </div>

        <!-- Section Title -->
        <div class="section-title">
            <% if (strainSet) { %>
                Define Your Region of Interest
            <% } else { %>
                How would you like to search for variants?
            <% } %>
        </div>

        <!-- Hidden Form for submissions -->
        <form id="optionForm" action="annotation.html" name="optionForm" class="hidden-form">
            <input type="hidden" name="mapKey" value="<%=mapKey%>" />
            <input type="hidden" name="geneList" value="<%=req.getParameter("geneList")%>" />
            <input type="hidden" name="chr" value="<%=req.getParameter("chr")%>" />
            <input type="hidden" name="start" value="<%=req.getParameter("start")%>" />
            <input type="hidden" name="stop" value="<%=req.getParameter("stop")%>" />
            <input type="hidden" name="geneStart" value="<%=req.getParameter("geneStart")%>" />
            <input type="hidden" name="geneStop" value="<%=req.getParameter("geneStop")%>" />
            <%
            for (int i=1; i<samplesSize; i++) {
                if (request.getParameter("sample" + i) != null) {
            %>
            <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
            <%
                }
            }
            %>
        </form>

        <!-- Options Grid -->
        <div class="options-grid">
            <% if (!strainSet) { %>
            <!-- Select Strains -->
            <div class="option-card primary" onclick="submitForm('select.html')">
                <div class="option-icon">&#128202;</div>
                <div class="option-title"><%=selectTitle%></div>
                <div class="option-description"><%=selectDesc%></div>
            </div>

            <!-- Limit by Genes -->
            <div class="option-card" onclick="submitForm('geneList.html')">
                <div class="option-icon">&#128271;</div>
                <div class="option-title">Limit by Genes</div>
                <div class="option-description">Search for strain variation based on an individual gene or gene list</div>
            </div>
            <% } %>

            <!-- Limit by Genomic Position -->
            <div class="option-card" onclick="submitForm('region.html')">
                <div class="option-icon">&#128205;</div>
                <div class="option-title">Limit by Genomic Position</div>
                <div class="option-description">Define a region using genomic coordinates or gene/SSLP marker bounds</div>
            </div>

            <% if (!strainSet) { %>
            <!-- Search by Function (before strain selection) -->
            <div class="option-card" onclick="window.location.href='/rgdweb/generator/list.html?vv=1'">
                <div class="option-icon">&#128300;</div>
                <div class="option-title">Search by Function</div>
                <div class="option-description">Build a gene list based on one or more ontology annotations</div>
            </div>
            <% } %>

            <% if (strainSet) { %>
            <!-- Enter a Gene List (shown when strains already selected) -->
            <div class="option-card" onclick="submitForm('geneList.html')">
                <div class="option-icon">&#128221;</div>
                <div class="option-title">Enter a Gene List</div>
                <div class="option-description">Search for variation in a specific set of genes</div>
            </div>

            <!-- Search by Function (after strain selection - at bottom) -->
            <div class="option-card" onclick="window.location.href='/rgdweb/generator/list.html?vv=1'">
                <div class="option-icon">&#128300;</div>
                <div class="option-title">Search by Function</div>
                <div class="option-description">Build a gene list based on one or more ontology annotations</div>
            </div>
            <% } %>
        </div>
    </div>
</div>

<script>
    function submitForm(action) {
        var form = document.getElementById('optionForm');
        form.action = action;
        form.submit();
    }
</script>

<% } catch (Exception e) {
    // Handle error silently
} %>

<%@ include file="/common/footerarea.jsp" %>
