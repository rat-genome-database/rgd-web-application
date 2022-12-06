<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Sample" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.GeoRecord" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Objects" %>
<%@ page import="java.util.Set" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>

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
<link rel="stylesheet" href="/rgdweb/OntoSolr/jquery.autocomplete.css" type="text/css" />
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

</style>
<script type="text/javascript" src="/rgdweb/js/ontPopUp/ontPopupBrowser.js"></script>
<%

    String pageTitle = "Create Geo Sample";
    String headContent = "";
    String pageDescription = "Create Geo Sample";

%>

<%@ include file="/common/headerarea.jsp" %>
<%

    String gse = request.getParameter("gse");
    String species = request.getParameter("species");
    HttpRequestFacade req = new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req,error);
    PhenominerDAO pdao = new PhenominerDAO();
    List<GeoRecord> samples = pdao.getGeoRecords(gse,species);
    HashMap<String,String> tissueMap = (HashMap)request.getAttribute("tissueMap");
    HashMap<String,String> tissueNameMap = (HashMap) request.getAttribute("tissueNameMap");
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
    int size = samples.size();
    String idName = "";
    boolean createSample = true;
%>


<br>
<div>
    <%
        if(samples.size() != 0) {
    %>
        <form action="experiments.html" method="POST">
            <table  class="t">
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


    <table class="table table-striped">

        <form action="experiments.html" method="POST" id="createSample">

            <tr>
                <td align="left"><input type="submit" value="Load Samples"/></td>
            </tr>
                <%
            if(samples.size() != 0) {
        %>
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
                <th>Sex (Curated): </th>
                <th>Age (Source): </th>
                <th>Age (in days) Low (Curated): </th>
                <th>Age (in days) High (Curated): </th>
                <th>Life Stage (Curated):</th>
                <th>Public Notes:</th>
                <th>Curator Notes:</th>
                <th>Status:</th>
            </tr>
                <%
            }

      int count = 0;
     for(GeoRecord s: samples){
boolean bool = false;
         Sample sample = pdao.getSampleByGeoId(s.getSampleAccessionId());

          try{
         if (sample == null)
             sample = new Sample();
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
                <td><input type="text" name="sampleId<%=count%>" id="sampleId<%=count%>" value="<%=dm.out("sampleId"+count,s.getSampleAccessionId())%>" readonly> </td>
                <td><%=s.getSampleOrganism()%></td>
                <td><%=Objects.toString(s.getSampleStrain(),"")%></td>
                <td><input type="text" name="strainId<%=count%>" id="strainId<%=count%>" value="<%=!Utils.isStringEmpty(sample.getStrainAccId()) ? sample.getStrainAccId() : Objects.toString(strainMap.get(s.getSampleStrain()),"")%>">
                    <br><input type="text" id="rs<%=count%>_term" name="rs<%=count%>_term" value="<%=Objects.toString(strainNameMap.get(s.getSampleStrain()),"")%>" style="border: none; background: transparent;width: 100%" readonly/>
                    <a href="" id="rs<%=count%>_popup" onclick="ontPopup('strainId<%=count%>','rs','rs<%=count%>_term')" style="color:black;">Ont Tree</a></td>
                <td><%=Objects.toString(s.getSampleCellType(),"")%></td>
                <td><input type="text" name="cellTypeId<%=count%>" id="cellTypeId<%=count%>" value="<%=!Utils.isStringEmpty(sample.getCellTypeAccId()) ? sample.getCellTypeAccId() : Objects.toString(cellTypeMap.get(s.getSampleCellType()),"")%>">
                    <br><input type="text" id="cl<%=count%>_term" name="cl<%=count%>_term" value="<%=Objects.toString(cellNameMap.get(s.getSampleCellType()),"")%>" style="border: none; background: transparent;width: 100%" readonly/>
                    <a href="" id="cl<%=count%>_popup" onclick="ontPopup('cellTypeId<%=count%>','cl','cl<%=count%>_term')" style="color:black;">Ont Tree</a></td>
                <td><%=Objects.toString(s.getSampleCellLine(),"")%></td>
                <td><input type="text" name="cellLineId<%=count%>" id="cellLineId<%=count%>" value="<%=!Utils.isStringEmpty(sample.getCellLineId()) ? sample.getCellLineId() : Objects.toString(cellLine.get(s.getSampleCellLine()),"")%>"> </td>
                <td><%=Objects.toString(s.getSampleTissue(),"")%></td>
                <td>
                    <input type="text" name="tissueId<%=count%>" id="tissueId<%=count%>" value="<%=!Utils.isStringEmpty(sample.getTissueAccId()) ? sample.getTissueAccId() : Objects.toString(tissueMap.get(s.getSampleTissue()),"")%>">
                    <br><input type="text" id="uberon<%=count%>_term" name="uberon<%=count%>_term" value="<%=Objects.toString(tissueNameMap.get(s.getSampleTissue()),"")%>" style="border: none; background: transparent;width: 100%" readonly/>
                    <a href="" id="uberon<%=count%>_popup" onclick="ontPopup('tissueId<%=count%>','uberon','uberon<%=count%>_term')" style="color:black;">Ont Tree</a>
                </td>
                <td>
                    <select name="sex<%=count%>" id="sex<%=count%>">
                        <option value="male" <%=Utils.stringsAreEqual(sample.getSex(),"male") ? "selected" : Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"male") ? "selected":""%>>Male</option>
                        <option value="female" <%=Utils.stringsAreEqual(sample.getSex(),"female") ? "selected" : Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"female") ? "selected":""%>>Female</option>
                        <option value="both" <%=Utils.stringsAreEqual(sample.getSex(),"both") ? "selected" : Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"both") ? "selected":""%>>both</option>
                        <option value="not specified" <%=Utils.stringsAreEqual(sample.getSex(),"not specified") ? "selected" : Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"not specified") ? "selected":""%>>Not Specified</option>
                    </select>
                </td>
                <td><%=Objects.toString(s.getSampleAge(),"")%> </td>
                <td><input type="text" name="ageLow<%=count%>" id="ageLow<%=count%>" value="<%=bool ?  sample.getAgeDaysFromLowBound() : Objects.toString(ageLow.get(s.getSampleAge()),"")%>"> </td>
                <td><input type="text" name="ageHigh<%=count%>" id="ageHigh<%=count%>" value="<%=bool ?  sample.getAgeDaysFromHighBound() : Objects.toString(ageHigh.get(s.getSampleAge()),"")%>"> </td>
                <td>
                    <fieldset>
                        <label><input type="checkbox" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="embryonic"
                            <%=!Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage().contains("embryonic") ? "checked": "":
                            Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("embryonic") ? "checked":""%>> embryonic</label>
                        <label><input type="checkbox" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="neonatal"
                            <%=!Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage().contains("neonatal") ? "checked": "":
                            Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("neonatal") ? "checked":""%>> neonatal</label>
                        <label><input type="checkbox" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="weanling"
                            <%=!Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage().contains("weanling") ? "checked": "":
                            Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("weanling") ? "checked":""%>> weanling</label><br>
                        <label><input type="checkbox" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="juvenile"
                            <%=!Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage().contains("juvenile") ? "checked": "":
                            Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("juvenile") ? "checked":""%>> juvenile</label>
                        <label><input type="checkbox" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="adult"
                            <%=!Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage().contains("adult") ? "checked": "":
                            Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("adult") ? "checked":""%>> adult</label>
                        <label><input type="checkbox" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="aged"
                            <%=!Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage().contains("aged") ? "checked": "":
                            Objects.toString(lifeStage.get(s.getSampleAge()),"" ).contains("aged") ? "checked":""%>> aged</label>
                    </fieldset>
                </td>
                <td><textarea name="notes<%=count%>" id="notes<%=count%>" style="height: 120px"><%=sample.getNotes()!=null ? sample.getNotes() : Objects.toString(notes.get(null),"")%></textarea></td>
                <td><textarea name="cNotes<%=count%>" id="cNotes<%=count%>" style="height: 120px"><%=sample.getCuratorNotes()!=null ? sample.getCuratorNotes() : Objects.toString(curNotes.get(null),"")%></textarea></td>
                <td><select id="status<%=count%>" name="status<%=count%>">
                    <option value="loaded" selected>Loaded</option>
                    <option  value="not4Curation">Not For Curation</option>
                    <option value="futureCuration">Future Curation</option>
                    <option  value="pending">Pending</option>
                </select>
                </td>
            </tr>

                <%
      count++;
      }
  %>
    </table>
    <input type="hidden" value="<%=request.getParameter("token")%>" name="token" />
    <input type="hidden" id="count" name="count" value="<%=count%>" />
    <input type="hidden" id="gse" name="gse" value="<%=gse%>" />
    <input type="hidden" id="species" name="species" value="<%=species%>" />
    </form>
</div>


</body>
</html>
<%@ include file="/common/footerarea.jsp"%>