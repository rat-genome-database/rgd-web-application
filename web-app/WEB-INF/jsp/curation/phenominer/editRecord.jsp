<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.dao.spring.HistogramQuery" %>
<%@ page import="edu.mcw.rgd.datamodel.HistogramRecord" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.*" %>

<%
    String pageTitle = "Edit Record";
    String headContent = "";
    String pageDescription = "";

%>

<%@ include file="editHeader.jsp" %>
<script type="text/javascript"  src="/OntoSolr/files/jquery.autocomplete.js"></script>
<script type="text/javascript"  src="/OntoSolr/files/ont_util.js"></script>

<%


    OntologyXDAO ontDao = new OntologyXDAO();
    List<String> idList = req.getParameterValues("id");

    boolean multiEdit = false;
    boolean enabledConditionInsDel = false;
    Integer ordNum = 2;
    boolean isNew = false;
    boolean isCloning = false;

    final DecimalFormat d_f = new DecimalFormat("0.####");

    if (req.getParameter("act").equals("new")) {
        isNew = true;
    }

    if (idList.size() > 1) {
        multiEdit = true;
        List<HistogramRecord> ords = dao.getOrdCounts(idList);
        if (ords.size() == 0) {
            enabledConditionInsDel = true;
            ordNum = 0;
        } else if (ords.size() == 1 && ((HistogramRecord)ords.get(0)).count == idList.size()) {
            enabledConditionInsDel = true;
            ordNum = Integer.parseInt(((HistogramRecord)ords.get(0)).value);
        }
    }

    String title = "Create Record";
    if (!isNew) {
        title = "Edit Record";
    }

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

%>


<script type="text/javascript" src="/rgdweb/js/util.js"></script>

<link rel="stylesheet" href="/rgdweb/js/windowfiles/dhtmlwindow.css" type="text/css"/>
<script type="text/javascript" src="/rgdweb/js/windowfiles/dhtmlwindow.js"></script>
<script type="text/javascript" src="/rgdweb/js/ontologyLookup.js"></script>


<span class="phenominerPageHeader"><%=title%></span>

<div class="phenoNavBar">
    <table>
        <tr>
            <% if (!req.getParameter("expId").equals("")) { %>
            <td><a href='records.html?act=new&expId=<%=req.getParameter("expId")%>'>Create New Record</a></td>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <% } %>
            <td><a href='home.html'>Home</a></td>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href='search.html'>Search</a></td>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href='studies.html'>List All Studies</a></td>
            <% if (!multiEdit || enabledConditionInsDel) { %>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="javascript:addCondition()">Add Condition</a></td>
            <% } %>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="javascript:addUnit()">Add Unit</a></td>
            <% if (req.getParameter("studyId") != null && req.getParameter("studyId").length() > 0) {
            if (req.getParameter("expId") != null && req.getParameterValues("expId").size() == 1) {  %>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="records.html?expId=<%=req.getParameter("expId")%>&studyId=<%=req.getParameter("studyId")%>">All Records</a></td>
            <% } %>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="experiments.html?studyId=<%=req.getParameter("studyId")%>">All Experiments</a></td>
            <%} else {
            if (req.getParameter("expId") != null && req.getParameterValues("expId").size() == 1) { %>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="records.html?expId=<%=req.getParameter("expId")%>">All Records</a></td>
            <% } }%>

        </tr>
    </table>
</div>


<%


    Report report = new Report();

    List<String> unitList = dao.getDistinct("PHENOMINER_ENUMERABLES where type=2", "value", true);

    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties("class='sortable'");

    if (idList.size() > 0) {
        report = (Report) request.getAttribute("report");
        out.print(report.format(strat));

    }
    Record rec = new Record();
    if (multiEdit) {
        rec.setCurationStatus(0);
        rec.getSample().setNumberOfAnimals(0);
    }
    String requiredFieldIndicator = "*";
    if (multiEdit) requiredFieldIndicator = "";

    if (!multiEdit && idList.size() == 1) {
        rec = dao.getRecord(Integer.parseInt(idList.get(0)));
        if (isNew) {
            isCloning = true;
            rec.setCurationStatus(10);
        }
    }
%>
<br>

<form action="records.html" method="get">

<input type="hidden" name="act" value="save"/>
<input type="hidden" name="studyId" value="<%=req.getParameter("studyId")%>"/>


