<%@ page import="edu.mcw.rgd.datamodel.FBQuestion" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%
    String pageHeader="User Messages";
    String pageTitle="User Messages";
    String headContent="";
    String pageDescription = "Messages submitted through the Contact Us and Send Message forms";

    List<FBQuestion> questions = (List<FBQuestion>) request.getAttribute("questions");
    String startDate = (String) request.getAttribute("startDate");
    String endDate = (String) request.getAttribute("endDate");
    String token = request.getParameter("token");
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    // the reply page gets the token and the dates, so its link back returns to this same list
    boolean unansweredOnly = Boolean.TRUE.equals(request.getAttribute("unansweredOnly"));
    String replyParams = "&amp;startDate=" + startDate + "&amp;endDate=" + endDate
            + (unansweredOnly ? "&amp;unanswered=1" : "")
            + (token != null ? "&amp;token=" + java.net.URLEncoder.encode(token, "UTF-8") : "");

    int unanswered = 0;
    for( FBQuestion q: questions ) {
        if( q.getAnswerCount() == 0 ) {
            unanswered++;
        }
    }
%>
<%@ include file="/common/headerarea.jsp"%>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.js"> </script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.widgets.js"></script>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>
<style>
    #feedbackQuestions td { vertical-align: top; }
    #feedbackQuestions { width: 100%; }
    /* the message is the most important column: it gets all the width the other columns do not need */
    #feedbackQuestions .fb-message-col { width: 60%; }
    #feedbackQuestions .fb-message { white-space: pre-wrap; word-break: break-word; max-height: 12em; overflow-y: auto; }
    #feedbackQuestions .fb-from { max-width: 220px; word-break: break-word; }
    #feedbackQuestions .fb-subject { max-width: 180px; word-break: break-word; }
    #feedbackQuestions .fb-nowrap { white-space: nowrap; }
    .fb-unanswered { color: #b94a48; font-weight: bold; }
    /* the dates, the filter and the button are boxed together: a change takes effect when the button is clicked */
    .fb-filter { display: inline-block; border: 1px solid #2865a3; border-radius: 4px; background-color: #f2f6fa; padding: 10px 15px; }
    .fb-filter.fb-changed { border-color: #c77700; background-color: #fff6e5; }
    .fb-filter-title { font-weight: bold; margin-bottom: 8px; }
    .fb-filter label { margin-right: 15px; font-weight: normal; }
    .fb-filter-changed { margin-left: 10px; font-weight: bold; color: #a65f00; }
</style>

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading"><%=pageHeader%></div>
</div>

<div class="container-fluid">

    <form method="get" action="home.html" class="fb-filter" id="fbFilter">
        <div class="fb-filter-title">Messages to show</div>
        <% if( token != null ) { %><input type="hidden" name="token" value="<%=StringEscapeUtils.escapeHtml4(token)%>"/><% } %>
        <label>Start date <input type="date" name="startDate" value="<%=startDate%>" required/></label>
        <label>End date <input type="date" name="endDate" value="<%=endDate%>" required/></label>
        <label><input type="radio" name="unanswered" value="0" <%=unansweredOnly ? "" : "checked"%>/> Show all</label>
        <label><input type="radio" name="unanswered" value="1" <%=unansweredOnly ? "checked" : ""%>/> Not answered</label>
        <button type="submit" class="btn btn-info btn-md">Show Messages</button>
        <%-- appears when a date or the filter is changed: the list below is not updated until the button is clicked --%>
        <span id="fbFilterChanged" class="fb-filter-changed" style="display:none;">Click Show Messages to update the list.</span>
    </form>
    <br>

<% if( unansweredOnly ) { %>
    <p><b><%=questions.size()%></b> messages submitted from <%=startDate%> through <%=endDate%> have not been answered.</p>
<% } else { %>
    <p><b><%=questions.size()%></b> messages submitted from <%=startDate%> through <%=endDate%>;
        <b><%=unanswered%></b> not answered.</p>
<% } %>

    <table id="feedbackQuestions" class="tablesorter">
        <thead><tr>
            <th>Date</th>
            <th>ID</th>
            <th>Type</th>
            <th>From</th>
            <th>Subject</th>
            <th class="fb-message-col">Message</th>
            <th>Answers</th>
            <th class="sorter-false"></th>
        </tr></thead>
        <tbody>
<%
    for( FBQuestion q: questions ) {
        String name = (edu.mcw.rgd.process.Utils.NVL(q.getFirstName(), "") + " " + edu.mcw.rgd.process.Utils.NVL(q.getLastName(), "")).trim();
        // email of the sender on file, or the "Recipients email:" address in the message: a reply is emailed to it
        String email = edu.mcw.rgd.feedback.FeedbackMessageReplyController.getReplyEmail(q);
        String institute = edu.mcw.rgd.process.Utils.NVL(q.getInstitute(), "");
%>
            <tr>
                <td class="fb-nowrap"><%=q.getMessageDate()==null ? "" : dateFormat.format(q.getMessageDate())%></td>
                <td><%=q.getMessageId()%></td>
                <td><%=StringEscapeUtils.escapeHtml4(edu.mcw.rgd.process.Utils.NVL(q.getTypeName(), ""))%></td>
                <td class="fb-from">
                    <% if( name.isEmpty() && email.isEmpty() ) { %>
                        <i>no sender on file</i>
                    <% } else { %>
                        <%=StringEscapeUtils.escapeHtml4(name)%>
                        <% if( !email.isEmpty() ) { %><br><%=StringEscapeUtils.escapeHtml4(email)%><% } %>
                        <% if( !institute.isEmpty() ) { %><br><%=StringEscapeUtils.escapeHtml4(institute)%><% } %>
                    <% } %>
                </td>
                <td class="fb-subject"><%=StringEscapeUtils.escapeHtml4(edu.mcw.rgd.process.Utils.NVL(q.getSubject(), ""))%></td>
                <td><div class="fb-message"><%=StringEscapeUtils.escapeHtml4(edu.mcw.rgd.process.Utils.NVL(q.getMessage(), ""))%></div></td>
                <td class="fb-nowrap"><% if( q.getAnswerCount() == 0 ) { %><span class="fb-unanswered">not answered</span><% } else { %><%=q.getAnswerCount()%><% } %></td>
                <td><a class="btn btn-info btn-sm" href="messageReply.html?messageId=<%=q.getMessageId()%><%=replyParams%>">Reply</a></td>
            </tr>
<%
    }
%>
        </tbody>
    </table>
</div>

<script>
    $(function() {
        $('#feedbackQuestions').tablesorter({ theme: 'blue', widgets: ['zebra'] });

        // a changed date or filter does nothing until Show Messages is clicked: the box says so
        $('#fbFilter').on('change input', 'input', function() {
            $('#fbFilter').addClass('fb-changed');
            $('#fbFilterChanged').show();
        });
    });
</script>

<%@ include file="/common/footerarea.jsp"%>
