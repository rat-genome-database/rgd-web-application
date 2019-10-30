<%@ page import="edu.mcw.rgd.datamodel.pheno.*" %>
<%@ include file="../sectionHeader.jsp"%>
<style>
    .exprData {
        border:1px solid black;
        border-radius:2px;
        border-spacing: 5px;
    }
    .exprData td,th{
        border: 1px solid #dddddd;
        text-align: left;
        padding: 8px;
    }
    .exprData  tr:nth-child(even) {background-color:#e2e2e2}
</style>
<%
    GeneExpressionDAO geneExpressionDAO = new GeneExpressionDAO();
    OntologyXDAO xdao = new OntologyXDAO();

    List<GeneExpressionRecordValue> geneExpressionRecordValues = geneExpressionDAO.getGeneExprRecordValuesForGene(obj.getRgdId(),"TPM");
    HashMap<Integer,GeneExpressionRecord> geneExprRecMap = new HashMap<>();
    HashMap<Integer,Experiment> experimentMap = new HashMap<>();
    Set<String> tissues = new TreeSet<>();
    HashMap<Integer, edu.mcw.rgd.datamodel.pheno.Sample> sampleMap = new HashMap<>();
    HashMap<Integer,Study> studyMap = new HashMap<>();
    for (GeneExpressionRecordValue rec : geneExpressionRecordValues) {
            GeneExpressionRecord geneExpRec;
            Experiment e;
            edu.mcw.rgd.datamodel.pheno.Sample s;
            Study study;
            if (geneExprRecMap.isEmpty() || !geneExprRecMap.keySet().contains(rec.getGeneExpressionRecordId())) {
                geneExpRec = geneExpressionDAO.getGeneExpressionRecordById(rec.getGeneExpressionRecordId());
                geneExprRecMap.put(rec.getGeneExpressionRecordId(), geneExpRec);
            } else geneExpRec = geneExprRecMap.get(rec.getGeneExpressionRecordId());

            if (experimentMap.isEmpty() || !experimentMap.keySet().contains(geneExpRec.getExperimentId())) {
                e = phenominerDAO.getExperiment(geneExpRec.getExperimentId());
                study = phenominerDAO.getStudy(e.getStudyId());
                experimentMap.put(e.getId(), e);
                studyMap.put(e.getStudyId(), study);

            }

            if (sampleMap.isEmpty() || !sampleMap.keySet().contains(geneExpRec.getSampleId())) {
                s = phenominerDAO.getSample(geneExpRec.getSampleId());
                sampleMap.put(s.getId(), s);
                tissues.add(s.getTissueAccId());
            }


    }

            if( !geneExpressionRecordValues.isEmpty() ) {
%>

<%=ui.dynOpen("rna-seq", "RNA-SEQ Expression")%>    <br>
<%
    for(String tissue: tissues) {
%>
<h3><%=xdao.getTerm(tissue).getTerm()%></h3>
<table class="exprData">

    <tr>

        <td><b>Strain</b></td>
        <td><b>sex</b></td>
        <td><b>Age</b></td>
        <td><b>Value</b></td>
        <td><b>Unit</b></td>
        <td><b>Assembly</b></td>
        <td><b>Reference</b></td>
    </tr>
    <%
        for (GeneExpressionRecordValue rec : geneExpressionRecordValues) {

            GeneExpressionRecord geneExpRec = geneExprRecMap.get(rec.getGeneExpressionRecordId());
            Experiment e = experimentMap.get(geneExpRec.getExperimentId());
            edu.mcw.rgd.datamodel.pheno.Sample s = sampleMap.get(geneExpRec.getSampleId());
            Study study = studyMap.get(e.getStudyId());
            String age;
            if(s.getAgeDaysFromHighBound() < 0 || s.getAgeDaysFromLowBound() < 0) {
                 age = String.valueOf(s.getAgeDaysFromLowBound() + 21);
                age+= "-";
                age+= String.valueOf(s.getAgeDaysFromHighBound() + 23);
                age+= " embryonic days";
            }
            else age = String.valueOf(s.getAgeDaysFromLowBound()) + "-" + String.valueOf(s.getAgeDaysFromHighBound()) + " days";
            if(s.getTissueAccId().equalsIgnoreCase(tissue)) {
    %>
    <tr>


        <td><%=xdao.getTerm(s.getStrainAccId()).getTerm()%></td>
        <td><%=s.getSex()%></td>
        <td><%=age%></td>
        <td><%=rec.getExpressionValue()%></td>
        <td>TPM</td>
        <td><%=MapManager.getInstance().getMap(rec.getMapKey()).getName()%></td>
        <td><a href="<%=Link.ref(study.getRefRgdId())%>"><%=study.getRefRgdId()%></a></td>
    </tr>
    <% } }  %>
</table>

<br>
<%}}%>

<%=ui.dynClose("rna-seq")%>


<%@ include file="../sectionFooter.jsp"%>
