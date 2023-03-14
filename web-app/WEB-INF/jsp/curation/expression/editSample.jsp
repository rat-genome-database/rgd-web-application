<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Sample" %>
<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.GeoRecord" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Record" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Condition" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="java.text.DecimalFormat" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<link rel="stylesheet" type="text/css" href="/rgdweb/css/enrichment/analysis.css">
<script type="text/javascript" src="/rgdweb/js/ontPopUp/ontPopupBrowser.js"></script>
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
    .formfield * {
        vertical-align: middle;
    }
    table input{
        font-size: 14px;
    }
    /* Chrome, Safari, Edge, Opera */
    input::-webkit-outer-spin-button,
    input::-webkit-inner-spin-button {
        -webkit-appearance: none;
        margin: 0;
    }

    /* Firefox */
    input[type=number] {
        -moz-appearance: textfield;
    }
</style>

<%

    String pageTitle = "Create Geo Sample";
    String headContent = "";
    String pageDescription = "Create Geo Sample";

%>

<%@ include file="/common/headerarea.jsp" %>
<%
    OntologyXDAO ontologyXDAO = new OntologyXDAO();
    PhenominerDAO dao = new PhenominerDAO();
    DisplayMapper dm = new DisplayMapper(new HttpRequestFacade(request), (ArrayList) request.getAttribute("error"));
    FormUtility fu = new FormUtility();
    List<String> unitList = dao.getDistinct("PHENOMINER_ENUMERABLES where type=3", "value", true);
    final DecimalFormat d_f = new DecimalFormat("0.####");
    List timeUnits = new ArrayList();
    timeUnits.add("secs");
    timeUnits.add("mins");
    timeUnits.add("hours");
    timeUnits.add("days");
    timeUnits.add("weeks");
    timeUnits.add("months");
    timeUnits.add("years");
    timeUnits.add("exhaustion");
    timeUnits.add("death");
    timeUnits.add("end of the experiment");

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
    List<Sample> sampleList = pdao.getSampleByGeoStudyId(gse);
    boolean existingSample = (sampleList != null && !sampleList.isEmpty());
    boolean createSample = false;
%>
<input type="hidden" id="exist" value="<%=existingSample%>">
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
                        <option value="futureCuration">Future Curation</option>
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
        if (existingSample){
    %>
    <div>
        <p style="color: red;font-size: xx-large;">Mappings already exist. Changes will apply to all samples! </p>
    </div>
    <% } %>

        <form id="expressionSub" action="experiments.html" method="POST">

            <input id="viewSample" type="button" value="View Samples" style="float: right;" onclick="submitForm()"/> <br><br>

            <table class="table table-striped">
                <tr style="all: revert;">
                    <th>GEO</th>
                    <th></th>
                    <th>RGD</th>
                </tr>
            <%
      int tcount = 0;
