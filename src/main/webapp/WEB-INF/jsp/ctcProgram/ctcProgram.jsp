<%--
  Created by IntelliJ IDEA.
  User: akundurthi
  Date: 9/5/2024
  Time: 1:11 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "Agenda CTC-RG2024";
    String headContent = "";
    String pageDescription = "Agenda CTC-RG2024";
%>
<%@ include file="/common/headerarea.jsp"%>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
</head>

<style>
    body {
        font-family: 'Arial', sans-serif;
    }

    .ctcHeader {
        text-align: center;
        margin: 20px 0;
    }

    .tabs {
        display: flex;
        justify-content: center; /* Centering tabs */
        padding: 10px;
        background-color: #eaf2f8;
    }

    .tab-links {
        font-size: 11pt;
        color: #333; /* Dark text for better readability */
        border: 2px solid #b0c4de; /* Slightly darker blue border */
        border-radius: 5px; /* Rounded corners */
        outline: none;
        cursor: pointer;
        padding: 10px 20px;
        margin: 0 5px; /* Space between tabs */
        transition: background-color 0.3s, border-color 0.3s;
    }

    .tab-links:hover {
        background-color: #c8d4e8; /* A bit darker blue on hover */
        border-color: #9fb6d1; /* Even darker border on hover */
    }

    .tab-links.active {
        background-color: #a6bfdd; /* Active tab has an even darker blue */
        border-color: #8aaed1; /* Stronger border color for active tab */
    }


    .tab-links:focus{
        outline: none;
    }

    .tab-content {
        display: none;
        padding: 20px;
        border: 1px solid #ccc;
        background-color: #fff;
        color: #333;
        /*line-height: 1.6;*/
        margin-top: 5px;
        opacity: 0; /* Initial opacity for transition */
        transition: opacity 0.3s ease-in-out; /* Transition effect */
    }

    .tab-content.active {
        display: block;
        opacity: 1; /* Full opacity when active */
    }


    h2 {
        border-bottom: 1px solid #ccc;
        padding-bottom: 5px;
    }

    p {
        font-size: 11pt;
        font-family: Helvetica, Arial, sans-serif;
    }
    .day{
        border: none;
        text-align: center;
        font-weight: bold;
    }
    .abstract {
            font-size: 10pt;
            font-family: Helvetica, Arial, sans-serif;
            color: #1a0dab;
            text-decoration: none;
            display: none;
    }

    .abstract:hover {
            text-decoration: underline;
    }

    .author{
            font-size: 11pt;
            font-family: Helvetica, Arial, sans-serif;
    }

    hr {
        height: 1px;
        background: #ccc;
        border: 0;
    }


    .session-details {
        list-style: disc; /* Keeps default bullet style */
        padding-left: 50px; /* Adjust padding for bullets */
    }

    .session-details li {
        margin-bottom: 5px;
        font-size: 11pt;
        font-family: Helvetica, Arial, sans-serif;
        line-height: 1.6;
        list-style-position: outside;
    }

    .session-details li::marker {
        font-size: 1.2em; /* Increase bullet size */
        color: #1a0dab; /* Custom color for bullet */
    }

    strong{
        font-size: 11pt;
    }


    .break-item{
        background-color: #f0f0f0; /* Softer background color */
        padding: 11px;
        margin: 15px 0; /* Adds more space above and below */
        font-weight: bold;
        text-align: center;
        border-radius: 10px;
        color: #444;
        border: 1px solid #ddd;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 10px; /* Space between icon and text */
    }

    .break-item i{
        font-size: 20px;
        color: #666;
    }

    .reception-card {
        background-color: #f9f9f9;
        border-radius: 8px;
        padding: 20px;
        margin: 20px auto;
        max-width: 800px;
        box-shadow: 0 6px 12px rgba(0, 0, 0, 0.1);
        font-family: 'Arial', sans-serif;
    }

    .reception-header h3 {
        font-size: 24px;
        color: #2c3e50;
        text-align: center;
        margin-bottom: 20px;
        border-bottom: 2px solid #e6e6e6;
        padding-bottom: 10px;
    }

    .reception-details {
        list-style: none;
        padding:0;
        margin: 0;
    }

    .reception-details li {
        display: flex;
        align-items: center;
        margin-bottom: 15px;
    }

    .reception-details li i {
        font-size: 11pt;
        color: #3498db;
        margin-right: 10px;
        align-self: center;
    }

    .reception-details li span {
        color: #34495e;
    }

    .reception-details li strong {
        font-weight: bold;
        color: #2c3e50;
    }

    /*.reception-time i, .reception-location i {*/
    /*    margin-top: -1.75px; !* Adjust this value as needed to raise or lower the icon relative to text *!*/
    /*}*/


    @media (max-width: 600px) {
        .tab-links {
            padding: 8px 10px;
            font-size: 10pt;
        }
    }

