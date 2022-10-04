<%@ page import="edu.mcw.rgd.datamodel.RGDNewsConf" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.dao.impl.RGDNewsConfDAO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css" type="text/css">

<script type="text/javascript" src="/rgdweb/js/util.js"></script>

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
                    <td class="label">Date of Release</td>
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
                    <%if(article.getDate()!=null){%>
                    <td><input name="releaseDate" type="text" value="<%=article.getDate()%>" maxlength="10" placeholder="yyyy-MM-dd"></input></td>
                        <%}
                        else{%>
                    <td><input name="releaseDate" type="text" maxlength="10" placeholder="yyyy-MM-dd"></input></td>
                    <% }%>
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
    function makePOSTRequest(theForm) {

        makePOSTRequest(theForm, null);
    }
    function makePOSTRequest(theForm, fnCallback) {
        alert("Updating Articles!");
        http_request = false;
        lastForm = theForm;
        onRequestCompleteCallback = fnCallback;

        if (window.XMLHttpRequest) { // Mozilla, Safari,...
            http_request = new XMLHttpRequest();
            if (http_request.overrideMimeType) {
                // set type accordingly to anticipated content type
                //http_request.overrideMimeType('text/xml');
                http_request.overrideMimeType('text/html');
            }
        } else if (window.ActiveXObject) { // IE
            try {
                http_request = new ActiveXObject("Msxml2.XMLHTTP");
            } catch (e) {
                try {
                    http_request = new ActiveXObject("Microsoft.XMLHTTP");
                } catch (e) {}
            }
        }

        if (!http_request) {
            alert('Cannot create XMLHTTP instance');
            return false;
        }

        http_request.onreadystatechange = alertContents;
        var parameters = create_request_string(theForm);
        http_request.open('POST', theForm.action, true);
        http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
        http_request.setRequestHeader("Content-length", parameters.length);
        http_request.setRequestHeader("Connection", "close");
        http_request.send(parameters);
    }

    function alertContents() {
        if (http_request.readyState == 4) {
            //if (http_request.status == 200) {
            //alert(http_request.responseText);
            result = http_request.responseText;

            if (result.indexOf("Update Successful") != -1) {
                setUpdated(lastForm);
            }
            document.getElementById('msg').innerHTML=result;
            document.getElementById('myspan').innerHTML = result;

            if( altAlertObjId!=null ) {
                document.getElementById(altAlertObjId).innerHTML = result;
                altAlertObjId = null;
            }
        }
    }
    function create_request_string(theForm) {
        var reqStr = "";

        for (i = 0; i < theForm.elements.length; i++) {
            isFormObject = false;

            switch (theForm.elements[i].tagName){
                case "INPUT":
                    switch (theForm.elements[i].type){
                        case "text":
                        case "hidden":
                            reqStr += theForm.elements[i].name + "=" + encodeURIComponent(theForm.elements[i].value);
                            isFormObject = true;
                            break;
                        case "checkbox":
                            if (theForm.elements[i].checked) {
                                reqStr += theForm.elements[i].name + "=" + theForm.elements[i].value;
                            } else {
                                reqStr += theForm.elements[i].name + "=";
                            }
                            isFormObject = true;
                            break;
                        case "radio":
                            if (theForm.elements[i].checked) {
                                reqStr += theForm.elements[i].name + "=" + theForm.elements[i].value;
                                isFormObject = true;
                            }
                    }
                    break;
                case "TEXTAREA":
                    reqStr += theForm.elements[i].name + "=" + encodeURIComponent(theForm.elements[i].value);
                    isFormObject = true;
                    break;
                case "SELECT":
                    var sel = theForm.elements[i];
                    reqStr += sel.name + "=" + sel.options[sel.selectedIndex].value;
                    isFormObject = true;
                    break;
            }

            if ((isFormObject) && ((i + 1) != theForm.elements.length)) {
                reqStr += "&";
            }
        }
        return reqStr;
    }
</script>
<%@ include file="/common/footerarea.jsp"%>