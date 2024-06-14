<style>
    .phenominerNavBar {
        background-color:#1E392A;
        color:white;
        margin-top:10px;
        padding:5px;
        margin-bottom:10px;
    }
    .phenominerNavBar a{
        color:white;
        text-decoration: none;
        font-weight:700;
        margin-left:20px;
        cursor:pointer;
    }
</style>


<div class="phenominerNavBar">
    <table >
        <tr>
            <% if (!req.getParameter("expId").equals("")) { %>
            <td><a href='records.html?act=new&expId=<%=req.getParameter("expId")%>'>Create New Record</a></td>
            <% } %>
            <td><a href='home.html'>Home</a></td>
            <td><a href='search.html'>Search</a></td>
            <td><a href='studies.html'>List All Studies</a></td>
            <% if (!multiEdit || enabledConditionInsDel) { %>
            <td><a href="javascript:addCondition()">Add Condition</a></td>
            <% } %>
            <td><a href="javascript:addUnit()">Add Unit</a></td>
            <% if (req.getParameter("studyId") != null && req.getParameter("studyId").length() > 0) {
                if (req.getParameter("expId") != null && req.getParameterValues("expId").size() == 1) { %>
            <td><a href="records.html?expId=<%=req.getParameter("expId")%>&studyId=<%=req.getParameter("studyId")%>">All
                Records</a></td>
            <td><a href="records.html?act=editSS&expId=<%=req.getParameter("expId")%>&studyId=<%=req.getParameter("studyId")%>">Edit All
                Records</a></td>

            <% } %>
            <td><a href="experiments.html?studyId=<%=req.getParameter("studyId")%>">All Experiments</a></td>
            <%
            } else {
                if (req.getParameter("expId") != null && req.getParameterValues("expId").size() == 1) {
            %>
            <td><a href="records.html?expId=<%=req.getParameter("expId")%>">All Records</a></td>
            <td><a href="records.html?act=editSS&expId=<%=req.getParameter("expId")%>&studyId=<%=req.getParameter("studyId")%>">Edit All
                Records</a></td>
            <% }
            }%>
        </tr>
    </table>
</div>
