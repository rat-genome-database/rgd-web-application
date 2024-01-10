<%@ include file="../sectionHeader.jsp"%>
<%@ page import="edu.mcw.rgd.dao.impl.VariantDAO" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>

<%
    VariantDAO vdao = new VariantDAO();
    SampleDAO smdao = new SampleDAO();
    smdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
    vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
    List<String> assembly = vdao.getAssemblyOfDamagingVariants(obj.getRgdId());
    List<Sample> samples= smdao.getSamplesByStrainRgdId(obj.getRgdId());
    if( assembly.size() != 0 ) {
%>

<%--<%=ui.dynOpen("damagingVar", "Damaging Variants")%>    <br>--%>
<div id="damagingVarTableDiv" class="light-table-border">
<div class="sectionHeading" id="damagingVar">Damaging Variants</div>
<table class="table table-sm table-hover table-striped">
    <thead style="font-size: smaller"><tr><th></th><th colspan="4"></th></tr></thead>
    <thead style="font-size: smaller"><tr><th>Assembly</th><th>Sample</th><th>Number of Damaging Variants</th></tr></thead>

    <tbody>
    <% for(Sample s: samples) {

        if (s.getMapKey() < 360) {
            continue;
        }

        int count = vdao.getCountofDamagingVariantsForSample(s.getId(), String.valueOf(s.getMapKey()));

        if(count != 0) {
    %>
        <tr>
            <td><%=MapManager.getInstance().getMap(s.getMapKey()).getRefSeqAssemblyName()%></td>
            <td>
            <%=s.getAnalysisName()%>
            </td>
            <td>
                <span class="detailReportLink"><a href="/rgdweb/report/strain/damagingVariants.html?id=<%=s.getId()%>&fmt=full&map=<%=s.getMapKey()%>"><%=count%> </a></span>

                </td>
        </tr>

   <% } } %>
    </tbody>
</table>
<%   %>


<br>
<%--<%=ui.dynClose("damagingVar")%>--%>
</div>
<% } %>

<%@ include file="../sectionFooter.jsp"%>
