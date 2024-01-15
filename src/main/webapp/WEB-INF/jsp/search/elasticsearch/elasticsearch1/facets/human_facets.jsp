<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 1/15/2024
  Time: 10:08 AM
  To change this template use File | Settings | File Templates.
--%>
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
                        <ul>
                            <li>
                                <button style="border:none;background-color: transparent" onclick="filterClick('${ratFilterItem.key}', '${item.key}','','')"><span>Type</span></button>
                                <ul>
                                    <c:forEach items="${model.aggregations.ratVariant}" var="variantType">
                                        <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                                    </c:forEach>
                                </ul>
                            </li>
                            <li>
                                <button style="border:none;background-color: transparent" onclick="filterClick('${ratFilterItem.key}', '${item.key}','','')"><span>Polyphen</span></button>
                                <ul>
                                    <c:forEach items="${model.aggregations.ratPolyphen}" var="polyphen">
                                        <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${polyphen.key}','polyphenStatus')">${polyphen.key} (${polyphen.docCount})</li>
                                    </c:forEach>
                                </ul>
                            </li>
                            <li>
                                <button style="border:none;background-color: transparent" onclick="filterClick('${ratFilterItem.key}', '${item.key}','','')"><span>Sample</span></button>
                                <ul>
                                    <c:forEach items="${model.aggregations.ratSample}" var="sample">
                                        <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${sample.key}','analysisName')">${sample.key} (${sample.docCount})</li>
                                    </c:forEach>
                                </ul>
                            </li>
                            <li>
                                <button style="border:none;background-color: transparent" onclick="filterClick('${ratFilterItem.key}', '${item.key}','','')"><span>Region</span></button>
                                <ul>
                                    <c:forEach items="${model.aggregations.ratRegion}" var="region">
                                        <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${region.key}','regionName')">${region.key} (${region.docCount})</li>
                                    </c:forEach>
                                </ul>
                            </li>




                        </ul>
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
