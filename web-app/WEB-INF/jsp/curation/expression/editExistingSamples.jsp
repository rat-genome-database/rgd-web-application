<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Sample" %>
<%@ page import="java.util.Objects" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.HashMap" %>
<script type="text/javascript"  src="/rgdweb/generator/generator.js"></script>
<script type="text/javascript" src="/rgdweb/js/jquery/jquery-1.12.4.min.js"></script>
<script>
    let jq = jQuery.noConflict(true);
</script>
<%
    String pageHeader="Edit Samples";
    String pageTitle="Edit Samples";
    String headContent="";
    String pageDescription = "Edit Samples";
    List<Sample> samples = (List<Sample>) request.getAttribute("samples");
    HashMap<String,String> tissueMap = new HashMap<>();
    HashMap<String,String> strainMap = new HashMap<>();
    HashMap<String,String> cellTypeMap = new HashMap<>();

    int size = samples.size();
    String idName = "";
    boolean createSample = true;
%>
<script>

    (function ($) {

        $(document).ready(function(){

            <% String ontId = "uberon"; %>
            <%@ include file="ontPopupConfig.jsp" %>
            <% ontId = "cl"; %>
            <%@ include file="ontPopupConfig.jsp" %>
            <% ontId = "rs"; %>
            <%@ include file="ontPopupConfig.jsp" %>
        });

    }(jq));

</script>
<%@ include file="/common/headerarea.jsp"%>
<table class="table table-striped">

    <form action="editSamples.html" method="POST">

        <tr>
            <td align="left"><input type="submit" value="Load Samples"/></td>
        </tr>
        <tr>
            <th>Sample ID: </th>
            <th>Strain ID: </th>
            <th>Cell Type ID: </th>
            <th>Cell Line ID: </th>
            <th>Tissue ID: </th>
            <th>GEO Sample:</th>
            <th>Sex: </th>
            <th>Age (in days) Low: </th>
            <th>Age (in days) High: </th>
            <th>Life Stage:</th>
            <th>Notes:</th>
        </tr>
        <%  int cnt = 0;
            for (Sample s : samples){ %>
        <tr>
            <td><input name="sample<%=cnt%>" id="sample<%=cnt%>" value="<%=s.getId()%>" readonly></td>
            <td><input name="strainId<%=cnt%>" id="strainId<%=cnt%>" value="<%=Objects.toString(s.getStrainAccId(),"")%>">
            <br><input type="text" id="rs_term<%=cnt%>" name="rs_term<%=cnt%>" value="" style="border: none; background: transparent;" readonly/>
            <a href="" id="rs_popup<%=cnt%>" style="color:black;">Ont Tree</a></td>

            <td><input name="cellTypeId<%=cnt%>" id="cellTypeId<%=cnt%>" value="<%=Objects.toString(s.getCellTypeAccId(),"")%>">
                <br><input type="text" id="cl_term<%=cnt%>" name="cl_term<%=cnt%>" value="" style="border: none; background: transparent;" readonly/>
                <a href="" id="cl_popup<%=cnt%>" style="color:black;">Ont Tree</a></td>
            <td><input name="cellLine<%=cnt%>" id="cellLine<%=cnt%>" value="<%=Objects.toString(s.getCellLineId(),"")%>"></td>
            <td><input name="tissueId<%=cnt%>" id="tissueId<%=cnt%>" value="<%=Objects.toString(s.getTissueAccId(),"")%>">
                <br><input type="text" id="uberon_term<%=cnt%>" name="uberon_term<%=cnt%>" value="" style="border: none; background: transparent;" readonly/>
                <a href="" id="uberon_popup<%=cnt%>" style="color:black;">Ont Tree</a></td>
            <td><input name="geoAcc<%=cnt%>" id="geoAcc<%=cnt%>" value="<%=Objects.toString(s.getGeoSampleAcc(),"")%>"></td>
            <td><select name="sex<%=cnt%>" id="sex<%=cnt%>">
                <option value="male" <%=Utils.stringsAreEqual(s.getSex(),"male") ? "selected" : ""%>>Male</option>
                <option value="female" <%=Utils.stringsAreEqual(s.getSex(),"female") ? "selected" : ""%>>Female</option>
                <option value="both" <%=Utils.stringsAreEqual(s.getSex(),"both") ? "selected" : ""%>>both</option>
                <option value="not specified" <%=Utils.stringsAreEqual(s.getSex(),"not specified") ? "selected" : ""%>>Not Specified</option>
            </select></td>
            <td><input name="ageLow<%=cnt%>" id="ageLow<%=cnt%>" value="<%=Objects.toString(s.getAgeDaysFromLowBound(),"")%>"></td>
            <td><input name="ageHigh<%=cnt%>" id="ageHigh<%=cnt%>" value="<%=Objects.toString(s.getAgeDaysFromHighBound(),"")%>"></td>
            <td><input name="lifeStage<%=cnt%>" id="lifeStage<%=cnt%>" value="<%=Objects.toString(s.getLifeStage(),"")%>"></td>
            <td><textarea name="notes<%=cnt%>" id="notes<%=cnt%>"><%=Objects.toString(s.getNotes(),"")%></textarea></td>
            <td><textarea name="cNotes<%=cnt%>" id="cNotes<%=cnt%>"><%=Objects.toString(s.getCuratorNotes(),"")%></textarea></td>
        </tr>
        <% cnt++;} %>
        <input type="hidden" id="count" name="count" value="<%=cnt%>" />
    </form>
</table>
<%@ include file="/common/footerarea.jsp"%>