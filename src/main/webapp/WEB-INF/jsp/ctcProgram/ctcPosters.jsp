<%--
  Created by IntelliJ IDEA.
  User: akundurthi
  Date: 9/24/2024
  Time: 11:14 AM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "Posters CTC-RG2024";
    String headContent = "";
    String pageDescription = "Posters CTC-RG2024";
%>
<%@ include file="/common/headerarea.jsp"%>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<style>
    body {
        font-family: Arial, sans-serif;
    }

    h1 {
        text-align: center;
        font-size: 28px;
        margin-bottom: 10px;
        margin-top: 20px;
    }

    hr {
        border: none;
        border-top: 0.5px solid lightslategray;
        margin-bottom: 30px;
    }

    .poster-entry {
        margin-bottom: 25px;
        border-radius: 8px;
        background-color: #f9f9f9;
        padding: 15px;
        border: 1px solid #ddd;
        transition: background-color 0.3s ease;
    }

    .poster-entry:hover {
        background-color: #e9e9e9;
    }

    .poster-name {
        font-size: 18px;
        font-weight: bold;
        margin: 0;
    }

    .poster-title {
        font-size: 16px;
        margin: 5px 0 10px 0;
    }

    .abstract-link {
        font-size: 14px;
        color: #1a0dab;
        text-decoration: none;
        font-weight: bold;
    }

    .abstract-link:hover {
        text-decoration: underline;
    }
</style>

<body>
<h1>Posters</h1>
<hr>
<div style="margin: 20px">
<div class="poster-entry">
    <p class="poster-name">Al Hefzi</p>
    <p class="poster-title">Investigating the role of the Spp1 gene in cardiac hypertrophy and fibrosis utilising normotensive and spontaneously hypertensive rat strains.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Al%20Hefzi.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Ashbrook</p>
    <p class="poster-title">Mouse Longevity Data Explorer App.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Ashbrook_DG.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Bryda</p>
    <p class="poster-title">Rat Resource and Research Center.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Bryda_E.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Chen DC</p>
    <p class="poster-title">Structural variants in heterogeneous stock rats.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Chen_DC.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Chen H</p>
    <p class="poster-title">Quantification and genetic mapping of oxycodone self-administration behaviors in nearly isogenic rat strains.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/ChenHao.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Demos</p>
    <p class="poster-title">Rat gene expression data expansion at the Rat Genome Database, an update.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Demos_W.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Hayman</p>
    <p class="poster-title">The Virtual Comparative Map tool at the Rat Genome Database facilitates comparative and translational studies.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Hayman_GT%20Final.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Jacob</p>
    <p class="poster-title">Identification of Targets for Delayed Mammary Tumor Onset and Aggressiveness Using Diversity Outbred Mice Expressing the Delta 16 Variant of HER2/neu.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Jacob_J.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Jin</p>
    <p class="poster-title">MoTrPAC Data Hub: Multi-omic, Multi-tissue Collection of Exercise Molecular Responses in Young Adult Rats.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Jin_CJ_datahub.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Kaldunski</p>
    <p class="poster-title">Finding a rat model for researching human disease using RGD resources.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Kaldunski_M.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Laulederkind</p>
    <p class="poster-title">Mapping of EFO terms from the GWAS catalog data to multiple ontologies at the Rat Genome Database.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Laulederkind.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Purdy</p>
    <p class="poster-title">Genetic mapping of cardiomyocyte ploidy phenotypes that influence basal cardiac physiology.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Purdy_AL.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Ray</p>
    <p class="poster-title">Comparative Genomic Maps of Kidney Proximal Tubules and Medullary Thick Ascending Limbs between Humans and Rats reveal Enrichment for Human Blood Pressure Associated Polymorphisms.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Ray_A.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Salehi</p>
    <p class="poster-title">Exploring residual heterozygosity in inbred rat strains: How much, where, and why?</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Salehi_F.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Samuelson</p>
    <p class="poster-title">Analysis of rat MIER family member 3 targeted mutation (Mier3tm) mammary gland ultrastructure using transmission electron microscopy.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Samuelson.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Smith</p>
    <p class="poster-title">Integration of data from the human GWAS Catalog into the Rat Genome Database.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Smith_JR_GWAS.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Tabbaa</p>
    <p class="poster-title">Chd8 haploinsufficiency interacts with genetic background and sex to regulate the developmental trajectory of social dominance.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Tabbaa_MT.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Takizawa</p>
    <p class="poster-title">Search for sufficient superovulation and optimal embryo cryopreservation in inbred rat strains in HRDP.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Takizawa_A_Final_Malloy2Present.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Tutaj</p>
    <p class="poster-title">Building a Comparative Genomic Atlas of Epigenetic Variation in Rat Tissues.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Tutaj.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Vanden Avond</p>
    <p class="poster-title">Targeted disruption of CTCF binding in the Dahl salt-sensitive rat reveals Renin transcriptional dynamics.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/VandenAvond_MV.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Vedi</p>
    <p class="poster-title">Exploring Rat Quantitative Phenotype Data with the Rat Genome Database (RGD).</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Vedi_MV.pdf" download target="_blank">(Download Abstract)</a>
</div>

<div class="poster-entry">
    <p class="poster-name">Wang</p>
    <p class="poster-title">Updated Hybrid Rat Diversity Panel Portal at RGD.</p>
    <a class="abstract-link" href="${pageContext.request.contextPath}/common/posters/Wang_sj.pdf" download target="_blank">(Download Abstract)</a>
</div>
</div>

</body>
</html>
<%@ include file="/common/footerarea.jsp"%>