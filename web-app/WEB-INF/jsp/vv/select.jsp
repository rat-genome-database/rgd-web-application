<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.VariantSearchBean" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    String pageTitle = "Variant Visualizer";
    String headContent = "";
    String pageDescription = "Analyze variation in next-gen strain sequence";
%>

<%@ include file="carpeHeader.jsp"%>
<%@ include file="menuBar.jsp" %>

<link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.10.0/css/all.css" integrity="sha384-AYmEC3Yw5cVb3ZcuHtOA93w35dYTsvhLPVnYs9eStHfGJvOvKxVfELGroGkvsg+p" crossorigin="anonymous"/>
<script
        src="https://code.jquery.com/jquery-1.12.4.min.js"
        integrity="sha256-ZosEbRLbNQzLpnKIkEdrPv7lOy9C27hHQ+Xp8a4MxAQ="
        crossorigin="anonymous"></script>
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
	#sortable { list-style-type: none; margin: 0; padding: 0; width: 200px; }
	#sortable li { cursor:move; margin: 0 2px 2px 2px; padding: 5px; padding-left: 5px; font-size: 14px; height: 18px; color:#01224D; }
	#sortable li span { cursor:pointer; position: absolute; margin-left: 2px; }
	</style>
	<script>
/*	$(function() {
		$( "#sortable" ).sortable();
		$( "#sortable" ).disableSelection();
	});*/

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


        if (count > 1) {

            document.getElementById("strainBox").submit();

        }else {
            alert("You must select at least one strain.")
        }
    }
</script>



<br>
<div class="typerMat">
    <form id="strainBox" action="config.html" method="post">

        <input type="hidden" name="mapKey" value="<%=req.getParameter("mapKey")%>" />

        <input type="hidden" name="geneList" value="<%=req.getParameter("geneList")%>" />
        <input type="hidden" name="chr" value="<%=req.getParameter("chr")%>" />
        <input type="hidden" name="start" value="<%=req.getParameter("start")%>" />
        <input type="hidden" name="stop" value="<%=req.getParameter("stop")%>" />

        <input type="hidden" name="geneStart" value="<%=req.getParameter("geneStart")%>" />
        <input type="hidden" name="geneStop" value="<%=req.getParameter("geneStop")%>" />

        <input type="hidden" name="geneList" value="<%=req.getParameter("geneList")%>" />
        <div class="typerTitle"><div class="typerTitleSub">Variant&nbsp;Visualizer</div></div>


<table class="stepLabel" border=0>
    <% if(request.getParameter("msg")!=null){%>
    <tr><td style="color:red"><%=request.getParameter("msg")%></td></tr>
    <%}%>
    <tr>
        <td align="left"><b>Step 1:</b> Select strains to compare</td>
        <td align="right"><%=MapManager.getInstance().getMap(mapKey).getName()%> assembly</td>
    </tr>
</table>



<table border=0  style="padding:4px;" align="center">
    <tr>
        <td  valign="top" align="right">
            <div style="padding-left:8px;top:30px;">
                <%--if(mapKey!=17){--%>
                <table><tr><td><a href="javascript:selectAll()"><img id="imageAll" border="0" src="/rgdweb/common/images/add.png" /></a></td><td><a href="javascript:selectAll()" style="color:white;">Select All</a></td></tr>
                </table>
                <%--}--%>
            </div>
            <%
             int columns=3;
             int rows=samples.size()/columns;
           //  String[][] matrix=new String[rows][columns];
                Sample[][] matrix=new Sample[rows][columns];
                int k = 0;
                int i = 0;
                for (Sample samp: samples) {

                    if (i < rows && k<columns) {
                            matrix[i][k] = samp;
                            i = i + 1;
                        }

                        if (i >=rows && k < columns) {
                            k = k + 1;
                            i = 0;
                        }
                    }
                %>
            <div style="; overflow:  auto; background-color:white; border: 3px outset #eeeeee;">
            <table>
            <%
                for(int r=0;r<rows;r++) {
                    %>
                <tr>

                  <%  for(int c=0;c<columns;c++){
                       Sample samp=matrix[r][c];
                        %>
                    <td>  <table  id="table<%=samp.getId()%>" style="border-bottom: 2px solid #eeeeee;" >
                          <tr>
                    <td ><a href="javascript:selectIt('<%=samp.getAnalysisName()%>', '<%=samp.getId()%>')"><img id="image<%=samp.getId()%>" border="0" src="/rgdweb/common/images/add.png" /></a></td>
                    <td><a href="javascript:selectIt('<%=samp.getAnalysisName()%>','<%=samp.getId()%>')"><%=samp.getAnalysisName()%></a></td>
                    <td>
                        <a onMouseOut="document.getElementById('div_<%=samp.getId()%>').style.visibility='hidden';" onMouseOver="document.getElementById('div_<%=samp.getId()%>').style.visibility='visible';" style="cursor: help" >
                            <i class="fa fa-question-circle" aria-hidden="true"></i>
                        </a>                        <div style="margin:10px; position:absolute; z-index:100; visibility:hidden; padding:10px;" id="div_<%=samp.getId()%>">
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
                          </tr>
                         </table>
                    </td>
                    <%
                    }
                    %>
                </tr>
                    <%
                }
               %>

            </table>

            </div>
        </td>
        <td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>


        <td valign="top">
            <input class="continueButton"  type="button" value="Continue..." onClick="submitPage()"/>
        </td>

    </tr>
</table>
    <ul id="sortable" style="visibility: hidden">
        <!--
        <li class="ui-state-default"><span class="ui-icon ui-icon-arrowthick-2-n-s"></span>Item 1</li>
         -->
    </ul>
</form>
    <%@ include file="/common/footerarea.jsp" %>
</div>



<script>
<% for (Sample samp: samples) {

        for (int j=1; j< 100 ; j++) {
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







