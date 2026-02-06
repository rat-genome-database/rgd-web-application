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

    /* Accordion Styles */
    .strain-accordion {
        margin: 10px 20px;
    }
    .accordion-section {
        margin-bottom: 2px;
        border: 1px solid #456;
        border-radius: 3px;
        overflow: hidden;
    }
    .accordion-header {
        background: linear-gradient(to bottom, #2a5a8a 0%, #1a3a5a 100%);
        color: white;
        padding: 5px 12px;
        cursor: pointer;
        display: flex;
        justify-content: space-between;
        align-items: center;
        user-select: none;
    }
    .accordion-header:hover {
        background: linear-gradient(to bottom, #3a6a9a 0%, #2a4a6a 100%);
    }
    .accordion-title {
        font-weight: bold;
        font-size: 13px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .accordion-toggle {
        font-size: 10px;
        transition: transform 0.3s;
    }
    .accordion-toggle.collapsed {
        transform: rotate(-90deg);
    }
    .accordion-count {
        font-size: 12px;
        color: #acd;
        margin-left: 5px;
    }
    .accordion-actions {
        display: flex;
        gap: 10px;
        align-items: center;
    }
    .accordion-select-all {
        font-size: 11px;
        padding: 2px 6px;
        background: #4a7aaa;
        border: 1px solid #5a8aba;
        border-radius: 3px;
        color: white;
        cursor: pointer;
    }
    .accordion-select-all:hover {
        background: #5a8aba;
    }
    .accordion-content {
        background: #1a2a3a;
        padding: 10px 15px;
        display: none;
    }
    .accordion-content.expanded {
        display: block;
    }
    .strain-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 5px 20px;
    }
    .strain-item {
        display: flex;
        align-items: center;
        gap: 5px;
        padding: 3px 0;
        color: white;
        font-size: 13px;
    }
    .strain-item input[type="checkbox"] {
        margin: 0;
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

    /* Summary section */
    .selection-summary {
        background: #1a3a5a;
        color: white;
        padding: 10px 20px;
        margin: 10px 20px;
        border-radius: 4px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .selection-count {
        font-size: 14px;
    }
    .expand-collapse-all {
        font-size: 12px;
        padding: 5px 10px;
        background: #4a7aaa;
        border: 1px solid #5a8aba;
        border-radius: 3px;
        color: white;
        cursor: pointer;
        margin-left: 10px;
    }
    .expand-collapse-all:hover {
        background: #5a8aba;
    }

    /* Bold Continue button - matches expand-collapse-all size */
    .continueButtonPrimary {
        font-size: 12px;
        font-weight: bold;
        background: linear-gradient(to bottom, #28a745 0%, #1e7e34 100%);
        color: white;
        border: 1px solid #1e7e34;
        border-radius: 3px;
        padding: 5px 10px;
        cursor: pointer;
        box-shadow: 0 2px 4px rgba(0,0,0,0.2);
    }
    .continueButtonPrimary:hover {
        background: linear-gradient(to bottom, #34ce57 0%, #28a745 100%);
    }

    /* Clear All button - matches expand-collapse-all */
    .clearAllButton {
        font-size: 12px;
        padding: 5px 10px;
        background: #4a7aaa;
        border: 1px solid #5a8aba;
        border-radius: 3px;
        color: white;
        cursor: pointer;
        margin-left: 10px;
    }
    .clearAllButton:hover {
        background: #5a8aba;
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

    <input type="hidden" name="mapKey" value="<%=req.getParameter("mapKey")%>" />

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
        <div style="margin:10px; color:white; border-bottom:1px solid white;"> Select Sequence Group (Optional)</div>
        <%}%>
        <table style="margin-left:50px;">
            <tr>
                <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) == 3) { %>
                <td style="color:white;">  <input id="hrdpClassic" name="hrdpClassic" type="checkbox" onChange="selectGroup('hrdpClassic')"/> Classic Inbred Strains</td>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td style="color:white;">  <input id="hrdpLE" name="hdrpLE" type="checkbox" onChange="selectGroup('hrdpLE')"/> FXLE/LEXF Recombinant Inbred Panel</td>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td style="color:white;">  <input id="hrdpHXB" name="hrdpHXB" type="checkbox" onChange="selectGroup('hrdpHXB')"/> HXB/BXH Recombinant Inbred Panel</td>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td style="color:white;"><input id="hsfounders" name="hsfounders" type="checkbox" onChange="selectGroup('hsfounders')"/> HS Founder Strains</td>
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

                <td style="color:white; font-size: small;">  <input id="<%=breeds.get(i+j)%>" name="<%=breeds.get(i+j)%>" type="checkbox" onChange="selectBreed('<%=breeds.get(i+j)%>','<%=breedMap.get(breeds.get(i+j))%>')" /> <%=breeds.get(i+j)%> &nbsp;&nbsp;</td>
                <% }
                %>
            </tr>
            <%
                    }
                } %>

        </table>
        <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 1 && SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 2 &&
                SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 9 && SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 13) { %>

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
            // e.g., HXB1, HXB10, HXB17 -> "HXB Panel"
            //       FXLE12, FXLE20 -> "FXLE Panel"
            //       LEXF10A, LEXF1C, LEXF2B -> "LEXF Panel"
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
                        <span class="accordion-toggle collapsed" id="toggle-<%=groupId%>">&#9660;</span>
                        <%=groupName%>
                        <span class="accordion-count">(<%=groupSamples.size()%>)</span>
                    </div>
                    <div class="accordion-actions" onclick="event.stopPropagation();">
                        <button type="button" class="accordion-select-all" onclick="toggleGroupSelection('<%=groupId%>')">Select/Deselect All</button>
                    </div>
                </div>
                <div class="accordion-content" id="content-<%=groupId%>">
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


