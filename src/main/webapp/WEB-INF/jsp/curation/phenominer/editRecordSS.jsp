<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.dao.spring.HistogramQuery" %>
<%@ page import="edu.mcw.rgd.datamodel.HistogramRecord" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.*" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Record" %>

<%
    String pageTitle = "Edit Record";
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="editHeader.jsp" %>

<br>

<script type="text/javascript" src="/rgdweb/js/ontPopUp/ontPopupBrowser.js"></script>
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

<%@ include file="spreadSheetMenuOptions.jsp"%>



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

    //check for presence of value in existing units optionsƒ
    function CheckPresence(existing,unitValue){
        for (i = 0; i < existing.length; i++) {
            var val = existing[i].value;
            if (val == unitValue)
                alert("Unit exists in the database - Only conversion will be added");
        }
    }

    function postMessage(inputBox,acc,term) {
        changed(inputBox);
    }

</script>



    <%

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
            margin-left: 169px;
            verflow-y: scroll;
            eight:500px;
            padding: 0;
        }

        .headcol {
            position: absolute;
            width: 5em;
            left: 25;
            top: auto;
            border: 0px solid black;
            /*only relevant for first row*/
            margin-top: -1px;
            /*compensate for top border*/
        }

        .headrow {
            position: absolute;
            width: 5em;
            left: 25;
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
            height:50px;
        }
        select{
            border:0px solid black;
            height:30px;

        }
    </style>

    <script>

        changeLog=[];

        function unlock(obj) {
            if (obj.readOnly) {
                if (!confirm("This field is locked and is not usually changed.  Would you like to edit the field?")) {
                    obj.blur();
                    return;
                }
            }

            //var obj = document.getElementById(fieldId);
            obj.readOnly=false;
            obj.focus();

        }


        // Enable navigation prompt
        window.onbeforeunload = function() {
            return true;
        };

        function revert(recordId) {
            if (document.getElementById("revert*" + recordId).style.opacity != 1) {
                return;
            }

            if (document.getElementById("revert*" + recordId).value=="Delete") {
                document.getElementById("tr_" + recordId).remove();
                return;
            }

            if (changeLog[recordId]) {
                document.getElementById("tr_" + recordId).innerHTML = changeLog[recordId];
                disableSave(recordId);
            }
        }

        function changed(obj) {
            var recordId=parseId(obj.name,"*");

            if (!changeLog[recordId]) {
                changeLog[recordId] = document.getElementById("tr_" + recordId).innerHTML;
            }

            obj.style.backgroundColor="#e9c893";
            enableSave(recordId);
        }

      function parseId(str, delimiter) {
            return str.substring(str.indexOf(delimiter)+1);
      }

      function parseRoot(inputName) {
          return inputName.substring(0,inputName.indexOf("*"));
      }

      function saveAll() {

          if (!confirm("This will save all changes. Select OK to continue.")) {

              return;
          }

          var elements = document.getElementById("editRecordForm").elements;
          var found=false;
          for (i = 0; i < elements.length; i++) {

              if (elements[i].type === "button") {


                  if (elements[i].id.startsWith("save")) {
                      if (elements[i].style.opacity==1) {
                          saveRecord(parseId(elements[i].id,"*"));
                          found=true;
                      }
                  }

              }

          }
          if (!found) {
              alert("Modifications to the page haven't been found.  Save failed.")
          }
      }

      function saveRecord(recordId) {
          if (document.getElementById("save*" + recordId).style.opacity != 1) {
              return;
          }

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

          var host = window.location.protocol + window.location.host;

          if (window.location.host.indexOf('localhost') > -1) {
              host =  'https://dev.rgd.mcw.edu';
          } else if (window.location.host.indexOf('dev.rgd') > -1) {
              host = window.location.protocol + '//dev.rgd.mcw.edu';
          }else if (window.location.host.indexOf('test.rgd') > -1) {
              host = window.location.protocol + '//test.rgd.mcw.edu';
          }else if (window.location.host.indexOf('pipelines.rgd') > -1) {
              host = window.location.protocol + '//pipelines.rgd.mcw.edu';
          }else {
              host = window.location.protocol + '//rest.rgd.mcw.edu';
          }

          axios
              //.get("http://localhost:8080/rgdweb/curation/phenominer/records.html?" + paramString)
              .get(host + "/rgdweb/curation/phenominer/records.html?" + paramString)
              .then(function (response) {
                  //alert(response.data);

                  if (response.data.startsWith("Update")) {
                      disableSave(recordId);

                      document.getElementById("save*" + recordId).value="Save";
                      document.getElementById("revert*" + recordId).value="Revert";

                      var elements=document.getElementById("editRecordForm").elements;
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

      //if offerDelete is true a delete option will be rendered on screen
      function enableSave(recordId, offerDelete) {
          document.getElementById("save*" + recordId).style.opacity=1;
        //  document.getElementById("tr_" + recordId).style.out

          document.getElementById("tr_" + recordId).style.outlineStyle="solid";
          document.getElementById("tr_" + recordId).style.outlineColor="#E9C893";
          document.getElementById("tr_" + recordId).style.outlineWidth="3px";

          document.getElementById("revert*" + recordId).style.opacity=1;

          if (offerDelete) {
              document.getElementById("revert*" + recordId).value="Delete";
          }else {
              document.getElementById("revert*" + recordId).value="Revert";
          }
      }
      function disableSave(recordId) {
          document.getElementById("save*" + recordId).style.opacity=.3;
          document.getElementById("tr_" + recordId).style.outlineStyle="solid";
          document.getElementById("tr_" + recordId).style.outlineColor="black";
          document.getElementById("tr_" + recordId).style.outlineWidth="1px";

          document.getElementById("revert*" + recordId).style.opacity=.3;

      }

      function getSiblingIdList(inputObj) {
          var inputName = inputObj.name;

          var table = document.getElementById("mainTable");
          var currentRowId = "tr_" + id;

          var idList = [];
          var root = parseRoot(inputName);

          for (var i=0; i<table.rows.length;i++) {
              if (table.rows[i].id.indexOf("tr_") > -1) {
                  var id = parseId(table.rows[i].id, "_");
                  idList[idList.length] = root + "*" + id;
              }
          }
          return idList;
      }

      function newRecord() {
            cloneRecord();
      }

      var lastRecordId = "";

      function cloneRecord(recordId) {
            if (!recordId) {
                recordId=999999999;
            }

            var numRecs = prompt("how many records would you like to create");

            for (var i=0;i<numRecs;i++) {

                var mainTable = document.getElementById("mainTable");
                var recTr = document.getElementById("tr_" + recordId);
                var row = mainTable.insertRow(1);

                var epoch = Date.now() + "";
                var tempId = "_" + epoch.substr(8);

                row.id = "tr_" + tempId;
                //lastRecordId=row.id;
                //console.log(recTr.innerHTML);
                //console.log("*****************");

                var htm = recTr.innerHTML.replaceAll(recordId, tempId);
                //console.log(htm);
                //console.log("*****************");
                row.innerHTML = htm;

                enableSave(tempId,true);
            }
      }

      //Enable tab to go vertically
        document.addEventListener('keydown', function(event)
        {
            var code = event.keyCode || event.which;
            if (code === 9) {
                event.preventDefault();
                var inputName = event.target.name;
                var list = getSiblingIdList(event.target);

                for (var i=0; i< list.length;i++) {
                    if (list[i] == inputName) {
                        if (list.length==i+1) {
                            document.getElementsByName(list[0])[0].focus();
                            document.getElementsByName(list[0])[0].select();
                        } else {
                            document.getElementsByName(list[i+1])[0].focus();
                            document.getElementsByName(list[i+1])[0].select();
                        }
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

        var activeColumn="";
        function showUploadWindow(event, column) {
            var offset = -800;
            if (event.clientX < 800) {
                offset = 200;
            }
            activeColumn=column;
            document.getElementById('uploadWindow').style.display='block'
            document.getElementById('uploadWindow').style.top=150;
            document.getElementById('uploadWindow').style.left=event.pageX + offset;
        }
        function uploadList() {

            var elements = document.getElementById("editRecordForm").elements;
            var found=false;

            var inputs = document.getElementById('uploadValue').value.replace(/\r\n/g,"\n").split("\n");

            var count=0;
            for (i = 0; i < elements.length; i++) {
                if (elements[i].name.indexOf(activeColumn) != -1) {
                    //alert(inputs.length + " " + count);
                    if (inputs.length > count) {
                        if (inputs[count].trim() != "") {
                            elements[i].value = inputs[count];
                            changed(elements[i]);
                            count++;
                        }
                    }
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

    int conditionCount=1;
    for (Condition condition: rec.getConditions()) {
        columns.add("Experimental Condition " + conditionCount);
        columns.add("Min Value");
        columns.add("Max Value");
        columns.add("Unit");
        columns.add("Min Dur");
        columns.add("Max Dur");
        columns.add("Application Method");
        columns.add("Ordinality");
        columns.add("Notes");
        conditionCount++;
    }
%>

<div id="options" style="color:white;display:none;padding:10px; margin-bottom:5px; border:2px solid black;background-color:#1E392A;">
<table >
<tr>
    <td colspan="6"><a style="color:white;" href="javascript:selectAllToggleOptions()">Select All</a>&nbsp;&nbsp;&nbsp;
    <a  style="color:white;" href="javascript:removeAllToggleOptions()">Remove All</a>&nbsp;&nbsp;&nbsp;
    <a  style="color:white;" href="javascript:toggleOptions()">Hide Options</a></td>
</tr>
    <tr>
        <td>&nbsp;</td>
    </tr>
    <tr>

<%
    int count=3;
    for(String column: columns) {
%>
        <td style="background-color:#E1E3E3;" class="phenominerTableHeader" valign="center" align="center">
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

        <table  style="border-collapse: separate;border-spacing: 0;border-top: 1px solid grey;border-color:#e2e3e3;" lass="table-sort" cellpadding="0" cellspacing="0" id="mainTable">
    <%@ include file="editHeaderRow.jsp"%>

    <%
        List<Record> records= dao.getRecords(Integer.parseInt(req.getParameter("expId")));

    for(Record rec1: records) {
        String rid="*" + rec1.getId();
        rec=rec1;

%>

        <%@ include file="editRecordRow.jsp"%>


<% }
    String rid="*" + "999999999";
    rec = new Record();
    rec.setCurationStatus(1);
    rec.setExperimentId(Integer.parseInt(req.getParameter("expId")));
    rec.setMeasurementError("");
    rec.setMeasurementSD("");
    rec.setMeasurementUnits("");
    rec.setMeasurementValue("");
    rec.setId(999999999);
%>

            <%@ include file="editRecordRow.jsp"%>

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


<div id="uploadWindow" style="position:absolute; display:none;z-index:1000; background-color:#1E392A; padding:10px;">

    <table >
        <tr>
            <td style="color:white;" valign="top">
                <div style="margin-top:28px;">
                <%for (int i=0; i< 20; i++) { %>
                    <div style="height:18px;"><%=i+1%></div>
                <%   }%>
                </div>
            </td>
            <td valign="top">
                <table>
                    <tr>
                        <td colspan="2" style="font-size:18px;color:white;">
                            &nbsp;Upload&nbsp;List
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <textarea style="font-size:16px;" id="uploadValue" name="uploadValue" rows="20" cols="80"></textarea><br>

                        </td>
                    </tr>
                    <tr>
                        <td>
                            <input style="margin:10px;height:30px;" type="button" value="Cancel" onClick="document.getElementById('uploadWindow').style.display='none'"/>
                        </td>
                        <td align="right">
                            <input type="button" value="Upload List" onClick="uploadList()" style="margin:10px;height:30px;"/>
                        </td>
                    </tr>
                </table>

            </td>
        </tr>
    </table>

</div>



<%@ include file="editFooter.jsp" %>