<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.datamodel.ontology.Annotation" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.process.describe.DescriptionGenerator" %>
<%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.Map" %>
<%@ page import="edu.mcw.rgd.report.DaoUtils" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Aspect" %>


<%@ include file="gaHeader.jsp" %>


<%
    RGDManagementDAO mdao = new RGDManagementDAO();
    RgdId id = mdao.getRgdId(Integer.parseInt(req.getParameter("rgdId")));

    String symbol="";
    String objectType="";
    String description="";
    String geneType="";

    List orthologs = new ArrayList();
    Map orthoMap = new HashMap();

    if (id.getObjectKey() == 1) {
        Gene g = gdao.getGene(id.getRgdId());
        symbol = g.getSymbol();
        objectType="Gene";
        geneType=g.getType();

        if (g.getSpeciesTypeKey() == 1) {
            description="<span style='color:#771428; font-weight:700; font-size:12px;'>" + g.getSymbol() + "</span> : " + g.getDescription();
        }else {
            DescriptionGenerator dg = new DescriptionGenerator();
            description= "<span style='color:#771428; font-weight:700; font-size:12px;'>" + g.getSymbol() + "</span> : " +  dg.buildDescription(id.getRgdId());
        }


        orthologs = gdao.getActiveOrthologs(id.getRgdId());
        List<String> orthologKeys=req.getParameterValues("ortholog");
        orthoMap =new HashMap();

        try {

            for (String key : orthologKeys) {
                orthoMap.put(Integer.parseInt(key), null);
            }
        }catch (Exception e) {
            for (Integer sKey: SpeciesType.getSpeciesTypeKeys()) {
                if (sKey != g.getSpeciesTypeKey()) {
                    orthoMap.put(sKey, null);
                }
            }

        }

    }

%>

<%

 %>

<div style="width: 95%; font-size:11px; padding: 6px;"><%=description%></div>


<table border=0  class="gaTable" width='95%'>
    <tr>
       <td valign="top">

<table border=0  class="gaTable">
    <tr>
        <td>

<table class="gaTable">
<tr>
    <td class="gaLabel"><%=objectType%> Symbol:</td>
    <td><%=symbol%></td>
</tr>
    <tr>
        <td class="gaLabel"><%=RgdContext.getSiteName(request)%> ID:</td>
        <td><%=id.getRgdId()%></td>
    </tr>
    <%if(geneType!=null){%>
    <tr>
        <td class="gaLabel">Gene Type:</td>
        <td><%=geneType%></td>
    </tr>
    <%}%>
    <tr>
        <td class="gaLabel">Species:</td>
        <td><%=SpeciesType.getCommonName(id.getSpeciesTypeKey())%></td>
    </tr>
    <tr>
        <td class="gaLabel">Link to <%=objectType%> Report</td>
        <td><a href="<%=Link.it(id.getRgdId())%>"><%=RgdContext.getSiteName(request)%></a></td>
    </tr>
</table>

</td>

<%
    //only genes have orthologs
    if (id.getObjectKey() == 1) {
        Iterator it = orthologs.iterator();
        while (it.hasNext()) {
            Gene ortho = (Gene) it.next();
            if (orthoMap.containsKey(ortho.getSpeciesTypeKey())) {
    %>
        <td>
            <table class="gaTable">

            <tr>
                <td class="gaLabel"><%=SpeciesType.getCommonName(ortho.getSpeciesTypeKey())%> Ortholog:</td>
                <td><%=ortho.getSymbol()%></td>
            </tr>
            <tr>
                <td class="gaLabel">Ortholog <%=RgdContext.getSiteName(request)%> ID:</td>
                <td><%=ortho.getRgdId()%></td>
            </tr>
                <tr>
                    <td class="gaLabel">Gene Type:</td>
                    <td><%=ortho.getType()%></td>
                </tr>
            <tr>
                <td class="gaLabel">Species:</td>
                <td><%=SpeciesType.getCommonName(ortho.getSpeciesTypeKey())%></td>
            </tr>
            <tr>
                <td class="gaLabel">Link to Gene Page</td>
                <td><a href="<%=Link.gene(ortho.getRgdId())%>"><%=RgdContext.getSiteName(request)%></a></td>
            </tr>
            </table>
        </td>
    <% }
    } %>

        <% if (orthologs.size()==0) { %>
            <td><span style='color:red;'>No Orthologs Found</span></td>
         <% }%>
      <% }%>
