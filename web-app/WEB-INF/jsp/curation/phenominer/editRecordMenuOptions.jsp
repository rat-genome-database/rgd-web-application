<div class="phenoNavBar">
    <table>
        <tr>
            <% if (!req.getParameter("expId").equals("")) { %>
            <td><a href='records.html?act=new&expId=<%=req.getParameter("expId")%>'>Create New Record</a></td>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <% } %>
            <td><a href='home.html'>Home</a></td>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href='search.html'>Search</a></td>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href='studies.html'>List All Studies</a></td>
            <% if (!multiEdit || enabledConditionInsDel) { %>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="javascript:addCondition()">Add Condition</a></td>
            <% } %>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="javascript:addUnit()">Add Unit</a></td>
            <% if (req.getParameter("studyId") != null && req.getParameter("studyId").length() > 0) {
                if (req.getParameter("expId") != null && req.getParameterValues("expId").size() == 1) { %>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="records.html?expId=<%=req.getParameter("expId")%>&studyId=<%=req.getParameter("studyId")%>">All
                Records</a></td>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="records.html?act=editSS&expId=<%=req.getParameter("expId")%>&studyId=<%=req.getParameter("studyId")%>">Edit All
                Records</a></td>

            <% } %>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="experiments.html?studyId=<%=req.getParameter("studyId")%>">All Experiments</a></td>
            <%
            } else {
                if (req.getParameter("expId") != null && req.getParameterValues("expId").size() == 1) {
            %>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="records.html?expId=<%=req.getParameter("expId")%>">All Records</a></td>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="ssrecords.html?expId=<%=req.getParameter("expId")%>">Edit All Records</a></td>
            <% }
            }%>
            <td align="center"><img src="http://rgd.mcw.edu/common/images/icons/asterisk_yellow.png"/></td>
            <td><a href="javascript:toggleOptions()">Configure</a></td>
        </tr>
    </table>
</div>