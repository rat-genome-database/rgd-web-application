<%@ page import="edu.mcw.rgd.dao.impl.RGDNewsConfDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.RGDNewsConf" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Date" %>
<%@ page import="java.text.SimpleDateFormat" %>
<hr>
<table border="0" style="width:100%; max-width:700px">
        <tr>
                <td>
                        <div class="" style="border-color: transparent;margin-top:20px;">
                                <h5 class="card-title">RGD News</h5>
                        </div>
                        
<%--                        <p><a href="/wg/news/12-10-announcing-the-release-of-mratbn7/">12/10 - Announcing the release of mRatBN7.1, the new rat genome assembly!</a></p>--%>
<%--                        <p><a href="/wg/news/rgds-2021-rat-calendar-is-available/">12/02 -  RGD's 2021 Rat Calendar is available!</a></p>--%>
<%--                        <p><a href="/wg/news/11-10-introducing-domestic-pig-resource-page/">11/10 - Introducing Domestic Pig Resource Page</a></p>--%>
<%--                        <p><a href="/wg/10-30-introducing-mouse-resource-page/">10/30 - Introducing Mouse Resource Page</a></p>--%>
<%--                        <p><a href="/wg/news/10-23-introducing-autism-rat-model-resource/">10/23 - Introducing Autism Rat Model Resource</a></p>--%>
<%--                        <p><a href="/wg/news/10-15-introducing-human-resource-page/">10/15 - Introducing Human Resource Page</a></p>--%>
<%--                        <p><a href="/wg/news/09-15-submissions-are-open-for-rgds-2021-rat-calendar/">10/13 - Submissions are STILL open for RGD’s 2021 Rat Calendar!</a></p>--%>
<%--                        <p><a href="/wg/news/07-31-introducing-dog-resource-page/">07/31 - Introducing Dog Resource Page</a></p>--%>
<%--                        <p><a href="/wg/news/07-29-rgd-releases-covid-19-resources-and-disease-portal-pages/">07/29 - RGD Releases COVID-19 Resources and Disease Portal Pages</a></p>--%>
<%--                        <p><a href="/wg/news/07-24-updated-chinchilla-resource-page/">07/24 - *Updated* Chinchilla Resource Page</a></p>--%>
<%--                        <p><a href="/wg/news/07-10-introducing-squirrel-resource-page/">07/10 - Introducing Squirrel Resource Page</a></p>--%>
<%--                        <p><a href="/wg/news/remembering-dr-mary-shimoyama/">02/28 - Remembering Dr. Mary Shimoyama</a></p>--%>



                        <%
                                RGDNewsConfDAO dao = new RGDNewsConfDAO();
                                List<RGDNewsConf> news = dao.getAllNews();
                                SimpleDateFormat format = new SimpleDateFormat("MM/dd/yyy");
                                for (RGDNewsConf article : news) {
                                        Date d = new Date(article.getDate().getTime());
                                        String date = format.format(d);
                                        if (article.getStrongText() == null)
                                                out.print("<p><a href=\"" + article.getRedirectLink() + "\">"+ date +" - "+article.getDisplayText() +"</p>");
                                        else
                                                out.print("<p><a href=\"" + article.getRedirectLink() + "\">"+ date +" - "+ article.getDisplayText() +" "
                                                        + " <strong><span style=\"color:red\">"+article.getStrongText()+"</strong></span>" +"</p>");

                                }
                        %>


                </td>
        </tr>
</table>
<hr>

