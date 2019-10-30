<%@ page import="edu.mcw.rgd.datamodel.pheno.*" %>
<%@ include file="../sectionHeader.jsp"%>
<style>
    .exprData {
        border:1px solid black;
        font-size:small;
        margin-top:5px;
        padding:20px;
        margin-left:2%;
        margin-right:2%;
        border-radius:2px;
        border-spacing: 5px;
    }
    .exprData tr{
        font-size:small;
        text-align:center;
    }
    .exprData  tr:nth-child(even) {background-color:#e2e2e2}
</style>
<%
    GeneExpressionDAO geneExpressionDAO = new GeneExpressionDAO();
    OntologyXDAO xdao = new OntologyXDAO();

    List<GeneExpressionRecordValue> geneExpressionRecordValues = geneExpressionDAO.getGeneExprRecordValuesForGene(obj.getRgdId());
    HashMap<Integer,GeneExpressionRecord> geneExprRecMap = new HashMap<>();
    HashMap<Integer,Experiment> experimentMap = new HashMap<>();
    HashMap<Integer, edu.mcw.rgd.datamodel.pheno.Sample> sampleMap = new HashMap<>();
    if( !geneExpressionRecordValues.isEmpty() ) {
%>

<%=ui.dynOpen("rna-seq", "RNA-SEQ Expression")%>    <br>
<table >
    <tr>
        <td style="vertical-align: top;">
<h3> TPM Values </h3>
<table class="exprData">
    <tr>

        <th>Strain</th>
        <th>Tissue</th>
        <th>sex</th>
        <th>Age High Bound</th>
        <th>Age Low Bound</th>
        <th>Value</th>
        <th>Assembly</th>
    </tr>
    <%
        for (GeneExpressionRecordValue rec : geneExpressionRecordValues) {
            if(rec.getExpressionUnit().equalsIgnoreCase("TPM")) {
            GeneExpressionRecord geneExpRec;
            Experiment e;
            edu.mcw.rgd.datamodel.pheno.Sample s;
          if(geneExprRecMap.isEmpty() || !geneExprRecMap.keySet().contains(rec.getGeneExpressionRecordId())){
               geneExpRec = geneExpressionDAO.getGeneExpressionRecordById(rec.getGeneExpressionRecordId());
              geneExprRecMap.put(rec.getGeneExpressionRecordId(),geneExpRec);
          }
            else geneExpRec = geneExprRecMap.get(rec.getGeneExpressionRecordId());

            if(experimentMap.isEmpty() || !experimentMap.keySet().contains(geneExpRec.getExperimentId())){
                e = phenominerDAO.getExperiment(geneExpRec.getExperimentId());
                experimentMap.put(e.getId(),e);
            }
            else e = experimentMap.get(geneExpRec.getExperimentId());

            if(sampleMap.isEmpty() || !sampleMap.keySet().contains(geneExpRec.getSampleId())){
                s = phenominerDAO.getSample(geneExpRec.getSampleId());
                sampleMap.put(s.getId(),s);
            }
            else s = sampleMap.get(geneExpRec.getSampleId());

    %>
    <tr>


        <td><%=xdao.getTerm(s.getStrainAccId()).getTerm()%></td>
        <td><%=xdao.getTerm(s.getTissueAccId()).getTerm()%></td>
        <td><%=s.getSex()%></td>
        <td><%=s.getAgeDaysFromHighBound()%></td>
        <td><%=s.getAgeDaysFromLowBound()%></td>
        <td><%=rec.getExpressionValue()%></td>
        <td><%=MapManager.getInstance().getMap(rec.getMapKey()).getName()%></td>
    </tr>
    <% }} %>
</table>
        </td>
        <td style="vertical-align: top">
            <h3> FPKM Values </h3>
            <table class="exprData">
                <tr>

                    <th>Strain</th>
                    <th>Tissue</th>
                    <th>sex</th>
                    <th>Age High Bound</th>
                    <th>Age Low Bound</th>
                    <th>Value</th>
                    <th>Assembly</th>
                </tr>
                <%
                    for (GeneExpressionRecordValue rec : geneExpressionRecordValues) {
                        if(rec.getExpressionUnit().equalsIgnoreCase("FPKM")) {
                        GeneExpressionRecord geneExpRec;
                        Experiment e;
                        edu.mcw.rgd.datamodel.pheno.Sample s;
                        if(geneExprRecMap.isEmpty() || !geneExprRecMap.keySet().contains(rec.getGeneExpressionRecordId())){
                            geneExpRec = geneExpressionDAO.getGeneExpressionRecordById(rec.getGeneExpressionRecordId());
                            geneExprRecMap.put(rec.getGeneExpressionRecordId(),geneExpRec);
                        }
                        else geneExpRec = geneExprRecMap.get(rec.getGeneExpressionRecordId());

                        if(experimentMap.isEmpty() || !experimentMap.keySet().contains(geneExpRec.getExperimentId())){
                            e = phenominerDAO.getExperiment(geneExpRec.getExperimentId());
                            experimentMap.put(e.getId(),e);
                        }
                        else e = experimentMap.get(geneExpRec.getExperimentId());

                        if(sampleMap.isEmpty() || !sampleMap.keySet().contains(geneExpRec.getSampleId())){
                            s = phenominerDAO.getSample(geneExpRec.getSampleId());
                            sampleMap.put(s.getId(),s);
                        }
                        else s = sampleMap.get(geneExpRec.getSampleId());



                %>
                <tr>


                    <td><%=xdao.getTerm(s.getStrainAccId()).getTerm()%></td>
                    <td><%=xdao.getTerm(s.getTissueAccId()).getTerm()%></td>
                    <td><%=s.getSex()%></td>
                    <td><%=s.getAgeDaysFromHighBound()%></td>
                    <td><%=s.getAgeDaysFromLowBound()%></td>
                    <td><%=rec.getExpressionValue()%></td>
                    <td><%=MapManager.getInstance().getMap(rec.getMapKey()).getName()%></td>
                </tr>
                <%} } %>
            </table>
        </td>
    </tr>
</table>
<br>
<%=ui.dynClose("rna-seq")%>

<% } %>

<%@ include file="../sectionFooter.jsp"%>
