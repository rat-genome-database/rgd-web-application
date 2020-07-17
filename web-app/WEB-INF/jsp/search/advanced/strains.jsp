<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.process.search.SearchBean" %>
<%--
  Created by IntelliJ IDEA.
  User: jdepons
  Date: May 5, 2008
  Time: 9:18:22 AM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String pageTitle = "Strain Search";
    String headContent = "";
    String pageDescription = "";

%>
<%@ include file="/common/headerarea.jsp"%>

<!--link rel="stylesheet" href="/rgdweb/common/bootstrap/css/bootstrap.css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
<script src="/rgdweb/common/bootstrap/js/bootstrap.js"></script-->
<link href="/rgdweb/css/cyStyle.css" rel="stylesheet" type="text/css">

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading">Strain Search</div>
</div>

<%
    int selSpecies = RgdContext.isChinchilla(request) ? SpeciesType.CHINCHILLA : SpeciesType.RAT;
    String speciesTypeParam = request.getParameter("speciesType");
    if( speciesTypeParam!=null && SpeciesType.isValidSpeciesTypeKey(Integer.parseInt(speciesTypeParam)) ) {
        selSpecies = Integer.parseInt(speciesTypeParam);
    }
    String title="Strain";
%>

<style>
    .searchLabel {
        font-weight:700;
        font-size:14px;
        padding:10px;
    }
</style>


<div class="searchBox">


    <div class="searchExamples">
    </div>

    <form name="adSearch" action="/rgdweb/elasticResults.html">


        <table border='0' >
            <tr>
                <td>
                    <b>Example searches:</b> <a href="javascript:document.adSearch.term.value='fhl';document.adSearch.submit();" >fhl</a>,
                    <a href="javascript:document.adSearch.term.value='wild';document.adSearch.submit();" > wild</a>,
                    <a href="javascript:document.adSearch.term.value='Adora2a';document.adSearch.submit();" >Adora2a</a>,
                    <a href="javascript:document.adSearch.term.value=' hypertension';document.adSearch.submit();" > hypertension</a>,
                    <a href="javascript:document.adSearch.term.value='d16rat31';document.adSearch.submit();" >d16rat31</a>

                </td>
            </tr>
            <tr>
                <td  ><span class="searchLabel">Search&nbsp;by&nbsp;Keyword</span></td>
                <td><input name="term" id="objectSearchTerm" type="text" value="" style="font-size:20px;" size="40"/></td>
                <td><input type="submit" value="Search <%=title%>" style="font-size:20px; margin-left:10px;" /></td>
            </tr>
            <tr><td>&nbsp;&nbsp;&nbsp;</td></tr>

            <input type="hidden" name="chr" value="All"/>

        </table>

        <input type="hidden" name="category" id="objectSearchCat" value="Gene" />
        <input type="hidden" name="objectSearch" value="true"/>

    </form>





</div>



<table>
    <tr>
        <td><span class="searchLabel">Browse the Ontology</span></td>
        <td>
            <li><a href="/rgdweb/ontology/view.html?acc_id=RS:0001340">advanced intercross line</a><br>
            <li><a href="/rgdweb/ontology/view.html?acc_id=RS:0000271">is-a chromosome altered</a><br>
            <li><a href="/rgdweb/ontology/view.html?acc_id=RS:0000458">coisogenic strain</a><br>
            <li><a href="/rgdweb/ontology/view.html?acc_id=RS:0000459">congenic strain</a><br>
            <li><a href="/rgdweb/ontology/view.html?acc_id=RS:0001431">conplastic strain</a><br>
            <li><a href="/rgdweb/ontology/view.html?acc_id=RS:0000460">consomic strain</a><br>
            <li><a href="/ontology/view.html?acc_id=RS:0002067">hybrid strain</a><br>
            <li><a href="/ontology/view.html?acc_id=RS:0000765">inbred strain</a><br>
            <li><a href="/rgdweb/ontology/view.html?acc_id=RS:0000461">mutant strain</a><br>
            <li><a href="/rgdweb/ontology/view.html?acc_id=RS:0000462">outbred strain</a><br>
            <li><a href="/rgdweb/ontology/view.html?acc_id=RS:0000463">recombinant inbred strain</a><br>
            <li><a href="/rgdweb/ontology/view.html?acc_id=RS:0000464">segregating inbred strain</a><br>
            <li><a href="/rgdweb/ontology/view.html?acc_id=RS:0004472">transchromosomal strain</a><br>
            <li><a href="/rgdweb/ontology/view.html?acc_id=RS:0000465">transgenic strain</a><br>
            <li><a href=/rgdweb/ontology/view.html?acc_id=RS:0001091">Wild</a><br>
        </td>
    </tr>

</table>



<style>
    .geneSearchToolTitle {
        text-align:left;
        top:0; left:0;
        margin:0px;
        padding:5px;
        order-radius:10px;
        opacity:1;
        font-weight: bold;
        background-color:#eff3fc;
        color: #24609c;
        font-size: 16px;
        z-index:20;
        border:1px solid #2865a3;
    }

    .geneSearchSubTitle {
        font-size:12px;
    }



</style>


<hr>
<div style="margin-top:30px;margin-bottom:10px; border-color: transparent;font-size:18px;color:#2865a3;ont-weight:700;">Additional ways to search Genes</div>


<table width="80%">
    <tr>
        <td><div class="geneSearchToolTitle">Region Search</div></td>
        <td>&nbsp;</td>
        <td>Search for genes in a genomic region</td>
    </tr>
    <tr><td width="200"><div class="geneSearchToolTitle">OLGA<br><span class="geneSearchSubTitle">Gene List Generator</span></div></td>
        <td>&nbsp;</td>
        <td>Enter a list of genes, QTLs or strains, or create new lists based on genomic position and/or functional annotations. Flexibly combine your lists, then send the final result to other RGD tools for analysis.n</td>
    </tr>
    <tr>
        <td><div class="geneSearchToolTitle">Variant Visualizer<br><span class="geneSearchSubTitle">Gene List Generator</span></div></td>
        <td>&nbsp;</td>
        <td>For a genomic region or list of genes and one or more samples of interest, view and analyze rat strain-specific sequence polymorphisms and human variants from ClinVar. Filter results based on parameters such as variant consequences (damaging vs. benign), clinical significance, sequence type and call statistics.</td>
    </tr>
    <tr>
        <td><div class="geneSearchToolTitle">Function Search<br><span class="geneSearchSubTitle">Gene List Generator</span></div></td>
        <td>&nbsp;</td>
        <td>Ontologies provide standardized vocabularies for annotating molecular function, biological process,cellular component, phenotype and disease associations. Allows searching across genes, QTLs, strains and provides a basis for cross-species comparisons.</td>
    </tr>
    <tr>
        <td><div class="geneSearchToolTitle">JBrowse<br><span class="geneSearchSubTitle">Gene List Generator</span></div></td>
        <td>&nbsp;</td>
        <td>View genes, transcripts, variants, QTLs, etc in their genomic context. RGD has genome browsers for all of the species and assemblies for which we have data. Click here for help getting started with RGD’s browsers.</td>
    </tr>


</table>






<%@ include file="/common/footerarea.jsp"%>
