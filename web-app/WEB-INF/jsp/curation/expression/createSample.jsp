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
    HttpRequestFacade req = new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req,error);
    PhenominerDAO pdao = new PhenominerDAO();
    List<GeoRecord> samples = pdao.getGeoRecords(gse,species);
    HashMap<String,String> tissueMap = (HashMap)request.getAttribute("tissueMap");
    HashMap<String,String> strainMap = (HashMap)request.getAttribute("strainMap");
    HashMap<String,String> ageLow = (HashMap)request.getAttribute("ageLow");
    HashMap<String,String> ageHigh = (HashMap)request.getAttribute("ageHigh");
    HashMap<String,String> cellType = (HashMap)request.getAttribute("cellType");
    HashMap<String,String> cellLine = (HashMap)request.getAttribute("cellLine");
    HashMap<String,String> gender = (HashMap)request.getAttribute("gender");
    HashMap<String, String> lifeStage = (HashMap)request.getAttribute("lifeStage");
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

        <form action="experiments.html" method="POST">

            <tr>
                <td align="left"><input type="submit" value="Load Samples"/></td>
            </tr>
                <%
            if(samples.size() != 0) {
        %>
            <tr>
                <th>GEO Sample ID: </th>
                <th>Sample Organism</th>
                <th>Strain ID (SAMPLE): </th>
                <th>Strain (RNA_SEQ): </th>
                <th>Cell Type ID (SAMPLE): </th>
                <th>Cell Type (RNA_SEQ): </th>
                <th>Cell Line ID (SAMPLE): </th>
                <th>Cell Line (RNA_SEQ): </th>
                <th>Tissue ID (SAMPLE): </th>
                <th>Tissue (RNA_SEQ): </th>
                <th>Sex (SAMPLE): </th>
                <th>Age (RNA_SEQ): </th>
                <th>Age (in days) Low (SAMPLE): </th>
                <th>Age (in days) High (SAMPLE): </th>
                <th>Life Stage (SAMPLE):</th>
            </tr>
                <%
            }

      int count = 0;
     for(GeoRecord s: samples){
         Sample sample = pdao.getSampleByGeoId(s.getSampleAccessionId());
        boolean bool = !(sample.getAgeDaysFromLowBound()==0 && Objects.equals(sample.getAgeDaysFromHighBound(), sample.getAgeDaysFromLowBound()) );
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
                <td><input type="text" name="strainId<%=count%>" id="strainId<%=count%>" value="<%=!Utils.isStringEmpty(sample.getStrainAccId()) ? sample.getStrainAccId() : Objects.toString(strainMap.get(s.getSampleStrain()),"")%>"> </td>
                <td><%=Objects.toString(s.getSampleStrain(),"")%></td>
                <td><input type="text" name="cellId<%=count%>" id="cellId<%=count%>" value="<%=!Utils.isStringEmpty(sample.getCellTypeAccId()) ? sample.getCellTypeAccId() : Objects.toString(cellType.get(s.getSampleCellType()),"")%>"> </td>
                <td><%=Objects.toString(s.getSampleCellType(),"")%></td>
                <td><input type="text" name="cellLineId<%=count%>" id="cellLineId<%=count%>" value="<%=!Utils.isStringEmpty(sample.getCellLineId()) ? sample.getCellLineId() : Objects.toString(cellLine.get(s.getSampleCellLine()),"")%>"> </td>
                <td><%=Objects.toString(s.getSampleCellLine(),"")%></td>
                <td>
                    <input type="text" name="tissueId<%=count%>" id="tissueId<%=count%>" value="<%=!Utils.isStringEmpty(sample.getTissueAccId()) ? sample.getTissueAccId() : Objects.toString(tissueMap.get(s.getSampleTissue()),"")%>">
                </td>
                <td><%=Objects.toString(s.getSampleTissue(),"")%></td>
                <td>
                    <select name="sex<%=count%>" id="sex<%=count%>">
                        <option value="male" <%=Utils.stringsAreEqual(sample.getSex(),"male") ? "selected" : Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"male") ? "selected":""%>>Male</option>
                        <option value="female" <%=Utils.stringsAreEqual(sample.getSex(),"female") ? "selected" : Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"female") ? "selected":""%>>Female</option>
                        <option value="both" <%=Utils.stringsAreEqual(sample.getSex(),"both") ? "selected" : Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"both") ? "selected":""%>>both</option>
                        <option value="not specified" <%=Utils.stringsAreEqual(sample.getSex(),"not specified") ? "selected" : Utils.stringsAreEqual(Objects.toString(gender.get(s.getSampleGender())) ,"not specified") ? "selected":""%>>Not Specified</option>
                    </select>
                </td>
                <td><%=Objects.toString(s.getSampleAge(),"")%> </td>
                <td><input type="text" name="ageLow<%=count%>" id="ageLow<%=count%>" value="<%=(bool) ?  sample.getAgeDaysFromLowBound() : Objects.toString(ageLow.get(s.getSampleAge()),"")%>"> </td>
                <td><input type="text" name="ageHigh<%=count%>" id="ageHigh<%=count%>" value="<%=bool ?  sample.getAgeDaysFromHighBound() : Objects.toString(ageHigh.get(s.getSampleAge()),"")%>"> </td>
                <td><input type="text" name="lifeStage<%=count%>" id="lifeStage<%=count%>" value="<%=!Utils.isStringEmpty(sample.getLifeStage()) ?  sample.getLifeStage():Objects.toString(lifeStage.get(s.getSampleAge()),"" )%>"></td>

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