<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%
    String pageTitle = "Rat Genome Database Pathway";
    String headContent = "Rat Genome Database Pathway";
    String pageDescription = "Rat Genome Database Pathway";
    List<String> pwList = new ArrayList<String>();

    Map<String, String> pwMap = (Map)request.getAttribute("pwMap");

%>
<%@ include file="/common/headerarea.jsp"%>
<%
    HttpRequestFacade req= new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req, error);
%>

<script type="text/javascript">

function validateForm(formVal){
    var result = "";
    var error = "";
    var formValue = document.getElementById(formVal);
    if(formValue.value.length==10){
        //alert(formValue.value+" length is 10");
        if(!(formValue.value.search("^[PW]")>-1)){
            error = "your ID needs to begin with a PW in Uppercase";
        }
        if(!(formValue.value.search("[\\:\\d+]"))){
            error = "you need to specify your ID in form PW:XXXXXXX where X= any number between 0 and 9]";
        }
        result += error;
    }
    else{
        //alert("length is" + formValue.value.length);
        error = "your pathway ID needs to be 10 characters long!";
        result += error;
    }

    if(result.length>1){
        alert("Some fields need correction:\n" + result);
        return false;
    }else{
        return true;
    }
}
</script>

<!-- adding function for autocompletion of term searches.-->


<script type="text/javascript" src="/QueryBuilder/js/jquery.autocomplete.js"></script>

<script>
$(document).ready(function(){
  $("#acc_id1").autocomplete('/solr/OntoSolr/select', {
        extraParams:{
          'qf': 'term^2 synonym^1 id^1',
          'fq': 'cat:PW',
          'wt': 'velocity',
          'v.template': 'termselect'
        },
        max: 10000
  }
  );

  $('#acc_id1').result(function(event, results){
    $('#acc_id1').val(results[1]);
  });

});

$(document).ready(function(){
  $("#acc_id2").autocomplete('/solr/OntoSolr/select', {
        extraParams:{
          'qf': 'term^2 synonym^1 id^1',
          'fq': 'cat:PW',
          'wt': 'velocity',
          'v.template': 'termselect'
        },
        max: 10000
  }
  );

  $('#acc_id2').result(function(event, results){
    $('#acc_id2').val(results[1]);
  });

});


</script>


<form id="pathwayCreate" action="pathwayCreate.html" method="GET"
        onsubmit="return validateForm('acc_id1')">
<table>
    <tr>
        <h4>
        Hello!
        Find your Pathway record.
        </h4>
        Enter a Pathway Ontology ID.
    <br />
        If the Pathway Record Exists, you will be able to <b>view its report</b>.
        If it doesn't, yet, you will be able to <b>create a new pathway record</b>.
    </tr>
    <tr>
        <td align="left"><input type="text" id="acc_id1" name="acc_id" size="70" value="<%=dm.out("acc_id", "")%>"></td>
        <td align="center"><input type="submit"  value="Edit Existing Pathway or Create New Pathway Object" > </td>
    </tr>
</table>
</form>

<form id="pathwayRecord" action="/rgdweb/pathway/pathwayRecord.html" method="GET"
        onsubmit="return validateForm('acc_id2')">
<table>
    <tr>
        <td align="left"><input type="text" id="acc_id2" name="acc_id" size="70" style="text-transform: uppercase"></td>
        <input name="processType" type="hidden" id="processType" value="view" />
        <input name="species" type="hidden" id="species" value="Rat"/>
        <td align="center"><input type="submit"  value="View Report of Existing Pathway"></td>
    </tr>
</table>
</form>

<form action="">
    <table>
    <tr>
        <td>
            <br /><h3>Select Pathway from List</h3>
                <%
                    for(Map.Entry<String,String> entry: pwMap.entrySet()){
                       %>
                    <br /><a href="/rgdweb/pathway/pathwayRecord.html?processType=view&species=Rat&acc_id=<%=entry.getValue()%>">
                        <%=entry.getKey()+"  ("+entry.getValue()+")"%>
                    </a>
                <%
                    }
                %>
        </td>
    </tr>
    </table>
</form>


<%@ include file="/common/footerarea.jsp"%>
