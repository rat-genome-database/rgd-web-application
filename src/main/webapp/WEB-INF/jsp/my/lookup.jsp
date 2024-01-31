<%@ taglib prefix='c' uri='http://java.sun.com/jsp/jstl/core' %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="com.sun.mail.smtp.SMTPTransport" %>
<%@ page import="java.util.Properties" %>
<%@ page import="jakarta.mail.Session" %>
<%@ page import="jakarta.mail.internet.MimeMessage" %>
<%@ page import="jakarta.mail.internet.InternetAddress" %>
<%@ page import="jakarta.mail.Message" %>
<%@ page import="java.util.Date" %>

<script src='https://www.google.com/recaptcha/api.js'></script>


<table align="center">
    <tr>
        <td style="padding:20px;"><img src="http://rgd.mcw.edu/common/images/rgd_LOGO_blue_rgd.gif" border="0"/></td>
    </tr>
</table>


<%
    String user = (String) request.getSession().getAttribute("user");
    String name = user;
%>



<% if (name.equals("anonymousUser")) { %>


<table align="center" style="padding-bottom:20px;">
    <tr>
        <td style="font-size:30px;color:#55556D;">Reset Password</td>
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



<form action="/rgdweb/my/lookup.html" method="POST" >
    <table border="0" align="center" style="border:2px outset lightgrey;background-color:#F7F7F7;padding:40px;">
        <tr>
            <td>Email Address:</td>
            <td><input type='text' name='j_username' value="" /></td>
        </tr>
        <tr>
            <td>&nbsp;</td>
        </tr>
        <tr></tr>
        <td colspan="2" align="center">
            <div style="margin-top:5px;" class="g-recaptcha" data-sitekey="6LccGxITAAAAAKxaUj88wOc-ueTuVU2njjOHmBqW"></div>
        </td>
        <tr>
            <td  align="right"><input name="submit"  onClick="location.href=document.referrer" type="button" value="Cancel" style="font-size:16px; margin-top:20px;"></td>
            <td  align="center"><input name="submit" type="submit" value="Reset Password" style="font-size:16px; margin-top:20px;"></td>
        </tr>
        <tr>
        </tr>
    </table>
</form>

<% } else { %>

<table align="center" style="padding-bottom:20px;">
    <tr>
        <td style="font-size:30px;color:#55556D;">My RGD Account</td>
    </tr>
</table>


Name: <%=name%>




<% } %>


<%
    /*
    Properties props = System.getProperties();

props.setProperty("mail.smtp.host", "smtp.mcw.edu");
props.setProperty("mail.smtp.port", "25");

Session sess = Session.getInstance(props, null);

final MimeMessage msg = new MimeMessage(sess);

msg.setFrom(new InternetAddress("jdepons@mcw.edu"));
msg.setRecipients(Message.RecipientType.TO, InternetAddress.parse("jdepons@mcw.edu", false));

msg.setSubject("test email");
msg.setText("here is my message", "utf-8");
msg.setSentDate(new Date());

SMTPTransport t = (SMTPTransport) sess.getTransport("smtp");

t.connect();
t.sendMessage(msg, msg.getAllRecipients());
t.close();
*/
%>