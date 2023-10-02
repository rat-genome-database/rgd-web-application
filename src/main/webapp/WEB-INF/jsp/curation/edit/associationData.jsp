<%@ page import="java.util.Iterator" %>

<% {  %>
<tr>
    <td class="label"><a href="javascript:addTextArea('<%=objectType%><%=associationType%>Association',<%=speciesTypeKey%>,'<%=objectKey%>');void(0);" class="addButton">Add&nbsp;<%=associationType%></a>&nbsp;</td>
    <td id="<%=objectType%><%=associationType%>AssociationTD" align="left"> 
    <%
        Iterator associationIt = associationList.iterator();
        int associationCount = 1;
        while (associationIt.hasNext()) {
            Object ooa = associationIt.next();

            int assocRgdId = 0;
            if( ooa instanceof Association ) {
                assocRgdId = ((Association)ooa).getDetailRgdId();
            } else if( ooa instanceof Identifiable ) {
                assocRgdId = ((Identifiable)ooa).getRgdId();
            }

    %>
    <input id="<%=objectType%><%=associationType%>Association<%=associationCount%>"
           name="<%=objectType%><%=associationType%>Association" type="text" size="9" value="<%=assocRgdId%>"/><a href="javascript:lookup_render('<%=objectType%><%=associationType%>Association<%=associationCount%>', 3, '<%=objectKey%>')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a><a class="removeButton" href="javascript:removeAssociation('<%=objectType%><%=associationType%>Association<%=associationCount%>')"><img src="/rgdweb/common/images/del.jpg" border="0"/></a>

    <%
            associationCount++;
        }
    %>
    </td>
</tr>
<tr><td></td><td><hr></td></tr>
<% } %>