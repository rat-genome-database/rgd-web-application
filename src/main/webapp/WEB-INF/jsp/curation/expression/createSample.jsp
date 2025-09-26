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
<%@ page import="edu.mcw.rgd.datamodel.XdbId" %>
<%@ page import="edu.mcw.rgd.dao.impl.XdbIdDAO" %>

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
    List<String> cultureUnitList = pdao.getDistinct("PHENOMINER_ENUMERABLES where type=7", "value", true);
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

    try {
    OntologyXDAO xdao = new OntologyXDAO();
    XdbIdDAO xdbDAO = new XdbIdDAO();
    List<GeoRecord> samples = pdao.getGeoRecords(gse,species);
    int count = 0, curCount = 0, batchSize = 0;
    boolean tooManySamples = Utils.stringsAreEqual((String) request.getAttribute("tooManySamples"), "true");
    HashMap<String,String> tissueMap = new HashMap<>();
    HashMap<String,String> tissueNameMap = new HashMap<>();
    HashMap<String,String> vtMap = new HashMap<>();
    HashMap<String,String> vtNameMap = new HashMap<>();
    HashMap<String,String> strainMap = new HashMap<>();
    HashMap<String,String> strainNameMap = new HashMap<>();
    HashMap<String,String> ageLow = new HashMap<>();
    HashMap<String,String> ageHigh = new HashMap<>();
    HashMap<String,String> clinMeasMap = new HashMap<>();
    HashMap<String,String> clinMeasNameMap = new HashMap<>();
    HashMap<String,String> cellTypeMap = new HashMap<>();
    HashMap<String,String> cellNameMap = new HashMap<>();
    HashMap<String,String> cellLine = new HashMap<>();
    HashMap<String,String> gender = new HashMap<>();
    HashMap<String,String> lifeStage = new HashMap<>();
    HashMap<String,String> notes = new HashMap<>();
    HashMap<String,String> curNotes = new HashMap<>();
    HashMap<String,String> xcoMap = new HashMap<>();
    HashMap<String,String> culture = new HashMap<>();
    HashMap<String,String> cultureUnit = new HashMap<>();
    List<Condition> conditions = new ArrayList<>();
    List<Integer> refRgdIds = new ArrayList<>();
    if (tooManySamples){
        curCount = Integer.parseInt(request.getAttribute("curCount").toString());
        tissueMap = (HashMap) session.getAttribute("tissueMap");
        tissueNameMap = (HashMap) session.getAttribute("tissueNameMap");
        vtMap = (HashMap) session.getAttribute("vtMap");
        vtNameMap = (HashMap) session.getAttribute("vtNameMap");
        strainMap = (HashMap) session.getAttribute("strainMap");
        strainNameMap = (HashMap) session.getAttribute("strainNameMap");
        ageLow = (HashMap) session.getAttribute("ageLow");
        ageHigh = (HashMap) session.getAttribute("ageHigh");
        clinMeasMap = (HashMap) session.getAttribute("clinMeasMap");
        clinMeasNameMap = (HashMap) session.getAttribute("clinMeasNameMap");
        cellTypeMap = (HashMap) session.getAttribute("cellType");
        cellNameMap = (HashMap) session.getAttribute("cellNameMap");
        cellLine = (HashMap) session.getAttribute("cellLine");
        gender = (HashMap) session.getAttribute("gender");
        lifeStage = (HashMap) session.getAttribute("lifeStage");
        notes = (HashMap) session.getAttribute("notesMap");
        curNotes = (HashMap) session.getAttribute("curNotesMap");
        xcoMap = (HashMap) session.getAttribute("xcoTerms");
        culture = (HashMap) session.getAttribute("cultureDur");
        cultureUnit = (HashMap) session.getAttribute("cultureUnit");
        conditions = (List) session.getAttribute("conditions");
        refRgdIds = (List) session.getAttribute("refRgdIds");
    }
    else{
        tissueMap = (HashMap)request.getAttribute("tissueMap");
        tissueNameMap = (HashMap) request.getAttribute("tissueNameMap");
        vtMap = (HashMap) request.getAttribute("vtMap");
        vtNameMap = (HashMap) request.getAttribute("vtNameMap");
        strainMap = (HashMap)request.getAttribute("strainMap");
        strainNameMap = (HashMap) request.getAttribute("strainNameMap");
        ageLow = (HashMap)request.getAttribute("ageLow");
        ageHigh = (HashMap)request.getAttribute("ageHigh");
        clinMeasMap = (HashMap) request.getAttribute("clinMeasMap");
        clinMeasNameMap = (HashMap) request.getAttribute("clinMeasNameMap");
        cellTypeMap = (HashMap)request.getAttribute("cellType");
        cellNameMap = (HashMap) request.getAttribute("cellNameMap");
        cellLine = (HashMap)request.getAttribute("cellLine");
        gender = (HashMap)request.getAttribute("gender");
        lifeStage = (HashMap)request.getAttribute("lifeStage");
        notes = (HashMap)request.getAttribute("notesMap");
        curNotes = (HashMap) request.getAttribute("curNotesMap");
        xcoMap = (HashMap) request.getAttribute("xcoTerms");
        culture = (HashMap) request.getAttribute("cultureDur");
        cultureUnit = (HashMap) request.getAttribute("cultureUnit");
        conditions = (ArrayList) request.getAttribute("conditions");
        refRgdIds = (ArrayList) request.getAttribute("refRgdIds");
    }
    // save request for where left off, 300, 300*x
    List<Sample> sampleList = pdao.getSampleByGeoStudyId(gse);
    boolean updateSample = (sampleList != null && !sampleList.isEmpty());;
    int size = samples.size();
    String idName = "";
    boolean createSample = true;
    List<Experiment> experiments = updateSample ? pdao.getExperiments(samples.get(0).getGeoAccessionId()) : new ArrayList<>();

    Study study = null;

        if (size > 100) {
            session.setAttribute("tissueMap", tissueMap);
            session.setAttribute("tissueNameMap", tissueNameMap);
            session.setAttribute("vtMap", vtMap);
            session.setAttribute("vtNameMap", vtNameMap);
            session.setAttribute("strainMap", strainMap);
            session.setAttribute("strainNameMap", strainNameMap);
            session.setAttribute("ageLow", ageLow);
            session.setAttribute("ageHigh", ageHigh);
            session.setAttribute("clinMeasMap", clinMeasMap);
            session.setAttribute("clinMeasNameMap", clinMeasNameMap);
            session.setAttribute("cellType", cellTypeMap);
            session.setAttribute("cellNameMap", cellNameMap);
            session.setAttribute("cellLine", cellLine);
            session.setAttribute("gender", gender);
            session.setAttribute("lifeStage", lifeStage);
            session.setAttribute("notesMap", notes);
            session.setAttribute("curNotesMap", curNotes);
            session.setAttribute("xcoTerms", xcoMap);
            session.setAttribute("cultureDur", culture);
            session.setAttribute("cultureUnit", cultureUnit);
            session.setAttribute("conditions", conditions);
            session.setAttribute("refRgdIds", refRgdIds);

        }

        batchSize = curCount+100;
%>


<br>
<div>
    <%
        if(samples.size() != 0) {
            StringBuilder pubmedIds = new StringBuilder();
            study = pdao.getStudyByGeoIdWithReferences(samples.get(0).getGeoAccessionId());
            List<XdbId> pmIds = new ArrayList<>();
            if (study!=null){
                for (Integer rgdId : study.getRefRgdIds()){
                    List<XdbId> dbs = xdbDAO.getXdbIdsByRgdId(2, rgdId);
                    pmIds.addAll(dbs);
                }
                for (int i = 0 ; i < pmIds.size(); i++){
                    if (i==pmIds.size()-1){
                        pubmedIds.append(pmIds.get(i).getAccId());
                    }
                    else
                        pubmedIds.append(pmIds.get(i).getAccId()).append(", ");
                }
            }
            else
                pubmedIds.append(samples.get(0).getPubmedId());
    %>
        <form action="experiments.html" method="POST">
            <table  class="t" style="width: 1880px">
                <tr>
                    <input type="hidden" id="geoId" name="geoId" value=<%=gse%> />
                    <td><b>Geo Accession Id: </b></td><td><a href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=<%=samples.get(0).getGeoAccessionId()%>" target="_blank"><%=samples.get(0).getGeoAccessionId()%></a></td>
                    <td><b>Study Title: </b></td><td><%=samples.get(0).getStudyTitle()%></td>
                    <td><b>PubMed Id: </b></td><td><%=pubmedIds%></td>
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




        <form action="/rgdweb/curation/expression/experiments.html" method="POST" id="createSample">
            <input type="button" value="Show/Hide Conditions" onclick="showColumns()">
            <input type="button" value="Load Samples" style="float: right;" onclick="submitForm()"/>
            <input type="hidden" value="<%=request.getParameter("token")%>" name="token" />
            <input type="hidden" id="count" name="count" value="<%=count%>" />
            <input type="hidden" id="curCount" name="curCount" value="<%=batchSize%>">
            <input type="hidden" id="sampSize" name="sampSize" value="<%=size%>">
            <input type="hidden" id="gse" name="gse" value="<%=gse%>" />
            <input type="hidden" id="title" name="title" value="<%=samples.get(0).getStudyTitle()%>">
            <input type="hidden" id="species" name="species" value="<%=species%>" />
            <%int refSize = 0;
            int refRgdSize = (refRgdIds != null && !refRgdIds.isEmpty()) ? refRgdIds.size() : 0;
            for(refSize = 0; refSize < refRgdSize ; refSize++) {%>
                <input type="hidden" name="refRgdId<%=refSize%>" id="refRgdId<%=refSize%>" value="<%=(refRgdIds.get(refSize)!=null && refRgdIds.get(refSize)!=0) ? refRgdIds.get(refSize) : ""%>">
            <%}
            for (int i = refSize; i < 3 ; i++){%>
                <input type="hidden" name="refRgdId<%=i%>" id="refRgdId<%=i%>" value="">
            <% } %>
            <br>
            <div class="sticky-table">
            <table class="table table-striped">

                <%
            if(samples.size() != 0) {
        %>
                <colgroup>
                    <col span="21">
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
                <th>Culture Duration (Curated)</th>
                <th>Cell Line (Source): </th>
                <th>Cell Line ID (Curated): </th>
                <th>Tissue (Source): </th>
                <th>Tissue ID (Curated): </th>
                <th>Vertebrate Trait  ID (Curated): </th>
                <th>Clinical Measurement ID (Curated): </th>
                <th>Sex (Curated): </th>
                <th>Age (Source): </th>
                <th>Age (in days) Low (Curated): </th>
                <th>Age (in days) High (Curated): </th>
                <th>Life Stage (Curated):</th>
<%--                <th>Reference RGD Ids:</th>--%>
                <th>Public Notes:</th>
                <th>Curator Notes:</th>
                <th>Status/Action:</th>
                <% int k = 0;
                    for (k = 0; k < conditions.size(); k++){%>
                <th><b style="font-size: x-large"><%=k+1%></b> <input type="checkbox" name="checkAll<%=k%>" id="checkAll<%=k%>" value="<%=k%>" onclick="checkedAll('<%=k%>', this)" checked></th>
                <th>AccId <%=k+1%>:</th>
                <th title="Ordinality <%=k+1%>">Ord <%=k+1%>:</th>
                <th>Min Value <%=k+1%>:</th>
                <th>Max Value <%=k+1%>:</th>
                <th>Unit <%=k+1%>:</th>
                <th>Min Dur <%=k+1%>:</th>
                <th>Max Dur <%=k+1%>:</th>
                <th>Application Method <%=k+1%>:</th>
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
            try {
            if (batchSize>samples.size())
                batchSize=samples.size();
//            System.out.println("batch:"+batchSize);
     for(int zed = curCount; zed < batchSize ; zed++){
         GeoRecord s = samples.get(zed);
//         if (count % 300 == 0)
//             break;
         boolean bool = false;
         Sample sample = pdao.getSampleByGeoId(s.getSampleAccessionId());
         Experiment exp = new Experiment();
         ClinicalMeasurement cm = new ClinicalMeasurement();
         List<Condition> conds = new ArrayList<>();
         GeneExpressionRecord r = new GeneExpressionRecord();
         try{
             r=geDAO.getGeneExpressionRecordBySampleId(sample.getId());
         }
         catch (Exception e){ }
         if (r!=null) {
             if (r.getClinicalMeasurementId() != null && r.getClinicalMeasurementId() != 0)
                 cm = pdao.getClinicalMeasurement(r.getClinicalMeasurementId());
             conds = r.getConditions();
             if (r.getExperimentId() != 0)
                exp = geDAO.getExperiment(r.getExperimentId());
         }
         int j = 0, n = 0;
       try{
          if (sample == null)
             sample = new Sample();
          bool = !(sample.getAgeDaysFromLowBound()==0 && (Objects.equals(sample.getAgeDaysFromHighBound(), sample.getAgeDaysFromLowBound())) );
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
//         System.out.println(s.getSampleAccessionId() + "|" + s.getSampleTitle());

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
                <td>
                    <input type="number" name="cultureDur<%=count%>" id="cultureDur<%=count%>" value="<%=(updateSample && !Objects.toString(culture.get(s.getSampleCellType()), "").isEmpty()) ? Objects.toString(culture.get(s.getSampleCellType()), "") : sample.getCultureDur()!=null ? sample.getCultureDur() : Objects.toString(culture.get(s.getSampleCellType()), "")%>">
                    <select name="cultureUnits<%=count%>" id="cultureUnits<%=count%>">
                        <% for (String unit : cultureUnitList){%>
                        <option value="<%=unit%>" <%=(updateSample && !Objects.toString(cultureUnit.get(s.getSampleCellType()),"").isEmpty()) ? (Objects.toString(cultureUnit.get(s.getSampleCellType()),"").equals(unit) ? "selected" : "") : ( !Utils.isStringEmpty(sample.getCultureDurUnit()) && sample.getCultureDurUnit().equals(unit) ) ? "selected" : Objects.toString(cultureUnit.get(s.getSampleCellType()),"").equals(unit) ? "selected" : ""%>><%=unit%></option>
                        <% } %>
                    </select>
                </td>
                <td><%=Objects.toString(s.getSampleCellLine(),"")%></td>
                <td><input type="text" name="cellLineId<%=count%>" id="cellLineId<%=count%>" value="<%=(updateSample && !Objects.toString(cellLine.get(s.getSampleCellLine()),"").isEmpty()) ? Objects.toString(cellLine.get(s.getSampleCellLine()),"") : !Utils.isStringEmpty(sample.getCellLineId()) ? sample.getCellLineId() : Objects.toString(cellLine.get(s.getSampleCellLine()),"")%>"> </td>
                <td><%=Objects.toString(s.getSampleTissue(),"")%></td>
                <td>
                    <input type="text" name="tissueId<%=count%>" id="tissueId<%=count%>" value="<%=(updateSample && !Objects.toString(tissueMap.get(s.getSampleTissue()),"").isEmpty()) ? Objects.toString(tissueMap.get(s.getSampleTissue()),"") :!Utils.isStringEmpty(sample.getTissueAccId()) ? sample.getTissueAccId() : Objects.toString(tissueMap.get(s.getSampleTissue()),"")%>">
                    <br><input type="text" id="uberon<%=count%>_term" name="uberon<%=count%>_term" value="<%=Objects.toString(tissueNameMap.get(s.getSampleTissue()),"")%>" title="<%=Utils.NVL(tissueNameMap.get(s.getSampleTissue()),"")%>"  style="border: none; background: transparent;width: 100%" readonly/>
                    <a href="" id="uberon<%=count%>_popup" onclick="ontPopup('tissueId<%=count%>','uberon','uberon<%=count%>_term')" style="color:black;">Ont Tree</a>
                </td>
                <td>
                    <input type="text" name="vtId<%=count%>" id="vtId<%=count%>" value="<%=(updateSample && !Objects.toString(vtMap.get(s.getSampleTissue()),"").isEmpty()) ? Objects.toString(vtMap.get(s.getSampleTissue()), "") : !Utils.isStringEmpty(exp.getTraitOntId()) ? Objects.toString(exp.getTraitOntId(),"") : Objects.toString(vtMap.get(s.getSampleTissue()), "")%>">
                    <br><input type="text" id="vt<%=count%>_term" name="vt<%=count%>_term" value="<%=Objects.toString(vtNameMap.get(s.getSampleTissue()),"")%>" title="<%=Utils.NVL(vtNameMap.get(s.getSampleTissue()),"")%>"  style="border: none; background: transparent;width: 100%" readonly/>
                    <a href="" id="vt<%=count%>_popup" onclick="ontPopup('vtId<%=count%>','vt','vt<%=count%>_term')" style="color:black;">Ont Tree</a>
                </td>
                <td>
                    <input type="text" name="cmoId<%=count%>" id="cmoId<%=count%>" value="<%=(updateSample && !Objects.toString(clinMeasMap.get(s.getSampleTissue()),"").isEmpty()) ? Objects.toString(clinMeasMap.get(s.getSampleTissue()), "") : !Utils.isStringEmpty(cm.getAccId()) ? Objects.toString(cm.getAccId(), "") : Objects.toString(clinMeasMap.get(s.getSampleTissue()),"")%>">
                    <br><input type="text" id="cmo<%=count%>_term" name="cmo<%=count%>_term" value="<%=Objects.toString(clinMeasNameMap.get(s.getSampleTissue()),"")%>" title="<%=Utils.NVL(clinMeasNameMap.get(s.getSampleTissue()),"")%>"  style="border: none; background: transparent;width: 100%" readonly/>
                    <a href="" id="cmo<%=count%>_popup" onclick="ontPopup('cmoId<%=count%>','cmo','cmo<%=count%>_term')" style="color:black;">Ont Tree</a>
                </td>
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
                    <%if (sample.getId()!=0 || s.getCurationStatus().equals("loaded")){%>
                    <option value="loaded" <%=s.getCurationStatus().equals("loaded") ? "selected":""%>>Loaded</option>
                    <%}%>
                    <option  value="not4Curation" <%=s.getCurationStatus().equals("not4Curation") ? "selected":""%>>Not For Curation</option>
                    <option value="futureCuration" <%=s.getCurationStatus().equals("futureCuration") ? "selected":""%>>Future Curation</option>
                    <option  value="pending" <%=s.getCurationStatus().equals("pending") ? "selected":""%>>Pending</option>
                </select>
                    <br>
                    <br>
                    <select id="action<%=count%>" name="action<%=count%>" onchange="checkDropdown('action<%=count%>','status<%=count%>','action')">
                        <option value="load" <%=s.getCurationStatus().equals("pending") ? "selected":""%>>Load</option>
                        <option value="ignore" <%=(s.getCurationStatus().equals("not4Curation") || s.getCurationStatus().equals("futureCuration")) ? "selected":""%>>Ignore</option>
                        <option value="edit" <%=s.getCurationStatus().equals("loaded")  ? "selected":""%>>Edit</option><!-- || sample.getId()!=0  && sample.getId()==0 -->
                    </select>
                </td>

                <%try{
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
                <td><input type="number" size="7" name="cOrdinality<%=count%>" value="<%=c.getOrdinality()%>" min="0" oninput="this.value = Math.abs(this.value)" style="width: 30px"/></td>
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
                    for (Condition c : conds) {%>
                <td align="right">
                    <input type="checkbox" value="<%=j%>" class="expCondition<%=j%>" name="expCondition<%=count%>" id="expCondition<%=count%>" checked>
                    <input type="hidden" name="cId<%=count%>" id="cId<%=count%>" value="<%=c.getId()%>">
                </td>
                <td>
                    <input name="xcoId<%=count%>_<%=j%>" id="xcoId<%=count%>_<%=j%>" value="<%=c.getOntologyId()%>">
                    <a href="" id="xco<%=count%><%=j%>_popup" onclick="ontPopup('xcoId<%=count%>_<%=j%>','xco','xco<%=count%><%=j%>_term')" style="color:black;">Ont Tree</a><br>
                    <input type="text" id="xco<%=count%><%=j%>_term" name="xco<%=count%><%=j%>_term" value="" style="border: none; background: transparent;width: 100%" readonly/>
                </td>
                <td><input type="number" name="cOrdinality<%=count%>" value="<%=c.getOrdinality()%>" min="0" oninput="this.value = Math.abs(this.value)" style="width: 30px"/></td>
                <td><input type="text" size="7" name="cValueMin<%=count%>" value="<%=c.getValueMin()%>"/></td>
                <td><input type="text" size="7" name="cValueMax<%=count%>" value="<%=c.getValueMax()%>"/></td>
                <td><select name="cUnits<%=count%>" id="cUnits<%=count%>">
                    <% for (String unit : unitList){%>
                    <option value="<%=unit%>" <%=Utils.stringsAreEqual(c.getUnits(),unit) ? "selected" : ""%>><%=unit%></option>
                    <% } %></select>
                </td>
                <td><input type="text" size="12" name="cMinDuration<%=count%>"
                           value="<%=c.getDurationLowerBound()%>"/><%=fu.buildSelectList("cMinDurationUnits"+count, timeUnits, "")%>
                </td>
                <td><input type="text" size="12" name="cMaxDuration<%=count%>"
                           value="<%=c.getDurationUpperBound()%>"/><%=fu.buildSelectList("cMaxDurationUnits"+count, timeUnits, "")%>
                </td>
                <td><input type="text" size="30" name="cApplicationMethod<%=count%>" value="<%=Utils.NVL(c.getApplicationMethod(),"")%>"/></td>

                <td><input type="text" size="30" name="conNotes<%=count%>" value="<%=Utils.NVL(c.getNotes(),"")%>"/></td>
                <%j++; }}
                catch (Exception e){/*System.out.println(e);*/}
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
                <td><input type="number" size="7" name="cOrdinality<%=count%>" value="" min="0" oninput="this.value = Math.abs(this.value)" style="width: 30px"/></td>
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
                    }catch (Exception e) {e.printStackTrace();}
//            System.out.println("count:"+count);
  %></tbody>
    </table>
            </div>
            <br>
            <input type="button" value="Load Samples" style="float: right;" onclick="submitForm()"/>
    </form>
</div>
<%}catch (Exception e){
    e.printStackTrace();
}%>

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
    window.addEventListener( "pageshow", function ( event ) {
        var historyTraversal = event.persisted ||
            ( typeof window.performance != "undefined" &&
                window.performance.navigation.type === 2 );
        if ( historyTraversal ) {
            // Handle page restore.
            window.location.reload();
        }
    });
</script>