<%--
  Created by IntelliJ IDEA.
  User: jthota
  Date: 1/15/2024
  Time: 10:07 AM
  To change this template use File | Settings | File Templates.
--%>
<c:forEach items="${model.aggregations.species}" var="item">
    <c:if test="${item.key.equalsIgnoreCase('rat')}">
        <button style="border:none;background-color: transparent" onclick="filterClick('${model.searchBean.category}', '${item.key}','', '')"><span style="font-weight: bold;color:#24609c">${item.key} ( ${item.docCount})</span></button>
        <ul>
            <c:forEach items="${model.aggregations.rat}" var="ratFilterItem">

            <li> <button style="border:none;background-color: transparent" onclick="filterClick('${ratFilterItem.key}', '${item.key}','','')"><span>${ratFilterItem.key} (${ratFilterItem.docCount})</span></button>

                <ul>
                    <c:if test="${ratFilterItem.key.equalsIgnoreCase('gene')}">
                        <c:forEach items="${model.aggregations.ratGene}" var="geneType">
                            <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${geneType.key}')">${geneType.key} (${geneType.docCount})</li>
                        </c:forEach>
                    </c:if>
                    <c:if test="${ratFilterItem.key.equalsIgnoreCase('variant')}">
                    <li><span>Type</span>
                        <ul>
                            <c:forEach items="${model.aggregations.ratVariant}" var="variantType">
                                <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${variantType.key}')">${variantType.key} (${variantType.docCount})</li>
                            </c:forEach>
                        </ul>
                    </li>
                        <li><span>Polyphen</span>
                        <ul>
                            <c:forEach items="${model.aggregations.ratPolyphen}" var="polyphen">
                                <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${polyphen.key}','polyphenStatus')">${polyphen.key} (${polyphen.docCount})</li>
                            </c:forEach>
                        </ul>
                        </li>
                        <li><span>Sample</span>
                            <ul>
                                <c:forEach items="${model.aggregations.ratSample}" var="sample">
                                    <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${sample.key}','analysisName')">${sample.key} (${sample.docCount})</li>
                                </c:forEach>
                            </ul>
                        </li>
                        <li><span>Region</span>
                            <ul>
                                <c:forEach items="${model.aggregations.ratRegion}" var="region">
                                    <li onclick="filterClick('${ratFilterItem.key}', '${item.key}','', '${region.key}','regionName')">${region.key} (${region.docCount})</li>
                                </c:forEach>
                            </ul>
                        </li>
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

    </ul>
    </c:if>
</c:forEach>
