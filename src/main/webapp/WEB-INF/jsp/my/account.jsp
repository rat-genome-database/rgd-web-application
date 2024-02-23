<%@ taglib prefix='c' uri='http://java.sun.com/jsp/jstl/core' %>
<%@ page import="edu.mcw.rgd.dao.impl.MyDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.MessageCenterMessage" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.web.Stamp" %>
<%@ page import="org.springframework.format.datetime.DateFormatter" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.datamodel.myrgd.MyUser" %>
<%@ page import="edu.mcw.rgd.security.UserManager" %>


<%
    String name = UserManager.getInstance().getMyUser(request).getUsername();

%>



<% if (name.equals("anonymousUser")) { %>


<table align="center">
    <tr>
        <td style="padding:20px;"><img src="http://rgd.mcw.edu/common/images/rgd_LOGO_blue_rgd.gif" border="0"/></td>
    </tr>
</table>

<table align="center" style="padding-bottom:20px;">
    <tr>
        <td style="font-size:30px;color:#55556D;">Create RGD Account</td>
    </tr>
</table>

<%

    ArrayList error = (ArrayList) request.getAttribute("error");
    if (error != null) {
        Iterator errorIt = error.iterator();
        while (errorIt.hasNext()) {
            String err = (String) errorIt.next();
            out.println("<div align=\"center\" style=\"padding-bottom:12px; color:red;\">" + err + "</div>");
        }
    }

    ArrayList status = (ArrayList) request.getAttribute("status");
    if (status !=null) {
        Iterator statusIt = status.iterator();
        while (statusIt.hasNext()) {
            String stat = (String) statusIt.next();
            out.println("<div align=\"center\" style=\"padding-bottom:12px; color:blue;\">" + stat + "</div>");
        }
    }
%>





<% } else { %>


<%
    String pageTitle = "My RGD Account";
    String headContent = "";
    String pageDescription = "";

    MyDAO mdao = new MyDAO();
    MyUser user = mdao.getMyUser(name);

    String digest = "false";

    if (user.isSendDigest()) {
        digest="true";
    }


%>

<%@ include file="/common/headerarea.jsp"%>



<script>
    rgdModule.controller('MessageCenterController', [
        '$scope','$http',
        function ($scope, $http) {

            var ctrl = this;

            this.messages=[];
            ctrl.digest=<%=digest%>;

            ctrl.deleteMessage = function (messageId) {
                $http({
                    method: 'POST',
                    data: {mid: messageId},
                    url: "/rgdweb/webservice/my.html?method=deleteMessageCenterMessage",
                }).then(function successCallback(response) {

                    ctrl.messages=response.data;

                }, function errorCallback(response) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                });
            }

            ctrl.getMessages = function () {
                $http({
                    method: 'POST',
                    //data: {mid: messageId},
                    url: "/rgdweb/webservice/my.html?method=getMessageCenterMessages",
                }).then(function successCallback(response) {

                    ctrl.messages=response.data;

                }, function errorCallback(response) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                });
            }

            ctrl.updateDigestSetting = function () {

                $http({
                    method: 'POST',
                    data: {digest: ctrl.digest},
                    url: "/rgdweb/webservice/my.html?method=updateDigestSetting",
                }).then(function successCallback(response) {

                }, function errorCallback(response) {
                    // called asynchronously if an error occurs
                    // or server returns response with an error status.
                });
            }



            angular.element(document).ready(function () {
                //alert("about to call set user");

                ctrl.getMessages();

            });


        }




    ]);
</script>


<div ng-controller="MessageCenterController as msg">


    <table align="center" style="padding-bottom:20px;">
    <tr>
        <td style="font-size:26px;color:#55556D;">Welcome {{username}}</td>
    </tr>
</table>

    <div style='border:1px solid black;padding:10px;'>
    RGD has retired its legacy login system.  We are now using Google to authenticate.   If you previously used an email address tied to a Google account your login will work as it did before.  <br><br>If you used an email account that is not registered with Google you have 3 options...
    <ol>
    <li>Create a Google account using the email address previously used to register on RGD.  <a href='https://support.google.com/accounts/answer/27441?hl=en'>https://support.google.com/accounts/answer/27441?hl=en</a></li>
    <li>Use the RGD contact us form to request RGD migrate your notification to an existing Google account.</li>
    <li>Do nothing.  Your notification will continue to be sent even if you do not update your account.   You will not be able to add new notification or modify existing ones.</li>
    </ol>
    <br>If you have question, RGD can be contacted by way of the <a href='http://localhost:8080/rgdweb/contact/contactus.html'>RGD Contact Page</a>
    </div>

    <br><br>
<table border="0">
    <tr>
        <td align="center">

            <table align="center">
                <tr>
                    <td>
                        <span style="font-size:16px">
                                You are signed in and can subscribe to updates.

                        <br>
                        To set a notification, look for the binoculars icon <img src="/rgdweb/common/images/binoculars.png" width="30" height="30" border="0"/> on any RGD gene or ontology report.
                               <br><br><input type="button" class="btn btn-info btn-sm"  value="Manage Subscriptions" ng-click="rgd.loadMyRgd($event)" style="background-color:#2B84C8;padding:1px 10px;font-size:12px;line-height:1.5;border-radius:3px"/>
                        <br>
                        <br>


                        </span>
                    </td>
                </tr>
                <tr>
                    <td>
                        <%

                            java.util.List<MessageCenterMessage> msgs= mdao.getAllMessagesFromMessageCenter(name);


                        %>

                        <table>
                            <tr>
                                <td>
                                    My RGD allows you to receive a weekly digest email that includes changes made to selected RGD genes or annotations.  Uncheck the box below to disable this feature.
                                </td>
                            </tr>
                            <tr>
                                <td><b>Weekly Email Digest&nbsp;&nbsp;&nbsp;</b> <input ng-model="msg.digest" ng-click="msg.updateDigestSetting()" type="checkbox">&nbsp;ON</td>
                            </tr>
                        </table>
                        <br>


                        <table style="border:2px solid black; padding:5px; background-color:#E4E6E5; border-radius: 15px 15px 5px 5px;" width="700">
                            <tr>
                                <td style="font-weight:700; text-decoration:underline;">Message Center</td>
                            </tr>

                            <tr>
                                <td>
                                    <div style="border:1px solid black; padding:5px; background-color:#E4E6E5;">
                                            <% if (msgs.size()==0) { %>
                                                0 Messages Found
                                            <% } %>

                                            <div ng-repeat="message in msg.messages" style="display:table-row;">
                                                   <div style="display: table-cell; float:left; margin-right:10px; min-width: 100px;">{{message.createdDate}}</div>
                                                   <div style="display: table-cell; float:left;  margin-right:10px; min-width: 300px;"><a  target="_blank" href="/rgdweb/my/msg.html?mid={{message.id}}">{{message.title}}</a></div>
                                                   <div style="display: table-cell; float:left;  margin-right:10px; min-width: 100px;" ><img style="cursor: pointer;" ng-click="msg.deleteMessage(message.id)" src="/rgdweb/common/images/del.jpg" /></div
                                            </div>
                                    </div>


                                </td>
                            </tr>

                        </table>

                    </td>
                </tr>
            </table>


        </td>
        <td width="400" align="center" valign="top">


        </td>
    </tr>
</table>

</div>





<%@ include file="/common/footerarea.jsp"%>



<% } %>

