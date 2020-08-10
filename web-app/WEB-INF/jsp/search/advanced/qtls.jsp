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
    String pageTitle = "QTL (quantitative trait loci) Search - " + RgdContext.getLongSiteName(request);
    String headContent = "";
    String pageDescription = "QTL reports provide phenotype and disease descriptions, mapping, and strain information as well as links to markers and candidate genes.";
    String title="QTL";
%>
<%@ include file="/common/headerarea.jsp"%>

<!--link rel="stylesheet" href="/rgdweb/common/bootstrap/css/bootstrap.css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
<script src="/rgdweb/common/bootstrap/js/bootstrap.js"></script-->
<link href="/rgdweb/css/cyStyle.css" rel="stylesheet" type="text/css">

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading">QTL Search</div>
</div>

<%
    int selSpecies = RgdContext.isChinchilla(request) ? SpeciesType.CHINCHILLA : SpeciesType.RAT;
    String speciesTypeParam = request.getParameter("speciesType");
    if( speciesTypeParam!=null && SpeciesType.isValidSpeciesTypeKey(Integer.parseInt(speciesTypeParam)) ) {
        selSpecies = Integer.parseInt(speciesTypeParam);
    }
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
                <td width="10%"><span class="searchLabel" >Species:</span></td>
                <td colspan=2>
                    <select style="font-size:16px;" name="species")>
                        <% for( int speciesTypeKey: SpeciesType.getSpeciesTypeKeys()) { %>
                        <option><%=SpeciesType.getCommonName(speciesTypeKey)%></option>
                        <% }%>
                    </select>
                </td>
            </tr>
            <tr><td>&nbsp;</td></tr>
            <tr>
                <td>

                </td>
                <td>
                    <div class="searchExamples">
                        <b>Example searches:</b>
                        <a href="javascript:document.adSearch.term.value='Mcs';document.adSearch.submit();" >Mcs</a>,
                        <a href="javascript:document.adSearch.term.value='&quot;blood pressure&quot;';document.adSearch.submit();" >&quot;blood pressure&quot;</a>,
                        <a href="javascript:document.adSearch.term.value='renal function';document.adSearch.submit();" >renal function</a>,
                        <a href="javascript:document.adSearch.term.value='blood -pressure';document.adSearch.submit();" >blood -pressure</a>,
                        <a href="javascript:document.adSearch.term.value='Johnson';document.adSearch.submit();" >Johnson</a>
                    </div>

                </td>
            </tr>
            <tr>
                <td  ><span class="searchLabel">Search&nbsp;by&nbsp;Keyword</span></td>
                <td><input name="term" id="objectSearchTerm" type="text" value="" style="font-size:20px;" size="40"/></td>
                <td><input type="submit" value="Search <%=title%>" style="font-size:20px; margin-left:10px;" /></td>
            </tr>
            <input type="hidden" name="chr" value="All"/>

        </table>

        <input type="hidden" name="category" id="objectSearchCat" value="QTL" />
        <input type="hidden" name="objectSearch" value="true"/>

    </form>


</div>


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
        <td>Search for QTL in a genomic region</td>
    </tr>
    <tr><td width="200"><div class="geneSearchToolTitle">OLGA<br><span class="geneSearchSubTitle">Gene List Generator</span></div></td>
        <td>&nbsp;</td>
        <td>Enter a list of genes, QTLs or strains, or create new lists based on genomic position and/or functional annotations. Flexibly combine your lists, then send the final result to other RGD tools for analysis.n</td>
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
