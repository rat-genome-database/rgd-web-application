<%@ page import="java.util.LinkedHashMap" %>


<%
    String pageTitle = "Rat Genome Database";
    String headContent = "";
    String pageDescription = "The Rat Genome Database houses genomic, genetic, functional, physiological, pathway and disease data for the laboratory rat as well as comparative data for mouse and human.  The site also hosts data mining and analysis tools for rat genomics and physiology";
%>
<%@ include file="/common/headerarea.jsp"%>

<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.8.2/css/all.css" integrity="sha384-oS3vJWv+0UjzBfQzYUhtDYW+Pj2yciDJxpsK1OYPAYjqT085Qq/1cq5FLXAZQ7Ay" crossorigin="anonymous">
<style>
   #rgd-news a{
       text-decoration: none;
   }
    #rgd-conf a{
        text-decoration: none;
    }
    h5{
        color:#24609c;
        font-weight: bold;
        font-size: 20px;
    }
   .hp-video-tut{
       background-color: transparent;
       border-color: transparent;
   }
   .carousel-inner h5{
        color:white;
   }
   .carousel-inner p{
       color:white;
       font-size: 20px;
       font-weight: bold;
   }

   .carousel-inner{
       width:100%;
       max-height: 400px !important;
   }

    .speciesIcon {
        border:1px solid black;
        padding:3px;

    }
    .speciesIconList {
        padding-bottom:3px;
    }

</style>

<style>
    .searchCard {
        line-height:63px;
        text-align: center;
        height:63px;
        z-index:30;
        opacity:1;
        font-size:14px;
        text-decoration:none;
        padding-left:11px;
        padding-right:11px;
    }

    .searchCard p {
        line-height: 1.3;
        display: inline-block;
        font-size:14px;
        ertical-align: middle;
    }

    .searchCard:hover p {
        color:white;
    }

    .searchCard:hover {
        opacity:.5;
        cursor:pointer;
        background-color:#2865a3;
        color:white;

    }

     a {
         color:#0C1D2E;
         olor:#073C66;
         text-decoration:underline;
         ont-weight:700;
     }

    .speciesCardOverlay {
        position:absolute;
        background-color:#2865a3;
        minWidth:63px;
        width:63px;
        height:63px;
        z-index:30;
        opacity:0;
    }

    .speciesCardOverlay:hover {
        opacity:.9;
        cursor:pointer;
        color:white;

    }

</style>


<link href="https://fonts.googleapis.com/css?family=Marcellus+SC&display=swap" rel="stylesheet">
<style>
    .card-body {
        font-family: Alatsi;
    }
</style>

<style>
    @font-face {
        font-family: 'freshbotregular';
        src: url('http://localhost:8080/rgdweb/common/font/freshbot/freshbot-webfont.eot');
        src: url('http://localhost:8080/rgdweb/common/font/freshbot/freshbot-webfont.eot?#iefix') format('embedded-opentype'),
        url('http://localhost:8080/rgdweb/common/font/freshbot/freshbot-webfont.woff2') format('woff2'),
        url('http://localhost:8080/rgdweb/common/font/freshbot/freshbot-webfont.woff') format('woff'),
        url('http://localhost:8080/rgdweb/common/font/freshbot/freshbot-webfont.ttf') format('truetype'),
        url('http://localhost:8080/rgdweb/common/font/freshbot/freshbot-webfont.svg#freshbotregular') format('svg');
        font-weight: normal;
        font-style: normal;

    }
</style>


<link href="https://fonts.googleapis.com/css?family=Lobster&display=swap" rel="stylesheet">


<style>
    .rgdContainer {
        width: 100%;
        padding-right: 15px;
        padding-left: 15px;
        margin-right: auto;
        margin-left: auto;
    }
</style>
<!--
<table align=center ><tr><td style="color:red;"> NOTICE: Due to a systems upgrade, portions of RGD may be unavailable Sunday October 3rd</td></tr></table>
<br><br>
-->
<script>
    function covidPortal() {
        //location.href="https://rgd.mcw.edu/wg/portals/covid-19-disease-portal-related-links/";
    }
</script>
<table style="border:2px; background-color:#eaf2f8; solid: #8A0000;margin-bottom:10px;" align="center" width="80%">
    <tr>
    <td style="padding:8px;">
        <table align="center">
            <tr>
                <td ><span style="font-size:14px;color:black;">&nbsp;This repository is under review for potential modification in compliance with Administration directives.</span></td>
            </tr>
        </table>
    </td>
    </tr>
    </table>

