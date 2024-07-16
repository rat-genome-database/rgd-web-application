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

<h1 style="text-align: center;padding-top: 45px">The Hybrid Rat Diversity Panel</h1>
<div style="text-align: end;">
    <button id="btn-contact">
        <a class="here" href="mailto:HRDP@mcw.edu?subject=HRDP inquiry" style="text-decoration: none">Contact HRDP</a>
    </button>
</div>
<div style="text-align: center;padding-top: 50px">
    <img src="/rgdweb/common/images/hrdp/hrdp.png" alt="hrdp image">
</div>
<div style="margin-left: 15px;margin-top: 15px">
<%--    <p style="padding-top: 10px">--%>
<%--        The Hybrid Rat Diversity Panel (HRDP) is a panel of 96 inbred rat strains carefully chosen to maximize power to detect specific genetic loci associated with a complex trait and to maximize the genetic diversity among strains. The HRDP includes 33 genetically diverse inbred strains of rat and two panels of recombinant inbred rat strains, the FXLE/LEXF (33 strains) from Japan and the HXB/BXH (30 strains) from the Czech Republic.--%>
<%--        Recombinant inbred strains are panels of inbred strains derived from two inbred parental rat strains. The two parental strains are crossed to produce F1 pups. F1 pups are subsequently intercrossed to create an F2 generation.--%>
<%--        These genetically unique F2 generation rats are paired as founders and brother-sister mated for at least 20 generations to fix their genomes. The two RI panels used in the HRDP have been well characterized through studies focused on seizures, epilepsy, lymphoma and leukemia, blood pressure regulation, metabolic syndrome, and alcohol consumption.--%>
<%--    </p>--%>
<%--    <p>--%>
<%--        The HXB/BXH recombinant inbred strains were derived from the Spontaneously Hypertensive Rat (SHR/Olalpcv) and the normotensive BN-Lx (BN-Lx/Cub), a Brown Norway congenic rat strain with polydactyly-luxate syndrome.--%>
<%--        The FXLE x LEXF recombinant inbred strains were derived from the Long Evans strain (LE/Stm) and the Fischer F344 strain (F344/Stm).--%>
<%--    </p>--%>
<%--    <p>--%>
<%--        <b>Notes:</b>--%>
<%--    <ul style="margin-top: -10px">--%>
<%--        <li>--%>
<%--            In the tables below, an asterisk (*) designates that the tagged strain has been sequenced. The VCF files for these (48 strains in total) are available for download.--%>
<%--            These data have been mapped to both Rn6 and Rn7 and can be accessed <a class="here" href="https://download.rgd.mcw.edu/strain_specific_variants/Dwinell_MCW_HybridRatDiversityProgram/Dec2021/?_gl=1*umtyp9*_ga*OTEwNTM3NjMyLjE2OTg2ODE3MzM.*_ga_BTF869XJFG*MTcwOTIxODk0Ni4xNi4xLjE3MDkyMTkzOTcuMC4wLjA">here</a>.--%>
<%--        </li>--%>
<%--        <br>--%>
<%--        <li>--%>
<%--            The double dagger icons (<strong>&#8225;</strong>) designate the strains that have been found by whole genome sequence comparison to be the most genetically similar to the Heterogeneous Stock (HS) Founder Strains. This data is courtesy of Dr. Abraham Palmer (University of California, San Diego) and Dr. Hao Chen (University of Tennessee Health Sciences Center).--%>
<%--            For more information about the HS Founders and the HRDP strains that are similar to them, <a class="here" href="https://rgd.mcw.edu/wg/hrdp_panel/hrdp-to-hs-founder-strain-genetic-similarity/">click here</a>.--%>
<%--        </li>--%>
<%--        <br>--%>
<%--        <li>--%>
<%--            The inbred Wistar WN/N strain is no longer available and no closely related substrains are included in the HRDP panel. However, DNA from a frozen tissue sample from the original NIH strain has been sequenced and that sequence compared to WGS from the HRDP strains. Of the strains currently available from the HRDP, the one found in this analysis to be most closely related to WN/N is WAG/RijCrl with a sequence similarity of approximately 76%.--%>
<%--        </li>--%>
<%--    </ul>--%>
    <div class="hrdpContent">
    <h3>What is the Hybrid Rat Diversity Panel (HRDP)?</h3>
    <br>
    <ul>
        <li>Panel of 96 inbred rat strains with genetic and phenotypic diversity
            <ul>
                <br>
                <li>33 genetically diverse “classic” inbred strains</li>
                <br>
                <li>Two recombinant inbred (RI) panels: FXLE/LEXF (33 strains, Japan) and HXB/BXH (30 strains, Czech Republic)
                    <ul>
                        <br>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=7244374">FXLE/Stm</a></li>
                        <br>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=629500">LEXF/Stm</a></li>
                        <br>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=61098">BXH/Ipcv</a></li>
                        <br>
                        <li><a class="here" href="/rgdweb/report/strain/main.html?id=61099">HXB/Ipcv</a></li>
                    </ul>
                </li>
                <br>
                <li>To learn more about recombinant inbred strains, <a class="here" href="https://www.informatics.jax.org/mgihome/nomen/strains.shtml#ris">click here</a></li>
            </ul>
        </li>
    </ul>
    <br>
    <h3>What resources are available for the HRDP?</h3>
    <ul>
        <br>
        <li>
            Many of the HRDP strains are currently available for experiments. <a class="here" href="mailto:HRDP@mcw.edu?subject=HRDP inquiry">Contact HRDP</a> for details.
        </li>
        <br>
        <li>
            Whole genome sequence data (VCF files for download, variants integrated into Variant Visualizer)
        </li>
        <br>
        <li>
           Quantitative phenotype measurements can be explored through PhenoMiner
        </li>
    </ul>
    <br>
    <h3>How do the HRDP strains relate to the Heterogenous Stock (HS) founder strains?</h3>
    <ul>
        <br>
        <li>
            Based on sequence similarity, the best match from the HRDP inbred strains has been identified for each of the HS founder strains.
        </li>
        <br>
        <li>For more information about the HRDP strains matched to the HS founders, <a class="here" href="https://rgd.mcw.edu/wg/hrdp_panel/hrdp-to-hs-founder-strain-genetic-similarity/">click here</a>
        </li>
    </ul>
    </div>
    <br>
    <br>
    <%if(hrdpClassicInbredStrains!=null||hrdpHXBStrains!=null||hrdpFXLEStrains!=null){%>
    <span><strong>The strains included in the HRDP panel are:</strong></span>
    </p>
    <form id="hrdpForm" method="post">
        <%if (hrdpClassicInbredStrains!=null) {%>
        <div class="legend">
            <div><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick">- Data for listed strains exist and related strains may exist.</div>
            <div><img src="/rgdweb/common/images/hrdp/redtick.png" alt="redtick">- No data available.</div>
        </div>
        <div class="centered">
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
                    <td style="text-align: center;"><input type="checkbox" name="rgdId" value="<%=str.getStrainId()%>"></td>
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
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/yellowcheck.png" alt="yellowtick"></td>
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
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/yellowcheck.png" alt="yellowtick"></td>
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
                <td style="text-align: center;"><input type="checkbox" name="rgdId" value="<%=str.getStrainId()%>"></td>
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
                <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/yellowcheck.png" alt="yellowtick"></td>
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
                <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/yellowcheck.png" alt="yellowtick"></td>
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
                    <td style="text-align: center;"><input type="checkbox" name="rgdId" value="<%=str.getStrainId()%>"></td>
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
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/yellowcheck.png" alt="yellowtick"></td>
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
                    <td style="text-align: center"><img src="/rgdweb/common/images/hrdp/yellowcheck.png" alt="yellowtick"></td>
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
            <input type="submit" class="btn-analyze fixed-bottom-center hidden" value="Analyze" style="color: white; font-size: 11pt" onclick="showWindow()">
        </div>
        <%}%>
        <!-- Popup window structure -->
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
    </form>
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

        document.getElementById("noDataMessage").style.display=!hasPhenominerData&&!hasVariantVisualizerData?'block':'none'
        document.getElementById("optionsModal").style.display='block'

    }

    function closeWindow(){
        document.getElementById("optionsModal").style.display='none'
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
            document.getElementById("optionsModal").style.display = "none";
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

    document.querySelector(".close-button").addEventListener("click",closeWindow);

    document.querySelectorAll('input[type="checkbox"][name="rgdId"]').forEach(checkbox => {
        checkbox.addEventListener("change", toggleAnalyzeButton);
    });

    // //responsible for enabling anaylze button when the user navigates to other pages and come back to hrdp page
    window.onload = function() {
        toggleAnalyzeButton(); // Check the state of checkboxes and update button visibility
    };


</script>