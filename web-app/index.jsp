
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
</style>
<div class="container-fluid">
<br>
<br>

<div class="container content">
    <div class="card" style="border-color: transparent;">
        <div class="row">
          <div class="col-sm-8">
                <div class="row">
                    <div class="card col"  style="width: 18rem;height:200px">
                        <p style="font-weight: bold;color: #24609c;font-size: 14px">Multi Ontology Enrichment Tool</p>
                        <img src="/rgdweb/images/MOET.png" height="70%"  border="0" />
                    </div>
                    <div class="card col"  style="width: 18rem;height:200px" >
                        <p style="font-weight: bold;color: #24609c;font-size: 14px">Pathways</p>
                        <img src="/rgdweb/images/pathway.png" border="0" />
                    </div>

                    <div class="card col" style="width: 18rem;height:200px">
                        <p style="font-weight: bold;color: #24609c;font-size: 14px">Phenotype Ranges</p>
                        <img src="/rgdweb/images/expectedRanges.png"  height="70%" border="0" />
                    </div>
                </div>
              <div class="row">
                  <div class="card col" style="width: 18rem;height:200px">
                      <p style="font-weight: bold;color: #24609c;font-size: 14px">Disease Navigator</p>
                      <img src="/rgdweb/common/images/diseaseNavLogo75.png" height="70%" width="70%" border="0" />
                  </div>
                  <div class="card col" style="width: 18rem;height:200px">
                      <p style="font-weight: bold;color: #24609c;font-size: 14px">Protein-Protein Interactions</p>
                      <img src="/rgdweb/images/cy_new.png" height="70%" width="70%" border="0" />
                  </div>
                  <div class="card col" style="width: 18rem;height:200px">
                      <p style="font-weight: bold;color: #24609c;font-size: 14px">JBrowse</p>

                  </div>
              </div>
              <div class="row">
                  <div class="card col" style="width: 18rem;height:200px">
                      <p style="font-weight: bold;color: #24609c;font-size: 14px">Variant Visualizer</p>
                      <img src="/rgdweb/common/images/variantVisualizer.png"  border="0" />
                  </div>
                  <div class="card col" style="width: 18rem;height:200px">
                      <p style="font-weight: bold;color: #24609c;font-size: 14px">PhenoMiner</p>
                      <img src="/rgdweb/common/images/phenominerNew.png" border="0" />
                  </div>
                  <div class="card col" style="width: 18rem;height:200px">
                      <p style="font-weight: bold;color: #24609c;font-size: 14px">OntoMate - Literature Search</p>
                      <img src="/rgdweb/images/logo.png" height="70%" width="70%" border="0" />
                  </div>
              </div>

          </div>
            <div class="col-sm-4" >
                <div class="card" style="border-color: transparent;">
                    <div class="card-body">
                        <div class="bd-example">
                            <div id="carouselExampleCaptions" class="carousel slide" data-ride="carousel">
                                <ol class="carousel-indicators">
                                    <li data-target="#carouselExampleCaptions" data-slide-to="0" class="active"></li>
                                    <li data-target="#carouselExampleCaptions" data-slide-to="1"></li>
                                    <li data-target="#carouselExampleCaptions" data-slide-to="2"></li>
                                </ol>
                                <div class="carousel-inner">
                                    <div class="carousel-item active">
                                        <img src="https://rgd.mcw.edu/common/images/bonobobanner.png" height="200px" class="d-block w-100" alt="...">
                                        <a style="text-decoration: none;" href="https://rgd.mcw.edu/wg/bonobo/">
                                        <div class="carousel-caption d-none d-md-block">
                                            <h5>Bonobo</h5>
                                            <p>RGD has included genes for the Bonobo. Click here to find out more details...</p>
                                        </div>
                                            </a>
                                    </div>
                                    <div class="carousel-item">
                                        <img src="https://rgd.mcw.edu/common/images/devdisease_150x163.png" height="200px" class="d-block w-100" alt="...">
                                        <div class="carousel-caption d-none d-md-block">
                                            <h5>Developmental Diseases</h5>
                                            <p>RGD announces the release of the Developmental Disease Potal. Click here to learn more</p>
                                        </div>
                                    </div>
                                    <div class="carousel-item">
                                        <img src="https://rgd.mcw.edu/common/images/boxerbanner.png" height="200px" class="d-block w-100" alt="...">
                                        <div class="carousel-caption d-none d-md-block">
                                            <h5>Dog Genes</h5>
                                            <p>RGD has added dog genes to the database. More details ...</p>
                                        </div>
                                    </div>
                                </div>
                                <a class="carousel-control-prev" href="#carouselExampleCaptions" role="button" data-slide="prev">
                                    <span class="carousel-control-prev-icon" aria-hidden="true"></span>
                                    <span class="sr-only">Previous</span>
                                </a>
                                <a class="carousel-control-next" href="#carouselExampleCaptions" role="button" data-slide="next">
                                    <span class="carousel-control-next-icon" aria-hidden="true"></span>
                                    <span class="sr-only">Next</span>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="card" style="border-color: transparent;">
                    <h5 class="card-title">Featured RGD Video Tutorials</h5>
                    <div style="height: 280px;overflow-y: auto">
                    <div>
                        <p style="font-weight: bold;color: #24609c;">JBrowse Genome Browser <a title="Watch the tutorial video about RGD's JBrowse genome browser" href="/wg/home/rgd_rat_community_videos/jbrowse-genome-browser"><i class="fas fa-play-circle" style="color:royalblue;font-size: 20px"></i></a> </p>
                        <p class="card-text">This video will demonstrate how to use the RGD JBrowse Genome Browser. The JBrowse Genome Browser allows the user to view objects such as genes, variants, QTLs, and so forth in their genomic context. You can view versions for Rat, Human and Mouse.</p>
                    </div>
                    <div>
                        <p style="font-weight: bold;color: #24609c;">Molecular Pathway Diagrams <a title="Watch the tutorial video about RGD's Interactive Pathway Diagrams" href="/wg/home/rgd_rat_community_videos/molecular-pathway-diagrams" target="_self"><i class="fas fa-play-circle" style="color:royalblue;font-size: 20px"></i></a></p>
                        <p class="card-text">This video will demonstrate how to use the RGD Molecular Pathway Diagrams. You can access the Ontology Report for the pathway, view the description for the pathway with its various interactions and components, and you can click on any of the pathway&#8217;s interactive features to view more information about that entity.</p>
                    </div>
                    <div>
                        <p style="font-weight: bold;color: #24609c;">PhenoGen Informatics Genome/Transcriptome Data/Browser   <a title="PhenoGen Informatics Genome/Transcriptome Data and Browser hands-on workshop video" href="/wg/home/rgd_rat_community_videos/other-videos-of-interest/outside-videos2/phenogen-informatics-genome/transcriptome-data-and-browser" target="_self"><i class="fas fa-play-circle" style="color:royalblue;font-size: 20px"></i></a></p>
                        <p class="card-text">RGD has been providing links from our gene pages to the <strong>PhenoGen Informatics Genome/Transcriptome Data Browser</strong>, but there&#8217;s a good chance you don&#8217;t know all there is to know about the tool. Want more information about how to use it so you can get the most out of its data and functionality? This informative hands-on workshop video is just the tutorial to help you with that!</p>
                    </div>
                </div>
                </div>
            </div>
        </div>
    </div>