<%

    if (!isNew) {
        for (String id : idList) { %>
<input type="hidden" name="id" value="<%=id%>"/>

<%
        }
    }
%>


<%

    String cmTerm = "";

    try {
        if (rec.getClinicalMeasurement().getAccId() != null) {
            cmTerm = ontDao.getTermByAccId(rec.getClinicalMeasurement().getAccId()).getTerm();
        }
    } catch (Exception e) {
        cmTerm = "ERROR: TERM NOT FOUND!!!!!";
        e.printStackTrace();
    }
%>

<%
    String sTerm = "";
    try {
        if (rec.getSample().getStrainAccId() != null) {
            sTerm = ontDao.getTermByAccId(rec.getSample().getStrainAccId()).getTerm();
        }
    } catch (Exception e) {
        sTerm = "ERROR: TERM NOT FOUND!!!!!";
        e.printStackTrace();
    }


%>
<br>
<script>
function editField(fieldID) {
    $(fieldID).attr('readonly', false);
    $(fieldID).css('background-color', 'white');
    $(fieldID).focus();
}

function lockField(fieldID) {
    $(fieldID).attr('readonly', true);
    $(fieldID).css('background-color', '#dddddd');
}
</script>

<b>Curation Status: </b>
<%=fu.buildSelectList("sStatus", dao.getEnumerableMap(6, 0, multiEdit), dm.out("sStatus", rec.getCurationStatus()))%>
&nbsp&nbsp&nbsp&nbsp<b>Experiment ID: </b>
<input type="text" id="expId" name="expId" value="<%=req.getParameter("expId")%>" style="background-color: #dddddd" readonly="true"/>
<button type="button" onclick="editField('#expId')" class="butEdit"></button>

<br>
<br>

<b>Strain</b> <%=requiredFieldIndicator%>ACC ID: <input type="text" id="sAccId" name="sAccId" size="40"
                             value="<%=dm.out("sAccId", rec.getSample().getStrainAccId())%>"/>

<script>
    var justLoaded = true;
    var lastIndex = 0;
