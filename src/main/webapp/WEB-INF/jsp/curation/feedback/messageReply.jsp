<%@ page import="edu.mcw.rgd.datamodel.FBAnswer" %>
<%@ page import="edu.mcw.rgd.datamodel.FBPerson" %>
<%@ page import="edu.mcw.rgd.datamodel.FBQuestion" %>
<%@ page import="edu.mcw.rgd.feedback.FeedbackCannedResponses" %>
<%@ page import="edu.mcw.rgd.feedback.FeedbackMessageReplyController" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="org.apache.commons.text.StringEscapeUtils" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String pageHeader="Reply to Message";
    String pageTitle="Reply to Message";
    String headContent="";
    String pageDescription = "Reply to a message submitted through the Contact Us and Send Message forms";

    FBQuestion question = (FBQuestion) request.getAttribute("question");
    List<FBPerson> curators = (List<FBPerson>) request.getAttribute("curators");
    List<FBAnswer> answers = (List<FBAnswer>) request.getAttribute("answers");
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");

    // link back to the list of messages, with the same dates the curator came from
    StringBuilder backUrl = new StringBuilder("home.html?");
    for( String param: new String[]{"token", "startDate", "endDate", "unanswered"} ) {
        String value = request.getParameter(param);
        if( value != null && !value.isEmpty() ) {
            backUrl.append(param).append("=").append(java.net.URLEncoder.encode(value, "UTF-8")).append("&");
        }
    }
    backUrl.setLength(backUrl.length() - 1);
