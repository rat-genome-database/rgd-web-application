<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.core.Authentication" %>
<%@ taglib prefix='c' uri='http://java.sun.com/jsp/jstl/core' %>
<%@ page import="org.springframework.security.core.context.SecurityContextHolder" %>
<%@ page import="org.springframework.security.core.Authentication" %>
<%@ page import="edu.mcw.rgd.dao.impl.MyDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.MessageCenterMessage" %>
<%@ page import="java.util.*" %>
<%@ page import="edu.mcw.rgd.web.Stamp" %>
<%@ page import="org.springframework.format.datetime.DateFormatter" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.datamodel.myrgd.MyUser" %>

<script src='https://www.google.com/recaptcha/api.js'></script>




<%
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    String name = auth.getName();



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



<form action="/rgdweb/my/account.html" method="POST" >
    <table border="0" align="center" style="border:2px outset lightgrey;background-color:#F7F7F7;padding:40px;">
        <tr>
            <td>Email Address:</td>
            <td><input type='text' name='j_username' value="" /></td></tr>
        <tr><td>&nbsp;</td></tr>
        <tr><td>Password:</td><td><input type='password' name='pass1' value=""></td></tr>
        <tr><td>Retype Password:</td><td><input type='password' name='pass2' value=""></td></tr>
        <tr><td>&nbsp;</td></tr>

        <td colspan="2" align="center">
            <div style="margin-top:5px;" class="g-recaptcha" data-sitekey="6LccGxITAAAAAKxaUj88wOc-ueTuVU2njjOHmBqW"></div>
        </td>
        <tr>
            <td  align="right"><input name="submit"  onClick="location.href=document.referrer" type="button" value="Cancel" style="font-size:16px; margin-top:20px;"></td>
            <td  align="center"><input name="submit" type="submit" value="Create Account" style="font-size:16px; margin-top:20px;"></td>
        </tr>
        <tr>
        </tr>
    </table>
</form>

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
        <td style="font-size:30px;color:#55556D;">Welcome to My RGD</td>
    </tr>
</table>

<table border="0">
    <tr>
        <td align="center">

            <table align="center">
                <tr>
                    <td>
                        <span style="font-size:16px">
                                You are signed in to MY RGD.  My RGD allows you to receive a weekly digest email that includes changes made to selected RGD genes or annotations.

                        <br>
                        To set a notification, look for the binoculars icon <img src="/rgdweb/common/images/binoculars.png" width="30" height="30" border="0"/> on any RGD gene or ontology report.
                        <br>
                        <br>
                        Check back often for new My RGD features!
                        <br><br>

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
                                <td><b>Weekly Email Digest</b> <input ng-model="msg.digest" ng-click="msg.updateDigestSetting()" type="checkbox">ON</td>
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

            <form action="/rgdweb/my/account.html" method="POST">
                <table style="border:2px solid black;padding:10px; background-color:#E4E6E5; border-radius: 15px 15px 5px 5px;"">
                    <tr>
                        <td colspan="2" style="font-weight:700; text-decoration:underline;">Change Password</td>
                    </tr>
                    <tr>
                        <td>Email Address:</td>
                        <td><%=name%></td>
                    </tr>
                    <tr>
                        <td>Old&nbsp;Password:</td>
                        <td><input name="passOld" type="password" /></td>
                    </tr>
                    <tr>
                        <td>New&nbsp;Password:</td>
                        <td><input name="pass1" type="password" /></td>
                    </tr>
                    <tr>
                        <td>Retype&nbsp;New&nbsp;Password:</td>
                        <td><input type="password" name="pass2"/></td>
                    </tr>
                    <tr>
                        <td align="center" colspan='2'><input type="submit" name="submit" value="Update Password"/></td>
                    </tr>
                </table>
            </form>

        </td>
    </tr>
</table>

</div>





<%@ include file="/common/footerarea.jsp"%>



<% } %>

