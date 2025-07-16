<%@ page import="java.util.ArrayList" %><%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 7/11/2025
  Time: 3:13 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
  List<Map<String, Object>> mapDataList= new ArrayList<>();
  if(sourceMap.get("mapDataList")!=null)
        mapDataList=  (List<Map<String, Object>>) sourceMap.get("mapDataList");
%>
<td onmouseover="link=false;" onmouseout="link=true;">
  <div class="filter-list">
    <%
      if(defaultAssembly!=null && !defaultAssembly.equalsIgnoreCase("all")){
        for(Map<String, Object> map:mapDataList){
          if(defaultAssembly.equalsIgnoreCase(map.get("map").toString())){%>
    <%=map.get("map")%>
    <%}}}else{

      for(Map<String, Object> map:mapDataList){
        if(defaultAssembly == null || !defaultAssembly.equalsIgnoreCase(map.get("map").toString())){%>
    <%=map.get("map")%>
    <%break;}}}%>
  </div>
</td>
<td onmouseover="link=false;" onmouseout="link=true;"> <!-- LOCATION--->
  <div class="filter-list">
    <%
      if(defaultAssembly!=null && !defaultAssembly.equalsIgnoreCase("all")){
        for(Map<String, Object> map:mapDataList){
          if(defaultAssembly.equalsIgnoreCase(map.get("map").toString())){%>
    <%=map.get("chromosome")%>
    <%}}}else{
      for(Map<String, Object> map:mapDataList){
        if(defaultAssembly == null || !defaultAssembly.equalsIgnoreCase(map.get("map").toString()) && map.get("chromosome")!=null){%>
    <%=map.get("chromosome")%>
    <% break;}}}%>
  </div>


</td> <!-- END LOCATION--->
<td onmouseover="link=false;" onmouseout="link=true;"> <!-- LOCATION--->
  <div class="filter-list">
    <%
      if(defaultAssembly!=null && !defaultAssembly.equalsIgnoreCase("all")){
        for(Map<String, Object> map:mapDataList){
          if(defaultAssembly.equalsIgnoreCase(map.get("map").toString())){%>
    <%=map.get("startPos")%>
    <%}}}else{for(Map<String, Object> map:mapDataList){
      if(defaultAssembly == null || !defaultAssembly.equalsIgnoreCase(map.get("map").toString()) && map.get("startPos")!=null){%>
    <%=map.get("startPos")%>
    <%break;}}}%>
  </div>
</td> <!-- END LOCATION--->
<td onmouseover="link=false;" onmouseout="link=true;"> <!-- LOCATION--->
  <div class="filter-list">
    <%
      if(defaultAssembly!=null && !defaultAssembly.equalsIgnoreCase("all")){
        for(Map<String, Object> map:mapDataList){
          if(defaultAssembly.equalsIgnoreCase(map.get("map").toString())){%>
    <%=map.get("stopPos")%>
    <%}}}else{for(Map<String, Object> map:mapDataList){
      if(defaultAssembly == null || !defaultAssembly.equalsIgnoreCase(map.get("map").toString()) && map.get("stopPos")!=null){%>
    <%=map.get("stopPos")%>
    <% break;}}}%>
  </div>

</td> <!-- END LOCATION--->

