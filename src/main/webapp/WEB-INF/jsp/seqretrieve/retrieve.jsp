<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%
    String pageTitle = "Fasta DNA Sequence Retriever";
    String headContent = "";
    String pageDescription = "retrieve your genomic sub-sequence - fasta files";

%>
<%@ include file="/common/headerarea.jsp"%>
<%
    Integer mapKey = (Integer) request.getAttribute("mapKey");
    if( mapKey==null )
        mapKey=17;
    int speciesTypeKey = SpeciesType.getSpeciesTypeKeyForMap(mapKey);

    String chr = Utils.defaultString((String) request.getAttribute("chr"));
    Integer startPos = (Integer) request.getAttribute("startPos");
    Integer stopPos = (Integer) request.getAttribute("stopPos");
    String fasta = (String) request.getAttribute("fasta");
%>

<h2>Reference DNA Fasta Sequence Retriever</h2>

<form action="retrieve.html">
  <table width="500" border="black" frame="box">
    <tr>
      <th>Species</th>
      <th>Assembly</th>
      <th>Chr</th>
      <th>Start Pos</th>
      <th>End Pos</th>
    </tr>
    <tr>
      <td>
        <select onchange="populateMapKeys()" id="selectSpecies">
          <option <%=speciesTypeKey==SpeciesType.HUMAN?"selected=\"selected\"":""%>>Human</option>
          <option <%=speciesTypeKey==SpeciesType.MOUSE?"selected=\"selected\"":""%>>Mouse</option>
          <option <%=speciesTypeKey==SpeciesType.RAT?"selected=\"selected\"":""%>>Rat</option>
        </select>
      </td>
      <td>
        <select id="mapKey" name="mapKey">
            <% if( speciesTypeKey==SpeciesType.HUMAN ) { %>
              <option value="38" <%=mapKey==38?"selected":""%>>GRCh38 (hg38)</option>
              <option value="17" <%=mapKey==17?"selected":""%>>GRCh37 (hg19)</option>
              <option value="13" <%=mapKey==13?"selected":""%>>NCBI36 (hg18)</option>
            <% } else if( speciesTypeKey==SpeciesType.MOUSE ) { %>
              <option value="239" <%=mapKey==239?"selected":""%>>GRCm39 (mm39)</option>
              <option value="35" <%=mapKey==35?"selected":""%>>GRCm38 (mm10)</option>
              <option value="18" <%=mapKey==18?"selected":""%>>MGSCv37 (mm9)</option>
            <% } else if( speciesTypeKey==SpeciesType.RAT ) { %>
            <option value="372" <%=mapKey==372?"selected":""%>>mRatBN7.2 (rn7)</option>
            <option value="360" <%=mapKey==360?"selected":""%>>Rnor6.0 (rn6)</option>
            <option value="70" <%=mapKey==70?"selected":""%>>Rnor5.0 (rn5)</option>
            <option value="60" <%=mapKey==60?"selected":""%>>RGSC3.4 (rn4)</option>
            <% } else { %>
            <% } %>
        </select>
      </td>
      <td><input type="text" name="chr" size="2" maxlength="2" value="<%=chr%>"></td>
      <td><input type="text" name="startPos" value="<%=startPos!=null?startPos:""%>"></td>
      <td><input type="text" name="stopPos" value="<%=stopPos!=null?stopPos:""%>"></td>
    </tr>
  </table>

  <p>

  <table width="500" border="black" frame="box">
    <tr>
      <td>Format:</td>
      <td>
        <select name="format">
          <option selected="selected">html</option>
          <option>text</option>
        </select>
      </td>
      <td colspan="3" align="center"><input type="Submit" value="Submit"></td>
    </tr>
  </table>
</form>

<form action="retrieve.html">
  <% if( fasta!=null ) {%>
  <p>
  <table width="500" border="black" frame="box">
    <tr>
    <td>FASTA:</td>
    <td><textarea name="fasta" rows="10" cols="70"><%=fasta%></textarea>
    </td>
    </tr>
  </table>
  <% } %>
</form>

<script>
    function populateMapKeys() {
        var mapKeyObj = document.getElementById('mapKey');
        var speciesName = document.getElementById('selectSpecies').value;
        if( speciesName=='Human' ) {
            mapKeyObj.innerHTML =
            '<option value="38">GRCh38 (hg38)</option>\n'+
            '<option value="17">GRCh37 (hg19)</option>\n'+
            '<option value="13">NCBI36 (hg18)</option>\n';
        }
        else if( speciesName=='Mouse' ) {
            mapKeyObj.innerHTML =
            '<option value="239">GRCm39 (mm39)</option>\n'+
            '<option value="35">GRCm38 (mm10)</option>\n'+
            '<option value="18">MGSCv37 (mm9)</option>\n';
        }
        else if( speciesName=='Rat' ) {
            mapKeyObj.innerHTML =
            '<option value="372">mRatBN7.2 (rn7)</option>\n'+
            '<option value="360">Rnor6.0 (rn6)</option>\n'+
            '<option value="70">Rnor5.0 (rn5)</option>\n'+
            '<option value="60">RGSC3.4 (rn4)</option>\n';
        }
        else {
            mapKeyObj.innerHTML = '';
        }
    }
</script>

<%@ include file="/common/footerarea.jsp"%>