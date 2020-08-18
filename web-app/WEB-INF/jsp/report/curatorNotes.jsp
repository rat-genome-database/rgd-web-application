<%@ page import="edu.mcw.rgd.datamodel.Note" %>
<%@ page import="java.util.List" %>

<%@ include file="sectionHeader.jsp"%>
<%
    List<Note> noteList = noteDAO.getNotes(obj.getRgdId());
    // sort notes by note_type
	Collections.sort(noteList, new Comparator<Note>() {
        public int compare(Note o1, Note o2) {
            return Utils.stringsCompareToIgnoreCase(o1.getNotesTypeName(), o2.getNotesTypeName());
        }
    });
if (noteList.size() > 0) {
%>


<div class="sectionHeading" id="rgdCurationNotes">RGD Curation Notes</div>
<table border="1" cellpadding="4" cellspacing="0">
<tr>
    <th>Note Type</th>
    <th>Note</th>
    <th>Reference</th>
<% if( RgdContext.isCurator() ) { %>
    <th>Is Public</th>
<% } %>
</tr>
<%
    for (Note noteValue: noteList) {
        if( noteValue.getPublicYN().equals("Y") || RgdContext.isCurator() ) {
%>
<tr>
    <td><%=noteValue.getNotesTypeName()%></td>
    <td><%=noteValue.getNotes()%></td>

    <td>

        <% if (noteValue.getRefId() != null) { %>
            <a href="<%=Link.ref(noteValue.getRefId())%>"><%=noteValue.getRefId()%></a>
        <% } else { %>
            &nbsp;
        <% } %>

    </td>

<% if( RgdContext.isCurator() ) { %>
    <td><%=noteValue.getPublicYN()%></td>
<% } %>
</tr>


<%
    }}
%>
</table>
<br>


<% } %>

<%@ include file="sectionFooter.jsp"%>
