
<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 3/15/2024
  Time: 12:52 PM
  To change this template use File | Settings | File Templates.
--%>
<c:if test="${model.totalHits == 10000}">
  <span style="font-weight: bold">Showing Top</span>
</c:if>
<span style="color:#24609c;font-size:15px;"><span id="totalHits"><strong>${model.totalHits}</strong></span>
                            <c:if test="${fn:toLowerCase(model.searchBean.category)!='general' && model.searchBean.category!='Ontology'}">
                              <c:if test="${model.searchBean.type!='null'}">
                                <span style="color:blue">${model.searchBean.type}</span>
                              </c:if>
                              <c:if test="${model.searchBean.trait!=null && model.searchBean.trait!='null'}">
                                <span style="color:blue">${model.searchBean.trait}</span>
                              </c:if>
                              <span class="${model.searchBean.category}">${model.searchBean.category}</span>
                            </c:if>
                             <c:if test="${model.searchBean.category=='Ontology' && model.searchBean.subCat!=''}">
                               <span class="${model.searchBean.category}" style="color:mediumpurple;font-weight: bold;" > ${model.searchBean.subCat}</span>
                             </c:if>
                             <c:if test="${model.searchBean.category=='Ontology' && model.searchBean.subCat==''}">
                               <span class="${model.searchBean.category}" style="color:mediumpurple;font-weight: bold;" > ${model.searchBean.category}</span>
                             </c:if>
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
<h4>Showing results <span id="showResultsFrom">1</span> - <span id="showResultsTo"><c:if test="${model.totalHits<50}">${model.totalHits}</c:if>
        <c:if test="${model.totalHits>50}">50</c:if></span> of ${model.totalHits} results</h4>
