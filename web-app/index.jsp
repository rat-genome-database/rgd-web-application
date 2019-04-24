
<%
    String pageTitle = "Rat Genome Database";
    String headContent = "";
    String pageDescription = "The Rat Genome Database houses genomic, genetic, functional, physiological, pathway and disease data for the laboratory rat as well as comparative data for mouse and human.  The site also hosts data mining and analysis tools for rat genomics and physiology";
%>
<%@ include file="/common/headerarea.jsp"%>
<style>
   #rgd-news a{
       text-decoration: none;
   }
    #rgd-conf a{
        text-decoration: none;
    }
</style>
<div class="container-fluid">
<br>
<br>

<div class="content" >
    <table align="center">
        <tbody>
        <tr>
            <td>
                <div style="float: left;">
                    <div id="genes" class="image_item">
                        <div class="icon"><a title="Search genes" href="/rgdweb/search/genes.html?100"><img src="https://rgd.mcw.edu/common/images/gene_image.jpg" width="100" height="50" border="0" /></a></div>
                        <div class="title"><a title="RGD" href="/rgdweb/search/genes.html?100">Genes</a></div>
                        <div class="description">Map positions, functions and more</div>
                    </div>
                    <div id="ontologies" class="image_item">
                        <div class="icon"><a title="Ontology Annotations" href="/rgdweb/ontology/search.html"><img src="https://rgd.mcw.edu/common/images/function_image.jpg" width="100" height="50" border="0" /></a></div>
                        <div class="title"><a title="Rat Genome Database - Ontology Annotations" href="/rgdweb/ontology/search.html">Ontologies</a></div>
                        <div class="description">Gene Ontology, Phenotype, Pathway</div>
                    </div>
                    <div id="genome" class="image_item">
                        <div class="icon"><a title="Rat JBrowse Genome Browser" href="https://rgd.mcw.edu/jbrowse?data=data_rgd6"><img src="https://rgd.mcw.edu/common/images/genome_image2.jpg" width="100" height="50" border="0" /></a></div>
                        <div class="title"><a title="Rat JBrowse Genome Browser" href="https://rgd.mcw.edu/jbrowse?data=data_rgd6">Rat JBrowse</a></div>
                        <div class="description">Genome browser</div>
                    </div>
                </div>
            </td>
            <td>
                <div style="float: right;">
                    <div id="strains" class="image_item">
                        <div class="icon"><a title="RGD Strains" href="/rgdweb/search/strains.html?100"><img src="https://rgd.mcw.edu/common/images/strain_image.jpg" width="100" height="50" border="0" /></a></div>
                        <div class="title"><a title="RGD Strains" href="/rgdweb/search/strains.html?100">Strains</a></div>
                        <div class="description">Search Strains</div>
                    </div>
                    <div id="diseases" class="image_item">
                        <div class="icon"><a title="Rat Genome Database - RGD Disease Portals" href="/wg/portals?100"><img src="https://rgd.mcw.edu/common/images/disease_image2.jpg" width="100" height="50" border="0" /></a></div>
                        <div class="title"><a title="Rat Genome Database - RGD Disease Portals" href="/wg/portals?100">Diseases</a></div>
                        <div class="description">Genes, QTL &amp; Strains related to Disease</div>
                    </div>
                    <div id="tools" class="image_item">
                        <div class="icon"><a title="RGD" href="/wg/tool-menu?100"><img src="https://rgd.mcw.edu/common/images/snplotyper_image.jpg" width="100" height="50" border="0" /></a></div>
                        <div class="small-title"><a title="RGD" href="/wg/tool-menu?100">Analysis &amp; Visualization</a></div>
                        <div class="description">Data mining, visualization</div>
                    </div>
                </div>
            </td>
            <td valign="top">
                <div style="float: right;">
                    <div id="qtl" class="image_item">
                        <div class="icon"><a title="QTLs Query Form" href="/rgdweb/search/qtls.html?100"><img src="https://rgd.mcw.edu/common/images/qtl_image.jpg" width="100" height="50" border="0" /></a></div>
                        <div class="title"><a title="QTLs Query Form" href="/rgdweb/search/qtls.html?100">QTL</a></div>
                        <div class="description">Phenotypes &amp; Traits linked to the genome</div>
                    </div>
                    <div id="physiology" class="image_item">
                        <div class="icon"><a href="/wg/physiology?100"><img src="https://rgd.mcw.edu/common/images/physiology_image.jpg" width="100" height="50" border="0" /></a></div>
                        <div class="small-title"><a href="/wg/physiology?100">Phenotypes &amp; Models</a></div>
                        <div class="description">Phenotype data, Assays, Husbandry and more</div>
                    </div>
                    <div id="pathway" class="image_item">
                        <div class="icon"><a href="/wg/home/pathway2?100"><img src="https://rgd.mcw.edu/common/images/pathway_image.jpg" width="100" height="50" border="0" /></a></div>
                        <div class="title"><a href="/wg/home/pathway2?100">Pathways</a></div>
                        <div class="description">Pathway reports and diagrams</div>
                    </div>
                </div>
            </td>
            <td rowspan="3">
                <div class="content">
                    <script type="text/javascript" src="https:/rgd.mcw.edu/common/js/tabber.js"></script><br />
                    <script type="text/javascript" src="https://rgd.mcw.edu/common/js/slideshow.js"></script>
                    <div id="slideshow">
                        <div class="controls" >
                            <table>
                                <tbody>
                                <tr>
                                    <td><a id="previous" style="display:none;" href="javascript:previous()">&laquo; previous</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                    <td><a id="start" style="display:none;" href="javascript:start()">slideshow</a><a id="stop" style="display:none;" href="javascript:stop()">stop</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
                                    <td><a id="next" style="display:none;" href="javascript:next()">next &raquo;</a></td>
                                </tr>
                                </tbody>
                            </table>
                        </div>
                        <table border="0" cellspacing="0" cellpadding="0">
                            <tbody>
                            <tr>
                                <td valign="top">
                                    <div class="items">
                                        <p><!--____________________________________________________________________________________________--></p>
                                        <div id="Ensembl" class="item">
                                            <div class="ad-box-item2">
                                                <table>
                                                    <tbody>
                                                    <tr>
                                                        <td>
                                                            <table>
                                                                <tbody>
                                                                <tr>
                                                                    <td class="title" colspan="2">Ensembl Genes</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="title" valign="top">in RGD</td>
                                                                    <td><img src="https://rgd.mcw.edu/common/images/shim.gif" /></td>
                                                                </tr>
                                                                </tbody>
                                                            </table>
                                                            <p><span style="font-size: small;"><a style="text-decoration: none;" href="/wg/news/https-rgd-mcw-edu-wg-11-26-ensembl-tracks-now-on-jbrowse/"><b>RGD&#8217;s JBrowse now has Ensembl genes for Rnor 6.0. Click here to find out more and to see the data.</b></a></span></td>
                                                        <td><img src="https://rgd.mcw.edu/common/images/JBrowse.Asip.PNG" width="150" height="100" /></td>
                                                    </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <p><!--____________________________________________________________________________________________--></p>
                                        <div id="bonobos" class="item">
                                            <div class="ad-box-item2">
                                                <table>
                                                    <tbody>
                                                    <tr>
                                                        <td>
                                                            <table>
                                                                <tbody>
                                                                <tr>
                                                                    <td class="title" colspan="2">Bonobo Genes</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="title" valign="top">in RGD</td>
                                                                    <td><img src="https://rgd.mcw.edu/common/images/shim.gif" /></td>
                                                                </tr>
                                                                </tbody>
                                                            </table>
                                                            <p><span style="font-size: small;"><a style="text-decoration: none;" href="https://rgd.mcw.edu/wg/bonobo/"><b>RGD has included genes for the bonobo. Click here to find out more and to see the data.</b></a></span></td>
                                                        <td><img src="https://rgd.mcw.edu/common/images/bonobobanner.png" /></td>
                                                    </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <p><!--____________________________________________________________________________________________--></p>
                                        <div id="devdisease" class="item">
                                            <div class="ad-box-item2">
                                                <table>
                                                    <tbody>
                                                    <tr>
                                                        <td>
                                                            <table>
                                                                <tbody>
                                                                <tr>
                                                                    <td class="title" colspan="2">Developmental Disease</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="title" valign="top">Portal</td>
                                                                    <td><img src="https://rgd.mcw.edu/common/images/shim.gif" /></td>
                                                                </tr>
                                                                </tbody>
                                                            </table>
                                                            <p><span style="font-size: small;"><a style="text-decoration: none;" href="https://rgd.mcw.edu/wg/news/n1/"><b>RGD announces the release of the Developmental Disease Portal. Click here to learn more!</b></a></span></td>
                                                        <td><img src="https://rgd.mcw.edu/common/images/devdisease_150x163.png" /></td>
                                                    </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <p><!--____________________________________________________________________________________________--></p>
                                        <div id="doggenes" class="item">
                                            <div class="ad-box-item2">
                                                <table>
                                                    <tbody>
                                                    <tr>
                                                        <td>
                                                            <table>
                                                                <tbody>
                                                                <tr>
                                                                    <td class="title" colspan="2">RGD Introduces</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="title" valign="top">Dog Genes</td>
                                                                    <td><img src="https://rgd.mcw.edu/common/images/shim.gif" /></td>
                                                                </tr>
                                                                </tbody>
                                                            </table>
                                                            <p><span style="font-size: small;"><a style="text-decoration: none;" href="https://rgd.mcw.edu/wg/doggenes/"><b>RGD has added dog genes to the database. Click here</b></a> for details.</span></td>
                                                        <td><img src="https://rgd.mcw.edu/common/images/boxerbanner.png" /></td>
                                                    </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <p><!--____________________________________________________________________________________________--></p>
                                        <div id="updatePMP" class="item">
                                            <div class="ad-box-item2">
                                                <table>
                                                    <tbody>
                                                    <tr>
                                                        <td>
                                                            <table>
                                                                <tbody>
                                                                <tr>
                                                                    <td class="title" colspan="2">Phenotypes and</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="title" valign="middle">Models Portal</td>
                                                                    <td><img src="https://rgd.mcw.edu/common/images/Updated_Yellow4_75x30.png" /></td>
                                                                </tr>
                                                                </tbody>
                                                            </table>
                                                            <p><span style="font-size: small;"><a style="text-decoration: none;" href="/wg/news/01-28-rgd-releases-an-updated-phenotypes-and-models-portal/"><b>Click here to learn more about the new look and added functionality of RGD&#8217;s updated Phenotypes and Models Portal and to check out the new portal for yourself!</b></a></span></td>
                                                        <td><img src="https://rgd.mcw.edu/common/images/UpdatedPMPortal_101x120.png" /></td>
                                                    </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <p><!--____________________________________________________________________________________________--></p>
                                        <div id="chinchilla" class="item">
                                            <div class="ad-box-item2">
                                                <table>
                                                    <tbody>
                                                    <tr>
                                                        <td>
                                                            <table>
                                                                <tbody>
                                                                <tr>
                                                                    <td class="title" colspan="2">RGD Adds</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="title" valign="top">Chinchilla Data</td>
                                                                    <td><img src="https://rgd.mcw.edu/common/images/shim.gif" /></td>
                                                                </tr>
                                                                </tbody>
                                                            </table>
                                                            <p><span style="font-size: small;"><a style="text-decoration: none;" href="https://rgd.mcw.edu/wg/chinchilla_news/"><b>RGD now includes chinchilla genes. Click here to investigate new annotations.</b></a></span></td>
                                                        <td><img src="https://rgd.mcw.edu/common/images/chinchillabanner.png" /></td>
                                                    </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <p><!--____________________________________________________________________________________________--></p>
                                        <div id="2019calendar" class="item">
                                            <div class="ad-box-item2">
                                                <table>
                                                    <tbody>
                                                    <tr>
                                                        <td>
                                                            <table>
                                                                <tbody>
                                                                <tr>
                                                                    <td class="title" colspan="2">RGD&#8217;s 2019</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="title" valign="top">Calendar</td>
                                                                    <td><img src="https://rgd.mcw.edu/common/images/shim.gif" /></td>
                                                                </tr>
                                                                </tbody>
                                                            </table>
                                                            <p><span style="font-size: small;"><a style="text-decoration: none;" href="/wg/news/woohoo-2019-calendars-are-here/"><b>A few copies of the 2019 RGD Calendar are still available. Click here to learn more.</b></a></span></td>
                                                        <td><img src="https://rgd.mcw.edu/common/images/RGD_2019_Calendar_Cover_120x120.png" /></td>
                                                    </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <p><!--____________________________________________________________________________________________--></p>
                                        <div id="squirrel" class="item">
                                            <div class="ad-box-item2">
                                                <table>
                                                    <tbody>
                                                    <tr>
                                                        <td>
                                                            <table>
                                                                <tbody>
                                                                <tr>
                                                                    <td class="title" colspan="2">RGD Welcomes</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="title" valign="top">Squirrel!</td>
                                                                    <td><img src="https://rgd.mcw.edu/common/images/shim.gif" /></td>
                                                                </tr>
                                                                </tbody>
                                                            </table>
                                                            <p><span style="font-size: small;"><a style="text-decoration: none;" href="https://rgd.mcw.edu/wg/squirrel/"><b>RGD has added genes for the thirteen-lined ground squirrel. Click here to learn more and explore our new data!</b></a></span></td>
                                                        <td><img src="https://rgd.mcw.edu/common/images/Squirrel_150x137.png" /></td>
                                                    </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <p><!--____________________________________________________________________________________________--></p>
                                        <div id="ureacycle" class="item">
                                            <div class="ad-box-item2">
                                                <table>
                                                    <tbody>
                                                    <tr>
                                                        <td>
                                                            <table>
                                                                <tbody>
                                                                <tr>
                                                                    <td class="title" colspan="2">Urea Cycle Pathway</td>
                                                                </tr>
                                                                <tr>
                                                                    <td class="title" valign="top">Diagram Update</td>
                                                                    <td><img src="https://rgd.mcw.edu/common/images/Updated_Yellow4_75x30.png" /></td>
                                                                </tr>
                                                                </tbody>
                                                            </table>
                                                            <p><span style="font-size: small;"><a style="text-decoration: none;" href="https://rgd.mcw.edu/wg/2018/05/04/ureacyclepathwayupdate/"><b>Click here to view an updated, expanded diagram page for this important nitrogen homeostasis pathway. </b></a></span></td>
                                                        <td><img src="https://rgd.mcw.edu/common/images/ureacycacpwupdbanner.png" /></td>
                                                    </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                        <p><script>
                                            var myFunc = new Function("location.href='https://rgd.mcw.edu/wg/news/woohoo-2019-calendars-are-here/';");
                                            document.getElementById("2019calendar").onclick=myFunc;
                                            var myFunc = new Function("location.href='https://rgd.mcw.edu/wg/doggenes/';");
                                            document.getElementById("doggenes").onclick=myFunc;
                                            var myFunc = new Function("location.href='https://rgd.mcw.edu/wg/news/n3/';");
                                           // document.getElementById("fehomeopws").onclick=myFunc;
                                            var myFunc = new Function("location.href='https://rgd.mcw.edu/wg/bonobo/';");
                                            document.getElementById("bonobos").onclick=myFunc;
                                            var myFunc = new Function("location.href='https://rgd.mcw.edu/wg/news/01-28-rgd-releases-an-updated-phenotypes-and-models-portal/';");
                                            document.getElementById("updatePMP").onclick=myFunc;
                                            var myFunc = new Function("location.href='https://rgd.mcw.edu/wg/squirrel/';");
                                            document.getElementById("squirrel").onclick=myFunc;
                                            var myFunc = new Function("location.href='https://rgd.mcw.edu/wg/news/n1/';");
                                            document.getElementById("devdisease").onclick=myFunc;
                                            var myFunc = new Function("location.href='https://rgd.mcw.edu/wg/chinchilla_news/';");
                                            document.getElementById("chinchilla").onclick=myFunc;
                                            var myFunc = new Function("location.href='https://rgd.mcw.edu/wg/2018/05/04/ureacyclepathwayupdate/';");
                                            document.getElementById("ureacycle").onclick=myFunc;
                                        </script></p>
                                    </div>



                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </div>
                    <p><!-- end position 3 --></p>
                    <!--/div-->
                </div>
            </td>
        </tr>
        </tbody>
    </table>
