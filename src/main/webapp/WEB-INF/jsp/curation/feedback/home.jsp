<%@ page import="edu.mcw.rgd.datamodel.FBPerson" %>
<%@ page import="edu.mcw.rgd.datamodel.FBQuestion" %>
<%@ page import="edu.mcw.rgd.feedback.FeedbackCannedResponses" %>
<%@ page import="edu.mcw.rgd.feedback.FeedbackMessageReplyController" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Set" %>
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
            + "&amp;unanswered=" + (unansweredOnly ? "1" : "0")
            + (token != null ? "&amp;token=" + java.net.URLEncoder.encode(token, "UTF-8") : "");

    // answering the selected messages together: curators, and what was entered if the answer could not be saved
    List<FBPerson> curators = (List<FBPerson>) request.getAttribute("curators");
    String bulkCuratorId = edu.mcw.rgd.process.Utils.NVL((String) request.getAttribute("bulkCuratorId"), "");
    String bulkResponse = edu.mcw.rgd.process.Utils.NVL((String) request.getAttribute("bulkResponse"), "");
    Set<Integer> bulkMessageIds = (Set<Integer>) request.getAttribute("bulkMessageIds");
    if( bulkMessageIds == null ) {
        bulkMessageIds = new HashSet<Integer>();
    }

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
    /* answering the messages selected with the checkboxes */
    .fb-bulk { border: 1px solid #ccc; border-radius: 4px; background-color: #f8f8f8; padding: 10px 15px; margin-bottom: 15px; max-width: 1000px; }
    .fb-bulk-title { font-weight: bold; margin-bottom: 8px; }
    .fb-bulk label { margin-right: 8px; font-weight: normal; }
    .fb-bulk select { margin-right: 15px; }
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
        <label><input type="radio" name="unanswered" value="1" <%=unansweredOnly ? "checked" : ""%>/> Not answered</label>
        <label><input type="radio" name="unanswered" value="0" <%=unansweredOnly ? "" : "checked"%>/> Show all</label>
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

    <%-- one answer for all messages selected with the checkboxes of the table (the checkboxes belong to this form) --%>
    <form id="bulkForm" method="post" action="home.html" class="fb-bulk">
        <div class="fb-bulk-title">Answer the selected messages (<span id="fbSelectedCount">0</span> selected)</div>
        <input type="hidden" name="act" value="bulkAnswer"/>
        <% if( token != null ) { %><input type="hidden" name="token" value="<%=StringEscapeUtils.escapeHtml4(token)%>"/><% } %>
        <input type="hidden" name="startDate" value="<%=startDate%>"/>
        <input type="hidden" name="endDate" value="<%=endDate%>"/>
        <input type="hidden" name="unanswered" value="<%=unansweredOnly ? "1" : "0"%>"/>

        <label for="bulkCurator">Curator</label>
        <select id="bulkCurator" name="curatorId" required>
            <option value="">-- select a curator --</option>
<%
    for( FBPerson curator: curators ) {
%>
            <option value="<%=curator.getPersonId()%>" <%=String.valueOf(curator.getPersonId()).equals(bulkCuratorId) ? "selected" : ""%>><%=StringEscapeUtils.escapeHtml4(FeedbackMessageReplyController.curatorLabel(curator))%></option>
<%
    }
%>
        </select>

        <%-- a canned response is saved and emailed to the senders; "hidden" is only saved, so the messages count as answered --%>
        <label for="bulkResponse">Response</label>
        <select id="bulkResponse" name="response" required>
            <option value="">-- select a response --</option>
<%
    List<FeedbackCannedResponses.CannedResponse> cannedResponses = FeedbackCannedResponses.getResponses();
    for( int i=0; i<cannedResponses.size(); i++ ) {
%>
            <option value="<%=i%>" <%=String.valueOf(i).equals(bulkResponse) ? "selected" : ""%>>Email: <%=StringEscapeUtils.escapeHtml4(cannedResponses.get(i).getTitle())%></option>
<%
    }
%>
            <option value="hidden" <%="hidden".equals(bulkResponse) ? "selected" : ""%>>Hide: save the answer "hidden", no email</option>
        </select>

        <button type="submit" class="btn btn-info btn-md">Apply to Selected Messages</button>
    </form>

    <table id="feedbackQuestions" class="tablesorter">
        <thead><tr>
            <th class="sorter-false"><input type="checkbox" id="fbSelectAll" title="Select all messages in the list"/></th>
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
                <td><input type="checkbox" class="fb-select" name="messageIds" value="<%=q.getMessageId()%>" form="bulkForm" <%=bulkMessageIds.contains(q.getMessageId()) ? "checked" : ""%>/></td>
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

        // checkboxes of the rows: the selected messages are answered together by the form above the table
        var boxes = $('#feedbackQuestions .fb-select');
        function selectedCount() {
            var count = boxes.filter(':checked').length;
            $('#fbSelectedCount').text(count);
            $('#fbSelectAll').prop('checked', count > 0 && count === boxes.length);
            return count;
        }
        boxes.change(selectedCount);
        $('#fbSelectAll').change(function() {
            boxes.prop('checked', this.checked);
            selectedCount();
        });
        selectedCount();

        $('#bulkForm').submit(function() {
            var count = selectedCount();
            if( count === 0 ) {
                alert('Please select at least one message with the checkboxes in the list.');
                return false;
            }
            var messages = count === 1 ? 'the selected message' : 'the ' + count + ' selected messages';
            if( $('#bulkResponse').val() === 'hidden' ) {
                return confirm('Save the answer "hidden" for ' + messages + ' without sending any email?');
            }
            var title = $.trim($('#bulkResponse option:selected').text()).replace(/^Email: /, '');
            return confirm('Save the canned response "' + title + '" for ' + messages
                + ' and email it to ' + (count === 1 ? 'its sender' : 'their senders') + '?');
        });
    });
</script>

<%@ include file="/common/footerarea.jsp"%>
