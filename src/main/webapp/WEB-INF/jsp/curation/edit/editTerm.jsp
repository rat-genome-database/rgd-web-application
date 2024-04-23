<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermSynonym" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermDagEdge" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermXRef" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%
    String pageTitle = "Term Edit";
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="/common/headerarea.jsp"%>
<%
    FormUtility fu = new FormUtility();
    HttpRequestFacade req = new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req, null);

    Term term = (Term) request.getAttribute("term");

    String statusMsg = (String) request.getAttribute("statusMsg");

    String synTabMsg = (String) request.getAttribute("synTabMsg");
    List<TermSynonym> synonyms = (List<TermSynonym>) request.getAttribute("synonyms");

    String dagTabMsg = (String) request.getAttribute("dagTabMsg");
    List<TermDagEdge> parentEdges = (List<TermDagEdge>) request.getAttribute("dags");

    String xrefTabMsg = (String) request.getAttribute("xrefTabMsg");
    List<TermXRef> xrefs = (List<TermXRef>) request.getAttribute("xrefs");

    List<String> synonymTypes = (List<String>) request.getAttribute("synonymTypes");

    boolean isNewCustomTerm = Utils.isStringEmpty(term.getTerm());
    boolean termIsDeleted = synonyms==null;

    Map<String,String> dagTypes = new HashMap<>();
    dagTypes.put("IA", "is-a");
    dagTypes.put("PO", "part-of");
    dagTypes.put("HC", "has-component");
%>
<% if( isNewCustomTerm ) { %>
<h1>New Custom Term:</h1>
<% } else { %>
<h1>Edit Term: <%=term.getTerm()%> (<%=term.getAccId()%>)</h1>
<% } %>


<form action="editTerm.html" method="post" accept-charset="UTF-8">
<input type="hidden" name="termAcc" id="termAcc" value="<%=term.getAccId()%>" />
<input type="hidden" name="action" value="update" />

<% if( !Utils.isStringEmpty(statusMsg) ) { %>
    <p style="color:blue;font-weight:bold"><%=statusMsg%></p>
<% } %>

