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
        padding-left:10px;
        padding-right:10px;
    }

    .searchCard p {
        line-height: 1.3;
        display: inline-block;
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
</style>

<link href="https://fonts.googleapis.com/css?family=Marcellus+SC&display=swap" rel="stylesheet">



<link href="https://fonts.googleapis.com/css?family=Marcellus+SC&display=swap" rel="stylesheet">
<style>
    .card-body {
        font-family: Alatsi;
    }
</style>

<!--
<style>
    @font-face{
        font-family: 'freshbotregular';
        src: url('http://localhost:8080/rgdweb/common/font/freshbot/freshbot-webfont.eot');
        src: url('http://localhost:8080/rgdweb/common/font/freshbot/freshbot-webfont?#iefix') format('embedded-opentype'),
        url('http://localhost:8080/rgdweb/common/font/freshbot/freshbot-webfont.woff') format('woff'),
        url('http://localhost:8080/rgdweb/common/font/freshbot/freshbot-webfont.ttf') format('truetype'),
        url('http://localhost:8080/rgdweb/common/font/freshbot/freshbot-webfont.svg#webfont') format('svg');
    }
</style>
-->
<!--<link rel="stylesheet" href="/rgdweb/common/font/freshbot/stylesheet.css" type="text/css" charset="utf-8" />-->

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





<div class=container-fluid" >
    <div class="container" >
        <div class="row">
          <div class="col-sm"  style="background-color: white;margin-bottom:5px">
              <div class="row">

              <jsp:include page="popularSearches.jsp"/>


              <jsp:include page="popularTools.jsp"/>
            </div>
          </div>
           <div class="col-sm">
               <jsp:include page="carosel.jsp"/>
               <jsp:include page="twitter.jsp"/>

           </div>
        </div>
    </div>


    <div  style="background-color: #F5F8FF;height:auto">
        <div class="container">
            <div class="row">
                <jsp:include page="tutorials.jsp"/>
            </div>
        </div>

    </div>

    <div  style="background-color: #F5F8FF;height:auto">
        <div class="container">
            <div class="row">
                <div class="card col" style="background-color: transparent;border-color: transparent;padding:0">
                    <div class="card-body" style="background-color: transparent;padding-left:0" id="rgd-conf">
                        <h5 class="card-title">Conference Watch</h5>
                            <jsp:include page="conferences.jsp"/>
                    </div>
                </div>
                <div class="card col" id="rgd-news" style="background-color: transparent;border-color:transparent;padding:0">
                    <div class="card-body" style="background-color: transparent">
                        <h5 class="card-title">Latest News</h5>
                            <jsp:include page="news.jsp"/>
                    </div>
                </div>
                <div class="card col" id="rgd-news" style="background-color: transparent;border-color:transparent;padding:0">
                    <div class="card-body" style="background-color: transparent">

                <div class="card col" style="background-color: transparent;border-color: transparent;padding:0" >
                    <div class="card-body">



                            <div class="card" style="border-color: transparent;background-color:#EFF3FC">
                                <h5 style="font-size: medium;padding:5px 0 0 5px" class="card-title">Useful Links</h5>
                            </div>
                            <br>
                            <div>
                                <p><a href="https://rgd.mcw.edu/registration-entry.shtml" style="font-weight: bold;color: #24609c;font-size: 12px"><img src="/rgdweb/common/images/submit.png" width="30px" height="30px"/>&nbsp;Submit Data </a></p>



                                <p><a href="https://rgd.mcw.edu/rgdweb/report/genomeInformation/genomeInformation.html" style="font-weight: bold;color: #24609c;font-size: 12px"><img src="/rgdweb/common/images/dna.png" width="30px" height="30px"/>Genome Information</a></p>




                                <p><a href="http://ratmine.mcw.edu/ratmine/begin.do" style="font-weight: bold;color: #24609c;font-size: 12px"><img src="/rgdweb/common/images/ratMine.png"/>&nbsp;RatMine</a></p>
                                <p><a href="https://rgd.mcw.edu/wg/gerrc/" style="font-weight: bold;color: #24609c;font-size: 12px"><img src="/rgdweb/common/images/GERRC-35.png"></a></p>

                            </div>









                    </div>
                </div>
            </div>
    </div>
</div>
<%@ include file="/common/footerarea.jsp"%>