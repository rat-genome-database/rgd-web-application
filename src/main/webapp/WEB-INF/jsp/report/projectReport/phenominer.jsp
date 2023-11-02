<%@ page import="edu.mcw.rgd.process.pheno.SearchBean" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.pheno.Record" %>
<%@ page import="edu.mcw.rgd.reporting.Report" %>
<%@ page import="edu.mcw.rgd.reporting.HTMLTableReportStrategy" %>
<%@ include file="../sectionHeader.jsp"%>
<%

    AnnotationFormatter af = new AnnotationFormatter();

    PhenominerDAO phDAO = new PhenominerDAO();
    OntologyXDAO ontDAO = new OntologyXDAO();
//    List<Record> allRecords = phDAO.getFullRecords(obj.getRgdId());
    List<Record> allRecords = phDAO.getFullRecordsForProject(obj.getRgdId());
    List<Term> strainTerms = new ArrayList<>();
    HashMap<String,Boolean> terms = new HashMap<>();
    for (Record r : allRecords){
        String accId = r.getSample().getStrainAccId();
        Term term = ontDAO.getTermWithStatsCached(accId);
        if( term!=null && terms.get(term.getTerm())==null ) {
            terms.put(term.getTerm(),true);
            strainTerms.add(term);
        }
    }

    ArrayList<String> table = new ArrayList<>();

    for (int i = 0 ; i < strainTerms.size(); i++){
        String ontId = strainTerms.get(i).getAccId(); //ontologyDAO.getStrainOntIdForRgdId(strains.get(i).getAnnotatedObjectRgdId());
//        List<Record> records = phenominerDAO.getFullRecords(obj.getRgdId(),ontId);
        List<Record> records = phenominerDAO.getFullRecordsForProject(obj.getRgdId(),ontId);
        if (records!=null && records.size()>0) {
            Report r = new Report();
            edu.mcw.rgd.reporting.Record row = new edu.mcw.rgd.reporting.Record();
            row.append("Clinical Measurement");
            r.append(row);
            HashMap seen = new HashMap();
            for (Record rec : records) {
                row = new edu.mcw.rgd.reporting.Record();

                String term = ontologyDAO.getTerm(rec.getClinicalMeasurement().getAccId()).getTerm();

                if (!seen.containsKey(term)) {
                    row.append("<a href='/rgdweb/phenominer/table.html?species=3&terms=" + rec.getSample().getStrainAccId()
                            + "," + rec.getClinicalMeasurement().getAccId()
                            + "#ViewDataTable'>" + ontologyDAO.getTerm(rec.getClinicalMeasurement().getAccId()).getTerm() + "</a>");
                    r.append(row);
                    seen.put(term, true);
                }
            }
            HTMLTableReportStrategy strat = new HTMLTableReportStrategy();
            r.sort(0, Report.CHARACTER_SORT, Report.ASCENDING_SORT, true);
            table.add(i, strat.format(r));
        }
        else
            table.add(i,null);
    }

    List<String> columns = new ArrayList<>();
    int k = 0;
    for (int j = 0 ; j < strainTerms.size() ; j++){
        if (table.get(j)!=null && !table.get(j).isEmpty()){
            String objSymbol = Utils.NVL(strainTerms.get(j).getTerm(), "NA");
            columns.add(
                    "<td><input type=\"button\" class=\"phenoButton\" id=\"showHide"+k+"\" onclick=\"toggleCM('ClinMeasure"+k+"','showHide"+k+"');\" value=\"+\"></input>" +
                            "\t<a href=\"javascript:void(0);\" onclick=\"toggleCM('ClinMeasure"+k+"','showHide"+k+"');\" class='phenominer"
                            + refRgdId.getSpeciesTypeKey() + "'>" + objSymbol + "</a>" +
                            "<div id=\"ClinMeasure"+k+"\"style=\"display:none; border: 2px solid #000000;\" >"+table.get(j)+"</div></td>");
            k++;
        }
    }
//        List<Record> records = phenominerDAO.getFullRecords(obj.getRgdId());
//        if (records!=null && records.size() > 0) {
%>

