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


    <form action="editSamples.html" method="POST" id="updateSample">
        <input type="submit" value="Update Samples" style="float: right;"/>
        <table class="table table-striped">
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
            <br><input type="text" id="rs<%=cnt%>_term" name="rs<%=cnt%>_term" value="" style="border: none; background: transparent;width: 100%" readonly/>
            <a href="" id="rs<%=cnt%>_popup" onclick="ontPopup('strainId<%=cnt%>','rs','rs<%=cnt%>_term')" style="color:black;">Ont Tree</a></td>

            <td><input name="cellTypeId<%=cnt%>" id="cellTypeId<%=cnt%>" value="<%=Objects.toString(s.getCellTypeAccId(),"")%>">
                <br><input type="text" id="cl<%=cnt%>_term" name="cl<%=cnt%>_term" value="" style="border: none; background: transparent;width: 100%" readonly/>
                <a href="" id="cl<%=cnt%>_popup" onclick="ontPopup('cellTypeId<%=cnt%>','cl','cl<%=cnt%>_term')" style="color:black;">Ont Tree</a></td>
            <td><input name="cellLine<%=cnt%>" id="cellLine<%=cnt%>" value="<%=Objects.toString(s.getCellLineId(),"")%>"></td>
            <td><input name="tissueId<%=cnt%>" id="tissueId<%=cnt%>" value="<%=Objects.toString(s.getTissueAccId(),"")%>">
                <br><input type="text" id="uberon<%=cnt%>_term" name="uberon<%=cnt%>_term" value="" style="border: none; background: transparent;width: 100%" readonly/>
                <a href="" id="uberon<%=cnt%>_popup" onclick="ontPopup('tissueId<%=cnt%>','uberon','uberon<%=cnt%>_term')" style="color:black;">Ont Tree</a></td>
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
        </table>
        <input type="submit" value="Update Samples" style="float: right;"/>
    </form>

<%@ include file="/common/footerarea.jsp"%>
<script>
    $(document).ready(function() {
        $('input').mouseenter(function() {
            var $txt = $(this).val();
            $(this).attr('title', $txt);
        })
    })
    function submitForm()
    {
        var ageLow = document.querySelectorAll('[id^="ageLow"]');
        var ageHigh = document.querySelectorAll('[id^="ageHigh"]');
        var bool = true;
        var regex = /^0$|^-?[1-9]\d*(\.\d+)?$/;
        for (var i = 0 ; i < ageLow.length; i++){
            var numbool = ageLow[i].value === "" || regex.test(ageLow[i].value);
            if ((ageLow[i].value === "" && ageHigh[i].value !=="") || !numbool) {
                ageLow[i].focus();
                ageLow[i].style.border="2px solid red";
                bool = false;
            }
            else{
                ageLow[i].style.border="1px solid black";
            }
            numbool = ageHigh[i].value === "" || regex.test(ageHigh[i].value);
            if (( ageHigh[i].value === "" && ageLow[i].value!=="") || !numbool){
                ageHigh[i].focus();
                ageHigh[i].style.border="2px solid red";
                bool = false;
            }
            else{
                ageHigh[i].style.border="1px solid black";
            }
            if (Number(ageLow[i].value) > Number(ageHigh[i].value) ) {
                ageHigh[i].focus();
                ageHigh[i].style.border="2px solid red";
                ageLow[i].style.border="2px solid red";
                bool = false;
            }
        }
        if (bool)
            document.getElementById("updateSample").submit();
    }
</script>