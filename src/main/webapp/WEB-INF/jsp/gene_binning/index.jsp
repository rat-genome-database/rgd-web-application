<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="edu.mcw.rgd.web.*" %>
<%@ page import="edu.mcw.rgd.datamodel.annotation.TermWrapper" %>

<%
    String pageTitle = "Gene Binning";
    String headContent = "";
    String pageDescription = "Assigning genes of interest into Bins for disease portal curation.";
%>
<head>
    <style>
        .main-body{
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .main_form{
            display: flex;
            width: 100%;
            margin-top: 10px;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        input[type=submit]{
            margin-top: 10px;
            padding: 3px;
        }

        .show_bins{
            margin-left: auto;
            padding: 3px;
        }
    </style>
</head>
<%@ include file="../../../common/headerarea.jsp" %>
<div class="main-body" >
    <div class="show_bins">
        <button><a style="text-decoration: none" href="/rgdweb/geneBinning/bins.html?termAcc=GO:0008233&term=peptidase activity">Show Gene Bins</a></button>
    </div>
    <div class="main_form">
        <h3>Enter Genes: </h3>
        <form action="/rgdweb/geneBinning/bins.html" method="post">
            <input type="hidden" name="termAcc" value="GO:0008233" />
            <input type="hidden" name="term" value="peptidase activity" />
            <textarea rows="25" cols="150" name="inputdata"></textarea>
            <br>
            <input type="submit" value="Perform Binning">
        </form>
    </div>
</div>


<%--Id: <c:out value="${geneList.gene.rgd_id}"/> <br/>--%>
<%--Name: <c:out value="${geneList.gene.gene_symbol}"/>  <br/>--%>


<%@ include file="../../../common/footerarea.jsp" %>
