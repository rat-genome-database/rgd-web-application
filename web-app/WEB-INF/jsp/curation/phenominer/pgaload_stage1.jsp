<%
    String pageTitle = "Phenominer Curation";
    String headContent = "";
    String pageDescription = "";

%>

<%@ include file="editHeader.jsp"%>

<span class="phenominerPageHeader">PGA Load - Select Csv File</span>

<div class="phenoNavBar">
<table >
    <tr>
        <td><a href='home.html'>Home</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='search.html?act=new'>Search</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='studies.html'>List All Studies</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='pgaload.html'>PGA Load</a></td>
    </tr>
</table>
</div>

<form name="chooseFile" action="pgaload.html" method="post" enctype="multipart/form-data">
    <input type="hidden" name="stage" value="stage1" >
    <input type="hidden" name="study_source" value="PGA" >
    <input type="hidden" name="study_url" value="http://pga.mcw.edu" >

  <table width="90%" cellpadding="5" style="border:1px solid black;background-color:#fef0dc;">
    <tr>
        <td style="font-weight:700;font-size:16px;">Load a PGA Study</td>
    </tr>
    <tr>
      <td width="33%">Study Name:</td>
      <td width="33%"><input type="text" name="study_name" value="PGA "></td>
    </tr>
    <tr>
      <td>Study Type:</td>
      <td>
          <select name="study_type">
              <option value="PGA consomic protocol" selected="selected">PGA consomic protocol</option>
              <option value="PGA mutant protocol">PGA mutant protocol</option>
          </select>
       </td>
    </tr>
    <tr>
        <td width="33%">Data File:</td>
        <td width="33%"><input type="file" name="study_file" size="40"></td>
        <td><input type="submit" name="load_study" value="Load Study"></td>
    </tr>
  </table>
</form>

<%@ include file="editFooter.jsp"%>
