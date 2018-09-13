<%@ page import="edu.mcw.rgd.web.HeatMap" %>
<%@ page import="java.util.TreeMap" %>

<%
       HeatMap hm = new HeatMap();

    hm.setCellWidth(24);
    hm.setCellFontSize(9);
    hm.setHeaderHeight(300);
    hm.setMaxValue(33);

    int[][] mapData = new int[3][3];
    mapData[0][0] = 10;
    mapData[0][1] = 1;
    mapData[0][2] = 33;
    mapData[1][0] = 16;
    mapData[1][1] = 4;
    mapData[1][2] = 8;
    mapData[2][0] = 31;
    mapData[2][1] = 14;
    mapData[2][2] = 10;

    hm.setMapData(mapData);

    TreeMap xAxis = new TreeMap();
    xAxis.put("Term 1", "http://www.yahoo.com");
    xAxis.put("Term 2", "http://www.google.com");
    xAxis.put("Term 3", "http://www.cnn.com");
    hm.setxAxis(xAxis);

    TreeMap yAxis = new TreeMap();
    yAxis.put("Term A", "http://www.yahoo.com");
    yAxis.put("Term B", "http://www.google.com");
    yAxis.put("Term C", "http://www.cnn.com");
    hm.setyAxis(yAxis);

    hm.setyAxisSelectedIndex(1);
    hm.setxAxisSelectedIndex(2);
%>

<table border=1>
    <tr>
        <td>hello world</td>
        <td>goodbye</td>
    </tr>
    <tr>
        <td><%@ include file="/common/heatmap.jsp"%></td>
        <td>goodbye</td>
    </tr>

    <tr>
        <td>hello world</td>
        <td>goodbye</td>
    </tr>

</table>