if (tissueMap.isEmpty()){ %>
                <tr>
                    <td>
                        <label for="tissue<%=tcount%>" style="color: #24609c; font-weight: bold;">Tissue:  &nbsp&nbsp</label>
                    </td>
                    <td>
                            <input type="text" name="tissue<%=tcount%>" id="tissue<%=tcount%>" value="None imported!" style="border: none; background: transparent;" readonly>
                    </td>
                    <td>
                        <label for="tissueId<%=tcount%>" style="color: #24609c; font-weight: bold;">Tissue Id: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <%--                    <input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="<%=tissueMap.get(tissue)%>">--%>
                            <input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="" onblur="lostFocus('uberon')">
                            <a href="" id="uberon<%=tcount%>_popup" onclick="ontPopup('tissueId<%=tcount%>','uberon','uberon<%=tcount%>_term')" style="color:black;">Ont Tree</a><br>
                        <input type="text" id="uberon<%=tcount%>_term" name="uberon<%=tcount%>_term" style="border: none; background: transparent; width: 100%" value="" readonly/>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td></td>
                    <td></td>
                    <td>
                        <label for="vtId<%=tcount%>" style="color: #24609c; font-weight: bold;">Vertebrate Trait Id: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <%--                    <input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="<%=tissueMap.get(tissue)%>">--%>
                        <input type="text" name="vtId<%=tcount%>" id="vtId<%=tcount%>" value="" onblur="lostFocus('vt')">
                        <a href="" id="vt<%=tcount%>_popup" onclick="ontPopup('vtId<%=tcount%>','vt','vt<%=tcount%>_term')" style="color:black;">Ont Tree</a><br>
                        <input type="text" id="vt<%=tcount%>_term" name="vt<%=tcount%>_term" style="border: none; background: transparent; width: 100%" value="" readonly/>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td></td>
                    <td></td>
                    <td>
                        <label for="cmoId<%=tcount%>" style="color: #24609c; font-weight: bold;">Clinical Measurement Id: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <%--                    <input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="<%=tissueMap.get(tissue)%>">--%>
                        <input type="text" name="cmoId<%=tcount%>" id="cmoId<%=tcount%>" value="" onblur="lostFocus('cmo')">
                        <a href="" id="cmo<%=tcount%>_popup" onclick="ontPopup('cmoId<%=tcount%>','cmo','cmo<%=tcount%>_term')" style="color:black;">Ont Tree</a><br>
                        <input type="text" id="cmo<%=tcount%>_term" name="cmo<%=tcount%>_term" style="border: none; background: transparent; width: 100%" value="" readonly/>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>

 <%tcount++;}
   else {  for(String tissue: tissueMap.keySet()){
       String ontAccId = tissueMap.get(tissue);
        Term t = new Term();
       if (ontAccId!=null && !ontAccId.isEmpty() && !existingSample){
        t = ontologyXDAO.getTerm(ontAccId);}
  %>
            <tr>
                <td>
                    <label for="tissue<%=tcount%>" style="color: #24609c; font-weight: bold;">Tissue:  &nbsp&nbsp</label>
                </td>
                <td>
                    <input type="text" name="tissue<%=tcount%>" id="tissue<%=tcount%>" value="<%=tissue%>" style="border: none; background: transparent;" readonly>
                </td>
                <td>
                    <label for="tissueId<%=tcount%>" style="color: #24609c; font-weight: bold;">Tissue Id: &nbsp&nbsp </label>
                </td>
                <td>
<%--                    <input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="<%=tissueMap.get(tissue)%>">--%>
                    <input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="<%=existingSample ? "" : ontAccId%>" onblur="lostFocus('uberon')">
                    <a href="" id="uberon<%=tcount%>_popup" onclick="ontPopup('tissueId<%=tcount%>','uberon','uberon<%=tcount%>_term')" style="color:black;">Ont Tree</a><br>
                    <input type="text" id="uberon<%=tcount%>_term" name="uberon<%=tcount%>_term" value="<%=Utils.NVL(t.getTerm(),"")%>" title="<%=Utils.NVL(t.getTerm(),"")%>" style="border: none; background: transparent;width: 100%" readonly/>
                </td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
                <tr>
                    <td></td>
                    <td></td>
                    <td>
                        <label for="vtId<%=tcount%>" style="color: #24609c; font-weight: bold;">Vertebrate Trait Id: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <%--                    <input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="<%=tissueMap.get(tissue)%>">--%>
                        <input type="text" name="vtId<%=tcount%>" id="vtId<%=tcount%>" value="" onblur="lostFocus('vt')">
                        <a href="" id="vt<%=tcount%>_popup" onclick="ontPopup('vtId<%=tcount%>','vt','vt<%=tcount%>_term')" style="color:black;">Ont Tree</a><br>
                        <input type="text" id="vt<%=tcount%>_term" name="vt<%=tcount%>_term" style="border: none; background: transparent; width: 100%" value="" readonly/>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td></td>
                    <td></td>
                    <td>
                        <label for="cmoId<%=tcount%>" style="color: #24609c; font-weight: bold;">Clinical Measurement Id: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <%--                    <input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="<%=tissueMap.get(tissue)%>">--%>
                        <input type="text" name="cmoId<%=tcount%>" id="cmoId<%=tcount%>" value="" onblur="lostFocus('cmo')">
                        <a href="" id="cmo<%=tcount%>_popup" onclick="ontPopup('cmoId<%=tcount%>','cmo','cmo<%=tcount%>_term')" style="color:black;">Ont Tree</a><br>
                        <input type="text" id="cmo<%=tcount%>_term" name="cmo<%=tcount%>_term" style="border: none; background: transparent; width: 100%" value="" readonly/>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
        <%tcount++;}

      }
                    int scount = 0;
        if (strainMap.isEmpty()){%>
                <tr>
                    <td>
                        <label for="strain<%=scount%>" style="color: #24609c; font-weight: bold;">Strain: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <input type="text" name="strain<%=scount%>" id="strain<%=scount%>" value="No strains imported!" style="border: none; background: transparent;" readonly>
                    </td>
                    <td>
                        <label for="strainId<%=scount%>" style="color: #24609c; font-weight: bold;">Strain Id: &nbsp&nbsp </label>
                    </td>
                    <td>
<%--                        <input type="text" name="strainId<%=scount%>" id="strainId<%=scount%>" value="">--%>
                        <input type="text" name="strainId<%=scount%>" id="strainId<%=scount%>" value="" onblur="lostFocus('rs')">
                        <a href="" id="rs<%=scount%>_popup" onclick="ontPopup('strainId<%=scount%>','rs','rs<%=scount%>_term')" style="color:black;">Ont Tree</a><br>
                        <input type="text" id="rs<%=scount%>_term" name="rs<%=scount%>_term" style="border: none; background: transparent;width: 100%" value="" readonly/>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
<% scount++;}
   else {
          for(String strain: strainMap.keySet()){
              String ontAccId = strainMap.get(strain);
              Term t = new Term();
              if (ontAccId!=null && !ontAccId.isEmpty() && !existingSample){
                  t = ontologyXDAO.getTerm(ontAccId);}
                %>
            <tr>
                <td>
                    <label for="strain<%=scount%>" style="color: #24609c; font-weight: bold;">Strain: &nbsp&nbsp </label>
                </td>
                <td>
                    <input type="text" name="strain<%=scount%>" id="strain<%=scount%>" value="<%=strain%>" style="border: none; background: transparent;" readonly>
                </td>
                <td>
                    <label for="strainId<%=scount%>" style="color: #24609c; font-weight: bold;">Strain Id: &nbsp&nbsp </label>
                </td>
                <td>
<%--                    <input type="text" name="strainId<%=scount%>" id="strainId<%=scount%>" value="">--%>
                    <input type="text" name="strainId<%=scount%>" id="strainId<%=scount%>" value="<%=existingSample ? "" : ontAccId%>" onblur="lostFocus('rs')">
                    <a href="" id="rs<%=scount%>_popup" onclick="ontPopup('strainId<%=scount%>','rs','rs<%=scount%>_term')" style="color:black;">Ont Tree</a><br>
                    <input type="text" id="rs<%=scount%>_term" name="rs<%=scount%>_term" value="<%=Utils.NVL(t.getTerm(),"")%>" title="<%=Utils.NVL(t.getTerm(),"")%>"  style="border: none; background: transparent;width: 100%"  readonly/>
                </td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
                <%      scount++;
                }
            }
            int clcount = 0;
   if (cellLineMap.isEmpty()) { %>
                <tr>
                    <td>
                        <label for="cellLine<%=clcount%>" style="color: #24609c; font-weight: bold;">cellLine: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <input type="text" name="cellLine<%=clcount%>" id="cellLine<%=clcount%>" value="No cell lines imported!" style="border: none; background: transparent;" readonly>
                    </td>
                    <td>
                        <label for="cellLineId<%=clcount%>" style="color: #24609c; font-weight: bold;">cellLine Id: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <input type="text" name="cellLineId<%=clcount%>" id="cellLineId<%=clcount%>" value="">
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                <%clcount++;
   }
      else for(String cellLine: cellLineMap.keySet()){
        %>
                <tr>
                    <td>
                        <label for="cellLine<%=clcount%>" style="color: #24609c; font-weight: bold;">cellLine: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <input type="text" name="cellLine<%=clcount%>" id="cellLine<%=clcount%>" value="<%=cellLine%>" style="border: none; background: transparent;" readonly>
                    </td>
                    <td>
                        <label for="cellLineId<%=clcount%>" style="color: #24609c; font-weight: bold;">cellLine Id: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <input type="text" name="cellLineId<%=clcount%>" id="cellLineId<%=clcount%>" value="<%=cellLineMap.get(cellLine)%>">
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>

                <%    clcount++;
                    }
                    int cTcount = 0;
                    if (cellTypeMap.isEmpty()) {%>
                <tr>
                    <td>
                        <label for="cellType<%=cTcount%>" style="color: #24609c; font-weight: bold;">cellType: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <input type="text" name="cellType<%=cTcount%>" id="cellType<%=cTcount%>" value="No cell types imported!" style="border: none; background: transparent;" readonly>
                    </td>
                    <td>
                        <label for="cellTypeId<%=cTcount%>" style="color: #24609c; font-weight: bold;">cellType Id: &nbsp&nbsp </label>
                    </td>
                    <td>
<%--                        <input type="text" name="cellTypeId<%=cTcount%>" id="cellTypeId<%=cTcount%>" value=""> --%>
                        <input type="text" name="cellTypeId<%=cTcount%>" id="cellTypeId<%=cTcount%>" value="" onblur="lostFocus('cl')">
                        <a href="" id="cl<%=cTcount%>_popup" onclick="ontPopup('cellTypeId<%=cTcount%>','cl','cl<%=cTcount%>_term')" style="color:black;">Ont Tree</a><br>
                        <input type="text" id="cl<%=cTcount%>_term" name="cl<%=cTcount%>_term" style="border: none; background: transparent;width: 100%" value="" readonly/>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                <%   cTcount++;
                    }
                else for(String cellType: cellTypeMap.keySet()){
                        String ontAccId = cellTypeMap.get(cellType);
                        Term t = new Term();
                        if (ontAccId!=null && !ontAccId.isEmpty() && !existingSample){
                            t = ontologyXDAO.getTerm(ontAccId);}
                %>
                <tr>
                    <td>
                        <label for="cellType<%=cTcount%>" style="color: #24609c; font-weight: bold;">cellType: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <input type="text" name="cellType<%=cTcount%>" id="cellType<%=cTcount%>" value="<%=cellType%>" style="border: none; background: transparent;" readonly>
                    </td>
                    <td>
                        <label for="cellTypeId<%=cTcount%>" style="color: #24609c; font-weight: bold;">cellType Id: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <%--                        <input type="text" name="cellTypeId<%=cTcount%>" id="cellTypeId<%=cTcount%>" value=""> --%>
                            <input type="text" name="cellTypeId<%=cTcount%>" id="cellTypeId<%=cTcount%>" value="<%=existingSample ? "" : ontAccId%>" onblur="lostFocus('cl')">
                            <a href="" id="cl<%=cTcount%>_popup" onclick="ontPopup('cellTypeId<%=cTcount%>','cl','cl<%=cTcount%>_term')" style="color:black;">Ont Tree</a><br>
                            <input type="text" id="cl<%=cTcount%>_term" name="cl<%=cTcount%>_term" value="<%=Utils.NVL(t.getTerm(),"")%>" title="<%=Utils.NVL(t.getTerm(),"")%>"  style="border: none; background: transparent;width: 100%" readonly/>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>


                <%   cTcount++;
                    }
                  int ageCount = 0;
                    if (ages.isEmpty()){%>
                <tr>
                    <td>
                        <label for="age<%=ageCount%>" style="color: #24609c; font-weight: bold;">Age: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <input type="text" name="age<%=ageCount%>" id="age<%=ageCount%>" style="border: none; background: transparent;" readonly>
                    </td>
                    <td>
                        <label for="ageLow<%=ageCount%>" style="color: #24609c; font-weight: bold;">Age (in days) Low:  &nbsp&nbsp</label>
                    </td>
                    <td>
                        <input type="text" name="ageLow<%=ageCount%>" id="ageLow<%=ageCount%>" >
                    </td>
                    <td>
                        <label for="ageHigh<%=ageCount%>" style="color: #24609c; font-weight: bold;">Age (in days) High: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <input type="text" name="ageHigh<%=ageCount%>" id="ageHigh<%=ageCount%>" >
                    </td>
                    <td>
                        <fieldset>
                            <legend style="color: #24609c; font-weight: bold;"> Life Stage: &nbsp&nbsp </legend>
                            <label><input type="checkbox" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>" value="embryonic"> embryonic</label>&nbsp;&nbsp;
                            <label><input type="checkbox" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>" value="neonatal"> neonatal</label>&nbsp;&nbsp;
                            <label><input type="checkbox" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>" value="weanling"> weanling</label><br>
                            <label><input type="checkbox" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>" value="juvenile"> juvenile</label>&nbsp;&nbsp;
                            <label><input type="checkbox" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>" value="adult"> adult</label>&nbsp;&nbsp;
                            <label><input type="checkbox" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>" value="aged"> aged</label>
                            <%--                            <input type="text" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>">--%>
                        </fieldset>
                    </td>
                </tr>
                <%ageCount++;}
                    else {
                    for(String age: ages){
                %>
            <tr>
                <td>
                    <label for="age<%=ageCount%>" style="color: #24609c; font-weight: bold;">Age: &nbsp&nbsp </label>
                </td>
                <td>
                    <input type="text" name="age<%=ageCount%>" id="age<%=ageCount%>" value="<%=age%>" style="border: none; background: transparent;" readonly>
                </td>
                <td>
                    <label for="ageLow<%=ageCount%>" style="color: #24609c; font-weight: bold;">Age (in days) Low:  &nbsp&nbsp</label>
                </td>
                <td>
                    <input type="text" name="ageLow<%=ageCount%>" id="ageLow<%=ageCount%>" >
                </td>
                <td>
                    <label for="ageHigh<%=ageCount%>" style="color: #24609c; font-weight: bold;">Age (in days) High: &nbsp&nbsp </label>
                </td>
                <td>
                    <input type="text" name="ageHigh<%=ageCount%>" id="ageHigh<%=ageCount%>" >
                </td>
                <td>
                    <fieldset>
                        <legend style="color: #24609c; font-weight: bold;"> Life Stage: &nbsp&nbsp </legend>
                        <label><input type="checkbox" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>" value="embryonic"> embryonic</label>&nbsp;&nbsp;
                        <label><input type="checkbox" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>" value="neonatal"> neonatal</label>&nbsp;&nbsp;
                        <label><input type="checkbox" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>" value="weanling"> weanling</label><br>
                        <label><input type="checkbox" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>" value="juvenile"> juvenile</label>&nbsp;&nbsp;
                        <label><input type="checkbox" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>" value="adult"> adult</label>&nbsp;&nbsp;
                        <label><input type="checkbox" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>" value="aged"> aged</label>
                        <%--                            <input type="text" name="lifeStage<%=ageCount%>" id="lifeStage<%=ageCount%>">--%>
                    </fieldset>
                </td>
            </tr>

                <%
                    ageCount++;
                }   }
                    int gcount = 0;
                    if (gender.isEmpty()){%>
                <tr>
                    <td>
                        <label for="gender<%=gcount%>" style="color: #24609c; font-weight: bold;">Sex: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <input type="text" name="gender<%=gcount%>" id="gender<%=gcount%>" style="border: none; background: transparent;" readonly>
                    </td>
                    <td>
                        <label for="sex<%=gcount%>" style="color: #24609c; font-weight: bold;">Select Sex:  &nbsp&nbsp</label>
                    </td>
                    <td>
                        <select name="sex<%=gcount%>" id="sex<%=gcount%>">
                            <%=existingSample ? "<option value=\"\" selected></option>":""%>
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                        <option value="both">Both</option>
                        <option value="not specified" >Not Specified</option>
                    </select>
                    </td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                </tr>
                <%  gcount++;}
                    else{
                    for(String g: gender){
                %>
                <tr>
                    <td>
                        <label for="gender<%=gcount%>" style="color: #24609c; font-weight: bold;">Sex: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <input type="text" name="gender<%=gcount%>" id="gender<%=gcount%>" value="<%=g%>" style="border: none; background: transparent;" readonly>
                    </td>
                    <td>
                        <label for="sex<%=gcount%>" style="color: #24609c; font-weight: bold;">Select Sex:  &nbsp&nbsp</label>
                    </td>
                    <td>
                        <select name="sex<%=gcount%>" id="sex<%=gcount%>">
                            <%=existingSample ? "<option value=\"\" selected></option>":""%>
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                        <option value="both">Both</option>
                        <option value="not specified">Not Specified</option>
                    </select>
                    </td>
                    <td></td>
                    <td></td>
                 </tr>

                <%
                        gcount++;
                    }   }
                    int notesCnt = 0;%>
                <tr>
                    <td></td>
                    <td></td>
                    <td><label for="notesId<%=notesCnt%>" style="color: #24609c; font-weight: bold;">Public Notes: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <textarea name="notesId<%=notesCnt%>" id="notesId<%=notesCnt%>" style="height: 60px"></textarea></p>
                    </td>
                    <td><label for="cNotesId<%=notesCnt%>" style="color: #24609c; font-weight: bold;">Curator Notes: &nbsp&nbsp </label>
                    </td>
                    <td>
                        <textarea name="cNotesId<%=notesCnt%>" id="cNotesId<%=notesCnt%>" style="height: 60px"></textarea>
                    </td>
                    <td></td>
                </tr>
                <%notesCnt++;%>

    </table>
                <%
                    int xcoCnt=0;
                    Record r = new Record();
                    Condition c = new Condition();
                    c.setOrdinality(1);
                    r.getConditions().add(c);
                %>
                <div style="all: revert;">
                <script type="text/javascript">
                    var conditions = new Array();
                    cCount =<%=r.getConditions().size()%>;
                    function addCondition() {
                        var allConditionDiv = document.getElementsByClassName("condition");
                        for (var j = 1; j < allConditionDiv.length; j++){
                            if (allConditionDiv.item(j).style.display !== 'block'){
                                cCount=j;
                                var thisCondition = allConditionDiv.item(j);
                                thisCondition.style.display = "block";
                                break;
                            }
                        }
                    }
                </script>
                    <table>
                        <tr>
                            <td><h2>Experimental Conditions</h2></td>
                            <td style="padding-left: 50px"><input onclick="addCondition()" type="button" value="Add Condition"></td>
                        </tr>
                    </table>

                <%for (Condition cond : r.getConditions()){%>
            <div id="condition<%=xcoCnt%>" class="condition">
                <table class="table table-striped">
                    <tr></tr>
                <tr>
                    <td>
                        Experimental Condition <%=xcoCnt+1%>
                    </td>
                    <td>
                        <label for="xcoId<%=xcoCnt%>">*AccId</label>
                        <input name="xcoId<%=xcoCnt%>" id="xcoId<%=xcoCnt%>" value="">
                        <a href="" id="xco<%=xcoCnt%>_popup" onclick="ontPopup('xcoId<%=xcoCnt%>','xco','xco<%=xcoCnt%>_term')" style="color:black;">Ont&nbsp;Tree</a><br>
                        <input type="text" id="xco<%=xcoCnt%>_term" name="xco<%=xcoCnt%>_term" value="" style="border: none; background: transparent;width: 100%" readonly/>
                    </td>
                </tr>
                <tr>
                    <td>Min Value</td>
                    <td>Max Value</td>
                    <td>Unit</td>
                    <td>Min Dur</td>
                    <td>Max Dur</td>
                    <td>Application Method</td>
                    <td>*Ordinality</td>
                    <td>Notes</td>
                </tr>
                <tr>
                    <%try{
                        if (cond != null){%>
                    <input type="hidden" name="cId" value="<%=dm.out("cValue", cond.getId(), xcoCnt)%>"/>
                    <td><input type="text" size="7" name="cValueMin"
                               value="<%=dm.out("cValueMin", cond.getValueMin(), xcoCnt)%>"/></td>
                    <td><input type="text" size="7" name="cValueMax"
                               value="<%=dm.out("cValueMax", cond.getValueMax(), xcoCnt)%>"/></td>
                    <td><select name="cUnits" id="cUnits">
                        <% for (String unit : unitList){%>
                        <option value="<%=unit%>"><%=unit%></option>
                        <% } %></select>
                    </td>
                    <td><input type="text" size="12" name="cMinDuration"
                               value="<%=dm.out("cMinDuration", (cond.getDurationLowerBound() > 0 ? d_f.format(cond.getDurationLowerBound()) : ""), xcoCnt)%>"
                               onchange="document.getElementsByName('cMinDurationUnits')[<%=(xcoCnt)%>].style.color='red'"/><%=fu.buildSelectList("cMinDurationUnits", timeUnits, (cond.getDurationLowerBound() > 0 ? "" : Condition.convertDurationBoundToString(cond.getDurationLowerBound())))%>
                    </td>
                    <td><input type="text" size="12" name="cMaxDuration"
                               value="<%=dm.out("cMaxDuration", (cond.getDurationUpperBound() > 0 ? d_f.format(cond.getDurationUpperBound()) : ""), xcoCnt)%>"
                               onchange="document.getElementsByName('cMaxDurationUnits')[<%=(xcoCnt)%>].style.color='red'"/><%=fu.buildSelectList("cMaxDurationUnits", timeUnits, (cond.getDurationUpperBound() > 0 ? "" : Condition.convertDurationBoundToString(cond.getDurationUpperBound())))%>
                    </td>
                    <td><input type="text" size="30" name="cApplicationMethod"
                               value="<%=dm.out("cApplicationMethod", cond.getApplicationMethod(), xcoCnt)%>"/></td>
                    <td><input type="number" size="7" name="cOrdinality"
                               value="<%=dm.out("cOrdinality", cond.getOrdinality(), xcoCnt)%>"/></td>
                    <td><input type="text" size="30" name="cNotes"
                               value="<%=dm.out("cNotes", cond.getNotes(), xcoCnt + 1)%>"/></td>
                    <%}
                    } catch(Exception e){
                        e.printStackTrace();
                        }%>
                </tr>
                </table>
            </div>
                <% xcoCnt++; } %>

            <% for (int i = xcoCnt; i < 15; i++) { %>
                <div id="condition<%=i%>" style="display:none;"class="condition">
                    <table class="table table-striped">
                        <tr></tr>
                        <tr>
                            <td>
                                Experimental Condition <%=i+1%>
                            </td>
                            <td>
                                <label for="xcoId<%=i%>">*AccId</label>
                                <input name="xcoId<%=i%>" id="xcoId<%=i%>" value="">
                                <a href="" id="xco<%=i%>_popup" onclick="ontPopup('xcoId<%=i%>','xco','xco<%=i%>_term')" style="color:black;">Ont&nbsp;Tree</a><br>
                                <input type="text" id="xco<%=i%>_term" name="xco<%=i%>_term" value="" style="border: none; background: transparent;width: 100%" readonly/>
                            </td>
                            <td>
                                <a style="color:red; font-weight:700;"
                                   href="javascript:removeCondition('condition<%=i%>','<%=i%>') ;void(0);"><img
                                        src="/rgdweb/common/images/del.jpg" border="0"/></a>
                            </td>
                        </tr>
                        <tr>
                            <td>Min Value</td>
                            <td>Max Value</td>
                            <td>Units</td>
                            <td>Min Dur</td>
                            <td>Max Dur</td>
                            <td>Application Method</td>
                            <td>*Ordinality</td>
                            <td>Notes</td>
                        </tr>
                        <tr>
                            <input type="hidden" name="cId" value=""/>
                            <td><input type="text" size="7" name="cValueMin" value=""/></td>
                            <td><input type="text" size="7" name="cValueMax" value=""/></td>
                            <td><select name="cUnits" id="cUnits">
                                <% for (String unit : unitList){%>
                                <option value="<%=unit%>"><%=unit%></option>
                                <% } %></select>
                            </td>
                            <td><input type="text" size="12" name="cMinDuration"
                                       value=""/><%=fu.buildSelectList("cMinDurationUnits", timeUnits, "")%>
                            </td>
                            <td><input type="text" size="12" name="cMaxDuration"
                                       value=""/><%=fu.buildSelectList("cMaxDurationUnits", timeUnits, "")%>
                            </td>
                            <td><input type="text" size="30" name="cApplicationMethod" value=""/></td>
                            <td><input type="number" size="7" name="cOrdinality" value=""/></td>
                            <td><input type="text" size="30" name="cNotes" value=""/></td>
                        </tr>
                    </table>
                </div>
                <% } %>
                </div>
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
        <input type="hidden" id="conditionCount" name="conditionCount" value="15">
        <input type="hidden" id="gse" name="gse" value="<%=gse%>" />
        <input type="hidden" id="species" name="species" value="<%=species%>" />
        <input type="hidden" id="samplesExist" name="samplesExist" value="<%=!existingSample ? 0 : sampleList.size()%>">
      <input id="viewSample" type="button" value="View Samples" style="float: right;" onclick="submitForm()"/>
    </form>
