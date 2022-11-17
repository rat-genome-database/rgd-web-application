<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Sample" %>
<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.GeoRecord" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="java.util.*" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<link rel="stylesheet" type="text/css" href="/rgdweb/css/enrichment/analysis.css">
<script type="text/javascript"  src="/rgdweb/generator/generator.js"></script>
<script type="text/javascript" src="/rgdweb/js/jquery/jquery-1.12.4.min.js"></script>
<script>
    let jq = jQuery.noConflict(true);
</script>
<html>
<body style="background-color: white">
<style>
    .t{
        border:1px solid #ddd;
        border-radius:2px;
        width: 100%;
        text-align: center;
        font-size: 12px;

    }
    .t th{
        background: rgb(246,248,249); /* Old browsers */
        background: -moz-linear-gradient(top, rgba(246,248,249,1) 0%, rgba(229,235,238,1) 50%, rgba(215,222,227,1) 51%, rgba(245,247,249,1) 100%); /* FF3.6-15 */
        background: -webkit-linear-gradient(top, rgba(246,248,249,1) 0%,rgba(229,235,238,1) 50%,rgba(215,222,227,1) 51%,rgba(245,247,249,1) 100%); /* Chrome10-25,Safari5.1-6 */
        background: linear-gradient(to bottom, rgba(246,248,249,1) 0%,rgba(229,235,238,1) 50%,rgba(215,222,227,1) 51%,rgba(245,247,249,1) 100%); /* W3C, IE10+, FF16+, Chrome26+, Opera12+, Safari7+ */
        filter: progid:DXImageTransform.Microsoft.gradient( startColorstr='#f6f8f9', endColorstr='#f5f7f9',GradientType=0 );
    }
    .t td{
        max-width: 15px;
        min-width: 5px;
        padding: 2px;

    }
    .t  tr:nth-child(odd) {background-color: #f2f2f2}
    .t tr:hover {
        background-color: #daeffc;
    }

</style>

<%

    String pageTitle = "Create Geo Sample";
    String headContent = "";
    String pageDescription = "Create Geo Sample";

%>

<%@ include file="/common/headerarea.jsp" %>
<%

    String gse = request.getParameter("gse");
    String species = request.getParameter("species");
    PhenominerDAO pdao = new PhenominerDAO();
    List<GeoRecord> samples = pdao.getGeoRecords(gse,species);
    HashMap<String,String> tissueMap = new HashMap<>();
    HashMap<String,String> strainMap = new HashMap<>();
    Set<String> ages = new TreeSet<>();
    Set<String> gender = new TreeSet<>();
    HashMap<String,String> cellTypeMap = new HashMap<>();
    HashMap<String,String> cellLineMap = new HashMap<>();
    Set<String> notes = new TreeSet<>();
    for(GeoRecord s:samples){
        if(s.getSampleTissue() != null)
            tissueMap.put(s.getSampleTissue(),Objects.toString(s.getRgdTissueTermAcc(),""));
        if(s.getSampleStrain() != null)
            strainMap.put(s.getSampleStrain(),Objects.toString(s.getRgdStrainTermAcc(),""));
        if(s.getSampleAge() != null)
            ages.add(s.getSampleAge());
        if(s.getSampleGender() != null)
            gender.add(s.getSampleGender());
        if(s.getSampleCellLine() != null)
            cellLineMap.put(s.getSampleCellLine(),Objects.toString(s.getRgdCellTermAcc(),""));
        if(s.getSampleCellType() != null)
            cellTypeMap.put(s.getSampleCellType(),Objects.toString(s.getRgdCellTermAcc(),""));
    }
    int size = 0;
    String idName = "";
    boolean createSample = false;
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

<br>
<div>
    <%
        if(samples.size() != 0) {
    %>
        <form action="experiments.html" method="POST">
            <input type="hidden" value="<%=request.getParameter("token")%>" name="token" />
            <table  class="t">
                <tr>
                    <input type="hidden" id="geoId" name="geoId" value=<%=gse%> />
                    <td style="color: #24609c; font-weight: bold;">Geo Accession Id: </td><td><a href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=<%=samples.get(0).getGeoAccessionId()%>" target="_blank"><%=samples.get(0).getGeoAccessionId()%></a></td>
                    <td style="color: #24609c; font-weight: bold;">Study Title: </td><td><%=samples.get(0).getStudyTitle()%></td>
                    <td style="color: #24609c; font-weight: bold;">PubMed Id: </td><td><%=samples.get(0).getPubmedId()%></td>
                    <td style="color: #24609c; font-weight: bold;">Select status: </td>
                    <td><select id="status" name="status" >
                        <option value="loaded">Loaded</option>
                        <option  value="not4Curation">Not For Curation</option>
                        <option  value="pending">Pending</option>
                    </select>
                    </td>
                    <td><input type="submit" value="Update Status"/></td>
                  </tr>

            </table>
            <input type="hidden" id="species" name="species" value="<%=species%>" />
            <input type="hidden" id="act" name="act" value="update" />
        </form>
    <%
        }
    %>



        <form action="experiments.html" method="POST">

            <input type="submit" value="Create Samples"/> <br><br>
            <table class="table table-striped">

            <%
      int tcount = 0;
if (tissueMap.isEmpty()){ %>
                <tr>
                    <td><label for="tissue<%=tcount%>" style="color: #24609c; font-weight: bold;">Tissue:  &nbsp&nbsp</label><input type="text" name="tissue<%=tcount%>" id="tissue<%=tcount%>" value="None imported!" readonly></td>
                    <td><label for="tissueId<%=tcount%>" style="color: #24609c; font-weight: bold;">Tissue Id: &nbsp&nbsp </label>
                        <%--                    <input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="<%=tissueMap.get(tissue)%>">--%>
                        <input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="" value="" onblur="lostFocus('uberon')">
                        <input type="text" id="uberon_term<%=tcount%>" name="uberon_term<%=tcount%>" style="border: none; background: transparent;" value="" readonly/>
                        <a href="" id="uberon_popup<%=tcount%>" style="color:black;">Ont Tree</a>
                    </td>
                    <td></td>
                    <td></td>
                </tr>

 <%tcount++;}
   else {  for(String tissue: tissueMap.keySet()){
  %>
            <tr>
                <td><label for="tissue<%=tcount%>" style="color: #24609c; font-weight: bold;">Tissue:  &nbsp&nbsp</label><input type="text" name="tissue<%=tcount%>" id="tissue<%=tcount%>" value="<%=tissue%>" readonly></td>
                <td><label for="tissueId<%=tcount%>" style="color: #24609c; font-weight: bold;">Tissue Id: &nbsp&nbsp </label>
<%--                    <input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="<%=tissueMap.get(tissue)%>">--%>
                    <input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="<%=tissueMap.get(tissue)%>" value="" onblur="lostFocus('uberon')">
                    <input type="text" id="uberon_term<%=tcount%>" name="uberon_term<%=tcount%>" style="border: none; background: transparent;" value="" readonly/>
                    <a href="" id="uberon_popup<%=tcount%>" style="color:black;">Ont Tree</a>
                </td>
                <td></td>
                <td></td>
            </tr>

        <%tcount++;}

      }
                    int scount = 0;
        if (strainMap.isEmpty()){%>
                <tr>
                    <td><label for="strain<%=scount%>" style="color: #24609c; font-weight: bold;">Strain: &nbsp&nbsp </label><input type="text" name="strain<%=scount%>" id="strain<%=scount%>" value="No strains imported!" readonly></td>
                    <td>
                        <label for="strainId<%=scount%>" style="color: #24609c; font-weight: bold;">Strain Id: &nbsp&nbsp </label>
<%--                        <input type="text" name="strainId<%=scount%>" id="strainId<%=scount%>" value="">--%>
                        <input type="text" name="strainId<%=scount%>" id="strainId<%=scount%>" value="" value="" onblur="lostFocus('rs')">
                        <input type="text" id="rs_term<%=scount%>" name="rs_term<%=scount%>" style="border: none; background: transparent;" value=""readonly/>
                        <a href="" id="rs_popup<%=scount%>" style="color:black;">Ont Tree</a>
                    </td>
                    <td></td>
                    <td></td>
                </tr>
<% scount++;}
   else {
          for(String strain: strainMap.keySet()){
                %>
            <tr>
                <td><label for="strain<%=scount%>" style="color: #24609c; font-weight: bold;">Strain: &nbsp&nbsp </label><input type="text" name="strain<%=scount%>" id="strain<%=scount%>" value="<%=strain%>" readonly></td>
                <td>
                    <label for="strainId<%=scount%>" style="color: #24609c; font-weight: bold;">Strain Id: &nbsp&nbsp </label>
<%--                    <input type="text" name="strainId<%=scount%>" id="strainId<%=scount%>" value="">--%>
                    <input type="text" name="strainId<%=scount%>" id="strainId<%=scount%>" value=""  value="" onblur="lostFocus('rs')">
                    <input type="text" id="rs_term<%=scount%>" name="rs_term<%=scount%>" style="border: none; background: transparent;" value="" readonly/>
                    <a href="" id="rs_popup<%=scount%>" style="color:black;">Ont Tree</a>
                </td>
                <td></td>
                <td></td>
            </tr>
                <%      scount++;
                }
            }
            int clcount = 0;
   if (cellLineMap.isEmpty()) { %>
                <tr>
                    <td><label for="cellLine<%=clcount%>" style="color: #24609c; font-weight: bold;">cellLine: &nbsp&nbsp </label><input type="text" name="cellLine<%=clcount%>" id="cellLine<%=clcount%>" value="No cell lines imported!" readonly></td>
                    <td><label for="cellLineId<%=clcount%>" style="color: #24609c; font-weight: bold;">cellLine Id: &nbsp&nbsp </label><input type="text" name="cellLineId<%=clcount%>" id="cellLineId<%=clcount%>" value=""> </td>
                    <td></td>
                    <td></td>
                </tr>
                <%clcount++;
   }
      else for(String cellLine: cellLineMap.keySet()){
        %>
                <tr>
                    <td><label for="cellLine<%=clcount%>" style="color: #24609c; font-weight: bold;">cellLine: &nbsp&nbsp </label><input type="text" name="cellLine<%=clcount%>" id="cellLine<%=clcount%>" value="<%=cellLine%>" readonly></td>
                    <td><label for="cellLineId<%=clcount%>" style="color: #24609c; font-weight: bold;">cellLine Id: &nbsp&nbsp </label><input type="text" name="cellLineId<%=clcount%>" id="cellLineId<%=clcount%>" value="<%=cellLineMap.get(cellLine)%>"> </td>
                    <td></td>
                    <td></td>
                </tr>

                <%    clcount++;
                    }
                    int cTcount = 0;
                    if (cellTypeMap.isEmpty()) {%>
                <tr>
                    <td><label for="cellType<%=cTcount%>" style="color: #24609c; font-weight: bold;">cellType: &nbsp&nbsp </label><input type="text" name="cellType<%=cTcount%>" id="cellType<%=cTcount%>" value="No cell types imported!" readonly></td>
                    <td><label for="cellTypeId<%=cTcount%>" style="color: #24609c; font-weight: bold;">cellType Id: &nbsp&nbsp </label>
<%--                        <input type="text" name="cellTypeId<%=cTcount%>" id="cellTypeId<%=cTcount%>" value=""> --%>
                        <input type="text" name="cellTypeId<%=cTcount%>" id="cellTypeId<%=cTcount%>" value=""  value="" onblur="lostFocus('cl')">
                        <input type="text" id="cl_term<%=cTcount%>" name="cl_term<%=cTcount%>" value="" style="border: none; background: transparent;" readonly/>
                        <a href="" id="cl_popup<%=cTcount%>" style="color:black;">Ont Tree</a>
                    </td>
                    <td></td>
                    <td></td>
                </tr>
                <%   cTcount++;
                    }
                else for(String cellType: cellTypeMap.keySet()){
                %>
                <tr>
                    <td><label for="cellType<%=cTcount%>" style="color: #24609c; font-weight: bold;">cellType: &nbsp&nbsp </label><input type="text" name="cellType<%=cTcount%>" id="cellType<%=cTcount%>" value="<%=cellType%>" readonly></td>
                    <td><label for="cellTypeId<%=cTcount%>" style="color: #24609c; font-weight: bold;">cellType Id: &nbsp&nbsp </label>
                        <%--                        <input type="text" name="cellTypeId<%=cTcount%>" id="cellTypeId<%=cTcount%>" value=""> --%>
                        <input type="text" name="cellTypeId<%=cTcount%>" id="cellTypeId<%=cTcount%>" value=""  value="" onblur="lostFocus('cl')">
                        <input type="text" id="cl_term<%=cTcount%>" name="cl_term<%=cTcount%>" value="" style="border: none; background: transparent;" readonly/>
                        <a href="" id="cl_popup<%=cTcount%>" style="color:black;">Ont Tree</a>
                    </td>
                    <td></td>
                </tr>


                <%   cTcount++;
                    }
                  int ageCount = 0;
                    if (ages.isEmpty()){%>
                <tr>
                    <td><label for="age<%=ageCount%>" style="color: #24609c; font-weight: bold;">Age: &nbsp&nbsp </label><input type="text" name="age<%=ageCount%>" id="age<%=ageCount%>" ></td>
                    <td><label for="ageLow<%=ageCount%>" style="color: #24609c; font-weight: bold;">Age (in days) Low:  &nbsp&nbsp</label><input type="text" name="ageLow<%=ageCount%>" id="ageLow<%=ageCount%>" > </td>
                    <td><label for="ageHigh<%=ageCount%>" style="color: #24609c; font-weight: bold;">Age (in days) High: &nbsp&nbsp </label><input type="text" name="ageHigh<%=ageCount%>" id="ageHigh<%=ageCount%>" > </td>
                    <td><label for="lifeStage<%=ageCount%>" style="color: #24609c; font-weight: bold;"> Life Stage: &nbsp&nbsp </label><input type="text" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>"></td>
                </tr>
                <%ageCount++;}
                    else {
                    for(String age: ages){
                %>
            <tr>
                <td><label for="age<%=ageCount%>" style="color: #24609c; font-weight: bold;">Age: &nbsp&nbsp </label><input type="text" name="age<%=ageCount%>" id="age<%=ageCount%>" value="<%=age%>" readonly></td>
                <td><label for="ageLow<%=ageCount%>" style="color: #24609c; font-weight: bold;">Age (in days) Low:  &nbsp&nbsp</label><input type="text" name="ageLow<%=ageCount%>" id="ageLow<%=ageCount%>" > </td>
                <td><label for="ageHigh<%=ageCount%>" style="color: #24609c; font-weight: bold;">Age (in days) High: &nbsp&nbsp </label><input type="text" name="ageHigh<%=ageCount%>" id="ageHigh<%=ageCount%>" > </td>
                <td><label for="lifeStage<%=ageCount%>" style="color: #24609c; font-weight: bold;"> Life Stage: &nbsp&nbsp </label><input type="text" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>"></td>
            </tr>

                <%
                    ageCount++;
                }   }
                    int gcount = 0;
                    if (gender.isEmpty()){%>
                <tr>
                    <td><label for="gender<%=gcount%>" style="color: #24609c; font-weight: bold;">Sex: &nbsp&nbsp </label><input type="text" name="gender<%=gcount%>" id="gender<%=gcount%>"></td>
                    <td><label for="sex<%=gcount%>" style="color: #24609c; font-weight: bold;">Select Sex:  &nbsp&nbsp</label><select name="sex<%=gcount%>" id="sex<%=gcount%>">
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                        <option value="both">Both</option>
                        <option value="not specified" selected>Not Specified</option>
                    </select>
                    </td>
                </tr>
                <%  gcount++;}
                    else{
                    for(String g: gender){
                %>
                <tr>
                    <td><label for="gender<%=gcount%>" style="color: #24609c; font-weight: bold;">Sex: &nbsp&nbsp </label><input type="text" name="gender<%=gcount%>" id="gender<%=gcount%>" value="<%=g%>" readonly></td>
                    <td><label for="sex<%=gcount%>" style="color: #24609c; font-weight: bold;">Select Sex:  &nbsp&nbsp</label><select name="sex<%=gcount%>" id="sex<%=gcount%>">
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                        <option value="both">Both</option>
                        <option value="not specified">Not Specified</option>
                    </select></td>
                    <td></td>
                    <td></td>
                 </tr>

                <%
                        gcount++;
                    }   }
                    int notesCnt = 0;%>
                <tr>
                    <td><label for="notesId<%=notesCnt%>" style="color: #24609c; font-weight: bold;">Public Notes: &nbsp&nbsp </label><textarea name="notesId<%=notesCnt%>" id="notesId<%=notesCnt%>" style="height: 60px"></textarea></td>
                    <td><label for="cNotesId<%=notesCnt%>" style="color: #24609c; font-weight: bold;">Curator Notes: &nbsp&nbsp </label><textarea name="cNotesId<%=notesCnt%>" id="cNotesId<%=notesCnt%>" style="height: 60px"></textarea></td>
                    <td></td>
                    <td></td>
                </tr>
                <%notesCnt++;%>

    </table>
<%--            <input type="text" id = "<%=ontId%>_acc_id" name="<%=ontId%>_acc_id" size="50" value="" onblur="lostFocus('<%=ontId%>')">--%>
<%--            <input type="hidden" id="<%=ontId%>_term" name="<%=ontId%>_term" value=""/>--%>
<%--            <a href="" id="<%=ontId%>_popup" style="color:black;">Ont Tree</a>--%>
    <input type="hidden" id="tcount" name="tcount" value="<%=tcount%>" />
            <input type="hidden" id="gcount" name="gcount" value="<%=gcount%>" />
    <input type="hidden" id="scount" name="scount" value="<%=scount%>" />
    <input type="hidden" id="ctcount" name="ctcount" value="<%=cTcount%>" />
    <input type="hidden" id="clcount" name="clcount" value="<%=clcount%>" />
    <input type="hidden" id="agecount" name="agecount" value="<%=ageCount%>" />
    <input type="hidden" id="notescount" name="notescount" value="<%=notesCnt%>">
    <input type="hidden" id="gse" name="gse" value="<%=gse%>" />
    <input type="hidden" id="species" name="species" value="<%=species%>" />
    </form>
</div>


</body>
</html>
<%@ include file="/common/footerarea.jsp"%>