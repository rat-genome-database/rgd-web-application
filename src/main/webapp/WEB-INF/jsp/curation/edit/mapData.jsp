<%@ page import="edu.mcw.rgd.process.mapping.MapManager" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.datamodel.Map" %>

<%
    MapDAO mapDAO = new MapDAO();
    List<Map> activeMaps = mapDAO.getMaps(speciesTypeKey);
    java.util.Map<String, String>  mapHash = new HashMap<String, String>();
    for( Map map: activeMaps ) {
        mapHash.put(Integer.toString(map.getKey()), map.getName());
    }
    List<MapData> mapDataList = mapDAO.getMapData(rgdId);
%>

<% if (!isNew) {

%>

<form action="updateMaps.html" >
<input type="hidden" name="rgdId" value="<%=rgdId%>"/>
<table id="mapTable" border="1" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td colspan="6" style="background-color:#2865a3;color:white; font-weight: 700;">Map Data</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
    </tr>
    <tr>
        <td colspan="7" align="right"><a href="javascript:addMapData(); void(0);" style="font-weight:700; color: green;">Add Map Data</a></td>
    </tr>

    <tr>
        <td class="label">Map Name</td>
        <td class="label">Chr</td>
        <td class="label">Fish Band</td>
        <td class="label">Start Pos</td>
        <td class="label">Stop Pos</td>
        <td class="label">Strand</td>
        <td colspan="2" class="label">Source</td>
    </tr>

    <%
        int mapCount=1;
        for (MapData md : mapDataList) {
            if (rgdId != displayRgdId) {
                md.setKey(0);
            }
    %>
<tr id="mapRow<%=mapCount%>">
    <td><%=fu.buildSelectList("mapKey", mapHash, Integer.toString(md.getMapKey()))%></td>
    <td><input type="text" size="8" value="<%=md.getChromosome()%>" name="chr" /></td>
    <td><input type="text" size="8" value="<%=fu.chkNull(md.getFishBand())%>" name="fishBand" /></td>
    <td><input type="text" size="10" value="<%=fu.chkNull(md.getStartPos())%>" name="startPos" /></td>
    <td><input type="text" size="10" value="<%=fu.chkNull(md.getStopPos())%>" name="stopPos" /></td>
    <td><input type="text" size="1" value="<%=fu.chkNull(md.getStrand())%>" name="strand" /></td>
    <td><input type="text" size="12" value="<%=fu.chkNull(md.getSrcPipeline())%>" name="srcPipeline" /></td>
    <td align="right">
        <a style="color:red; font-weight:700;"
                         href="javascript:removeMap('mapRow<%=mapCount%>') ;void(0);"><img
            src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
</tr>
<%
        mapCount++;
    }
    %>
    </tbody>
</table>
</form>

<% } %>

<script>
  function removeMap(rowId) {
    var d = document.getElementById(rowId);
    d.parentNode.removeChild(d);
  }

    var mapCreatedCount = 1;
    function addMapData() {

        var tbody = document.getElementById("mapTable").getElementsByTagName("TBODY")[0];

        var row = document.createElement("TR");
        row.id = "mapRowCreated" + mapCreatedCount;

        var td = document.createElement("TD");
        td.innerHTML = '<%=fu.buildSelectList("mapKey", mapHash, null)%>';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="8" name="chr" />';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="8" name="fishBand" />';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="10" name="startPos" />';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="10" name="stopPos" />';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="1" name="strand" />';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="12" name="srcPipeline" value="RGD" />';
        row.appendChild(td);

        td = document.createElement("TD");
        td.align = "right";
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:removeMap('mapRowCreated" + mapCreatedCount + "') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        tbody.appendChild(row);

        mapCreatedCount++;
        enableAllOnChangeEvents();
    }
</script>