</style>

<body>
<div style="text-align: center;">
<img  src="/rgdweb/common/images/CTC.png" width="75%" alt="CTC-RG"  border="0">
</div>
<header class="ctcHeader">
    <h1>CTC-RG2024 Meeting Agenda</h1>
    <p >October 2-5, 2024 | Medical College Of Wisconsin</p>
    <span>All times listed are in Central Time (CT), US.</span>
</header>
<div class="tabs">
    <button class="tab-links active" onclick="openDay(event, 'Day0')">October 2</button>
    <button class="tab-links" onclick="openDay(event, 'Day1')">October 3</button>
    <button class="tab-links" onclick="openDay(event, 'Day2')">October 4</button>
    <button class="tab-links" onclick="openDay(event, 'Day3')">October 5</button>
</div>

<div id="Day0" class="tab-content active">
    <h2 class="day">October 2 (Wednesday)</h2>
    <div class="reception-card">
        <div class="reception-header">
            <h3>Reception</h3>
        </div>
        <ul class="reception-details">
            <li class="reception-time">
                <i class="fa fa-clock"></i>
                <span><strong>6:00 PM to 8:00 PM</strong></span>
            </li>
            <li class="reception-location" style="padding-left: 3px">
                <i class="fa fa-map-marker-alt"></i>
                <span style="font-family: Helvetica, Arial, sans-serif;"><strong>&nbsp;<a style="font-family: Helvetica, Arial, sans-serif;font-size: 11pt;text-decoration: none" href="https://www.google.co.in/maps/dir//7677+W+State+St,+Wauwatosa,+WI+53213/@43.0492321,-88.0904818,12z/data=!4m8!4m7!1m0!1m5!1m1!1s0x88051b2dc10cb82f:0x6f4a991dde13877e!2m2!1d-88.0080811!2d43.0492617?entry=ttu&g_ep=EgoyMDI0MDkxMS4wIKXMDSoASAFQAw%3D%3D" target="_new">Location: Café Hollander in Wauwatosa</a></strong></span>
            </li>
        </ul>
    </div>
</div>

