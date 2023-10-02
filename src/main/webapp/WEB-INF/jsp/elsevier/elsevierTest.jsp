<%--
  Created by IntelliJ IDEA.
  User: pjayaraman
  Date: 3/6/12
  Time: 2:17 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page import="edu.mcw.rgd.dao.impl.ReferenceDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Reference" %>
<%@ page import="edu.mcw.rgd.elsevier.ElsevierImageGenerator" %>

<%
    String pageTitle = "Rat Genome Database Test";
    String headContent = "Rat Genome Database Test";
    String pageDescription = "Rat Genome Database Test";
    //List<String> pwList = new ArrayList<String>();

    ReferenceDAO refDao = new ReferenceDAO();
    String doi = (String) request.getAttribute("doi");
    Reference ref = refDao.getReferenceByDOI(doi);
    ElsevierImageGenerator eig = new ElsevierImageGenerator();
%>

<h3>RGD Reference Object:</h3>
<%
    //System.out.println("here is the doi:" + doi);
    //out.print("here is the doi: " + doi);
%>
<%--<table>
    <tr>
        <td>
            <img src="http://www.sciencedirect.com/science/page/jcover/elsevier.gif" alt="Elsevier">
        </td>
    </tr>
</table>--%>

<table>
    <tr>
        <td>
            <a href="/rgdweb/elsevier/getReference.html?doi=<%=doi%>&type=redirect"><img src="/rgdweb/elsevier/rgdLogo.png?doi=<%=doi%>" alt=""></a>
        </td>
    </tr>
</table>