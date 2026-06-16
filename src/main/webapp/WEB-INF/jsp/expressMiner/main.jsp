<%@ page import="java.util.*" %>

<%
    String pageTitle = "Expression Miner";
    String headContent = "";
    String pageDescription = "Expression Miner - Analyze expression data ";
%>
<%@ include file="/common/headerarea.jsp" %>


<style>
    /* Modern Config Page Styles - Light Theme */
    .config-container {
        max-width: 950px;
        margin: 20px auto;
        padding: 10px 20px 20px 20px;
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

    /* Error banner */
    .em-error {
        background: #f8d7da;
        border: 1px solid #f1aeb5;
        border-left: 4px solid #c0392b;
        color: #b30000;
        font-weight: bold;
        font-size: 14px;
        padding: 12px 15px;
        border-radius: 4px;
        margin-bottom: 20px;
        line-height: 1.5;
    }
</style>

<% try { %>

<%
    Integer mapKeyObj = (Integer) request.getAttribute("mapKey");
    int mapKey = mapKeyObj == null ? 380 : mapKeyObj;
    String errorMessage = (String) request.getAttribute("errorMessage");
%>

<div class="typerMat">
    <div class="config-container">
        <!-- Header -->
        <div class="config-header">
            <div class="config-title">Expression Miner</div>
            <div class="config-subtitle">View expression data through strains and genes</div>
        </div>

        <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
        <div class="em-error"><%= errorMessage %></div>
        <% } %>

        <!-- Assembly Selector -->
        <div class="assembly-card">
            <span class="assembly-label">Select Assembly</span>
            <select class="assembly-select" id="mapKey" name="mapKey" onChange='location.href="?mapKey=" + this.options[this.selectedIndex].value'>
                <option value='380' <% if (mapKey==380) out.print("selected");%>>Rat Genome Assembly GRCr8</option>
                <option value='372' <% if (mapKey==372) out.print("selected");%>>mRatBN7.2 Assembly</option>
                <option value='360' <% if (mapKey==360) out.print("selected");%>>RGSC Genome Assembly v6.0</option>
<%--                <option value='70' <% if (mapKey==70) out.print("selected");%>>RGSC Genome Assembly v5.0</option>--%>
<%--                <option value='60' <% if (mapKey==60) out.print("selected");%>>RGSC Genome Assembly v3.4</option>--%>
<%--                <option value='38' <% if (mapKey==38) out.print("selected");%>>Human Genome Assembly GRCh38</option>--%>
<%--                <option value='17' <% if (mapKey==17) out.print("selected");%>>Human Genome Assembly GRCh37</option>--%>
<%--                <option value='631' <% if (mapKey==631) out.print("selected");%>>Dog CanFam3.1 Assembly</option>--%>
<%--                <option value='634' <% if (mapKey==634) out.print("selected");%>>ROS_Cfam_1.0 Assembly</option>--%>
<%--                <option value='911' <% if (mapKey==911) out.print("selected");%>>Pig Sscrofa11.1 Assembly</option>--%>
<%--                <option value='35' <% if (mapKey==35) out.print("selected");%>>Mouse Assembly GRCm38</option>--%>
<%--                <option value='239' <% if (mapKey==239) out.print("selected");%>>Mouse Assembly GRCm39</option>--%>
<%--                <option value='1311' <% if (mapKey==1311) out.print("selected");%>>Green Monkey Assembly Vervet 1.1</option>--%>
            </select>
        </div>

        <!-- Section Title -->
        <div class="section-title">
            Which genes would you like to analyze?
        </div>

        <!-- Hidden Form for submissions -->
        <form id="optionForm" action="annotation.html" name="optionForm" method="post" class="hidden-form">
            <input type="hidden" name="mapKey" value="<%=mapKey%>"/>
        </form>

        <!-- Options Grid -->
        <div class="options-grid">


            <!-- Limit by Genes -->
            <div class="option-card" onclick="submitForm('geneList.html')">
                <div class="option-icon">&#128271;</div>
                <div class="option-title">Limit by Genes</div>
                <div class="option-description">Start with a gene list, then pick studies that have expression data for those genes</div>
            </div>

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
