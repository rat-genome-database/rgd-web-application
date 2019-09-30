<%@ page import="edu.mcw.rgd.datamodel.SpeciesType" %>
<%@ taglib prefix="th" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="select" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 4/1/2016
  Time: 10:18 AM
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>


<%  String pageTitle =  "InterViewer - Ineraction Query Form";
    String pageDescription ="Cytoscape";
    String headContent = "";%>
<%@ include file="/common/headerarea.jsp"%>
<script src="/rgdweb/js/browser.js"></script>
<link href="/rgdweb/css/cyStyle.css" rel="stylesheet" type="text/css">
<style>
    h4{
        color:red;
    }
</style>
<%--@ include file="rgdHeader.jsp"--%>



<h4><c:out value='${msg}'/></h4>
<table id="logTable" style="border: 0px">

    <c:forEach items="${model.log}" var="i">
        <tr style="border: 0px;">
            <td  class="tdef">${i}</td>
        </tr>
    </c:forEach>
<h3 style="color: red;font-weight: bold"><c:out value="${model.msg}"/></h3>

</table>
<form id="query"   method="post" action="cy.html">
    <div class="container">
        <div class="rgd-panel rgd-panel-default">
            <div class="rgd-panel-heading">InterViewer - Protein Interactions</div>
            <div class="panel-body">
                <input type="hidden" name="browser" id="browser">
                <table border=0>
                    <tr><td style='background-color:#e6e6e6;' colspan="2"><br><b><span style="color:#205080;"></span></b>Enter a protein or list of proteins to analyse. <br><br></td></tr>
                    <tr><td>&nbsp;</td></tr>
                    <tr>
                        <td class="gaLabel">Select a Species</td>
                        <td style="padding-left:30px;">
                            <select name="species" id="species" >
                                <c:choose>
                                    <c:when test="${model.species!=null}">

                                        <c:forEach items="${model.speciesList}" var="val">
                                            <c:if test="${val==model.species}">
                                                <option value="${model.species}" SELECTED>${model.speciesType}</option>
                                            </c:if>
                                            <c:if test="${val==1 && val!=model.species}">
                                                <option value="${val}">Human</option>
                                            </c:if>
                                            <c:if test="${val==2 && val!=model.species}">
                                                <option value="${val}">Mouse</option>
                                            </c:if>
                                            <c:if test="${val==3 && val!=model.species}">
                                                <option value="${val}">Rat</option>
                                            </c:if>
                                            <c:if test="${val==6 && val!=model.species}">
                                                <option value="${val}">Dog</option>
                                            </c:if>
                                            <c:if test="${val==9 && val!=model.species}">
                                                <option value="${val}">Pig</option>
                                            </c:if>
                                            <c:if test="${val==0 && val!=model.species}">
                                                <option value="${val}">ALL</option>
                                            </c:if>

                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="0" SELECTED>ALL</option>
                                        <option value="3" >Rat</option>
                                        <option value="2" >Mouse</option>
                                        <option value="1" >Human</option>
                                        <option value="6" >Dog</option>
                                        <option value="9" >Pig</option>
                                    </c:otherwise>
                                </c:choose>

                            </select>
                        </td>
                    </tr>
                    <tr><td>&nbsp;</td></tr>

                    <tr>
                        <td valign="top">
                            <!--<span class="gaLabel" style="margin-right:20px;">Enter Symbols</span><input type="button" class="btn btn-info btn-sm" data-toggle="modal" data-target="#myModal" value="Import" ng-click="rgd.loadMyRgd($event)" style="background-color:#4584ED;"/>-->
                            <span class="gaLabel" style="margin-right:20px;">Enter Protein Identifiers</span>

                            <br><br>
                            When entering multiple identifiers<br> your list can be separated by commas,<br>spaces, tabs, or line feeds
                            <br><br>
                            <table style="border: 1px solid #e6e6e6;">
                                <tr>
                                    <td colspan=3 style="font-weight:700">Valid identifier types:</td>
                                </tr>
                                <tr>
                                    <td style="font-size:11px;">UniProtKB</td>
                                    <!--td style="font-size:11px;">MI Ontology Term ID</td-->
                                </tr>
                                <tr>
                                    <td style="font-size:11px;">Gene RGD ID</td>
                                </tr>
                                <tr>
                                    <td style="font-size:11px;">Gene Symbol</td>
                                </tr>

                            </table>
                        </td>
                        <td style="padding-left:30px;">
                            Example: P35900, P26769,Q03343,<br>
                            <c:choose>
                                <c:when test="${model.symbolList!=null}">
                                    <textarea id="identifiers" name="identifiers"  rows="12" cols=70  >${model.symbolList}</textarea>
                                </c:when>
                                <c:otherwise>
                                    <textarea placeholder="When entering multiple identifiers your list can be separated by commas, spaces, tabs, or line feeds" id="identifiers" name="identifiers"  rows="12" cols=70  ></textarea>
                                </c:otherwise>
                            </c:choose>



                            <!--
                            <textarea name="genes" rows="12" cols=70 ng-model="importTarget" >
                                {{importTarget}}
                            </textarea>
                            -->
                        </td>

                    </tr>
                    <tr><td>&nbsp;</td></tr>

                    <tr>
                        <td><input type="submit" value="Submit" /></td>
                    </tr>

                </table>
            </div>


        </div>
        <div class="panel panel-default">
            <div class="panel-heading">
               <h1><a href="ftp://ftp.rgd.mcw.edu/pub/data_release/interactions/" target="_blank">Download All Interactions By Species</a></h1>
            </div>
            <div class="panel-body">

                   <a href="report.html?species=Rat"><strong>Browse all Rat interactions</strong></a>


            </div>
        </div>
    </div>
</form>
<%@ include file="/common/footerarea.jsp"%>