<table >
    <tr>
        <td class="label">Term Acc:</td>
        <td><% if( isNewCustomTerm ) { %>
                <select name="newTermAcc">
                    <option selected>select ontology</option>
                    <option>DOID:9XXXXXX</option>
                    <option>PW:XXXXXXX</option>
                    <option>CMO:XXXXXXX</option>
                    <option>MMO:XXXXXXX</option>
                    <option>XCO:XXXXXXX</option>
                    <option>RS:XXXXXXX</option>
                </select>
            <% } else { %>
                <%=term.getAccId()%>
            <% } %>
            &nbsp;
            <% if(!termIsDeleted) {%> <a href="<%=Link.ontView(term.getAccId())%>">browse the term</a><% } %>
        </td>
    </tr>
    <tr>
        <td class="label">Is Obsolete:</td>
        <td><%=term.isObsolete()?"<span style='font-weight:bold;color:red;border-style:solid'>true</span>":"false"%></td>
    </tr>
    <tr>
        <td class="label">Created:</td>
        <td>by: <b><%=Utils.NVL(term.getCreatedBy(),"N/A")%></b>
            <% if( term.getCreationDate()!=null ) { %>, &nbsp; &nbsp; date created: <b><%=term.getCreationDate().toString().substring(0, 10)%></b> <% } %>
        </td>
    </tr>
    <tr>
        <td class="label">Last Modified:</td>
        <td><% if( term.getModificationDate()!=null ) { %>date modified: <b><%=term.getModificationDate().toString().substring(0, 10)%></b> <% } %>
        </td>
    </tr>

    <tr>
        <td class="label">Name:</td>
        <td><input type="text" name="name" size="80" value="<%=Utils.defaultString(term.getTerm())%>" /> </td>
    </tr>
    <tr>
        <td class="label">Definition:</td>
        <td><textarea rows="5" cols="120" name="def"><%=Utils.defaultString(term.getDefinition())%></textarea></td>
    </tr>

    <% if( !isNewCustomTerm && !termIsDeleted ) { %>
    <tr>
        <td class="label" valign="top">Definition sources:
            <br><br>
            <a href="javascript:addXref(); void(0);" style="font-weight:bold;color:green">Add Row</a>
        </td>
        <td><% if( !Utils.isStringEmpty(xrefTabMsg) ) { %>
            <p style="color:brown;font-weight:bold"><%=xrefTabMsg%></p>
            <% } %>
            <table id="xrefTab" width="800" border="1" cellpadding="1" cellspacing="1">
                <tr style="background-color:blue;color:white;font-size:10pt;">
                    <th>Xref &nbsp; f.e. 'CMO:0000286' or 'https://rgd.mcw.edu'</th>
                    <th>Description</th>
                    <th>Del</th>
                </tr>
                <%  int itx = -1;
                    for( TermXRef xref: xrefs ) {
                        itx++;
                %>
                <tr style="background-color:#d3d3d3">
                    <td><input name="xref_key" type="hidden" value="<%=xref.getKey()%>">
                        <input name="xref_value" value="<%=Utils.defaultString(xref.getXrefValue())%>" size="100"></td>
                    </td>
                    <td><input name="xref_info" value="<%=Utils.defaultString(xref.getXrefDescription())%>" size="20"></td>
                    <td><input name="xref_del<%=itx%>" type="checkbox"></td>
                </tr>
                <% } %>
            </table>
        </td>
    </tr>

    <tr>
        <td class="label" valign="top">Synonyms:
            <br><br>
            <a href="javascript:addTermSynonym(); void(0);" style="font-weight:bold;color:green">Add EXACT</a>
            <br>
            <a href="javascript:addRelatedSynonym(); void(0);" style="font-weight:bold;color:green">Add RELATED</a>
            <br>
            <a href="javascript:addDisplaySynonym(); void(0);" style="font-weight:bold;color:green" title="Add 'display_synonym' to be used in the Alliance UI">Add DISPLAY</a>
        </td>
        <td><% if( !Utils.isStringEmpty(synTabMsg) ) { %>
            <p style="color:red;font-weight:bold"><%=synTabMsg%></p>
            <% } %>
            <table id="synTab" width="800" border="1" cellpadding="1" cellspacing="1">
            <tr style="background-color:blue;color:white;font-size:10pt;">
                <th>Type</th>
                <th>Name</th>
                <th>Source</th>
                <th>DbXrefs</th>
                <th>Created</th>
                <th>Del</th>
            </tr>
            <%  int its = -1;
                for( TermSynonym ts: synonyms ) {
                  its++;
            %>
            <tr style="background-color:#d3d3d3">
                <td><input name="syn_key" type="hidden" value="<%=ts.getKey()%>">
                    <%=fu.buildSelectList("syn_type",synonymTypes, dm.out("objectStatus",ts.getType()))%>
                </td>
                <td><input name="syn_name" value="<%=Utils.defaultString(ts.getName())%>" size="66"></td>
                <td><input name="syn_source" value="<%=Utils.defaultString(ts.getSource())%>" size="4"></td>
                <td><input name="syn_dbxrefs" value="<%=Utils.defaultString(ts.getDbXrefs())%>" size="5"></td>
                <td><%=ts.getCreatedDate()==null ? "" : ts.getCreatedDate().toString().substring(0, 10)%></td>
                <td><input name="syn_del<%=its%>" type="checkbox"></td>
            </tr>
            <% } %>
        </table>
        </td>
    </tr>

    <tr>
        <td class="label" valign="top">Parent Relationships:
            <br>
            <br>
            <a href="javascript:addParentEdge(); void(0);" style="font-weight:bold;color:green">Add Parent</a>
        </td>
        <td><% if( !Utils.isStringEmpty(dagTabMsg) ) { %>
            <p style="color:red;font-weight:bold"><%=dagTabMsg%></p>
            <% } %>
            <table id="dagTab" width="800" border="1" cellpadding="1" cellspacing="1">
            <tr style="background-color:blue;color:white;font-size:10pt;">
                <th>Parent Term Acc</th>
                <th>Parent Term Name</th>
                <th>Relationship</th>
                <th>Created Date</th>
                <th>Del</th>
            </tr>
            <%  for( TermDagEdge dag: parentEdges ) {
                    int colonPos = dag.getParentTermAcc().indexOf(':');
            %>
            <tr style="background-color:#d3d3d3">
                <td><input name="dag_term_acc" readonly value="<%=Utils.defaultString(dag.getParentTermAcc())%>" size="12"></td>
                <td><%=Utils.defaultString(dag.getParentTermName())%></td>
                <td><%=fu.buildSelectList("dag_type",dagTypes, dm.out("dag_type",dag.getRelId()))%></td>
                <td><%=Utils.defaultString(dag.getCreatedDate().toString())%></td>
                <td><input name="dag_del_<%=dag.getParentTermAcc().substring(1+colonPos)%>" type="checkbox"></td>
            </tr>
            <% } %>
        </table>
        </td>
    </tr>
    <% } %>

    <% if( !termIsDeleted ) { %>
    <tr>
        <td>&nbsp;</td>
        <td><table width="100%"><tr>
            <td align="right"><input type="submit" name="form_upsert" id="upsert" value="<%=isNewCustomTerm?"Insert Custom Term":"Update Term"%>"></td>
            <% if( !isNewCustomTerm && parentEdges.isEmpty() ) { %>
            <td align="right"><input type="submit" name="form_delete" value="Delete from database" style="font-weight:bold;color:red"></td>
            <td align="right"><input type="submit" name="form_obsolete" value="Obsolete term" style="font-weight:bold;color:orangered"></td>
            <% } %>
        </tr></table></td>
    </tr>

    <tr>
        <td class="label">Comments: (non-public)</td>
        <td><textarea rows="4" cols="120" name="comment"><%=Utils.defaultString(term.getComment())%></textarea></td>
    </tr>
    <% } else { %>
    <a href="/rgdweb/ontology/search.html">Search Ontologies</a><p>
    <% } %>
