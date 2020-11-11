<%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>

<%@ page import="edu.mcw.rgd.ontology.OntAnnotBean" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.List" %>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<% try { %>

<style>
    .gaLabel {
        font-weight:700;
        color:#3F3F3F;
    }

    .gaLabelHeader {
        font-weight:700;
        color:#3F3F3F;
        background-color:#D8D8DB;
    }
    .gaTable{
        background-color: #E6E6E6;
        border: 1px solid #c8c8c8;
    }

    h1, h2, h3, h4, h5, h6 {
        font-family: Georgia, "Times New Roman", Times, serif;
        color:#4088b8;
        clear: both;
        font-weight:700;
    }

    #wrap {
        color: #404040;
        /*margin: 0 12%;*/
        margin: 20px 40px;
    }


    ul, ol {
        margin-left 0;
    }

    ul ul {
        margin-bottom: 20px;
    }

    a {
        color: #4088b8;
    }
    .gaTable td, .gaTable a, .gaTable input, .gaTable option{
       font-size:11px;
       background: #f8f8f8;
       font-family:Arial;
       color:#3F3F3F;
            background: #f8f8f8;
    text-align: left;
    padding: 5px;
    vertical-align: top;
    }
</style>


<link rel="stylesheet" type="text/css" href="/rgdweb/common/search.css">
<link rel="stylesheet" type="text/css" href="/rgdweb/css/ontology.css">

<%
   String pageDescription="hello";
   String pageTitle="hello";
   String headContent="";
%>

<%@ include file="headerarea.jsp" %>

<table border=0>
    <tr>
        <td valign="top" width=250>
            <%@ include file="menu.jsp" %>
        </td>
        <td valign="top">
            <div id="content" style="padding:5px;">

<%
    Term oterm = xdao.getTerm(req.getParameter("term"));
    int annotationTotal = adao.getAnnotationCount(oterm.getAccId(),true);
    int objectTotal =  adao.getAnnotatedObjectCount(oterm.getAccId(),true);

%>


<div style="font-size:25px;"><%=oterm.getTerm()%></div>

<% if (oterm.getDefinition() != null) {%>
    <div style="font-size:10px;"><%=oterm.getDefinition()%></div>
<% } %>

<br>
<div style="background-color: #E6E6E6; color: #0c1d2e;font-weight:700;">Annotation Summary</div>

<table>
    <tr>
        <td colspan=5><b><%=annotationTotal%></b> Annotations have been made to <b><%=objectTotal%></b> Objects</td>
    </tr>

</table>

