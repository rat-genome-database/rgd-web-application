<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.Iterator" %>
<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.OntologyXDAO" %>
<%@ page import="edu.mcw.rgd.dao.impl.PortalDAO" %>
<%@ page import="edu.mcw.rgd.datamodel.Portal" %>


<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta name="keywords" content="rat genome database,rat genome,rgd">
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
<meta name="author" content="RGD">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" /><meta name="generator" content="WebGUI 7.9.16" /><meta http-equiv="Content-Script-Type" content="text/javascript" /><meta http-equiv="Content-Style-Type" content="text/css" /><script type="text/javascript">function getWebguiProperty (propName) {var props = new Array();props["extrasURL"] = "/extras/";props["pageURL"] = "/wg/template";props["firstDayOfWeek"] = "0";return props[propName];}</script><link href="/wg/layout.css" rel="stylesheet" type="text/css" /><!--page layout--><meta http-equiv="Pragma" content="no-cache" /><meta http-equiv="Cache-Control" content="no-cache, must-revalidate, max-age=0, private" /><meta http-equiv="Expires" content="0" />
  <%
        if (!pageDescription.equals("")) {
    %>
        <meta name="description" content="<%=pageDescription%>" />
    <% } %>

    <%=headContent%>
    <title><%=pageTitle%></title>

    <link rel="stylesheet" href="/rgdweb/css/smoothness/jquery-ui-1.8.17.custom.css">
<link rel="SHORTCUT ICON" href="/favicon.ico" />
<link rel="stylesheet" type="text/css" href="/common/modalDialog/subModal.css" />
<link rel="stylesheet" type="text/css" href="/common/modalDialog/style.css" />
<link href="http://rgd.mcw.edu/common/style/rgd_styles-3.css" rel="stylesheet" type="text/css" />

<!-- CSS for Tab Menu #4 -->
<link rel="stylesheet" type="text/css" href="/common/style/ddcolortabs.css" />

<script type="text/javascript" src="/common/modalDialog/common.js"></script>
<script type="text/javascript" src="/common/modalDialog/subModal.js"></script>
<script type="text/javascript" src="/common/js/poll.js"></script>
<script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
</script>
    <script src="/rgdweb/js/jquery/jquery-1.12.4.min.js"></script>
    <script src="/rgdweb/js/jquery/jquery-ui-1.8.17.custom.min.js"></script>
    <script src="/rgdweb/js/jquery/jquery_combo_box.js"></script>

<script type="text/javascript">
_uacct = "UA-2739107-2";
urchinTracker();
</script>


<script type="text/javascript" src="/common/js/ddtabmenu.js">

/***********************************************
* DD Tab Menu script- � Dynamic Drive DHTML code library (www.dynamicdrive.com)
* This notice MUST stay intact for legal use
* Visit Dynamic Drive at http://www.dynamicdrive.com/ for full source code
***********************************************/

</script>

<script type="text/javascript" src="/common/js/rgdHomeFunctions-3.js">
</script>

</head>

<body>
<table class="wrapperTable" cellpadding="0" cellspacing="0" border="0">
<tr>
<td>
<div class="wrapper">

<div id="main">

<table width=100% style="background-color:black;" cellpadding=0 border=0>
    <tr>
        <td>
            <div class="top-bar">
                <table width="100% border="0" class="headerTable">
                <tr>
                    <td align="left" style="color:white;">&nbsp;&nbsp;&nbsp;<a href="/" style="font-size:14px;font-weight:700;"><<<< Bach to RGD</a> </td>
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

    AnnotationDAO adao = new AnnotationDAO();
    HttpRequestFacade req = new HttpRequestFacade(request);
    OntologyXDAO xdao = new OntologyXDAO();
    PortalDAO pdao = new PortalDAO();
%>
