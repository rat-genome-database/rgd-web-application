<%--
  Created by IntelliJ IDEA.
  User: pjayaraman
  Date: 3/6/12
  Time: 2:17 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page import="edu.mcw.rgd.dao.impl.ReferenceDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.ontology.Annotation" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="com.google.gson.JsonParser" %>
<%@ page import="com.google.gson.JsonSerializationContext" %>

<%
    String pageTitle = "Rat Genome Database Test PMID webservice";
    String headContent = "Rat Genome Database Test PMID webservice";
    String pageDescription = "Rat Genome Database Test PMID webservice";
    //List<String> pwList = new ArrayList<String>();

    List<Annotation> annotObjs = (ArrayList<Annotation>) request.getAttribute("annots");
    String jsonParam = (String) request.getAttribute("jsonP");

    response.setHeader("Access-Control-Allow-Origin", "*.mcw.edu");
    //request.getRequestDispatcher("refAnnots.jsp").include(request, response);
    //response.setHeader("Access-Control-Allow-Origin", "*.mcw.edu");
    //ArrayList errorList = (ArrayList) request.getAttribute("error");

%>


<!--<h3>RGD Reference Object:</h3>-->



    <%
        if((annotObjs!=null) && (annotObjs.size()>0)){
            String fulldataSet="\"data\" : \"";
            for(Annotation a : annotObjs){
                String data = a.getObjectSymbol()+"|"+a.getAnnotatedObjectRgdId()+"|"+a.getTermAcc()+"|"+a.getTerm()+"|"+a.getEvidence()+"|"+a.getQualifier()+"|"+SpeciesType.getCommonName(a.getSpeciesTypeKey())+"~";
                fulldataSet+=data;
    %>
    <%
            }
            fulldataSet+="\"";
            out.println(jsonParam+"({"+fulldataSet+"});");
        }else{
            out.println(jsonParam+"({\"data\" : \"ERROR\"});");
        }

    %>