</table>
</form>
<script>

var xkey = 0;
function addXref() {
    xkey--;
    var tbody = document.getElementById("xrefTab").getElementsByTagName("TBODY")[0];

    var row = document.createElement("TR");
    var td = document.createElement("TD");
    td.innerHTML = '<input name="xref_key" type="hidden" value="'+xkey+'">'+
        '<input name="xref_value" size="100">';
    row.appendChild(td);

    td = document.createElement("TD");
    td.innerHTML = '<input name="xref_info" size="20">';
    row.appendChild(td);

    td = document.createElement("TD");
    td.innerHTML = '<input name="xref_delm'+(-xkey)+'" type="checkbox">';
    row.appendChild(td);

    tbody.appendChild(row);
}

function addTermSynonym() {
    addSynonym('exact_synonym');
}

function addRelatedSynonym() {
    addSynonym('related_synonym');
}

function addDisplaySynonym() {
    addSynonym('display_synonym');
}

var tskey = 0;
function addSynonym(newSynType) {
    tskey--;
    var tbody = document.getElementById("synTab").getElementsByTagName("TBODY")[0];

    var row = document.createElement("TR");
    var td = document.createElement("TD");
    td.innerHTML = '<input name="syn_key" type="hidden" value="'+tskey+'">'+
            '<input name="syn_type" value="'+newSynType+'" size="16" style="font-size:10pt">';
    row.appendChild(td);

    td = document.createElement("TD");
    td.innerHTML = '<input name="syn_name" value="" size="66">';
    row.appendChild(td);

    td = document.createElement("TD");
    td.innerHTML = '<input name="syn_source" value="RGD" size="4">';
    row.appendChild(td);

    td = document.createElement("TD");
    td.innerHTML = '<input name="syn_dbxrefs" value="" size="5">';
    row.appendChild(td);

    td = document.createElement("TD");
    td.innerHTML = '<input name="syn_delm'+(-tskey)+'" type="checkbox">';
    row.appendChild(td);

    tbody.appendChild(row);
}

function addParentEdge() {
    var tbody = document.getElementById("dagTab").getElementsByTagName("TBODY")[0];

    var row = document.createElement("TR");
    var td;

    td = document.createElement("TD");
    td.innerHTML = '<input name="dag_term_acc" value="" size="12" maxlength="12">';
    row.appendChild(td);

    td = document.createElement("TD");
    row.appendChild(td);

    td = document.createElement("TD");
    td.innerHTML = '<%=fu.buildSelectList("dag_type",dagTypes, dm.out("dag_type","is-a"))%>';
    row.appendChild(td);

    td = document.createElement("TD");
    row.appendChild(td);

    td = document.createElement("TD");
    row.appendChild(td);

    tbody.appendChild(row);
}
</script>
<%@ include file="/common/footerarea.jsp"%>
