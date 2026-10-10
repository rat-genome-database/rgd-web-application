<%
    String pageTitle = "Phenominer Curation";
    String headContent = "";
    String pageDescription = "";

%>

<%@ include file="editHeader.jsp"%>

<span class="phenominerPageHeader">Select Reference For Study</span>

<div class="phenoNavBar">
<table >
    <tr>
        <td><a href='home.html'>Home</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='search.html?act=new'>Search</a></td>
        <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png" /></td>
        <td><a href='studies.html'>List All Studies</a></td>
    </tr>
</table>
</div>


<form name="importReferences" action="/rgdweb/pubmed/importReferences.html?action=phenominer">
  <input type="hidden" value="phenominer" name="action" />
    <table width="90%" cellpadding="5" style="border:1px solid black;background-color:#fef0dc;">
    <tr><td style="font-weight:700;font-size:16px;">Import Reference from NCBI</td></tr>
    <tr>
      <td width="33%">PMID:</td>
      <td width="33%"><input type="text" name="pmid_list" id="pmid_list" value=""></td>
      <td><input type="submit" name="importdirectly" value="Import" ></td>
    </tr>
    <tr>
      <td colspan="3"></td>
    </tr>
  </table>

</form>

<form name="findReferences" action="reference.html">
  <table width="90%" cellpadding="5" style="border:1px solid black;background-color:#fef0dc;">
    <tr><td style="font-weight:700;font-size:16px;">Search for an Existing Reference</td></tr>
    <tr>
      <td width="33%">Keywords in Title, Citation, or RGDID:</td>
      <td width="33%"><input type="text" name="title" id="title" value=""></td>
        <td><input type="submit" name="FindReferences" value="Find References" onClick="checkFindReferences();"></td>
    </tr>

    <tr>
      <td>Author:</td>
      <td><input type="text" name="author" id="author" value=""></td>
    </tr>
    <tr>
      <td>Year:</td>
      <td><input type="text" name="year" id="year" value=""></td>
    </tr>
  </table>
</form>

<form name="createStudy" action="studies.html">
    <input name="act" type="hidden" value="save">
  <table width="90%" cellpadding="5" style="border:1px solid black;background-color:#fef0dc;">
    <tr>
        <td style="font-weight:700;font-size:16px;">Create a New Study</td>
    </tr>
    <tr>
      <td width="33%">Study Name:</td>
      <td width="33%"><input type="text" name="name" value=""></td>
    </tr>
    <tr>
          <td>Study Source:</td>
          <td><input type="text" name="source" value=""></td>
    </tr>
    <tr>
      <td>Study Type:</td>
      <td><input type="text" name="type" value=""></td>
    </tr>
    <tr>
        <td>Ref RGD Id:</td>
        <td><input type="text" name="refRgdId0" value=""></td>
    </tr>
      <tr>
          <td>Additional Ref RGD Ids:</td>
          <td><input type="text" name="refRgdId1" value=""></td>
      </tr>
      <tr>
          <td></td>
          <td><input type="text" name="refRgdId2" value=""></td>
          <td><input type="submit" name="create_study" value="Create Study"></td>
      </tr>
  </table>
</form>

<%@ include file="editFooter.jsp"%>
