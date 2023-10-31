<%@ page import="edu.mcw.rgd.dao.impl.XdbIdDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Xdb" %>
<%@ page import="java.util.*" %>

<html>
<body>

<link href="/rgdweb/js/jsor-jcarousel-7bb2e0a/style.css" rel="stylesheet" type="text/css"/>

<%@ include file="gaHeader.jsp" %>
<%--@ include file="rgdHeader.jsp" --%>

<%
    XdbIdDAO xdao = new XdbIdDAO();
    List<Xdb> xdbs = xdao.getActiveXdbs();
%>


<script>
    function toggle(name) {
        checkboxes = document.getElementsByName(name);

        var checked = "checked";
        if (checkboxes[0].checked) {
            checked=false;
        }

        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = checked;
        }
    }

    function viewReport(rgdId) {
        document.report.rgdId.value = rgdId;
        document.report.submit();

    }
</script>

<form action="/rgdweb/ga/ui.html" name="report" method="<%=method%>">

    <table border=0 width="100%" style="margin-top:8px;">
        <tr><td style='background-color:#e6e6e6;padding:7px;' colspan="2"><b>Step Two: &nbsp;&nbsp;<span style="color:#205080;"></span></b>Select annotations to include in report<br></td></tr>
        <tr><td>&nbsp;</td></tr>
    </table>
    <table >
        <tr>
            <td valign="top">
                <input type="hidden" name="species" value="<%=req.getParameter("species")%>"/>
                <input type="hidden" name="rgdId" value=""/>
                <input type="hidden" name="idType" value="<%=req.getParameter("idType")%>"/>

                <table border="0" cellspacing=4 cellpadding=0 class="gaTable">
                    <tr>
                        <td class="gaLabel" colspan=2>Ontology Annotations &nbsp;&nbsp;<a href="javascript:void(0);" style="color:#4088b8;" onclick="toggle('o')">(toggle)</a></td>

               <%
                for( java.util.Map.Entry<String,String> aspect: aspects.entrySet() ) {
                %>
                    <tr>
                        <td><input type="checkbox" name="o" value="<%=aspect.getKey()%>" <% if (req.isInParameterValues("o",aspect.getKey())) out.print("checked"); %>>
                        </td>
                        <td><%=aspect.getValue()%>
                        </td>
                    </tr>

                    <% } %>
                </table>

            </td>
            <td>&nbsp;</td>
            <td valign="top">

                <%
                    int third = (2+xdbs.size())/3;
                    List xdbs1 = xdbs.subList(0, third);
                    int col3startIndex = 2*third;
                    if( xdbs.size()%3==1 )
                        col3startIndex--;
                    List xdbs2 = xdbs.subList(third, col3startIndex);
                    List xdbs3 = xdbs.subList(col3startIndex, xdbs.size());
                    Iterator xdi1 = xdbs1.iterator();
                    Iterator xdi2 = xdbs2.iterator();
                    Iterator xdi3 = xdbs3.iterator();
                %>

                <table border="0" cellspacing=4 cellpadding=0 class="gaTable">

                    <tr>
                        <td class="gaLabel" colspan="6">External Links&nbsp;&nbsp;<a href="javascript:void(0);" style="color:#4088b8;" onclick="toggle('x')">(toggle)</a></td>

                    <% while (xdi1.hasNext()) {
                        Xdb x1 = (Xdb) xdi1.next();
                    %>
                    <tr>
                        <td><input type="checkbox" name="x" value="<%=x1.getKey()%>" <% if (req.isInParameterValues("x",x1.getKey() + "")) out.print("checked"); %>></td>
                        <td><%=x1.getName()%></td>

                        <%

                        if (xdi2.hasNext()) {
                            Xdb x2 = (Xdb) xdi2.next();
                        %>
                            <td><input type="checkbox" name="x" value="<%=x2.getKey()%>" <% if (req.isInParameterValues("x",x2.getKey() + "")) out.print("checked"); %>></td>
                            <td><%=x2.getName()%></td>
                        <% } %>

                    <%

                    if (xdi3.hasNext()) {
                        Xdb x3 = (Xdb) xdi3.next();
                    %>
                        <td><input type="checkbox" name="x" value="<%=x3.getKey()%>" <% if (req.isInParameterValues("x",x3.getKey() + "")) out.print("checked"); %>></td>
                        <td><%=x3.getName()%></td>
                    <% } %>
                    </tr>
                    <% } %>
                </table>


            </td>
            <td>&nbsp;</td>
            <td valign="top" align="center">

                <table border="0" cellspacing=4 cellpadding=0 class="gaTable">
                    <tr>
                        <td class="gaLabel" colspan="2">Select Orthologs &nbsp;&nbsp;<a href="javascript:void(0);" style="color:#4088b8;" onclick="toggle('ortholog')"/>(toggle)</a></td>
                    </tr>

                    <% if (!req.getParameter("species").equals("1")) { %>
                    <tr>
                        <td><input type="checkbox" name="ortholog"
                                   value="1" <% if (req.isInParameterValues("ortholog","1")) out.print("checked"); %>>
                        </td>
                        <td> Human</td>
                    </tr>
                    <% } %>

                    <% if (!req.getParameter("species").equals("3")) { %>
                    <tr>
                        <td><input type="checkbox" name="ortholog"
                                   value="3" <% if (req.isInParameterValues("ortholog","3")) out.print("checked"); %>>
                        </td>
                        <td> Rat</td>
                    </tr>
                    <% } %>

                    <% if (!req.getParameter("species").equals("2")) { %>
                    <tr>
                        <td><input type="checkbox" name="ortholog"
                                   value="2" <% if (req.isInParameterValues("ortholog","2")) out.print("checked"); %>>
                        </td>
                        <td> Mouse</td>
                    </tr>
                    <% } %>

                    <% if (!req.getParameter("species").equals("4")) { %>
                    <tr>
                        <td><input type="checkbox" name="ortholog"
                                   value="4" <% if (req.isInParameterValues("ortholog","4")) out.print("checked"); %>>
                        </td>
                        <td> Chinchilla</td>
                    </tr>
                    <% } %>
                    <% if (!req.getParameter("species").equals("5")) { %>
                    <tr>
                        <td><input type="checkbox" name="ortholog"
                                   value="5" <% if (req.isInParameterValues("ortholog","5")) out.print("checked"); %>>
                        </td>
                        <td> Bonobo</td>
                    </tr>
                    <% } %>
                    <% if (!req.getParameter("species").equals("6")) { %>
                    <tr>
                        <td><input type="checkbox" name="ortholog"
                                   value="6" <% if (req.isInParameterValues("ortholog","6")) out.print("checked"); %>>
                        </td>
                        <td> Dog</td>
                    </tr>
                    <% } %>
                    <% if (!req.getParameter("species").equals("7")) { %>
                    <tr>
                        <td><input type="checkbox" name="ortholog"
                                   value="7" <% if (req.isInParameterValues("ortholog","7")) out.print("checked"); %>>
                        </td>
                        <td> Squirrel</td>
                    </tr>
                    <% } %>
                    <% if (!req.getParameter("species").equals("9")) { %>
                    <tr>
                        <td><input type="checkbox" name="ortholog"
                                   value="9" <% if (req.isInParameterValues("ortholog","9")) out.print("checked"); %>>
                        </td>
                        <td> Pig</td>
                    </tr>
                    <% } %>
                    <% if (!req.getParameter("species").equals("13")) { %>
                    <tr>
                        <td><input type="checkbox" name="ortholog"
                                   value="13" <% if (req.isInParameterValues("ortholog","13")) out.print("checked"); %>>
                        </td>
                        <td> Green Monkey</td>
                    </tr>
                    <% } %>
                    <% if (!req.getParameter("species").equals("14")) { %>
                    <tr>
                        <td><input type="checkbox" name="ortholog"
                                   value="14" <% if (req.isInParameterValues("ortholog","14")) out.print("checked"); %>>
                        </td>
                        <td> Naked Mole-Rat</td>
                    </tr>
                    <% } %>
                </table>

                <br><br><br>
                <input type="submit" value="Submit"/>

            </td>
        </tr>


    </table>
    <input type="submit" value="Submit"/>
    <input type="hidden" name="genes" value="<%=req.getParameter("genes")%>"/>
    <input type="hidden" name="chr" value="<%=req.getParameter("chr")%>"/>
    <input type="hidden" name="start" value="<%=req.getParameter("start")%>"/>
    <input type="hidden" name="stop" value="<%=req.getParameter("stop")%>"/>
    <input type="hidden" name="mapKey" value="<%=req.getParameter("mapKey")%>"/>


</form>

   <script>
       toggle("o");
       toggle("x");
       toggle("ortholog");
   </script>

</body>
</html>
