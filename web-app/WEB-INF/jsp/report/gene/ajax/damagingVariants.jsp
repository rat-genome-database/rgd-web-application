<%@ page import="edu.mcw.rgd.dao.impl.VariantDAO" %>
<%@ page import="edu.mcw.rgd.dao.DataSourceFactory" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.SampleDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>
<%@ page import="edu.mcw.rgd.datamodel.Variant" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.Sample" %>

<style>
  #variants {
      border:1px solid black;
      font-size:small;
      margin-top:5px;
      padding:15px;
      margin-left:1%;
      margin-right:1%;
      border-radius:2px;
  }
  #variants tr{
      font-size:small;
      text-align:center;
  }
  #variants  tr:nth-child(even) {background-color:#e2e2e2}
</style>
<%
    int objRgdId = (int) request.getAttribute("id");
    String objSymbol = (String) request.getAttribute("symbol");

    VariantDAO vdao = new VariantDAO();
    vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
    List<String> assemblies = vdao.getGeneAssemblyOfDamagingVariants(objRgdId);
    SampleDAO sdao = new SampleDAO();
    sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
    Map m;
    if(assemblies.size() != 0) { %>
<div id="damagingVariantsTableDiv" class="light-table-border">

<div class="sectionHeading" id="damagingVariants">Damaging Variants</div>

    <br>
<%
    for(int i = assemblies.size()-1; i >=0  ; i--){
        String a = assemblies.get(i);
        List<Variant> assembly = vdao.getDamagingVariantsForGeneByAssembly(objRgdId,a);
        m = MapManager.getInstance().getMap(Integer.valueOf(a));
        if( !assembly.isEmpty() ) {
%>

<span style="border-bottom: 0 solid gray"><br><span class="highlight">Assembly: <u><%=m.getName()%></u></span><br></span>
<br>
<table id="variants">
<tr>
    <td><b>Chromosome</b></td>
    <td><b>Start Pos</b></td>
    <td><b>End Pos</b></td>
    <td><b>Reference Nucleotide</b></td>
    <td><b>Variant Nucleotide</b></td>
    <td><b>Variant Type</b></td>
    <td><b>Strain</b></td>
</tr>
    <%
       String pstrain = "",passembly = "";
        int count = 0;
        Variant v1 = new Variant();
        for (Variant v : assembly) {
            Sample s = sdao.getSample(v.getSampleId());
            if(v1.getStartPos() == v.getStartPos() && v1.getEndPos() == v.getEndPos()
                   && v1.getReferenceNucleotide().equalsIgnoreCase(v.getReferenceNucleotide())
                   && v1.getVariantNucleotide().equalsIgnoreCase(v.getVariantNucleotide())) {
                String url = "/rgdweb/front/variants.html?chr=&start=&stop=&geneStart=&geneStop=&mapKey="+m.getKey()+"&geneList="+objSymbol+"&con=&probably=true&possibly=true&depthLowBound=8&depthHighBound=&excludePossibleError=true&sample1="+s.getId();
                pstrain = pstrain.concat(",\t");
                pstrain = pstrain.concat("<a href="+url+">");
                pstrain = pstrain.concat(s.getAnalysisName());
                pstrain.concat("</a>");}
           else  {
                    if(count != 0) {
    %>

    <tr>
        <td><%=v1.getChromosome()%></td>
        <td><%=v1.getStartPos()%></td>
        <td><%=v1.getEndPos()%></td>
        <td><%=v1.getReferenceNucleotide()%></td>
        <td><%=v1.getVariantNucleotide()%></td>
        <td><%=v1.getVariantType()%></td>
        <td><%= pstrain %></td>
    </tr>
<%
         } else
            pstrain = "";
            String url = "/rgdweb/front/variants.html?chr=&start=&stop=&geneStart=&geneStop=&mapKey="+m.getKey()+"&geneList="+objSymbol+"&con=&probably=true&possibly=true&depthLowBound=8&depthHighBound=&excludePossibleError=true&sample1="+s.getId();
            pstrain = "<a href="+url+">";
            pstrain = pstrain.concat(s.getAnalysisName());
            pstrain = pstrain.concat("</a>");}
        count ++;
        v1 = v;
    }  %>
<tr>
    <td><%=v1.getChromosome()%></td>
    <td><%=v1.getStartPos()%></td>
    <td><%=v1.getEndPos()%></td>
    <td><%=v1.getReferenceNucleotide()%></td>
    <td><%=v1.getVariantNucleotide()%></td>
    <td><%=v1.getVariantType()%></td>
    <td><%= pstrain %></td>
</tr>
</table>
<br>



<% } }%>
</div>
<%}%>

