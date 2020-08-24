<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Sample" %>
<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.GeoRecord" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Experiment" %>
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.6/umd/popper.min.js"></script>
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/js/bootstrap.min.js"></script>

<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.2.1/css/bootstrap.min.css">
<link href="//maxcdn.bootstrapcdn.com/font-awesome/4.1.0/css/font-awesome.min.css" rel="stylesheet">
<link rel="stylesheet" type="text/css" href="/rgdweb/css/enrichment/analysis.css">
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
<script type="text/javascript" src="/rgdweb/js/ontologyLookup.js"></script>
<!--script type="text/javascript" src="/OntoSolr/files/jquery-1.4.3.min.js"></script>
<script type="text/javascript" src="/OntoSolr/files/jquery.autocomplete.js"></script-->
<script type="text/javascript" src="/QueryBuilder/js/jquery.autocomplete.js"></script>

<script type="text/javascript" src="/rgdweb/OntoSolr/ont_util.js"></script>
<script>
    var justLoaded = true;
    var lastIndex = 0;
    $(document).ready(function () {
        var not4Curation = ' AND NOT Not4Curation';
        <% for (int i = 0; i < 15; i++) { %>
        $("#strainId").autocomplete('/OntoSolr/select', {
                    extraParams: {
                        'qf': 'term_en^1 term_en_sp^3 term_str^2 term^1 synonym_en^1 synonym_en_sp^3  synonym_str^2 synonym^1 def^1 anc^20 idl_s^2',
                        'bf': 'term_len_l^8',
                        'fq': 'cat:RS AND synonym:(+RGD +ID)' + not4Curation,
                        'wt': 'velocity',
                        'v.template': 'curtermselect'
                    },
                    max: 10000
                }
        );
        $("#strainId").result(function (data, value) {
            $("#strainId").val(value[1]);
            $("#strainTerm").html(value[0]);
        });
        <%}%>
        <% for (int i = 0; i < 15; i++) { %>
        $("#tissueId").autocomplete('/OntoSolr/select', {
                    extraParams: {
                        'qf': 'term_en^5 term_en_sp^2 term_str^3 term^3 synonym_en^4.5 synonym_en_sp^1.5  synonym_str^2 synonym^2 def^1 idl_s^2',
                        'bf': 'term_len_l^2',
                        'fq': 'cat:UBERON' + not4Curation,
                        'wt': 'velocity',
                        'v.template': 'termidsel_cur'
                    },
                    max: 10000,
                    multiple: true,
                    multipleSeparator: '|'
                }
        );
        $("#tissueId").result(function (data, value) {
            $("#tissueId").val(value[1]);
            $("#tissueTerm").html(value[0]);
        });
        <%}%>
    });
