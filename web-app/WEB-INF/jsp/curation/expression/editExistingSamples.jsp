<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Sample" %>
<%@ page import="java.util.Objects" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.HashMap" %>
<script type="text/javascript" src="/rgdweb/js/ontPopUp/ontPopupBrowser.js"></script>
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
            <br><input type="text" id="rs<%=cnt%>_term" name="rs<%=cnt%>_term" value="" style="border: none; background: transparent;" readonly/>
            <a href="" id="rs<%=cnt%>_popup" onclick="ontPopupGroup('strainId','rs','<%=cnt%>')" style="color:black;">Ont Tree</a></td>

            <td><input name="cellTypeId<%=cnt%>" id="cellTypeId<%=cnt%>" value="<%=Objects.toString(s.getCellTypeAccId(),"")%>">
                <br><input type="text" id="cl<%=cnt%>_term" name="cl<%=cnt%>_term" value="" style="border: none; background: transparent;" readonly/>
                <a href="" id="cl<%=cnt%>_popup" onclick="ontPopupGroup('cellTypeId','cl','<%=cnt%>')" style="color:black;">Ont Tree</a></td>
            <td><input name="cellLine<%=cnt%>" id="cellLine<%=cnt%>" value="<%=Objects.toString(s.getCellLineId(),"")%>"></td>
            <td><input name="tissueId<%=cnt%>" id="tissueId<%=cnt%>" value="<%=Objects.toString(s.getTissueAccId(),"")%>">
                <br><input type="text" id="uberon<%=cnt%>_term" name="uberon<%=cnt%>_term" value="" style="border: none; background: transparent;" readonly/>
                <a href="" id="uberon<%=cnt%>_popup" onclick="ontPopupGroup('tissueId','uberon','<%=cnt%>')" style="color:black;">Ont Tree</a></td>
            <td><input name="geoAcc<%=cnt%>" id="geoAcc<%=cnt%>" value="<%=Objects.toString(s.getGeoSampleAcc(),"")%>"></td>
            <td><select name="sex<%=cnt%>" id="sex<%=cnt%>">
                <option value="male" <%=Utils.stringsAreEqual(s.getSex(),"male") ? "selected" : ""%>>Male</option>
                <option value="female" <%=Utils.stringsAreEqual(s.getSex(),"female") ? "selected" : ""%>>Female</option>
                <option value="both" <%=Utils.stringsAreEqual(s.getSex(),"both") ? "selected" : ""%>>both</option>
                <option value="not specified" <%=Utils.stringsAreEqual(s.getSex(),"not specified") ? "selected" : ""%>>Not Specified</option>
            </select></td>
            <td><input name="ageLow<%=cnt%>" id="ageLow<%=cnt%>" value="<%=Objects.toString(s.getAgeDaysFromLowBound(),"")%>"></td>
            <td><input name="ageHigh<%=cnt%>" id="ageHigh<%=cnt%>" value="<%=Objects.toString(s.getAgeDaysFromHighBound(),"")%>"></td>
            <td>
                <fieldset>
                    <label><input type="checkbox" name="lifeStage<%=cnt%>" id="lifeStage<%=cnt%>" value="embryonic"
                        <%=!Utils.isStringEmpty(s.getLifeStage()) ?  s.getLifeStage().contains("embryonic") ? "checked": "":""%>> embryonic</label>
                    <label><input type="checkbox" name="lifeStage<%=cnt%>" id="lifeStage<%=cnt%>" value="neonatal"
                        <%=!Utils.isStringEmpty(s.getLifeStage()) ?  s.getLifeStage().contains("neonatal") ? "checked": "":""%>> neonatal</label>
                    <label><input type="checkbox" name="lifeStage<%=cnt%>" id="lifeStage<%=cnt%>" value="weanling"
                        <%=!Utils.isStringEmpty(s.getLifeStage()) ?  s.getLifeStage().contains("weanling") ? "checked": "":""%>> weanling</label><br>
                    <label><input type="checkbox" name="lifeStage<%=cnt%>" id="lifeStage<%=cnt%>" value="juvenile"
                        <%=!Utils.isStringEmpty(s.getLifeStage()) ?  s.getLifeStage().contains("juvenile") ? "checked": "":""%>> juvenile</label>
                    <label><input type="checkbox" name="lifeStage<%=cnt%>" id="lifeStage<%=cnt%>" value="adult"
                        <%=!Utils.isStringEmpty(s.getLifeStage()) ?  s.getLifeStage().contains("adult") ? "checked": "":""%>> adult</label>
                    <label><input type="checkbox" name="lifeStage<%=cnt%>" id="lifeStage<%=cnt%>" value="aged"
                        <%=!Utils.isStringEmpty(s.getLifeStage()) ?  s.getLifeStage().contains("aged") ? "checked": "":""%>> aged</label>
                    <%--                            <input type="text" name="lifeStage<%=cnt%>" id="lifeStage<%=cnt%>">--%>
                </fieldset>
            </td>
            <td><textarea name="notes<%=cnt%>" id="notes<%=cnt%>"><%=Objects.toString(s.getNotes(),"")%></textarea></td>
            <td><textarea name="cNotes<%=cnt%>" id="cNotes<%=cnt%>"><%=Objects.toString(s.getCuratorNotes(),"")%></textarea></td>
        </tr>
        <% cnt++;} %>
        <input type="hidden" id="count" name="count" value="<%=cnt%>" />
    </form>
</table>
<%@ include file="/common/footerarea.jsp"%>