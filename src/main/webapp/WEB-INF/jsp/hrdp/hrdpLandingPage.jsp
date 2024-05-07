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
<div style="margin-left: 15px;">
    <p style="padding-top: 10px">
        The Hybrid Rat Diversity Panel (HRDP) is a panel of 96 inbred rat strains carefully chosen to maximize power to detect specific genetic loci associated with a complex trait and to maximize the genetic diversity among strains. The HRDP includes 33 genetically diverse inbred strains of rat and two panels of recombinant inbred rat strains, the FXLE/LEXF (33 strains) from Japan and the HXB/BXH (30 strains) from the Czech Republic.
        Recombinant inbred strains are panels of inbred strains derived from two inbred parental rat strains. The two parental strains are crossed to produce F1 pups. F1 pups are subsequently intercrossed to create an F2 generation.
        These genetically unique F2 generation rats are paired as founders and brother-sister mated for at least 20 generations to fix their genomes. The two RI panels used in the HRDP have been well characterized through studies focused on seizures, epilepsy, lymphoma and leukemia, blood pressure regulation, metabolic syndrome, and alcohol consumption.
    </p>
    <p>
        The HXB/BXH recombinant inbred strains were derived from the Spontaneously Hypertensive Rat (SHR/Olalpcv) and the normotensive BN-Lx (BN-Lx/Cub), a Brown Norway congenic rat strain with polydactyly-luxate syndrome.
        The FXLE x LEXF recombinant inbred strains were derived from the Long Evans strain (LE/Stm) and the Fischer F344 strain (F344/Stm).
    </p>
    <p>
        <b>Notes:</b>
    <ul style="margin-top: -10px">
        <li>
            In the tables below, an asterisk (*) designates that the tagged strain has been sequenced. The VCF files for these (48 strains in total) are available for download.
            These data have been mapped to both Rn6 and Rn7 and can be accessed <a class="here" href="https://download.rgd.mcw.edu/strain_specific_variants/Dwinell_MCW_HybridRatDiversityProgram/Dec2021/?_gl=1*umtyp9*_ga*OTEwNTM3NjMyLjE2OTg2ODE3MzM.*_ga_BTF869XJFG*MTcwOTIxODk0Ni4xNi4xLjE3MDkyMTkzOTcuMC4wLjA">here</a>.
        </li>
        <br>
        <li>
            The double dagger icons (<strong>&#8225;</strong>) designate the strains that have been found by whole genome sequence comparison to be the most genetically similar to the Heterogeneous Stock (HS) Founder Strains. This data is courtesy of Dr. Abraham Palmer (University of California, San Diego) and Dr. Hao Chen (University of Tennessee Health Sciences Center).
            For more information about the HS Founders and the HRDP strains that are similar to them, <a class="here" href="https://rgd.mcw.edu/wg/hrdp_panel/hrdp-to-hs-founder-strain-genetic-similarity/">click here</a>.
        </li>
        <br>
        <li>
            The inbred Wistar WN/N strain is no longer available and no closely related substrains are included in the HRDP panel. However, DNA from a frozen tissue sample from the original NIH strain has been sequenced and that sequence compared to WGS from the HRDP strains. Of the strains currently available from the HRDP, the one found in this analysis to be most closely related to WN/N is WAG/RijCrl with a sequence similarity of approximately 76%.
        </li>
    </ul>
    <br>
    <a class="here"href="front/config.html?mapKey=372&geneList=&chr=&start=&stop=&geneStart=&geneStop=&geneList=&hrdp=on&strain%5B%5D=3000&strain%5B%5D=3015&strain%5B%5D=3029&strain%5B%5D=3016&strain%5B%5D=3031&strain%5B%5D=3002&strain%5B%5D=3017&strain%5B%5D=3032&strain%5B%5D=3004&strain%5B%5D=3018&strain%5B%5D=3033&strain%5B%5D=3003&strain%5B%5D=3020&strain%5B%5D=3036&strain%5B%5D=3019&strain%5B%5D=3035&strain%5B%5D=3021&strain%5B%5D=3037&strain%5B%5D=3007&strain%5B%5D=3022&strain%5B%5D=3038&strain%5B%5D=3008&strain%5B%5D=3030&strain%5B%5D=3039&strain%5B%5D=3009&strain%5B%5D=3023&strain%5B%5D=3041&strain%5B%5D=3034&strain%5B%5D=3040&strain%5B%5D=3010&strain%5B%5D=3024&strain%5B%5D=3042&strain%5B%5D=3025&strain%5B%5D=3043&strain%5B%5D=3026&strain%5B%5D=3044&strain%5B%5D=3013&strain%5B%5D=3027&strain%5B%5D=3014&strain%5B%5D=3028&strain%5B%5D=3045&sample1=3000&sample2=3015&sample3=3029&sample4=3016&sample5=3031&sample6=3002&sample7=3017&sample8=3032&sample9=3004&sample10=3018&sample11=3033&sample12=3003&sample13=3020&sample14=3036&sample15=3019&sample16=3035&sample17=3021&sample18=3037&sample19=3007&sample20=3022&sample21=3038&sample22=3008&sample23=3030&sample24=3039&sample25=3009&sample26=3023&sample27=3041&sample28=3034&sample29=3040&sample30=3010&sample31=3024&sample32=3042&sample33=3025&sample34=3043&sample35=3026&sample36=3044&sample37=3013&sample38=3027&sample39=3014&sample40=3028&sample41=3045">Click here to use RGD's Variant Visualizer tool to explore variants in HRDP strains mapped against the mRatBN7.2 reference</a>
    <span>(all HRDP strains pre-selected) or </span>
    <a class="here" href="front/config.html">Click here to begin your own query in Variant Visualizer</a>.
    <br>
    <br>
    <span>Quantitative phenotype measurements are available for many of the HRDP strains. </span>
    <a class="here" href="phenominer/table.html?species=3&terms=RS:0003549,RS:0001791,RS:0000145,RS:0000116,RS:0000165,RS:0000169,RS:0001814,RS:0001815,RS:0001816,RS:0001817,RS:0001818,RS:0004994,RS:0004995,RS:0001821,RS:0001822,RS:0001823,RS:0001824,RS:0000185,RS:0000244,RS:0000179,RS:0000428,RS:0000342,RS:0000473,RS:0000349,RS:0000350,RS:0000351,RS:0000352,RS:0000353,RS:0000354,RS:0000355,RS:0000356,RS:0000357,RS:0000358,RS:0000359,RS:0000360,RS:0000361,RS:0001313,RS:0001314,RS:0004036,RS:0000399,RS:0000401,RS:0001998,RS:0004798,RS:0002000,RS:0002001,RS:0000403,RS:0002002,RS:0002003,RS:0002004,RS:0004991,RS:0004992,RS:0002007,RS:0002008,RS:0002009,RS:0002010,RS:0002011,RS:0002012,RS:0002013,RS:0002014,RS:0004990,RS:0004989,RS:0002017,RS:0002018,RS:0000431,RS:0000509,RS:0000534,RS:0004988,RS:0000536,RS:0000537,RS:0000538,RS:0000539,RS:0002455,RS:0000540,RS:0002454,RS:0000541,RS:0000542,RS:0000543,RS:0003521,RS:0000544,RS:0000545,RS:0000546,RS:0002447,RS:0000547,RS:0000548,RS:0000549,RS:0000550,RS:0000551,RS:0003523,RS:0002450,RS:0000552,RS:0000553,RS:0000554,RS:0000558,RS:0000559,RS:0003876,RS:0000573,RS:0002070,RS:0000589,RS:0000593,RS:0000126,RS:0000647,RS:0000660,RS:0000677,RS:0000679,RS:0000715,RS:0002538,RS:0001454,RS:0000811,RS:0002249,RS:0000731">Click here to explore this data in RGD's PhenoMiner tool</a>.
    <span> Select a measurement or a phenotype category on the resulting page to view a graph of the data.</span>
    <br>
    <br>
    <br>
    <%if(hrdpClassicInbredStrains!=null||hrdpHXBStrains!=null||hrdpFXLEStrains!=null){%>
    <span><strong>The strains included in the HRDP panel are:</strong></span>
    </p>
    <form id="hrdpForm" method="post">
        <%if (hrdpClassicInbredStrains!=null) {%>
        <div class="legend">
            <div><img src="/rgdweb/common/images/hrdp/greentick.png" alt="greentick">- Strain data exists, and related strain data may exist.</div>
            <div><img src="/rgdweb/common/images/hrdp/yellowtick.png" alt="yellowtick">- Only related strains data exist.</div>
            <div><img src="/rgdweb/common/images/hrdp/redtick.png" alt="redtick">- Neither strain data nor related strains data exist.</div>
        </div>
        <div class="centered">
            <table  class="hrdpTable">
                <thead>
                <tr><th colspan="5" class="table-heading">Classic&nbsp;Inbred&nbsp;Strains</th></tr>
                <tr>
                    <th style="text-align: center;"><input type="checkbox" onclick="toggleAllCheckboxes(this, 'hrdpTable')"></th>
                    <th>Strain</th>
                    <th>Phenominer Data</th>
                    <th>Variant Visualizer Data</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <%for (HrdpPortalCache str : hrdpClassicInbredStrains) {%>
                <tr data-has-phenominer="<%=str.getHasPhenominer()>0%>" data-has-variant-visualizer="<%=str.getHasVariantVisualizer()>0%>">
                    <td style="text-align: center;"><input type="checkbox" name="rgdId" value="<%=str.getStrainId()%>"></td>
                    <td><a class="here"><%=str.getStrainSymbol()%></a></td>
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

                    <td><a class="here" title="Click to View Strain Report"href="report/strain/main.html?id=<%=str.getStrainId()%>">View&nbsp;Strain Report</a></td>
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
                    <th>Phenominer Data</th>
                    <th>Variant Visualizer Data</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <%for (HrdpPortalCache str : hrdpHXBStrains) {%>
                <tr data-has-phenominer="<%=str.getHasPhenominer()>0%>" data-has-variant-visualizer="<%=str.getHasVariantVisualizer()>0%>">
                <td style="text-align: center;"><input type="checkbox" name="rgdId" value="<%=str.getStrainId()%>"></td>
                <td><a class="here"><%=str.getStrainSymbol()%></a></td>
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

                <td><a class="here" title="Click to View Strain Report"href="report/strain/main.html?id=<%=str.getStrainId()%>">View&nbsp;Strain Report</a></td>
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
                    <th>Phenominer Data</th>
                    <th>Variant Visualizer Data</th>
                    <th></th>
                </tr>
                </thead>
                <tbody>
                <%for (HrdpPortalCache str : hrdpFXLEStrains) {%>
                <tr data-has-phenominer="<%=str.getHasPhenominer()>0%>" data-has-variant-visualizer="<%=str.getHasVariantVisualizer()>0%>">
                    <td style="text-align: center;"><input type="checkbox" name="rgdId" value="<%=str.getStrainId()%>"></td>
                    <td><a class="here"><%=str.getStrainSymbol()%></a></td>
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

                    <td><a class="here" title="Click to View Strain Report"href="report/strain/main.html?id=<%=str.getStrainId()%>">View&nbsp;Strain Report</a></td>
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

</script>