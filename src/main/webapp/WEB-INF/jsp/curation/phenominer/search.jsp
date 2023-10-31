<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Experiment" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Record" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Condition" %>
<%@ page import="edu.mcw.rgd.dao.impl.ReferenceDAO" %>
<%
    String pageTitle = "Phenominer Curation";
    String headContent = "";
    String pageDescription = "";

    Study study = new Study();
    Experiment ex = new Experiment();
    Record rec = new Record();
    Condition cond = new Condition();

%>

<%@ include file="editHeader.jsp"%>

<script type="text/javascript" src="/rgdweb/js/util.js"></script>

<link rel="stylesheet" href="/rgdweb/js/windowfiles/dhtmlwindow.css" type="text/css"/>
<script type="text/javascript" src="/rgdweb/js/windowfiles/dhtmlwindow.js"></script>
<script type="text/javascript" src="/rgdweb/js/ontologyLookup.js"></script>

<script type="text/javascript" src="/QueryBuilder/js/jquery.autocomplete.js"></script>

<script type="text/javascript"  src="/rgdweb/OntoSolr/ont_util.js"></script>

<span class="phenominerPageHeader">Phenominer Search</span>

<div class="phenoNavBar">
<table>
    <tr>
        <td><a href='studies.html?act=new'>Create New Study</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='home.html'>Home</a></td>
        <td align="center"><img src="/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='studies.html'>List All Studies</a></td>
    </tr>
</table>
</div>
<script type="text/javascript">
    function submitPage(actionValue) {

        document.nav.action = actionValue;
        document.nav.submit();

    }

    $(document).ready(function(){
        var not4Curation = ' AND NOT Not4Curation';

      $("#sAccId").autocomplete('/solr/OntoSolr/select', {
                  extraParams:{
                  'qf': 'term_en^1 term_en_sp^3 term_str^2 term^1 synonym_en^1 synonym_en_sp^3  synonym_str^2 synonym^1 def^1 anc^20 idl_s^2',
                  'bf': 'term_len_l^8',
                  'fq': 'cat:RS'+not4Curation,
                  'wt': 'velocity',
                  'v.template': 'curtermselect'
                },
                max: 10000
              }
      );
    $("#sAccId").result(function(data, value){
       $("#sAccId").val(value[1]);
        $("#sTerm").html(value[0]);
       });

        $("#cmAccId").autocomplete('/solr/OntoSolr/select', {
                    extraParams:{
                        'qf': 'term_en^5 term_en_sp^2 term_str^3 term^3 synonym_en^4.5 synonym_en_sp^1.5  synonym_str^2 synonym^2 def^1 idl_s^2',
                        'bf': 'term_len_l^2',
                    'fq': 'cat:CMO'+not4Curation,
                    'wt': 'velocity',
                    'v.template': 'curtermselect'
                  },
                  max: 10000
                }
        );
      $("#cmAccId").result(function(data, value){
         $("#cmAccId").val(value[1]);
          $("#cmTerm").html(value[0]);
         });

        $("#mmAccId").autocomplete('/solr/OntoSolr/select', {
                    extraParams:{
                        'qf': 'term_en^5 term_en_sp^2 term_str^3 term^3 synonym_en^4.5 synonym_en_sp^1.5  synonym_str^2 synonym^2 def^1 idl_s^2',
                        'bf': 'term_len_l^2',
                    'fq': 'cat:MMO'+not4Curation,
                    'wt': 'velocity',
                    'v.template': 'curtermselect'
                  },
                  max: 10000
                }
        );
      $("#mmAccId").result(function(data, value){
         $("#mmAccId").val(value[1]);
          $("#mmTerm").html(value[0]);
         });

        $("#cAccId_1").autocomplete('/solr/OntoSolr/select', {
                    extraParams:{
                        'qf': 'term_en^5 term_en_sp^2 term_str^3 term^3 synonym_en^4.5 synonym_en_sp^1.5  synonym_str^2 synonym^2 def^1 idl_s^2',
                        'bf': 'term_len_l^2',
                    'fq': 'cat:XCO'+not4Curation,
                    'wt': 'velocity',
                    'v.template': 'curtermselect'
                  },
                  max: 10000
                }
        );
      $("#cAccId_1").result(function(data, value){
         $("#cAccId_1").val(value[1]);
          $("#cTerm_1").html(value[0]);
         });

        $("#expName").autocomplete('/solr/OntoSolr/select', {
                    extraParams:{
                    'qf': 'term^2 synonym^1 idl_s^1',
                    'fq': 'cat:(VT OR RDO)'+not4Curation,
                    'wt': 'velocity',
                    'v.template': 'termidsel_cur'
                  },
                  max: 10000
                }
        );

      $("#expName").result(function(data, value){
         $("#expName").val(value[0]);
         });

        $("#mmSite").autocomplete('/solr/OntoSolr/select', {
                  extraParams:{
                      'qf': 'term_en^5 term_en_sp^2 term_str^3 term^3 synonym_en^4.5 synonym_en_sp^1.5  synonym_str^2 synonym^2 def^1 idl_s^2',
                      'bf': 'term_len_l^2',
                      'fq': 'cat:MA'+not4Curation,
                      'wt': 'velocity',
                      'v.template': 'termidsel_cur'
                  },
                  max: 10000,
                  multiple: true,
                  multipleSeparator: '|'
                }
        );
        $("#mmSite").result(function(data, value){
            $("#mmSite").val(value[0]);
           });

    });