<table>
    <tr>
        <td>
            <table border=0 class="gaTable">
                <tr>
                    <td colspan="5" style="font-weight:700;font-size:14px;">Rat</td>
                </tr>
                <tr>
                    <% int objectCount=adao.getAnnotatedObjectCount(req.getParameter("term"), true, 3, 1); %>
                    <td>Genes</td><td><span style="font-weight:700;font-size:12px;"><%=objectCount%></span></td>
                    <% if (objectCount > 0) {%>
                        <td><a href="objects.jsp?term=<%=req.getParameter("term")%>&species=Mouse&key=<%=key%>">(View)</a></td><td><a href="">(Download)</a><td><a href="">(Annotate)</a></td>
                    <% } else { %>
                       <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                    <% }%>
                    </td>
                </tr>
                <tr>
                    <% objectCount=adao.getAnnotatedObjectCount(req.getParameter("term"), true, 3, 6); %>
                    <td>QTLs</td><td><span style="font-weight:700;font-size:12px;"><%=objectCount%></span></td>
                    <% if (objectCount > 0) {%>
                        <td><a href="">(View)</a></td><td><a href="">(Download)</a><td><a href="">(Annotate)</a></td>
                    <% } else { %>
                       <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                    <% }%>
                    </td>
                </tr>
                </tr>
                <tr>
                    <% objectCount=adao.getAnnotatedObjectCount(req.getParameter("term"), true, 3, 5); %>
                    <td>Strains</td><td><span style="font-weight:700;font-size:12px;"><%=objectCount%></span></td>

                    <% if (objectCount > 0) {%>
                        <td><a href="">(View)</a></td><td><a href="">(Download)</a><td><a href="">(Annotate)</a></td>
                    <% } else { %>
                       <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                    <% }%>
                    </td>
                </tr>
            </table>
        </td>
                <td>
            <table border=0 class="gaTable">
                <tr>
                    <td colspan="5" style="font-weight:700;font-size:14px;">Human</td>
                </tr>
                <tr>
                    <%  objectCount=adao.getAnnotatedObjectCount(req.getParameter("term"), true, 1, 1); %>
                    <td>Genes</td><td><span style="font-weight:700;font-size:12px;"><%=objectCount%></span></td>
                    <% if (objectCount > 0) {%>
                        <td><a href="">(View)</a></td><td><a href="">(Download)</a><td><a href="">(Annotate)</a></td>
                    <% } else { %>
                       <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                    <% }%>
                    </td>
                </tr>
                <tr>
                    <% objectCount=adao.getAnnotatedObjectCount(req.getParameter("term"), true, 1, 6); %>
                    <td>QTLs</td><td><span style="font-weight:700;font-size:12px;"><%=objectCount%></span></td>

                    <% if (objectCount > 0) {%>
                        <td><a href="">(View)</a></td><td><a href="">(Download)</a><td><a href="">(Annotate)</a></td>
                    <% } else { %>
                       <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                    <% }%>
                    </td>
                </tr>
                </tr>
                <tr>
                    <td style="background-color:#E6E6E6;">&nbsp;</td>
                </tr>
            </table>
        </td>
                <td>
            <table border=0 class="gaTable">
                <tr>
                    <td colspan="5" style="font-weight:700;font-size:14px;">Mouse</td>
                </tr>
                <tr>
                    <%  objectCount=adao.getAnnotatedObjectCount(req.getParameter("term"), true, 2, 1); %>
                    <td>Genes</td><td><span style="font-weight:700;font-size:12px;"><%=objectCount%></span></td>
                    <% if (objectCount > 0) {%>
                        <td><a href="">(View)</a></td><td><a href="">(Download)</a><td><a href="">(Annotate)</a></td>
                    <% } else { %>
                       <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                    <% }%>
                    </td>
                </tr>
                <tr>
                    <% objectCount=adao.getAnnotatedObjectCount(req.getParameter("term"), true, 2, 6); %>
                    <td>QTLs</td><td><span style="font-weight:700;font-size:12px;"><%=objectCount%></span></td>

                    <% if (objectCount > 0) {%>
                        <td><a href="">(View)</a></td><td><a href="">(Download)</a><td><a href="">(Annotate)</a></td>
                    <% } else { %>
                       <td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td>
                    <% }%>
                    </td>
                </tr>
                </tr>
                <tr>
                    <td style="background-color:#E6E6E6;">&nbsp;</td>
                </tr>
            </table>
        </td>
    </tr>
</table>

<br>
<div style="background-color: #E6E6E6; color: #0c1d2e;font-weight:700;">Gene Set Analysis</div>
<div style="font-size:12px;">Follow the links to view additional annotations to the genes annotated for each species</div>
<table class="gaTable">
    <tr>
        <%
            List orthologs = new ArrayList();
            orthologs.add("1");
            orthologs.add("2");

            List<Integer> ids =  adao.getAnnotatedObjectIds(oterm.getAccId(),true, 3, 1);
            List symbols = new ArrayList();
            for (Integer id: ids) {
                symbols.add(id + "");
            }

            List ontologies = new ArrayList();
            ontologies.add("W");

            List xdbs = new ArrayList();
            xdbs.add("23");
            xdbs.add("17");


        %>

        <td><a href="<%=Link.gaTool(3,ontologies,xdbs,orthologs,symbols,60)%>">Pathway Annotations</a> </td>

        <%
            ontologies = new ArrayList();
            ontologies.add("D");
            xdbs = new ArrayList();

        %>
        <td><a href="<%=Link.gaTool(3,ontologies,xdbs,orthologs,symbols,60)%>">Disease Annotations</a></td>
        <%
            ontologies = new ArrayList();
            ontologies.add("C");

            xdbs = new ArrayList();

        %>
        <td><a href="<%=Link.gaTool(3,ontologies,xdbs,orthologs,symbols,60)%>">Cellular Component Annotations</a></td>
    </tr>
    <tr>
        <%
            ontologies = new ArrayList();
            ontologies.add("F");

            xdbs = new ArrayList();

        %>
        <td><a href="<%=Link.gaTool(3,ontologies,xdbs,orthologs,symbols,60)%>">Molecular Function Annotations</a></td>
        <%
            ontologies = new ArrayList();
            ontologies.add("P");

            xdbs = new ArrayList();

        %>
        <td><a href="<%=Link.gaTool(3,ontologies,xdbs,orthologs,symbols,60)%>">Biological Process Annotations</a></td>
        <%
            ontologies = new ArrayList();
            ontologies.add("N");

            xdbs = new ArrayList();

        %>
        <td><a href="<%=Link.gaTool(3,ontologies,xdbs,orthologs,symbols,60)%>">Mammalian Phenotype Annotations</a></td>
    </tr>
</table>






            </div>
        </td>
    </tr>
</table>

<%@ include file="footerarea.jsp" %>


<% } catch (Exception e) {
    e.printStackTrace();

 } %>