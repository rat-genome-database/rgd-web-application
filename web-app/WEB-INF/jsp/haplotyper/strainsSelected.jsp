<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.carpenovo.SampleManager" %>




 <div style="margin-top:12px; margin-bottom:12px;">
<table border=0 width="100%" style="border:1px dashed white; padding-bottom:5px;">
    <tr>
     <td style="font-size:11px;color:white;" >
    <%
    List<String> sampleIds = new ArrayList();

    for (int i=1; i<100; i++) {
        if (request.getParameter("sample" + i) != null) {
            String strain = "";
            if (i > 1) {
                strain += ",&nbsp;";
            }

            strain+= SampleManager.getInstance().getSampleName(Integer.parseInt(request.getParameter("sample" + i))).getAnalysisName();

    %>
        <%=strain%>
        <input type="hidden" name="sample<%=i%>" value="<%=request.getParameter("sample" + i)%>"/>
    <%
        }
    }
    %>
         <input type="hidden" name="mapKey" value="<%=request.getParameter("mapKey")%>"/>
        </td>
    </tr>
</table>
</div>


</div>