</script>

<form name="nav" action="" >

<input type="hidden" name="act" value="search" />


<table width="90%">
    <tr>
        <td align="right"><input type="submit" value="Find Studies" onClick="submitPage('studies.html')" />
        <input type="button" value="Find Experiments" onClick="submitPage('experiments.html')"/>
        <input type="button" value="Find Records" onClick="submitPage('records.html')"/>
        </td>
    </tr>
</table>


<table>
    <tr>
        <td>SID</td>
        <td>EID</td>
        <td>RID</td>
        <td>Study Name</td>
        <td>Source</td>
        <td>Type</td>
        <td>Reference</td>
        <td>Experiment Name</td>
    </tr>
    <tr>
        <td><input size="5" type="text" name="studyId" id="studyId" value="<%=dm.out("studyId", "")%>"> </td>
        <td><input size="10" type="text" name="expId" id="expId" value="<%=dm.out("expId", "")%>"> </td>
        <td><input size="10" type="text" name="recordId" id="recordId" value="<%=dm.out("recordId", "")%>"> </td>
        <td><input type="text" size="30" name="studyName" value="<%=dm.out("studyName", study.getName())%>"> </td>
        <td><%=fu.buildSelectList("source",dao.getDistinct("study","study_source", true), dm.out("source", study.getSource()))%></td>
        <td><%=fu.buildSelectList("type",dao.getDistinct("study","study_type", true), dm.out("type", study.getType()))%></td>
        <td><input size="10" type="text" name="reference" id="reference" value="<%=dm.out("reference", "")%>"> </td>
        <td><input type="text" size="30" name="expName" id="expName" value=""></td>

    </tr>
</table>

    <br>

    <table>
        <tr>
            <td><div class="highlight">Strain</div></td>
            <td>    ACC ID: <input type="text" id="sAccId" name="sAccId" value=""/>
                <a href="javascript:lookup_treeRender('sAccId', 'RS', 'RS:0000457' )"><img src="/rgdweb/common/images/tree.png" border="0"/></a>
                <span id="sTerm" class="highlight"></span>
            </td>
        </tr>
    </table>


    <table>
        <tr>
            <td>Animal Count</td>
            <td>Min Age</td>
            <td>Max Age</td>
            <td>Sex</td>
        </tr>
        <tr>
            <td><input type="text" size="11" name="sAnimalCount" value="<%=dm.out("sAnimalCount", rec.getSample().getNumberOfAnimals()==0?null:rec.getSample().getNumberOfAnimals())%>"/></td>
            <td><input type="text" size="7" name="sMinAge" value="<%=dm.out("sMinAge", rec.getSample().getAgeDaysFromLowBound())%>"/></td>
            <td><input type="text" size="7" name="sMaxAge" value="<%=dm.out("sMaxAge", rec.getSample().getAgeDaysFromHighBound())%>"/></td>
            <td><%=fu.buildSelectList("sSex", dao.getDistinct("PHENOMINER_ENUMERABLES where type=1 ", "value", true), dm.out("sSex", rec.getSample().getSex()))%>

        </tr>
    </table>
    

   <br>

    <table>
        <tr>
            <td><div class="highlight">Clinical Measurement</div></td>
            <td>ACC ID: <input type="text" id="cmAccId" name="cmAccId" value=""/>
            <a href="javascript:lookup_treeRender('cmAccId', 'CMO', 'CMO:0000000')"><img src="/rgdweb/common/images/tree.png" border="0"/></a>
            <span id="cmTerm" class="highlight"></span></td>
        </tr>
    </table>

    <table>
        <tr>
            <td>Value</td>
            <td>Units</td>
            <td>SD</td>
            <td>SEM</td>
            <td>Error</td>
            <td>Average Type</td>
            <td>Formula</td>
        </tr>
        <tr>
            <td><input type="text" size="7" name="cmValue" value="<%=dm.out("cmValue", rec.getMeasurementValue())%>"/></td>
            <td><%=fu.buildSelectListLabelsNewValue("cmUnits", dao.getDistinct("PHENOMINER_ENUMERABLES where type=3 ", "concat(LABEL,concat('|', VALUE))", true), dm.out("cmUnits", rec.getMeasurementUnits()))%>
            <td><input type="text" size="7" name="cmSD" value="<%=dm.out("cmSD", rec.getMeasurementSD())%>"/></td>
            <td><input type="text" size="7" name="cmSEM" value="<%=dm.out("cmSEM", rec.getMeasurementSem())%>"/></td>
            <td><input type="text" name="cmError" value="<%=dm.out("cmError", rec.getMeasurementError())%>"/></td>
            <td><%=fu.buildSelectList("cmAveType", dao.getDistinct("PHENOMINER_ENUMERABLES where type=4 ", "value", true), dm.out("cmAveType", rec.getClinicalMeasurement().getAverageType()))%>
            <td><input type="text" name="cmFormula" value="<%=dm.out("cmFormula", rec.getClinicalMeasurement().getFormula())%>"/></td>
        </tr>
    </table>

    <br>

    <table>
        <tr>
            <td><div class="highlight">Measurement Method</div></td>
            <td>ACC ID: <input type="text" id="mmAccId" name="mmAccId" value="<%=dm.out("mmAccId", rec.getMeasurementMethod().getAccId())%>"/>
                <a href="javascript:lookup_treeRender('mmAccId', 'MMO', 'MMO:0000000')"><img src="/rgdweb/common/images/tree.png" border="0"/></a>
                <span id="mmTerm" class="highlight"></span>
            </td>
        </tr>
    </table>

