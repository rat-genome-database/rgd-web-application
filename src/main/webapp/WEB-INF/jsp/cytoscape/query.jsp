<%@ taglib prefix="th" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="select" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="java.util.*" %>
<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 4/1/2016
  Time: 10:18 AM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>


<%  String pageTitle =  "InterViewer - Ineraction Query Form";
    String pageDescription ="Cytoscape";
    String headContent = "";%>
<%@ include file="/common/headerarea.jsp"%>
<script src="/rgdweb/js/browser.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
    .iv-header {
        text-align: center;
        padding: 20px 0 10px;
    }
    .iv-header h1 {
        color: #24609c;
        font-size: 28px;
        margin: 0 0 5px;
    }
    .iv-header p {
        color: #666;
        font-size: 14px;
        margin: 0;
    }
    .iv-panel {
        max-width: 900px;
        margin: 20px auto;
        background: white;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        overflow: hidden;
    }
    .iv-panel-heading {
        background: #24609c;
        color: white;
        padding: 15px 25px;
        font-size: 18px;
        font-weight: 600;
    }
    .iv-panel-body {
        padding: 25px;
    }
    .iv-form-row {
        display: flex;
        flex-wrap: wrap;
        gap: 25px;
        margin-bottom: 20px;
    }
    .iv-form-col {
        flex: 1;
        min-width: 260px;
    }
    .iv-label {
        display: block;
        font-weight: 600;
        color: #24609c;
        margin-bottom: 8px;
        font-size: 14px;
    }
    .iv-help {
        color: #666;
        font-size: 13px;
        margin-bottom: 8px;
    }
    .iv-select,
    .iv-textarea {
        width: 100%;
        padding: 10px 12px;
        border: 1px solid #ccc;
        border-radius: 6px;
        font-size: 14px;
        box-sizing: border-box;
        font-family: inherit;
    }
    .iv-textarea {
        min-height: 220px;
        resize: vertical;
    }
    .iv-select:focus,
    .iv-textarea:focus {
        outline: none;
        border-color: #24609c;
        box-shadow: 0 0 0 3px rgba(36,96,156,0.15);
    }
    .iv-id-types {
        background: #f0f7ff;
        border: 1px solid #cfe0f5;
        border-radius: 8px;
        padding: 12px 15px;
        margin-top: 10px;
    }
    .iv-id-types .iv-id-title {
        font-weight: 700;
        color: #24609c;
        font-size: 13px;
        margin-bottom: 6px;
    }
    .iv-id-types ul {
        margin: 0;
        padding-left: 18px;
        font-size: 12px;
        color: #555;
    }
    .iv-example {
        font-size: 12px;
        color: #666;
        font-style: italic;
        margin-bottom: 6px;
    }
    .iv-actions {
        display: flex;
        justify-content: center;
        margin-top: 10px;
    }
    .iv-btn {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        padding: 12px 30px;
        border: none;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 600;
        cursor: pointer;
        background: #28a745;
        color: white;
        transition: all 0.2s;
    }
    .iv-btn:hover {
        background: #218838;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(40,167,69,0.3);
    }
    .iv-msg {
        max-width: 900px;
        margin: 15px auto;
        padding: 12px 20px;
        background: #fff3cd;
        border: 1px solid #ffeeba;
        border-left: 4px solid #f0ad4e;
        border-radius: 6px;
        color: #856404;
        font-weight: 500;
    }
    .iv-secondary-panel {
        max-width: 900px;
        margin: 20px auto;
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }
    .iv-secondary-card {
        background: white;
        border-radius: 10px;
        box-shadow: 0 1px 4px rgba(0,0,0,0.08);
        padding: 20px;
    }
    .iv-secondary-card h3 {
        color: #24609c;
        margin: 0 0 10px;
        font-size: 16px;
    }
    .iv-secondary-card a {
        color: #24609c;
        font-weight: 600;
        text-decoration: none;
    }
    .iv-secondary-card a:hover {
        text-decoration: underline;
    }
    @media (max-width: 700px) {
        .iv-secondary-panel { grid-template-columns: 1fr; }
    }
</style>

<%
    HashMap<Integer, String> speciesTypes = new HashMap<>();
    speciesTypes.put(0, "All");
    speciesTypes.put(1, "Human");
    speciesTypes.put(2, "Mouse");
    speciesTypes.put(3, "Rat");
    speciesTypes.put(6, "Dog");
    speciesTypes.put(9, "Pig");
    int species = 0;

    try {
        species = Integer.parseInt(request.getParameter("species"));
        if(speciesTypes.get(species)==null)
            species=0;
    }catch (Exception ignored) {

    }
