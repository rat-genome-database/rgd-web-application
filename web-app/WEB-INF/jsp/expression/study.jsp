<%@ page import="edu.mcw.rgd.datamodel.GeoRecord" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.PhenominerDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Study" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Objects" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Experiment" %>
<%@ page import="java.util.ArrayList" %>
<%

  String pageTitle = "Create Geo Sample";
  String headContent = "";
  String pageDescription = "Create Geo Sample";

%>

<%@ include file="/common/headerarea.jsp" %>
<%

  String gse = request.getParameter("gse");
  PhenominerDAO pdao = new PhenominerDAO();
  Study study = pdao.getStudyByGeoId(gse);
  List<Experiment> experiments = new ArrayList<>();
  if(study != null)
    experiments = pdao.getExperiments(study.getId());
  %>

<% if(study == null ) {%>
<span style="color: #24609c; font-weight: bold;"><a href="https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=<%=gse%>" target="_blank"><%=gse%></a></span><br>

<form name="importReferences" action="/rgdweb/pubmed/importReferences.html?action=phenominer">
  <input type="hidden" value="phenominer" name="action" />
  <table width="90%" cellpadding="5" style="background-color: #daeffc">
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
  <table width="90%" cellpadding="5" style="background-color: #daeffc">
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

<form name="createStudy" action="study.html">
  <input type="hidden" name="act" value="createStudy"/>
  <table width="90%" cellpadding="5" style="background-color:#daeffc;">
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
        <td><input type="text" name="refRgdId" value=""></td>
    </tr>
    <tr>
        <td>Geo Series Acc</td>
        <td><input type="text" readonly="true" name="geoSeriesAcc" value=<%=gse%>> </td>
        <td><input type="submit"  value="Create Study"></td>
    </tr>
  </table>
</form>

<% } else { %>
<form name="createStudy" action="study.html">
  <input type="hidden" name="act" value="editStudy"/>
  <table width="90%" cellpadding="5">
    <tr>
      <td style="font-weight:700;font-size:16px;">Edit Study</td>
    </tr>
    <tr>
      <td width="33%">Study Id:</td>
      <td width="33%"><input type="text" readonly="true" name="studyId" value=<%=study.getId()%>></td>
    </tr>
    <tr>
      <td width="33%">Study Name:</td>
      <td width="33%"><input type="text" name="name" value=<%=study.getName()%>></td>
    </tr>
    <tr>
      <td>Study Source:</td>
      <td><input type="text" name="source" value=<%=study.getSource()%>></td>
    </tr>
    <tr>
      <td>Study Type:</td>
      <td><input type="text" name="type" value=<%=study.getType()%>></td>
    </tr>
    <tr>
      <td>Ref RGD Id:</td>
      <td><input type="text" name="refRgdId" value=<%=study.getRefRgdId()%>></td>
    </tr>
    <tr>
      <td>Geo Series Acc</td>
      <td><input type="text" readonly="true" name="geoSeriesAcc" value=<%=study.getGeoSeriesAcc()%>> </td>
      <td><input type="submit"  value="Edit Study"></td>
    </tr>
  </table>
</form>

<a href="/rgdweb/expression/editExperiment.html?studyId=<%=study.getId()%>">Create Experiment</a><br><br>
  <table width="90%" cellpadding="5">
    <% if(experiments.size() > 0) {%>
      <th>Experiment Id</th>
    <th>Experiment Name</th>
    <th>Trait Ont Id</th>
    <th>Notes</th>
    <%}%>
    <%for(Experiment e:experiments){ %>
  <tr>
  <td><a href='editExperiment.html?act=edit&expId=<%=e.getId()%>&studyId=<%=e.getStudyId()%>'><%=e.getId()%></a></td>
    <td><%=e.getName()%></td>
    <td><%=e.getTraitOntId()%></td>
    <td><%=e.getNotes()%> </td>
</tr>
    <%}%>
</table>

<%}%>


