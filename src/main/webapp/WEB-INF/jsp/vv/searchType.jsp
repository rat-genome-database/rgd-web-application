<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.vv.SampleManager" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%
String pageTitle = "Variant Visualizer (Define Region)";
String headContent = "";
String pageDescription = "Define Region";


%>
<%@ include file="/common/headerarea.jsp" %>
<%@ include file="carpeHeader.jsp"%>

<% try { %>


<%

    int mapKey = (Integer) request.getAttribute("mapKey");

    Boolean positionSet = (Boolean) request.getAttribute("positionSet");
    Boolean strainSet = (Boolean) request.getAttribute("strainSet");
    Boolean genesSet = (Boolean) request.getAttribute("genesSet");

%>

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading">Variant Visualizer</div>
</div>

<form action="annotation.html" name="optionForm">


<div class="typerMat" style="width:100%;">
  <!-- <div class="typerTitle"><div class="typerTitleSub">Variant&nbsp;Visualizer</div></div>-->
    <table width="100%" class="stepLabel" cellpadding=0 cellspacing=0 border=0>
        <tr>
            <td colspan=2>
                <table align="center" width="95%" cellpadding=0 cellspacing=0>
                    <tr><td style="color:#FFCF3E;">&nbsp;</td></tr>
                </table>
            </td>
        </tr>
        <tr>
            <td style="padding:10px;">
                Select an Assembly
            </td>
            <td align="left">
                <select style="height:26px; font-size:16px; width: 300px" id="mapKey" name="mapKey" onChange='location.href="?mapKey=" + this.options[this.selectedIndex].value'>
                    <option value='372' <% if (mapKey==372) out.print("selected");%>>mRatBN7.2 Assembly</option>
                    <option value='360' <% if (mapKey==360) out.print("selected");%>>RGSC Genome Assembly v6.0</option>
                <option value='70' <% if (mapKey==70) out.print("selected");%>>RGSC Genome Assembly v5.0</option>
                <option value='60' <% if (mapKey==60) out.print("selected");%>>RGSC Genome Assembly v3.4</option>
                    <option value='38' <% if (mapKey==38) out.print("selected");%>>Human Genome Assembly GRCh38</option>
                    <option value='17' <% if (mapKey==17) out.print("selected");%>>Human Genome Assembly GRCh37</option>
                    <option value='631' <% if (mapKey==631) out.print("selected");%>>Dog CanFam3.1 Assembly</option>
<%--                    <option value='910' <% if (mapKey==910) out.print("selected");%>>Pig Sscrofa10.2 Assembly</option>--%>
                    <option value='911' <% if (mapKey==911) out.print("selected");%>>Pig Sscrofa11.1 Assembly</option>
                    <option value='35' <% if (mapKey==35) out.print("selected");%>>Mouse Assembly GRCm38</option>
                    <option value='239' <% if (mapKey==239) out.print("selected");%>>Mouse Assembly GRCm39</option>
<%--                    <option value='1311' <% if (mapKey==1311) out.print("selected");%>>Green Monkey Assembly Vervet 1.1</option>--%>
                </select>
            </td>


        </tr>

        <tr>
            <td>
            <% if (strainSet) {%>
                <b>Limit your region of interest</b>
            <% } else  {%>
                <b>How would you like to search for variants?
            <% } %>

            </td>
            <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>

        </tr>
    </table>

<br>


    <input type="hidden" name="mapKey" value="<%=req.getParameter("mapKey")%>" />
    <input type="hidden" name="geneList" value="<%=req.getParameter("geneList")%>" />
    <input type="hidden" name="chr" value="<%=req.getParameter("chr")%>" />
    <input type="hidden" name="start" value="<%=req.getParameter("start")%>" />
    <input type="hidden" name="stop" value="<%=req.getParameter("stop")%>" />
    <input type="hidden" name="geneStart" value="<%=req.getParameter("geneStart")%>" />
    <input type="hidden" name="geneStop" value="<%=req.getParameter("geneStop")%>" />
    <input type="hidden" name="geneList" value="<%=req.getParameter("geneList")%>" />

    <%
    int samplesSize=100;

    if(mapKey==631 || mapKey==600){
    samplesSize=250;
    }
    for (int i=1; i<samplesSize; i++) {
        if (request.getParameter("sample" + i) != null) {
            String strain = "";
            if (i > 1) {
                strain += ",&nbsp;";
            }

            strain+= SampleManager.getInstance().getSampleName(Integer.parseInt(request.getParameter("sample" + i))).getAnalysisName();

    %>
        <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
    <%
        }
    }
    %>

    <%
        String selectTitle="Select Strains";
       // if (MapManager.getInstance().getMap(mapKey).getSpeciesTypeKey() == 1) {
       if (mapKey==37 || mapKey==38 || mapKey==17) {
            selectTitle="Select Sequences";
        }
        if (mapKey==631) {
            selectTitle="Select Breeds";
        }
        if (mapKey==911 || mapKey==1311 || mapKey==35 || mapKey==239){
            selectTitle="View EVA Variants";
        }

    %>

    <table border=0 align="center" style="padding:8px; ">
        <% if (!strainSet) {%>
        <tr>
              <td style="padding:5px;">
               <input value ="<%=selectTitle%>" type="button" onClick="this.form.action='select.html';this.form.submit();" style="border-radius:50px; font-size:18px; height:60px; width:250px" name="chr" size="6" />
            </td>
            <td style="padding:5px;" >
               <input value ="Limit by Genes" type="button" onClick="this.form.action='geneList.html';this.form.submit();"  style="border-radius:50px; font-size:18px; height:60px; width:250px" name="chr" size="6" />
            </td>
        </tr>
        <tr>
            <td  width=250 valign="top" style="font-size:14px;color:white;padding:10px;">Select Sequence Tracks</td>
            <td  width=250 valign="top" style="font-size:14px;color:white;padding:10px;">Search for strain variation based on an individual gene or gene list</td>
        </tr>
        <% }else { %>
        <tr><td>&nbsp;&nbsp;&nbsp;<br><br></td></tr>
        <% } %>
        <tr>
            <td style="padding:5px;">
               <input value ="Limit by Genomic Position" type="button" onClick="this.form.action='region.html';this.form.submit();" style="border-radius:50px;font-size:18px; height:60px; width:250px" name="chr" size="6" />
            </td>
            <td style="padding:5px;" >
               <input value ="Search by Function" type="button" onClick="location.href='/rgdweb/generator/list.html?vv=1'"  style="border-radius:50px; font-size:18px; height:60px; width:250px" name="chr" size="6" />
            </td>
            <% if (strainSet) { %>
                <td style="padding:5px;" >
                   <input value ="Enter a Gene List" type="button" onClick="this.form.action='geneList.html';this.form.submit();"  style="border-radius:50px; font-size:18px; height:60px; width:250px" name="chr" size="6" />
                </td>
            <% } %>
        </tr>
        <tr>
            <td  width=250 valign="top" style="font-size:14px;color:white;padding:10px;">A region can be defined using a genomic position or 2 gene/SSLP flanks located on the same chromosome</td>
            <td  width=250 valign="top" style="font-size:14px;color:white;padding:10px;">Build a gene list based on one or more ontology annotations</td>
            <% if (strainSet) { %>
                <td  width=250 valign="top" style="font-size:14px;color:white;padding:10px;">Select Sequence Tracks</td>
            <% } %>
        </tr>

    </table>

<br><br>
<br><br>

</form>

<% } catch (Exception e) {
    //e.printStackTrace();

} %>

<%@ include file="/common/footerarea.jsp" %>
