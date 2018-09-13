<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
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

    function selectIt(name, sampleId) {
        var add=true;

        if (!document.getElementById("image" + sampleId)) {
            return;
        }

        if (document.getElementById("image" + sampleId).src.indexOf("remove") != -1) {
            add=false;
        }

        if (add) {

        var li = document.createElement("li");
        li.className = "ui-state-default";
        li.id = "li" + sampleId;

        var span = document.createElement("span");
        span.className = "i-icon ui-icon-arrowthick-2-n-s";
        li.appendChild(span);

        var txt = document.createTextNode(name);
        li.appendChild(txt);
        li.sampleId=sampleId;

        document.getElementById("table" + sampleId).style.backgroundColor="#EDFAFA";

        //li.innerHTML='<span class="ui-icon ui-icon-arrowthick-2-n-s"></span>' + name;
        document.getElementById("sortable").appendChild(li);
            document.getElementById("image" + sampleId).src="/rgdweb/common/images/remove.png";
        } else {
            document.getElementById("table" + sampleId).style.backgroundColor="white";
            document.getElementById("sortable").removeChild(document.getElementById("li" + sampleId));
            document.getElementById("image" + sampleId).src="/rgdweb/common/images/add.png";
        }

    }

    function submitPage() {
        var count=1;
        var url = "searchType.html?a=1";
        for (i=0; i< document.getElementById("sortable").childNodes.length; i++) {

            if (document.getElementById("sortable").childNodes[i].sampleId) {
                var input = document.createElement("input");
                input.type = "hidden";
                input.name = "sample" + count;
                document.getElementById("strainBox").appendChild(input);
                input.value = document.getElementById("sortable").childNodes[i].sampleId;
                count++;
            }
        }

       // url = url + "&mapKey=" + document.getElementById("mapKey").options[document.getElementById("mapKey").selectedIndex].value;

        if (count > 1) {
           //location.href=url;
           // document.getElementById("strainBox").action=url;
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



<table border=0  style="padding:4px;" align="center" width="95%">
    <tr>
        <td width=500 valign="top" align="right">
            <div style="padding-left:8px;top:30px;"><table><tr><td><a href="javascript:selectAll()"><img id="imageAll" border="0" src="/rgdweb/common/images/add.png" /></a></td><td><a href="javascript:selectAll()" style="color:white;">Select All</a></td></tr></table> </div>

            <div style="height:400px; overflow:  auto; background-color:white; ackground-color:#F6F6F6; border: 3px outset #eeeeee;">
            <table border=0  width="100%" >
            <%
                for (Sample samp: samples) {
                    if (samp.getId() == 900 || samp.getId() == 901)   {
                        if (session.getAttribute("showHidden") == null || !session.getAttribute("showHidden").equals("1")) {
                            continue;
                        }
                    }

                %>
                   <tr>
                       <td valign="left">
                           <table border=0 id="table<%=samp.getId()%>" width="100%" style="border-bottom: 2px solid #eeeeee;" >
                               <tr>
                                   <td width=20><a href="javascript:selectIt('<%=samp.getAnalysisName()%>', '<%=samp.getId()%>')"><img id="image<%=samp.getId()%>" border="0" src="/rgdweb/common/images/add.png" /></a></td>
                                   <td><table cellpadding="0" cellspacing="0" width="100%"><tr>
                                       <td><a href="javascript:selectIt('<%=samp.getAnalysisName()%>','<%=samp.getId()%>')"><%=samp.getAnalysisName()%></a></td>
                                       <td align="right"><% if( samp.getStrainRgdId()!=0 ) { %>
                                         <a href="<%=Link.strain(samp.getStrainRgdId())%>">see strain report</a>
                                       <%}%></td>
                                   </tr></table></td>
                               </tr>
                               <tr>
                                   <td>&nbsp;</td>
                                   <td style="font-size:11px;">
                                       <table>

                                           <% if (samp.getSequencedBy() != null) { %>
                                           <tr>
                                               <td valign="top" style="font-size:10px; font-weight:700;">Sequenced By:</td>
                                               <td style="font-size:10px;"><%=samp.getSequencedBy()%></td>
                                           </tr>
                                           <% } %>
                                           <% if (samp.getSequencer() != null) { %>
                                           <tr>
                                               <td style="font-size:10px; font-weight:700;">Platform:</td>
                                               <td style="font-size:10px;"><%=samp.getSequencer()%></td>
                                           </tr>
                                           <% } %>
                                           <% if (samp.getSecondaryAnalysisSoftware() != null) { %>
                                           <tr>
                                               <td style="font-size:10px; font-weight:700;">Secondary Analysis:</td>
                                               <td style="font-size:10px;"><%=samp.getSecondaryAnalysisSoftware()%></td>
                                           </tr>
                                           <% } %>
                                           <% if (samp.getWhereBred() != null) { %>
                                           <tr>
                                               <td style="font-size:10px; font-weight:700;">Breeder:</td>
                                               <td style="font-size:10px;"><%=samp.getWhereBred()%></td>
                                           </tr>
                                           <% } %>
                                           <% if (samp.getGrantNumber() != null) { %>
                                           <tr>
                                               <td style="font-size:10px; font-weight:700;">Grant Information:</td>
                                               <td style="font-size:10px;"><%=samp.getGrantNumber()%></td>
                                           </tr>
                                           <% } %>
                                       </table>
                                   </td>
                               </tr>
                           </table>
                       </td>
                   </tr>

                <% } %>
            </table>
            </div>
        </td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
        <td  valign="top" align="center" width=225>
            <div style="padding-left:8px;top:30px;"><table><tr><td>&nbsp;</td></tr></table> </div>
            <div style="height:400px; overflow:  auto;background-color:#F1FBFC; border:3px outset #eeeeee;">
                <br>
                        <div class="demo">
                        <ul id="sortable">
                            <!--
                            <li class="ui-state-default"><span class="ui-icon ui-icon-arrowthick-2-n-s"></span>Item 1</li>
                             -->
                        </ul>
                        </div><!-- End demo -->
                <br>
                </div>
        </td>
        <td>&nbsp;</td>
        <td valign="top">
            <input class="continueButton"  type="button" value="Continue..." onClick="submitPage()"/>
        </td>

    </tr>
</table>
</div>

</form>

<script>
<% for (Sample samp: samples) {

        for (int j=1; j< 1000 ; j++) {
            String sampStr = req.getParameter("sample" + j );

            if (sampStr.equals("")) {
                break;
            }
            if (sampStr.equals(samp.getId() + "")) {
        %>
                selectIt('<%=samp.getAnalysisName()%>', '<%=samp.getId()%>');
          <%
            }
        }
 } %>
</script>

<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>



<%@ include file="/common/footerarea.jsp" %>



