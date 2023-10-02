<%@ page import="edu.mcw.rgd.reporting.Report,edu.mcw.rgd.reporting.GViewerReportStrategy,edu.mcw.rgd.process.search.SearchBean,edu.mcw.rgd.process.mapping.MapManager,edu.mcw.rgd.datamodel.Map" %><%
    Report report = (Report) request.getAttribute("report");
    //report.sort(report.getIndex("Chr"), Report.ASCENDING_SORT, true);
    SearchBean search = (SearchBean) request.getAttribute("searchBean");
    Map m = MapManager.getInstance().getMap(search.getMap());
    if (!m.getUnit().equals("bp")) {
    //    out.println("GViewer is currently only available for base pair maps.  You are currently using map " + m.getName());
        return;        
    }
    out.println(report.format(new GViewerReportStrategy()));
%>
