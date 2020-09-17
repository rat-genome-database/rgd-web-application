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
<div class="sectionHeading" id="damagingVar">Damaging Variants</div>
<table class="table table-sm table-hover table-striped">
    <thead style="font-size: smaller"><tr><th></th><th colspan="4">Number of Damaging Variants</th></tr></thead>
    <thead style="font-size: smaller"><tr><tr><th>Sample</th><th>Rnor_6.0</th><th>Rnor_5.0</th><th>RGSC_v3.4</th></tr></thead>

    <tbody>
    <% for(Sample s: samples) {
        int count = vdao.getCountofDamagingVariantsForSample(s.getId(), String.valueOf(s.getMapKey()));
        if(count != 0) {
    %>
        <tr>
            <td><%=s.getAnalysisName()%></td>
            <td><% if(s.getMapKey() == 360 ) {%>
                <span class="detailReportLink"><a href="/rgdweb/report/strain/damagingVariants.html?id=<%=s.getId()%>&fmt=full&map=<%=s.getMapKey()%>"><%=count%> </a></span>
            <% }  %></td>
            <td><% if(s.getMapKey() == 70 ) {%>
                <span class="detailReportLink"><a href="/rgdweb/report/strain/damagingVariants.html?id=<%=s.getId()%>&fmt=full&map=<%=s.getMapKey()%>"><%=count%> </a></span>
                <% }  %></td>
            <td><% if(s.getMapKey() == 60 ) {%>
                <span class="detailReportLink"><a href="/rgdweb/report/strain/damagingVariants.html?id=<%=s.getId()%>&fmt=full&map=<%=s.getMapKey()%>"><%=count%> </a></span>
                <% }  %></td>
        </tr>

   <% } } %>
    </tbody>
</table>
<%   %>


<br>
<%--<%=ui.dynClose("damagingVar")%>--%>

<% } %>

<%@ include file="../sectionFooter.jsp"%>
