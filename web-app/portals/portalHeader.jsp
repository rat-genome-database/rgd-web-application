<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<link rel="stylesheet" href="http://rgd.mcw.edu/rgdweb/css/smoothness/jquery-ui-1.8.17.custom.css">
<link rel="SHORTCUT ICON" href="/favicon.ico" />
<link rel="stylesheet" type="text/css" href="http://rgd.mcw.edu/common/modalDialog/subModal.css" />
<link rel="stylesheet" type="text/css" href="http://rgd.mcw.edu/common/modalDialog/style.css" />
<link href="http://rgd.mcw.edu/common/style/rgd_styles-3.css" rel="stylesheet" type="text/css" />

<!-- CSS for Tab Menu #4 -->
<link rel="stylesheet" type="text/css" href="http://rgd.mcw.edu/common/style/ddcolortabs.css" />

<script type="text/javascript" src="http://rgd.mcw.edu/common/modalDialog/common.js"></script>
<script type="text/javascript" src="http://rgd.mcw.edu/common/modalDialog/subModal.js"></script>
<script type="text/javascript" src="http://rgd.mcw.edu/common/js/poll.js"></script>
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
<script src="http://rgd.mcw.edu/rgdweb/js/jquery/jquery-1.12.4.min.js"></script>
<script src="http://rgd.mcw.edu/rgdweb/js/jquery/jquery-ui-1.8.17.custom.min.js"></script>
<script src="http://rgd.mcw.edu/rgdweb/js/jquery/jquery_combo_box.js"></script>

    <link rel="stylesheet" type="text/css" href="http://rgd.mcw.edu/rgdweb/common/search.css">
    <link rel="stylesheet" type="text/css" href="http://rgd.mcw.edu/rgdweb/css/ontology.css">

<script type="text/javascript" src="http://rgd.mcw.edu/common/js/ddtabmenu.js">

/***********************************************
* DD Tab Menu script- ? Dynamic Drive DHTML code library (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code
***********************************************/

</script>

<script type="text/javascript" src="http://rgd.mcw.edu/common/js/rgdHomeFunctions-3.js">
</script>

<html>

<body>



<table width=100% style="background-color:black;" cellpadding=0>
    <tr>
        <td>
            <div class="top-bar">
                <table width="100% border="0" class="headerTable">
                <tr>
                    <td align="left" style="color:white;">&nbsp;&nbsp;&nbsp;
                    </td>
                    <td align="right" style="color:white;"><a href="/tu">Help</a>&nbsp;|&nbsp;
                        <a href="ftp://ftp.rgd.mcw.edu/pub">FTP Download</a>&nbsp;|&nbsp;
                        <a href="/wg/citing-rgd">Citing RGD</a>&nbsp;|&nbsp;

                        <a href="/contact/index.shtml">Contact Us</a>&nbsp;&nbsp;&nbsp;
                    </td>
                </tr>
</table>
</div>
</td>
</tr>
</table>


<table width="100%" border="0" cellspacing="0" cellpadding="0" style="border-bottom: 2px solid black;">
    <tr>
        <td colspan="5" bgcolor="#154062"><img src='http://rgd.mcw.edu/common/images/shim.gif' width="1" height="2">
        </td>
    </tr>
    <tr align="left" valign="top">
        <td width="440" background='http://rgd.mcw.edu//common/images/header-bkgd.gif' nowrap><img
                src="http://rgd.mcw.edu//common/dportal/images/Respiratory_Header.gif" border="0"></td>

        <td background='http://rgd.mcw.edu//common/images/header-bkgd.gif' nowrap><img
                src='http://rgd.mcw.edu//common/images/shim.gif' width="20" height="1"></td>


        <td width="100%" valign="bottom" nowrap background='http://rgd.mcw.edu//common/images/header-bkgd.gif'><a
                href="http://pga.mcw.edu"><img src='/common/images/physGen_logo2.gif' border="0"></a></td>

        <td width="240" background='http://rgd.mcw.edu//common/images/header-bkgd.gif' align="left" valign="middle"
            nowrap>
            <table border="0" cellpadding="2" cellspacing="1" width="240">
                <form method="post" action='/rgdweb/search/search.html' onSubmit="return verify(this);">
                    <input type="hidden" name="type" value="nav"/>
                    <tr>
                        <td>
                            <div class="searchBorder">
                                <table border=0 cellpadding=0 cellspacing=0>
                                    <form method="post" action='/rgdweb/search/search.html'
                                          onSubmit="return verify(this);">
                                        <input type="hidden" name="type" value="nav"/>
                                        <tr>
                                            <td class="searchKeywordLabel">Keyword&nbsp;</td>

                                            <td class="atitle" align="right"><input type=text name=term size=12 value=""
                                                                                    onFocus="JavaScript:document.forms[0].term.value=''"
                                                                                    class="searchKeywordSmall">
                                            </td>
                                            <td>
                                                <input type="image"
                                                       src="http://rgd.mcw.edu/common/images/searchGlass.gif"
                                                       class="searchButtonSmall"/>
                                            </td>
                                        </tr>
                                    </form>
                                </table>
                            </div>

                        </td>
                    </tr>
                </form>
            </table>
        </td>

        <td width="5" background='http://rgd.mcw.edu//common/images/header-bkgd.gif' nowrap><img
                src='http://rgd.mcw.edu//common/images/shim.gif' width="5" height="1"></td>
    </tr>
</table>

	<div id="mainBody">
		<div id="contentArea" class="content-area">
			<div id="layout3f7342bad77460be364638b044032ac2" class="layout default">

<a name="idP3NCutd0YL42RjiwRAMqwg" id="idP3NCutd0YL42RjiwRAMqwg"></a>






<!-- begin position 1 -->
<div class="wg-content-position">



<%

    ArrayList error = (ArrayList) request.getAttribute("error");
    if (error != null) {
        Iterator errorIt = error.iterator();
        while (errorIt.hasNext()) {
            String err = (String) errorIt.next();
            out.println("<br><span style=\"color:red;\">" + err + "</span>");
        }
        out.println("<br>");
    }

    ArrayList status = (ArrayList) request.getAttribute("status");
    if (status !=null) {
        Iterator statusIt = status.iterator();
        while (statusIt.hasNext()) {
            String stat = (String) statusIt.next();
            out.println("<br><span style=\"color:blue;\">" + stat + "</span>");
        }
        out.println("<br><br>");
    }
%>