</div>

<br><br>
    <!--div class="layoutColumnPadding"-->
<div class="container-fluid" style="background-color: #EDF0F9;height:1200px">
<div class="container" style="padding:2%">
<div class="row " style="width:74%;float:left">
    <div class="col-md-6 content">

            <div class="strain-article-title">Featured RGD Video Tutorials</div>
            <div class="card" style="background-color: transparent;border-color:transparent">
                <div class="card-body">
                    <table border="0" cellspacing="0" cellpadding="10">
                        <tbody>
                        <tr>
                            <td><a title="Watch the tutorial video about RGD's JBrowse genome browser" href="/wg/home/rgd_rat_community_videos/jbrowse-genome-browser"><img style="border: 1px solid black;" src="https://rgd.mcw.edu/common/images/jbrowseplay.png" width="105" height="50" /></a></td>
                            <td>
                                <h4 style="font-size: 10px;"><a title="Watch the tutorial video about RGD's JBrowse genome browser" href="/wg/home/rgd_rat_community_videos/jbrowse-genome-browser">JBrowse Genome Browser</a></h4>
                                <p>&nbsp;</p>
                                <p>This video will demonstrate how to use the RGD JBrowse Genome Browser. The JBrowse Genome Browser allows the user to view objects such as genes, variants, QTLs, and so forth in their genomic context. You can view versions for Rat, Human and Mouse.</td>
                            <td><img src="https://rgd.mcw.edu/common/images/shim.gif" width="1" height="1" /></td>
                        </tr>
                        <tr>
                            <td><a title="Watch the tutorial video about RGD's Interactive Pathway Diagrams" href="/wg/home/rgd_rat_community_videos/molecular-pathway-diagrams" target="_self"><img style="border: 1px solid black;" src="https://rgd.mcw.edu/common/images/mpdiagramsplay.png" width="105" height="50" /></a></td>
                            <td colspan="2">
                                <h4 style="font-size: 10px;"><a title="Watch the tutorial video about RGD's Interactive Pathway Diagrams" href="/wg/home/rgd_rat_community_videos/molecular-pathway-diagrams" target="_self">Molecular Pathway Diagrams</a></h4>
                                <p><strong><br />
                                </strong></p>
                                <p>This video will demonstrate how to use the RGD Molecular Pathway Diagrams. You can access the Ontology Report for the pathway, view the description for the pathway with its various interactions and components, and you can click on any of the pathway&#8217;s interactive features to view more information about that entity.</td>
                        </tr>
                        <tr>
                            <td><a title="PhenoGen Informatics Genome/Transcriptome Data and Browser hands-on workshop video" href="/wg/home/rgd_rat_community_videos/other-videos-of-interest/outside-videos2/phenogen-informatics-genome/transcriptome-data-and-browser" target="_self"><img style="border: 1px solid black;" src="https://rgd.mcw.edu/common/images/PG_workshop_video_Arrow_105x50.png" width="105" height="50" /></a></td>
                            <td colspan="2">
                                <h4><a title="PhenoGen Informatics Genome/Transcriptome Data and Browser hands-on workshop video" href="/wg/home/rgd_rat_community_videos/other-videos-of-interest/outside-videos2/phenogen-informatics-genome/transcriptome-data-and-browser" target="_self">PhenoGen Informatics Genome/Transcriptome Data and Browser</a></h4>
                                <p>RGD has been providing links from our gene pages to the <strong>PhenoGen Informatics Genome/Transcriptome Data Browser</strong>, but there&#8217;s a good chance you don&#8217;t know all there is to know about the tool. Want more information about how to use it so you can get the most out of its data and functionality? This informative hands-on workshop video is just the tutorial to help you with that!</td>
                        </tr>
                        </tbody>
                    </table>
                    <table border="0" cellspacing="0" cellpadding="10">
                        <tbody>
                        <tr>
                            <td colspan="2"><img src="https://rgd.mcw.edu/common/images/shim.gif" width="1" height="1" /></td>
                        </tr>
                        <tr valign="middle">
                            <td colspan="2"><strong><a title="RGD's Rat Community Videos page" href="/wg/home/rgd_rat_community_videos/" target="_self">Click here</a></strong> to access RGD&#8217;s <strong>Rat Community Videos</strong> page.  This page includes all of the tutorial videos that RGD has produced, plus other videos of interest to rat researchers.</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>


    </div>

     <div class="card col-md-6" style="background-color: transparent;border-color: transparent">
         <div class="strain-article-title">Conference Watch</div>
                    <div class="card-body" style="background-color: transparent" id="rgd-conf">

                            <p ><a href="https://www.toxicology.org/events/am/AM2019/registration.asp" target="_blank" rel="noopener">58th Annual Meeting of the Society of Toxicology &amp; ToxExpo, Baltimore Convention Center, Baltimore, MD, USA &#8211; March 10-14, 2019</a></p>
                            <p><a href="https://10times.com/experimental-biology-orlando" target="_blank" rel="noopener">Experimental Biology 2019, Rosen Centre Hotel, Orlando, FL, USA, April 6-10, 2019</a></p>
                            <p ><a href="https://www.biocuration2019.org/" target="_blank" rel="noopener">Biocuration 2019, The 12th International Biocuration Conference, West Road Concert Hall, Cambridge, UK &#8211; April 7-10, 2019</a></p>
                            <p ><a href="http://wiki.geneontology.org/index.php/Consortium_Meetings_and_Workshops#2019" target="_blank" rel="noopener">Gene Ontology Consortium Meeting, Cambridge, UK, April 11-13, 2019</a></p>
                            <p ><a href="https://www.amia.org/cic2019?gclid=CjwKCAiA4t_iBRApEiwAn-vt-3lRwhE34586XKVO3-7YblkFfpsJpEV_eUG4hP493lsCQ6mOd5Wv_BoCggUQAvD_BwE" target="_blank" rel="noopener">AMIA 2019 Clinical Informatics Conference, W Atlanta Midtown Hotel, Atlanta, GA, USA &#8211; April 30-May 2, 2019</a></p>
                            <p ><a href="https://meetings.cshl.edu/meetings.aspx?meet=GENOME&amp;year=19" target="_blank" rel="noopener">The Biology of Genomes, Cold Spring Harbor, NY, USA &#8211; May 7-11, 2019; Abstract deadline: February 15, 2019</a></p>
                            <p ><a href="https://ibangs.memberclicks.net/assets/media/IBANGS%202019%20.png" target="_blank" rel="noopener">21st International Behavioural and Neural Genetics Society (IBANGS) Meeting, University of Edinburgh, Edinburgh, Scotland, May 10-14, 2019</a></p>
                            <p ><a href="https://www.iscb.org/glbio2019" target="_blank" rel="noopener">Great Lakes Bioinformatics Conference, Union South building, UW Madison, Madison, WI, USA &#8211; May 19-22, 2019; Abstract deadline (oral presentations): March 11, 2019</a></p>
                            <p ><a href="https://meetings.cshl.edu/meetings.aspx?meet=SYMP&amp;year=19" target="_blank" rel="noopener">84th Symposium: RNA Control &amp; Regulation, Cold Spring Harbor, NY, USA &#8211; May 29-June 3, 2019; Abstract deadline: March 8, 2019</a></p>
                            <p ><a href="http://ratgenes.org/ctc2019/" target="_blank" rel="noopener">17th Annual Meeting of the Complex Traits Consortium/Rat Genomics, Medical Education and Telemedicine building, UCSD, La Jolla, CA, USA &#8211; June 8-11, 2019</a></p>
                            <p ><a href="https://meetings.cshl.edu/meetings.aspx?meet=BIOME&amp;year=19" target="_blank" rel="noopener">Microbiome, Cold Spring Harbor, NY, USA &#8211; July 18-21, 2019; Abstract deadline: May 3, 2019</a></p>
                            <p ><a href="https://www.iscb.org/ismbeccb2019" target="_blank" rel="noopener">27th Conference on Intelligent Systems for Molecular Biology/18th European Conference on Computational Biology, Congress Center Basel, Basel, Switzerland &#8211; July 21-25, 2019; Abstract deadline: April 11, 2019</a></p>
                            <p ><a href="https://sites.google.com/view/icbo2019" target="_blank" rel="noopener">10th International Conference on Biomedical Ontology, Buffalo, NY, USA &#8211; July 29-August 2, 2019; Abstract deadline: May 15, 2019</a></p>
                            <p ><a href="https://www.amia.org/amia2019" target="_blank" rel="noopener">AMIA 2019 Annual Symposium, Washington, DC, USA &#8211; November 16-20, 2019; Submission deadline: March 13, 2019</a></p>

                    </div>
                </div>
    </div>
