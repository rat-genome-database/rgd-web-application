<%@ page import="edu.mcw.rgd.datamodel.annotation.GeneWrapper" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.MathContext" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.TermWithStats" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Ontology" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Aspect" %>
<%@ page import="edu.mcw.rgd.web.*" %>
<%@ page import="java.util.*" %>

<%@ include file="gaHeader.jsp" %>

 <%
 try {
    ArrayList passedAspects = new ArrayList();
    if (!req.getParameter("aspect").equals("")) {
        passedAspects.add(req.getParameter("aspect"));
    }
    /*
    int slimId = -1;
    if (req.getParameter("aspect").equals("E")) {
       slimId=1;
    }
    */
     LinkedHashMap<String,Integer> geneCounts=  adao.getGeneCounts(om.getMappedRgdIds(), termSet, passedAspects);
     OntologyXDAO oDao = new OntologyXDAO();
 %>


<table cellpadding="2" cellspacing="2" width=550 border=0 style="background-color:#E6E6E6;">

<% if (geneCounts.size() == 0) { %>
    <tr><td>0 annotations found</td></tr>
<% } %>

<%
    int count=0;
    Iterator tit = geneCounts.keySet().iterator();
    while (tit.hasNext() && count++ < 200) {
        String acc = (String) tit.next();
        int refs = geneCounts.get(acc);
        BigDecimal genePercent = new BigDecimal(((double) refs / (double) om.getMappedRgdIds().size() * 100));
%>

    <tr>
        <td style="background-color:white;" >


        <div id="<%=acc%>" class="reportSection">

            <img id="<%=acc%>_i" src="/rgdweb/common/images/add.png"  />

            <%
                String term = "";
                try {
                   term = oDao.getTermByAccId(acc).getTerm();
                }catch (Exception e) {
                    e.printStackTrace();
                }
            %>


            &nbsp;&nbsp; <%=genePercent.round(new MathContext(4))%>% &nbsp;&nbsp;<b><%=term%></b> (<%=acc%>)

        </div>
            <div style='display:none;' id="<%=acc%>_content">
                <span style="color:red; font-weight:700; font-size:16px;">
                <br>Loading...  (please wait)<br><br>
                </span>
            </div>

            <script type="text/javascript">regHeader("<%=acc%>");</script>


    </td>
        <td style="background-color:white;" valign="top"><input type="checkbox" id="<%=acc%>" name="<%=acc%>" onclick="compare()"/></td>
    </tr>

    <%
    }
     %>



</table>

<% } catch (Exception e) {
    e.printStackTrace();
}
%>