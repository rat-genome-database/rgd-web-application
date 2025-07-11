<%@ page import="java.util.List" %>
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
    }

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
        <div style="margin:10px; color:white; border-bottom:1px solid white;"> Select Samples</div>
<%}%>
        <table width="90%" cellpadding="0" cellspacing="0">
            <tr>
                <td align="right">
                    <input class="continueButton"  type="button" value="Clear all" onClick="deselectAll()"/>
                    &nbsp;&nbsp;
                    <input class="continueButton"  type="button" value="Continue..." onClick="submitPage()"/></td>
            </tr>
        </table>


                <%
                    int count=0;


                    ArrayList<Sample> sampList1 = new ArrayList<Sample>();
                    ArrayList<Sample> sampList2 = new ArrayList<Sample>();
                    ArrayList<Sample> sampList3 = new ArrayList<Sample>();
                    ArrayList<Sample> sampList4 = new ArrayList<>();
//                    ArrayList<Sample> sortedSamples = new ArrayList<Sample>();
                    int sampSize = samples.size();
                    int colSize = sampSize / 4 + ((sampSize%4>0) ? 1 : 0);
                    if(samples.size()==1){
                        sampList1.add(samples.get(0));
                    }else {
                        int num = 1;
                        for (Sample samp : samples) {
                            String sampleName = samp.getAnalysisName();
//                            System.out.println(sampleName);
                            if (sampleName.contains("GWAS") && sampleName.contains("Ensembl"))
                                continue;
                            if (num <= colSize) {
//                                System.out.println("sampleList1|"+sampSize+"|"+num+"|"+colSize+"|"+sampleName);
                                sampList1.add(samp);
                            }
                            else if (num <= (colSize*2)) {
//                                System.out.println("sampleList2|"+sampSize+"|"+num+"|"+colSize+"|"+sampleName);
                                sampList2.add(samp);
                            }
                            else if (num <= (colSize*3)) {
//                                System.out.println("sampleList3|"+sampSize+"|"+num+"|"+colSize+"|"+sampleName);
                                sampList3.add(samp);
                            }
                            else {
//                                System.out.println("sampleList4|"+sampSize+"|"+num+"|"+colSize+"|"+sampleName);
                                sampList4.add(samp);
                            }
                            num++;
                        }
                    }
//System.out.println(sampList1.size()+"|"+sampList2.size()+"|"+sampList3.size());

                    List<List<Sample>> sortedSamples = new ArrayList<>();
                    sortedSamples.add(sampList1);
                    sortedSamples.add(sampList2);
                    sortedSamples.add(sampList3);
                    sortedSamples.add(sampList4);

                    String checked="";

                    %>
                <table border="0" style="margin-left:50px;">
                    <tr>
                <%
                    for (List<Sample> column : sortedSamples){
                    %>

                        <td>
        <table>
        <%
                    for (Sample samp: column) {
                        if (samp.getId() == 900 || samp.getId() == 901)   {
                            if (session.getAttribute("showHidden") == null || !session.getAttribute("showHidden").equals("1")) {
                                continue;
                            }
                        }
                %>
            <tr>
                <td>
                    <table>
                        <tr>
                            <% if (sampleMap.get(samp.getId() + "") != null) {
                                checked = " checked ";
                            }else {
                                checked=" ";
                            }
                            %>
                            <td><input type="checkbox"  id="<%=samp.getStrainRgdId()%>_<%=samp.getId()%>" name="strain[]" value="<%=samp.getId()%>" <%=checked%>/></td>
                            <td style="color:white;"><%=samp.getAnalysisName().replaceAll("\\ ", "&nbsp;")%></td>
                            <td>
                                <img onMouseOut="document.getElementById('div_<%=samp.getId()%>').style.visibility='hidden';" onMouseOver="document.getElementById('div_<%=samp.getId()%>').style.visibility='visible';" src="/rgdweb/common/images/help.png" height="15" width="15"/>
                                <div style="margin:10px; position:absolute; z-index:100; visibility:hidden; padding:10px;" id="div_<%=samp.getId()%>">
                                    <table cellpadding='4' style="background-color:#063968;border:2px solid white;padding:10px;">
                                        <tr>
                                            <td style="font-size:14px; font-weight:700; color:white;">Sample ID:</td>
                                            <td style="font-size:14px; color:white;"><%=samp.getId()%></td>
                                        </tr>

                                        <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) == 3) { %>
                                        <tr>
                                            <td style="font-size:14px; font-weight:700; color:white;">Strain RGD ID</td>
                                            <td style="font-size:14px; color:white;"><%=samp.getStrainRgdId()%></td>
                                        </tr>
                                        <% } %>

                                        <% if (samp.getSequencedBy() != null) { %>
                                        <tr>
                                            <td valign="top" style="font-size:14px; font-weight:700; color:white;">Sequenced By:</td>
                                            <td style="font-size:14px; color:white;"><%=samp.getSequencedBy()%></td>
                                        </tr>
                                        <% } %>
                                        <% if (samp.getSequencer() != null) { %>
                                        <tr>
                                            <td style="font-size:14px; font-weight:700; color:white;">Platform:</td>
                                            <td style="font-size:14px; color:white;"><%=samp.getSequencer()%></td>
                                        </tr>
                                        <% } %>
                                        <% if (samp.getSecondaryAnalysisSoftware() != null) { %>
                                        <tr>
                                            <td style="font-size:14px; font-weight:700; color:white;">Secondary Analysis:</td>
                                            <td style="font-size:14px; color:white;"><%=samp.getSecondaryAnalysisSoftware()%></td>
                                        </tr>
                                        <% } %>
                                        <% if (samp.getWhereBred() != null) { %>
                                        <tr>
                                            <td style="font-size:14px; font-weight:700; color:white;">Breeder:</td>
                                            <td style="font-size:14px; color:white;"><%=samp.getWhereBred()%></td>
                                        </tr>
                                        <% } %>
                                        <% if (samp.getGrantNumber() != null) { %>
                                        <tr>
                                            <td style="font-size:14px; font-weight:700;color:white;">Grant Information:</td>
                                            <td style="font-size:14px; color:white;"><%=samp.getGrantNumber()%></td>
                                        </tr>
                                        <% } %>
                                    </table>
                                </div>
                            </td>
                        </Tr>
                    </table>

                </td>
            </tr>

            <% } %>

        </table>
                        </td>
        <% } %>
                    </tr>
        </table>

        <br>
        <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 1 && SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 2 &&
                SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 9 && SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 13) { %>
        <table width="90%">
            <tr>
                <td align="right">
                    <input class="continueButton"  type="button" value="Clear all" onClick="deselectAll()"/>
                    &nbsp;&nbsp;
                    <input class="continueButton"  type="button" value="Continue..." onClick="submitPage()"/></td>
            </tr>
        </table>
        <%}%>
    </div>
</form>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<%@ include file="/common/footerarea.jsp" %>


