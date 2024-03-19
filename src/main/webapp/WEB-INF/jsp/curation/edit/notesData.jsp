<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.dao.impl.ReferenceDAO" %>
<%@ page import="java.lang.ref.Reference" %>

<% if (!isNew) { %>

<%  
    NotesDAO ndao = new NotesDAO();
    List noteList = ndao.getNotes(displayRgdId);

    List isPublic = new ArrayList();
    isPublic.add("Y");
    isPublic.add("N");
    isPublic.add("H");
    isPublic.add("D");
    
%>

<script type="text/javascript">

    function removeNote(noteId, noteKey) {
        document.getElementById(noteId).style.display="none";

        if (noteKey != "") {
            var nd = document.createElement("input");
            nd.type="hidden";
            nd.value=noteKey;
            nd.name="notesDelete";
            document.getElementById("notesTable").appendChild(nd);
        }
    }

    var rowCreatedCount = 1;
    function addNote() {

        var tbody = document.getElementById("notesTable").getElementsByTagName("TBODY")[0];

        var row = document.createElement("TR");
        row.id = "createdNoteRow" + rowCreatedCount;

        var td = document.createElement("TD");
        td.innerHTML='<input type="text" name="notesRefKey" size="9" value="" />';
        row.appendChild(td);

        td = document.createElement("TD");

    <%
        String notesTypeSelectList = fu.buildSelectList("notesTypeName",new NotesDAO().getNotesTypes(notesObjectType), "", true);
    %>


    td.innerHTML='<%=notesTypeSelectList%>';
        
        row.appendChild(td);

        td = document.createElement("TD");
        td.align="center";
        td.innerHTML = '<%=fu.buildSelectList("notesIsPublic",isPublic, "Y")%>';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML='<textarea cols=45 rows="4" name="notesNotes"></textarea>';
        row.appendChild(td);

        td = document.createElement("TD");
        td.align="right";
        td.innerHTML='<a style="color:red; font-weight:700;" href="javascript:removeNote(\'createdNoteRow' + rowCreatedCount + '\');void(0);" ><img src="/rgdweb/common/images/del.jpg" border="0"/></a>';
        row.appendChild(td);

        rowCreatedCount++;

        var key = document.createElement("input");
        key.type="hidden";
        key.name="notesKey";
        key.value = "0";
        tbody.appendChild(key);

        tbody.appendChild(row);
        enableAllOnChangeEvents();

    }

</script>

<form action="updateNotes.html">
<input  type="hidden" name="rgdId" value="<%=rgdId%>"/>

<table id="notesTable" class="updateTile" width="600" cellspacing="0" border="0">
    <tbody >
    <!--<tr><td align="right" colspan="5"><input type="button" value="update" onclick="makePOSTRequest(this.form)"/></td></tr>-->
    <!--<tr><td align="right" colspan="5"><input type="submit" value="update" /></td></tr>-->
    <tr >
        <td colspan="4" style="background-color:#2865a3;color:white; font-weight: 700;">Free Text Notes</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;">
            <!--<input type="submit" value="submit" />-->
            <input type="button" value="Update" onclick="makePOSTRequest(this.form)"/>
        </td>
    </tr>
    <tr>
        <td colspan="5" align="right"><a href="javascript:addNote(); void(0);" style="font-weight:700; color: green;">Add Note</a></td>
    </tr>
    <tr>
        <td align="center" style="font-weight:700;">Ref RGD ID</td>
        <td align="center" style="font-weight:700;">Type</td>
        <td align="center" style="font-weight:700;">is Public?</td>
        <td align="center" style="font-weight:700;">Note</td>
        <td>&nbsp;</td>
    </tr>

    <%
        int noteCount=0;
        Iterator nit = noteList.iterator();
        while (nit.hasNext()) {
            Note note = (Note) nit.next();
            if (rgdId != displayRgdId) {
                note.setKey(0);
            }

    %>
    <input type="hidden" name="notesKey" value="<%=note.getKey()%>" />
    <tr id="noteRow<%=noteCount%>">
        <td valign="top"><input type="text" id="notesRefKey<%=noteCount%>" name="notesRefKey" size="9" value="<%=dm.out("notesRefKey",note.getRefId(),noteCount)%>" /></td>
        <td valign="top"><%=fu.buildSelectList("notesTypeName",new NotesDAO().getNotesTypes(notesObjectType), dm.out("notesTypeName",note.getNotesTypeName(),noteCount), true)%></td>
        <td  valign="top" align="center"><%=fu.buildSelectList("notesIsPublic",isPublic, dm.out("notesIsPublic",note.getPublicYN(),noteCount))%></td>
        <td><textarea cols=45 rows="4" name="notesNotes"><%=dm.out("notesNotes",note.getNotes(),noteCount)%></textarea></td>
        <td valign="top" align="right"><a  style="color:red; font-weight:700;" href="javascript:removeNote('noteRow<%=noteCount%>', <%=note.getKey()%>) ;void(0);" ><img src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
    </tr>
    <%
            noteCount++;
        }
    %>
    </tbody>
</table>
<div style="color:red">IsPublic: 'Y'-public, 'N'-not_public, 'H'-on_hold, 'D'-deleted <br>
Notes of types 'qtl_curation_comments', 'gene_curation_comments', 'qtl_cross_type', 'strain_curation_comments' and 'cell_line_curation_comments' cannot be public
</div>
</form>

<% } %>
