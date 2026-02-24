<%@ page import="edu.mcw.rgd.dao.impl.RGDNewsConfDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.RGDNewsConf" %>
<%@ page import="java.util.List" %>
<div class="" style="border-color: transparent;">
    <div class="" style="border-color: transparent;margin-top:20px;">
        <h5 class="card-title">RGD Video Tutorials</h5>
    </div>
    <hr>
<table class="videoTutorials" style="width:100%; max-width:270px">
    <%
        RGDNewsConfDAO dao = new RGDNewsConfDAO();
        List<RGDNewsConf> videos = dao.getAllVideos();

        for (RGDNewsConf article : videos) {
            %>
        <tr>
    <%
            if (article.getStrongText() == null) { %>
            <td> <a href="<%=article.getRedirectLink()%>"><img src="/rgdweb/common/images/social/youtube-20.png" /></a></td><td>&nbsp;</td>
                <td><a href="<%=article.getRedirectLink()%>" style="font-weight: bold;color: #24609c;text-decoration:none;"><%=article.getDisplayText()%></a></td>
            <%}
            else { %>
            <td> <a href="<%=article.getRedirectLink()%>"><img src="/rgdweb/common/images/social/youtube-20.png" /></a></td><td>&nbsp;</td>
            <td><a href="<%=article.getRedirectLink()%>" style="font-weight: bold;color: #24609c;text-decoration:none;"><%=article.getDisplayText()%></a>
                <strong><span style="color: red;"><%=article.getStrongText()%></span></strong></td>
            <% } %>
            </tr>
            <%
        }
    %>
</table>
</div>
<style>
    .videoTutorials td{
        padding-bottom: .5em;
    }
</style>




