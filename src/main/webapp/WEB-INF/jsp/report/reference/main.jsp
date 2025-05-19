<%@ page import="edu.mcw.rgd.reporting.SearchReportStrategy" %>
<%@ page import="edu.mcw.rgd.datamodel.Reference" %>
<%@ page import="dev.langchain4j.model.ollama.OllamaChatModel" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="java.net.http.HttpRequest" %>
<%@ page import="java.net.URI" %>
<%@ page import="java.time.Duration" %>
<%@ page import="java.net.http.HttpClient" %>
<%@ page import="java.net.http.HttpResponse" %>
<%@ page import="org.biojava.ontology.OntologyTerm" %>

<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 30, 2008
  Time: 4:19:11 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<%@ include file="../dao.jsp"%>

  <% boolean includeMapping = true; %>
<%
    String title = "References";

    Reference obj = (Reference) request.getAttribute("reportObject");
    String pageTitle = "RGD Reference Report - " + obj.getTitle() + " - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = obj.getCitation()!=null ? obj.getCitation() : "";


    // handling of RETIRED/WITHDRAWN references: rgd id history is searched for an active rgd id that possibly
    // replaced this retired/withdrawn object
    RgdId refRgdId = managementDAO.getRgdId(obj.getRgdId());
    boolean isRefStatusNotActive = !refRgdId.getObjectStatus().equals("ACTIVE");
    Reference newRef = null; // gene that replaced the current one
    if( isRefStatusNotActive ) {
        int newRgdId = managementDAO.getActiveRgdIdFromHistory(obj.getRgdId());

        if( newRgdId>0 )
            newRef = referenceDAO.getReference(newRgdId);
    }
%>

<div id="top" ></div>

<%@ include file="/common/headerarea.jsp"%>
<%@ include file="../reportHeader.jsp"%>
<script>
    let reportTitle = "reference";
</script>

<script>


    function loadData(pmid,entity) {
        //var url = '/rgdweb/webservice/entity.html?pmid=' + pmid + '&entity=' + entity;

        fetch('/rgdweb/webservice/entity.html?pmid=' + pmid + '&entity=' + entity)
            .then(response => {
                if (!response.ok) {
                    throw new Error("Network response was not ok");
                }
                return response.text(); // or response.json() if you're expecting JSON
            })
            .then(data => {

                //console.log(data);
                var thinkMatch = data.match(/<think>([\s\S]*?)<\/think>/);
                //console.log(thinkMatch);
                var thinkText = thinkMatch ? thinkMatch[1].trim() : "";
                //console.log (thinkText);
                var afterThink = data.replace(/<think>[\s\S]*?<\/think>/, "").trim();

                document.getElementById(entity + "Div").style.display = "block";
                document.getElementById(entity + "Think").style.display = "block";
                document.getElementById(entity + "Div").innerHTML = afterThink;
                document.getElementById(entity + "Think").innerHTML = thinkText;
            })
            .catch(error => {
                document.getElementById(entity + "Div").innerHTML = 'Error loading content: ' + error;
            });
    }
</script>




<div id="page-container">

    <div id="left-side-wrap">
        <%@ include file="../reportSidebar.jsp"%>
    </div>



    <div id="content-wrap">

<%@ include file="menu.jsp"%>

