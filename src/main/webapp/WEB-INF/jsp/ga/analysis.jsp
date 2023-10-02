<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Aspect" %>
<%@ page import="java.net.URI" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>

<html>
<body>
<% String pageTitle = "GA Tool: Annotation Search and Export";
    String headContent = "";
    String pageDescription = "Generate an annotation report for a list of genes.";%>
<%@ include file="/common/headerarea.jsp" %>
<%@ include file="gaHeader.jsp" %>
<%--@ include file="rgdHeader.jsp" --%>
<%@ include file="menuBar.jsp" %>


<script>
    function compare() {
        var terms="";
        var inputs = window.document.getElementsByTagName('input');
        var count=0;
        for(var i=0; i < inputs.length; i++){ //iterate through all input elements
            if (inputs[i].type.toLowerCase() == 'checkbox') {
                if (inputs[i].checked) {
                    count++;
                    if (terms == "") {
                        terms = inputs[i].id;
                    }else {
                        terms += "," + inputs[i].id;
                    }
                }
            }
        }
        if (count < 2) {
            $("#new-nav").html("Select 2 or more terms below");
            return;
        }
        $("#new-nav").html("Loading......  (may take up to 60 seconds for large gene sets)");
        $.ajax({
            url: "/rgdweb/ga/cross.html",
            data: {species:"<%=req.getParameter("species")%>", genes: "<%=om.getMappedAsString()%>", terms: terms },
            type: "POST",
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                document.getElementById("new-nav").innerHTML = XMLHttpRequest.status + " " + XMLHttpRequest.statusText + "<br>" + url;
            },
            success: function(data) {
                document.getElementById("new-nav").innerHTML = data;
                regCrossHeader("cross1");
            }
        });
    }
    var count=0;
    function load(divId, aspect) {
        var species = <%=req.getParameter("species")%>;
        if(species == <%=SpeciesType.HUMAN%> && aspect == '<%=Aspect.MAMMALIAN_PHENOTYPE%>')
                aspect = '<%=Aspect.HUMAN_PHENOTYPE%>';
        $.ajax({
            url: "/rgdweb/ga/terms.html",
            data: {aspect: aspect, species:"<%=req.getParameter("species")%>", genes: "<%=om.getMappedAsString()%>" },
            type: "GET",
            error: function(XMLHttpRequest, textStatus, errorThrown) {
                        //$("#new-nav").html("had a 500 for " + aspect);
                if (count < 3) {
                    count++;
                    load(divId, aspect);
                }else {
                    alert('status:' + XMLHttpRequest.status + ', status text: ' + XMLHttpRequest.statusText);
                }
            },
            success: function(data) {
                //alert("success " + aspect);
                document.getElementById(divId).innerHTML = data
                        var imgs = document.getElementById(divId).getElementsByTagName("img");
                        for (i=0; i < imgs.length; i++) {
                            if (imgs[i]) {
                               regHeader(imgs[i].id.split("_")[0]);
                            }
                        }
            }
        });
    }
</script>

<br>
<div id="content">
<div id="new-nav" style="padding: 5px; border: 1px solid black; background-color:#F0F6F9">Cross Analysis: Select terms below from <span style="color:steelblue" >Disease, Pathway, Mammalian Phenotype, Biological Process, Cellular Component, Molecular Function, ChEBI</span> </div>

<script>
</script>

<br>

<div style="font-size:20px; font-weight:700;"><%=om.getMapped().size()%> Genes in set</div>

<% if (om.getMapped().size() == 0) {
    return;
}%>
    <%
        String firstId = null;
        List symbols = (List) request.getAttribute("symbols");
    %>
   <% List<String> ontologies = req.getParameterValues("o"); %>

<br>
<%
  String loadingMessage = "Loading...&nbsp;&nbsp;(Please&nbsp;Wait)";
%>



        <!--
            <ul id="mycarousel" class="jcarousel-skin-tango">
        -->

        <table>
            <tr style="display:none">

                <%
                    int i = 1;
                    Iterator symbolIt = om.getMapped().iterator();
                    while (symbolIt.hasNext()) {
                        Object obj = symbolIt.next();
                        String symbol = "";
                        int rgdId=-1;
                        String type="";
                        if (obj instanceof Gene) {
                            Gene g = (Gene) obj;
                            symbol=g.getSymbol();
                            rgdId=g.getRgdId();
                            type="gene";
                            if (firstId == null) {
                                firstId=rgdId + "";
                            }
                        }
                        if (obj instanceof String) {
                            symbol=(String) obj;
                            rgdId=-1;
                        }
                        if (rgdId==-1) {
                %>
                <td><span style="color:red; font-weight:700; margin-left:7px;" class="geneList"><%=symbol%></span><span style="font-size:11px;">&nbsp;(<%=i%>)</span></td>


                <%
                } else {
                %>

                <td><a href="javascript:void(0);" style="font-size:18px;margin-left:7px;" onClick="viewReport(<%=rgdId%>,'<%=type%>')" class="geneList"><%=symbol%></a><span style="font-size:11px;">&nbsp;(<%=i%>)</span></td>

                <% }
                    i++;
                } %>
                <!--    </ul> -->

            </tr>
        </table>