%>

<div class="iv-header">
    <h1><i class="fas fa-project-diagram"></i> InterViewer</h1>
    <p>Protein Interactions - query and visualize binary interactions across species</p>
</div>

<c:if test="${not empty msg}">
    <div class="iv-msg"><c:out value="${msg}"/></div>
</c:if>
<c:if test="${not empty model.msg}">
    <div class="iv-msg"><c:out value="${model.msg}"/></div>
</c:if>
<c:if test="${not empty model.log}">
    <div class="iv-msg">
        <c:forEach items="${model.log}" var="i">
            <div>${i}</div>
        </c:forEach>
    </div>
</c:if>

<form id="query" method="post" action="cy.html">
    <input type="hidden" name="browser" id="browser">

    <div class="iv-panel">
        <div class="iv-panel-heading">Query Protein Interactions</div>
        <div class="iv-panel-body">
            <div class="iv-form-row">
                <div class="iv-form-col" style="max-width: 260px;">
                    <label class="iv-label" for="species">Species</label>
                    <select class="iv-select" name="species" id="species">
                        <c:choose>
                            <c:when test="${model.species!=null}">
                                <c:forEach items="${model.speciesList}" var="val">
                                    <c:if test="${val==model.species}">
                                        <option value="${model.species}" SELECTED>${model.speciesType}</option>
                                    </c:if>
                                    <c:if test="${val==1 && val!=model.species}"><option value="${val}">Human</option></c:if>
                                    <c:if test="${val==2 && val!=model.species}"><option value="${val}">Mouse</option></c:if>
                                    <c:if test="${val==3 && val!=model.species}"><option value="${val}">Rat</option></c:if>
                                    <c:if test="${val==6 && val!=model.species}"><option value="${val}">Dog</option></c:if>
                                    <c:if test="${val==9 && val!=model.species}"><option value="${val}">Pig</option></c:if>
                                    <c:if test="${val==0 && val!=model.species}"><option value="${val}">ALL</option></c:if>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <%
                                for (Integer key : speciesTypes.keySet()){
                                    if(key == species){ %>
                                        <option value="<%=key%>" SELECTED><%=speciesTypes.get(key)%></option>
                                <%  } else { %>
                                        <option value="<%=key%>"><%=speciesTypes.get(key)%></option>
                                <%  } } %>
                            </c:otherwise>
                        </c:choose>
                    </select>

                    <div class="iv-id-types">
                        <div class="iv-id-title">Valid identifier types</div>
                        <ul>
                            <li>UniProtKB</li>
                            <li>Gene RGD ID</li>
                            <li>Gene Symbol</li>
                        </ul>
                    </div>
                </div>

                <div class="iv-form-col">
                    <label class="iv-label" for="identifiers">Protein Identifiers</label>
                    <div class="iv-help">Enter one or more identifiers, separated by commas, spaces, tabs, or line feeds.</div>
                    <div class="iv-example">Example: P35900, P26769, Q03343</div>
                    <c:choose>
                        <c:when test="${model.symbolList!=null}">
                            <textarea class="iv-textarea" id="identifiers" name="identifiers" rows="12">${model.symbolList}</textarea>
                        </c:when>
                        <c:otherwise>
                            <textarea class="iv-textarea" id="identifiers" name="identifiers" rows="12"
                                      placeholder="e.g. P35900, P26769, Q03343"></textarea>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <div class="iv-actions">
                <button type="submit" class="iv-btn"><i class="fas fa-search"></i> Submit Query</button>
            </div>
        </div>
    </div>
</form>

<div class="iv-secondary-panel">
    <div class="iv-secondary-card">
        <h3><i class="fas fa-download"></i> Bulk Downloads</h3>
        <p style="font-size:13px; color:#555; margin:0 0 8px;">Download every binary interaction by species.</p>
        <a href="ftp://ftp.rgd.mcw.edu/pub/data_release/interactions/" target="_blank">Open FTP directory <i class="fas fa-external-link-alt" style="font-size:11px;"></i></a>
    </div>
    <div class="iv-secondary-card">
        <h3><i class="fas fa-list"></i> Browse Rat Interactions</h3>
        <p style="font-size:13px; color:#555; margin:0 0 8px;">Full report of every rat interaction in RGD.</p>
        <a href="report.html?species=Rat">Browse all Rat interactions</a>
    </div>
</div>

<%@ include file="/common/footerarea.jsp"%>
