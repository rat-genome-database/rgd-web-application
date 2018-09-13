        <%
        String geneObj = "--";

        int colspan=1;

        String fontColor="black";
        String backColor="#E8E4D5;";
        String cursor = "default";

        if (g != null) {
            geneObj = g.getSymbol();
            colspan = snplotyper.getVariantSpan(g.getRgdId());
            backColor="#42433E";
            fontColor="white";
            cursor="pointer";

        }

        int groupSize = 10;
        int loopCount = (int) Math.floor(colspan / groupSize);
        int leftOver = colspan % groupSize;

        //loop over and print out by 20s
        for (int i=0; i< loopCount; i++) {

            int width = cellWidth;
            if (groupSize > 1) {
                width = (cellWidth * groupSize) + (groupSize - 1);
            }

         %>
            <td colspan="<%=groupSize%>"  style="background-color:<%=backColor%>;">
                <div class="geneTrack" id="<%=uniqueId%><%=i%>-<%=pos%>" style="overflow:hidden; cursor:<%=cursor%>; height:<%=cellWidth%>px; border-top: 1px solid white; *height: <%=cellWidth + 1%>px; width:<%=width%>; background-color:<%=backColor%>" >
                     <a style="width:<%=width%>; text-decoration:none; font-weight:700; cursor:<%=cursor%>; font-size: 12px; color:<%=fontColor%>;" href="javascript:void(0);" title="<%=geneObj%>">
                        <%=geneObj%>
                     </a>
               </div>
            </td>
        <script>
                <% if (g != null) { %>
                document.getElementById("<%=uniqueId%><%=i%>-<%=pos%>").gene="<%=geneObj%>";
                document.getElementById("<%=uniqueId%><%=i%>-<%=pos%>").onclick=showVariants;
                <% } %>
        </script>

        <%
        }

        if (leftOver > 0) {
            groupSize=leftOver;
            int width = cellWidth;
            if (groupSize > 1) {
                width = (cellWidth * groupSize) + (groupSize - 1);
            }
        %>
            <td colspan="<%=groupSize%>"  style="background-color:<%=backColor%>;">
                <div class="geneTrack" id="<%=uniqueId%>-<%=pos%>" style="overflow:hidden; cursor:<%=cursor%>; height:<%=cellWidth%>px; border-top: 1px solid white; *height: <%=cellWidth + 1%>px; width:<%=width%>; background-color:<%=backColor%>; border-right: 1px solid white;" >
                    <a style="  width:<%=width%>;text-decoration:none; font-weight:700; font-size: 12px; cursor:<%=cursor%>;  color:<%=fontColor%>;" href="javascript:void(0);" title="<%=geneObj%>"><%=geneObj%></a>
                </div>
            </td>
            <script>
                <% if (g != null) { %>
                document.getElementById("<%=uniqueId%>-<%=pos%>").gene="<%=geneObj%>";
                document.getElementById("<%=uniqueId%>-<%=pos%>").onclick=showVariants;
                <% } %>

            </script>
        <% } %>

    <%

        if (colspan > 1) {
            for (int i=0; i< colspan -1; i++) {
                if (cit.hasNext()) {
                    cit.next();
                }else {
                    break;
                }
            }
        }
     %>