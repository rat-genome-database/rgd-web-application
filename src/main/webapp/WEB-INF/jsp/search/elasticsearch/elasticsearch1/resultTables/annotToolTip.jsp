<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 7/18/2025
  Time: 11:10 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<div class="tooltips">
  <%if(sourceMap.get("annotationsCount")!=null && ((int)sourceMap.get("annotationsCount"))>0){%>
  Term  (<%=sourceMap.get("termAnnotsCount")%>) + Child Term  (<%=sourceMap.get("childTermsAnnotsCount")%>)
    <div class="scoreBoard tooltiptext" style="font-size: x-small;width:400px">

      <table width="100%">
        <caption style="font-size: x-small;color:white">Associated Objects:</caption>
        <thead>
        <tr>
          <td  style="color: white;padding-left:10px"></td>
          <td style="color: white">Rat</td>
          <td style="color: white">Human</td>
          <td style="color: white">Mouse</td>
          <td style="color: white">Chinchilla</td>
          <td style="color: white">Dog</td>
          <td style="color: white">Bonobo</td>
          <td style="color: white;">Squirrel</td>
          <td style="color: white;">Naked Mole-rat</td>
          <td style="color: white;padding-right:10px">Green Monkey</td>
        </tr>
        <%
          List<List<Integer>> matrix= (List<List<Integer>>) sourceMap.get("annotationsMatrix");
          int i=0;
          String label=null;
          for (List<Integer> integers : matrix) {
            if (i == 0) label = "Gene";
            if (i == 1) label = "Strain";
            if (i == 2) label = "QTL";
            if (i == 3) label = "Variant";
        %>

        <tr>
          <td style="color: white" class="sorter-false"><%=label%>
          </td>
          <%
            for (Integer integer : integers) {%>
          <td class="matrix" style="color: white"><%=integer%>
          </td>
          <%}%>
        </tr>
        <%
            i++;
          }
        %>
        </thead>

      </table>

    </div>
    <%}%>

</div>