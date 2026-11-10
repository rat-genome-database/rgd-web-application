
<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 3/15/2024
  Time: 12:52 PM
  To change this template use File | Settings | File Templates.
--%>
<%-- "Showing Top" used to appear here on exactly 10000 hits, which was how a capped count showed
     itself: Elasticsearch stopped counting at 10000 and reported it as the total. The search now
     sets track_total_hits, so 10000 means ten thousand and the label would be a lie. --%>
<span style="color:#24609c;font-size:15px;"><span id="totalHits"><strong>${model.totalHits}</strong></span>

        results found for search.. <c:if test="${model.term!=''}"><strong>Term:${model.term}</strong></c:if>


    </span>


<c:if test="${model.searchBean.species!='' || fn:length(model.aggregations.species)==1}">
  &nbsp;|&nbsp;species: <span class="${model.searchBean.species} ${model.aggregations.species[0].key}" style="font-weight: bold; font-size: 16px">
                    <c:if test="${model.searchBean.species!=''}">
                      ${model.searchBean.species}
                    </c:if>
                     <c:if test="${fn:length(model.aggregations.species)==1 && model.searchBean.species==''}">
                       ${model.aggregations.species[0].key}
                     </c:if>
                          </span>

</c:if>
<c:if test="${(model.searchBean.chr!='0' && model.searchBean.chr!='') || model.searchBean.start!='' || model.searchBean.stop!=''}">
  &nbsp;|&nbsp;Location <span style="font-weight:bold;font-size: 15px"><c:if test="${model.searchBean.chr!=''}">CHR-</c:if>${(model.searchBean.chr)}:&nbsp;${model.searchBean.start}-${model.searchBean.stop}</span>
</c:if>
<c:if test="${model.searchBean.category!=null}">
    &nbsp;|&nbsp;Category:&nbsp;<span class="${model.searchBean.category}" style="font-size: 16px">${model.searchBean.category}</span>
</c:if>

<c:if test="${fn:toLowerCase(model.searchBean.category)!='general' && model.searchBean.category!='Ontology'}">
    <c:if test="${model.searchBean.type!=null && model.searchBean.type!=''}">
        &nbsp;|&nbsp;Filter: <span style="color:blue; font-size: 16px;font-weight: bold">${model.searchBean.type}</span>
    </c:if>
    <c:if test="${model.searchBean.trait!=null && model.searchBean.trait!='' && model.searchBean.trait!='null'}">
        &nbsp;|&nbsp;Filter: <span style="color:blue;font-size: 16px;font-weight: bold">${model.searchBean.trait}</span>
    </c:if>
    <c:if test="${model.searchBean.variantCategory!=null && model.searchBean.variantCategory!='' && model.searchBean.variantCategory!='null'}">
        &nbsp;|&nbsp;Filter:  <span style="color:blue;font-size: 16px;font-weight: bold">${model.searchBean.variantCategory}</span>
    </c:if>
    <c:if test="${model.searchBean.polyphenStatus!=null && model.searchBean.polyphenStatus!='' && model.searchBean.polyphenStatus!='null'}">
        &nbsp;|&nbsp;Filter: <span style="color:blue;font-size: 16px;font-weight: bold">${model.searchBean.polyphenStatus}</span>
    </c:if>
    <c:if test="${model.searchBean.region!=null && model.searchBean.region!='' && model.searchBean.region!='null'}">
        &nbsp;|&nbsp;Filter: <span style="color:blue;font-size: 16px;font-weight: bold">${model.searchBean.region}</span>
    </c:if>
    <c:if test="${model.searchBean.sample!=null && model.searchBean.sample!='' && model.searchBean.sample!='null'}">
        &nbsp;|&nbsp;Filter: <span style="color:blue;font-size: 16px;font-weight: bold">${model.searchBean.sample}</span>
    </c:if>

</c:if>
<c:if test="${model.searchBean.category=='Ontology' && model.searchBean.subCat!=''}">
    &nbsp;|&nbsp;Filter:  <span class="${model.searchBean.category}" style="color:mediumpurple;font-weight: bold;" > ${model.searchBean.subCat}</span>
</c:if>
<c:if test="${model.searchBean.category=='Ontology' && model.searchBean.subCat==''}">
    &nbsp;|&nbsp;Filter: <span class="${model.searchBean.category}" style="color:mediumpurple;font-weight: bold;" > ${model.searchBean.category}</span>
</c:if>
<%-- The page size was hardcoded as 50 here, so a first page of 500 still announced "1 - 50".
     elasticsearch.js rewrites these two spans on every page change; this is the first render. --%>
<h4>Showing results <span id="showResultsFrom">1</span> - <span id="showResultsTo">${model.totalHits lt model.searchBean.size ? model.totalHits : model.searchBean.size}</span> of ${model.totalHits} results</h4>
