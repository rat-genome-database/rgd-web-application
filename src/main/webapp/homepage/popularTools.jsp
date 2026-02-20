<%@ page import="edu.mcw.rgd.web.RgdContext" %>

<style>
    .headerCardTitle {
        text-align:left;
        position:absolute;
        top:0; left:0;
        margin:0px;
        padding:5px;
        border-radius:10px;
        opacity:1;
        font-weight: bold;
        background-color:#eff3fc;
        color: #24609c;
        font-size: 16px;
        border-right:1px solid black;
        border:1px solid black;
        z-index:20;
    }

    .headerSubTitle {
        font-size:12px;
    }

    .headerCardOverlay {
        position:absolute;
        top:0; left:0;
        background-color:#2865a3;
        width:100%;
        height:100%;
        z-index:30;
        opacity:0;
        transition:opacity 0.2s;
    }

    .headerCardOverlay:hover {
        opacity:.5;
        cursor:pointer;
    }

    .headerCardImage {
        margin:10px;
        border:1px solid black;
        z-index:15;
        max-width:90%;
        height:auto;
    }
    .headerCard {
        position:relative;
        width:200px;
        min-width:0;
        border: 1px solid rgba(0,0,0,.125);
        margin:5px;
        overflow:hidden;
    }

    .headerRow {
        display: flex;
        flex-wrap: wrap;
        margin-right: 5px;
        margin-left: 5px;
    }

</style>




<div class="" style="border-color: transparent;margin-top:25px;">
    <h5 class="card-title">Analysis and Visualization</h5>
</div>

<table border="0" cellpadding="7" class="hp-tools-table">
    <tr>
        <td>
            <div class="headerCard" style="width: 200px;;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='/rgdweb/jbrowse2/listing.jsp'">.</div>
                <div class="headerCardTitle">JBrowse<br><span class="headerSubTitle">Genome Browser</span></div>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/jbrowseScreen.png" border="0" /></span>
            </div>
        </td>
        <td>
            <div class="headerCard" style="width: 200px;height:auto;margin-right: 2%;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='/rgdweb/front/config.html'">.</div>
                <div class="headerCardTitle">Variant Visualizer</div>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/vvScreen.png"  border="0" /></span>
            </div>

        </td>
        <td>
            <div class="headerCard" style="width: 200px;height:auto;margin-right: 2%;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='/vcmap'">.</div>
                <div class="headerCardTitle">VCMap<br><span class="headerSubTitle">Synteny Browser</span></div>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/vcmap.png?"  border="0" /></span>
            </div>

        </td>


    </tr>
    <tr>
        <td>
            <div class="headerCard" style="width: 200px;height:auto;margin-right: 2%;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='/rgdweb/generator/list.html'">.</div>
                <div class="headerCardTitle">OLGA<br><span class="headerSubTitle">Gene List Generator</span></div>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/olgaScreen.png"  border="0" /></span>
            </div>

        </td>
        <td>
            <div class="headerCard" style="width: 200px;margin-right: 2%;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='/rgdweb/portal/index.jsp'">.</div>
                <div class="headerCardTitle">Disease Portals</div>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/diseasePortalScreen.png"  border="0" /></span>
            </div>

        </td>
        <td>
            <div class="headerCard" style="width: 200px;;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='/wg/physiology/'">.</div>
                <div class="headerCardTitle">Phenotypes and Models</div>
                <img class="headerCardImage" src="/rgdweb/common/images/expected.png"  border="0" />
            </div>
        </td>
    </tr>
    <tr>
        <td>
            <div class="headerCard"  style="width: 200px;;margin-right: 2%;;text-align: center;padding-top:1%;">
                <div class="headerCardOverlay" onclick="location.href='/rgdweb/enrichment/start.html'">.</div>
                <div class="headerCardTitle">MOET</span><br><span class="headerSubTitle">Multi-Ontology Enrichment</span></div>
                <img class="headerCardImage" src="/rgdweb/common/images/moetScreen.png" border="0" style="border:1px solid black;" />
            </div>
        </td>

        <td>
            <div class="headerCard" style="width: 200px;height:auto;;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='<%=RgdContext.getSolrUrl("solr")%>'">.</div>
                <div class="headerCardTitle">OntoMate<br><span class="headerSubTitle">Advanced Literature Search</span></div>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/ontomateScreen.png"border="0" /></span>
            </div>

        </td>
        <td>
            <div class="headerCard" style="width: 200px;height:auto;margin-right: 2%;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='/rgdweb/ga/start.jsp'">.</div>
                <div class="headerCardTitle">GA Tool<br><span class="headerSubTitle">Gene Annotator</span></div>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/gaTool.png"  border="0" /></span>
            </div>

        </td>
    </tr>


    <tr>
        <td>
            <div class="headerCard"  style="width: 200px;;margin-right: 2%;;text-align: center;padding-top:1%;" >
                <div class="headerCardOverlay" onclick="location.href='/wg/home/pathway2/'">.</div>
                <div class="headerCardTitle">Pathway Explorer<br><span class="headerSubTitle">Interactive Diagrams</span></div>
                <img class="headerCardImage" src="/rgdweb/common/images/pathwayScreen.png" style="border:1px solid black;" border="0" />
            </div>

        </td>
        <td>
            <div class="headerCard" style="width: 200px;;margin-right: 2%;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='/rgdweb/cytoscape/query.html'">.</div>
                <div class="headerCardTitle">Interviewer<br><span class="headerSubTitle">Protein-Protein Interactions</span></div>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/interviewerScreen.png"  border="0" /></span>
            </div>
        </td>
        <td>
            <div class="headerCard" style="width: 200px;height:auto;margin-right: 2%;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='/rgdweb/report/genomeInformation/genomeInformation.html'">.</div>
                <div class="headerCardTitle">Genome Information</div>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/genomeInformationScreen.png"   border="0" /></span>
            </div>

        </td>

    </tr>
    <!--
    <tr>
        <td>
            <div class="headerCard" style="width: 200px;height:auto;margin-right: 2%;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='https://www.google.com'">.</div>
                <p style="font-weight: bold;color: #24609c;font-size: 14px">GOLF<br></p>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/vvScreen.png"  height="70%" width="70%" border="0" /></span>
            </div>

        </td>
        <td>
            <div class="headerCard" style="width: 200px;height:auto;margin-right: 2%;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='https://www.google.com'">.</div>
                <div class="headerCardTitle">Ratmine</div>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/ratmineScreen.png"  border="0" /></span>
            </div>

        </td>
        <td>
            <div class="headerCard" style="width: 200px;height:auto;;text-align: center;padding-top:1%">
                <div class="headerCardOverlay" onclick="location.href='https://www.google.com'">.</div>
                <p style="font-weight: bold;color: #24609c;font-size: 14px">GViewer</p>
                <span style="text-align: center"><img class="headerCardImage" src="/rgdweb/common/images/ontomateScreen.png"border="0" /></span>
            </div>

        </td>
    </tr>
    -->
</table>