<div id="Day1" class="tab-content">
    <h2 class="day">October 3 (Thursday)</h2>
    <br>
    <h2>Registration and Introduction</h2>
    <ul class="session-details">
    <li><strong>8:00 AM to 9:00 AM</strong> - Registration</li>
    <li><strong>9:00 AM to 9:15 AM</strong> - Intro</li>
    </ul>
    <h2>Session 1 - Genome Biology</h2>
    <ul class="session-details">
        <li><strong>9:15 AM to 9:30 AM</strong> - Pangenome mapping enhances genotype-phenotype associations in BXD mouse family by <strong class="author">Flavia Villani</strong>. <a class="abstract" href="${pageContext.request.contextPath}/common/abstracts/Villani_FV.pdf" download target="_blank">(Download Abstract)</a>
        </li>
        <li><strong>9:30 AM to 9:45 AM</strong> - Haplotype-based analyses of phylogeny and regional genome diversity in laboratory rats by <strong class="author">Yanchao Pan</strong>. <a class="abstract" href="#">(Download Abstract)</a></li>
        <li><strong>9:45 AM to 10:00 AM</strong> - Genomics and Genetics of Immunoglobulin in the Rat by <strong class="author">Peter Doris</strong>. <a class="abstract" href="#">(Download Abstract)</a></li>
        <li><strong>10:00 AM to 10:15 AM</strong> - Y and mitochondrial chromosomes in the heterogeneous stock rat population by <strong class="author">Faith Okamoto</strong>. <a class="abstract" href="#">(Download Abstract)</a></li>
        <li><strong>10:15 AM to 10:30 AM</strong> - Discussion</li>
    </ul>
    <div class="break-item">
        <i class="fa fa-coffee"></i>
        <strong>10:30 AM to 10:45 AM - BREAK</strong>
    </div>
    <h2>Session 2 - Obesity and Metabolism</h2>
    <ul class="session-details">
    <li><strong>10:45 AM to 11:00 AM</strong> - Genome-wide association of adiposity in heterogeneous stock rats by <strong class="author">Apurva Chitre</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>11:00 AM to 11:15 AM</strong> - Identification of genes that link obesity and stress/emotional behaviors using outbred rats by <strong class="author">Leah Solberg-Woods</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>11:15 AM to 11:30 AM</strong> - Complex metabolic traits are mediated by genes with distal heritability by <strong class="author">Greg Carter</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>11:30 AM to 11:45 AM</strong> - Health Outcomes of PFAS Exposure Through Genetics and Environmental Interactions in Heterogenous Stock Founder Rats by <strong class="author">Katie Holl</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
        <li><strong>11:45 AM to 12:00 PM</strong> - Discussion</li>
    </ul>
    <div class="break-item">
        <i class="fa fa-utensils"></i>
        <strong>12:00 PM to 1:00 PM - LUNCH</strong>
    </div>
    <h2>Keynote 1</h2>
    <ul class="session-details">
    <li><strong>1:00 PM to 2:00 PM</strong> - Sex chromosome-modified mice and rats to identify factors causing sex differences in physiology and disease by <strong class="author">Arthur Arnold</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    </ul>
    <h2>Session 3 - Data Science and Resources</h2>
    <ul class="session-Details">
    <li><strong>2:00 PM to 2:15 PM</strong> - ClassifyGxT: Probabilistic classification of gene-by-treatment effects in molecular count phenotypes by <strong class="author">William Valdar</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>2:15 PM to 2:30 PM</strong> - PipeRat: A high-throughput python package to perform and visualize large-scale genetic association analysis by <strong class="author">Thiago Missfeldt Sanches</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>2:30 PM to 2:45 PM</strong> - 2024 Update on GeneNetwork.org by <strong class="author">Pjotr Prins</strong>.</li>
    <li><strong>2:45 PM to 3:00 PM</strong> - MoTrPAC Data Hub: Multi-omic, Multi-tissue Collection of Exercise Molecular Responses in Young Adult Rats by <strong class="author">Christopher Jin</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    </ul>
    <div class="break-item">
        <i class="fa fa-coffee"></i>
        <strong>3:00 PM to 3:30 PM - BREAK</strong>
    </div>
    <ul class="session-Details">
    <li><strong>3:30 PM to 3:45 PM</strong> - Introducing the center for genetics, genomics, and epigenetics of substance use disorders in outbred rats by <strong class="author">Abraham Palmer</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>3:45 PM to 4:00 PM</strong> - HRDP Update by <strong class="author">Melinda Dwinell</strong>.</li>
    <li><strong>4:00 PM to 4:45 PM</strong> - <strong>Panel Discussion:</strong> Expanding the use of biological and data resources.</li>
    </ul>
    <div class="break-item">
    <strong>Dinner - On Your Own</strong>
    </div>
</div>
<div id="Day2" class="tab-content">
    <h2 class="day">October 4 (Friday)</h2>
    <br>
    <h2>Session 4 - Workshop</h2>
    <ul class="session-details">
    <li><strong>8:30 AM to 9:30 AM</strong> - <strong>Use case 1:</strong> Navigating the public resources for quantitative genetics, phenotypes and omics data for my research.</li>
    <li><strong>9:30 AM to 10:30 AM</strong> - <strong>Use case 2:</strong> Using online resources to find a model for my disease of interest (in this case, obesity).</li>
    </ul>
    <div class="break-item">
        <i class="fa fa-coffee"></i>
    <strong>10:30 AM to 10:45 AM - BREAK</strong>
    </div>
    <h2>Session 5 - Virtual Session</h2>
    <ul class="session-details">
    <li><strong>10:45 AM to 11:00 AM</strong> - Hemodynamic abnormalities and tissue electrolyte accumulation during initiation of salt-induced hypertension in a rat model of primary aldosteronism by <strong class="author">Michal Pravenec</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>11:00 AM to 11:15 AM</strong> - From rats to humans: revealing conserved molecular networks of addiction through gene expression and GWAS integration by <strong class="author">Yanning Zuo</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    </ul>
    <h2>Session 6 - The Microbiome</h2>
    <ul class="session-details">
    <li><strong>11:15 AM to 11:30 AM</strong> - Differences in gut microbiota significantly modulate colon cancer susceptibility in the rat genetic model of familial colon cancer by <strong class="author">James Amos-Landgraf</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>11:30 AM to 11:45 AM</strong> - Multi-cohort analysis identifies robust host genetic effects on the rat gut microbiome by <strong class="author">Amelie Baud</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
        <li><strong>11:45 AM to 12:00 PM</strong> - Discussion</li>
    </ul>
    <div class="break-item">
        <i class="fa fa-utensils"></i>
        <strong>12:00 PM to 1:00 PM - LUNCH</strong>
    </div>
    <h2>Poster Presentation</h2>
    <ul class="session-details">
        <li><strong>1:00 PM to 2:15 PM</strong> - POSTERS</li>
    </ul>
    <h2>Session 7 - Disease Models I</h2>
    <ul class="session-details">
        <li><strong>2:15 PM to 2:30 PM</strong> - Developmental systems genomics identifies expression quantitative trait loci underlying strain differences in skeletal differentiation and developmental pace by <strong class="author">Ian Welsh</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
        <li><strong>2:30 PM to 2:45 PM</strong> - Machine learning reveals genetic modifiers of the immune microenvironment of cancer by <strong class="author">Michael Flister</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
        <li><strong>2:45 PM to 3:00 PM</strong> - Linking brain cell types with predisposition to alcohol consumption in rats by <strong class="author">Laura Saba</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    </ul>
    <h2>Session 8 - Genome Biology II</h2>
    <ul class="session-details">
    <li><strong>3:00 PM to 3:15 PM</strong> - Multi-platform genome assembly of an SHR/OlaIpcv X BN-Lx/Cub F1 rat trio by <strong class="author">Andrea Guarracino</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>3:15 PM to 3:30 PM</strong> - Telomere-to-Telomere Assembly of the SHRSP/BbbUtx (SHR-A3) Rat by <strong class="author">Kai Li</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    </ul>
    <div class="break-item">
        <i class="fa fa-coffee"></i>
        <strong>3:30 PM to 4:00 PM - BREAK</strong>
    </div>
    <h2>Keynote 2</h2>
    <ul class="session-details">
    <li><strong>4:00 PM to 5:00 PM</strong> - The Serengeti Rules: The Regulation and Restoration of Biodiversity by <strong class="author">Sean Carrol.</strong></li>
    </ul>
    <div class="break-item">
        <strong>Dinner - On Your Own</strong>
    </div>
