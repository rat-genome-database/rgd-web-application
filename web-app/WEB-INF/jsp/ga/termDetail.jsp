<%@ page import="edu.mcw.rgd.datamodel.annotation.GeneWrapper" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Identifiable" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.OntologyEnrichment" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.TermWrapper" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.LinkedHashMap" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.web.UI" %>
<%

    //initializations
    HttpRequestFacade req = new HttpRequestFacade(request);
    DisplayMapper dm = new DisplayMapper(req,  new java.util.ArrayList());
    FormUtility fu = new FormUtility();
    UI ui=new UI();
    AnnotationDAO adao = new AnnotationDAO();
    GeneDAO gdao = new GeneDAO();

    ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");
    List termSet= Utils.symbolSplit(req.getParameter("terms"));
    List<TermWrapper> termWrappers = new ArrayList();

    String method="get";

    if (Utils.symbolSplit(req.getParameter("genes")).size() > 250) {
        method="post";
    }

    LinkedHashMap aspects = new LinkedHashMap();
    aspects.put("D","Disease");
    aspects.put("W","Pathway");
    aspects.put("N","Phenotype");
    aspects.put("P","GO: Biological Process");
    aspects.put("C","GO: Cellular Component");
    aspects.put("F","GO: Molecular Function");
    aspects.put("E","Chemical Interactions");

    String acc = req.getParameter("acc");

    termSet=new ArrayList();
    termSet.add(acc);


    ArrayList passedAspects = new ArrayList();
    if (!req.getParameter("aspect").equals("")) {
        passedAspects.add(req.getParameter("aspect"));
    }

    OntologyEnrichment oe = adao.getOntologyEnrichment(om.getMappedRgdIds(), termSet, passedAspects);
    TermWrapper tw = null;
    //String acc = null;

    //Iterator tit = oe.getTermWrappers().keySet().iterator();
    //while (tit.hasNext()) {
        //acc = (String) tit.next();
        tw = (TermWrapper) oe.termMap.get(acc);
        //termWrappers.add(tw);
    //}
        %>


        <div id="<%=tw.getTerm().getAccId()%>_content" style="background-color:#F0F6F9;padding:3px;">
        <table border=0  style="padding:3px; margin: 2px;">

        <%
            Iterator git = tw.refs.iterator();
            boolean first = true;
            String genes="";
            while (git.hasNext()) {
                GeneWrapper gw = (GeneWrapper) git.next();
                if (first) {
                    genes += gw.getGene().getSymbol();
                    first=false;
                }else {
                    genes += "," + gw.getGene().getSymbol();
                }
            }

        %>

        <tr><td align="right" colspan=2><a href="javascript:explore('<%=genes%>')">Explore this Gene Set</a>&nbsp;&nbsp;</td></tr>
        <%

        git = tw.refs.iterator();
        while (git.hasNext()) {
            GeneWrapper gw = (GeneWrapper) git.next();
            Iterator bIt = gw.getRoots(tw).iterator();
            String terms = "";

            first = true;
            while (bIt.hasNext()) {
                Term baseTerm = (Term) bIt.next();
                if (first) {
                    terms += baseTerm.getTerm() + "";
                    first=false;
                }else {
                    terms += "&nbsp;:&nbsp; " + baseTerm.getTerm();
                }

            }
            if (terms.length()!=0) {
                terms="(" + terms + ")";
            }
         %>
            <tr><td>&nbsp;&nbsp;</td><td valign="top"><a onclick="geneList('<%=gw.getGene().getRgdId()%>')" href="javascript:void(0)"><%=gw.getGene().getSymbol()%></a>&nbsp;<%=terms%></td></tr>
        <%
        }
        %>
        </table>
       </div>
