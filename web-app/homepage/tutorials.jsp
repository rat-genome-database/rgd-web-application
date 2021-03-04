<%@ page import="edu.mcw.rgd.dao.impl.RGDNewsConfDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.RGDNewsConf" %>
<%@ page import="java.util.List" %>
<div class="" style="border-color: transparent;">
    <div class="" style="border-color: transparent;margin-top:20px;">
        <h5 class="card-title">RGD Video Tutorials</h5>
    </div>
    <hr>
<%--    <p>--%>
<%--        <a href="https://www.youtube.com/watch?v=cONcdQr4OmY"><img src="/rgdweb/common/images/social/youtube-20.png" /></a>--%>
<%--        &nbsp;&nbsp;<a href="https://www.youtube.com/watch?v=cONcdQr4OmY" style="font-weight: bold;color: #24609c;text-decoration:none;">JBrowse Genome Browser</a>--%>
<%--    </p>--%>
<%--    <p>--%>
<%--        <a href="https://www.youtube.com/watch?v=3EUaurjK7u8&list=PLBD6hGqefQVkBpf1YCQDFxjhLHssro_6a"><img src="/rgdweb/common/images/social/youtube-20.png" /></a>--%>
<%--        &nbsp;&nbsp;<a href="https://www.youtube.com/watch?v=3EUaurjK7u8&list=PLBD6hGqefQVkBpf1YCQDFxjhLHssro_6a" style="font-weight: bold;color: #24609c;text-decoration:none;">Introduction to Biomedical Ontologies</a>--%>
<%--    </p>--%>
<%--    <p>--%>
<%--        <a href="https://www.youtube.com/watch?v=Pn7BM5rSsN4"><img src="/rgdweb/common/images/social/youtube-20.png" /></a>--%>
<%--        &nbsp;&nbsp;<a href="https://www.youtube.com/watch?v=Pn7BM5rSsN4" style="font-weight: bold;color: #24609c;text-decoration:none;">Introduction to Biomedical Nomenclature</a>--%>
<%--    </p>--%>
<%--    <p>--%>
<%--        <a href="https://www.youtube.com/watch?v=0hY9EVYa1eo"><img src="/rgdweb/common/images/social/youtube-20.png" /></a>--%>
<%--        &nbsp;&nbsp;<a href="https://www.youtube.com/watch?v=0hY9EVYa1eo" style="font-weight: bold;color: #24609c;text-decoration:none;">Gene Report Pages</a>--%>
<%--    </p>--%>
<%--    <p>--%>
<%--        <a href="https://www.youtube.com/watch?v=_VhEsfqf1JA&t=358s"><img src="/rgdweb/common/images/social/youtube-20.png" /></a>--%>
<%--        &nbsp;&nbsp;<a href="https://www.youtube.com/watch?v=_VhEsfqf1JA&t=358s" style="font-weight: bold;color: #24609c;text-decoration:none;">Variant Visualizer</a>--%>
<%--    </p>--%>
<%--    <p>--%>
<%--        <a href="https://www.youtube.com/watch?v=jGhW0VJR6Us"><img src="/rgdweb/common/images/social/youtube-20.png" /></a>--%>
<%--        &nbsp;&nbsp;<a href="https://www.youtube.com/watch?v=jGhW0VJR6Us" style="font-weight: bold;color: #24609c;text-decoration:none;">OLGA (Gene list builder and analyzer)</a>--%>
<%--    </p>--%>
<%--    <p>--%>
<%--        <a href="https://www.youtube.com/watch?v=xgxngwiLNko"><img src="/rgdweb/common/images/social/youtube-20.png" /></a>--%>
<%--        &nbsp;&nbsp;<a href="https://www.youtube.com/watch?v=xgxngwiLNko" style="font-weight: bold;color: #24609c;text-decoration:none;">GA Tool (Gene Annotator)</a>--%>
<%--    </p>--%>
<%--    <p>--%>
<%--        <a href="https://www.youtube.com/watch?v=I7XhEk72xSU"><img src="/rgdweb/common/images/social/youtube-20.png" /></a>--%>
<%--        &nbsp;&nbsp;<a href="https://www.youtube.com/watch?v=I7XhEk72xSU" style="font-weight: bold;color: #24609c;text-decoration:none;">Molecular Pathways</a>--%>
<%--    </p>--%>

    <%

        RGDNewsConfDAO dao = new RGDNewsConfDAO();
        List<RGDNewsConf> videos = dao.getAllVideos();

        for (RGDNewsConf article : videos) {
            if (article.getStrongText() == null)
            {
                out.print("<p> <a href=\""+article.getRedirectLink()+"\"><img src=\"/rgdweb/common/images/social/youtube-20.png\" /></a>&nbsp;"+
                "<a href=\""+article.getRedirectLink()+"\" style=\"font-weight: bold;color: #24609c;text-decoration:none;\"> "+article.getDisplayText()+"</a></p>");
            }
            else {
                out.print("<p> <a href=\""+article.getRedirectLink()+"\"><img src=\"/rgdweb/common/images/social/youtube-20.png\" /></a>&nbsp;"+
                        "<a href=\""+article.getRedirectLink()+"\" style=\"font-weight: bold;color: #24609c;text-decoration:none;\">"+article.getDisplayText()+
                        " <strong><span style=\"color:red\">"+article.getStrongText()+"</strong></span>" +"</a></p>");
            }
        }
    %>

</div>




