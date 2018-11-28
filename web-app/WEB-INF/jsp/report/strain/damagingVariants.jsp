<%@ include file="../sectionHeader.jsp"%>
<%@ page import="edu.mcw.rgd.dao.impl.VariantDAO" %>
<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>

<%
    VariantDAO vdao = new VariantDAO();
    vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
    List<String> assembly = vdao.getAssemblyOfDamagingVariants(obj.getRgdId());

    Map m = new Map();
    if( assembly.size() != 0 ) {
%>

<%=ui.dynOpen("damagingVar", "Damaging Variants")%>    <br>
<table>
<%
    for(String s:assembly) {
    m = MapManager.getInstance().getMap(Integer.valueOf(s));%>

    <tr>
        <td style="background-color:#e2e2e2;font-weight:700;"><%=m.getName()%></td>
        <td>&nbsp;</td>
        <td>No of damaging variants = <%=vdao.getCountofDamagingVariantsForStrainByAssembly(obj.getRgdId(),s)%></td>
        <td>&nbsp;</td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/report/strain/damagingVariants.html?id=<%=obj.getRgdId()%>&fmt=full&map=<%=m.getKey()%>">Full Report</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/report/strain/damagingVariants.html?id=<%=obj.getRgdId()%>&fmt=csv&map=<%=m.getKey()%>">CSV</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/report/strain/damagingVariants.html?id=<%=obj.getRgdId()%>&fmt=tab&map=<%=m.getKey()%>">TAB</a></span></td>
        <td><img src='/rgdweb/common/images/bullet_green.png' /></td><td><span class="detailReportLink"><a href="/rgdweb/report/strain/damagingVariants.html?id=<%=obj.getRgdId()%>&fmt=print&map=<%=m.getKey()%>">Printer</a></span></td>

    </tr>
        <%    } %>
</table>
<%   %>


<br>
<%=ui.dynClose("damagingVar")%>

<% } %>

<%@ include file="../sectionFooter.jsp"%>
