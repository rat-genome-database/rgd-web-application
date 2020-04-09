<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.dao.impl.VariantSampleGroupDAO" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    String pageTitle = "Variant Visualizer";
    String headContent = "";
    String pageDescription = "Analyze variation in next-gen strain sequence";
%>

<%@ include file="carpeHeader.jsp"%>
<%@ include file="menuBar.jsp" %>


<%
if (req.getParameter("u").equals("394033")) {
    session.setAttribute("showHidden","1");
}
%>

<% try { %>

<%
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
		$( "#sortable" ).sortable();
		$( "#sortable" ).disableSelection();
	});

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
        <td align="left"><b>Step 1:</b> Select strains to compare</td>
        <td align="right"><%=MapManager.getInstance().getMap(mapKey).getName()%> assembly</td>
    </tr>
</table>

    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/css/bootstrap.min.css" integrity="sha384-MCw98/SFnGE8fJT3GXwEOngsV7Zt27NXFoaoApmYm81iuXoPkFOJwJ8ERdknLPMO" crossorigin="anonymous">                                                                                                                                                                                                                                                                                                                                                                                       <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>
<style>

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js" integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49" crossorigin="anonymous"></script>
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js" integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy" crossorigin="anonymous"></script>

</style>
<%
   VariantSampleGroupDAO vsgd = new VariantSampleGroupDAO();
   List<Integer> founders = vsgd.getVariantSamples("HS Founder");
   String founderArr = "[";
   for (Integer f: founders) {
       founderArr += f + ",";
   }
   founderArr += "]";

   List<Integer> hdrp = vsgd.getVariantSamples("HDRP");
   String hdrpArr = "[";
   for (Integer f: hdrp) {
       hdrpArr += f + ",";
   }
   hdrpArr += "]";


%>


<script>


    function selectGroup(name) {

        var strainGroups = {};
        strainGroups["hsfounders"] = <%=founderArr%>;
        strainGroups["hdrp"] = <%=hdrpArr%>;


        var group = document.getElementById(name);

        var founders = strainGroups[name];
        var checkboxes = document.getElementsByName('strain[]');

        for (var i in checkboxes) {
            if (!checkboxes[i].id) continue;
            var strainId = checkboxes[i].id.split("_");
            for (j=0; j< founders.length; j++) {
                if (strainId[0] == founders[j]) {

                    if (group.checked) {
                        checkboxes[i].checked = true;
                    }else {
                        checkboxes[i].checked = false;
                    }

                }
            }
        }


    }
</script>

    <% if (mapKey==360 || mapKey==70 || mapKey==60) { %>

<div style="margin:10px; color:white; border-bottom:1px solid white;"> Select Strain Group</div>

        <table style="margin-left:50px;">
            <tr>
                <td style="color:white;">  <input id="hdrp" name="hdrp" type="checkbox" onChange="selectGroup('hdrp')"/> HDRP Strains</td>
                <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                <td style="color:white;"><input id="hsfounders" name="hsfounders" type="checkbox" onChange="selectGroup('hsfounders')"/> HS Founder Strains</td>
            </tr>
        </table>
<% } %>

            <div style="margin:10px; color:white; border-bottom:1px solid white;"> Select Strains</div>

        <table border="0" style="margin-left:50px;">
            <tr>
            <%
            int count=0;
            for (Sample samp: samples) {
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
                <td><input type="checkbox"  id="<%=samp.getStrainRgdId()%>_<%=samp.getId()%>" name="strain[]" value="<%=samp.getId()%>"/></td>
                <td style="color:white;"><%=samp.getAnalysisName().replaceAll("\\ ", "&nbsp;")%></td>
                <td>
                    <img onMouseOut="document.getElementById('div_<%=samp.getId()%>').style.visibility='hidden';" onMouseOver="document.getElementById('div_<%=samp.getId()%>').style.visibility='visible';" src="/rgdweb/common/images/help.png" height="15" width="15"/>
                    <div style="margin:10px; position:absolute; z-index:100; visibility:hidden; padding:10px;" id="div_<%=samp.getId()%>">
                        <table cellpadding='4' style="background-color:#063968;border:2px solid white;padding:10px;">
                            <tr>
                                <td style="font-size:14px; font-weight:700; color:white;">Sample ID:</td>
                                <td style="font-size:14px; color:white;"><%=samp.getId()%></td>
                            </tr>
                            <tr>
                                <td style="font-size:14px; font-weight:700; color:white;">Strain RGD ID</td>
                                <td style="font-size:14px; color:white;"><%=samp.getStrainRgdId()%></td>
                            </tr>

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
        </td>
    </tr>
</table>

<br>
<table width="90%">
    <tr>
        <td align="right"><input class="continueButton"  type="button" value="Continue..." onClick="submitPage()"/></td>
    </tr>
</table>


</form>



<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>



<%@ include file="/common/footerarea.jsp" %>



