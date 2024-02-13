<%@ page import="edu.mcw.rgd.security.UserManager" %>
<%@ taglib prefix='c' uri='http://java.sun.com/jsp/jstl/core' %>
<%@ taglib prefix='c' uri='http://java.sun.com/jsp/jstl/core' %>

<%
    String user = UserManager.getInstance().getMyUser(request).getUsername();

%>

<%
    String pageTitle = "MY RGD Log-in";
    String headContent = "";
    String pageDescription = "Log in to your RGD account";
%>

<%@ include file="/common/headerarea.jsp" %>

<!-- twitter boot strap model -->

<br><br>
<table align="center">
    <tr>
        <td style="font-size:20px;">Sign in with your RGD account</td>
    </tr>
</table>



<c:if test="${not empty param.login_error}">
    <table align="center" style="padding:20px;">
         <tr>
             <td>
                <span style="color:red;">
                Your login attempt was not successful, please try again.
                </span>
             </td>
         </tr>
    </table>
</c:if>


    <form action="<c:url value='/rgdweb/j_spring_security_check'/>" method="POST">
  <table align="center" border=0 style="border:2px outset lightgrey;background-color:#F7F7F7;padding:40px;">
    <tr>
        <td>Email Address:</td>
        <td><input type='text' size='30' id="j_username" name='j_username' value="" <c:if test="${not empty param.login_error}">value='<c:out value="${ACEGI_SECURITY_LAST_USERNAME}"/>'</c:if>></td></tr>
    <tr><td>Password:</td><td><input  size='30' type='password' id="j_password" name='j_password' value=""></td></tr>

    <!--<tr><td><input type="checkbox" name="j_spring_security_remember_me"></td><td>Don't ask for my password for two weeks</td></tr>-->

      <tr>
          <td align="center" colspan="2">
              <table cellpadding="5">
                  <tr>
                      <td><input name="submit"  onClick="location.href='/rgdweb'" type="button" value="Cancel" style="font-size:16px; margin-top:20px;"></td>
                      <!--<td><input name="submit" type="submit" value="Log In" style="font-size:16px; margin-top:20px;"></td>-->
                      <td><input style="font-size:16px; margin-top:20px;" name="submit" type="submit" value="Log In"></td>
                  </tr>
              </table>
          </td>
      </tr>
    </tr>
  </table>

</form>


    <table align="center" border="0">
        <tr>
            <td>
                <a href="/rgdweb/my/account.html?submit=Create" style="font-size:16px; margin-right:10px;">Create New Account</a>
            </td>
            <td>
                <a href="/rgdweb/my/lookup.html" style="font-size:16px;">Recover Password</a>
            </td>
        </tr>
    </table>




<%@ include file="/common/footerarea.jsp" %>
