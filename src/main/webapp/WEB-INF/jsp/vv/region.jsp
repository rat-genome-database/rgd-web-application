<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.vv.SampleManager" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %>

<%
String pageTitle = "Variant Visualizer (Define Region)";
String headContent = "";
String pageDescription = "Define Region";

%>
<%@ include file="/common/headerarea.jsp" %>
<%@ include file="carpeHeader.jsp"%>
<%@ include file="menuBar.jsp" %>

<style>
    /* Modern Region Page Styles - Light Theme */
    .typerTitle {
        margin-top: 20px;
    }

    .region-container {
        max-width: 900px;
        margin: 20px auto;
        padding: 0 20px 20px 20px;
    }

    .region-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
        padding-bottom: 10px;
        border-bottom: 2px solid rgba(255,255,255,0.3);
    }

    .region-title {
        font-size: 18px;
        font-weight: bold;
        color: #ffffff;
    }

    .region-assembly {
        font-size: 14px;
        color: #b8d4f0;
    }

    .region-instructions {
        background: #e8f4fc;
        border-left: 4px solid #3a7aba;
        padding: 12px 15px;
        margin-bottom: 20px;
        border-radius: 0 4px 4px 0;
        color: #2a4a6a;
        font-size: 13px;
        line-height: 1.5;
    }

    .region-card {
        background: #e8f0f8;
        border: 1px solid #c0d0e0;
        border-radius: 6px;
        padding: 20px;
        margin-bottom: 0;
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

    .form-row {
        display: flex;
        align-items: center;
        gap: 20px;
        flex-wrap: wrap;
    }

    .form-group {
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .form-group label {
        color: #3a5a7a;
        font-size: 13px;
        font-weight: 600;
        white-space: nowrap;
    }

    .form-group input[type="text"],
    .form-group select {
        padding: 8px 12px;
        border: 1px solid #bccada;
        border-radius: 4px;
        background: #f8fafc;
        color: #333;
        font-size: 13px;
    }

    .form-group input[type="text"]:focus,
    .form-group select:focus {
        outline: none;
        border-color: #3a7aba;
        box-shadow: 0 0 0 2px rgba(58, 122, 186, 0.15);
        background: #fff;
    }

    .form-group input[type="text"]::placeholder {
        color: #8899aa;
    }

    .form-group select {
        min-width: 80px;
    }

    .form-group input.position-input {
        width: 140px;
    }

    .form-group input.symbol-input {
        width: 180px;
    }

    .form-actions {
        margin-left: auto;
    }

    /* OR Divider */
    .or-divider {
        display: flex;
        align-items: center;
        margin: 25px 0;
        gap: 15px;
    }

    .or-line {
        flex: 1;
        height: 1px;
        background: linear-gradient(to right, transparent, #bccada, transparent);
    }

    .or-badge {
        background: #3a7aba;
        color: white;
        padding: 6px 16px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: bold;
        letter-spacing: 1px;
    }

    /* Continue Button */
    .continueButtonPrimary {
        font-size: 13px;
        font-weight: bold;
        background: linear-gradient(to bottom, #28a745 0%, #1e7e34 100%);
        color: white;
        border: 1px solid #1e7e34;
        border-radius: 4px;
        padding: 8px 16px;
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
        margin-top: 20px;
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
</style>

<%
    if(request.getParameter("mapKey")!=null && !request.getParameter("mapKey").equals("")){
   int mapKey = Integer.parseInt(request.getParameter("mapKey"));
    MapDAO mdao = new MapDAO();
    Map<String,Integer> chromeSize = mdao.getChromosomeSizes(mapKey);
    Set<String> chrs = chromeSize.keySet();

    String start = "";
    String stop = "";
    if(req.getParameter("start")!=null && !req.getParameter("start").equals("")){
        start=req.getParameter("start");
    }else{
        if(request.getAttribute("start")!=null)
            start= String.valueOf(request.getAttribute("start"));
    }
    if(req.getParameter("stop")!=null && !req.getParameter("stop").equals("")){
        stop=req.getParameter("stop");
    }else{
        if(request.getAttribute("stop")!=null)
            stop= String.valueOf(request.getAttribute("stop"));
    }

    // Count selected strains
    int strainCount = 0;
    for (int i=1; i<1000; i++) {
        if (request.getParameter("sample" + i) != null) {
            strainCount++;
        }
    }
%>

<div class="typerMat">
    <div class="typerTitle"><div class="typerTitleSub">Variant&nbsp;Visualizer</div></div>

    <div class="region-container">
        <!-- Header -->
        <div class="region-header">
            <div class="region-title">Step 2: Define a Region</div>
            <div class="region-assembly"><%=MapManager.getInstance().getMap(mapKey).getName()%> assembly</div>
        </div>

        <!-- Instructions -->
        <div class="region-instructions">
            Define your region of interest using <strong>genomic coordinates</strong> or <strong>gene/SSLP marker bounds</strong>.
            The region must be on a single chromosome and no larger than 30 Mb.
        </div>

        <!-- Position Card -->
        <div class="region-card">
            <div class="card-title">Option 1: Genomic Position</div>
            <form action="config.html" id="optionForm1" name="optionForm">
                <input type="hidden" name="mapKey" value="<%=request.getParameter("mapKey")%>"/>
                <% for (int i=1; i<1000; i++) {
                    if (request.getParameter("sample" + i) != null) { %>
                <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
                <%}} %>

                <div class="form-row">
                    <div class="form-group">
                        <label>Chromosome</label>
                        <select name="chr" id="chr">
                            <% for (String c : chrs) {
                                if (c.startsWith("NW_")) continue;
                                if (c.equals("1")){ %>
                            <option value="<%=c%>" selected><%=c%></option>
                                <% } else { %>
                            <option value="<%=c%>"><%=c%></option>
                                <% }
                            } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Start</label>
                        <input type="text" class="position-input" placeholder="e.g., 1,000,000" id="start" name="start" value="<%=FormUtility.formatThousands(dm.out("start",start))%>" required>
                    </div>
                    <div class="form-group">
                        <label>Stop</label>
                        <input type="text" class="position-input" placeholder="e.g., 2,000,000" id="stop" name="stop" value="<%=FormUtility.formatThousands(dm.out("stop",stop))%>" required>
                    </div>
                    <div class="form-actions">
                        <input class="continueButtonPrimary" type="submit" value="Continue..."/>
                    </div>
                </div>
            </form>
        </div>

        <% if (MapManager.getInstance().getMap(mapKey).getSpeciesTypeKey() == 3) { %>
        <!-- OR Divider -->
        <div class="or-divider">
            <div class="or-line"></div>
            <div class="or-badge">OR</div>
            <div class="or-line"></div>
        </div>

        <!-- Gene/SSLP Bounds Card -->
        <div class="region-card">
            <div class="card-title">Option 2: Gene or SSLP Bounds <span style="font-weight: normal; font-size: 12px; color: #89a;">(must be on same chromosome)</span></div>
            <form action="config.html" id="optionForm2" name="optionForm">
                <input type="hidden" name="mapKey" value="<%=request.getParameter("mapKey")%>"/>
                <% for (int i=1; i<1000; i++) {
                    if (request.getParameter("sample" + i) != null) { %>
                <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
                <%}} %>

                <div class="form-row">
                    <div class="form-group">
                        <label>Symbol 1</label>
                        <input type="text" class="symbol-input" placeholder="e.g., Brca1" name="geneStart" value="<%=dm.out("geneStart",req.getParameter("geneStart"))%>" required/>
                    </div>
                    <div class="form-group">
                        <label>Symbol 2</label>
                        <input type="text" class="symbol-input" placeholder="e.g., Tp53" name="geneStop" value="<%=dm.out("geneStop",req.getParameter("geneStop"))%>" required/>
                    </div>
                    <div class="form-actions">
                        <input class="continueButtonPrimary" type="submit" value="Continue..."/>
                    </div>
                </div>
            </form>
        </div>
        <% } %>

        <!-- Strains Selected Card -->
        <div class="strains-card">
            <div class="strains-header">
                <div class="strains-title">Strains Selected</div>
                <div class="strains-count"><%=strainCount%> strain<%= strainCount != 1 ? "s" : "" %></div>
            </div>
            <div class="strains-list">
                <%
                boolean first = true;
                for (int i=1; i<1000; i++) {
                    if (request.getParameter("sample" + i) != null) {
                        if (!first) { %>, <% }
                        first = false;
                        try {
                            out.print(SampleManager.getInstance().getSampleName(Integer.parseInt(request.getParameter("sample" + i))).getAnalysisName());
                        } catch (Exception e) {}
                    }
                }
                if (first) { %>
                    <span style="color: #667; font-style: italic;">No strains selected</span>
                <% } %>
            </div>
        </div>
    </div>
</div>
<%}%>
<%@ include file="/common/footerarea.jsp" %>