<table>
    <tr>
        <td>Duration</td>
        <td>Site</td>
        <td>PI Type</td>
        <td>PI Time</td>
        <td>PI Time Unit</td>
    </tr>
    <tr>
        <td><input type="text" size="7" name="mmDuration" value="<%=dm.out("mmDuration", rec.getMeasurementMethod().getDuration())%>"/></td>
        <td><input id="mmSite" size="40" type="text" name="mmSite" value="<%=dm.out("mmSite", rec.getMeasurementMethod().getSite())%>">
        <td><input type="text" name="mmPostInsultType" value="<%=dm.out("mmPostInsultType", rec.getMeasurementMethod().getPiType())%>"/></td>
        <td><input type="text" size="7" name="mmPostInsultTime" value="<%=dm.out("mmPostInsultTime", rec.getMeasurementMethod().getPiTimeValue())%>"/></td>
        <td><%=fu.buildSelectList("mmInsultTimeUnit", dao.getDistinct("PHENOMINER_ENUMERABLES where type=5 ", "value", true), dm.out("mmInsultTimeUnit", rec.getMeasurementMethod().getPiTypeUnit()))%>
    </tr>
</table>


    <br>
    <table>
        <tr>
            <td><div class="highlight">Experimental Condition</div></td>
            <td>    ACC ID: <input type="text" id="cAccId_1" name="cAccId" value="<%=dm.out("cAccId", cond.getOntologyId())%>"/>
                <a href="javascript:lookup_treeRender('cAccId_1', 'XCO', 'XCO:0000000')"><img src="/rgdweb/common/images/tree.png" border="0"/></a>&nbsp;&nbsp;
                <span id="cTerm_1" class="highlight"></span>
</td>
        </tr>
    </table>

    <table>
        <tr>
            <td>Min Value</td>
            <td>Max Value</td>
            <td>Units</td>
            <td>Min Dur</td>
            <td>Max Dur</td>
            <td>Application Method</td>
            <td>Ordinality</td>
        </tr>
        <tr>
            <td><input type="text" size="7" name="cValueMin" value="<%=dm.out("cValueMin", cond.getValueMin())%>"/></td>
            <td><input type="text" size="7" name="cValueMax" value="<%=dm.out("cValueMax", cond.getValueMax())%>"/></td>
            <td><%=fu.buildSelectList("cUnits",dao.getDistinct("experiment_condition","exp_cond_assoc_units", true), dm.out("cUnits", cond.getUnits()))%></td>
            <td><input type="text" size="12" name="cMinDuration" value="<%=dm.out("cMinDuration", cond.getDurationLowerBound()==0?null:cond.getDurationLowerBound())%>"/></td>
            <td><input type="text" size="12" name="cMaxDuration" value="<%=dm.out("cMaxDuration", cond.getDurationUpperBound()==0?null:cond.getDurationUpperBound())%>"/></td>
            <td><input type="text" name="cApplicationMethod" value="<%=dm.out("cApplicationMethod", cond.getApplicationMethod())%>"/></td>
            <td><input type="text" size="7" name="cOrdinality" value="<%=dm.out("cOrdinality", cond.getOrdinality())%>"/></td>
        </tr>
    </table>

<table width="90%">
    <tr>
       <td align="right"><input type="button" value="Find Studies" onClick="this.form.action='studies.html';this.form.submit()" />
        <input type="button" value="Find Experiments" onClick="this.form.action='experiments.html';this.form.submit()"/>
        <input type="button" value="Find Records" onClick="this.form.action='records.html';this.form.submit()"/>
        </td>
    </tr>
</table>

</form>

<%@ include file="editFooter.jsp"%>
