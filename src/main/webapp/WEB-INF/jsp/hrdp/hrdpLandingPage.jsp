<%--
Created by IntelliJ IDEA.
User: akundurthi
Date: 2/28/2024
Time: 1:41 PM
To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.dao.spring.StringMapQuery" %>
<%@ include file="/WEB-INF/jsp/report/dao.jsp" %>
<%
    String pageTitle = "Hybrid Rat Diversity Panel Portal";
    String headContent = "";
    String pageDescription = "Hybrid Rat Diversity Panel Portal";
%>
<%@ include file="/common/headerarea.jsp"%>
<%

    HrdpPortalCacheDAO cacheDAO = new HrdpPortalCacheDAO();
    List<HrdpPortalCache>hrdpClassicInbredStrains=null;
    List<HrdpPortalCache>hrdpHXBStrains = null;
    List<HrdpPortalCache>hrdpFXLEStrains = null;
    try {
        hrdpClassicInbredStrains = cacheDAO.getHrdpStrainsByGroupName("Classic Inbred Strains");
    }
    catch (Exception ingore){}
    try{
        hrdpHXBStrains = cacheDAO.getHrdpStrainsByGroupName("HXB/BXH Recombinant Inbred Panel");
    }
    catch (Exception ingore){}
    try{
        hrdpFXLEStrains = cacheDAO.getHrdpStrainsByGroupName("FXLE/LEXF Recombinant Inbred Panel");
    }
    catch (Exception ingore){}
%>
<link rel="stylesheet" type="text/css" href="css/hrdp/hrdpStyling.css">

