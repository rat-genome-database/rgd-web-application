<%@ page import="edu.mcw.rgd.datamodel.RGDNewsConf" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.RGDNewsConfDAO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" type="text/css">

<script type="text/javascript" src="/rgdweb/js/util.js"></script>
<script type="text/javascript" src="/rgdweb/js/editFunctions.js"></script>

<%
    FormUtility fu = new FormUtility();

    String pageTitle = "Edit Object";
    String headContent = "";
    String pageDescription = "";

    RGDNewsConfDAO newsConfDAO = new RGDNewsConfDAO();
    String contentType = request.getParameter("content");
    List<RGDNewsConf> articles = new ArrayList<>();
    if (contentType.equals("NEWS"))
        articles = newsConfDAO.getAllNews();
    else if (contentType.equals("CONFERENCE"))
        articles = newsConfDAO.getAllConferences();
    else
        articles = newsConfDAO.getAllVideos();

    List list = new ArrayList();
    list.add("NEWS");
    list.add("CONFERENCE");
    list.add("VIDEO");

%>

<%@ include file="/common/headerarea.jsp"%>

<h3>RGD Articles to edit</h3>
<%
    if (articles.isEmpty())
        out.print("No articles found");
    else{        %>

<html>
<form action="updateNewsConf.html">
            <table>
                <tbody>
                <tr><td><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
                <td><input type="hidden" name="contentType" value="<%=contentType%>"></td></tr>
                <tr> <%--          Column names          --%>
                    <%if(!contentType.equals("VIDEO")){%>
                    <td class="label">Date of Release</td>
                    <%}%>
                    <td class="label">Display Text</td>
                    <td class="label">Redirect Link</td>
                    <td class="label">Strong Alert message (Red text)</td>
                    <td class="label">Content Type</td>
                </tr>
<%
        int count = 1;
            for (RGDNewsConf article : articles){
                String strong = article.getStrongText();
                if (strong == null || strong.trim().isEmpty())
                    strong = "";%>

                <tr id="articleRow<%=count%>">
                    <%if(!contentType.equals("VIDEO")){
                        if(article.getDate()!=null){%>
                    <td><input name="releaseDate" type="text" value="<%=article.getDate()%>" maxlength="10" placeholder="yyyy-MM-dd"></input></td>
                        <%}
                        else{%>
                    <td><input name="releaseDate" type="text" maxlength="10" placeholder="yyyy-MM-dd"></input></td>
                    <% }
                    }%>
                    <td><input name="displayTxt" size="75" value="<%=article.getDisplayText()%>"></input></td>
                    <td><input name="redirectLink" size="75" value="<%=article.getRedirectLink()%>"></input></td>
                    <td><input name="Strong" size="75" value="<%=strong%>"></input></td>
                    <td><%=fu.buildSelectList("contentList",list, contentType)%></td>
                        <td align="right">
                            <a style="color:red; font-weight:700;"
                               href="javascript:removeArticle('articleRow<%=count%>') ;void(0);"><img
                                    src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
                </tr>
                <%
                count++;
            }
            %>
                </tbody>
            </table>
</form>
</html>
<%
    }
%>
<script>
    function removeArticle(rowId) {
        var d = document.getElementById(rowId);
        d.parentNode.removeChild(d);
    }
</script>
<%@ include file="/common/footerarea.jsp"%>