%>
<%@ include file="/common/headerarea.jsp"%>
<style>
    .fb-reply { max-width: 1000px; }
    .fb-reply table.fb-details td { padding: 2px 15px 2px 0; vertical-align: top; }
    .fb-reply table.fb-details td:first-child { font-weight: bold; white-space: nowrap; }
    .fb-reply .fb-original { white-space: pre-wrap; word-break: break-word; border: 1px solid #ccc; border-left: 4px solid #2865a3;
        background-color: #f8f8f8; padding: 10px; margin: 10px 0 20px 0; }
    .fb-reply textarea { width: 100%; }
    .fb-reply .fb-answer-heading { font-weight: bold; margin-top: 10px; }
    .fb-reply .fb-answer { white-space: pre-wrap; word-break: break-word; border: 1px solid #ccc; border-left: 4px solid #5a9e5a;
        background-color: #f8f8f8; padding: 10px; margin: 5px 0 20px 0; }
    .fb-add-curator { border: 1px solid #ccc; background-color: #f8f8f8; padding: 10px; margin-top: 10px; }
    .fb-add-curator label { margin-right: 15px; font-weight: normal; }
    .fb-canned { margin-bottom: 8px; }
    .fb-canned label { font-weight: normal; margin-right: 8px; }
    .fb-add-curator-error { color: #b94a48; margin-top: 5px; }
</style>

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading"><%=pageHeader%></div>
</div>

<div class="container-fluid fb-reply">
    <p><a href="<%=StringEscapeUtils.escapeHtml4(backUrl.toString())%>">&laquo; Back to messages</a></p>
<%
    if( question != null ) {
        String name = (Utils.NVL(question.getFirstName(), "") + " " + Utils.NVL(question.getLastName(), "")).trim();
        // email of the sender on file, or the "Recipients email:" address in the message: the reply is emailed to it
        String email = FeedbackMessageReplyController.getReplyEmail(question);
        String institute = Utils.NVL(question.getInstitute(), "");
        String selectedCuratorId = Utils.NVL((String) request.getAttribute("selectedCuratorId"), "");
        String replyText = Utils.NVL((String) request.getAttribute("replyText"), "");

        String from = name;
        if( !email.isEmpty() ) {
            from += (from.isEmpty() ? "" : ", ") + email;
        }
        if( !institute.isEmpty() ) {
            from += (from.isEmpty() ? "" : ", ") + institute;
        }
%>
    <h4>Original Message</h4>
    <table class="fb-details">
        <tr><td>Message ID</td><td><%=question.getMessageId()%></td></tr>
        <tr><td>Date</td><td><%=question.getMessageDate()==null ? "" : dateFormat.format(question.getMessageDate())%></td></tr>
        <tr><td>Type</td><td><%=StringEscapeUtils.escapeHtml4(Utils.NVL(question.getTypeName(), ""))%></td></tr>
        <tr><td>From</td><td><% if( from.isEmpty() ) { %><i>no sender on file</i><% } else { %><%=StringEscapeUtils.escapeHtml4(from)%><% } %></td></tr>
        <tr><td>Subject</td><td><%=StringEscapeUtils.escapeHtml4(Utils.NVL(question.getSubject(), ""))%></td></tr>
    </table>
    <div class="fb-original"><%=StringEscapeUtils.escapeHtml4(Utils.NVL(question.getMessage(), ""))%></div>

    <h4>Answers (<%=answers.size()%>)</h4>
<%
        if( answers.isEmpty() ) {
%>
    <p>This message has not been answered yet.</p>
<%
        }
        for( FBAnswer answer: answers ) {
            String answeredBy = (Utils.NVL(answer.getFirstName(), "") + " " + Utils.NVL(answer.getLastName(), "")).trim();
            String answeredByEmail = Utils.NVL(answer.getEmail(), "");
            if( answeredBy.isEmpty() ) {
                answeredBy = answeredByEmail;
            } else if( !answeredByEmail.isEmpty() ) {
                answeredBy += " (" + answeredByEmail + ")";
            }
%>
    <div class="fb-answer-heading">
        <%=answer.getAnswerDate()==null ? "" : dateFormat.format(answer.getAnswerDate())%>
        <% if( !answeredBy.isEmpty() ) { %>&mdash; answered by <%=StringEscapeUtils.escapeHtml4(answeredBy)%><% } %>
    </div>
    <div class="fb-answer"><%=StringEscapeUtils.escapeHtml4(Utils.NVL(answer.getAnswer(), "").trim())%></div>
<%
        }
%>

    <h4><label for="curator">Curator</label></h4>
    <%-- the curator and the reply belong to replyForm below; they are outside of it because forms cannot be nested --%>
    <select id="curator" name="curatorId" form="replyForm" required>
        <option value="">-- select a curator --</option>
<%
        for( FBPerson curator: curators ) {
%>
        <option value="<%=curator.getPersonId()%>" <%=String.valueOf(curator.getPersonId()).equals(selectedCuratorId) ? "selected" : ""%>><%=StringEscapeUtils.escapeHtml4(FeedbackMessageReplyController.curatorLabel(curator))%></option>
<%
        }
%>
    </select>
    <button type="button" id="showAddCurator" class="btn btn-info btn-sm" style="margin-left:10px;">Add New Curator</button>
    <span id="curatorStatus" style="margin-left:10px;"></span>

    <%-- shown by the Add New Curator button; saved without reloading the page, so a reply typed below is kept --%>
    <form id="addCuratorForm" class="fb-add-curator" style="display:none;">
        <label>First name <input type="text" name="firstName" maxlength="<%=FeedbackMessageReplyController.MAX_FIRST_NAME%>" required/></label>
        <label>Last name <input type="text" name="lastName" maxlength="<%=FeedbackMessageReplyController.MAX_LAST_NAME%>" required/></label>
        <label>Email <input type="email" name="email" size="30" maxlength="<%=FeedbackMessageReplyController.MAX_EMAIL%>" required/></label>
        <button type="submit" class="btn btn-info btn-sm">Save Curator</button>
        <button type="button" id="cancelAddCurator" class="btn btn-default btn-sm">Cancel</button>
        <div id="addCuratorError" class="fb-add-curator-error"></div>
    </form>
    <br><br>

    <h4><label for="reply">Reply</label></h4>
    <%-- canned responses: the chosen one is copied into the reply box, where it can still be edited --%>
    <div class="fb-canned">
        <label for="cannedResponse">Canned response</label>
<%
        List<FeedbackCannedResponses.CannedResponse> cannedResponses = FeedbackCannedResponses.getResponses();
        org.json.JSONArray cannedTexts = new org.json.JSONArray();
        if( cannedResponses.isEmpty() ) {
%>
        <select id="cannedResponse" disabled><option value="">-- none available yet --</option></select>
<%
        } else {
%>
        <select id="cannedResponse">
            <option value="">-- select a canned response --</option>
<%
            for( int i=0; i<cannedResponses.size(); i++ ) {
                cannedTexts.put(cannedResponses.get(i).getText());
%>
            <option value="<%=i%>"><%=StringEscapeUtils.escapeHtml4(cannedResponses.get(i).getTitle())%></option>
<%
            }
%>
        </select>
        <button type="button" id="useCannedResponse" class="btn btn-info btn-sm" style="margin-left:10px;">Use Response</button>
<%
        }
%>
    </div>
    <script>
        $(function() {
            var cannedTexts = <%=cannedTexts.toString().replace("</", "<\\/")%>;

            $('#useCannedResponse').click(function() {
                var index = $('#cannedResponse').val();
                if( index === '' ) {
                    return;
                }
                var reply = $('#reply');
                if( $.trim(reply.val()) !== '' && !confirm('Replace the reply typed so far with the canned response?') ) {
                    return;
                }
                reply.val(cannedTexts[index]).focus();
            });
        });
    </script>
    <textarea id="reply" name="reply" rows="12" form="replyForm" maxlength="<%=FeedbackMessageReplyController.MAX_ANSWER%>" required><%=StringEscapeUtils.escapeHtml4(replyText)%></textarea>

    <form id="replyForm" method="post" action="messageReply.html" style="margin-top:10px;"
          onsubmit="return confirm('Save this reply and email it to <%=StringEscapeUtils.escapeHtml4(StringEscapeUtils.escapeEcmaScript(email))%>?');">
        <input type="hidden" name="act" value="sendReply"/>
        <input type="hidden" name="messageId" value="<%=question.getMessageId()%>"/>
<%
        for( String param: new String[]{"token", "startDate", "endDate", "unanswered"} ) {
            String value = request.getParameter(param);
            if( value != null && !value.isEmpty() ) {
%>
        <input type="hidden" name="<%=param%>" value="<%=StringEscapeUtils.escapeHtml4(value)%>"/>
<%
            }
        }
        if( email.isEmpty() ) {
%>
        <button type="submit" class="btn btn-info btn-md" disabled>Send</button>
        <span style="margin-left:10px;">This message has no email address to reply to.</span>
<%
        } else {
%>
        <button type="submit" class="btn btn-info btn-md">Send</button>
        <span style="margin-left:10px;">The reply will be saved and emailed to <b><%=StringEscapeUtils.escapeHtml4(email)%></b>.</span>
<%
        }
%>
    </form>

    <script>
        $(function() {
            var form = $('#addCuratorForm');

            $('#showAddCurator').click(function() {
                form.show();
                form.find('input[name=firstName]').focus();
            });

            $('#cancelAddCurator').click(function() {
                form.hide();
                form[0].reset();
                $('#addCuratorError').text('');
            });

            form.submit(function(event) {
                event.preventDefault();
                $('#addCuratorError').text('');

                var data = {
                    act: 'addCurator',
                    firstName: form.find('input[name=firstName]').val(),
                    lastName: form.find('input[name=lastName]').val(),
                    email: form.find('input[name=email]').val()
                };
                var token = new URLSearchParams(window.location.search).get('token');
                if( token ) {
                    data.token = token;
                }

                $.post('messageReply.html', data, null, 'json').done(function(result) {
                    if( result.error ) {
                        $('#addCuratorError').text(result.error);
                        return;
                    }
                    // the curator goes into the dropdown (unless already listed) and is selected
                    var select = $('#curator');
                    if( select.find('option[value="' + result.personId + '"]').length === 0 ) {
                        select.append($('<option>').val(result.personId).text(result.label));
                    }
                    select.val(String(result.personId));
                    $('#curatorStatus').text(result.message);
                    form.hide();
                    form[0].reset();
                }).fail(function() {
                    $('#addCuratorError').text('The curator could not be added. Please sign in again or try later.');
                });
            });
        });
    </script>
<%
    }
%>
</div>

<%@ include file="/common/footerarea.jsp"%>