</script>
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
      int tcount = 1;

     for(String tissue: tissueMap.keySet()){
  %>
            <tr>
                <td><label for="tissue<%=tcount%>" style="color: #24609c; font-weight: bold;">Tissue:  &nbsp&nbsp</label><input type="text" name="tissue<%=tcount%>" id="tissue<%=tcount%>" value="<%=tissue%>" readonly></td>
                <td><label for="tissueId<%=tcount%>" style="color: #24609c; font-weight: bold;">Tissue Id: &nbsp&nbsp </label><input type="text" name="tissueId<%=tcount%>" id="tissueId<%=tcount%>" value="<%=tissueMap.get(tissue)%>"> </td>
                <td><span id="tissueTerm" class="highlight"></span></td>
            </tr>

        <%
      tcount++;
      }
                    int scount = 1;
                    for(String strain: strainMap.keySet()){
                %>
            <tr>
                <td><label for="strain<%=scount%>" style="color: #24609c; font-weight: bold;">Strain: &nbsp&nbsp </label><input type="text" name="strain<%=scount%>" id="strain<%=scount%>" value="<%=strain%>" readonly></td>
                <td><label for="strainId<%=scount%>" style="color: #24609c; font-weight: bold;">Strain Id: &nbsp&nbsp </label><input type="text" name="strainId<%=scount%>" id="strainId<%=scount%>" value="<%=strainMap.get(strain)%>"> </td>
                <td><span id="strainTerm" class="highlight"></span></td>
            </tr>

        <%
                    scount++;
                }
            int clcount = 1;
            for(String cellLine: cellLineMap.keySet()){
        %>
                <tr>
                    <td><label for="cellLine<%=clcount%>" style="color: #24609c; font-weight: bold;">cellLine: &nbsp&nbsp </label><input type="text" name="cellLine<%=clcount%>" id="cellLine<%=clcount%>" value="<%=cellLine%>" readonly></td>
                    <td><label for="cellLineId<%=clcount%>" style="color: #24609c; font-weight: bold;">cellLine Id: &nbsp&nbsp </label><input type="text" name="cellLineId<%=clcount%>" id="cellLineId<%=clcount%>" value="<%=cellLineMap.get(cellLine)%>"> </td>
                    <td></td>
                </tr>

                <%
                        clcount++;
                    }
                    int cTcount = 1;
                    for(String cellType: cellTypeMap.keySet()){
                %>
                <tr>
                    <td><label for="cellType<%=cTcount%>" style="color: #24609c; font-weight: bold;">cellType: &nbsp&nbsp </label><input type="text" name="cellType<%=cTcount%>" id="cellType<%=cTcount%>" value="<%=cellType%>" readonly></td>
                    <td><label for="cellTypeId<%=cTcount%>" style="color: #24609c; font-weight: bold;">cellType Id: &nbsp&nbsp </label><input type="text" name="cellTypeId<%=cTcount%>" id="cellTypeId<%=cTcount%>" value="<%=cellTypeMap.get(cellType)%>"> </td>
                    <td></td>
                </tr>

                <%
                        cTcount++;
                    }
                  int ageCount = 1;
                    for(String age: ages){
                %>
            <tr>
                <td><label for="age<%=tcount%>" style="color: #24609c; font-weight: bold;">Age: &nbsp&nbsp </label><input type="text" name="age<%=ageCount%>" id="age<%=ageCount%>" value="<%=age%>" readonly></td>
                <td><label for="ageLow<%=tcount%>" style="color: #24609c; font-weight: bold;">Age Low:  &nbsp&nbsp</label><input type="text" name="ageLow<%=ageCount%>" id="ageLow<%=ageCount%>" > </td>
                <td><label for="ageHigh<%=tcount%>" style="color: #24609c; font-weight: bold;">Age High: &nbsp&nbsp </label><input type="text" name="ageHigh<%=ageCount%>" id="ageHigh<%=ageCount%>" > </td>
                <td><label for="stage<%=tcount%>" style="color: #24609c; font-weight: bold;">Developmental Stage</label><select name="stage<%=tcount%>" id="stage<%=tcount%>">
                    <option value="embryonic">embryonic (< 0 days)</option>
                    <option value="neonatal">neonatal (0 - 20 days)</option>
                    <option value="weanling">weanling (21 – 34 days)</option>
                    <option value="juvenile">juvenile (35 – 55 days)</option>
                    <option value="adult">adult (56 – 719 days)</option>
                    <option value="aged">aged (>=720 days)</option>
                </select></td>
            </tr>

                <%
                    ageCount++;
                }
                    int gcount = 1;
                    for(String g: gender){
                %>
                <tr>
                    <td><label for="gender<%=gcount%>" style="color: #24609c; font-weight: bold;">Sex: &nbsp&nbsp </label><input type="text" name="gender<%=gcount%>" id="gender<%=gcount%>" value="<%=g%>" readonly></td>
                    <td><label for="sex<%=gcount%>" style="color: #24609c; font-weight: bold;">Select Sex:  &nbsp&nbsp</label><select name="sex<%=gcount%>" id="sex<%=gcount%>">
                        <option value="male">Male</option>
                        <option value="female">Female</option>
                        <option value="mixed">Mixed</option>
                        <option value="not specified">Not Specified</option>
                    </select></td>
                 </tr>

                <%
                        gcount++;
                    }
                %>

    </table>
    <input type="hidden" id="tcount" name="tcount" value="<%=tcount%>" />
            <input type="hidden" id="gcount" name="gcount" value="<%=gcount%>" />
    <input type="hidden" id="scount" name="scount" value="<%=scount%>" />
    <input type="hidden" id="ctcount" name="ctcount" value="<%=cTcount%>" />
    <input type="hidden" id="clcount" name="clcount" value="<%=clcount%>" />
    <input type="hidden" id="agecount" name="agecount" value="<%=ageCount%>" />
    <input type="hidden" id="gse" name="gse" value="<%=gse%>" />
    <input type="hidden" id="species" name="species" value="<%=species%>" />
    </form>
</div>


</body>
</html>