<% if (view.equals("2")) { %>

<% } else if (isRefStatusNotActive) { %>
    <br><br>The reference with citation <%=obj.getCitation()%> (RGD ID: <%=obj.getRgdId()%>) has been <%=refRgdId.getObjectStatus()%>. <br><br>
    <% if(newRef!=null ) { %>
      This reference has been replaced by the reference <a href="<%=edu.mcw.rgd.reporting.Link.ref(newRef.getRgdId())%>" title="click to see the gene report"><%=newRef.getCitation()%> (RGD ID: <%=newRef.getRgdId()%>)</a>.
     <br><br>
    <%}%>
<% } else { %>



<table width="95%" border="0">
    <tr>
        <td>
            <%@ include file="info.jsp"%>

<%
/*
        String paper = PubmedFetcher.fetchPMCFullTextXML("21995344");

        String body = XMLBodyExtractor.extractBodyText(paper);

        System.out.println(body);

        String paperText = "<abstract> " + obj.getRefAbstract() + "</abstract>\n" + body;
*/
%>

    <%
        /*
                OllamaChatModel model = OllamaChatModel.builder()
                        .baseUrl("http://grudge.rgd.mcw.edu:11434") // Ollama's default port
                        .modelName("rgddeepseek70") // Replace with your downloaded model
                        .build();

                String prompt = "Extract the gene symbol for any gene discussed in the following paper. Each genes should only show up once in the return list.  The maximum number of symbols returned should be 100.  If you fine more than 100, please return the first 100 found. <paper>"  + paperText+ "</paper> respond with a pipe delimited list of <symbol> and no other output";
                String genes = model.generate(prompt);


                model = OllamaChatModel.builder()
                        .baseUrl("http://grudge.rgd.mcw.edu:11434") // Ollama's default port
                        .modelName("rgddeepseek70") // Replace with your downloaded model
                        .build();
                prompt = "Extract the Disease ontology Terms for any disease discussed in the following paper. Each disease should only show up once in the return list.  The maximum number of terms returned should be 100.  If you fine more than 100, please return the first 100 found. <paper> " + paperText+ "<paper> respond with a pipe delimited list of symbols and no other output";
                String diseases = model.generate(prompt);
*/
/*
                prompt = "Extract the <Biological Process Terms> for any Biological Processes discussed in the following abstract. The maximum number of terms returned should be 100.  If you fine more than 100, please return the first 100 found.  <abstract>" + obj.getRefAbstract() + "</abstract> respond with a pipe delimited list of <symbol> and no other output";
                String bp = model.generate(prompt);

                prompt = "Extract the <CHEBI chemical terms> for any chemical discussed in the following abstract. The maximum number of terms returned should be 100.  If you fine more than 100, please return the first 100 found.  <abstract>" + obj.getRefAbstract() + "</abstract> respond with a pipe delimited list of <symbol> and no other output";
                String chebi = model.generate(prompt);

                prompt = "Extract the <Sequnece Ontology terms> for any Sequence Ontology in the following abstract. The maximum number of terms returned should be 100.  If you fine more than 100, please return the first 100 found.  <abstract>" + obj.getRefAbstract() + "</abstract> respond with a pipe delimited list of <symbol> and no other output";
                String so = model.generate(prompt);

                prompt = "Extract the <Biological Pathway terms> for any biological pathway in the following abstract. The maximum number of terms returned should be 100.  If you fine more than 100, please return the first 100 found.  <abstract>" + obj.getRefAbstract() + "</abstract> respond with a pipe delimited list of <symbol> and no other output";
                String pw = model.generate(prompt);

                prompt = "Extract the <Anatomy terms> in the following abstract. The maximum number of terms returned should be 100.  If you fine more than 100, please return the first 100 found.  <abstract>" + obj.getRefAbstract() + "</abstract> respond with a pipe delimited list of <symbol> and no other output";
                String ma = model.generate(prompt);

                prompt = "Extract the <Phenotype terms> in the following abstract. The maximum number of terms returned should be 100.  If you fine more than 100, please return the first 100 found.  <abstract>" + obj.getRefAbstract() + "</abstract> respond with a pipe delimited list of <symbol> and no other output";
                String mp = model.generate(prompt);
*/
                OntologyTermMatcher otm = new OntologyTermMatcher();

                List<XdbId> pIds = xdbDAO.getXdbIdsByRgdId(2, obj.getRgdId());
                String pId = "";
                if (pIds.size() > 0) {
                    pId = pIds.get(0).getAccId();
                }
            %>

            <br>
            <div style="border:2px solid black;padding:5px;">
                AI Assistant<br><br>

                <table>
                    <tr>
                        <td><b>Genes:</b></td>
                        <td>
                            <button onclick="loadData('<%=pId%>','gene')">Load Content</button>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <div id="geneDiv" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div><br>
                            <div id="geneThink" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div>

                        </td>
                    </tr>
                    <tr>
                        <td><b>Diseases:</b></td>
                        <td>
                            <button onclick="loadData('<%=pId%>','do')">Load Content</button>
                        </td>
                    </tr>
                    <tr>
                    <td colspan="2">
                            <div id="doDiv" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div><br>
                            <div id="doThink" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div>
                        </td>
                    </tr>
                    <tr>
                        <td><b>GO Biological Process:</b></td>
                        <td>
                            <button onclick="loadData('<%=pId%>','bp')">Load Content</button>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <div id="bpDiv" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div><br>
                            <div id="bpThink" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div>
                        </td>
                    </tr>
                    <tr>
                        <td><b>CHEBi:</b></td>
                        <td>
                            <button onclick="loadData('<%=pId%>','chebi')">Load Content</button>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <div id="chebiDiv" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div><br>
                            <div id="chebiThink" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div>
                        </td>
                    </tr>
                    <tr>
                        <td><b>Sequence Ontology:</b></td>
                        <td>
                            <button onclick="loadData('<%=pId%>','so')">Load Content</button>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <div id="soDiv" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div><br>
                            <div id="soThink" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div>

                        </td>
                    </tr>
                    <tr>
                        <td><b>Pathway Ontology:</b></td>
                        <td>
                            <button onclick="loadData('<%=pId%>','pw')">Load Content</button>

                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <div id="pwDiv" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div><br>
                            <div id="pwThink" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div>

                        </td>
                    </tr>
                    <tr>
                        <td><b>Mouse Anatomy Ontology:</b></td>
                        <td>
                            <button onclick="loadData('<%=pId%>','ma')">Load Content</button>

                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <div id="maDiv" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div><br>
                            <div id="maThink" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div>

                        </td>
                    </tr>
                    <tr>
                        <td><b>Mammalian Phenotype Ontology:</b></td>
                        <td>
                            <button onclick="loadData('<%=pId%>','mp')">Load Content</button>

                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <div id="mpDiv" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div><br>
                            <div id="mpThink" style="display:none; margin:5px; padding:5px;border:1px solid black;"></div>

                        </td>
                    </tr>
                </table>

            </div>

            <%
                //exclude from the  pipelines
                if ( !obj.getReferenceType().equals("DIRECT DATA TRANSFER") ) { %>

            <br><div class="subTitle" id="annotation">Annotation&nbsp;&nbsp;&nbsp;&nbsp;<a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('annotation', 'annotation');">Click to see Annotation Detail View</a></div><br>
            <br>

            <div id="associationsCurator" style="display:block;">
                <%@ include file="../associationsCurator.jsp"%>
                <%@ include file="phenominerDetails.jsp"%>
            </div>
            <div id="associationsStandard" style="display:none;">
                <%@ include file="../associations.jsp"%>
                <%@ include file="phenominer.jsp"%>
            </div>

                <%@ include file="../objectsAnnotated.jsp"%>

                <br><div  class="subTitle" id="additionalInformation">Additional Information</div><br>

                <%@ include file="xdbs.jsp"%>
                <%@ include file="../nomen.jsp"%>
                <%@ include file="../curatorNotes.jsp"%>
            <% } %>
        </td>
        <td>&nbsp;</td>
        <td valign="top">
           <%-- <%@ include file="links.jsp" %>--%>
            <br>
<%--            <%@ include file="../idInfo.jsp" %>--%>
        </td>
    </tr>
 </table>
    </div>
</div>



<% }%>
    <%@ include file="../reportFooter.jsp"%>
    <%@ include file="/common/footerarea.jsp"%>
<%!
    private int checkAnnotInList1(Annotation annotation, List<Annotation> objListAnnot) {

        for(Annotation a : objListAnnot){
            if(a.getAnnotatedObjectRgdId().equals(annotation.getAnnotatedObjectRgdId())){
                return 1;
            }
        }
        return 0;
    }
%>

<script type="text/javascript">
    openAll();
    //alert("done expanding");
</script>
<script src="/rgdweb/js/reportPages/geneReport.js?v=15"> </script>
<script src="/rgdweb/js/reportPages/tablesorterReportCode.js?v=2"> </script>

