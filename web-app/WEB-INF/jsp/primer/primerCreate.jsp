<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>

<%
    String pageTitle = "Rat Genome Database Primer";
    String headContent = "";
    String pageDescription = "Rat Genome Database Primer";

    Map<String, String> spMap = (Map)request.getAttribute("spMap");

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
    if(formValue.value.length>0){
        //alert(formValue.value);
        result += error;
    }
    else{
        //alert("length is" + formValue.value.length);
        error = "Application needs a gene of interest";
        result += error;
    }

    if(result.length>1){
        alert("Some fields need correction:\n" + result);
        return false;
    }else{
        return true;
    }
}



function updateSelectTarget () {
   var id = this.options[this.selectedIndex].value;
   var targets = this.parentNode.getElementsByTagName("select");
   var len = targets.length;
   for (var i = len - 1; i > 0; --i) {
      if (targets[i].id == id) {
         targets[i].style.display = "block";
      }
      else {
         targets[i].style.display = "none";
      }
   }
}


</script>


<form id="primerCreate" action="primerCreate.html" method="GET"
        onsubmit="return validateForm('gene_ens_id1')">

<table>
    <tr>
        <h4>
        Hello!
        Welcome to the PrimerCreate Program.
        </h4>
        Enter your gene of interest and the position of the variant.
    <br />
    </tr>

    <fieldset>
        <legend>Select Species</legend>
        <select id="Species" name="Species" class="source" onchange="updateSelectTarget()">
            <option value="">------- Select -------</option>
            <option value="Human">Human</option>
            <option value="Mouse">Mouse</option>
            <option value="Rat">Rat</option>
        </select>
        <select id="Human" name="Human">
          <option value="13">Assembly v36</option>
          <option value="17">Assembly v37</option>
        </select>
        <select id="Mouse" name="Mouse" class="hidden">
          <option value="18">Assembly v37</option>
          <option value="35">Assembly v38</option>
        </select>
        <select id="Rat" name="Rat" class="hidden">
          <option value="60">Assembly v3.4</option>
          <option value="70">Assembly v5.0</option>
        </select>
    </fieldset>

     <tr>
        <td align="left"><input type="text" id="gene_ens_id1" name="gene_ens_id" size="70" value="<%=dm.out("gene_ens_id", "")%>"></td>
        <td align="left"><input type="text" id="chr1" name="chr" size="70" value="<%=dm.out("chr", "")%>"></td>
        <td align="left"><input type="text" id="start1" name="start" size="70" value="<%=dm.out("start", "")%>"></td>
        <td align="left"><input type="text" id="stop1" name="stop" size="70" value="<%=dm.out("stop", "")%>"></td>
        <td align="center"><input type="submit"  value="Create primer Pairs" > </td>
    </tr>

</table>
</form>





<%@ include file="/common/footerarea.jsp"%>
