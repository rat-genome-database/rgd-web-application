<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.GeoRecord" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneExpressionDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.*" %>

<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<link rel="stylesheet" type="text/css" href="/rgdweb/css/enrichment/analysis.css">
<html>

<script type="text/javascript"  src="/rgdweb/common/jquery.autocomplete.custom.js"></script>

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
    table input{
        font-size: 14px;
    }

    .sticky-table{
        height: 650px;
        max-width: 98vw;
        overflow-x: auto;
        /*position: relative;*/
        margin-top: 25px;
    }
    .sticky-table thead{

        position: -webkit-sticky;
        position: sticky;
        left: 0;
        top: 0;
        z-index: 10;
    }
    /*.sticky-table th, td {*/
    /*    padding: 10px 100px;*/
    /*    text-transform: capitalize;*/
    /*}*/
    .sticky-table th {
        background: white;
        color: black;
        white-space: nowrap;

    }
    .sticky-table th:first-child {
             position: -webkit-sticky;
             position: sticky;
             left: 0px;
             z-index: 3;
             width: 200px;
    }
    .sticky-table td:first-child {
        position: -webkit-sticky;
        position: sticky;
        left: 0px;
        z-index: 3;
        width: 200px;
    }
    .sticky-table tr:nth-child(odd) td:first-child {
            background: #f1f1f1;
    }
    .sticky-table tr:nth-child(even) td:first-child {
        background: white;
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
<script type="text/javascript" src="/rgdweb/js/ontPopUp/ontPopupBrowser.js"></script>
<%

    String pageTitle = "Create Geo Sample";
    String headContent = "";
    String pageDescription = "Create Geo Sample";

%>

<%@ include file="/common/headerarea.jsp" %>
<%
    DisplayMapper dm = new DisplayMapper(new HttpRequestFacade(request), (ArrayList) request.getAttribute("error"));
    FormUtility fu = new FormUtility();
    PhenominerDAO pdao = new PhenominerDAO();
    GeneExpressionDAO geDAO = new GeneExpressionDAO();
    List<String> unitList = pdao.getDistinct("PHENOMINER_ENUMERABLES where type=2", "value", true);
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
    HttpRequestFacade req = new HttpRequestFacade(request);


    OntologyXDAO xdao = new OntologyXDAO();
    List<GeoRecord> samples = pdao.getGeoRecords(gse,species);
    HashMap<String,String> tissueMap = (HashMap)request.getAttribute("tissueMap");
    HashMap<String,String> tissueNameMap = (HashMap) request.getAttribute("tissueNameMap");
    HashMap<String,String> vtMap = (HashMap) request.getAttribute("vtMap");
    HashMap<String,String> vtNameMap = (HashMap) request.getAttribute("vtNameMap");
    HashMap<String,String> cmoMap = (HashMap) request.getAttribute("cmoMap");
    HashMap<String,String> cmoNameMap = (HashMap) request.getAttribute("cmoNameMap");
    HashMap<String,String> strainMap = (HashMap)request.getAttribute("strainMap");
    HashMap<String,String> strainNameMap = (HashMap) request.getAttribute("strainNameMap");
    HashMap<String,String> ageLow = (HashMap)request.getAttribute("ageLow");
    HashMap<String,String> ageHigh = (HashMap)request.getAttribute("ageHigh");
    HashMap<String,String> cellTypeMap = (HashMap)request.getAttribute("cellType");
    HashMap<String,String> cellNameMap = (HashMap) request.getAttribute("cellNameMap");
    HashMap<String,String> cellLine = (HashMap)request.getAttribute("cellLine");
    HashMap<String,String> gender = (HashMap)request.getAttribute("gender");
    HashMap<String, String> lifeStage = (HashMap)request.getAttribute("lifeStage");
    HashMap<String,String> notes = (HashMap)request.getAttribute("notesMap");
    HashMap<String,String> curNotes = (HashMap) request.getAttribute("curNotesMap");
    HashMap<String,String> xcoMap = (HashMap) request.getAttribute("xcoTerms");
    List<Condition> conditions = (ArrayList) request.getAttribute("conditions");
    int sampleSize = (int) request.getAttribute("samplesExist");
    boolean updateSample = sampleSize!=0;
    int size = samples.size();
    String idName = "";
    boolean createSample = true;
    Study study = new Study();
    int count = 0;
%>


<br>
<div>
    <%
        if(samples.size() != 0) {
            study = pdao.getStudyByGeoId(samples.get(0).getGeoAccessionId());
    %>
        <form action="experiments.html" method="POST">
            <table  class="t" style="width: 1880px">
                <tr>
                    <input type="hidden" id="geoId" name="geoId" value=<%=gse%> />
                    <td><b>Geo Accession Id: </b></td><td><a href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=<%=samples.get(0).getGeoAccessionId()%>" target="_blank"><%=samples.get(0).getGeoAccessionId()%></a></td>
                    <td><b>Study Title: </b></td><td><%=samples.get(0).getStudyTitle()%></td>
                    <td><b>PubMed Id: </b></td><td><%=samples.get(0).getPubmedId()%></td>
                    <td><b>Select status: </b></td>
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
    %>




        <form action="experiments.html" method="POST" id="createSample">
            <input type="button" value="Show/Hide Conditions" onclick="showColumns()">
            <input type="button" value="Load Samples" style="float: right;" onclick="submitForm()"/>
            <br>
            <div class="sticky-table">
            <table class="table table-striped">

                <%
            if(samples.size() != 0) {
        %>
                <colgroup>
                    <col span="19">
                    <% for (int i = 0; i < 15; i ++){%>
                    <col span="3">
                    <col id="showMe<%=i%>" span="7" style="visibility: collapse">
                    <%}%>
                </colgroup>
            <thead>
            <tr>
                <th>GEO Sample ID: </th>
                <th>Sample Organism</th>
                <th>Strain (Source): </th>
                <th>Strain ID (Curated): </th>
                <th>Cell Type (Source): </th>
                <th>Cell Type ID (Curated): </th>
                <th>Cell Line (Source): </th>
                <th>Cell Line ID (Curated): </th>
                <th>Tissue (Source): </th>
                <th>Tissue ID (Curated): </th>
                <th>Vertebrate Trait  ID (Curated): </th>
<%--                <th>Clinical Measurement ID (Curated): </th>--%>
                <th>Sex (Curated): </th>
                <th>Age (Source): </th>
                <th>Age (in days) Low (Curated): </th>
                <th>Age (in days) High (Curated): </th>
                <th>Life Stage (Curated):</th>
                <th>Public Notes:</th>
                <th>Curator Notes:</th>
                <th>Status/Action:</th>
                <% int k = 0;
                    for (k = 0; k < conditions.size(); k++){%>
                <th><b style="font-size: x-large"><%=k+1%></b> <input type="checkbox" name="checkAll<%=k%>" id="checkAll<%=k%>" value="<%=k%>" onclick="checkedAll('<%=k%>', this)" checked></th>
                <th>AccId <%=k+1%>:</th>
                <th>Min Value <%=k+1%>:</th>
                <th>Max Value <%=k+1%>:</th>
                <th>Unit <%=k+1%>:</th>
                <th>Min Dur <%=k+1%>:</th>
                <th>Max Dur <%=k+1%>:</th>
                <th>Application Method <%=k+1%>:</th>
                <th>Ordinality <%=k+1%>:</th>
                <th>Condition Notes <%=k+1%>:</th>
                <% }
                for (int i = k; i < 15; i++) {%>
                <th><b style="font-size: x-large"><%=i+1%></b> <input type="checkbox" name="checkAll<%=i%>" id="checkAll<%=i%>" value="<%=i%>" onclick="checkedAll('<%=i%>', this)"></th>
                    <th>AccId <%=i+1%>:</th>
                    <th title="Ordinality <%=i+1%>">Ord <%=i+1%>:</th>
                    <th>Min Value <%=i+1%>:</th>
                    <th>Max Value <%=i+1%>:</th>
                    <th>Unit <%=i+1%>:</th>
                    <th>Min Dur <%=i+1%>:</th>
                    <th>Max Dur <%=i+1%>:</th>
                    <th>Application Method <%=i+1%>:</th>
                    <th>Condition Notes <%=i+1%>:</th>
                <% } %>
            </tr>
            </thead>
                <tbody>
                <%
            }


     for(GeoRecord s: samples){
         boolean bool = false;
         Sample sample = pdao.getSampleByGeoId(s.getSampleAccessionId());
         List<Experiment> experiments = new ArrayList<>();
         Experiment exp = new Experiment();
         GeneExpressionRecord gre = new GeneExpressionRecord();
         List<Condition> conds = new ArrayList<>();
         int j = 0, n = 0;
//System.out.println(s.getSampleAccessionId()+"|"+s.getCurationStatus());
          try{
         if (sample == null)
             sample = new Sample();

          if (sample.getId() != 0 && Utils.stringsAreEqual(study.getGeoSeriesAcc(), samples.get(0).getGeoAccessionId())) {
              experiments = pdao.getExperiments(study.getId());
              if (!experiments.isEmpty()) {
                  exp = experiments.get(0);
                  gre = geDAO.getGeneExpressionRecordByExperimentIdAndSampleId(exp.getId(), sample.getId());
                  if (gre.getConditions()!= null && !gre.getConditions().isEmpty())
                    conds = gre.getConditions();//geDAO.getConditions(gre.getId());

              }

          }

         bool = !(sample.getAgeDaysFromLowBound()==0 && ( sample.getAgeDaysFromHighBound()== sample.getAgeDaysFromLowBound() ) );
        }catch (Exception ignore){
              // number is null
        }
         if ((!ageHigh.isEmpty() || !ageLow.isEmpty()) && Utils.isStringEmpty(s.getSampleAge()) )
         {
             try{
             Set<String> keys = ageHigh.keySet();
             if (keys.isEmpty())
                 keys = ageLow.keySet();
             s.setSampleAge(keys.iterator().next());
             }
             catch (Exception e){

             }
         }
         if (!gender.isEmpty() && s.getSampleGender()==null){
try{
    Set<String> gKeys = gender.keySet();
    s.setSampleGender(gKeys.iterator().next());
}
catch (Exception e){}
         }
  %>
            <tr>
                <td ><input type="text" name="sampleId<%=count%>" id="sampleId<%=count%>" value="<%=dm.out("sampleId"+count,s.getSampleAccessionId())%>" readonly> </td>
                <td><%=s.getSampleOrganism()%></td>
                <td><%=Objects.toString(s.getSampleStrain(),"")%></td>
                <td><input type="text" name="strainId<%=count%>" id="strainId<%=count%>" value="<%=(updateSample && !Objects.toString(strainMap.get(s.getSampleStrain()),"").isEmpty()) ? Objects.toString(strainMap.get(s.getSampleStrain()),"") :!Utils.isStringEmpty(sample.getStrainAccId()) ? sample.getStrainAccId() : Objects.toString(strainMap.get(s.getSampleStrain()),"")%>">
                    <br><input type="text" id="rs<%=count%>_term" name="rs<%=count%>_term" value="<%=Objects.toString(strainNameMap.get(s.getSampleStrain()),"")%>" title="<%=Utils.NVL(strainNameMap.get(s.getSampleStrain()),"")%>" style="border: none; background: transparent;width: 100%" readonly/>
                    <a href="" id="rs<%=count%>_popup" onclick="ontPopup('strainId<%=count%>','rs','rs<%=count%>_term')" style="color:black;">Ont Tree</a></td>
                <td><%=Objects.toString(s.getSampleCellType(),"")%></td>
                <td><input type="text" name="cellTypeId<%=count%>" id="cellTypeId<%=count%>" value="<%=(updateSample && !Objects.toString(cellTypeMap.get(s.getSampleCellType()),"").isEmpty()) ? Objects.toString(cellTypeMap.get(s.getSampleCellType()),"") :!Utils.isStringEmpty(sample.getCellTypeAccId()) ? sample.getCellTypeAccId() : Objects.toString(cellTypeMap.get(s.getSampleCellType()),"")%>">
                    <br><input type="text" id="cl<%=count%>_term" name="cl<%=count%>_term" value="<%=Objects.toString(cellNameMap.get(s.getSampleCellType()),"")%>"  title="<%=Utils.NVL(cellNameMap.get(s.getSampleCellType()),"")%>" style="border: none; background: transparent;width: 100%" readonly/>
                    <a href="" id="cl<%=count%>_popup" onclick="ontPopup('cellTypeId<%=count%>','cl','cl<%=count%>_term')" style="color:black;">Ont Tree</a></td>
                <td><%=Objects.toString(s.getSampleCellLine(),"")%></td>
                <td><input type="text" name="cellLineId<%=count%>" id="cellLineId<%=count%>" value="<%=(updateSample && !Objects.toString(cellLine.get(s.getSampleCellLine()),"").isEmpty()) ? Objects.toString(cellLine.get(s.getSampleCellLine()),"") : !Utils.isStringEmpty(sample.getCellLineId()) ? sample.getCellLineId() : Objects.toString(cellLine.get(s.getSampleCellLine()),"")%>"> </td>
                <td><%=Objects.toString(s.getSampleTissue(),"")%></td>
                <td>
                    <input type="text" name="tissueId<%=count%>" id="tissueId<%=count%>" value="<%=(updateSample && !Objects.toString(tissueMap.get(s.getSampleTissue()),"").isEmpty()) ? Objects.toString(tissueMap.get(s.getSampleTissue()),"") :!Utils.isStringEmpty(sample.getTissueAccId()) ? sample.getTissueAccId() : Objects.toString(tissueMap.get(s.getSampleTissue()),"")%>">
                    <br><input type="text" id="uberon<%=count%>_term" name="uberon<%=count%>_term" value="<%=Objects.toString(tissueNameMap.get(s.getSampleTissue()),"")%>" title="<%=Utils.NVL(tissueNameMap.get(s.getSampleTissue()),"")%>"  style="border: none; background: transparent;width: 100%" readonly/>
                    <a href="" id="uberon<%=count%>_popup" onclick="ontPopup('tissueId<%=count%>','uberon','uberon<%=count%>_term')" style="color:black;">Ont Tree</a>
                </td>
                <td>
                    <input type="text" name="vtId<%=count%>" id="vtId<%=count%>" value="<%=Objects.toString(vtMap.get(s.getSampleTissue()), "")%>">
                    <br><input type="text" id="vt<%=count%>_term" name="vt<%=count%>_term" value="<%=Objects.toString(vtNameMap.get(s.getSampleTissue()),"")%>" title="<%=Utils.NVL(vtNameMap.get(s.getSampleTissue()),"")%>"  style="border: none; background: transparent;width: 100%" readonly/>
                    <a href="" id="uberon<%=count%>_popup" onclick="ontPopup('vtId<%=count%>','vt','vt<%=count%>_term')" style="color:black;">Ont Tree</a>
                </td>
<%--                <td>--%>
<%--                    <input type="text" name="cmoId<%=count%>" id="cmoId<%=count%>" value="<%=Objects.toString(cmoMap.get(s.getSampleTissue()), "")%>">--%>
<%--                    <br><input type="text" id="cmo<%=count%>_term" name="cmo<%=count%>_term" value="<%=Objects.toString(cmoNameMap.get(s.getSampleTissue()),"")%>" title="<%=Utils.NVL(cmoNameMap.get(s.getSampleTissue()),"")%>"  style="border: none; background: transparent;width: 100%" readonly/>--%>
<%--                    <a href="" id="cmo<%=count%>_popup" onclick="ontPopup('cmoId<%=count%>','cmo','cmo<%=count%>_term')" style="color:black;">Ont Tree</a>--%>
<%--                </td>--%>
                <td>
                    <select name="sex<%=count%>" id="sex<%=count%>">
                        <option value="male" <%=(updateSample && !Objects.toString(gender.get(s.getSampleGender())).isEmpty())? Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"male") ?  "selected":"" :Utils.stringsAreEqual(sample.getSex(),"male") ? "selected" : Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"male") ? "selected":""%>>Male</option>
                        <option value="female" <%=(updateSample && !Objects.toString(gender.get(s.getSampleGender())).isEmpty())? Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"female") ?  "selected":"" :Utils.stringsAreEqual(sample.getSex(),"female") ? "selected" : Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"female") ? "selected":""%>>Female</option>
                        <option value="both" <%=(updateSample && !Objects.toString(gender.get(s.getSampleGender())).isEmpty())? Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"both") ?  "selected":"" :Utils.stringsAreEqual(sample.getSex(),"both") ? "selected" : Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"both") ? "selected":""%>>both</option>
                        <option value="not specified" <%=(updateSample && !Objects.toString(gender.get(s.getSampleGender())).isEmpty())? Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"not specified") ?  "selected":"" :Utils.stringsAreEqual(sample.getSex(),"not specified") ? "selected" : Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"not specified") ? "selected":""%>>Not Specified</option>
                    </select>
                </td>
                <td><%=Objects.toString(s.getSampleAge(),"")%> </td>
                <td><input type="text" name="ageLow<%=count%>" id="ageLow<%=count%>" value="<%=(updateSample && !Objects.toString(ageLow.get(s.getSampleAge()),"").isEmpty()) ? Objects.toString(ageLow.get(s.getSampleAge()),"") :bool ?  sample.getAgeDaysFromLowBound() : Objects.toString(ageLow.get(s.getSampleAge()),"")%>"> </td>
                <td><input type="text" name="ageHigh<%=count%>" id="ageHigh<%=count%>" value="<%=(updateSample && !Objects.toString(ageHigh.get(s.getSampleAge()),"").isEmpty())? Objects.toString(ageHigh.get(s.getSampleAge()),"") : bool ?  sample.getAgeDaysFromHighBound() : Objects.toString(ageHigh.get(s.getSampleAge()),"")%>"> </td>
                <td>
                    <fieldset>
                        <label><input type="checkbox" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="embryonic"
                            <%=(updateSample && !Objects.toString(lifeStage.get(s.getSampleAge()),"" ).isEmpty())?Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("embryonic") ? "checked":"":
                            !Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage().contains("embryonic") ? "checked": "":
                            Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("embryonic") ? "checked":""%>> embryonic</label>
                        <label><input type="checkbox" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="neonatal"
                            <%=(updateSample && !Objects.toString(lifeStage.get(s.getSampleAge()),"" ).isEmpty())?Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("neonatal") ? "checked":"":
                            !Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage().contains("neonatal") ? "checked": "":
                            Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("neonatal") ? "checked":""%>> neonatal</label>
                        <label><input type="checkbox" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="weanling"
                            <%=(updateSample && !Objects.toString(lifeStage.get(s.getSampleAge()),"" ).isEmpty())?Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("weanling") ? "checked":"":
                            !Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage().contains("weanling") ? "checked": "":
                            Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("weanling") ? "checked":""%>> weanling</label><br>
                        <label><input type="checkbox" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="juvenile"
                            <%=(updateSample && !Objects.toString(lifeStage.get(s.getSampleAge()),"" ).isEmpty())?Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("juvenile") ? "checked":"":
                            !Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage().contains("juvenile") ? "checked": "":
                            Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("juvenile") ? "checked":""%>> juvenile</label>
                        <label><input type="checkbox" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="adult"
                            <%=(updateSample && !Objects.toString(lifeStage.get(s.getSampleAge()),"" ).isEmpty())?Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("adult") ? "checked":"":
                            !Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage().contains("adult") ? "checked": "":
                            Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("adult") ? "checked":""%>> adult</label>
                        <label><input type="checkbox" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="aged"
                            <%=(updateSample && !Objects.toString(lifeStage.get(s.getSampleAge()),"" ).isEmpty())?Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("aged") ? "checked":"":
                            !Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage().contains("aged") ? "checked": "":
                            Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("aged") ? "checked":""%>> aged</label>
                    </fieldset>
                </td>
                <td><textarea name="notes<%=count%>" id="notes<%=count%>" style="height: 60px"><%=(updateSample && !Objects.toString(notes.get(null),"").isEmpty()) ? Objects.toString(notes.get(null),"") :sample.getNotes()!=null ? sample.getNotes() : Objects.toString(notes.get(null),"")%></textarea></td>
                <td><textarea name="cNotes<%=count%>" id="cNotes<%=count%>" style="height: 60px"><%=(updateSample && !Objects.toString(curNotes.get(null),"").isEmpty()) ? Objects.toString(curNotes.get(null),"") : sample.getCuratorNotes()!=null ? sample.getCuratorNotes() : Objects.toString(curNotes.get(null),"")%></textarea></td>
                <td><select id="status<%=count%>" name="status<%=count%>" onchange="checkDropdown('action<%=count%>','status<%=count%>','status')">
                    <%if (sample.getId()!=0){%>
                    <option value="loaded" <%=s.getCurationStatus().equals("loaded") ? "selected":""%>>Loaded</option>
                    <%}%>
                    <option  value="not4Curation" <%=s.getCurationStatus().equals("not4Curation") ? "selected":""%>>Not For Curation</option>
                    <option value="futureCuration" <%=s.getCurationStatus().equals("futureCuration") ? "selected":""%>>Future Curation</option>
                    <option  value="pending" <%=s.getCurationStatus().equals("pending") ? "selected":""%>>Pending</option>
                </select>
                    <br>
                    <br>
                    <select id="action<%=count%>" name="action<%=count%>" onchange="checkDropdown('action<%=count%>','status<%=count%>','action')">
                        <option value="load" <%=s.getCurationStatus().equals("pending") && sample.getId()==0 ? "selected":""%>>Load</option>
                        <option value="ignore" <%=(s.getCurationStatus().equals("not4Curation") || s.getCurationStatus().equals("futureCuration")) ? "selected":""%>>Ignore</option>
                        <option value="edit" <%=s.getCurationStatus().equals("loaded") || sample.getId()!=0 ? "selected":""%>>Edit</option>
                    </select>
                </td>

                <%try{ for (n = 0; n < conds.size(); n++) {%>
                <td align="right">
                    <input type="checkbox" value="<%=n%>" class="expCondition<%=n%>" name="expCondition<%=count%>" id="expCondition<%=count%>" checked>
                    <input type="hidden" name="cId<%=count%>" id="cId<%=count%>" value="<%=conds.get(n).getId()%>">
                </td>
                <td>
                    <input name="xcoId<%=count%>_<%=n%>" id="xcoId<%=count%>_<%=n%>" value="<%=conds.get(n).getOntologyId()%>">
                    <a href="" id="xco<%=count%><%=n%>_popup" onclick="ontPopup('xcoId<%=count%>_<%=n%>','xco','xco<%=count%><%=n%>_term')" style="color:black;">Ont Tree</a><br>
                    <input type="text" id="xco<%=count%><%=n%>_term" name="xco<%=count%><%=n%>_term" value="" style="border: none; background: transparent;width: 100%" readonly/>
                </td>
                <td><input type="number" name="cOrdinality<%=count%>" value="<%=conds.get(n).getOrdinality()%>" style="width: 30px"/></td>
                <td><input type="text" size="7" name="cValueMin<%=count%>" value="<%=conds.get(n).getValueMin()%>"/></td>
                <td><input type="text" size="7" name="cValueMax<%=count%>" value="<%=conds.get(n).getValueMax()%>"/></td>
                <td><select name="cUnits<%=count%>" id="cUnits<%=count%>">
                    <% for (String unit : unitList){%>
                    <option value="<%=unit%>" <%=Utils.stringsAreEqual(conds.get(n).getUnits(),unit) ? "selected" : ""%>><%=unit%></option>
                    <% } %></select>
                </td>
                <td><input type="text" size="12" name="cMinDuration<%=count%>"
                           value="<%=conds.get(n).getDurationLowerBound()%>"/><%=fu.buildSelectList("cMinDurationUnits"+count, timeUnits, "")%>
                </td>
                <td><input type="text" size="12" name="cMaxDuration<%=count%>"
                           value="<%=conds.get(n).getDurationUpperBound()%>"/><%=fu.buildSelectList("cMaxDurationUnits"+count, timeUnits, "")%>
                </td>
                <td><input type="text" size="30" name="cApplicationMethod<%=count%>" value="<%=Utils.NVL(conds.get(n).getApplicationMethod(),"")%>"/></td>

                <td><input type="text" size="30" name="conNotes<%=count%>" value="<%=Utils.NVL(conds.get(n).getNotes(),"")%>"/></td>
                <%}}
                catch (Exception e){System.out.println(e);}
                j=n;
                    for (Condition c : conditions){%>
                <td align="right">
                <input type="checkbox" value="<%=j%>" class="expCondition<%=j%>" name="expCondition<%=count%>" id="expCondition<%=count%>" checked>
                <input type="hidden" value="" name="cId<%=count%>" id="cId<%=count%>">
                </td>
                <td>
                    <input name="xcoId<%=count%>_<%=j%>" id="xcoId<%=count%>_<%=j%>" value="<%=c.getOntologyId()%>">
                    <a href="" id="xco<%=count%><%=j%>_popup" onclick="ontPopup('xcoId<%=count%>_<%=j%>','xco','xco<%=count%><%=j%>_term')" style="color:black;">Ont Tree</a><br>
                    <input type="text" id="xco<%=count%><%=j%>_term" name="xco<%=count%><%=j%>_term" value="<%=xcoMap.get(c.getOntologyId())%>" style="border: none; background: transparent;width: 100%" readonly/>
                </td>
                <td><input type="number" size="7" name="cOrdinality<%=count%>" value="<%=c.getOrdinality()%>" style="width: 30px"/></td>
                <td><input type="text" size="7" name="cValueMin<%=count%>" value="<%=c.getValueMin()%>"/></td>
                <td><input type="text" size="7" name="cValueMax<%=count%>" value="<%=c.getValueMax()%>"/></td>
                <td><select name="cUnits<%=count%>" id="cUnits<%=count%>">
                    <% for (String unit : unitList){%>
                    <option value="<%=unit%>" <%=Utils.stringsAreEqual(c.getUnits(),unit) ? "selected" : ""%>><%=unit%></option>
                <% } %></select>
                </td>
                <td><input type="text" size="12" name="cMinDuration<%=count%>"
                           value="<%=c.getDurationLowerBound()%>"/><%=fu.buildSelectList("cMinDurationUnits" + count, timeUnits, "")%>
                </td>
                <td><input type="text" size="12" name="cMaxDuration<%=count%>"
                           value="<%=c.getDurationUpperBound()%>"/><%=fu.buildSelectList("cMaxDurationUnits" + count, timeUnits, "")%>
                </td>
                <td><input type="text" size="30" name="cApplicationMethod<%=count%>" value="<%=c.getApplicationMethod()%>"/></td>

                <td><input type="text" size="30" name="conNotes<%=count%>" value="<%=c.getNotes()%>"/></td>
                <% j++;}
                for (int i = j; i < 15; i++) {%>
                <td align="right">
                    <input type="checkbox" value="<%=i%>" class="expCondition<%=i%>" name="expCondition<%=count%>" id="expCondition<%=count%>">
                    <input type="hidden" value="" name="cId<%=count%>" id="cId<%=count%>">
                </td>
                <td>
                    <input name="xcoId<%=count%>_<%=i%>" id="xcoId<%=count%>_<%=i%>" value="">
                    <a href="" id="xco<%=count%><%=i%>_popup" onclick="ontPopup('xcoId<%=count%>_<%=i%>','xco','xco<%=count%><%=i%>_term')" style="color:black;">Ont Tree</a><br>
                    <input type="text" id="xco<%=count%><%=i%>_term" name="xco<%=count%><%=i%>_term" value="" style="border: none; background: transparent;width: 100%" readonly/>
                </td>
                <td><input type="number" size="7" name="cOrdinality<%=count%>" value="" style="width: 30px"/></td>
                <td><input type="text" size="7" name="cValueMin<%=count%>" value=""/></td>
                <td><input type="text" size="7" name="cValueMax<%=count%>" value=""/></td>
                <td><select name="cUnits<%=count%>" id="cUnits<%=count%>">
                    <% for (String unit : unitList){%>
                    <option value="<%=unit%>"><%=unit%></option>
                    <% } %></select>
                </td>
                <td><input type="text" size="12" name="cMinDuration<%=count%>"
                           value=""/><%=fu.buildSelectList("cMinDurationUnits"+count, timeUnits, "")%>
                </td>
                <td><input type="text" size="12" name="cMaxDuration<%=count%>"
                           value=""/><%=fu.buildSelectList("cMaxDurationUnits"+count, timeUnits, "")%>
                </td>
                <td><input type="text" size="30" name="cApplicationMethod<%=count%>" value=""/></td>

                <td><input type="text" size="30" name="conNotes<%=count%>" value=""/></td>
                <% } %>
            </tr>
                <%
      count++;
      }
  %></tbody>
    </table>
            </div>
            <br>
            <input type="button" value="Load Samples" style="float: right;" onclick="submitForm()"/>
    <input type="hidden" value="<%=request.getParameter("token")%>" name="token" />
    <input type="hidden" id="count" name="count" value="<%=count%>" />
    <input type="hidden" id="gse" name="gse" value="<%=gse%>" />
    <input type="hidden" id="title" name="title" value="<%=samples.get(0).getStudyTitle()%>">
    <input type="hidden" id="species" name="species" value="<%=species%>" />
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
        if (bool) {
            var count = document.getElementById("count");
            if (count.value === "")
                alert("Count is empty for an unknown reason. Unable to insert/edit");
            else
                document.getElementById("createSample").submit();
        }
    }
    function checkDropdown(actionId, statusId, act){
        var action = document.getElementById(actionId);
        var status = document.getElementById(statusId);
        if (act === "status"){
            if (status.value === "loaded"){
                action.value = "edit";
            }
            else if (status.value === "not4Curation" || status.value === "futureCuration"){
                action.value = "ignore";
            }
            else if (status.value === "pending"){
                action.value = "load";
            }
        }
        else if (act === "action"){
            if (status.value === "loaded" && action.value==="load"){
                action.value = "edit";
            }
            else if (status.value === "pending" && action.value === "edit"){
                action.value = "load";
            }
            else if (status.value === "not4Curation" && action.value === "edit"){
                action.value = "load";
            }
            else if (status.value === "futureCuration" && action.value === "edit"){
                action.value = "load";
            }
        }

    }

    function showColumns() {
        for (var i = 0; i < 15; i++) {
            var col = document.getElementById("showMe"+i);
            if (col.style.visibility === "collapse")
                col.style.visibility = "visible";
            else
                col.style.visibility = "collapse";
        }
    }

    function checkedAll(col, o) {
        var conBox = confirm("Select/deselect All?");
        if (conBox) {
            var elements = document.getElementsByClassName('expCondition' + col);
            for (var i = elements.length; i--;) {
                if (elements[i].type === 'checkbox') {
                    elements[i].checked = o.checked;
                }
            }
        }
        else {
            var check = document.getElementById('checkAll'+col).checked == true;
            document.getElementById('checkAll' + col).checked = !check;
        }
    }
</script>