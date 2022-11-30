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
var cCount = 0;<!--cCount made glogal variable for RGD1797-->
<%@ include file="editHeader.jsp" %>

<br>
<!--script type="text/javascript" src="/OntoSolr/files/jquery.autocomplete.js"></script-->
<script type="text/javascript" src="/QueryBuilder/js/jquery.autocomplete.js"></script>

<script type="text/javascript" src="/rgdweb/OntoSolr/ont_util.js"></script>

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
        } else if (ords.size() == 1 && ((HistogramRecord) ords.get(0)).count == idList.size()) {
            enabledConditionInsDel = true;
            ordNum = Integer.parseInt(((HistogramRecord) ords.get(0)).value);
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

<%@ include file="editRecordMenuOptions.jsp"%>



<%
    Report report = new Report();
    List<String> unitList = dao.getDistinct("PHENOMINER_ENUMERABLES where type=2", "value", true);
    HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
    strat.setTableProperties("class='sortable'");
    if (idList.size() > 0) {
        report = (Report) request.getAttribute("report");
        //out.print(report.format(strat));
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
<script>
    function addUnit() {
        var unit = document.getElementById("unit");
        unit.style.display = "block";
        addSD();
    }
    function addSD() {
        var ontId = document.getElementById("accId").value;
        if (ontId != null && ontId != "") {
            $.ajax({
                url: "/rgdws/lookup/standardUnit/" + ontId.replace(":", "%3A"), success: function (result) {
                    document.getElementById("unitSD").value = result;
                }
            });
        }
    }
    function checkUnitConversion() {
        var SD = document.getElementById("unitSD").value;
        var unitValue = document.getElementById("unitValue").value;

        if (SD != null && SD != unitValue && SD != "")
            document.getElementById("termScale").style.display = "block";
    }
    function updateUnits() {
        var unitType = document.getElementById("unitType").value;
        var unitValue = document.getElementById("unitValue").value;
        var existingcmUnits, existingcUnits;

        //check for CMO Unit type or Expt Unit type
        if (unitType == 3) {//CMO unit type
            existingcmUnits = document.getElementsByName("cmUnits")[0].options;
            CheckPresence(existingcmUnits,unitValue);
            var option = document.createElement("option");
            option.text = unitValue;
            option.value = unitValue;
            option.selected = "true";
            document.getElementsByName("cmUnits")[0].add(option, 0);
        }
        else if(unitType == 2){//Expt unit type
            //existingcUnits = document.getElementsByName("cUnits")[0].options;
            //CheckPresence(existingcUnits,unitValue);
            //var option = document.createElement("option");
            //option.text = unitValue;
            //option.value = unitValue;
            //option.selected = "true";
            var selectedAccId = document.getElementById("accId").value;//get XCO id been updated
            for(var i=0;i<cCount;i++){//check all list of conditions for XCO Id been updated
                if( selectedAccId == document.getElementById("cAccId"+i).value ){
                    existingcUnits = document.getElementsByName("cUnits")[0].options;
                    CheckPresence(existingcUnits,unitValue);
                    var option = document.createElement("option");
                    option.text = unitValue;
                    option.value = unitValue;
                    option.selected = "true";
                    document.getElementById("cUnits"+i).add(option, 0);
                }
            }
        }
        var unit = document.getElementById("unit");
        unit.style.display = "none";
    }

    //check for presence of value in existing units options
    function CheckPresence(existing,unitValue){
        for (i = 0; i < existing.length; i++) {
            var val = existing[i].value;
            if (val == unitValue)
                alert("Unit exists in the database - Only conversion will be added");
        }
    }
</script>



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


    <script>
        var justLoaded = true;
        var lastIndex = 0;
        $(document).ready(function () {
            var not4Curation = ' AND NOT Not4Curation';
            $(".butEdit").button({icons: {primary: "ui-icon-unlocked"}, text: false});
            $("#expId").focusout(function () {
                lockField('#expId')
            });
            $("#cmSite").focusout(function () {
                lockField('#cmSite')
            });
            $("#mmSite").focusout(function () {
                lockField('#mmSite')
            });
            $("#sAccId").autocomplete('/OntoSolr/select', {
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
            $("#sAccId").result(function (data, value) {
                $("#sAccId").val(value[1]);
                $("#sTerm").html(value[0]);
            });
            $("#cmAccId").autocomplete('/OntoSolr/select', {
                    extraParams: {
                        'qf': 'term_en^5 term_en_sp^2 term_str^3 term^3 synonym_en^4.5 synonym_en_sp^1.5  synonym_str^2 synonym^2 def^1 idl_s^2',
                        'bf': 'term_len_l^2',
                        'fq': 'cat:CMO' + not4Curation,
                        'wt': 'velocity',
                        'v.template': 'curtermselect'
                    },
                    max: 10000
                }
            );
            $("#cmAccId").result(function (data, value) {
                $("#cmAccId").val(value[1]);
                $("#cmTerm").html(value[0]);
            });
            $("#mmAccId").autocomplete('/OntoSolr/select', {
                    extraParams: {
                        'qf': 'term_en^5 term_en_sp^2 term_str^3 term^3 synonym_en^4.5 synonym_en_sp^1.5  synonym_str^2 synonym^2 def^1 idl_s^2',
                        'bf': 'term_len_l^2',
                        'fq': 'cat:MMO' + not4Curation,
                        'wt': 'velocity',
                        'v.template': 'curtermselect'
                    },
                    max: 10000
                }
            );
            $("#mmAccId").result(function (data, value) {
                $("#mmAccId").val(value[1]);
                $("#mmTerm").html(value[0]);
            });
            <% for (int i = 0; i < 15; i++) { %>
            $("#cAccId<%=i%>").autocomplete('/OntoSolr/select', {
                    extraParams: {
                        'qf': 'term_en^5 term_en_sp^2 term_str^3 term^3 synonym_en^4.5 synonym_en_sp^1.5  synonym_str^2 synonym^2 def^1 idl_s^2',
                        'bf': 'term_len_l^2',
                        'fq': 'cat:XCO' + not4Curation,
                        'wt': 'velocity',
                        'v.template': 'curtermselect'
                    },
                    max: 10000
                }
            );
            $("#cAccId<%=i%>").result(function (data, value) {
                $("#cAccId<%=i%>").val(value[1]);
                $("#cTerm<%=i%>").html(value[0]);
            });
            <%};%>
            $("#mmSiteAccID").autocomplete('/OntoSolr/select', {
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
            $("#mmSiteAccID").result(function (data, value) {
//       $("#mmSite").val($("#mmSite").val()+value[1]);
                var siteStr = $("#mmSiteAccID").val();
                $("#mmSiteAccID").val(siteStr.substring(0, siteStr.lastIndexOf('|') + 1) + value[1]);
                getOntTerms($("#mmSiteAccID").val(), "#mmSite");
            });
            $("#mmSiteAccID").keyup(function (event) {
                getOntTerms($("#mmSiteAccID").val(), "#mmSite");
                $("#mmSite").css("color", "red");
            });
            $("#cmSiteAccID").autocomplete('/OntoSolr/select', {
                    extraParams: {
                        'qf': 'term_en^5 term_en_sp^2 term_str^3 term^3 synonym_en^4.5 synonym_en_sp^1.5  synonym_str^2 synonym^2 def^1 idl_s^2',
                        'bf': 'term_len_l^2',
                        'fq': 'cat:(UBERON CL) ' + not4Curation,
                        'wt': 'velocity',
                        'v.template': 'termidsel_cur'
                    },
                    max: 10000,
                    multiple: true,
                    multipleSeparator: '|'
                }
            );
            $("#cmSiteAccID").result(function (data, value) {
//       $("#mmSite").val($("#mmSite").val()+value[1]);
                var siteStr = $("#cmSiteAccID").val();
                $("#cmSiteAccID").val(siteStr.substring(0, siteStr.lastIndexOf('|') + 1) + value[1]);
                getOntTerms($("#cmSiteAccID").val(), "#cmSite");
            });
            $("#cmSiteAccID").keyup(function (event) {
                getOntTerms($("#cmSiteAccID").val(), "#cmSite");
                $("#cmSite").css("color", "red");
            });
        });
    </script>

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

    <%
        if (multiEdit) {
            for (int i = 0; i < ordNum; i++) rec.getConditions().add(new Condition());
        }
        if (req.getParameter("act").equals("save") &&
                (idList.size() == 0 || dm.hasErrors())) {
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
        cCount =<%=rec.getConditions().size()%>;
        function addCondition() {
            var thisCondition = document.getElementById("condition" + cCount);
            thisCondition.style.display = "block";
            cCount++;
        }
    </script>

    <%
        int conditionCount = 0;
        System.out.println("im here" + rec.getConditions());
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

    <style>
        .phenominerTableHeader {
            font-weight:700;
            background-color:#25C780;
            padding-left:5px;
            padding-right:5px;
            margin: 0;
            border-left: 1px solid grey;
            white-space: nowrap;
            border-top-width: 0px;
            color:black;
            height:50px;

            position: sticky;
            top: 0;
        }
        .phenominerTableCell2 {
            padding-left:10px;
            padding-right:10px;
            margin: 0;
            border: 1px solid grey;
            white-space: nowrap;
            border-top-width: 0px;
        }
        .curationTable {
            border-collapse: separate;
            border-spacing: 0;
            border-top: 1px solid grey;
        }


        .scrollableCurationTable {
            width: 1500%;
            overflow-x: scroll;
            margin-left: 5em;
            overflow-y: visible;
            padding: 0;
        }

         .maintable {
             border-collapse: separate;
             border-spacing: 0;
             border-top: 1px solid grey;
             border-color:#e2e3e3;
         }

        .phenominerTableCell {
            margin: 0px;
            border: 1px solid #e2e3e3;
            white-space: nowrap;
            border-top-width: 0px;
            padding-left:5px;
            padding-right:5px;
        }

        .mainDiv {
            idth: 1200px;
            overflow-x: scroll;
            margin-left: 107px;
            verflow-y: scroll;
            eight:500px;
            padding: 0;
        }

        .headcol {
            position: absolute;
            width: 5em;
            left: 15;
            top: auto;
            border: 0px solid black;
            /*only relevant for first row*/
            margin-top: -1px;
            /*compensate for top border*/
        }

        .headrow {
            position: absolute;
            width: 5em;
            left: 15;
            top: auto;
            border: 0px solid black;
            /*only relevant for first row*/
            margin-top: -1px;
            /*compensate for top border*/
        }


        .headcol:before {
            ontent: 'Row ';
        }

        .long {
            background: yellow;
            letter-spacing: 1em;
        }

        input {
            border:0px solid black;
            height:40px;
        }
        select{
            border:0px solid black;
            height:30px;

        }
    </style>

    <script>

        // Enable navigation prompt
        window.onbeforeunload = function() {
            return true;
        };

        function changed(obj,recordId) {
            obj.style.backgroundColor="#F6F1A3";
            document.getElementById("save*" + recordId).style.backgroundColor="#F6F1A3";
        }

        function deleteRecord() {


      }

      function getRecordId(inputName) {
            return inputName.substring(inputName.indexOf("*")+1);
      }

      function saveAll() {

          var elements = document.getElementById("editRecordForm").elements;

          for (i = 0; i < elements.length; i++) {

              if (elements[i].type === "button") {


                  if (elements[i].id.startsWith("save")) {
                      //alert(elements[i].style.backgroundColor);
                      if (elements[i].style.backgroundColor==="rgb(246, 241, 163)") {
                          saveRecord(getRecordId(elements[i].id));
                      }
                  }

              }

          }
      }

      function saveRecord(recordId) {
          const formData = new FormData(document.getElementById("editRecordForm"));

          var params = new URLSearchParams(formData);

          var paramArray = params.toString().split("&");

          var paramString="studyId=<%=req.getParameter("studyId")%>&act=saveSS";

          for (var i=0; i< paramArray.length; i++) {
              var str = paramArray[i];
              console.log(str);
              console.log(str.indexOf("*"));
              var starIndex=str.indexOf("*");
              var eqIndex = str.indexOf("=");

              var val=str.substring(starIndex + 1,eqIndex);

              var name =str.substring(0,starIndex);
              var value=str.substring(starIndex + val.length + 2);

              console.log("name = " + name + " , value =" + value);

              console.log(recordId);
              if (val==recordId) {
                  paramString =  paramString + "&" + name + "=" + value;
              }


          }

          axios
              .get("http://localhost:8080/rgdweb/curation/phenominer/records.html?" + paramString)
              .then(function (response) {
                  //alert(response.data);

                  if (response.data.startsWith("Update")) {
                      document.getElementById("save*"+recordId).style.backgroundColor="#25C780";

                      var elements=document.getElementById("editRecordForm").elements;

                      alert(recordId);
                      for (i=0; i<elements.length; i++){

                          if (elements[i].name.indexOf(recordId) > -1) {
                              if (elements[i].type === "button") {
                                  //elements[i].style.backgroundColor = "#25C780";
                              } else {
                                  elements[i].style.backgroundColor = "white";
                              }
                          }
                      }
                  }else  {
                      alert(response.data);
                  }

              }).catch(function (error) {
                alert(error);
          });

      }




      function cloneRecord(frm,recordId) {

            var numRecs = prompt("how many records would you like to create");

            for (var i=0;i<numRecs;i++) {

                var mainTable = document.getElementById("mainTable");
                var recTr = document.getElementById("tr_" + recordId);
                var row = mainTable.insertRow(1);

                var epoch = Date.now() + "";
                var tempId = "_" + epoch.substr(8);
                row.id = "tr_" + tempId;

                var htm = recTr.innerHTML.replaceAll(recordId, tempId);
                row.innerHTML = htm;

                document.getElementById("save*" + tempId).style.backgroundColor = "#F6F1A3";
            }
            }

      function addNew() {

      }

      //Enable tab to go vertically
        document.addEventListener('keydown', function(event)
        {
            var code = event.keyCode || event.which;
            if (code === 9) {
                event.preventDefault();
                var inputName = event.target.name;
                var inputs = document.getElementsByName(inputName);

                var hasFocus=false;
                for (var i=0;i<inputs.length; i++) {
                    if (hasFocus) {
                        inputs[i].focus();
                        inputs[i].select();
                        break;
                    }
                    if (document.activeElement==inputs[i]) {
                        hasFocus=true;
                    }
                }
            }
        });

        function toggleColumn(obj,index) {
            if (obj.checked) {
                if (document.getElementById("mainTable").classList.contains("hide" + index)) {
                    document.getElementById("mainTable").classList.remove("hide" + index);
                    window.localStorage.setItem("toggle" + index,true);

                }
            }else {
                    document.getElementById("mainTable").classList.add("hide" + index);
                    window.localStorage.setItem("toggle" + index,false);
            }

        }

        function toggleOptions() {
            if (document.getElementById("options").style.display === "none") {
                document.getElementById("options").style.display = "block";
            }else {
                document.getElementById("options").style.display = "none";
            }

        }
        function selectAllToggleOptions() {
            for(i=0; i<50; i++) {
                var toggle = "toggle" +i;
                if (document.getElementById(toggle)) {
                    document.getElementById(toggle).checked = true;
                    toggleColumn(document.getElementById(toggle),i);
                }
            }
        }
        function removeAllToggleOptions() {
            for(i=0; i<50; i++) {
                var toggle = "toggle" +i;
                if (document.getElementById(toggle)) {
                    document.getElementById(toggle).checked = false;
                    toggleColumn(document.getElementById(toggle),i);
                }
            }
        }

    </script>

<style>
    <% for(int i=0; i<50; i++) { %>
    .hide<%=i%> tr td:nth-child(<%=i%>) {
        display:none;
    }
    <% } %>
    <% for(int i=0; i<50; i++) { %>
    .show<%=i%> tr td:nth-child(<%=i%>) {
        display:block;
    }
    <% } %>

    <style>
     table { border-collapse: collapse; }
    tr:nth-child(3) { border: solid thin; }
</style>
</style>


<%
    ArrayList<String> columns = new ArrayList<String>();
    columns.add("EID");
    columns.add("RID");
    columns.add("Curation Status");
    columns.add("Clinical Measurement");
    columns.add("Site");
    columns.add("Site Acc IDs");
    columns.add("Value");
    columns.add("Unit");
    columns.add("SD");
    columns.add("SEM");
    columns.add("Error");
    columns.add("Average Type");
    columns.add("Formula");
    columns.add("Note");
    columns.add("Measurement Method");
    columns.add("Duration");
    columns.add("Site");
    columns.add("Site Acc IDs");
    columns.add("PI Type");
    columns.add("PI Time");
    columns.add("PI Time Unit");
    columns.add("Notes");
    columns.add("Strain");
    columns.add("Animal Count");
    columns.add("Min Age");
    columns.add("Max Age");
    columns.add("Sex");
    columns.add("BioSample ID");
    columns.add("Experimental Condition 1");
    columns.add("Min Value");
    columns.add("Max Value");
    columns.add("Unit");
    columns.add("Min Dur");
    columns.add("Max Dur");
    columns.add("Application Method");
    columns.add("Ordinality");
    columns.add("Notes");

%>



<div id="options" style="display:none;padding:10px;">
<table >
<tr>
    <td colspan="2"><a href="javascript:selectAllToggleOptions()">Select All</a></td>
    <td colspan="2"><a href="javascript:removeAllToggleOptions()">Remove All</a></td>
</tr>
    <tr>

<%
    int count=3;
    for(String column: columns) {
%>
        <td class="phenominerTableHeader" valign="center" align="center">
            <%=column%><br><input id="toggle<%=count%>" type="checkbox" onClick="toggleColumn(this,<%=count%>)" checked/>
        </td>
        <%
        count++;
    } %>
    </tr>
</table>
</div>




    <div class="mainDiv">

        <form name= "editRecordForm" action="records.html" id="editRecordForm">
            <input type="hidden" name="act" value="save"/>
            <input type="hidden" name="studyId" value="<%=req.getParameter("studyId")%>"/>

        <table  class="mainTable" cellpadding="0" cellspacing="0" id="mainTable">
    <%@ include file="editHeaderRow.jsp"%>

    <%
        List<Record> records= dao.getRecords(Integer.parseInt(req.getParameter("expId")));

    for(Record rec1: records) {
        String rid="*" + rec1.getId();
        rec=rec1;
    %>

        <%@ include file="editRecordRow.jsp"%>


<% }

}
%>

</table>
        </form>
</div>
<!--</form>-->


<script>
    for(i=0; i<50; i++) {
        var toggle = "toggle" +i;
        if (window.localStorage.getItem(toggle) == "false") {
            document.getElementById(toggle).checked = false;
            toggleColumn(document.getElementById(toggle),i);
        }
    }

</script>



<%@ include file="editFooter.jsp" %>