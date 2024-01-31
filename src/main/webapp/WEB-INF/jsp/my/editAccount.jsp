<%@ taglib prefix='c' uri='http://java.sun.com/jsp/jstl/core' %>

<script src='https://www.google.com/recaptcha/api.js'></script>


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



<form action="/rgdweb/my/account.html" method="get" >
    <table border="0" align="center" style="border:2px outset lightgrey;background-color:#F7F7F7;padding:40px;">
        <tr>
            <td>Email Address:</td>
            <td><input type='text' name='j_username' value="" <c:if test="${not empty param.login_error}">value='<c:out value="${ACEGI_SECURITY_LAST_USERNAME}"/>'</c:if>></td></tr>
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