</div>

<br><br>
    <!--div class="layoutColumnPadding"-->
<div class="container-fluid" style="background-color: #F5F8FF;height:auto">
<div class="container">
    <div class="row">
  <div class="card col" style="background-color: transparent;border-color: transparent;float:left">

                    <div class="card-body" style="background-color: transparent" id="rgd-conf">
                        <h5 class="card-title">Conference Watch</h5>
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

<!--td class="secondColumn" valign="top" width="40%"--><!-- begin position 3 -->

        <div class="card col" id="rgd-news" style="background-color: transparent;border-color:transparent">

            <div class="card-body" style="background-color: transparent">
                <h5 class="card-title">Latest News</h5>

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
        <div class="card col" style="background-color: transparent;border-color: transparent;float:right" >
            <div class="card-body">
                <a class="twitter-timeline" data-width="99%" data-height="550" data-theme="light" ata-border-color="#cc0000" href="https://twitter.com/ratgenome?ref_src=twsrc%5Etfw">Tweets by ratgenome</a>
                <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script><br />
            </div>
        </div>
    </div>
    <hr>


    <h5 class="card-title">Featured RGD Video Tutorials</h5>
    <div class="row hp-video-tut">
        <div class="col-sm-4 ">
            <div class="card hp-video-tut">
                <div class="card-body">
                    <h5 class="card-title">JBrowse Genome Browser <a title="Watch the tutorial video about RGD's JBrowse genome browser" href="/wg/home/rgd_rat_community_videos/jbrowse-genome-browser"><i class="fas fa-play-circle" style="color:royalblue;font-size: 30px"></i></a> </h5>
                    <p class="card-text">This video will demonstrate how to use the RGD JBrowse Genome Browser. The JBrowse Genome Browser allows the user to view objects such as genes, variants, QTLs, and so forth in their genomic context. You can view versions for Rat, Human and Mouse.</p>

                </div>
            </div>
        </div>
        <div class="col-sm-4 ">
            <div class="card hp-video-tut">
                <div class="card-body">
                    <h5 class="card-title">Molecular Pathway Diagrams <a title="Watch the tutorial video about RGD's Interactive Pathway Diagrams" href="/wg/home/rgd_rat_community_videos/molecular-pathway-diagrams" target="_self"><i class="fas fa-play-circle" style="color:royalblue;font-size: 30px"></i></a></h5>
                    <p class="card-text">This video will demonstrate how to use the RGD Molecular Pathway Diagrams. You can access the Ontology Report for the pathway, view the description for the pathway with its various interactions and components, and you can click on any of the pathway&#8217;s interactive features to view more information about that entity.</p>

                </div>
            </div>
        </div>
        <div class="col-sm-4 hp-video-tut">
            <div class="card hp-video-tut">
                <div class="card-body hp-video-tut">
                    <h5 class="card-title">PhenoGen Informatics Genome/Transcriptome Data and Browser   <a title="PhenoGen Informatics Genome/Transcriptome Data and Browser hands-on workshop video" href="/wg/home/rgd_rat_community_videos/other-videos-of-interest/outside-videos2/phenogen-informatics-genome/transcriptome-data-and-browser" target="_self"><i class="fas fa-play-circle" style="color:royalblue;font-size: 30px"></i></a></h5>
                    <p class="card-text">RGD has been providing links from our gene pages to the <strong>PhenoGen Informatics Genome/Transcriptome Data Browser</strong>, but there&#8217;s a good chance you don&#8217;t know all there is to know about the tool. Want more information about how to use it so you can get the most out of its data and functionality? This informative hands-on workshop video is just the tutorial to help you with that!</p>


                </div>
            </div>
        </div>
    </div>


</div>
</div>
</div>
<%@ include file="/common/footerarea.jsp"%>