</div>


</body>
</html>
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
        var existing = document.getElementById("exist").value;
        var allConditionDiv = document.getElementsByClassName("condition");
        var conditionCount = 0;
        var ordinal = document.getElementsByName("cOrdinality");
        if (existing !== "true") {
            for (var j = 0; j < allConditionDiv.length; j++) {
                var xco = document.getElementById("xcoId" + j);
                var hasXco = j == 0 || allConditionDiv.item(j).style.display === 'block';
                var hasOrdinality = ordinal[j].value === "";
                if (hasXco) {
                    if (xco.value === "" && !hasOrdinality) {
                        xco.style.border = "2px solid red";
                        ordinal[j].style.border = "1px solid black";
                        bool = false;
                    } else if (xco.value === "" && hasOrdinality) {
                        xco.style.border = "2px solid red";
                        ordinal[j].style.border = "2px solid red";
                        bool = false;
                    } else if (xco.value !== "" && hasOrdinality) {
                        xco.style.border = "1px solid black";
                        ordinal[j].style.border = "2px solid red";
                        bool = false;
                    } else {
                        xco.style.border = "1px solid black";
                        ordinal[j].style.border = "1px solid black";
                    }
                }
            }
        }
        if (bool)
            document.getElementById("expressionSub").submit();
    }
    function removeCondition(divName, i){
        document.getElementById(divName).style.display = 'none';
        document.getElementById("xcoId"+i).value="";
        document.getElementById("xco"+i+"_term").value="";
        document.getElementsByName("cValueMin")[i].value="";
        document.getElementsByName("cValueMax")[i].value="";
        document.getElementsByName("cUnits")[i].value="";
        document.getElementsByName("cMinDuration")[i].value="";
        document.getElementsByName("cMinDurationUnits")[i].value="secs";
        document.getElementsByName("cMaxDuration")[i].value="";
        document.getElementsByName("cMaxDurationUnits")[i].value="secs";
        document.getElementsByName("cApplicationMethod")[i].value="";
        document.getElementsByName("cOrdinality")[i].value="";
        document.getElementsByName("cNotes")[i].value="";
        document.getElementsByName("cOrdinality")[i].style.border = "1px solid black";
        document.getElementById("xcoId"+i).style.border = "1px solid black";
    }
</script>