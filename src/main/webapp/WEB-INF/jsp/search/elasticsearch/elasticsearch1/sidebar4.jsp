
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<div>
<!--div><button id="viewAllBtn" style="display:none">View All Results</button></div-->
    <div>
       <c:if test="${!model.objectSearch.equals('true')}">
    <div style="width:40%;float:right">
        <form action="/rgdweb/elasticResults.html" id="viewAllForm">
            <input type="hidden" value="${model.term}" id="searchTerm" name="term"/>
            <input type="hidden" value="general" id="searchCategory" name="category"/>
            <!--input type="hidden" name="species" id = "sp1" value="${model.sp1}"-->
            <input type="hidden" name="type" id = "type" >
            <input type="hidden" name="viewall" value="true"/>
            <input type="hidden" name="chr" id = "chr" value="${model.searchBean.chr}">
            <input type="hidden" name="start" id="start" value="${model.searchBean.start}"/>
            <input type="hidden" name="stop" id = "stop" value="${model.searchBean.stop}"/>

            <button  type="submit" id="viewAll">View All Results</button>
        </form>

    </div>
       </c:if>
<h3>Filters</h3>

   </div>
<div id="jstree_results">

     <ul>

        <c:if test="${model.searchBean.category.equals('Gene') || model.searchBean.category.equals('Strain') || model.searchBean.category.equals('QTL')
                    || model.searchBean.category.equals('SSLP') || model.searchBean.category.equals('Variant') || model.searchBean.viewAll
                    || model.searchBean.category.equals('Ontology') || model.searchBean.category.equals('Cell line') || model.searchBean.category.equals('Promoter')
                    || (model.defaultAssembly !=null)}" >
            <c:if test="${fn:length(model.aggregations.species)>0}">
                <c:forEach items="${model.aggregations.species}" var="item">
                    <c:if test="${item.key.equalsIgnoreCase('rat')}">
                        <li><button style="border:none;background-color: transparent" onclick="filterClick('${model.searchBean.category}', '${item.key}','', '')"><span style="font-weight: bold;color:#24609c">${item.key} ( ${item.docCount})</span></button>
                            <ul>
                                <c:if test="${item.key.equalsIgnoreCase('rat')}">
                                    <!--c:if test="$--{fn:length(model.ratFilterBkts)>1}"-->
                                    <c:forEach items="${model.aggregations.rat}" var="ratFilterItem">

                                        <li> <button style="border:none;background-color: transparent" onclick="filterClick('${ratFilterItem.key}', '${item.key}','','')"><span>${ratFilterItem.key} (${ratFilterItem.docCount})</span></button>

                                            <ul>
                                                <c:if test="${ratFilterItem.key.equalsIgnoreCase('gene')}">
                                                    <c:forEach items="${model.aggregations.ratGene}" var="geneType">
                                                        <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                    </c:forEach>
                                                </c:if>
                                                <c:if test="${ratFilterItem.key.equalsIgnoreCase('variant')}">
                                                    <c:forEach items="${model.aggregations.ratVariant}" var="variantType">
                                                        <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                    </c:forEach>
                                                </c:if>
                                                <c:if test="${ratFilterItem.key.equalsIgnoreCase('qtl')}">

                                                    <c:forEach items="${model.aggregations.ratQTL}" var="qtlType">
                                                       <c:if test="${qtlType.key!='Not determined'}">
                                                            <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>
                                                        </c:if>
                                                    </c:forEach>
                                                </c:if>
                                                <c:if test="${ratFilterItem.key.equalsIgnoreCase('sslp')}">
                                                    <c:forEach items="${model.aggregations.ratSSLP}" var="sslpType">
                                                        <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                    </c:forEach>
                                                </c:if>
                                                <c:if test="${ratFilterItem.key.equalsIgnoreCase('strain')}">
                                                    <c:forEach items="${model.aggregations.ratStrain}" var="sslpType">
                                                        <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                    </c:forEach>
                                                </c:if>
                                            </ul>
                                        </li>
                                    </c:forEach>
                                    <!--/c:if-->
                                </c:if>
                       </ul>
                     </li>
                     </c:if>
              </c:forEach>
              </c:if>

                <c:if test="${fn:length(model.aggregations.species)>0}">

                <c:forEach items="${model.aggregations.species}" var="item">

                    <c:if test="${!item.key.equals('All') && !item.key.equalsIgnoreCase('rat')}">

                           <li><button style="border:none;background-color: transparent" onclick="filterClick('${model.searchBean.category}', '${item.key}','','')"><span style="font-weight: bold;color:#24609c">${item.key} ( ${item.docCount})</span></button>
                                  <ul>
                                            <c:if test="${item.key.equalsIgnoreCase('rat')}">
                                                <!--c:if test="$--{fn:length(model.ratFilterBkts)>1}"-->
                                                <c:forEach items="${model.aggregations.rat}" var="ratFilterItem">

                                                    <li> <button style="border:none;background-color: transparent" onclick="filterClick('${ratFilterItem.key}', '${item.key}','','')"><span>${ratFilterItem.key} (${ratFilterItem.docCount})</span></button>

                                                        <ul>
                                                            <c:if test="${ratFilterItem.key.equalsIgnoreCase('gene')}">
                                                                <c:forEach items="${model.aggregations.ratGene}" var="geneType">
                                                                    <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${ratFilterItem.key.equalsIgnoreCase('variant')}">
                                                                <c:forEach items="${model.aggregations.ratVariant}" var="variantType">
                                                                    <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${ratFilterItem.key.equalsIgnoreCase('qtl')}">
                                                                <c:forEach items="${model.aggregations.ratQTL}" var="qtlType">
                                                                    <c:if test="${qtlType.key!='Not determined'}">
                                                                    <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>
                                                                    </c:if>
                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${ratFilterItem.key.equalsIgnoreCase('sslp')}">
                                                                <c:forEach items="${model.aggregations.ratSSLP}" var="sslpType">
                                                                    <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${ratFilterItem.key.equalsIgnoreCase('strain')}">
                                                                <c:forEach items="${model.aggregations.ratStrain}" var="sslpType">
                                                                    <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                        </ul>
                                                    </li>
                                                </c:forEach>
                                                    <!--/c:if-->
                                            </c:if>
                                            <c:if test="${item.key.equalsIgnoreCase('human')}">
                                                <!--c:if test="$--{fn:length(model.humanFilterBkts)>1}"-->
                                                <c:forEach items="${model.aggregations.human}" var="humanFilterItem">
                                                 <c:if test="${humanFilterItem.key.equalsIgnoreCase('gene')}">
                                                   <li><button style="border:none;background-color: transparent" onclick="filterClick('${humanFilterItem.key}', '${item.key}','','')"><span>${humanFilterItem.key} (${humanFilterItem.docCount})</span></button>

                                                       <ul>
                                                           <c:if test="${humanFilterItem.key.equalsIgnoreCase('gene')}">
                                                               <c:forEach items="${model.aggregations.humanGene}" var="geneType">
                                                                   <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${humanFilterItem.key.equalsIgnoreCase('variant')}">
                                                               <c:forEach items="${model.aggregations.humanVariant}" var="variantType">
                                                                   <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${humanFilterItem.key.equalsIgnoreCase('qtl')}">
                                                               <c:forEach items="${model.aggregations.humanQTL}" var="qtlType">

                                                                   <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>

                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${humanFilterItem.key.equalsIgnoreCase('sslp')}">
                                                               <c:forEach items="${model.aggregations.humanSSLP}" var="sslpType">
                                                                   <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                   </ul>
                                                   </li>
                                                   </c:if>
                                                </c:forEach>
                                                <c:forEach items="${model.aggregations.human}" var="humanFilterItem">
                                                 <c:if test="${!humanFilterItem.key.equalsIgnoreCase('gene')}">
                                                      <li><button style="border:none;background-color: transparent" onclick="filterClick('${humanFilterItem.key}', '${item.key}','','')"><span>${humanFilterItem.key} (${humanFilterItem.docCount})</span></button>
                                                          <ul>
                                                          <c:if test="${humanFilterItem.key.equalsIgnoreCase('gene')}">
                                                          <c:forEach items="${model.aggregations.humanGene}" var="geneType">
                                                          <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                           </c:forEach>
                                                  </c:if>
                                                 <c:if test="${humanFilterItem.key.equalsIgnoreCase('variant')}">
                                                         <c:forEach items="${model.aggregations.humanVariant}" var="variantType">
                                                          <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                          </c:forEach>
                                                  </c:if>
                                                              <c:if test="${humanFilterItem.key.equalsIgnoreCase('qtl')}">
                                                                  <c:forEach items="${model.aggregations.humanQTL}" var="qtlType">

                                                                      <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>

                                                                  </c:forEach>
                                                              </c:if>
                                                              <c:if test="${humanFilterItem.key.equalsIgnoreCase('sslp')}">
                                                                  <c:forEach items="${model.aggregations.humanSSLP}" var="sslpType">
                                                                      <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                                  </c:forEach>
                                                              </c:if>
                                                          </ul>
                                                      </li>
                                                 </c:if>
                                                </c:forEach>
                                            <!--/c:if-->

                                            </c:if>
                                            <c:if test="${item.key.equalsIgnoreCase('mouse')}">
                                                <!--c:if test="$--{fn:length(model.mouseFilterBkts)>1}"-->
                                                <c:forEach items="${model.aggregations.mouse}" var="mouseFilterItem">
                                                    <li><button style="border:none;background-color: transparent" onclick="filterClick('${mouseFilterItem.key}', '${item.key}','','')"><span>${mouseFilterItem.key} (${mouseFilterItem.docCount})</span></button>
                                                        <ul>
                                                            <c:if test="${mouseFilterItem.key.equalsIgnoreCase('gene')}">
                                                                <c:forEach items="${model.aggregations.mouseGene}" var="geneType">
                                                                    <li onclick="filterClick('${mouseFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${mouseFilterItem.key.equalsIgnoreCase('variant')}">
                                                                <c:forEach items="${model.aggregations.mouseVariant}" var="variantType">
                                                                    <li onclick="filterClick('${mouseFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${mouseFilterItem.key.equalsIgnoreCase('qtl')}">
                                                                <c:forEach items="${model.aggregations.mouseQTL}" var="qtlType">

                                                                    <li onclick="filterClick('${mouseFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>

                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${mouseFilterItem.key.equalsIgnoreCase('sslp')}">
                                                                <c:forEach items="${model.aggregations.mouseSSLP}" var="sslpType">
                                                                    <li onclick="filterClick('${mouseFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                        </ul>

                                                    </li>
                                                </c:forEach>
                                                <!--/c:if-->

                                            </c:if>
                                            <c:if test="${item.key.equalsIgnoreCase('dog')}">

                                                <c:forEach items="${model.aggregations.dog}" var="dogFilterItem">
                                                    <li><button style="border:none;background-color: transparent" onclick="filterClick('${dogFilterItem.key}', '${item.key}','','')"><span style= >${dogFilterItem.key} (${dogFilterItem.docCount})</span></button>


                                                            <ul>
                                                                <c:if test="${dogFilterItem.key.equalsIgnoreCase('gene')}">
                                                                    <c:forEach items="${model.aggregations.dogGene}" var="geneType">
                                                                        <li onclick="filterClick('${dogFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                                    </c:forEach>
                                                                </c:if>
                                                                <c:if test="${dogFilterItem.key.equalsIgnoreCase('variant')}">
                                                                    <c:forEach items="${model.aggregations.dogVariant}" var="variantType">
                                                                        <li onclick="filterClick('${dogFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                                    </c:forEach>
                                                                </c:if>
                                                                <c:if test="${dogFilterItem.key.equalsIgnoreCase('qtl')}">
                                                                    <c:forEach items="${model.aggregations.dogQTL}" var="qtlType">

                                                                        <li onclick="filterClick('${dogFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>

                                                                    </c:forEach>
                                                                </c:if>
                                                                <c:if test="${dogFilterItem.key.equalsIgnoreCase('sslp')}">
                                                                    <c:forEach items="${model.aggregations.dogSSLP}" var="sslpType">
                                                                        <li onclick="filterClick('${dogFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                                    </c:forEach>
                                                                </c:if>
                                                            </ul>

                                                        </li>

                                                </c:forEach>


                                            </c:if>
                                            <c:if test="${item.key.equalsIgnoreCase('chinchilla')}">

                                                <c:forEach items="${model.aggregations.chinchilla}" var="chinchillaFilterItem">
                                                    <li><button style="border:none;background-color: transparent" onclick="filterClick('${chinchillaFilterItem.key}', '${item.key}','','')"><span style=>${chinchillaFilterItem.key} (${chinchillaFilterItem.docCount})</span></button>

                                                            <ul>
                                                                <c:if test="${chinchillaFilterItem.key.equalsIgnoreCase('gene')}">
                                                                    <c:forEach items="${model.aggregations.chinchillaGene}" var="geneType">
                                                                        <li onclick="filterClick('${chinchillaFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                                    </c:forEach>
                                                                </c:if>
                                                                <c:if test="${chinchillaFilterItem.key.equalsIgnoreCase('variant')}">
                                                                    <c:forEach items="${model.aggregations.chinchillaVariant}" var="variantType">
                                                                        <li onclick="filterClick('${chinchillaFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                                    </c:forEach>
                                                                </c:if>
                                                                <c:if test="${chinchillaFilterItem.key.equalsIgnoreCase('qtl')}">
                                                                    <c:forEach items="${model.aggregations.chinchillaQTL}" var="qtlType">

                                                                        <li onclick="filterClick('${chinchillaFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>

                                                                    </c:forEach>
                                                                </c:if>
                                                                <c:if test="${chinchillaFilterItem.key.equalsIgnoreCase('sslp')}">
                                                                    <c:forEach items="${model.aggregations.chinchillaSSLP}" var="sslpType">
                                                                        <li onclick="filterClick('${chinchillaFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                                    </c:forEach>
                                                                </c:if>
                                                            </ul>

                                                        </li>

                                                </c:forEach>


                                            </c:if>
                                            <c:if test="${item.key.equalsIgnoreCase('bonobo')}">

                                                <c:forEach items="${model.aggregations.bonobo}" var="bonoboFilterItem">
                                                   <li><button style="border:none;background-color: transparent" onclick="filterClick('${bonoboFilterItem.key}', '${item.key}','','')"><span >${bonoboFilterItem.key} (${bonoboFilterItem.docCount})</span></button>
                                                       <ul>
                                                           <c:if test="${bonoboFilterItem.key.equalsIgnoreCase('gene')}">
                                                               <c:forEach items="${model.aggregations.bonoboGene}" var="geneType">
                                                                   <li onclick="filterClick('${bonoboFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${bonoboFilterItem.key.equalsIgnoreCase('variant')}">
                                                               <c:forEach items="${model.aggregations.bonoboVariant}" var="variantType">
                                                                   <li onclick="filterClick('${bonoboFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${bonoboFilterItem.key.equalsIgnoreCase('qtl')}">
                                                               <c:forEach items="${model.aggregations.bonoboQTL}" var="qtlType">
                                                                   <li onclick="filterClick('${bonoboFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${bonoboFilterItem.key.equalsIgnoreCase('sslp')}">
                                                               <c:forEach items="${model.aggregations.bonoboSSLP}" var="sslpType">
                                                                   <li onclick="filterClick('${bonoboFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                       </ul>

                                                   </li>
                                                </c:forEach>


                                            </c:if>
                                            <c:if test="${item.key.equalsIgnoreCase('squirrel')}">

                                                <c:forEach items="${model.aggregations.squirrel}" var="squirrelFilterItem">
                                                   <li><button style="border:none;background-color: transparent" onclick="filterClick('${squirrelFilterItem.key}', '${item.key}','','')"><span>${squirrelFilterItem.key} (${squirrelFilterItem.docCount})</span></button>

                                                       <ul>
                                                           <c:if test="${squirrelFilterItem.key.equalsIgnoreCase('gene')}">
                                                               <c:forEach items="${model.aggregations.squirrelGene}" var="geneType">
                                                                   <li onclick="filterClick('${squirrelFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${squirrelFilterItem.key.equalsIgnoreCase('variant')}">
                                                               <c:forEach items="${model.aggregations.squirrelVariant}" var="variantType">
                                                                   <li onclick="filterClick('${squirrelFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${squirrelFilterItem.key.equalsIgnoreCase('qtl')}">
                                                               <c:forEach items="${model.aggregations.squirrelQTL}" var="qtlType">

                                                                   <li onclick="filterClick('${squirrelFilterItem.key}', '${item.key}','', '${qtlType.key}'),'trait'">${qtlType.key} (${qtlType.docCount})</li>

                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${squirrelFilterItem.key.equalsIgnoreCase('sslp')}">
                                                               <c:forEach items="${model.aggregations.squirrelSSLP}" var="sslpType">
                                                                   <li onclick="filterClick('${squirrelFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                       </ul>
                                                   </li>
                                                </c:forEach>

                                             </c:if>
                                      <c:if test="${item.key.equalsIgnoreCase('pig')}">

                                          <c:forEach items="${model.aggregations.pig}" var="pigFilterItem">
                                              <li><button style="border:none;background-color: transparent" onclick="filterClick('${pigFilterItem.key}', '${item.key}','','')"><span>${pigFilterItem.key} (${pigFilterItem.docCount})</span></button>

                                                  <ul>
                                                      <c:if test="${pigFilterItem.key.equalsIgnoreCase('gene')}">
                                                          <c:forEach items="${model.aggregations.pigGene}" var="geneType">
                                                              <li onclick="filterClick('${pigFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                          </c:forEach>
                                                      </c:if>
                                                      <c:if test="${pigFilterItem.key.equalsIgnoreCase('variant')}">
                                                          <c:forEach items="${model.aggregations.pigVariant}" var="variantType">
                                                              <li onclick="filterClick('${pigFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                          </c:forEach>
                                                      </c:if>
                                                      <c:if test="${pigFilterItem.key.equalsIgnoreCase('qtl')}">
                                                          <c:forEach items="${model.aggregations.pigQTL}" var="qtlType">

                                                              <li onclick="filterClick('${pigFilterItem.key}', '${item.key}','', '${qtlType.key}'),'trait'">${qtlType.key} (${qtlType.docCount})</li>

                                                          </c:forEach>
                                                      </c:if>
                                                      <c:if test="${pigFilterItem.key.equalsIgnoreCase('sslp')}">
                                                          <c:forEach items="${model.aggregations.pigSSLP}" var="sslpType">
                                                              <li onclick="filterClick('${pigFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                          </c:forEach>
                                                      </c:if>
                                                  </ul>
                                              </li>
                                          </c:forEach>

                                      </c:if>
                                      <c:if test="${item.key.equalsIgnoreCase('Green Monkey')}">

                                          <c:forEach items="${model.aggregations.greenmonkey}" var="greenMonkeyFilterItem">
                                              <li><button style="border:none;background-color: transparent" onclick="filterClick('${greenMonkeyFilterItem.key}', '${item.key}','','')"><span>${greenMonkeyFilterItem.key} (${greenMonkeyFilterItem.docCount})</span></button>

                                                  <ul>
                                                      <c:if test="${greenMonkeyFilterItem.key.equalsIgnoreCase('gene')}">
                                                          <c:forEach items="${model.aggregations.greenmonkeyGene}" var="geneType">
                                                              <li onclick="filterClick('${greenMonkeyFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                          </c:forEach>
                                                      </c:if>
                                                      <c:if test="${greenMonkeyFilterItem.key.equalsIgnoreCase('variant')}">
                                                          <c:forEach items="${model.aggregations.greenmonkeyVariant}" var="variantType">
                                                              <li onclick="filterClick('${greenMonkeyFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                          </c:forEach>
                                                      </c:if>
                                                      <c:if test="${greenMonkeyFilterItem.key.equalsIgnoreCase('qtl')}">
                                                          <c:forEach items="${model.aggregations.greenmonkeyQTL}" var="qtlType">

                                                              <li onclick="filterClick('${greenMonkeyFilterItem.key}', '${item.key}','', '${qtlType.key}'),'trait'">${qtlType.key} (${qtlType.docCount})</li>

                                                          </c:forEach>
                                                      </c:if>
                                                      <c:if test="${greenMonkeyFilterItem.key.equalsIgnoreCase('sslp')}">
                                                          <c:forEach items="${model.aggregations.greenmonkeySSLP}" var="sslpType">
                                                              <li onclick="filterClick('${greenMonkeyFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                          </c:forEach>
                                                      </c:if>
                                                  </ul>
                                              </li>
                                          </c:forEach>

                                      </c:if>
                                      <c:if test="${item.key.equalsIgnoreCase('Naked Mole-rat')}">

                                          <c:forEach items="${model.aggregations.nakedmolerat}" var="greenMonkeyFilterItem">
                                              <li><button style="border:none;background-color: transparent" onclick="filterClick('${greenMonkeyFilterItem.key}', '${item.key}','','')"><span>${greenMonkeyFilterItem.key} (${greenMonkeyFilterItem.docCount})</span></button>

                                                  <ul>
                                                      <c:if test="${greenMonkeyFilterItem.key.equalsIgnoreCase('gene')}">
                                                          <c:forEach items="${model.aggregations.nakedmoleratGene}" var="geneType">
                                                              <li onclick="filterClick('${greenMonkeyFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                          </c:forEach>
                                                      </c:if>
                                                      <c:if test="${greenMonkeyFilterItem.key.equalsIgnoreCase('variant')}">
                                                          <c:forEach items="${model.aggregations.nakedmoleratVariant}" var="variantType">
                                                              <li onclick="filterClick('${greenMonkeyFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                          </c:forEach>
                                                      </c:if>
                                                      <c:if test="${greenMonkeyFilterItem.key.equalsIgnoreCase('qtl')}">
                                                          <c:forEach items="${model.aggregations.nakedmoleratQTL}" var="qtlType">

                                                              <li onclick="filterClick('${greenMonkeyFilterItem.key}', '${item.key}','', '${qtlType.key}'),'trait'">${qtlType.key} (${qtlType.docCount})</li>

                                                          </c:forEach>
                                                      </c:if>
                                                      <c:if test="${greenMonkeyFilterItem.key.equalsIgnoreCase('sslp')}">
                                                          <c:forEach items="${model.aggregations.nakedmoleratSSLP}" var="sslpType">
                                                              <li onclick="filterClick('${greenMonkeyFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                          </c:forEach>
                                                      </c:if>
                                                  </ul>
                                              </li>
                                          </c:forEach>

                                      </c:if>
                                  </ul>
                           </li>
                    </c:if>
                </c:forEach>


                </c:if>
            </c:if>
         <li><span style="font-weight: bold;color:#24609c">Other Categories:</span>
             <ul>

                     <c:forEach items="${model.aggregations.category}" var="item">
                <c:if test="${item.key.equalsIgnoreCase('reference')}">
                        <li style="border:none;background-color: transparent;cursor: pointer" onclick="filterClick('${item.key}', '')">${item.key}(${item.docCount})</li>
                </c:if>
            </c:forEach>

             <c:if test="${fn:length(model.aggregations.ontology)>0}">

                 <c:forEach items="${model.aggregations.category}" var="item">
                 <c:if test="${item.key.equalsIgnoreCase('ontology')}">
                     <li><span style="font-weight: bold">Ontology Terms: (${item.docCount})</span>
              <ul>
                   <c:forEach items="${model.aggregations.ontology}" var="ontItem">
                       <li>
                           <button style="border:none;background-color: transparent;cursor:pointer" onclick="filterClick('Ontology', '','${ontItem.key}')">${ontItem.key}</button>(${ontItem.docCount})</li>
                   </c:forEach>
              </ul>
                 </li>
                     </c:if>
                 </c:forEach>
           </c:if>



         </ul>
         </li>
         <!--li><span style="font-weight: bold;color:#24609c">Assembly</span-->
             <!--ul>
                 <c:forEach items="${model.aggregations.assembly}"  var="item">
                     <li  onclick="filterClick('', '','','','', '${item.key}')">${item.key}&nbsp;(${item.docCount})</li>
                 </c:forEach>

             </ul-->
             <!--ul>
                 <c:forEach items="${model.assemblyMapsByRank}"  var="item">
                    <c:forEach items="${model.aggregations.assembly}" var="map">
                        <c:if test="${map.key==item.value}">
                     <li  onclick="filterClick('', '','','','', '${map.key}')">${map.key}&nbsp;(${map.docCount})</li>
                        </c:if>
                    </c:forEach>
                 </c:forEach>

             </ul>

         </li-->
         </ul>

       </div>



</div>