<div style="margin-left: 15px;margin-top: 15px">
    <div class="hrdpContent">
    <div class="hrdp-header">
        <h1>The Hybrid Rat Diversity Panel</h1>
        <button id="btn-contact">
            <a class="here" href="mailto:HRDP@mcw.edu?subject=HRDP inquiry" style="text-decoration: none">Contact HRDP</a>
        </button>
    </div>
    <div class="hrdp-img-container">
        <a title="Click here to jump to strain listing" href="#strainList"><img src="/rgdweb/common/images/hrdp/hrdp.png?1" alt="hrdp image" class="hrdp-main-img"></a>
    </div>
    <h3>What is the Hybrid Rat Diversity Panel (HRDP)?</h3>
    <ul>
        <li>Panel of 96 inbred rat strains with genetic and phenotypic diversity
            <ul>
                <li>33 genetically diverse "classic" inbred strains</li>
                <li>Two recombinant inbred (RI) panels: FXLE/LEXF (33 strains, Japan) and HXB/BXH (30 strains, Czech Republic). To learn more about recombinant inbred strains, <a class="here" href="https://www.informatics.jax.org/mgihome/nomen/strains.shtml?#ris">click here</a>.
                    <ul class="horizontal-list">
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=7244374">FXLE/Stm</a></li>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=629500">LEXF/Stm</a></li>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=61098">BXH/Ipcv</a></li>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=61099">HXB/Ipcv</a></li>
                    </ul>
                </li>
                <li>
                    A Mini-HRDP panel – 8 classic inbred strains including the RI progenitor strains.
                    <ul class="horizontal-list">
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=631848">SHR/OlaIpcv</a></li>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=61498">BN/NHsdMcwi</a></li>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=1302686">F344/Stm</a></li>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=629485">LE/Stm</a></li>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=1358112">WKY/NCrl</a></li>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=10395297">GK/FarMcwi</a></li>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=61499">SS/JrHsdMcwi</a></li>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=7364991">ACI/EurMcwi</a></li>
                    </ul>
                </li>
            </ul>
        </li>
    </ul>
    <h3>What resources are available for the HRDP?</h3>
    <ul>
        <li>
            Many of the HRDP strains are currently available for experiments. <a class="here" href="mailto:HRDP@mcw.edu?subject=HRDP inquiry">Contact HRDP</a> for details.
        </li>
        <li>
           Quantitative phenotype measurements can be explored through <a class="here" href="/rgdweb/phenominer/ontChoices.html?species=3">PhenoMiner</a>
        </li>
        <li>
            Whole genome sequence data (<a class="here" target="_blank" href="https://download.rgd.mcw.edu/strain_specific_variants/Dwinell_MCW_HybridRatDiversityProgram/">VCF files for download</a>, variants integrated into <a class="here" target="_blank" href="/rgdweb/front/config.html">Variant Visualizer</a>)
        </li>
        <li>
            Whole Brain, heart, liver and kidney RNA expression levels – <a class="here" target="_blank" href="https://phenogen.org/">PhenoGen Informatics</a>
            <ul>
                <li>
                    <a class="here" target="_blank" href="https://genome.ucsc.edu/cgi-bin/hgTracks?db=rn7&lastVirtModeType=default&lastVirtModeExtraState=&virtModeType=default&virtMode=0&nonVirtPosition=&position=chr1%3A79348972%2D79379997&hgsid=3232894521_B0iMbE5Oq9ZuQpWJAmAGV0sJNEWk">
                        UCSC&nbsp;Track&nbsp;Hubs
                    </a>
                </li>
                <li>
                    <a class="here" target="_blank" href="https://phenogen.org/web/sysbio/resources.jsp">
                        Download</a>
                    RNA-Seq&nbsp;Data&nbsp;from&nbsp;PhenoGen&nbsp;Informatics
                </li>
            </ul>
        </li>
        <li>
            <a class="here" target="_blank" href="<%= (RgdContext.isDev() || RgdContext.isTest()) ? "https://pipelines.rgd.mcw.edu" : ""
  %>/jbrowse2/?loc=Chr4:12315270-14781251&assembly=mRatBN7.2&tracklist=true&tracks=RNAseq_Gastrocnemius_BN_Lx_CubMcwi_F">HRDP Expression Profiles on JBrowse 2</a>
        </li>
    </ul>
        <h3>How can the HRDP resources be leveraged for New Approach Methodologies (NAMs)?</h3>
        <ul>
            <li>
                <img src="/rgdweb/common/images/hrdp/Mini-HRDP.png" alt="Mini-HRDP and HS Founder Best Match" class="mini-hrdp-img">
                Well characterized subsets of HRDP strains can be used to complement, benchmark, and validate human disease mechanisms. Two important subsets include the mini-HRDP and the Heterogeneous Stock (HS) founder strains. <b>Use of these smaller panels can reduce the use of animals through focused pre-clinical studies</b>.
                <ul>
                    <li>
                        Both subsets capture genetic and phenotypic variability of the full HRDP.
                    </li>
                    <li>
                        Mini-HRDP includes 8 strains suitable for most experimental protocols, including behavioral assays and the progenitors for the two recombinant inbred panels.
                    </li>
                    <li>
                        The HS founder strains are the strains that most closely represent the 8 inbred strains used to create the Heterogeneous Stock outbred population.
                    </li>
                </ul>
            </li>
            <li>
                The wealth of available genomic and phenotypic data for the HRDP strains can be used to <b>validate NAMs data</b>. PhenoMiner and Variant Visualizer can be used to explore and access the data.
            </li>
            <li>
                Data is available for download for use in <b>computational models</b>.
            </li>
        </ul>
    <h3>How do the HRDP strains relate to the Heterogenous Stock (HS) founder strains?</h3>
    <ul>
        <li>
            Based on sequence similarity, the best match from the HRDP inbred strains has been identified for each of the HS founder strains.
        </li>
        <li>For more information about the HRDP strains matched to the HS founders, <a class="here" href="https://rgd.mcw.edu/wg/hrdp_panel/hrdp-to-hs-founder-strain-genetic-similarity/">click here</a>
        </li>
    </ul>
    </div>
    <br>
    <a id="strainList"></a>
    <br>
    <%if(hrdpClassicInbredStrains!=null||hrdpHXBStrains!=null||hrdpFXLEStrains!=null){%>
    <span><strong>HRDP strains are listed below. To explore PhenoMiner or Variant Visualizer data, check strain(s) and "analyze".</strong></span>
    </p>
    <form id="hrdpForm" method="post" target="_blank">
        <%if (hrdpClassicInbredStrains!=null) {%>
        <div class="centered">
            <div class="legend">
                <div><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick">- Data for listed strains exist and related strains may exist.</div>
                <div><img src="/rgdweb/common/images/hrdp/redtick.png" alt="redtick">- No data available.</div>
            </div>
            <table  class="hrdpTable">
                <thead>
                <tr><th colspan="5" class="table-heading">Classic&nbsp;Inbred&nbsp;Strains</th></tr>
                <tr>
                    <th style="text-align: center;"><input type="checkbox" onclick="toggleAllCheckboxes(this, 'hrdpTable')"></th>
                    <th>Strain</th>
                    <th>Strain Available</th>
                    <th>Phenominer Data</th>
                    <th>Variant Visualizer Data</th>
<%--                    <th></th>--%>
                </tr>
                </thead>
                <tbody>
                <%for (HrdpPortalCache str : hrdpClassicInbredStrains) {%>
                <tr data-has-phenominer="<%=str.getHasPhenominer()>0%>" data-has-variant-visualizer="<%=str.getHasVariantVisualizer()>0%>">
                    <td style="text-align: center;"><input type="checkbox" name="rgdId" value="<%=str.getStrainId()%>" data-strain-symbol="<%=str.getStrainSymbol()%>"></td>
                    <td><a class="here"href="report/strain/main.html?id=<%=str.getStrainId()%>"><%=str.getStrainSymbol()%></a></td>
                    <% if (str.getAvailableStrainId() != null && !str.getAvailableStrainId().isEmpty()) {
                        String[] ids = str.getAvailableStrainId().split(",");
                        String[] symbols = str.getAvailableStrainSymbol().split(",");
                        StringBuilder linksBuilder = new StringBuilder();
                        for(int i=0;i<ids.length;i++){
                            if (i > 0) {
                                linksBuilder.append(", "); // Add a comma before each link except the first
                            }
                            // Append each link. Ensure that IDs and Symbols are aligned by index.
                            linksBuilder.append("<a class='here' href='report/strain/main.html?id=")
                                    .append(ids[i].trim())
                                    .append("'>")
                                    .append(symbols[i].trim())
                                    .append("</a>");
                        }
                        if(linksBuilder.length()>0){%>
                    <td><%=linksBuilder.toString()%></td>
                    <%}else{%>
                    <td></td>
                    <%}%>
                    <%}else{%>
                    <td></td>
                    <%}%>
                    <%if (str.getHasParentPhenoCount()>0) {%>
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick"></td>
                    <td style="display: none;">
                        <input type="hidden" class="ontIdInput" name="ontId" value="<%=str.getParentOntId()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                    </td>
                    <%if(str.getHasChildPhenoCount()>0){%>
                    <td style="display: none;">
                        <input type="hidden" class="childOntIdInput" name="childontId" value="<%=str.getChildOntIds()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                    </td>
                    <%}
                    }else if(str.getHasParentPhenoCount()==0 && str.getHasChildPhenoCount()>0){%>
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick"></td>
                    <td style="display: none;">
                        <input type="hidden" class="childOntIdInput" name="childontId" value="<%=str.getChildOntIds()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                    </td>
                    <%} else {%>
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/redtick.png" alt="redtick"></td>
                    <%}%>
                    <%if (str.getHasParentSampleCount()>0) {%>
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick"></td>
                    <td style="display: none;">
                        <input type="hidden" class="sampleInput" name="sampleIds" value="<%= str.getParentSampleIds()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                    </td>
                    <%if(str.getHasChildSampleCount()>0){%>
                    <input type="hidden" class="sampleChildInput" name="sampleChildIds" value="<%= str.getChildSampleIds() %>" disabled data-rgdid="<%=str.getStrainId()%>">
                    <%}
                    }
                    else if (str.getHasParentSampleCount()==0&&str.getHasChildSampleCount()>0) {%>
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick"></td>
                    <input type="hidden" class="sampleChildInput" name="sampleChildIds" value="<%=str.getChildSampleIds()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                    <%}
                    else {%>
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/redtick.png" alt="redtick"></td>
                    <%}%>

<%--                    <td><a class="here" title="Click to View Strain Report"href="report/strain/main.html?id=<%=str.getStrainId()%>">View&nbsp;Strain Report</a></td>--%>
                </tr>
                <%}%>
                </tbody>
            </table>
        </div>
        <%}%>
        <div class="side-by-side">
            <%if (hrdpHXBStrains!=null) {%>
            <table class="hrdpTable">
                <thead>
                <tr><th colspan="5" class="table-heading">HXB/BXH&nbsp;Recombinant&nbsp;Inbred&nbsp;Panel&nbsp;Strains</th></tr>
                <tr>
                    <th style="text-align: center"><input type="checkbox" onclick="toggleAllCheckboxes(this, 'hrdpTable')"></th>
                    <th>Strain</th>
                    <th>Strain Available</th>
                    <th>Phenominer Data</th>
                    <th>Variant Visualizer Data</th>
<%--                    <th></th>--%>
                </tr>
                </thead>
                <tbody>
                <%for (HrdpPortalCache str : hrdpHXBStrains) {%>
                <tr data-has-phenominer="<%=str.getHasPhenominer()>0%>" data-has-variant-visualizer="<%=str.getHasVariantVisualizer()>0%>">
                <td style="text-align: center;"><input type="checkbox" name="rgdId" value="<%=str.getStrainId()%>" data-strain-symbol="<%=str.getStrainSymbol()%>"></td>
                <td><a class="here" href="report/strain/main.html?id=<%=str.getStrainId()%>"><%=str.getStrainSymbol()%></a></td>
                    <% if (str.getAvailableStrainId() != null && !str.getAvailableStrainId().isEmpty()) {
                        String[] ids = str.getAvailableStrainId().split(",");
                        String[] symbols = str.getAvailableStrainSymbol().split(",");
                        StringBuilder linksBuilder = new StringBuilder();
                        for(int i=0;i<ids.length;i++){
                            if (i > 0) {
                                linksBuilder.append(", "); // Add a comma before each link except the first
                            }
                            // Append each link. Ensure that IDs and Symbols are aligned by index.
                            linksBuilder.append("<a class='here' href='report/strain/main.html?id=")
                                    .append(ids[i].trim())
                                    .append("'>")
                                    .append(symbols[i].trim())
                                    .append("</a>");
                        }
                        if(linksBuilder.length()>0){%>
                    <td><%=linksBuilder.toString()%></td>
                    <%}else{%>
                    <td></td>
                    <%}%>
                    <%}else{%>
                    <td></td>
                    <%}%>
                <%if (str.getHasParentPhenoCount()>0) {%>
                <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick"></td>
                <td style="display: none;">
                    <input type="hidden" class="ontIdInput" name="ontId" value="<%=str.getParentOntId()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                </td>
                <%if(str.getHasChildPhenoCount()>0){%>
                <td style="display: none;">
                    <input type="hidden" class="childOntIdInput" name="childontId" value="<%=str.getChildOntIds()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                </td>
                <%}
                }else if(str.getHasParentPhenoCount()==0 && str.getHasChildPhenoCount()>0){%>
                <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick"></td>
                <td style="display: none;">
                    <input type="hidden" class="childOntIdInput" name="childontId" value="<%=str.getChildOntIds()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                </td>
                <%} else {%>
                <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/redtick.png" alt="redtick"></td>
                <%}%>
                <%if (str.getHasParentSampleCount()>0) {%>
                <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick"></td>
                <td style="display: none;">
                    <input type="hidden" class="sampleInput" name="sampleIds" value="<%= str.getParentSampleIds()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                </td>
                <%if(str.getHasChildSampleCount()>0){%>
                <input type="hidden" class="sampleChildInput" name="sampleChildIds" value="<%= str.getChildSampleIds() %>" disabled data-rgdid="<%=str.getStrainId()%>">
                <%}
                }
                else if (str.getHasParentSampleCount()==0&&str.getHasChildSampleCount()>0) {%>
                <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick"></td>
                <input type="hidden" class="sampleChildInput" name="sampleChildIds" value="<%=str.getChildSampleIds()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                <%}
                else {%>
                <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/redtick.png" alt="redtick"></td>
                <%}%>

<%--                <td><a class="here" title="Click to View Strain Report"href="report/strain/main.html?id=<%=str.getStrainId()%>">View&nbsp;Strain Report</a></td>--%>
                </tr>
                <%}%>
                </tbody>
            </table>
            <%}%>
            <%if (hrdpFXLEStrains!=null) {
            %>
            <table class="hrdpTable">
                <thead>
                <tr><th colspan="5" class="table-heading" >FXLE/LEXF &nbsp;Recombinant&nbsp;Inbred&nbsp;Panel&nbsp;Strains</th></tr>
                <tr>
                    <th style="text-align: center"><input type="checkbox" onclick="toggleAllCheckboxes(this,'hrdpTable')"></th>
                    <th>Strain</th>
                    <th>Strain Available</th>
                    <th>Phenominer Data</th>
                    <th>Variant Visualizer Data</th>
<%--                    <th></th>--%>
                </tr>
                </thead>
                <tbody>
                <%for (HrdpPortalCache str : hrdpFXLEStrains) {%>
                <tr data-has-phenominer="<%=str.getHasPhenominer()>0%>" data-has-variant-visualizer="<%=str.getHasVariantVisualizer()>0%>">
                    <td style="text-align: center;"><input type="checkbox" name="rgdId" value="<%=str.getStrainId()%>" data-strain-symbol="<%=str.getStrainSymbol()%>"></td>
                    <td><a class="here"href="report/strain/main.html?id=<%=str.getStrainId()%>"><%=str.getStrainSymbol()%></a></td>
                    <% if (str.getAvailableStrainId() != null && !str.getAvailableStrainId().isEmpty()) {
                        String[] ids = str.getAvailableStrainId().split(",");
                        String[] symbols = str.getAvailableStrainSymbol().split(",");
                        StringBuilder linksBuilder = new StringBuilder();
                        for(int i=0;i<ids.length;i++){
                            if (i > 0) {
                                linksBuilder.append(", "); // Add a comma before each link except the first
                            }
                            // Append each link. Ensure that IDs and Symbols are aligned by index.
                            linksBuilder.append("<a class='here' href='report/strain/main.html?id=")
                                    .append(ids[i].trim())
                                    .append("'>")
                                    .append(symbols[i].trim())
                                    .append("</a>");
                        }
                        if(linksBuilder.length()>0){%>
                    <td><%=linksBuilder.toString()%></td>
                    <%}else{%>
                    <td></td>
                    <%}%>
                    <%}else{%>
                    <td></td>
                    <%}%>
                    <%if (str.getHasParentPhenoCount()>0) {%>
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick"></td>
                    <td style="display: none;">
                        <input type="hidden" class="ontIdInput" name="ontId" value="<%=str.getParentOntId()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                    </td>
                    <%if(str.getHasChildPhenoCount()>0){%>
                    <td style="display: none;">
                        <input type="hidden" class="childOntIdInput" name="childontId" value="<%=str.getChildOntIds()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                    </td>
                    <%}
                    }else if(str.getHasParentPhenoCount()==0 && str.getHasChildPhenoCount()>0){%>
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick"></td>
                    <td style="display: none;">
                        <input type="hidden" class="childOntIdInput" name="childontId" value="<%=str.getChildOntIds()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                    </td>
                    <%} else {%>
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/redtick.png" alt="redtick"></td>
                    <%}%>
                    <%if (str.getHasParentSampleCount()>0) {%>
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick"></td>
                    <td style="display: none;">
                        <input type="hidden" class="sampleInput" name="sampleIds" value="<%= str.getParentSampleIds()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                    </td>
                    <%if(str.getHasChildSampleCount()>0){%>
                    <input type="hidden" class="sampleChildInput" name="sampleChildIds" value="<%= str.getChildSampleIds() %>" disabled data-rgdid="<%=str.getStrainId()%>">
                    <%}
                    }
                    else if (str.getHasParentSampleCount()==0&&str.getHasChildSampleCount()>0) {%>
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick"></td>
                    <input type="hidden" class="sampleChildInput" name="sampleChildIds" value="<%=str.getChildSampleIds()%>" disabled data-rgdid="<%=str.getStrainId()%>">
                    <%}
                    else {%>
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/redtick.png" alt="redtick"></td>
                    <%}%>

<%--                    <td><a class="here" title="Click to View Strain Report"href="report/strain/main.html?id=<%=str.getStrainId()%>">View&nbsp;Strain Report</a></td>--%>
                </tr>
                <%}%>
                </tbody>
            </table>
            <%}%>
        </div>
        <div style="text-align: center;padding-top: 30px;">
            <input type="hidden" name="userChoice" id="userChoice" value="">
            <input type="submit" class="btn-analyze fixed-bottom-center hidden" value="Analyze" style="color: white; font-size: 11pt" onclick="showSelectedStrains()">
        </div>
        <%}%>
        <!-- Popup window structure of options -->
        <div id="optionsModal" class="modal-hrdp">
            <div class="modal-content-hrdp">
                <div class="modal-header-hrdp">
                    <h3>Analyze Strain List</h3>
                    <span class="close-button">&times;</span>
                </div>
                <hr>
                <table class="options-table">
                    <tr>
                        <td onclick="optionSelected('phenominer');">
                            <img src="/rgdweb/common/images/phenominerNew.png" alt="Phenominer Data" />
                            <p>Phenominer</p>
                        </td>
                        <td onclick="optionSelected('variantVisualizer');">
                            <img src="/rgdweb/common/images/variantVisualizer.png" alt="Variant Visualizer" />
                            <p>Variant Visualizer</p>
                        </td>
                        <td id="noDataMessage" style="display: none">No data available for the selected strains.</td>
                    </tr>
                    <!-- Add more rows and cells as needed for additional options -->

                </table>
            </div>
        </div>

<%--        Modal Structure of Strains Selected--%>
        <div id="selectedStrainsModal" class="modal-hrdp">
            <div class="modal-content-hrdp-strain-selected">
                <div class="modal-header-hrdp">
                    <h3>Selected Strains For Analysis</h3>
                    <span class="close-button" onclick="closeSelectedStrainsModal()">&times;</span>
                </div>
                <hr>
                <ul id="selectedStrainsList">
                    <!-- List items will be dynamically inserted here -->
                </ul>
<%--                <div style="text-align: center;margin-top: 15px">--%>
<%--                <button id="confirmStrainsSelection" class="btn-ok" style="color: white; font-size: 11pt;" onclick="showWindow()">Proceed</button>--%>
<%--                </div>--%>
                <div style="text-align: center; margin-top: 15px; display: flex; justify-content: center;">
                    <button id="cancelStrainsSelection" class="btn-cancel" style="color: white; font-size: 11pt; margin-right: 10px;" onclick="closeSelectedStrainsModal()">Cancel</button>
                    <button id="confirmStrainsSelection" class="btn-ok" style="color: white; font-size: 11pt;" onclick="showWindow()">Proceed</button>
                </div>


            </div>
        </div>
    </form>
</div>

<div style="margin-left: 15px; margin-top: 20px; margin-bottom: 20px;">
    <div class="hrdpContent">
    <h3>References</h3>
    <ul>
        <%
            // Reference data - different RGD IDs for dev vs pipelines/prod
            String[][] hrdpRefs;
            if (RgdContext.isDev() || request.getServerName().contains("localhost")) {
                hrdpRefs = new String[][] {
                    {"39907792", "640030560"},
                    {"36186443", "401959584"},
                    {"31228159", "640030561"}
                };
            } else {
                hrdpRefs = new String[][] {
                    {"39907792", "632517862"},
                    {"36186443", "401959584"},
                    {"31228159", "632517863"}
                };
            }
            ReferenceDAO refDAO = new ReferenceDAO();
            for (String[] refData : hrdpRefs) {
                String pmId = refData[0];
                String rgdId = refData[1];
                try {
                    Reference ref = refDAO.getReferenceByRgdId(Integer.parseInt(rgdId));
                    if (ref != null) {
        %>
        <li>
            <b><%=ref.getTitle()%></b><br>
            <%=ref.getCitation()%>
            PMID: <a class="here" target="_blank" href="https://www.ncbi.nlm.nih.gov/pubmed/<%=pmId%>"><%=pmId%></a>,
            RGD ID: <a class="here" href="/rgdweb/report/reference/main.html?id=<%=rgdId%>"><%=rgdId%></a>
        </li>
        <%
                    }
                } catch (Exception e) {
                    // Reference doesn't exist in this environment yet, skip it
                }
            }
        %>
    </ul>
    </div>
</div>

<%@ include file="/common/footerarea.jsp"%>

<script type="text/javascript">

    function toggleAllCheckboxes(toggleAllCheckbox){
        let table = toggleAllCheckbox.closest('table')
        let checkboxes = table.querySelectorAll('input[type="checkbox"][name="rgdId"]')

        checkboxes.forEach(function(checkbox){
            checkbox.checked = toggleAllCheckbox.checked;
        })

        toggleAnalyzeButton();
    }

    function validateForm(){
        let isAnyCheckboxChecked = false
        let checkboxes = document.querySelectorAll('input[type="checkbox"][name="rgdId"]')

        checkboxes.forEach(function (checkbox){
            if(checkbox.checked){
                isAnyCheckboxChecked = true
            }
        })
        if (!isAnyCheckboxChecked) {
            return false;
        }
        return true;
    }

    function showWindow(){
        if(!validateForm()) return false;

        // Determine the availability of Phenominer and Variant Visualizer data among selected strains
        let hasPhenominerData = false;
        let hasVariantVisualizerData = false;

        // Iterate over each selected strain to check for data availability
        document.querySelectorAll('input[type="checkbox"][name="rgdId"]:checked').forEach(function(checkbox) {
            let row = checkbox.closest('tr');
            if (row.dataset.hasPhenominer === 'true') {
                hasPhenominerData = true;
            }
            if (row.dataset.hasVariantVisualizer === 'true') {
                hasVariantVisualizerData = true;
            }
        });

        document.querySelector('td[onclick="optionSelected(\'phenominer\');"]').style.display = hasPhenominerData ? '' : 'none';
        document.querySelector('td[onclick="optionSelected(\'variantVisualizer\');"]').style.display = hasVariantVisualizerData ? '' : 'none';

        document.getElementById("noDataMessage").style.display=!hasPhenominerData&&!hasVariantVisualizerData?'block':'none';

        //close the selected strains modal and open the options modal
        closeSelectedStrainsModal();
        document.getElementById("optionsModal").style.display='block';

    }

    function closeWindow(){
        document.getElementById("optionsModal").style.display='none';
    }


    function optionSelected(option) {
        document.getElementById('userChoice').value = option;
        let checkboxes = document.querySelectorAll('input[type="checkbox"][name="rgdId"]');
        let isAnyCheckboxChecked = false;

        // Disable all inputs initially
        document.querySelectorAll(".ontIdInput, .childOntIdInput, .sampleInput, .sampleChildInput").forEach(input => input.disabled = true);

        checkboxes.forEach(checkbox => {
            if (checkbox.checked) {
                isAnyCheckboxChecked = true;  // Set flag if any checkbox is checked
                // Based on the option, enable relevant inputs for checked checkboxes
                if (option === "phenominer") {
                    enablePhenominerInputs(checkbox.value);
                } else if (option === "variantVisualizer") {
                    enableVariantVisualizerInputs(checkbox.value);
                }
            }
        });

        if (!isAnyCheckboxChecked) {
            alert('Please select at least one strain before analyzing.');
        } else {
            document.getElementById("optionsModal").style.display = "block";
            document.getElementById("hrdpForm").submit();
        }
    }

    function enablePhenominerInputs(rgdId) {
        let ontIdInput = document.querySelector("input.ontIdInput[data-rgdid='" + rgdId + "']");
        let childOntIdInput = document.querySelector("input.childOntIdInput[data-rgdid='" + rgdId + "']");
        if (ontIdInput) ontIdInput.disabled = false;
        if (childOntIdInput) childOntIdInput.disabled = false;
    }

    function enableVariantVisualizerInputs(rgdId) {
        document.querySelectorAll("input.sampleInput[data-rgdid='" + rgdId + "'], " +
            "input.sampleChildInput[data-rgdid='" + rgdId + "']").forEach(input => input.disabled = false);
    }

    function toggleAnalyzeButton(){
        let isAnyCheckboxChecked = [...document.querySelectorAll('input[type="checkbox"][name="rgdId"]')]
            .some(checkbox => checkbox.checked);

        let analyzeButton = document.querySelector(".btn-analyze");
        if (isAnyCheckboxChecked) {
            analyzeButton.classList.remove("hidden");
        } else {
            analyzeButton.classList.add("hidden");
        }

    }

    //code responsible for displaying and closing of selected strains modal
    function showSelectedStrains(){
       let selectedStrains= document.querySelectorAll('input[type="checkbox"][name="rgdId"]:checked');
       let strainList = document.getElementById('selectedStrainsList');
       strainList.innerHTML="";
       let uniqueSymbols = new Set();
       selectedStrains.forEach(function (strain){
          let strainSymbol = strain.getAttribute('data-strain-symbol');
          if(!uniqueSymbols.has(strainSymbol)) {
              uniqueSymbols.add(strainSymbol);
              let listItem = document.createElement("li");
              listItem.textContent = strainSymbol;
              strainList.append(listItem);
          }
       });
        document.getElementById('selectedStrainsModal').style.display = 'block';
    }

    function closeSelectedStrainsModal(){
        document.getElementById('selectedStrainsModal').style.display = 'none';
    }

    document.querySelector(".close-button").addEventListener("click",closeWindow);

    document.querySelectorAll('input[type="checkbox"][name="rgdId"]').forEach(checkbox => {
        checkbox.addEventListener("change", toggleAnalyzeButton);
    });

    // //responsible for enabling anaylze button when the user navigates to other pages and come back to hrdp page
    window.onload = function() {
        toggleAnalyzeButton(); // Check the state of checkboxes and update button visibility
    };


</script>
