<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.datamodel.ontology.Annotation" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="java.util.Date" %>
<%@ page import="edu.mcw.rgd.dao.impl.RGDUserDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>


<%
    String pageTitle;
    boolean isClone = (Boolean) request.getAttribute("isClone");
    boolean isNew = (Boolean) request.getAttribute("isNew");
    if (isNew)
        pageTitle = "Create Annotation";
    else pageTitle = "Edit Annotation";
    String headContent = "";
    String pageDescription = "";

%>
<%@ include file="/common/headerarea.jsp"%>
<%
    Annotation annot = (Annotation) request.getAttribute("editObject");
    HttpRequestFacade req = (HttpRequestFacade) request.getAttribute("requestFacade");
    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
    FormUtility fu = new FormUtility();
    DisplayMapper dm = new DisplayMapper(req, error);
Date today = new Date();
    if (isClone) {
        Annotation clone = (Annotation) request.getAttribute("cloneObject");
        annot = clone;
    }
    RGDUserDAO udao = new RGDUserDAO();

%>


<h1><%=pageTitle%> for <%=annot.getObjectSymbol()%></h1>

<form action="editAnnotation.html">
<input type="hidden" name="rgdId" value="<%=annot.getKey()%>" />
<input type="hidden" name="key" value="<%=annot.getKey()%>" />
    <% if (isNew) {%>
    <input type="hidden" name="act" id="act" value="add"/>
    <% } else { %>
    <input type="hidden" name="act" id="act" value="upd"/>
    <% } %>
<table >
    <% if (!isNew) { %>
    <tr>
        <td class="label" >Key:</td>
        <td><%=fu.chkNull(annot.getKey())%></td>
    </tr>
    <% } %>
    <tr>
        <td class="label">Annotated Object RGD ID:</td>
        <td><input type="text" name="annotatedObjectRgdId" size="20" value="<%=dm.out("annotatedObjectRgdId",annot.getAnnotatedObjectRgdId())%>" /></td>
    </tr>
    <tr>
        <td class="label">RGD Object Key:</td>
        <td><%=fu.chkNull(annot.getRgdObjectKey())%></td>
    </tr>
    <tr>
        <td class="label">Object Symbol:</td>
        <td><%=fu.chkNull(annot.getObjectSymbol())%></td>
    </tr>
    <tr>
        <td class="label">Object Name:</td>
        <td><%=fu.chkNull(annot.getObjectName())%></td>
    </tr>
    <tr><td>&nbsp;</td></tr>
    
    <tr>
        <td class="label">Term Acc:</td>
        <td><input type="text" name="termAcc" size="20" value="<%=dm.out("termAcc",annot.getTermAcc())%>" /></td>
    </tr>
    <tr>
        <td class="label">Term:</td>
        <td><%=fu.chkNull(annot.getTerm())%></td>
    </tr>
    <tr>
        <td class="label">Data Src:</td>
        <td><input type="text" name="dataSrc" size="20" value="<%=dm.out("dataSrc",annot.getDataSrc())%>" /></td>
    </tr>
    <tr>
        <td class="label">Ref RGD ID:</td>
        <td><input type="text" name="refRgdId" size="20" value="<%=dm.out("refRgdId",annot.getRefRgdId())%>" /></td>
    </tr>
    <tr>
        <td class="label">Evidence:</td>
        <td><input type="text" name="evidence" size="20" value="<%=dm.out("evidence",annot.getEvidence())%>" /></td>
    </tr>
    <tr>
        <td class="label">With Info:</td>
        <td><input type="text" name="withInfo" size="20" value="<%=dm.out("withInfo",annot.getWithInfo())%>" /></td>
    </tr>
    <tr>
        <td class="label">Aspect:</td>
        <td><input type="text" name="aspect" size="20" value="<%=dm.out("aspect",annot.getAspect())%>" /></td>
    </tr>
    <tr>
        <td class="label">Notes:</td>
        <td><textarea rows="4" name="notes" cols="45" ><%=dm.out("notes",annot.getNotes())%></textarea></td>
    </tr>
    <tr>
        <td class="label">Qualifier:</td>
        <td><input type="text" name="qualifier" size="20" value="<%=dm.out("qualifier",annot.getQualifier())%>" /></td>
    </tr>
    <tr>
        <td class="label">Relative To:</td>
        <td><input type="text" name="relativeTo" size="20" value="<%=dm.out("relativeTo",annot.getRelativeTo())%>" /></td>
    </tr>
    <tr>
        <td class="label">Created Date:</td>
        <% if (isNew) {%>
        <td><%=sdf.format(today)%></td>
        <% } else { %>
        <td><%=annot.getCreatedDate()==null ? "" : sdf.format(annot.getCreatedDate())%></td>
        <% } %>
    </tr>
    <tr>
        <td class="label">Last Modified Date:</td>
        <% if (isNew) {%>
        <td><%=sdf.format(today)%></td>
        <% } else { %>
        <td><%=annot.getLastModifiedDate()==null ? "" : sdf.format(annot.getLastModifiedDate())%></td>
        <% } %>
    </tr>
    <tr>
        <td class="label">Created By:</td>
        <% if (isNew) {%>
        <td> </td>
        <% } else { %>
        <td><%=udao.getCurationUser(annot.getCreatedBy())%></td>
        <% } %>

    </tr>
    <tr>
        <td class="label">Last Modified By:</td>
        <% if (isNew) {%>
        <td> </td>
        <% } else { %>
        <td><%=udao.getCurationUser(annot.getLastModifiedBy())%></td>
        <% } %>

    </tr>
    <tr>
        <td class="label">XRef Source:</td>
        <td><input type="text" name="xrefSource" size="45" value="<%=dm.out("xrefSource",annot.getXrefSource())%>" /></td>
    </tr>
    <tr>
        <% if(isNew) { %>
        <td colspan="2"><br><input type="submit" name="clone_and_curate" value="Add and return to curation tool"/>
            &nbsp; <input type="submit" value="Add" size="10" /> &nbsp;
       <% if ( (annot.getTermAcc().startsWith("DO") || annot.getTermAcc().startsWith("PW") || annot.getTermAcc().startsWith("CHEBI")) ) {  %>

            <input type="checkbox" name="clone1" value=<%=SpeciesType.RAT%> checked>  Rat&nbsp;
            <input type="checkbox" name="clone2" value=<%=SpeciesType.MOUSE%> checked>  Mouse&nbsp;
            <input type="checkbox" name="clone3" value=<%=SpeciesType.HUMAN%> checked>  Human&nbsp;
        </td>
            <% }} else {%>
        <td colspan="2"><br><input type="submit" name="update_and_curate" value="Update and return to curation tool"/>
            &nbsp; <input type="submit" value="Update" size="10" />
            &nbsp; <a href=/rgdCuration/?module=curation&func=linkAnnotation#title>Curation Tool</a>
        </td>
<%} %>
    </tr>
</table>
</form>
<form action="editAnnotation.html">
    <input type="hidden" value="clone" name="act" />

    <input type="hidden" name="rgdId" value="<%=annot.getKey()%>" />
    <% if (!isNew &&
            (annot.getEvidence().equals("IAGP") || annot.getEvidence().equals("IDA") || annot.getEvidence().equals("IEP") || annot.getEvidence().equals("IGI")
                    || annot.getEvidence().equals("IMP") || annot.getEvidence().equals("IPI")) || annot.getEvidence().equals("EXP") ) { %>
    <input  type="submit" value="Clone" />
    <% } %>

</form>
<%@ include file="/common/footerarea.jsp"%>

