<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermWithStats" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Ontology" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Record" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Condition" %>

<%@ include file="gaHeader.jsp" %>
<%@ include file="rgdHeader.jsp" %>
<%@ include file="menuBar.jsp" %>

<br>
<%
    OntologyXDAO xdao = new OntologyXDAO();

    Term term1 = xdao.getTermByAccId(request.getParameter("term1"));
    Term term2 = xdao.getTermByAccId(request.getParameter("term2"));

    int max = Integer.MIN_VALUE;

    Term xTerm = xdao.getTermByAccId(req.getParameter("term1"));
    Term yTerm = xdao.getTermByAccId(req.getParameter("term2"));
    List<TermWithStats> xTerms = xdao.getActiveChildTerms(xTerm.getAccId(),Integer.parseInt(req.getParameter("species")));
    List<TermWithStats> yTerms = xdao.getActiveChildTerms(yTerm.getAccId(),Integer.parseInt(req.getParameter("species")));

    ArrayList xAspects = new ArrayList();
    ArrayList yAspects = new ArrayList();
    Ontology xOnt = null;
    Ontology yOnt = null;

    List xAccIds=new ArrayList();
    for (TermWithStats t: xTerms) {
        xAccIds.add(t.getAccId());
    }

     //figure out which ontology this is
     if (xAccIds.size()>0) {
         xOnt = xdao.getOntologyFromAccId((String) xAccIds.get(0));
         xAspects.add(xOnt.getAspect());
     }

     List yAccIds=new ArrayList();
     for (TermWithStats t: yTerms) {
         yAccIds.add(t.getAccId());
     }

     if (yAccIds.size()>0) {
         yOnt = xdao.getOntologyFromAccId((String) yAccIds.get(0));
         yAspects.add(yOnt.getAspect());
     }

     yAspects.addAll(xAspects);

%>


<table align="center">
    <tr>
        <td align="center" style="font-style:italic;">Records Annotated to </td>
    </tr>
    <tr>
        <td align="center"><a href="<%=Link.ontAnnot(term1.getAccId())%>" target="_blank"><%=term1.getTerm()%></a>  (<%=term1.getAccId()%>)</td>
    </tr>
    <tr>
        <td align="center">and</td>
    </tr>
    <tr>
        <td align="center"><a href="<%=Link.ontAnnot(term2.getAccId())%>"  target="_blank"><%=term2.getTerm()%></a> (<%=term2.getAccId()%>)</td>
    </tr>
</table>


<%
try {
    int sid = 0;
    try {
        sid = Integer.parseInt("sid");
    }catch (Exception e) {
    }

    PhenominerDAO pdao = new PhenominerDAO();
    List records = pdao.getRecords(xAccIds,yAccIds, req.getParameter("countType"), sid);
    %>

    <table>
    <tr>
        <td># of Animals</td>
        <td>Clinical Measurement</td>
        <td>Strain</td>
        <td>Sex</td>
        <td>Value</td>
        <td>Units</td>
        <td>Condition 1</td>
        <td>Condition 2</td>
    </tr>

    <%
    Iterator it = records.iterator();
    int i=1;
    while (it.hasNext()) {
        Record r = (Record) it.next();
    %>
       <tr>
           <td><%=r.getSample().getNumberOfAnimals()%></td>
           <td><%=xdao.getTerm(r.getClinicalMeasurement().getAccId()).getTerm()%></td>
           <td><%=xdao.getTerm(r.getSample().getStrainAccId()).getTerm()%></td>
           <td><%=r.getSample().getSex()%></td>
           <td><%=r.getMeasurementValue()%></td>
           <td><%=r.getMeasurementUnits()%></td>

           <% for (Condition c: r.getConditions())  { %>

                <td><%=xdao.getTerm(c.getOntologyId()).getTerm()%></td>

           <% } %>

       </tr>
    <%
    }
    %>
    </table>
    <%
}catch (Exception e) {
    e.printStackTrace();
}
%>