<table align="center">
    <tr>

        <% if (RgdContext.getHostname().equals("pipelines.rgd.mcw.edu") || RgdContext.getHostname().equals("dev.rgd.mcw.edu") ) { %>
        <td>
            <a style="font-size:26px;padding-right:40px;" href="/rgdweb/curation/home.html">Enter Curation Portal</a>
        </td>
        <%}%>
        <td>
            <img style="margin-right:10px;" src="/rgdweb/common/images/species/ratI.png"   border="0"  class="speciesIcon"/>
        </td>

        <td valign="center">
            <table border="0">
                <tr>
                    <!--<td><span style="font-family: 'Marcellus SC', serif;font-size:14px;">Species Specific Portals</span></td>-->
                    <td><span style="font-family: 'Source Code Pro', monospace;font-size:14px; margin-right:8px;">Other Species Portals</span></td>
                </tr>
                <tr>
                    <td><img src="/rgdweb/common/images/blueArrow.png" border=0 ></td>
                </tr>
            </table>
        </td>

        <td>
            <a class="speciesCardOverlay" href="/wg/species/human/">
                <div style="margin:5px; font-weight:700;">Human</div>
            </a>
            <img src="/rgdweb/common/images/species/humanI.png"  border="0"  class="speciesIcon"/>
        </td>
                <td>
                    <a class="speciesCardOverlay" href="/wg/species/mouse">
                        <div style="margin:5px; font-weight:700;">Mouse</div>
                    </a>
                    <img src="/rgdweb/common/images/species/mouseI.jpg"  border="0"  class="speciesIcon"/></td>
        <td>
            <a class="speciesCardOverlay" href="/wg/species/chinchilla">
                <div style="margin:3px; font-weight:700;">Chinchilla</div>
            </a>
            <img src="/rgdweb/common/images/species/chinchillaI.jpg"   border="0"  class="speciesIcon"/></td>
        <td>
            <a class="speciesCardOverlay" href="/wg/species/dog">
                <div style="margin:5px; font-weight:700;">Domestic Dog</div>
            </a>
            <img src="/rgdweb/common/images/species/dogI.jpg"   border="0"  class="speciesIcon"/>

        </td>
        <td>
            <a class="speciesCardOverlay" href="/wg/species/squirrel">
                <div style="margin:5px; font-weight:700;font-size:11px;">Thirteen Lined Ground Squirrel</div>
            </a>
            <img src="/rgdweb/common/images/species/squirrelI.jpg"  border="0"  class="speciesIcon"/>
        </td>
        <td>
            <a class="speciesCardOverlay" href="/wg/species/bonobo">
                <div style="margin:5px; font-weight:700;">Bonobo</div>
            </a>
            <img src="/rgdweb/common/images/species/bonoboI.jpg"  border="0"  class="speciesIcon"/></td>
        <td>
            <a class="speciesCardOverlay" href="/wg/species/pig">
                <div style="margin:5px; font-weight:700;">Domestic Pig</div>
            </a>
            <img src="/rgdweb/common/images/species/pigI.png"  border="0"  class="speciesIcon"/></td>

        <td>
            <a class="speciesCardOverlay" href="/wg/species/mole-rat">
                <div style="margin:5px; font-weight:700;">Naked Mole Rat</div>
            </a>
            <img src="/rgdweb/common/images/species/mole-ratI.png"  border="0" class="speciesIcon" /></td>
        <td>
            <a class="speciesCardOverlay" href="/wg/species/green-monkey">
                <div style="margin:5px; font-weight:700;">African Green Monkey</div>
            </a>
            <img src="/rgdweb/common/images/species/green-monkeyI.png"  border="0"  class="speciesIcon"/></td>
     </tr>
</table>

<table align="center" cellspacing="5" cellpadding="5">
    <tr>
        <td width="780">
            <jsp:include page="/homepage/popularSearches.jsp"/>
            <jsp:include page="/homepage/popularTools.jsp"/>
            <jsp:include page="/homepage/news.jsp"/>
            <jsp:include page="/homepage/conferences.jsp"/>
            <hr>
            <jsp:include page="/homepage/scoreboard.jsp"/>
        </td>
        <td valign="top">
            <br>
            <jsp:include page="/homepage/twitter.jsp"/>
            <jsp:include page="/homepage/tutorials.jsp"/>

        </td>
    </tr>
</table>


<% if (RgdContext.getHostname().equals("pipelines.rgd.mcw.edu") || RgdContext.getHostname().equals("dev.rgd.mcw.edu") ) { %>
<table style="border: 1px solid black;">
    <tr>
        <td style="color:white; font-weight:700; background-color:black;">RGD Zoom Links</td>
    </tr>
    <tr>
        <td><a href="https://zoom.us/j/909448652?pwd=SlZUQ0FsZ0w0Nko0Ym1kUWx3TjE5dz09">Developer Zoom Channel </a></td>
    </tr>
    <tr>
        <td><a href="https://mcw-edu.zoom.us/j/965121883?pwd=SEVIbStmaEV6UlJvYk16a2J1VHVXZz09">Curation Zoom Channel </a></td>
    </tr>
    <tr>
        <td><a href="https://mcw-edu.zoom.us/j/97077035993?pwd=cHk3QlE1UzBaeTY5NmVQQzVnc3dKUT09">SCGE Toolkit Zoom Channel </a></td>
    </tr>
    <tr>
        <td><a href="https://mcw-edu.zoom.us/j/99583555634?pwd=TnVra0ZQYTMzcG5tYzl5c1pFNGV3dz09">Alliance Scrum Zoom Channel </a></td>
    </tr>
</table>

<%}%>





    <%@ include file="/common/footerarea.jsp"%>



