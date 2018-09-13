<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermWithStats" %>
<%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.process.generator.GeneratorCommandParser" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="java.util.Iterator" %>

<%
    int mapKey = Integer.parseInt(request.getParameter("mapKey"));
    int speciesType= SpeciesType.getSpeciesTypeKeyForMap(mapKey);
    int oKey=Integer.parseInt(request.getParameter("oKey"));
    String accId=request.getParameter("accId");

    List<String> allGenes = new ArrayList<String>();
    ArrayList terms = new ArrayList();
    GeneratorCommandParser gcp = new GeneratorCommandParser(mapKey,oKey);
    allGenes.addAll(gcp.parse(accId));


    if (gcp.getLog().size() > 0) {
        //check for message
        Iterator it = gcp.getLog().keySet().iterator();
        String msg = (String) gcp.getLog().get(it.next());
        out.print(msg.replaceAll("<br>","\\\n"));
        return;

    }

    if (allGenes.size() == 0) {
        out.print("0 objects are annotated to this term or region.\\n\\nPlease select again.");
        return;
    }

%>

<div style="font-weight:700;width:200px;padding-bottom:5px;border-bottom: 1px solid black;">Preview Count: <%=allGenes.size()%></div>
<ul>
<% for (String g: allGenes) { %>
       <li><%=g%></li>
<% } %>
</ul>