<!--td class="secondColumn" valign="top" width="40%"--><!-- begin position 3 -->
    <div style="float:right;width:25%">
        <div class="card" id="rgd-news" style="background-color: transparent;border-color:transparent">
            <card-header class="strain-article-title">Latest News</card-header>
            <div class="card-body" style="background-color: transparent">

                    <p > <a href="/wg/news/01-28-rgd-releases-an-updated-phenotypes-and-models-portal/">01/28 &#8211; RGD releases an updated Phenotypes and Models Portal</a></p>
                    <p ><a href="/wg/news/01-16-save-the-date-for-the-complex-trait-consortium-rat-genomics-meeting-ctc-rg/">01/16 &#8211; Save the date for the Complex Trait Consortium / Rat Genomics meeting (CTC/RG)</a></p>
                    <p><a href="/wg/news/woohoo-2019-calendars-are-here/">11/28 &#8211; Woo-Hoo! 2019 RGD Calendars have arrived! Click for details.</a></p>
                    <p ><a href="/wg/news/https-rgd-mcw-edu-wg-11-26-ensembl-tracks-now-on-jbrowse/">11/26 &#8211; Ensembl tracks now available on JBrowse for Rnor 6.0</a></p>
                    <p><a href="https://rgd.mcw.edu/wg/2018/05/04/ureacyclepathwayupdate/">05/07 &#8211; RGD releases an updated, expanded interactive diagram page for the urea cycle pathway</a></p>
                    <p><a href="/wg/news/n4">12/01 &#8211; RGD now offers links to human expression data at GTEx</a></p>
                    <p><a href="/wg/news/n3">10/20 &#8211; The Alliance of Genome Resources&#8217; 1.0 release is now available</a></p>
                    <p><a href="/wg/news/n1">09/06 &#8211; RGD releases the Developmental Disease Portal</a></p>
                    <p><a href="https://rgd.mcw.edu/wg/doggenes/">06/11 &#8211; RGD has added dog genes to the database</a></p>

            </div>
        </div>
        <br>
        <div class="card" style="background-color: transparent;border-color: transparent" >
            <div class="card-body">
            <a class="twitter-timeline" data-width="99%" data-height="550" data-theme="light" ata-border-color="#cc0000" href="https://twitter.com/ratgenome?ref_src=twsrc%5Etfw">Tweets by ratgenome</a>
            <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script><br />
            </div>
        </div>
    </div>
</div>
</div>
</div>
<%@ include file="/common/footerarea.jsp"%>