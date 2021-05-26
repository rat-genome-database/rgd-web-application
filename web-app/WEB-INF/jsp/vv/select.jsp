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
   /* $(function() {
        $( "#sortable" ).sortable();
        $( "#sortable" ).disableSelection();
    });*/

    function selectAll() {
        <% for (Sample samp: samples) { %>
        selectIt('<%=samp.getAnalysisName()%>', '<%=samp.getId()%>');
        <% } %>
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

    <input type="hidden" name="geneList" value="<%=req.getParameter("geneList")%>" />

    <br>
    <div class="typerMat">
        <div class="typerTitle"><div class="typerTitleSub">Variant&nbsp;Visualizer</div></div>

        <table width="100%" class="stepLabel" border=0>
            <tr>
                <td align="left">Select samples to compare</td>
                <td align="right"><%=MapManager.getInstance().getMap(mapKey).getName()%> assembly</td>
            </tr>
        </table>


            <%
           VariantSampleGroupDAO vsgd = new VariantSampleGroupDAO();
           List<Integer> founders = vsgd.getVariantSamples("HS Founder");
           String founderArr = "[";
           for (Integer f: founders) {
               founderArr += f + ",";
           }
           founderArr += "]";

           List<Integer> hrdp = vsgd.getVariantSamples("HRDP");
           String hdrpArr = "[";
           for (Integer f: hrdp) {
               hdrpArr += f + ",";
           }
           hdrpArr += "]";

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
                int index = name.indexOf("(");
                String breed = name.substring(0,index-1);
                breedsArr = breedMap.get(breed);
                if(breedsArr == null)
                    breedsArr = new ArrayList<>();
                breedsArr.add(s.getId());
                breedMap.put(breed,breedsArr);
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
                strainGroups["hrdp"] = <%=hdrpArr%>;
                var group = document.getElementById(name);
                var founders = strainGroups[name];
                var checkboxes = document.getElementsByName('strain[]');

                for (var i in checkboxes) {
                    if (!checkboxes[i].id) continue;
                    var strainId = checkboxes[i].id.split("_");

                    if (name=="all") {
                        if (group.checked) {
                            checkboxes[i].checked = true;
                        } else {
                            checkboxes[i].checked = false;
                        }
                    }else {
                        for (j = 0; j < founders.length; j++) {
                            if (strainId[0] == founders[j]) {

                                if (group.checked) {
                                    checkboxes[i].checked = true;
                                } else {
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
        <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 1) { %>
        <div style="margin:10px; color:white; border-bottom:1px solid white;"> Select Sequence Group (Optional)</div>
        <%}%>
        <table style="margin-left:50px;">
            <tr>
                <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) == 3) { %>
                <td style="color:white;">  <input id="hrdp" name="hrdp" type="checkbox" onChange="selectGroup('hrdp')"/> HRDP Strains</td>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td style="color:white;"><input id="hsfounders" name="hsfounders" type="checkbox" onChange="selectGroup('hsfounders')"/> HS Founder Strains</td>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <% } if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 6 && SpeciesType.getSpeciesTypeKeyForMap(mapKey)!=1) { %>
                <td style="color:white;"><input id="all" name="all" type="checkbox" onChange="selectGroup('all')"/> All Available</td>
                <%}%>

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
        <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 1) { %>
        <div style="margin:10px; color:white; border-bottom:1px solid white;"> Select Samples</div>
<%}%>
        <table width="90%" cellpadding="0" cellspacing="0">
            <tr>
                <td align="right"><input class="continueButton"  type="button" value="Continue..." onClick="submitPage()"/></td>
            </tr>
        </table>

        <table border="0" style="margin-left:50px;">
            <tr>
                <%
                    int count=0;


                    ArrayList<Sample> sampList1 = new ArrayList<Sample>();
                    ArrayList<Sample> sampList2 = new ArrayList<Sample>();
                    ArrayList<Sample> sampList3 = new ArrayList<Sample>();
                    if(mapKey==38 || mapKey==17){
                        sampList1.add(samples.get(0));
                    }
                    int num = 0;
                    for (Sample samp: samples) {
                        if (num < ((samples.size() / 3) )) {
                            sampList1.add(samp);
                        }else if (num < (((samples.size() / 3) ) * 2 )) {
                            sampList2.add(samp);

                        }else {
                            sampList3.add(samp);
                        }
                        num++;
                    }


                    ArrayList<Sample> sortedSamples = new ArrayList<Sample>();
                    try {
                        for (int i = 0; i < sampList1.size(); i++) {
                            sortedSamples.add(sampList1.get(i));
                            sortedSamples.add(sampList2.get(i));
                            sortedSamples.add(sampList3.get(i));
                        }
                    }catch (Exception e) {
                        out.print(e.getMessage());

                    }

                    String checked="";

                    for (Sample samp: sortedSamples) {
                        if (samp.getId() == 900 || samp.getId() == 901)   {
                            if (session.getAttribute("showHidden") == null || !session.getAttribute("showHidden").equals("1")) {
                                continue;
                            }
                        }
                        if (count++ % 3 == 0) {

                %>
            </tr><tr>

            <% } %>
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
            <td>&nbsp;</td>
            <% } %>

        </tr>
        </table>

        <br>
        <% if (SpeciesType.getSpeciesTypeKeyForMap(mapKey) != 1) { %>
        <table width="90%">
            <tr>
                <td align="right"><input class="continueButton"  type="button" value="Continue..." onClick="submitPage()"/></td>
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