<div style="background-color:#F8F8F8; width:<%=(ontologies.size() * 559)%>px; border: 1px solid #346F97;">

<table style="font-size:13px;">
    <tr>

    <%
        for (String asp: ontologies) {
    %>

        <% if (asp.equals(Aspect.DISEASE)) { %>
        <td valign="top" width=500>
            <span style="font-size:22px;font-weight:700;"><%=Aspect.getFriendlyName(Aspect.DISEASE)%></span>
            <div id="disease" style="font-weight:700; width:550px;"><br><%=loadingMessage%></div>
        </td>
        <% } %>

        <% if (asp.equals(Aspect.PATHWAY)) { %>
        <td valign="top" width=500>
            <span style="font-size:22px;font-weight:700;"><%=Aspect.getFriendlyName(Aspect.PATHWAY)%></span>
            <div id="pathway" style="font-weight:700; width:550px;"><br><%=loadingMessage%></div>
        </td>
        <% } %>

        <% if (asp.equals(Aspect.MAMMALIAN_PHENOTYPE)) {
           String aspect;
           if( Integer.parseInt(req.getParameter("species")) == SpeciesType.HUMAN)
           aspect = Aspect.getFriendlyName(Aspect.HUMAN_PHENOTYPE);
           else aspect = Aspect.getFriendlyName(Aspect.MAMMALIAN_PHENOTYPE);%>
        <td valign="top" width=500>
            <span style="font-size:22px;font-weight:700;"><%=aspect%></span>
            <div id="pheno" style="font-weight:700; width:550px;"><br><%=loadingMessage%></div>
        </td>
        <% } %>

        <% if (asp.equals(Aspect.CELLULAR_COMPONENT)) { %>
        <td valign="top" width=500>
            <span style="font-size:22px;font-weight:700;"><%=Aspect.getFriendlyName(Aspect.CELLULAR_COMPONENT)%></span>
            <div id="cc" style="font-weight:700; width:550px;"><br><%=loadingMessage%></div>
        </td>
        <% } %>

        <% if (asp.equals(Aspect.MOLECULAR_FUNCTION)) { %>
        <td valign="top" width=500>
            <span style="font-size:22px;font-weight:700;"><%=Aspect.getFriendlyName(Aspect.MOLECULAR_FUNCTION)%></span>
            <div id="mf" style="font-weight:700; width:550px;"><br><%=loadingMessage%></div>
        </td>
        <% } %>

        <% if (asp.equals(Aspect.BIOLOGICAL_PROCESS)) { %>
        <td valign="top" width=500>
            <span style="font-size:22px;font-weight:700;"><%=Aspect.getFriendlyName(Aspect.BIOLOGICAL_PROCESS)%></span>
            <div id="bp" style="font-weight:700; width:550px;"><br><%=loadingMessage%></div>
        </td>
        <% } %>

        <% if (asp.equals(Aspect.CHEBI)) {
        %>

        <td valign="top" width=500>
            <span style="font-size:22px;font-weight:700;"><%=Aspect.getFriendlyName(Aspect.CHEBI)%></span>
            <div id="chebi" style="font-weight:700; width:550px;"><br><%=loadingMessage%></div>
        </td>
        <% } %>

     <%
         }
     %>

    </tr>
</table>
       </div>
</div>

<script>
    load("disease","<%=Aspect.DISEASE%>");
    load("pathway","<%=Aspect.PATHWAY%>");
    load("pheno","<%=Aspect.MAMMALIAN_PHENOTYPE%>");
    load("mf","<%=Aspect.MOLECULAR_FUNCTION%>");
    load("cc","<%=Aspect.CELLULAR_COMPONENT%>") ;
    load("bp","<%=Aspect.BIOLOGICAL_PROCESS%>");
    load("chebi","<%=Aspect.CHEBI%>");
</script>

</body>
</html>