<%@ page import="edu.mcw.rgd.models.GenesDB" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %><%
    GenesDB db= null;
    try {
        db = new GenesDB();
    } catch (Exception e) {
        e.printStackTrace();
    }
    String query= (String) request.getAttribute("q");
   List<String> genes= null;
    try {
        genes = db.getGenes(query);
    } catch (Exception e) {
        e.printStackTrace();
    }
    System.out.println(genes.size());
    Iterator iterator= genes.iterator();



    Gson gson= new Gson();
    String geneList= gson.toJson(genes);
    response.getWriter().write(geneList);

%>