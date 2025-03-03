<%@ page import="edu.mcw.rgd.dao.impl.RGDNewsConfDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.RGDNewsConf" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Date" %>
<div class="" style="border-color: transparent;margin-top:20px;">
        <h5 class="card-title">Conferences, Courses and Workshops</h5>
</div>
<table style="width: 690px" class="conference">

 <%
                        RGDNewsConfDAO dao = new RGDNewsConfDAO();
                        List<RGDNewsConf> articles = dao.getAllConferences();
                        SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyy");
                        for (RGDNewsConf article : articles) { %>
        <tr>
                <%
                                Date d = new Date(article.getDate().getTime());
                                String date = format.format(d);
                                if (article.getStrongText() == null)
                                        out.print("<td><a href=\"" + article.getRedirectLink() + "\">"+ date +" - "+article.getDisplayText() +"</td>");
                                else
                                        out.print("<td><a href=\"" + article.getRedirectLink() + "\">"+ date +" - "+ article.getDisplayText() +" "
                                                + " <strong><span style=\"color:red\">"+article.getStrongText()+"</strong></span>" +"</td>");

                             %>
                </tr>
                <%
                        }
                %>
        </tr>
</table>

<style>
        .conference td {
                padding-bottom: 1em;
        }
</style>