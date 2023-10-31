<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="java.util.List" %>
<%
    String pageTitle = "Edit Object";
    String headContent = "";
    String pageDescription = "";

    FormUtility fu = new FormUtility();

    List speciesList = new ArrayList();
    speciesList.add("Rat");
    speciesList.add("Mouse");
    speciesList.add("Human");

    List statusList = new ArrayList();
    statusList.add("ACTIVE");
    statusList.add("RETIRED");
    statusList.add("WITHDRAWN");

%>

<%@ include file="/common/headerarea.jsp"%>

<script type="text/javascript" src="/rgdweb/js/util.js"></script>

<link rel="stylesheet" href="/rgdweb/js/windowfiles/dhtmlwindow.css" type="text/css"/>
<script type="text/javascript" src="/rgdweb/js/windowfiles/dhtmlwindow.js">
    /***********************************************
     * DHTML Window Widget- � Dynamic Drive (www.dynamicdrive.com)
     * This notice must stay intact for legal use.
     * Visit http://www.dynamicdrive.com/ for full source code
     ***********************************************/
</script>
<script type="text/javascript" src="/rgdweb/js/lookup.js"></script>

<script type="text/javascript">
    function navigatePage(form) {
        form.action = form.objectType.options[form.objectType.options.selectedIndex].value;

        form.submit();
    }
</script>

<h1>RGD Object Editor</h1>

<h3>Add an RGD Object</h3>
<form action="">
<input type="hidden" value="new" name="act" />
    <input type="hidden" value="<%=request.getParameter("token")%>" name="token" />
<table>
    <tr>
        <td>
            <select name="objectType">
                <option value="editGene.html">Gene</option>
                <option value="editQTL.html">QTL</option>
                <option value="editStrain.html">Strain</option>
                <option value="editSSLP.html">SSLP</option>
                <option value="editVariant.html">Variant</option>
                <option value="editReference.html">Reference</option>
                <option value="editCellLine.html">Cell Line</option>
                <option value="editTerm.html">Term</option>
                <option value="editProject.html">Project</option>
            </select>
        </td>
        <td><%=fu.buildSelectList("speciesType",speciesList, "Rat")%></td>
        <td><%=fu.buildSelectList("objectStatus",statusList, "ACTIVE")%></td>

        <td><input  type="button" value="Submit" onClick="navigatePage(this.form)"/> </td>
        <td> &nbsp; &nbsp; github login: <b><%=edu.mcw.rgd.edit.TermEditObjectController.getCreatedBy(request)%></b></td>
    </tr>
</table>
</form>


<h3>Edit an Existing RGD Object</h3>

<form action="">
<input type="hidden" value="new" name="edit" />
    <input type="hidden" value="<%=request.getParameter("token")%>" name="token" />
<table>
    <tr>
        <td>
            <select name="objectType">
                <option value="editGene.html">Gene</option>
                <option value="editQTL.html">QTL</option>
                <option value="editStrain.html">Strain</option>
                <option value="editSSLP.html">SSLP</option>
                <option value="editVariant.html">Variant</option>
                <option value="editReference.html">Reference</option>
                <option value="editCellLine.html">Cell Line</option>
                <option value="editAnnotation.html?">Annotation</option>
                <option value="editGenomicElement.html">Genomic Element</option>
                <option value="editTerm.html">Ontology Term</option>
                <option value="editProject.html">Project</option>
            </select>
        </td>
        <td>&nbsp;</td>
        <td  class="label">RGD ID:</td>
        <td><input id="rgdId1" name="rgdId" type="text" value="" /></td>
        <td><a href="javascript:lookup_render('rgdId1')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a></td>
        <td><input  type="button" value="Submit" onClick="navigatePage(this.form)"/> </td>
    </tr>
</table>
</form>

<h3>Clone an RGD Object</h3>
<form action="">
<input type="hidden" value="clone" name="act" />
    <input type="hidden" value="<%=request.getParameter("token")%>" name="token" />
<table>
    <tr>
        <td>
            <select name="objectType">
                <!--<option value="editGene.html">Gene</option>-->
                <option value="editQTL.html">QTL</option>
                <option value="editStrain.html">Strain</option>
                <option value="editVariant.html">Variant</option>
                <option value="editReference.html">Reference</option>
                <option value="editProject.html">Project</option>
                <!--
                <option value="editSSLP.html">SSLP</option>
                -->
            </select>
        </td>
        <td><%=fu.buildSelectList("speciesType",speciesList, "Rat")%></td>
        <td><%=fu.buildSelectList("objectStatus",statusList, "ACTIVE")%></td>
        <td><input type="text" id="rgdId2" name="rgdId" value="" /> </td>
        <td><a href="javascript:lookup_render('rgdId2')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a></td>        
        <td><input  type="button" value="Submit" onClick="navigatePage(this.form)"/> </td>
    </tr>
</table>
</form>

<hr>
<h1>Group Update Tools</h1>

<a href="statusUpdate.html" >Update Object Status</a>
<!--<a href="notesAdd.html" >Add Note</a>-->

<h3>Gene Merge</h3>
<form action="geneMerge.html">

<TABLE>
    <TR>
        <td class="label">Gene RGD ID From:</td><td><input type="text" name="rgdIdFrom" value="" /></td>
        <td class="label">Gene RGD ID To:</td><td><input type="text" name="rgdIdTo" value="" /></td>
        <td><input type="submit" name="Submit" value="Submit"/></td>
    </TR>
</table>
</form>

<h3>Drop Manual Orthologs</h3>
<form action="dropManualOrthologs.html">

<TABLE>
    <TR>
        <td><input type="submit" name="Submit" value="Go to Drop Manual Orthologs Tool"/></td>
    </TR>
</table>
</form>

<h3>Term Merge (RDO/CMO/MMO/XCO/RS/PW)</h3>
<form action="termMerge.html">

<TABLE>
    <TR>
        <td class="label">Term Acc From:</td><td><input type="text" name="termAccFrom" value="" /></td>
        <td class="label">Term Acc To:</td><td><input type="text" name="termAccTo" value="" /></td>
        <td><input type="submit" name="Submit" value="Submit"/></td>
    </TR>
</table>
</form>

<%@ include file="/common/footerarea.jsp"%>