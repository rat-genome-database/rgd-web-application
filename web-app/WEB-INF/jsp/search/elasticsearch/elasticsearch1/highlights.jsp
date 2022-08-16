<%@ page import="edu.mcw.rgd.web.RgdContext" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set value="true" var="first"/>
<c:set value="false" var="synonymExists"/>
<c:set value="false" var="symbolExists"/>
<c:set value="false" var="nameExists"/>
<c:set value="false" var="descripExists"/>
<c:set value="false" var="originExists"/>
<c:set value="false" var="srcExists"/>
<c:set value="false" var="titleExists"/>
<c:set value="false" var="termExists"/>
<c:set value="false" var="termDefExists"/>
<c:set value="false" var="citationExists"/>
<c:set value="false" var="authorExists"/>

<c:forEach items="${hit.getHighlightFields()}" var="hf">

    <c:if test="${hf.key=='xdbIdentifiers'}">
        <c:choose>
            <c:when test="${first=='true'}" >

                <span>External DB id</span>
                <c:set value="false" var="first"/>
            </c:when>
            <c:otherwise>
                , <span >External DB id</span>
            </c:otherwise>
        </c:choose>
    </c:if>


    <c:if test="${fn:containsIgnoreCase(hf.key, 'xdata')}">

        <c:choose>
            <c:when test="${first=='true'}" >

                <span >Experimental Data</span>
                <c:set value="false" var="first"/>
            </c:when>
            <c:otherwise>
                , <span >Experimental Data</span>
            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${hf.key=='symbol' || hf.key=='symbol.symbol' || hf.key=='symbol.keyword' || hf.key=='symbol.ngram' || hf.key=='htmlStrippedSymbol.ngram'}">
        <c:if test="${symbolExists=='false'}">
            <c:choose>
                <c:when test="${first=='true'}">
                    <span>Symbol</span>
                    <c:set value="true" var="symbolExists"/>
                    <c:set value="false" var="first"/>
                </c:when>
                <c:otherwise>
                    <span>, Symbol</span>
                    <c:set value="true" var="symbolExists"/>
                </c:otherwise>
            </c:choose>
        </c:if>
    </c:if>

    <c:if test="${hf.key=='synonyms' || hf.key=='synonyms.synonyms' }">
        <c:if test="${synonymExists=='false'}">
            <c:choose>
                <c:when test="${first=='true'}">
                    <span>Synonym/Alias</span>
                    <c:set value="true" var="synonymExists"/>
                    <c:set value="false" var="first"/>
                </c:when>
                <c:otherwise>
                    <span>, Synonym/Alias</span>
                    <c:set value="true" var="synonymExists"/>
                </c:otherwise>
            </c:choose>
        </c:if>
    </c:if>

    <c:if test="${hf.key=='name' || hf.key=='name.name'}">
        <c:choose>
            <c:when test="${first=='true'}" >
                <c:if test="${nameExists==false}">
                    <span>Name</span>
                    <c:set value="true" var="nameExists"/>
                    <c:set value="false" var="first"/>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:if test="${nameExists==false}">
                    <span>, Name</span>
                    <c:set value="true" var="nameExists"/>

                </c:if>
            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${hf.key=='description' || hf.key=='description.description'}">
        <c:choose>
            <c:when test="${first=='true'}" >
                <c:if test="${descripExists==false}">
                    <span>Description</span>
                    <c:set value="true" var="descripExists"/>
                    <c:set value="false" var="first"/>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:if test="${descripExists==false}">
                    <span>, Description</span>
                    <c:set value="true" var="descripExists"/>

                </c:if>
            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${hf.key=='origin' || hf.key=='origin.origin'}">
        <c:choose>
            <c:when test="${first=='true'}" >
                <c:if test="${originExists==false}">
                    <span>Origin</span>
                    <c:set value="true" var="originExists"/>
                    <c:set value="false" var="first"/>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:if test="${originExists==false}">
                    <span>, Origin</span>
                    <c:set value="true" var="originExists"/>

                </c:if>
            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${hf.key=='source' || hf.key=='source.source'}">
        <c:choose>
            <c:when test="${first=='true'}" >
                <c:if test="${srcExists==false}">
                    <span>Source</span>
                    <c:set value="true" var="srcExists"/>
                    <c:set value="false" var="first"/>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:if test="${srcExists==false}">
                    <span>, Source</span>
                    <c:set value="true" var="srcExists"/>

                </c:if>
            </c:otherwise>
        </c:choose>
    </c:if>

    <c:if test="${hf.key=='title' || hf.key=='title.title'}">
        <c:choose>
            <c:when test="${first=='true'}" >
                <c:if test="${titleExists==false}">
                    <span>Title</span>
                    <c:set value="true" var="titleExists"/>
                    <c:set value="false" var="first"/>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:if test="${titleExists==false}">
                    <span>, Title</span>
                    <c:set value="true" var="titleExists"/>

                </c:if>
            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${hf.key=='author' || hf.key=='author.author'}">
        <c:choose>
            <c:when test="${first=='true'}" >
                <c:if test="${authorExists==false}">
                    <span>Author</span>
                    <c:set value="true" var="authorExists"/>
                    <c:set value="false" var="first"/>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:if test="${authorExists==false}">
                    <span>, Author</span>
                    <c:set value="true" var="authorExists"/>

                </c:if>
            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${hf.key=='citation' || hf.key=='citation.citation'}">
        <c:choose>
            <c:when test="${first=='true'}" >
                <c:if test="${citationExists==false}">
                    <span>Citation</span>
                    <c:set value="true" var="citationExists"/>
                    <c:set value="false" var="first"/>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:if test="${citationExists==false}">
                    <span>, Citation</span>
                    <c:set value="true" var="citationExists"/>

                </c:if>
            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${hf.key=='term' || hf.key=='term.term'}">
        <c:choose>
            <c:when test="${first=='true'}" >
                <c:if test="${termExists==false}">
                    <span>Term</span>
                    <c:set value="true" var="termExists"/>
                    <c:set value="false" var="first"/>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:if test="${termExists==false}">
                    <span>, Term</span>
                    <c:set value="true" var="termExists"/>

                </c:if>
            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${hf.key=='term_def' || hf.key=='term_def.term'}">
        <c:choose>
            <c:when test="${first=='true'}" >
                <c:if test="${termDefExists==false}">
                    <span>Term_Def</span>
                    <c:set value="true" var="termDefExists"/>
                    <c:set value="false" var="first"/>
                </c:if>
            </c:when>
            <c:otherwise>
                <c:if test="${termDefExists==false}">
                    <span>, Term_Def</span>
                    <c:set value="true" var="termDefExists"/>

                </c:if>
            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${hf.key=='trait' ||  hf.key=='promoters' || hf.key=='type' || hf.key=='protein_acc_ids' ||
                            hf.key=='transcript_ids' || hf.key=='annotated_objects' || hf.key=='annotation_synonyms'}">
        <c:choose>
            <c:when test="${first=='true'}" >

                <span>${hf.key}</span>

                <c:set value="false" var="first"/>

            </c:when>
            <c:otherwise>
                <span>, ${hf.key}</span>

            </c:otherwise>
        </c:choose>
    </c:if>

    <c:if test="${hf.key=='subTrait'}">
        <c:choose>
            <c:when test="${first=='true'}" >

                <span>Measurement</span>

                <c:set value="false" var="first"/>

            </c:when>
            <c:otherwise>
                <span>, Measurement</span>

            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${hf.key=='refAbstract' || hf.key=='refAbstract.refAbstract'}">
        <c:choose>
            <c:when test="${first=='true'}" >

                <span>Abstract</span>

                <c:set value="false" var="first"/>

            </c:when>
            <c:otherwise>
                <span>, Abstract</span>

            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${hf.key=='associations'}">
        <c:choose>
            <c:when test="${first=='true'}" >

                <span>Related Genes</span>

                <c:set value="false" var="first"/>

            </c:when>
            <c:otherwise>
                <span>, Related Genes</span>

            </c:otherwise>
        </c:choose>
    </c:if>
    <c:if test="${hf.key=='genomicAlteration'}">
        <c:choose>
            <c:when test="${first=='true'}" >

                <span>Genomic Alteration</span>

                <c:set value="false" var="first"/>

            </c:when>
            <c:otherwise>
                <span>, Genomic Alteration</span>

            </c:otherwise>
        </c:choose>
    </c:if>
</c:forEach>
<% if(!RgdContext.isProduction()){%>
<a href="#" class="moreLink" style="color:dodgerblue" title="Matched fragments">Show Matches...</a>
<div  class="more hideContent" style="overflow-y: auto">
    <c:set value="true" var="first"/>
    <c:forEach items="${hit.getHighlightFields()}" var="hf">
        <strong>${fn:substring(hf.key,0,fn:indexOf(hf.key,"." ))}</strong>
        <c:forEach items="${hf.value.getFragments()}" var="f">
            ${f} ;
        </c:forEach>
    </c:forEach>
</div>
<%}%>