<%@ page import="java.util.List" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.dao.impl.VariantSampleGroupDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    String pageTitle = "Variant Visualizer";
    String headContent = "";
    String pageDescription = "Analyze variation in next-gen strain sequence";
%>
<%@ include file="/common/headerarea.jsp" %>
<%@ include file="carpeHeader.jsp"%>
<%@ include file="menuBar.jsp" %>

<%
    if (req.getParameter("u").equals("394033")) {
        session.setAttribute("showHidden","1");
    }
%>

<% try {
    List<Sample> samples = (List<Sample>) request.getAttribute("sampleList");

    int mapKey = (Integer) request.getAttribute("mapKey");
%>

<style>
    #sortable { list-style-type: none; margin: 0; padding: 0; width: 200; }
    #sortable li { cursor:move; margin: 0 2px 2px 2px; padding: 5px; padding-left: 5px; font-size: 14px; height: 18px; color:#01224D; }
    #sortable li span { cursor:pointer; position: absolute; margin-left: 2px; }

    /* Page Container */
    .select-container {
        max-width: 1200px;
        margin: 20px auto;
        padding: 0 20px 20px 20px;
    }

    .select-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
        padding-bottom: 10px;
        border-bottom: 2px solid rgba(255,255,255,0.3);
    }

    .select-title {
        font-size: 18px;
        font-weight: bold;
        color: #ffffff;
    }

    .select-assembly {
        font-size: 14px;
        color: #b8d4f0;
    }

    /* Sequence Group Section */
    .sequence-group-card {
        background: #e8f0f8;
        border: 1px solid #c0d0e0;
        border-radius: 6px;
        padding: 15px 20px;
        margin-bottom: 20px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.08);
    }

    .sequence-group-title {
        font-size: 14px;
        font-weight: 600;
        color: #1a3a5a;
        margin-bottom: 12px;
    }

    .sequence-group-options {
        display: flex;
        flex-wrap: wrap;
        gap: 20px;
    }

    .sequence-group-options label {
        display: flex;
        align-items: center;
        gap: 6px;
        color: #333;
        font-size: 13px;
        cursor: pointer;
    }

    /* Accordion Styles - Light Theme */
    .strain-accordion {
        margin: 0;
    }

    .accordion-section {
        margin-bottom: 4px;
        border: 1px solid #c0d0e0;
        border-radius: 4px;
        overflow: hidden;
        background: #e8f0f8;
    }

    .accordion-header {
        background: linear-gradient(to bottom, #e8f0f8 0%, #dce8f4 100%);
        color: #1a3a5a;
        padding: 8px 15px;
        cursor: pointer;
        display: flex;
        justify-content: space-between;
        align-items: center;
        user-select: none;
        border-bottom: 1px solid #c0d0e0;
    }

    .accordion-header:hover {
        background: linear-gradient(to bottom, #f0f6fc 0%, #e8f0f8 100%);
    }

    .accordion-title {
        font-weight: bold;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 8px;
        color: #1a3a5a;
    }

    .accordion-toggle {
        font-size: 10px;
        transition: transform 0.3s;
        color: #3a7aba;
    }

    .accordion-toggle.collapsed {
        transform: rotate(-90deg);
    }

    .accordion-count {
        font-size: 12px;
        color: #6a8aaa;
        margin-left: 5px;
    }

    .accordion-actions {
        display: flex;
        gap: 10px;
        align-items: center;
    }

    .accordion-select-all {
        font-size: 11px;
        padding: 3px 8px;
        background: linear-gradient(to bottom, #5a9bcf 0%, #3a7aba 100%);
        border: 1px solid #3a7aba;
        border-radius: 3px;
        color: white;
        cursor: pointer;
        font-weight: 600;
    }

    .accordion-select-all:hover {
        background: linear-gradient(to bottom, #6aabdf 0%, #4a8aca 100%);
    }

    .accordion-content {
        background: #f0f6fc;
        padding: 12px 15px;
        display: none;
        border-top: 1px solid #d0dde8;
    }

    .accordion-content.expanded {
        display: block;
    }

    .strain-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 8px 20px;
    }

    @media (max-width: 900px) {
        .strain-grid {
            grid-template-columns: repeat(2, 1fr);
        }
    }

    .strain-item {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 4px 0;
        color: #333;
        font-size: 13px;
    }

    .strain-item input[type="checkbox"] {
        margin: 0;
    }

    .strain-item label {
        cursor: pointer;
    }

    .strain-item .help-icon {
        cursor: help;
    }

    .strain-tooltip {
        margin: 10px;
        position: absolute;
        z-index: 100;
        visibility: hidden;
        padding: 10px;
    }

    /* Summary section - Light Theme */
    .selection-summary {
        background: #dce8f4;
        color: #1a3a5a;
        padding: 12px 20px;
        margin: 15px 0;
        border-radius: 6px;
        border: 1px solid #c0d0e0;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    .selection-count {
        font-size: 14px;
        font-weight: 600;
    }

    .expand-collapse-all {
        font-size: 12px;
        padding: 6px 12px;
        background: linear-gradient(to bottom, #6c757d 0%, #545b62 100%);
        border: 1px solid #545b62;
        border-radius: 4px;
        color: white;
        cursor: pointer;
        margin-left: 10px;
    }

    .expand-collapse-all:hover {
        background: linear-gradient(to bottom, #7a8288 0%, #6c757d 100%);
    }

    /* Bold Continue button */
    .continueButtonPrimary {
        font-size: 13px;
        font-weight: bold;
        background: linear-gradient(to bottom, #28a745 0%, #1e7e34 100%);
        color: white;
        border: 1px solid #1e7e34;
        border-radius: 4px;
        padding: 6px 16px;
        cursor: pointer;
        box-shadow: 0 2px 4px rgba(0,0,0,0.15);
    }

    .continueButtonPrimary:hover {
        background: linear-gradient(to bottom, #34ce57 0%, #28a745 100%);
    }

    /* Clear All button */
    .clearAllButton {
        font-size: 12px;
        padding: 6px 12px;
        background: linear-gradient(to bottom, #6c757d 0%, #545b62 100%);
        border: 1px solid #545b62;
        border-radius: 4px;
        color: white;
        cursor: pointer;
        margin-right: 10px;
    }

    .clearAllButton:hover {
        background: linear-gradient(to bottom, #7a8288 0%, #6c757d 100%);
    }

    /* Light theme overrides for page header */
    .typerMat .stepLabel td {
        color: #ffffff;
    }

    /* Container for light-themed content */
    .select-content-wrapper {
        background: #f0f5fa;
        border-radius: 6px;
        padding: 20px;
        margin: 15px 0;
    }
</style>
<script>
    $(function() {
        //  $( "#sortable" ).sortable();
        //  $( "#sortable" ).disableSelection();
        <%if (req.getParameter("sample1").equals("all")) {%>
        selectAll();
        <% }%>

    });

    function selectAll() {
        document.getElementById("all").checked = true;
        selectGroup("all");
    }

    function deselectAll(){
        const allCheckedBoxes = document.querySelectorAll('input[type="checkbox"]')
        allCheckedBoxes.forEach(checkbox =>{
            checkbox.checked=false;
        })
        updateSelectionCount();
    }

    // Accordion functions
    function toggleAccordion(sectionId) {
        const content = document.getElementById('content-' + sectionId);
        const toggle = document.getElementById('toggle-' + sectionId);
        if (content.classList.contains('expanded')) {
            content.classList.remove('expanded');
            toggle.classList.add('collapsed');
        } else {
            content.classList.add('expanded');
            toggle.classList.remove('collapsed');
        }
    }

    function selectAllInGroup(groupId, selectAll) {
        const content = document.getElementById('content-' + groupId);
        const checkboxes = content.querySelectorAll('input[type="checkbox"]');
        checkboxes.forEach(cb => {
            cb.checked = selectAll;
        });
        updateSelectionCount();
    }

    function toggleGroupSelection(groupId) {
        const content = document.getElementById('content-' + groupId);
        const checkboxes = content.querySelectorAll('input[type="checkbox"]');
        const allChecked = Array.from(checkboxes).every(cb => cb.checked);
        selectAllInGroup(groupId, !allChecked);
    }

    function expandAllAccordions() {
        document.querySelectorAll('.accordion-content').forEach(content => {
            content.classList.add('expanded');
        });
        document.querySelectorAll('.accordion-toggle').forEach(toggle => {
            toggle.classList.remove('collapsed');
        });
    }

    function collapseAllAccordions() {
        document.querySelectorAll('.accordion-content').forEach(content => {
            content.classList.remove('expanded');
        });
        document.querySelectorAll('.accordion-toggle').forEach(toggle => {
            toggle.classList.add('collapsed');
        });
    }

    function updateSelectionCount() {
        const checkboxes = document.querySelectorAll('input[name="strain[]"]');
        const checked = Array.from(checkboxes).filter(cb => cb.checked).length;
        const countEl = document.getElementById('selection-count');
        if (countEl) {
            countEl.textContent = checked + ' of ' + checkboxes.length + ' strains selected';
        }
    }

    // Add event listener to update count when checkboxes change
    document.addEventListener('DOMContentLoaded', function() {
        document.querySelectorAll('input[name="strain[]"]').forEach(cb => {
            cb.addEventListener('change', updateSelectionCount);
        });
        updateSelectionCount();
    });

    function submitPage() {

        var checkboxes = document.getElementsByName('strain[]');
        var count=1;
        var url = "searchType.html?a=1";

        for (var i in checkboxes) {
            if (checkboxes[i].checked) {
                var input = document.createElement("input");
                input.type = "hidden";
                input.name = "sample" + count;
                document.getElementById("strainBox").appendChild(input);
                input.value = checkboxes[i].value;
                count++;
            }
        }

        if (count > 1) {
            document.getElementById("strainBox").submit();
        }else {
            alert("You must select at least one strain.")
        }
    }
</script>

<form id="strainBox" action="config.html">

    <input type="hidden" name="mapKey" value="<%=mapKey%>" />

    <input type="hidden" name="geneList" value="<%=req.getParameter("geneList")%>" />
    <input type="hidden" name="chr" value="<%=req.getParameter("chr")%>" />
    <input type="hidden" name="start" value="<%=req.getParameter("start")%>" />
    <input type="hidden" name="stop" value="<%=req.getParameter("stop")%>" />

    <input type="hidden" name="geneStart" value="<%=req.getParameter("geneStart")%>" />
    <input type="hidden" name="geneStop" value="<%=req.getParameter("geneStop")%>" />

<%--    <input type="hidden" name="geneList" value="<%=req.getParameter("geneList")%>" />--%>

    <br>
    <div class="typerMat">
        <div class="typerTitle"><div class="typerTitleSub">Variant&nbsp;Visualizer</div></div>

        <table width="100%" class="stepLabel" border=0>
            <tr>
                <td align="left">Select samples to compare</td>
                <td align="right" style="font-size:16px;"><%=MapManager.getInstance().getMap(mapKey).getName()%> assembly</td>
            </tr>
        </table>


            <%
                int colCount = 4;
           VariantSampleGroupDAO vsgd = new VariantSampleGroupDAO();
           List<Integer> founders = vsgd.getVariantSamples("HS Founder");
           String founderArr = "[";
           for (Integer f: founders) {
               founderArr += f + ",";
           }
           founderArr += "]";

           List<Integer> hrdpClass = vsgd.getVariantSamples("HRDP","Classic Inbred Strains");
           String hdrpArrClassic = "[";
           for (Integer f: hrdpClass) {
               hdrpArrClassic += f + ",";
           }
            hdrpArrClassic += "]";

            List<Integer> hrdpLE = vsgd.getVariantSamples("HRDP","FXLE/LEXF Recombinant Inbred Panel");
            String hrdpArrLE = "[";
            for (Integer f: hrdpLE) {
                hrdpArrLE += f + ",";
            }
            hrdpArrLE += "]";

            List<Integer> hrdpHXB = vsgd.getVariantSamples("HRDP","HXB/BXH Recombinant Inbred Panel");
            String hrdpArrHXB = "[";
            for (Integer f: hrdpHXB) {
                hrdpArrHXB += f + ",";
            }
                hrdpArrHXB += "]";

            int sampNum = 1;
            String sampVal = "";
            HashMap<String,String> sampleMap = new HashMap<String,String>();
            while ((sampVal = request.getParameter("sample" + sampNum)) != null) {
                sampleMap.put(request.getParameter("sample" + sampNum), "found");
                sampNum++;
            }
        HashMap<String,List<Integer>> breedMap = new HashMap<>();
         List<String> breeds = new ArrayList<>();
        if(mapKey == 631){
            List<Integer> breedsArr = new ArrayList<>();
            for(Sample s:samples){
                String name = s.getAnalysisName();
                try{
                    int index = name.indexOf("Wolf");
                    boolean foundWolf = index >= 0;

                    if (foundWolf) {
                        String breed = "Wolf";
                        breedsArr = breedMap.get(breed);

                        if (breedsArr == null) {
                            breedsArr = new ArrayList<>();
                        }

                        breedsArr.add(s.getId());
                        breedMap.put(breed,breedsArr);

                    }else {
                        index = name.indexOf("(");
                        if( index > 0 ) {
                            String breed = name.substring(0, index - 1);

                            breedsArr = breedMap.get(breed);
                            if (breedsArr == null) {
                                breedsArr = new ArrayList<>();
                            }
                            breedsArr.add(s.getId());
                            breedMap.put(breed, breedsArr);
                        }
                    }
                }
                catch (Exception e){
                    e.printStackTrace();

                    // probably eva, if not some other bug
                }
            }

                    breeds.addAll(breedMap.keySet());
                    Collections.sort(breeds);
        }
        if(mapKey==38 || mapKey==17){

        }
        %>


        <script>
            function selectGroup(name) {
                var strainGroups = {};
                strainGroups["hsfounders"] = <%=founderArr%>;
                strainGroups["hrdpClassic"] = <%=hdrpArrClassic%>;
                strainGroups["hrdpLE"] = <%=hrdpArrLE%>;
                strainGroups["hrdpHXB"] = <%=hrdpArrHXB%>;
                var group = document.getElementById(name);
                var selected = strainGroups[name];
                var founders = strainGroups["hsfounders"];
                var hrdpClassic = strainGroups["hrdpClassic"];
                var hrdpLE = strainGroups["hrdpLE"];
                var hrdpHXB = strainGroups["hrdpHXB"];

                var checkboxes = document.getElementsByName('strain[]');
                if(name=="all"){
                    if (group.checked) {
                        document.getElementById("hsfounders").checked = true;
                        document.getElementById("hrdp").checked = true;
                    }
                    else{  document.getElementById("hsfounders").checked = false;
                        document.getElementById("hrdp").checked = false;}

                }
                for (var i in checkboxes) {
                    if (!checkboxes[i].id) continue;
                    var strainId = checkboxes[i].id.split("_");

                    if (name == "all") {
                        if (group.checked) {
                            checkboxes[i].checked = true;

                        } else {
                            checkboxes[i].checked = false;
                        }
                    } else {
                        for (j = 0; j < selected.length; j++) {
                            if (strainId[0] == selected[j]) {
                                var flag = "false";
                                var otherGroup;
                                var hrdpGroup1;
                                var hrdpGroup2;
                                var hrdpGroup3;
                                if (name == 'hsfounders') {
                                    // otherGroup = document.getElementById("hsfounders");
                                    otherGroup = document.getElementById("hrdpClassic");
                                    hrdpGroup2 = document.getElementById("hrdpLE")
                                    hrdpGroup3 = document.getElementById("hrdpHXB");

                                    if (otherGroup.checked) {
                                        for (k = 0; k < hrdpClassic.length; k++) {
                                            if (strainId[0] == hrdpClassic[k]) {
                                                flag = "true";
                                                break;
                                            }
                                        }
                                    }
                                }
                                if (name == 'hrdpClassic') {
                                    otherGroup = document.getElementById("hsfounders");
                                    // hrdpGroup1 = document.getElementById("hrdpClassic");
                                    hrdpGroup2 = document.getElementById("hrdpLE")
                                    hrdpGroup3 = document.getElementById("hrdpHXB");

                                    if (otherGroup.checked) {
                                        for (var k = 0; k < founders.length; k++) {
                                            console.log( strainId[0] +"\t"+ founders[k]);

                                            if (strainId[0] == founders[k]) {
                                                flag = "true";
                                                break;
                                            }
                                        }
                                    }
                                    if (hrdpGroup2.checked) {
                                        for (k = 0; k < hrdpLE.length; k++) {
                                            if (strainId[0] == hrdpLE[k]) {
                                                flag = "true";
                                                break;
                                            }
                                        }
                                    }
                                    if (hrdpGroup3.checked) {
                                        for (k = 0; k < hrdpHXB.length; k++) {
                                            if (strainId[0] == hrdpHXB[k]) {
                                                flag = "true";
                                                break;
                                            }
                                        }
                                    }
                                }
                                if (name == 'hrdpLE') {
                                    otherGroup = document.getElementById("hsfounders");
                                    hrdpGroup1 = document.getElementById("hrdpClassic");
                                    // hrdpGroup2 = document.getElementById("hrdpLE")
                                    hrdpGroup3 = document.getElementById("hrdpHXB");

                                    if (otherGroup.checked) {
                                        for (var k = 0; k < founders.length; k++) {
                                            console.log( strainId[0] +"\t"+ founders[k]);

                                            if (strainId[0] == founders[k]) {
                                                flag = "true";
                                                break;
                                            }
                                        }
                                    }
                                    if (hrdpGroup1.checked) {
                                        for (k = 0; k < hrdpClassic.length; k++) {
                                            if (strainId[0] == hrdpClassic[k]) {
                                                flag = "true";
                                                break;
                                            }
                                        }
                                    }
                                    if (hrdpGroup3.checked) {
                                        for (k = 0; k < hrdpHXB.length; k++) {
                                            if (strainId[0] == hrdpHXB[k]) {
                                                flag = "true";
                                                break;
                                            }
                                        }
                                    }
                                }
                                if (name == 'hrdpHXB') {
                                    otherGroup = document.getElementById("hsfounders");
                                    hrdpGroup1 = document.getElementById("hrdpClassic");
                                    hrdpGroup2 = document.getElementById("hrdpLE")
                                    // hrdpGroup3 = document.getElementById("hrdpHXB");

                                    if (otherGroup.checked) {
                                        for (var k = 0; k < founders.length; k++) {
                                            console.log( strainId[0] +"\t"+ founders[k]);

                                            if (strainId[0] == founders[k]) {
                                                flag = "true";
                                                break;
                                            }
                                        }
                                    }
                                    if (hrdpGroup1.checked) {
                                        for (k = 0; k < hrdpClassic.length; k++) {
                                            if (strainId[0] == hrdpClassic[k]) {
                                                flag = "true";
                                                break;
                                            }
                                        }
                                    }
                                    if (hrdpGroup2.checked) {
                                        for (k = 0; k < hrdpLE.length; k++) {
                                            if (strainId[0] == hrdpLE[k]) {
                                                flag = "true";
                                                break;
                                            }
                                        }
                                    }
                                }
                                    if (group.checked) {
                                        checkboxes[i].checked = true;

                                    } else {
                                            if (flag==="false")
                                                checkboxes[i].checked = false;
                                    }


                            }
                        }
                    }
                }
            }
            function selectBreed(name,value) {
                var group = document.getElementById(name);
                value = value.substring(1,value.length-1);

                var samples = value.split(",");

                var checkboxes = document.getElementsByName('strain[]');
                for (var i in checkboxes) {
                    if (!checkboxes[i].id) continue;
                    var strainId = checkboxes[i].id.split("_");

                    for (j = 0; j < samples.length; j++) {
                        if (strainId[1] == (samples[j].trim())) {
                            if (group.checked) {
                                checkboxes[i].checked = true;
                            } else {
                                checkboxes[i].checked = false;
                            }
                        }
                    }
                }
            }
        </script>
        <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 1 && SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 2 &&
                SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 9 && SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 13) { %>
        <div class="sequence-group-card">
            <div class="sequence-group-title">Select Sequence Group (Optional)</div>
        <%}%>
        <table class="sequence-group-options">
            <tr>
                <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) == 3) { %>
                <td style="color:#333;">  <input id="hrdpClassic" name="hrdpClassic" type="checkbox" onChange="selectGroup('hrdpClassic')"/> Classic Inbred Strains</td>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td style="color:#333;">  <input id="hrdpLE" name="hdrpLE" type="checkbox" onChange="selectGroup('hrdpLE')"/> FXLE/LEXF Recombinant Inbred Panel</td>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td style="color:#333;">  <input id="hrdpHXB" name="hrdpHXB" type="checkbox" onChange="selectGroup('hrdpHXB')"/> HXB/BXH Recombinant Inbred Panel</td>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td style="color:#333;"><input id="hsfounders" name="hsfounders" type="checkbox" onChange="selectGroup('hsfounders')"/> HS Founder Strains</td>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <% }// if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 6 && SpeciesType.getSpeciesTypeKeyForMap(mapKey)!=1 && SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 2 &&
                     //   SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 9 && SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 13) { %>
<%--                <td style="color:white;"><input id="all" name="all" type="checkbox" onChange="selectGroup('all')"/> All Available</td>--%>
<%--                <%}%>--%>

            </tr>

            <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) == SpeciesType.DOG) {

                for(int i=0; i < breeds.size(); i=i+5) {
            %>
            <tr>
                <%
                    for(int j = 0;j < 5;j++) {
                %>

                <td style="color:#333; font-size: small;">  <input id="<%=breeds.get(i+j)%>" name="<%=breeds.get(i+j)%>" type="checkbox" onChange="selectBreed('<%=breeds.get(i+j)%>','<%=breedMap.get(breeds.get(i+j))%>')" /> <%=breeds.get(i+j)%> &nbsp;&nbsp;</td>
                <% }
                %>
            </tr>
            <%
                    }
                } %>

        </table>
        <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 1 && SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 2 &&
                SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 9 && SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 13) { %>
        </div>

        <!-- Selection Summary and Controls -->
        <div class="selection-summary">
            <div>
                <span id="selection-count">0 of 0 strains selected</span>
                <button type="button" class="expand-collapse-all" onclick="expandAllAccordions()">Expand All</button>
                <button type="button" class="expand-collapse-all" onclick="collapseAllAccordions()">Collapse All</button>
            </div>
            <div>
                <input class="clearAllButton" type="button" value="Clear all" onClick="deselectAll()"/>
                &nbsp;&nbsp;
                <input class="continueButtonPrimary" type="button" value="Continue..." onClick="submitPage()"/>
            </div>
        </div>

        <%
            // Dynamically group samples by strain family/panel
            LinkedHashMap<String, List<Sample>> strainGroups = new LinkedHashMap<>();
            String checked = "";

            // Helper function to determine strain family from sample name
            // This extracts the base strain/family name from sample analysis names
            for (Sample samp : samples) {
                String sampleName = samp.getAnalysisName();
                if (sampleName.contains("GWAS") && sampleName.contains("Ensembl")) continue;
                if (samp.getId() == 900 || samp.getId() == 901) {
                    if (session.getAttribute("showHidden") == null || !session.getAttribute("showHidden").equals("1")) {
                        continue;
                    }
                }

                // Extract the strain family/group from the sample name
                String group = extractStrainFamily(sampleName);

                // Add to the appropriate group
                if (!strainGroups.containsKey(group)) {
                    strainGroups.put(group, new ArrayList<Sample>());
                }
                strainGroups.get(group).add(samp);
            }

            // Sort the groups: put "Other" at the end, sort rest alphabetically
            List<String> sortedGroups = new ArrayList<>(strainGroups.keySet());
            Collections.sort(sortedGroups, (a, b) -> {
                if (a.equals("Other")) return 1;
                if (b.equals("Other")) return -1;
                return a.compareToIgnoreCase(b);
            });

            int groupIndex = 0;
        %>

        <%!
            // Method to extract the strain family from a sample name
            // Generic logic: strips trailing numbers and letter suffixes to group related strains
            // If numbers were stripped from a short strain code, appends "Panel"
            // Special cases: FXLE/LEXF and HXB/BXH are combined into single panels
            // e.g., HXB1, HXB10, BXH2, BXH13 -> "HXB/BXH Panel"
            //       FXLE12, FXLE20, LEXF10A, LEXF1C -> "FXLE/LEXF Panel"
            //       ACI -> "ACI" (no numbers, no Panel suffix)
            //       European Variation Archive Release 7 -> "European Variation Archive Release" (no Panel - has spaces)
            private String extractStrainFamily(String sampleName) {
                if (sampleName == null || sampleName.isEmpty()) return "Other";

                // Get the part before the slash (if any)
                String baseName = sampleName.split("/")[0].trim();

                if (baseName.length() == 0) return "Other";

                // Strip trailing number+letter combinations to group strain families
                // Pattern: numbers followed by optional letters at the end
                // e.g., HXB10 -> HXB, LEXF10A -> LEXF, LEXF1C -> LEXF
                String family = baseName.replaceAll("\\d+[A-Za-z]*$", "").trim();

                // If stripping leaves nothing or just one char, keep original
                // This handles edge cases like single letter strains
                if (family.length() <= 1) {
                    return baseName;
                }

                // Combine FXLE and LEXF into one panel
                if (family.equalsIgnoreCase("FXLE") || family.equalsIgnoreCase("LEXF")) {
                    return "FXLE/LEXF Panel";
                }

                // Combine HXB and BXH into one panel
                if (family.equalsIgnoreCase("HXB") || family.equalsIgnoreCase("BXH")) {
                    return "HXB/BXH Panel";
                }

                // Only add "Panel" suffix for short strain codes (no spaces)
                // Long names with spaces like "European Variation Archive Release" are not panels
                if (!family.equals(baseName) && !family.contains(" ")) {
                    return family + " Panel";
                }

                return family;
            }
        %>

        <div class="strain-accordion">
        <% for (String groupName : sortedGroups) {
            List<Sample> groupSamples = strainGroups.get(groupName);
            if (groupSamples == null || groupSamples.isEmpty()) continue;
            String groupId = "group" + groupIndex;
        %>
            <div class="accordion-section">
                <div class="accordion-header" onclick="toggleAccordion('<%=groupId%>')">
                    <div class="accordion-title">
                        <span class="accordion-toggle" id="toggle-<%=groupId%>">&#9660;</span>
                        <%=groupName%>
                        <span class="accordion-count">(<%=groupSamples.size()%>)</span>
                    </div>
                    <div class="accordion-actions" onclick="event.stopPropagation();">
                        <button type="button" class="accordion-select-all" onclick="toggleGroupSelection('<%=groupId%>')">Select/Deselect All</button>
                    </div>
                </div>
                <div class="accordion-content expanded" id="content-<%=groupId%>">
                    <div class="strain-grid">
                    <% for (Sample samp : groupSamples) {
                        if (sampleMap.get(samp.getId() + "") != null) {
                            checked = " checked ";
                        } else {
                            checked = " ";
                        }
                    %>
                        <div class="strain-item">
                            <input type="checkbox" id="<%=samp.getStrainRgdId()%>_<%=samp.getId()%>" name="strain[]" value="<%=samp.getId()%>" <%=checked%>/>
                            <label for="<%=samp.getStrainRgdId()%>_<%=samp.getId()%>"><%=samp.getAnalysisName().replaceAll("\\ ", "&nbsp;")%></label>
                            <img class="help-icon" onMouseOut="document.getElementById('div_<%=samp.getId()%>').style.visibility='hidden';" onMouseOver="document.getElementById('div_<%=samp.getId()%>').style.visibility='visible';" src="/rgdweb/common/images/help.png" height="12" width="12"/>
                            <div class="strain-tooltip" id="div_<%=samp.getId()%>">
                                <table cellpadding='4' style="background-color:#063968;border:2px solid white;padding:10px;">
                                    <tr>
                                        <td style="font-size:12px; font-weight:700; color:white;">Sample ID:</td>
                                        <td style="font-size:12px; color:white;"><%=samp.getId()%></td>
                                    </tr>
                                    <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) == 3) { %>
                                    <tr>
                                        <td style="font-size:12px; font-weight:700; color:white;">Strain RGD ID</td>
                                        <td style="font-size:12px; color:white;"><%=samp.getStrainRgdId()%></td>
                                    </tr>
                                    <% } %>
                                    <% if (samp.getSequencedBy() != null) { %>
                                    <tr>
                                        <td style="font-size:12px; font-weight:700; color:white;">Sequenced By:</td>
                                        <td style="font-size:12px; color:white;"><%=samp.getSequencedBy()%></td>
                                    </tr>
                                    <% } %>
                                    <% if (samp.getSequencer() != null) { %>
                                    <tr>
                                        <td style="font-size:12px; font-weight:700; color:white;">Platform:</td>
                                        <td style="font-size:12px; color:white;"><%=samp.getSequencer()%></td>
                                    </tr>
                                    <% } %>
                                    <% if (samp.getWhereBred() != null) { %>
                                    <tr>
                                        <td style="font-size:12px; font-weight:700; color:white;">Breeder:</td>
                                        <td style="font-size:12px; color:white;"><%=samp.getWhereBred()%></td>
                                    </tr>
                                    <% } %>
                                </table>
                            </div>
                        </div>
                    <% } %>
                    </div>
                </div>
            </div>
        <% groupIndex++; } %>
        </div>

        <!-- Bottom buttons -->
        <div class="selection-summary">
            <div>
                <span id="selection-count-bottom">0 of 0 strains selected</span>
            </div>
            <div>
                <input class="clearAllButton" type="button" value="Clear all" onClick="deselectAll()"/>
                &nbsp;&nbsp;
                <input class="continueButtonPrimary" type="button" value="Continue..." onClick="submitPage()"/>
            </div>
        </div>

        <script>
            // Update both selection count displays
            function updateSelectionCount() {
                const checkboxes = document.querySelectorAll('input[name="strain[]"]');
                const checked = Array.from(checkboxes).filter(cb => cb.checked).length;
                const text = checked + ' of ' + checkboxes.length + ' strains selected';
                const countEl = document.getElementById('selection-count');
                const countElBottom = document.getElementById('selection-count-bottom');
                if (countEl) countEl.textContent = text;
                if (countElBottom) countElBottom.textContent = text;
            }
            // Initialize on page load
            document.addEventListener('DOMContentLoaded', function() {
                document.querySelectorAll('input[name="strain[]"]').forEach(cb => {
                    cb.addEventListener('change', updateSelectionCount);
                });
                updateSelectionCount();
            });
        </script>

        <%}%>
    </div>
</form>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<%@ include file="/common/footerarea.jsp" %>


