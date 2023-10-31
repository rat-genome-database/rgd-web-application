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
               name="<%=objectType%><%=associationType%>Association" type="text" size="9" value="<%=assocRgdId%>"/><a href="javascript:lookup_render('<%=objectType%><%=associationType%>Association<%=associationCount%>')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a><a class="removeButton" href="javascript:removeAssociation('<%=objectType%><%=associationType%>Association<%=associationCount%>')"><img src="/rgdweb/common/images/del.jpg" border="0"/></a>

        <%
                associationCount++;
            }
        %>
    </td>
</tr>
<tr><td></td><td><hr></td></tr>
<% } %>
<script>
    function lookup_render(oid) {
        objectType="REFERENCES";
        speciesTypeKey=0;
        var seed = "";
        if (document.getElementById(oid)) {
            seed = document.getElementById(oid).value;
        }
        console.log(seed);
        lookup_currentId = oid;
        lookup_speciesTypeKey = speciesTypeKey;
        lookup_objectType = objectType;
        if (lookup_currentWindow != null && !lookup_currentWindow.closed) {
            lookup_currentWindow.close();
        }

        lookup_currentWindow=dhtmlwindow.open('ajaxbox', 'ajax', '/rgdweb/common/lookup/lookup.jsp?seed=' + seed, 'Symbol Lookup', 'width=400px,height=350px,left=300px,top=50px,resize=0,scrolling=1');
        //lookup_intervalId = setInterval("lookup_checkValue()", 3500);

    }
</script>