$(document).ready(function(){
    var not4Curation = ' AND NOT Not4Curation';
    $(".butEdit").button({icons: {primary: "ui-icon-unlocked"}, text:false});
    $("#expId").focusout(function() {lockField('#expId')});
    $("#cmSite").focusout(function() {lockField('#cmSite')});
    $("#mmSite").focusout(function() {lockField('#mmSite')});

  $("#sAccId").autocomplete('/OntoSolr/select', {
              extraParams:{
              'qf': 'term_en^1 term_en_sp^3 term_str^2 term^1 synonym_en^1 synonym_en_sp^3  synonym_str^2 synonym^1 def^1 anc^20 idl_s^2',
              'bf': 'term_len_l^8',
              'fq': 'cat:RS AND synonym:(+RGD +ID)'+not4Curation,
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

    $("#cmAccId").autocomplete('/OntoSolr/select', {
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

    $("#mmAccId").autocomplete('/OntoSolr/select', {
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

<% for (int i = 0; i < 15; i++) { %>


    $("#cAccId<%=i%>").autocomplete('/OntoSolr/select', {
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
  $("#cAccId<%=i%>").result(function(data, value){
     $("#cAccId<%=i%>").val(value[1]);
      $("#cTerm<%=i%>").html(value[0]);
     });

<%};%>

    $("#mmSiteAccID").autocomplete('/OntoSolr/select', {
              extraParams:{
                  'qf': 'term_en^5 term_en_sp^2 term_str^3 term^3 synonym_en^4.5 synonym_en_sp^1.5  synonym_str^2 synonym^2 def^1 idl_s^2',
                  'bf': 'term_len_l^2',
                  'fq': 'cat:UBERON'+not4Curation,
                  'wt': 'velocity',
                  'v.template': 'termidsel_cur'
              },
              max: 10000,
              multiple: true,
              multipleSeparator: '|'
            }
    );
    $("#mmSiteAccID").result(function(data, value){
//       $("#mmSite").val($("#mmSite").val()+value[1]);
        var siteStr = $("#mmSiteAccID").val();
        $("#mmSiteAccID").val(siteStr.substring(0, siteStr.lastIndexOf('|')+1) + value[1]);
        getOntTerms($("#mmSiteAccID").val(), "#mmSite");
       });

    $("#mmSiteAccID").keyup(function(event){
       getOntTerms($("#mmSiteAccID").val(), "#mmSite");
        $("#mmSite").css("color", "red");
    });

    $("#cmSiteAccID").autocomplete('/OntoSolr/select', {
              extraParams:{
                  'qf': 'term_en^5 term_en_sp^2 term_str^3 term^3 synonym_en^4.5 synonym_en_sp^1.5  synonym_str^2 synonym^2 def^1 idl_s^2',
                  'bf': 'term_len_l^2',
                  'fq': 'cat:(UBERON CL) '+not4Curation,
                  'wt': 'velocity',
                  'v.template': 'termidsel_cur'
              },
              max: 10000,
              multiple: true,
              multipleSeparator: '|'
            }
    );
    $("#cmSiteAccID").result(function(data, value){
//       $("#mmSite").val($("#mmSite").val()+value[1]);
        var siteStr = $("#cmSiteAccID").val();
        $("#cmSiteAccID").val(siteStr.substring(0, siteStr.lastIndexOf('|')+1) + value[1]);
        getOntTerms($("#cmSiteAccID").val(), "#cmSite");
       });

    $("#cmSiteAccID").keyup(function(event){
       getOntTerms($("#cmSiteAccID").val(), "#cmSite");
        $("#cmSite").css("color", "red");
    });

});


</script>


<a href="javascript:lookup_treeRender('sAccId', 'RS', 'RS:0000457' )"><img src="/rgdweb/common/images/tree.png" border="0"/></a>
<span id="sTerm" class="highlight"><%=sTerm%></span>

<table>
    <tr>
        <td><%=requiredFieldIndicator%>Animal Count</td>
        <td><%=requiredFieldIndicator%>Min Age</td>
        <td><%=requiredFieldIndicator%>Max Age</td>
        <td><%=requiredFieldIndicator%>Sex</td>
    </tr>
    <tr>
        <td><input type="text" size="11" name="sAnimalCount"
                   value="<%=dm.outForce("sAnimalCount", (rec.getSample().getNumberOfAnimals() == 0 ? null : rec.getSample().getNumberOfAnimals()), multiEdit || (isNew && !isCloning) ?
                   "" : "N/A")%>"/></td>
        <td><input type="text" size="7" name="sMinAge"
                   value="<%=dm.outForce("sMinAge", rec.getSample().getAgeDaysFromLowBound(), multiEdit || (isNew && !isCloning) ?
                   "" : "N/A")%>"/></td>
        <td><input type="text" size="7" name="sMaxAge"
                   value="<%=dm.outForce("sMaxAge", rec.getSample().getAgeDaysFromHighBound(), multiEdit || (isNew && !isCloning) ?
                   "" : "N/A")%>"/></td>
        <td><%=fu.buildSelectListNewValue("sSex", dao.getDistinct("PHENOMINER_ENUMERABLES where type=1 ", "value", true), dm.out("sSex", rec.getSample().getSex()))%>
        </td>
    </tr>
</table>

<br>

<b>Clinical Measurement</b> <%=requiredFieldIndicator%>ACC ID: <input type="text" id="cmAccId" name="cmAccId" size="40"
                                           value="<%=dm.out("cmAccId", rec.getClinicalMeasurement().getAccId())%>"/>
<a href="javascript:lookup_treeRender('cmAccId', 'CMO', 'CMO:0000000')"><img src="/rgdweb/common/images/tree.png" border="0"/></a>
<span id="cmTerm" class="highlight"><%=cmTerm%></span>
    <table>
    <tr>
        <td>Value</td>
        <td><%=requiredFieldIndicator%>Unit</td>
        <td>SD</td>
        <td>SEM</td>
        <td>Error</td>
        <td>Average Type</td>
        <td>Formula</td>
    </tr>
    <tr>
        <td><input type="text" name="cmValue" size="7" value="<%=dm.out("cmValue", rec.getMeasurementValue())%>"/></td>
        <td><%=fu.buildSelectListLabelsNewValue("cmUnits", dao.getDistinct("PHENOMINER_ENUMERABLES where type=3 ", "concat(LABEL,concat('|', VALUE))", true), dm.out("cmUnits", rec.getMeasurementUnits()))%>
        </td>
        <td><input type="text" name="cmSD" size="7" value="<%=dm.out("cmSD", rec.getMeasurementSD())%>"/></td>
        <td><input type="text" name="cmSEM" size="7" value="<%=dm.out("cmSEM", rec.getMeasurementSem())%>"/></td>
        <td><input type="text" name="cmError" value="<%=dm.out("cmError", rec.getMeasurementError())%>"/></td>
        <td><%=fu.buildSelectListNewValue("cmAveType", dao.getDistinct("PHENOMINER_ENUMERABLES where type=4 ", "value", true), dm.out("cmAveType", rec.getClinicalMeasurement().getAverageType()))%>
        </td>
        <td><input type="text" name="cmFormula"
                   value="<%=dm.out("cmFormula", rec.getClinicalMeasurement().getFormula())%>"/></td>
    </tr>
</table>
<table>
    <tr>
        <td>Site Acc IDs ("|" separated)</td>
        <td>Site</td>
        <td>Note</td>
    </tr>
    <tr>
        <td><input id="cmSiteAccID" size="40" type="text" name="cmSiteAccID" value="<%=dm.out("cmSiteAccID", rec.getClinicalMeasurement().getSiteOntIds())%>"/></td>
        <td><input id="cmSite" size="40" type="text" name="cmSite" value="<%=dm.out("cmSite", rec.getClinicalMeasurement().getSite())%>" style="background-color: #dddddd" readonly="true"><button type="button" onclick="editField('#cmSite')" class="butEdit"></button>
        <td><input type="text" size="30" name="cmNote"
                   value="<%=dm.out("cmNote", rec.getClinicalMeasurement().getNotes())%>"/></td>
    </tr>
</table>
<br>

<%
    String mmTerm = "";
    Long mmDuration;
    if (rec.getMeasurementMethod().getDuration() != null) {
        try {
            mmDuration = new Long(rec.getMeasurementMethod().getDuration());
        } catch (Exception e) {
            mmDuration = -1111L;
        }
    } else {
        mmDuration = new Long(0);
    }

    try {
        if (rec.getMeasurementMethod().getAccId() != null) {
            mmTerm = ontDao.getTermByAccId(rec.getMeasurementMethod().getAccId()).getTerm();
        }
    } catch (Exception e) {
        mmTerm = "ERROR: TERM NOT FOUND!!!!!";
    }

%>


<b>Measurement Method</b> <%=requiredFieldIndicator%>ACC ID: <input type="text" id="mmAccId" name="mmAccId" size="40"
                                         value="<%=dm.out("mmAccId", rec.getMeasurementMethod().getAccId())%>"/>
<a href="javascript:lookup_treeRender('mmAccId', 'MMO', 'MMO:0000000')"><img src="/rgdweb/common/images/tree.png" border="0"/></a>
<span id="mmTerm" class="highlight"><%=mmTerm%></span>

<table>
    <tr>
        <td>Duration</td>
        <td>Site Acc IDs ("|" separated)</td>
        <td>Site</td>
    </tr>
    <tr>
        <td><input type="text" size="7" name="mmDuration"
                   value="<%=dm.out("mmDuration", (mmDuration == -1111L ? rec.getMeasurementMethod().getDuration() :(mmDuration > 0 ? mmDuration.toString() : "")))%>" onchange="document.getElementsByName('mmDurationUnits')[0].style.color='red'"/><%=fu.buildSelectList("mmDurationUnits", timeUnits, (mmDuration == -1111L || mmDuration > 0) ? "" : Condition.convertDurationBoundToString(mmDuration))%></td>
        <td><input id="mmSiteAccID" size="40" type="text" name="mmSiteAccID" value="<%=dm.out("mmSiteAccID", rec.getMeasurementMethod().getSiteOntIds())%>"/></td>
        <td><input id="mmSite" size="40" type="text" name="mmSite" value="<%=dm.out("mmSite", rec.getMeasurementMethod().getSite())%>" style="background-color: #dddddd" readonly="true"><button type="button" onclick="editField('#mmSite')" class="butEdit"></button>
</td>
    </tr>
    </table>
    <table>
    <tr>
        <td>PI Type</td>
        <td>PI Time</td>
        <td>PI Time Unit</td>
        <td>Notes</td>
    </tr>
    <tr>
        <td><input type="text" name="mmPostInsultType"
                   value="<%=dm.out("mmPostInsultType", rec.getMeasurementMethod().getPiType())%>"/></td>
        <td><input type="text" size="7" name="mmPostInsultTime"
                   value="<%=dm.out("mmPostInsultTime", rec.getMeasurementMethod().getPiTimeValue())%>"/></td>
        <td><%=fu.buildSelectList("mmInsultTimeUnit", dao.getDistinct("PHENOMINER_ENUMERABLES where type=5 ", "value", true), dm.out("mmInsultTimeUnit", rec.getMeasurementMethod().getPiTypeUnit()))%>
        </td>
        <td><input type="text" size="30" name="mmNotes"
                   value="<%=dm.out("mmNotes", rec.getMeasurementMethod().getNotes())%>"/></td>
    </tr>
</table>




<br>

<%

    if (multiEdit) {
        for (int i = 0; i < ordNum; i++) rec.getConditions().add(new Condition());
    }

    if (req.getParameter("act").equals("save") &&
    (idList.size() == 0 || dm.hasErrors()))  {
        List<String> accIdList = req.getParameterValues("cAccId");
        if (accIdList != null && accIdList.size() > 0) {
            List<String> cMinValueList = req.getParameterValues("cValueMin");
            List<String> cMaxValueList = req.getParameterValues("cValueMax");
            List<String> cMinDuraList = req.getParameterValues("cMinDuration");
            List<String> cMaxDuraList = req.getParameterValues("cMaxDuration");
            for (int i = 0; i < accIdList.size(); i++) {
                if (i < rec.getConditions().size()) continue;
                if (!(accIdList.get(i) + cMaxValueList.get(i) + cMinValueList.get(i)
                 + cMinDuraList.get(i) + cMaxDuraList.get(i)).trim().equals("")) {
                      rec.getConditions().add(new Condition());
                }
            }
        }
    } else if (!multiEdit && rec.getConditions().size() == 0) {
            Condition c = new Condition();
            c.setOrdinality(1);
            rec.getConditions().add(c);
    }
%>

<script type="text/javascript">

    var conditions = new Array();
    var cCount=<%=rec.getConditions().size()%>;

    function addCondition() {
        var thisCondition = document.getElementById("condition" + cCount);
        thisCondition.style.display = "block";
        cCount++;
    }
    function addUnit() {
        var unit = document.getElementById("unit");
        unit.style.display = "block";
    }
</script>

<%
    int conditionCount = 0;
    for (Condition cond : rec.getConditions()) {

    String cTerm = "";
    try {
        if (cond.getOntologyId() != null) {
            cTerm = ontDao.getTerm(cond.getOntologyId()).getTerm();
        }
    } catch (Exception e) {
        cTerm = "ERROR: TERM NOT FOUND!!!!!";
    }

%>

<div id="condition<%=conditionCount%>">
    <b>Experimental Condition <%=(conditionCount + 1)%> </b> <%=requiredFieldIndicator%>ACC ID: <input type="text" id="cAccId<%=conditionCount%>" name="cAccId" size="40"
                                                 value="<%=dm.out("cAccId", cond.getOntologyId(),conditionCount)%>"/>
    <a href="javascript:lookup_treeRender('cAccId<%=conditionCount%>', 'XCO', 'XCO:0000000')"><img src="/rgdweb/common/images/tree.png" border="0"/></a>&nbsp;&nbsp;
    <span id="cTerm<%=conditionCount%>" class="highlight"><%=cTerm%></span>
    <% if (!multiEdit || enabledConditionInsDel) {%>
        &nbsp;&nbsp;Delete?<input name="cDelete" value="<%=cond.getId()>0?cond.getId():-conditionCount-1%>" type="checkbox"/>
    <% } %>
    
    <table>
        <tr>
            <td>Min Value</td>
            <td>Max Value</td>
            <td>Unit</td>
            <td>Min Dur</td>
            <td>Max Dur</td>
            <td>Application Method</td>
            <td><%=requiredFieldIndicator%>Ordinality</td>
            <td>Notes</td>
        </tr>
        <tr>
            <%
                try {  if (cond != null) {
            %>
            <input type="hidden" name="cId" value="<%=dm.out("cValue", cond.getId(), conditionCount)%>"/>
            <td><input type="text" size="7" name="cValueMin"
                       value="<%=dm.out("cValueMin", cond.getValueMin(), conditionCount)%>"/></td>
            <td><input type="text" size="7" name="cValueMax"
                       value="<%=dm.out("cValueMax", cond.getValueMax(), conditionCount)%>"/></td>
            <td><%=fu.buildSelectListNewValue("cUnits", unitList, dm.out("cUnits", cond.getUnits(), conditionCount))%>
            </td>
            <td><input type="text" size="12" name="cMinDuration"
                       value="<%=dm.out("cMinDuration", (cond.getDurationLowerBound() > 0 ? d_f.format(cond.getDurationLowerBound()) : ""), conditionCount)%>" onchange="document.getElementsByName('cMinDurationUnits')[<%=(conditionCount)%>].style.color='red'"/><%=fu.buildSelectList("cMinDurationUnits", timeUnits, (cond.getDurationLowerBound() > 0 ? "": Condition.convertDurationBoundToString(cond.getDurationLowerBound())))%></td>
            <td><input type="text" size="12" name="cMaxDuration"
                       value="<%=dm.out("cMaxDuration", (cond.getDurationUpperBound() > 0 ? d_f.format(cond.getDurationUpperBound()) : ""), conditionCount)%>" onchange="document.getElementsByName('cMaxDurationUnits')[<%=(conditionCount)%>].style.color='red'"/><%=fu.buildSelectList("cMaxDurationUnits", timeUnits, (cond.getDurationUpperBound() > 0 ? "": Condition.convertDurationBoundToString(cond.getDurationUpperBound())))%></td>
            <td><input type="text" size="30" name="cApplicationMethod"
                       value="<%=dm.out("cApplicationMethod", cond.getApplicationMethod(), conditionCount)%>"/></td>
            <td><input type="text" size="7" name="cOrdinality"
                       value="<%=dm.out("cOrdinality", cond.getOrdinality(), conditionCount)%>"/></td>
            <td><input type="text" size="30" name="cNotes"
                       value="<%=dm.out("cNotes", cond.getNotes(), conditionCount + 1)%>"/></td>

            <%
                    } } catch (Exception e) {
                    e.printStackTrace();
                }
            %>

        </tr>


    </table>
    <br>
</div>
<% conditionCount++; %>
<% } %>

<% for (int i = conditionCount; i < 15; i++) { %>

<div id="condition<%=i%>" style="display:none;">
    <b>Experimental Condition <%=i+1%></b> *ACC ID: <input type="text" id="cAccId<%=i%>" name="cAccId" value=""/>
        <a href="javascript:lookup_treeRender('cAccId<%=i%>', 'XCO', 'XCO:0000000')"><img src="/rgdweb/common/images/tree.png" border="0"/></a>
    <span id="cTerm<%=i%>" class="highlight"></span>
    <table>
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
            <td><%=fu.buildSelectListNewValue("cUnits", unitList, "")%></td>
            <td><input type="text" size="12" name="cMinDuration" value=""/><%=fu.buildSelectList("cMinDurationUnits", timeUnits, "")%></td>
            <td><input type="text" size="12" name="cMaxDuration" value=""/><%=fu.buildSelectList("cMaxDurationUnits", timeUnits, "")%></td>
            <td><input type="text" size="30" name="cApplicationMethod" value=""/></td>
            <td><input type="text" size="7" name="cOrdinality" value=""/></td>
            <td><input type="text" size="30" name="cNotes" value=""/></td>
        </tr>
    </table>
    <br>
</div>


<% } %>






<table width="80%">
    <tr>
        <td align="left"><input type="submit" value="Save"/></td>
    </tr>
</table>


</form>
<div id="unit" style="display:none;">
    <form action="records.html" method="get">

        <input type="hidden" name="act" value="addUnit"/>>
        <b>Add Unit</b>
        <select name="species" id="unitValue">
            <option value="2">CMO Unit</option>
            <option value="3">Experiment Unit</option>
        </select>
        <input name="unitValue" placeholder="Unit Value" required>
        <input name="description" placeholder="Description">
        <button type="submit" class="btn">Save</button>
    </form>
</div>

<% if( !multiEdit ) {
    String recId = idList.get(0);
    List<IndividualRecord> indRecs = dao.getIndividualRecords(Integer.parseInt(recId));
    if( !indRecs.isEmpty() ) { %>
        <h3>Individual Records</h3>
        <table border>
            <tr><th>Animal ID</th><th>Value</th></tr>
        <% for( IndividualRecord ir: indRecs ) { %>
            <tr><td><%=ir.getAnimalId()%></td><td><%=ir.getMeasurementValue()%></td></tr>
        <% } %>
        </table>
<% }} %>

<%@ include file="editFooter.jsp" %>