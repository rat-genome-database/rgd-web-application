<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>

<% String pageTitle = "GA Tool: Annotation Search and Export";
    String headContent = "";
    String pageDescription = "Generate an annotation report for a list of genes.";%>
<%@ include file="/common/headerarea.jsp" %>
<%@ include file="gaHeader.jsp" %>
<%@ include file="menuBar.jsp" %>

<% if (om.getMapped().size()==0) { %>
    <br>
    <div style="font-size:20px; font-weight:700;"><%=om.getMapped().size()%> Genes in set</div>
<%  return;
 } %>






<%
    String firstId = null;
    List symbols = (List) request.getAttribute("symbols");
%>


<div id="wrap"  style="border: 1px solid #346F97; background-color: #F0F6F9; width:1100px; overflow-x: scroll; padding:10px;">

<!--
    <ul id="mycarousel" class="jcarousel-skin-tango">
-->

    <table>
      <tr>

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


</div>

<div id="content" style="font-size:22px;"><br>Please select an object from the list above <br><br></div>

<%
     if (om.getLog().size() > 0) {
%>

<br>
<table class="gaTable" width="100%">
    <tr><td style="font-weight:700; font-size:16px;">Symbol Substitutions</td></tr>
<%
    Iterator logIt = om.getLog().iterator();
    while (logIt.hasNext()) {
        String msg = (String) logIt.next();

        if (RgdContext.isChinchilla(request)) {
            msg = msg.replaceAll("\\sRGD\\s"," CRRD ");
        }


    %>
        <tr>
            <td><%=msg%></td>
        </tr>

    <%
    }
%>
</table>
<% } %>


<br>

<%
    if (!req.getParameter("rgdId").equals("")) {
        firstId = req.getParameter("rgdId");
    }
%>

<script type="text/javascript">

    <% if (firstId != null) { %>
        viewReport(<%=firstId%>);
    <% } %>
</script>


</body>
</html>