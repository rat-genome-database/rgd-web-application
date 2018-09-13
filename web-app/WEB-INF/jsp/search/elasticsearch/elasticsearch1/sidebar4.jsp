<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<div>
<!--div><button id="viewAllBtn" style="display:none">View All Results</button></div-->
    <div>
       <c:if test="${!model.objectSearch.equals('true')}">
    <div style="width:40%;float:right">
        <form action="/rgdweb/elasticResults.html" id="viewAllForm">
            <input type="hidden" value="${model.term}" id="searchTerm" name="term"/>
            <input type="hidden" value="${model.cat1}" id="searchCategory" name="category"/>
            <input type="hidden" name="species" id = "sp1" value="${model.sp1}">
            <input type="hidden" name="type" id = "type" >
            <input type="hidden" name="viewall" value="true"/>
            <input type="hidden" name="chr" id = "chr" value="${model.chr}">
            <input type="hidden" name="start" id="start" value="${model.start}"/>
            <input type="hidden" name="stop" id = "stop" value="${model.stop}"/>

            <button  type="submit" id="viewAll">View All Results</button>
        </form>

    </div>
       </c:if>
<h3>Filters</h3>
   </div>
<div id="jstree_results">

     <ul>
        <c:if test="${model.category.equals('Gene') || model.category.equals('Strain') || model.category.equals('QTL')
                    || model.category.equals('SSLP') || model.category.equals('Variant') || model.viewall.equals('true') || model.category.equals('Ontology') || model.category.equals('Cell line') || model.category.equals('Promoter')}" >
            <c:if test="${fn:length(model.speciesBkts)>0}">
                <c:forEach items="${model.speciesBkts}" var="item">
                    <c:if test="${item.key.equalsIgnoreCase('rat')}">
                        <li><button style="border:none;background-color: transparent" onclick="filterClick('${model.category}', '${item.key}','')"><span style="font-weight: bold;color:#24609c">${item.key} ( ${item.docCount})</span></button>
                            <ul>
                                <c:if test="${item.key.equalsIgnoreCase('rat')}">
                                    <!--c:if test="$--{fn:length(model.ratFilterBkts)>1}"-->
                                    <c:forEach items="${model.ratFilterBkts}" var="ratFilterItem">

                                        <li> <button style="border:none;background-color: transparent" onclick="filterClick('${ratFilterItem.key}', '${item.key}')"><span>${ratFilterItem.key} (${ratFilterItem.docCount})</span></button>

                                            <ul>
                                                <c:if test="${ratFilterItem.key.equalsIgnoreCase('gene')}">
                                                    <c:forEach items="${model.ratGeneTypeBkts}" var="geneType">
                                                        <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                    </c:forEach>
                                                </c:if>
                                                <c:if test="${ratFilterItem.key.equalsIgnoreCase('variant')}">
                                                    <c:forEach items="${model.ratVariantTypeBkts}" var="variantType">
                                                        <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                    </c:forEach>
                                                </c:if>
                                                <c:if test="${ratFilterItem.key.equalsIgnoreCase('qtl')}">
                                                    <c:forEach items="${model.ratQtlTypeBkts}" var="qtlType">
                                                        <c:if test="${qtlType.key!='Not determined'}">
                                                            <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>
                                                        </c:if>
                                                    </c:forEach>
                                                </c:if>
                                                <c:if test="${ratFilterItem.key.equalsIgnoreCase('sslp')}">
                                                    <c:forEach items="${model.ratSslpTypeBkts}" var="sslpType">
                                                        <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                    </c:forEach>
                                                </c:if>
                                                <c:if test="${ratFilterItem.key.equalsIgnoreCase('strain')}">
                                                    <c:forEach items="${model.ratStrainTypeBkts}" var="sslpType">
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

                <c:if test="${fn:length(model.speciesBkts)>0}">

                <c:forEach items="${model.speciesBkts}" var="item">

                    <c:if test="${!item.key.equals('All') && !item.key.equalsIgnoreCase('rat')}">

                           <li><button style="border:none;background-color: transparent" onclick="filterClick('${model.category}', '${item.key}','')"><span style="font-weight: bold;color:#24609c">${item.key} ( ${item.docCount})</span></button>
                                  <ul>
                                            <c:if test="${item.key.equalsIgnoreCase('rat')}">
                                                <!--c:if test="$--{fn:length(model.ratFilterBkts)>1}"-->
                                                <c:forEach items="${model.ratFilterBkts}" var="ratFilterItem">

                                                    <li> <button style="border:none;background-color: transparent" onclick="filterClick('${ratFilterItem.key}', '${item.key}')"><span>${ratFilterItem.key} (${ratFilterItem.docCount})</span></button>

                                                        <ul>
                                                            <c:if test="${ratFilterItem.key.equalsIgnoreCase('gene')}">
                                                                <c:forEach items="${model.ratGeneTypeBkts}" var="geneType">
                                                                    <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${ratFilterItem.key.equalsIgnoreCase('variant')}">
                                                                <c:forEach items="${model.ratVariantTypeBkts}" var="variantType">
                                                                    <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${ratFilterItem.key.equalsIgnoreCase('qtl')}">
                                                                <c:forEach items="${model.ratQtlTypeBkts}" var="qtlType">
                                                                    <c:if test="${qtlType.key!='Not determined'}">
                                                                    <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>
                                                                    </c:if>
                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${ratFilterItem.key.equalsIgnoreCase('sslp')}">
                                                                <c:forEach items="${model.ratSslpTypeBkts}" var="sslpType">
                                                                    <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${ratFilterItem.key.equalsIgnoreCase('strain')}">
                                                                <c:forEach items="${model.ratStrainTypeBkts}" var="sslpType">
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
                                                <c:forEach items="${model.humanFilterBkts}" var="humanFilterItem">
                                                 <c:if test="${humanFilterItem.key.equalsIgnoreCase('gene')}">
                                                   <li><button style="border:none;background-color: transparent" onclick="filterClick('${humanFilterItem.key}', '${item.key}')"><span>${humanFilterItem.key} (${humanFilterItem.docCount})</span></button>

                                                       <ul>
                                                           <c:if test="${humanFilterItem.key.equalsIgnoreCase('gene')}">
                                                               <c:forEach items="${model.humanGeneTypeBkts}" var="geneType">
                                                                   <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${humanFilterItem.key.equalsIgnoreCase('variant')}">
                                                               <c:forEach items="${model.humanVariantTypeBkts}" var="variantType">
                                                                   <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${humanFilterItem.key.equalsIgnoreCase('qtl')}">
                                                               <c:forEach items="${model.humanQtlTypeBkts}" var="qtlType">

                                                                   <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>

                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${humanFilterItem.key.equalsIgnoreCase('sslp')}">
                                                               <c:forEach items="${model.humanSslpTypeBkts}" var="sslpType">
                                                                   <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                   </ul>
                                                   </li>
                                                   </c:if>
                                                </c:forEach>
                                                <c:forEach items="${model.humanFilterBkts}" var="humanFilterItem">
                                                 <c:if test="${!humanFilterItem.key.equalsIgnoreCase('gene')}">
                                                                                                   <li><button style="border:none;background-color: transparent" onclick="filterClick('${humanFilterItem.key}', '${item.key}')"><span>${humanFilterItem.key} (${humanFilterItem.docCount})</span></button>

                                                                                                       <ul>
                                                                                                           <c:if test="${humanFilterItem.key.equalsIgnoreCase('gene')}">
                                                                                                               <c:forEach items="${model.humanGeneTypeBkts}" var="geneType">
                                                                                                                   <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                                                                               </c:forEach>
                                                                                                           </c:if>
                                                                                                           <c:if test="${humanFilterItem.key.equalsIgnoreCase('variant')}">
                                                                                                               <c:forEach items="${model.humanVariantTypeBkts}" var="variantType">
                                                                                                                   <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                                                                               </c:forEach>
                                                                                                           </c:if>
                                                                                                           <c:if test="${humanFilterItem.key.equalsIgnoreCase('qtl')}">
                                                                                                               <c:forEach items="${model.humanQtlTypeBkts}" var="qtlType">

                                                                                                                   <li onclick="filterClick('${humanFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>

                                                                                                               </c:forEach>
                                                                                                           </c:if>
                                                                                                           <c:if test="${humanFilterItem.key.equalsIgnoreCase('sslp')}">
                                                                                                               <c:forEach items="${model.humanSslpTypeBkts}" var="sslpType">
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
                                                <c:forEach items="${model.mouseFilterBkts}" var="mouseFilterItem">
                                                    <li><button style="border:none;background-color: transparent" onclick="filterClick('${mouseFilterItem.key}', '${item.key}')"><span>${mouseFilterItem.key} (${mouseFilterItem.docCount})</span></button>
                                                        <ul>
                                                            <c:if test="${mouseFilterItem.key.equalsIgnoreCase('gene')}">
                                                                <c:forEach items="${model.mouseGeneTypeBkts}" var="geneType">
                                                                    <li onclick="filterClick('${mouseFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${mouseFilterItem.key.equalsIgnoreCase('variant')}">
                                                                <c:forEach items="${model.mouseVariantTypeBkts}" var="variantType">
                                                                    <li onclick="filterClick('${mouseFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${mouseFilterItem.key.equalsIgnoreCase('qtl')}">
                                                                <c:forEach items="${model.mouseQtlTypeBkts}" var="qtlType">

                                                                    <li onclick="filterClick('${mouseFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>

                                                                </c:forEach>
                                                            </c:if>
                                                            <c:if test="${mouseFilterItem.key.equalsIgnoreCase('sslp')}">
                                                                <c:forEach items="${model.mouseSslpTypeBkts}" var="sslpType">
                                                                    <li onclick="filterClick('${mouseFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                                </c:forEach>
                                                            </c:if>
                                                        </ul>

                                                    </li>
                                                </c:forEach>
                                                <!--/c:if-->

                                            </c:if>
                                            <c:if test="${item.key.equalsIgnoreCase('dog')}">

                                                <c:forEach items="${model.dogFilterBkts}" var="dogFilterItem">
                                                    <li><button style="border:none;background-color: transparent" onclick="filterClick('${dogFilterItem.key}', '${item.key}')"><span style= >${dogFilterItem.key} (${dogFilterItem.docCount})</span></button>


                                                            <ul>
                                                                <c:if test="${dogFilterItem.key.equalsIgnoreCase('gene')}">
                                                                    <c:forEach items="${model.dogGeneTypeBkts}" var="geneType">
                                                                        <li onclick="filterClick('${dogFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                                    </c:forEach>
                                                                </c:if>
                                                                <c:if test="${dogFilterItem.key.equalsIgnoreCase('variant')}">
                                                                    <c:forEach items="${model.dogVariantTypeBkts}" var="variantType">
                                                                        <li onclick="filterClick('${dogFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                                    </c:forEach>
                                                                </c:if>
                                                                <c:if test="${dogFilterItem.key.equalsIgnoreCase('qtl')}">
                                                                    <c:forEach items="${model.dogQtlTypeBkts}" var="qtlType">

                                                                        <li onclick="filterClick('${dogFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>

                                                                    </c:forEach>
                                                                </c:if>
                                                                <c:if test="${dogFilterItem.key.equalsIgnoreCase('sslp')}">
                                                                    <c:forEach items="${model.dogSslpTypeBkts}" var="sslpType">
                                                                        <li onclick="filterClick('${dogFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                                    </c:forEach>
                                                                </c:if>
                                                            </ul>

                                                        </li>

                                                </c:forEach>


                                            </c:if>
                                            <c:if test="${item.key.equalsIgnoreCase('chinchilla')}">

                                                <c:forEach items="${model.chinchillaFilterBkts}" var="chinchillaFilterItem">
                                                    <li><button style="border:none;background-color: transparent" onclick="filterClick('${chinchillaFilterItem.key}', '${item.key}')"><span style=>${chinchillaFilterItem.key} (${chinchillaFilterItem.docCount})</span></button>

                                                            <ul>
                                                                <c:if test="${chinchillaFilterItem.key.equalsIgnoreCase('gene')}">
                                                                    <c:forEach items="${model.chinchillaGeneTypeBkts}" var="geneType">
                                                                        <li onclick="filterClick('${chinchillaFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                                    </c:forEach>
                                                                </c:if>
                                                                <c:if test="${chinchillaFilterItem.key.equalsIgnoreCase('variant')}">
                                                                    <c:forEach items="${model.chinchillaVariantTypeBkts}" var="variantType">
                                                                        <li onclick="filterClick('${chinchillaFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                                    </c:forEach>
                                                                </c:if>
                                                                <c:if test="${chinchillaFilterItem.key.equalsIgnoreCase('qtl')}">
                                                                    <c:forEach items="${model.chinchillaQtlTypeBkts}" var="qtlType">

                                                                        <li onclick="filterClick('${chinchillaFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>

                                                                    </c:forEach>
                                                                </c:if>
                                                                <c:if test="${chinchillaFilterItem.key.equalsIgnoreCase('sslp')}">
                                                                    <c:forEach items="${model.chinchillaSslpTypeBkts}" var="sslpType">
                                                                        <li onclick="filterClick('${chinchillaFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                                    </c:forEach>
                                                                </c:if>
                                                            </ul>

                                                        </li>

                                                </c:forEach>


                                            </c:if>
                                            <c:if test="${item.key.equalsIgnoreCase('bonobo')}">

                                                <c:forEach items="${model.bonoboFilterBkts}" var="bonoboFilterItem">
                                                   <li><button style="border:none;background-color: transparent" onclick="filterClick('${bonoboFilterItem.key}', '${item.key}')"><span >${bonoboFilterItem.key} (${bonoboFilterItem.docCount})</span></button>
                                                       <ul>
                                                           <c:if test="${bonoboFilterItem.key.equalsIgnoreCase('gene')}">
                                                               <c:forEach items="${model.bonoboGeneTypeBkts}" var="geneType">
                                                                   <li onclick="filterClick('${bonoboFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${bonoboFilterItem.key.equalsIgnoreCase('variant')}">
                                                               <c:forEach items="${model.bonoboVariantTypeBkts}" var="variantType">
                                                                   <li onclick="filterClick('${bonoboFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${bonoboFilterItem.key.equalsIgnoreCase('qtl')}">
                                                               <c:forEach items="${model.bonoboQtlTypeBkts}" var="qtlType">
                                                                   <li onclick="filterClick('${bonoboFilterItem.key}', '${item.key}','', '${qtlType.key}','trait')">${qtlType.key} (${qtlType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${bonoboFilterItem.key.equalsIgnoreCase('sslp')}">
                                                               <c:forEach items="${model.bonoboSslpTypeBkts}" var="sslpType">
                                                                   <li onclick="filterClick('${bonoboFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                       </ul>

                                                   </li>
                                                </c:forEach>


                                            </c:if>
                                            <c:if test="${item.key.equalsIgnoreCase('squirrel')}">

                                                <c:forEach items="${model.squirrelFilterBkts}" var="squirrelFilterItem">
                                                   <li><button style="border:none;background-color: transparent" onclick="filterClick('${squirrelFilterItem.key}', '${item.key}')"><span>${squirrelFilterItem.key} (${squirrelFilterItem.docCount})</span></button>

                                                       <ul>
                                                           <c:if test="${squirrelFilterItem.key.equalsIgnoreCase('gene')}">
                                                               <c:forEach items="${model.squirrelGeneTypeBkts}" var="geneType">
                                                                   <li onclick="filterClick('${squirrelFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${squirrelFilterItem.key.equalsIgnoreCase('variant')}">
                                                               <c:forEach items="${model.squirrelVariantTypeBkts}" var="variantType">
                                                                   <li onclick="filterClick('${squirrelFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${squirrelFilterItem.key.equalsIgnoreCase('qtl')}">
                                                               <c:forEach items="${model.squirrelQtlTypeBkts}" var="qtlType">

                                                                   <li onclick="filterClick('${squirrelFilterItem.key}', '${item.key}','', '${qtlType.key}'),'trait'">${qtlType.key} (${qtlType.docCount})</li>

                                                               </c:forEach>
                                                           </c:if>
                                                           <c:if test="${squirrelFilterItem.key.equalsIgnoreCase('sslp')}">
                                                               <c:forEach items="${model.squirrelSslpTypeBkts}" var="sslpType">
                                                                   <li onclick="filterClick('${squirrelFilterItem.key}', '${item.key}','', '${sslpType.key}')">${sslpType.key} (${sslpType.docCount})</li>
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

                     <c:forEach items="${model.categoryBkts}" var="item">
                <c:if test="${item.key.equalsIgnoreCase('reference')}">
                        <li style="border:none;background-color: transparent;cursor: pointer" onclick="filterClick('${item.key}', '')">${item.key}(${item.docCount})</li>
                </c:if>
            </c:forEach>

             <c:if test="${fn:length(model.ontologyBkts)>0}">

                 <c:forEach items="${model.categoryBkts}" var="item">
                 <c:if test="${item.key.equalsIgnoreCase('ontology')}">
                     <li><span style="font-weight: bold">Ontology Terms: (${item.docCount})</span>
              <ul>
                   <c:forEach items="${model.ontologyBkts}" var="ontItem">
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
         </ul>

       </div>


</div>