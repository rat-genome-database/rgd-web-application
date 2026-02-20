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
        vertical-align: middle;
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
         color:#073C66;
         text-decoration:underline;
         font-weight:700;
     }

    .speciesCardOverlay {
        position:absolute;
        background-color:#2865a3;
        min-width:63px;
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
        src: url('/rgdweb/common/font/freshbot/freshbot-webfont.eot');
        src: url('/rgdweb/common/font/freshbot/freshbot-webfont.eot?#iefix') format('embedded-opentype'),
        url('/rgdweb/common/font/freshbot/freshbot-webfont.woff2') format('woff2'),
        url('/rgdweb/common/font/freshbot/freshbot-webfont.woff') format('woff'),
        url('rgdweb/common/font/freshbot/freshbot-webfont.ttf') format('truetype'),
        url('/rgdweb/common/font/freshbot/freshbot-webfont.svg#freshbotregular') format('svg');
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
    .data-snapshot-button {
        display: block;
        width: 100%;
        padding: 14px 20px;
        background: linear-gradient(135deg, #2865a3 0%, #24609c 100%);
        color: white;
        text-decoration: none;
        border-radius: 6px;
        font-weight: 600;
        font-size: 16px;
        text-align: center;
        transition: all 0.3s ease;
        box-shadow: 0 3px 8px rgba(40, 101, 163, 0.3);
        border: none;
        box-sizing: border-box;
    }

    .data-snapshot-button:hover {
        background: linear-gradient(135deg, #1e4f7f 0%, #1d4d7a 100%);
        color: white;
        transform: translateY(-2px);
        box-shadow: 0 5px 15px rgba(40, 101, 163, 0.4);
        text-decoration: none;
    }

    .data-snapshot-button:active {
        transform: translateY(0);
        box-shadow: 0 2px 5px rgba(40, 101, 163, 0.3);
    }

    .data-snapshot-container {
        margin-top: 15px;
        margin-bottom: 30px;
        padding: 0;
    }

    /* ===== Homepage Responsive ===== */
    @media (max-width: 768px) {

        /* Notice banner full-width */
        table[width="80%"] {
            width: 95% !important;
        }

        /* Species portals: flex wrap */
        #species-portals,
        #species-portals > tbody,
        #species-portals > tbody > tr {
            display: flex !important;
            flex-wrap: wrap;
            justify-content: center;
            gap: 5px;
            padding: 8px;
        }
        #species-portals td {
            display: inline-block !important;
            width: auto !important;
        }
        #species-portals td[valign] {
            display: none !important;
        }
        .speciesIcon {
            width: 45px !important;
            height: 45px !important;
        }
        .speciesCardOverlay {
            width: 45px !important;
            height: 45px !important;
            min-width: 45px !important;
        }
        .speciesCardOverlay div {
            font-size: 8px !important;
            margin: 2px !important;
        }

        /* Main layout: stack content + sidebar */
        .hp-layout,
        .hp-layout > tbody,
        .hp-layout > tbody > tr {
            display: block !important;
            width: 100% !important;
        }
        .hp-content,
        .hp-sidebar {
            display: block !important;
            width: 100% !important;
            padding: 5px !important;
        }

        /* Search cards: flex wrap, hide separators */
        .hp-search-table,
        .hp-search-table > tbody,
        .hp-search-table > tbody > tr {
            display: flex !important;
            flex-wrap: wrap;
            justify-content: center;
            gap: 5px;
        }
        .hp-search-table td {
            display: inline-block !important;
            width: auto !important;
        }
        .hp-search-table td > img[src*="dnaSeperator"] {
            display: none !important;
        }
        .hp-search-table td:has(> img[src*="dnaSeperator"]) {
            display: none !important;
        }
        .searchCard {
            height: auto !important;
            line-height: 1.4 !important;
            padding: 10px 14px !important;
            min-width: 80px;
            background-color: #fff;
            border: 1px solid #d0d7de;
            border-radius: 6px;
        }
        .searchCard p {
            margin: 0 !important;
            padding: 0 !important;
        }

        /* Tool cards: responsive grid */
        .hp-tools-table,
        .hp-tools-table > tbody {
            display: block !important;
            width: 100% !important;
        }
        .hp-tools-table > tbody > tr {
            display: flex !important;
            flex-wrap: wrap;
            justify-content: center;
            gap: 8px;
            margin-bottom: 8px;
        }
        .hp-tools-table > tbody > tr > td {
            display: block !important;
            width: auto !important;
            padding: 0 !important;
        }
        .headerCard {
            width: 140px !important;
            min-width: 0 !important;
            margin: 3px !important;
        }
        .headerCardTitle {
            font-size: 12px !important;
            padding: 3px !important;
        }
        .headerSubTitle {
            font-size: 10px !important;
        }
        .headerCardImage {
            max-width: 90% !important;
            height: auto !important;
        }

        /* Data snapshot button */
        .data-snapshot-button {
            font-size: 14px;
            padding: 10px 15px;
        }

        /* Sidebar tutorials full-width */
        .videoTutorials {
            max-width: 100% !important;
        }

        /* Facebook embed responsive */
        .fb-page {
            width: 100% !important;
        }
        .fb-page > span,
        .fb-page > span > iframe {
            width: 100% !important;
        }
    }

    @media (max-width: 480px) {
        .speciesIcon {
            width: 35px !important;
            height: 35px !important;
        }
        .speciesCardOverlay {
            width: 35px !important;
            height: 35px !important;
            min-width: 35px !important;
        }
        .speciesCardOverlay div {
            font-size: 7px !important;
        }

        .headerCard {
            width: 110px !important;
        }
        .headerCardTitle {
            font-size: 10px !important;
        }

        .searchCard {
            min-width: 65px;
            font-size: 12px !important;
            padding: 8px 10px !important;
        }

        h5 {
            font-size: 17px !important;
        }
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

<table align="center" id="species-portals">
    <tr>

        <% if (!RgdContext.isProduction() ) { %>
        <td>
            <a style="font-size:26px;padding-right:40px;" href="/rgdweb/curation/home.html">Enter Curation Portal</a>
        </td>
        <%}%>
</table>

<table align="center" cellspacing="5" cellpadding="5" class="hp-layout">
    <tr>
        <td class="hp-content" width="780">
            <jsp:include page="/homepage/popularSearches.jsp"/>
            <jsp:include page="/homepage/popularTools.jsp"/>
            <jsp:include page="/homepage/news.jsp"/>
            <jsp:include page="/homepage/conferences.jsp"/>
            <hr>
            <jsp:include page="/homepage/scoreboard.jsp"/>
        </td>
        <td class="hp-sidebar" valign="top">
            <br>
            <div class="data-snapshot-container">
                <a href="#publicScoreboardHeader" class="data-snapshot-button">RGD Data Snapshot</a>
            </div>
            <jsp:include page="/homepage/twitter.jsp"/>
            <jsp:include page="/homepage/tutorials.jsp"/>

        </td>
    </tr>
</table>


<% if (!RgdContext.isProduction() ) { %>
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
    <tr>
        <td><a href="https://drive.google.com/drive/folders/1BasoWWlRFZFkDtRCGvmw8N1No29LYqfA">RGD Google Docs</a></td>
    </tr>
</table>

<%}%>





    <%@ include file="/common/footerarea.jsp"%>