<%--<%=ui.dynOpen("phenominerAssociation", "Phenotype Values via Phenominer")%>--%>
<% if (columns.size()>0){%>
<div id="phenominerAssociationTableWrapper" class="light-table-border">
    <link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>
    <div class="sectionHeading" id="phenominerAssociation">Phenotype Values via PhenoMiner&nbsp;&nbsp;&nbsp;&nbsp;
        <a href="javascript:void(0);" class="associationsToggle" onclick="toggleAssociations('phenominerAssociationCTableDiv', 'phenominerAssociationTableWrapper');">Click to see Annotation Detail View</a>
    </div>
    <div class="modelsViewContent" >
        <div class="pager phenominerAssociationPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <%List<Integer> refRgdIds1 = new ProjectDAO().getReferenceRgdIdsForProject(obj.getRgdId());%>
    <br>
    <table>
        <%for(int i=0;i<refRgdIds1.size();i++){
            List<Record> allRecords1 = phDAO.getFullRecords(refRgdIds1.get(i));
            if(allRecords1.size()>0){
        %>
        <tr>
            <td><b>Options:&nbsp;</b></td>
            <td><a href="/rgdweb/phenominer/table.html?species=3&refRgdId=<%=refRgdIds1.get(i)%>#ViewChart">View chart (<%=refRgdIds1.get(i)%>)</a></td>
            <td>&nbsp;|&nbsp;</td>
            <td><a href="/rgdweb/phenominer/table.html?species=3&fmt=3&refRgdId=<%=refRgdIds1.get(i)%>">Download data table (<%=refRgdIds1.get(i)%>)</a></td>
            <td>&nbsp;|&nbsp;</td>
            <td><a href="/rgdweb/phenominer/table.html?species=3&fmt=2&refRgdId=<%=refRgdIds1.get(i)%>">View expanded data table (<%=refRgdIds1.get(i)%>)</a></td>
            <td>&nbsp;|&nbsp;</td>
            <td><a href="javascript:void(0);" onclick="showAllClinicalMeasurement('ClinMeasure', 'showHide');">Show All Strains Clinical Measurement</a></td>
        </tr>
        <%}%>
        <%}%>
    </table>


    <br/>
    <div id="phenominerAssociationTableDiv">
        <input type="hidden" id="hiddenCheck" value="0">
        <table id="annotationTable9" border='0' cellpadding='2' cellspacing='2' aria-describedby="annotationTable9_pager_info">
            <tr class="headerRow"><td>Strains with Phenominer Data</td>
                <%
                    if (columns.size()%3==2)
                        out.print("<td style=\"color: #99BFE6;\">Strains with phenominer data</td>");
                    else if (columns.size()>2){
                        out.print("<td style=\"color: #99BFE6;\">Strains with phenominer data</td>" +
                                "<td style=\"color: #99BFE6;\">Strains with phenominer data</td>");
                    }
                %>
            </tr>
            <%
                /*if( recIds.size()>1000 ) {
                    out.println("<p><span class=\"highlight\"><u>Note: Only first 1000 records are shown!</u></span><br></p>");
                }
                */

                boolean isRow = false;
                String evenOdd = (isRow) ? "even" : "odd";
                isRow = true;
                for (int i = 0; i < columns.size();i++){
                    if (i==0) {
                        out.print("<tr  class=\"" + evenOdd + "Row\">");
                    }
                    else if (i%3==0){
                        evenOdd = (isRow) ? "even" : "odd";
                        out.print("</tr><tr  class=\""+evenOdd+"Row\">" );
                        isRow = !isRow;
                    }
                    out.print(columns.get(i));
                }
                if (columns.size()>0)
                    out.print("</tr>");
            %>
        </table>
    </div>
    <br>
    <div class="modelsViewContent" >
        <div class="pager phenominerAssociationPager" >
            <form>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
                <span type="text" class="pagedisplay"></span>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
                <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
                <select class="pagesize">
                    <option selected="selected" value="10">10</option>
                    <option value="20">20</option>
                    <option value="30">30</option>
                    <option  value="40">40</option>
                    <option   value="100">100</option>
                    <option value="9999">All Rows</option>
                </select>
            </form>
        </div>
    </div>
    <%--<%=ui.dynClose("phenominerAssociation")%>--%>
</div>
<% } %>
<%--<% } %>--%>
<script>
    function toggleCM(divName, myButton){
        var clinicalMeasurment = document.getElementById(divName);
        var pm = document.getElementById(myButton);
        if (clinicalMeasurment.style.display !== 'none') {
            clinicalMeasurment.style.display = 'none';
            pm.value = '+';
        }
        else {
            clinicalMeasurment.style.display = 'block';
            pm.value = '-';
        }

    }
    function showAllClinicalMeasurement(divNames, buttons){
        var allDivs = $("div[id^="+divNames+"]");
        var allBtns = $("[id^="+buttons+"]");
        var hidden = document.getElementById('hiddenCheck');
        if (hidden.value === '1')
            hidden.value = '0';
        else
            hidden.value = '1';
        for (var i = 0 ; i < allDivs.length ; i++){
            if (allDivs[i].style.display !== 'none' && hidden.value === '0') {
                allDivs[i].style.display = 'none';
                allBtns[i].value = '+';
            }
            else if (allDivs[i].style.display !== 'block' && hidden.value === '1'){
                allDivs[i].style.display = 'block';
                allBtns[i].value = '-';
            }
        }
    }
</script>
<style>
    .phenoButton{
        border: none;
        background: red;
        color: white;
    }
</style>
<%@ include file="../sectionFooter.jsp"%>