</div>
<div id="Day3" class="tab-content">
    <h2 class="day">October 5 (Saturday)</h2>
    <br>
    <h2>Session 9 - Substance Use Disorders and Behavior</h2>
    <ul class="session-details">
    <li><strong>9:15 AM to 9:30 AM</strong> - Genome-wide association study of cocaine use in Heterogeneous Stock rats by <strong class="author">Montana Lara</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>9:30 AM to 9:45 AM</strong> - Identifying the shared genetic signal from genome-wide association studies of externalizing and locomotor activity by <strong class="author">Brittany Leger</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>9:45 AM to 10:00 AM</strong> - Improved representation of behavior data in the Rat Genome Database's PhenoMiner tool by <strong class="author">Jennifer Smith</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    </ul>
    <div class="break-item">
        <i class="fa fa-coffee"></i>
        <strong>10:00 AM to 10:30 AM - BREAK</strong>
    </div>
    <h2>Session 10 - Disease Models II</h2>
    <ul class="session-details">
    <li><strong>10:30 AM to 10:45 AM</strong> - Oxidative stress induced suppression of metabolism pathways in Dahl Salt-Sensitive rat by <strong class="author">Satoshi Shimada</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>10:45 AM to 11:00 AM</strong> - Meta-analysis of hundreds of seizure-related traits reveals putative modifiers of epilepsy resilience and susceptibility by <strong class="author">Matt Mahoney</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>11:00 AM to 11:15 AM</strong> - Genome-wide association study for age-related hearing loss in CFW mice by <strong class="author">Oksana Polesskaya</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
    <li><strong>11:15 AM to 11:30 PM</strong> - The dark matter of the genome and blood pressure regulation – modeling non-coding genetic mechanisms in cellular models and rats by <strong class="author">Aron Geurts</strong>. <a class="abstract" href="">(Download Abstract)</a></li>
        <li><strong>11:30 AM to Noon</strong> - Parting comments and CTC-RG 25</li>
    </ul>
    <div class="break-item">
        <strong>Noon - Adjourn</strong>
    </div>
</div>

<script>
    function openDay(evt, dayId) {
        let i, tabcontent, tablinks;
        tabcontent = document.getElementsByClassName("tab-content");
        for (i = 0; i < tabcontent.length; i++) {
            tabcontent[i].style.display = "none";
            tabcontent[i].style.opacity = "0";
        }
        tablinks = document.getElementsByClassName("tab-links");
        for (i = 0; i < tablinks.length; i++) {
            tablinks[i].className = tablinks[i].className.replace(" active", "");
        }
        document.getElementById(dayId).style.display = "block";
        setTimeout(function() {
            document.getElementById(dayId).style.opacity = "1";
        }, 10);
        evt.currentTarget.className += " active";
    }

</script>
</body>
</html>
<%@ include file="/common/footerarea.jsp"%>