</tr>
    </table>


<table style="border: 0px solid black;">
    <tr>
        <td><div style="padding-top:10px; font-weight:700; font-size:18px">{ Annotations }</div></td>
    </tr>
</table>
<%



    orthologs.add(0,id);

    List<String> ontologies = req.getParameterValues("o");

    for (String asp: ontologies) {
        int count=0;

 %>
    <%
        Iterator it = orthologs.iterator();
        while (it.hasNext()) {
            Identifiable ortho = (Identifiable) it.next();
            Speciated spc = (Speciated) ortho;

            if(spc.getSpeciesTypeKey() == SpeciesType.HUMAN
                    && asp.equalsIgnoreCase(Aspect.MAMMALIAN_PHENOTYPE))
                asp = Aspect.HUMAN_PHENOTYPE;
            else if(spc.getSpeciesTypeKey() != SpeciesType.HUMAN
                    && asp.equalsIgnoreCase(Aspect.HUMAN_PHENOTYPE))
                asp = Aspect.MAMMALIAN_PHENOTYPE;


            List<Annotation> annotList=adao.getAnnotationsByAspect(ortho.getRgdId(),asp);

            Annotation lastAnnot = null;
            HashSet seen= new HashSet();


            for (Annotation annot: annotList) {

                if(annot.getAspect().equalsIgnoreCase(Aspect.HUMAN_PHENOTYPE))
                    annot.setAspect(Aspect.MAMMALIAN_PHENOTYPE);

                if (seen.contains(spc.getSpeciesTypeKey() + annot.getTermAcc())) {
                    continue;
                }

                if (lastAnnot != null && (lastAnnot.getAnnotatedObjectRgdId().equals(annot.getAnnotatedObjectRgdId()) && lastAnnot.getTermAcc().equals(annot.getTermAcc()) && lastAnnot.getEvidence().equals(annot.getEvidence()) && lastAnnot.getRefRgdId().equals(annot.getRefRgdId()))) {
                    continue;
                }

                if (count==0) {

    %>
                <br><div style="font-size:12px; font-weight:700"><%=aspects.get(annot.getAspect())%></div>

                 <table border=0  class="gaTable" width=1100px>
                <tr>
                    <td class="gaLabel">Species</td>
                    <td class="gaLabel">Accession</td>
                    <td class="gaLabel">Term</td>
                    <td class="gaLabel">Reference / Evidence</td>
                    <!--<td class="gaLabel">Reference</td>-->
                </tr>
                 <%
                    aspects.put(annot.getAspect(), null);
                }
                count++;

                if (spc.getSpeciesTypeKey() == id.getSpeciesTypeKey() || orthoMap.containsKey(spc.getSpeciesTypeKey())) {

                    String bgColor="#FFFFFF";
                    String textColor = "black";
//                    if (spc.getSpeciesTypeKey() == 1) {
//                        bgColor="#eeeeee";
//                    }else if (spc.getSpeciesTypeKey()==2) {
//                        bgColor="#cccccc";
//                    }else {
//
//                    }
                    switch (spc.getSpeciesTypeKey()){
                        case SpeciesType.HUMAN:
                            bgColor="#eeeeee";
                            textColor = "black";
                            break;
                        case SpeciesType.MOUSE:
                            bgColor="#cccccc";
                            textColor = "black";
                            break;
                        case SpeciesType.RAT:
                            bgColor="#aaaaaa";
                            textColor = "black";
                            break;
                        case SpeciesType.CHINCHILLA:
                            bgColor="#71797E";
                            textColor = "white";
                            break;
                        case SpeciesType.BONOBO:
                            bgColor="#E8E8E8";
                            textColor = "black";
                            break;
                        case SpeciesType.DOG:
                            bgColor="#888888";
                            textColor = "black";
                            break;
                        case SpeciesType.SQUIRREL:
                            bgColor="#7393B3";
                            textColor = "white";
                            break;
                        case SpeciesType.ZEBRAFISH:
                            bgColor="#C8C8C8";
                            textColor = "black";
                            break;
                        case SpeciesType.PIG:
                            bgColor="#696969";
                            textColor = "white";
                            break;
                        case SpeciesType.FRUITFLY:
                            bgColor="#E5E4E2";
                            textColor = "black";
                            break;
                        case SpeciesType.ROUNDWORM:
                            bgColor="#E0E0E0";
                            textColor = "black";
                            break;
                        case SpeciesType.VERVET:
                            bgColor="#989898";
                            textColor = "black";
                            break;
                        case SpeciesType.NAKED_MOLE_RAT:
                            bgColor="#B0B0C0";
                            textColor = "black";
                            break;
                        default:
                            bgColor="#aaaaaa";
                            textColor = "black";
                            break;
                    }


                 %>

                <tr >
                    <td style="background-color:<%=bgColor%>; color: <%=textColor%>"><%=SpeciesType.getCommonName(spc.getSpeciesTypeKey())%></td>
                    <td><a href="/rgdweb/ontology/annot.html?acc_id=<%=annot.getTermAcc()%>"><%=annot.getTermAcc()%></a></td>
                    <td><%=annot.getTerm()%></td>
                    <td ><a href="/rgdweb/report/annotation/main.html?term=<%=annot.getTermAcc()%>&id=<%=ortho.getRgdId()%>"><%=annot.getEvidence()%></a></td>
                    <!--<td><a href="<%=Link.ref(annot.getRefRgdId())%>"><%=annot.getRefRgdId()%></a></td>-->
                </tr>
           <%
                seen.add(spc.getSpeciesTypeKey() + annot.getTermAcc());

              }
               lastAnnot = annot;
           }
        }
        %>

 <%
     if (count > 0) out.print("</table>");
%>
   <% } %>

    <%
        Iterator it = aspects.keySet().iterator();
        while (it.hasNext()) {
            String key= (String) it.next();
            String value=(String) aspects.get(key);
            if (value != null && req.isInParameterValues("o", key)) {
                out.print("<br><span style='color:red;'>" + value + " annotations not found.</span><br>");
            }
        }

     %>

</td><td>



<table width=100  class="gaTable" align="center">
    <tr><td colspan=3 class="gaLabel">External Links</td><td>Source(s)</td></tr>
<%
    List<XdbId> xdbids;

    if (req.getParameterValues("x").size() > 0) {
        xdbids = DaoUtils.getInstance().getExternalDbLinksForGATool(req.getParameterValues("x"), id.getRgdId());
    }
    else
        xdbids = Collections.emptyList();

    XDBIndex xdb = XDBIndex.getInstance();
    if (xdbids.size()==0) {
%>
        <tr><td>NONE</td></tr>

    <% } %>
    <%
        for (XdbId xdbId: xdbids) {
            String link = xdb.getXDB(xdbId.getXdbKey()).getSpeciesURL(id.getSpeciesTypeKey())+xdbId.getAccId();
    %>
            <tr>
                <td><%=xdb.getXDB(xdbId.getXdbKey()).getName()%></td>
                <td><%=xdbId.getAccId()%></td>
                <td><a href="<%=link%>">Link</a></td>
                <td><%=xdbId.getSrcPipeline()%></td>
            </tr>
    <%  } %>

</table>

</td></tr>
</table>
