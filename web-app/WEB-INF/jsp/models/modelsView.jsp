<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<div class="rgd-panel rgd-panel-default">
    <div class="rgd-panel-heading">Rat Genetic Models</div>
</div>

<div id="modelsViewContent" >
    <div style="margin-bottom:10px;width:50%;float:left">
        <input type="text" class="search searchBox rounded" name="geneSearch" data-filter-column="1" placeholder="Search by Gene Symbol..." style="width:60%;border-color:lightgrey">
        <button type="button" class="btn btn-primary reset" title="Reset table">Reset</button> <!-- targeted by the "filter_reset" option -->
    </div>
    <div id="pager" class="pager" style="float:right;margin-bottom:2px;">
        <form>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
            <input type="text" class="pagedisplay"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>
            <select class="pagesize">
                <option   value="10">10</option>
                <option value="20">20</option>
                <option value="30">30</option>
                <option  value="40">40</option>
                <option   value="100">100</option>
                <option selected="selected" value="9999">All Rows</option>
            </select>
        </form>
    </div>

</div>

<div id="modelsView" >


    <table id="modelTable" cellspacing="1" class="tablesorter" style="table-layout: fixed;">
        <!--caption style="font-weight:bold;font-size:20px;color:#24609c">Genetic Models Data</caption-->
        <thead>

        <tr>
            <th style="width:5%;cursor:pointer" class="filter-false expandCollapseAll"><i  class="fa fa-plus-circle expandAll" aria-hidden="true" style="color:green;font-size: 20px" title="Click to expand all"></i></th>
            <th  class="tablesorter-header" data-placeholder="" style=" cursor: pointer; width:6%;text-align:left" title="Click to Sort">Gene Symbol</th>
            <th class="tablesorter-header filter-false" style=" cursor: pointer;text-align:left "title="Click to Sort">Gene</th>
            <th  class="tablesorter-header filter-false" style=" cursor: pointer; width:5.5%" title="Click to Sort">No. of Models</th>
            <th class="tablesorter-header filter-false" style=" cursor: pointer; "title="Click to Sort">Background Strain</th>
            <th class="tablesorter-header" style=" cursor: pointer;" title="Click to Sort">Strain Symbol</th>
            <th class="tablesorter-header filter-false" style=" cursor: pointer;"title="Click to Sort">Aliases</th>
            <th class="tablesorter-header filter-false" style=" cursor: pointer;"title="Click to Sort">Method</th>
            <th class="tablesorter-header filter-false" style=" cursor: pointer;" title="Click to Sort">Availability</th>
            <th class="tablesorter-header filter-false"  >Origination</th>
            <th class="tablesorter-header filter-false" >Phenotype Data</th>
            <th class="tablesorter-header filter-false">Publications</th>
            <th class="filter-false">Ask about this Model!</th>

        </tr>

        </thead>
        <tbody style="text-align: center;vertical-align:center">
        <c:set var="strains" value="${m:sortByGeneSymbol(model.strains)}"/>

        <c:forEach items="${model.headerChildMap}" var="entry">
            <c:set var="headerRec" value="true"/>
            <!-- Key:<!--c:out value="$--{entry.key}"/-->
            <c:choose>
                <c:when test="${fn:length(entry.value)>1 }">
                    <c:forEach items="${strains}" var="strain">
                        <c:if test="${entry.key.geneSymbol==strain.geneSymbol }">
                            <c:choose>
                                <c:when test="${headerRec=='true'}">
                                    <tr class="header1" style="display:table-row;">
                                        <td class="toggle" style="cursor:pointer;text-align:center;"><i  class="fa fa-plus-circle expand" aria-hidden="true" style="color:green;font-size: 20px" title="Click to expand"></i></td>
                                        <td style="" class="geneSymbol"><a href="/rgdweb/report/gene/main.html?id=${strain.geneRgdId}"target="_blank" title="Gene Symbol">${entry.key.geneSymbol}</a></td>
                                        <td title="Gene" style="">${entry.key.gene}</td>
                                        <td  style="text-align: center;font-weight:bold;" title="No. of Models">${fn:length(entry.value)}</td>
                                        <!--td><span style="color:blue">Click Expand Button</span></td-->
                                        <td style="" title="Click Epand/Collapse Button"></td>
                                        <td style="" title="Click Epand/Collapse Button"></td>
                                        <td style="" title="Click Epand/Collapse Button"></td>
                                        <td style="" title="Click Epand/Collapse Button"></td>
                                        <td style="" title="Click Epand/Collapse Button"></td>
                                        <td style="" title="Click Epand/Collapse Button"></td>
                                        <td style="" title="Click Epand/Collapse Button"></td>
                                        <td style="" title="Click Epand/Collapse Button"></td>
                                        <td style="" title="Click Epand/Collapse Button"></td>
                                    </tr>
                                    <tr id="childRecord" class="tablesorter-childRow" style="display:none">
                                        <td style="display:table-cell" ></td>
                                        <td style="display:table-cell" ></td>
                                        <td style="display:table-cell"> </td>
                                        <td style="display:table-cell" ></td>
                                        <td style="display:table-cell" >${strain.backgroundStrain}</td>
                                        <td style="display:table-cell;line-height: 26pt" ><a href="/rgdweb/report/strain/main.html?id=${strain.strainRgdId}"target="_blank"  title="Strain Symbol">${strain.strainSymbol}</a></td>
                                        <td style="width:40px;display:table-cell" title="Alias">
                                            <c:set var="first" value="true"/>
                                            <c:forEach items="${strain.aliases}" var="alias">
                                                <c:choose>
                                                    <c:when test="${first=='true'}">
                                                        ${alias}
                                                        <c:set var="first" value="false"/>
                                                    </c:when>
                                                    <c:otherwise>;<br>${alias}
                                                    </c:otherwise>
                                                </c:choose>

                                            </c:forEach>
                                        </td>
                                        <td style="display:table-cell" >${strain.method}</td>
                                        <td style="display:table-cell" title="Availability">${strain.availability}</td>

                                        <td class="source" style="display:table-cell" title="Source">${strain.source}</td>
                                        <c:choose>
                                            <c:when test="${strain.experimentRecordCount gt 0}">
                                                <td style="display:table-cell" ><a href="${strain.phenominerUrl}" target="_blank" style="color:white" title="Phenominer Link"><img src="/rgdweb/common/images/phenominer_icon.png" alt="Phenominer Link" style="width:25px; height: 25px"/></a></td>
                                            </c:when>
                                            <c:otherwise>
                                                <td></td>
                                            </c:otherwise>
                                        </c:choose>
                                        <td style="display:table-cell" >
                                            <c:if test="${fn:length(strain.references)>0}">
                                                <a href="javascript:void(0)" onclick="myModal('${strain.strainRgdId}')" title="Publications" ><img src="/rgdweb/common/images/nav/Publications.png" alt="Publications" title="Publications"style="width:20px;height:20px"></a>
                                            </c:if>
                                        </td>
                                        <c:choose>
                                            <c:when test="${strain.source.contains('physgen') || strain.source.contains('gerrc')|| strain.source.contains('PhysGen')}">
                                        <td style="text-align: center;display:table-cell" title="mcwcustomrats@mcw.edu"><a href="mailto:mcwcustomrats@mcw.edu?subject=${strain.strainSymbol}" ><i class="fa fa-envelope" aria-hidden="true"  style="color:steelblue"></i></a></td>
                                            </c:when>
                                            <c:otherwise>
                                                <td></td>
                                            </c:otherwise>

                                        </c:choose>


                                    </tr>
                                    <c:set var="headerRec" value="false"/>
                                </c:when>
                                <c:otherwise>
                                    <tr id="childRecord" class="tablesorter-childRow" style="display:none">
                                        <td style="display:table-cell"></td>
                                        <td style="display:table-cell" ></td>
                                        <td style="display:table-cell"></td>
                                        <td style="display:table-cell"></td>
                                        <td style="display:table-cell">${strain.backgroundStrain}</td>
                                        <td style="display:table-cell;line-height: 26pt" ><a href="/rgdweb/report/strain/main.html?id=${strain.strainRgdId}"target="_blank"  title="Strain Symbol">${strain.strainSymbol}</a></td>
                                        <td style="width:40px;display:table-cell" title="Alias">
                                            <c:set var="first" value="true"/>
                                            <c:forEach items="${strain.aliases}" var="alias">
                                                <c:choose>
                                                    <c:when test="${first=='true'}">
                                                        ${alias}
                                                        <c:set var="first" value="false"/>
                                                    </c:when>
                                                    <c:otherwise>;<br>${alias}
                                                    </c:otherwise>
                                                </c:choose>

                                            </c:forEach>
                                        </td>
                                        <td style="display:table-cell">${strain.method}</td>
                                        <td style="display: table-cell" title="Availability">${strain.availability}</td>

                                        <td class="source" style="display: table-cell;" title="Source">${strain.source}</td>
                                        <c:choose>
                                            <c:when test="${strain.experimentRecordCount gt 0}">
                                                <td style="display:table-cell"><a href="${strain.phenominerUrl}" target="_blank"  title="Phenominer Link"><img src="/rgdweb/common/images/phenominer_icon.png" alt="Phenominer Link" style="width:25px; height: 25px"/></a></td>
                                            </c:when>
                                            <c:otherwise>
                                                <td></td>
                                            </c:otherwise>
                                        </c:choose>

                                        <td style="display:table-cell" >
                                            <c:if test="${fn:length(strain.references)>0}">

                                                <a href="javascript:void(0)" onclick="myModal('${strain.strainRgdId}')" title="Publications"><img src="/rgdweb/common/images/nav/Publications.png" alt="Publications" title="Publications"style="width:20px;height:20px"></a>
                                            </c:if>
                                        </td>

                                        <c:choose>
                                            <c:when test="${strain.source.contains('physgen') || strain.source.contains('gerrc')|| strain.source.contains('PhysGen')}">
                                                <td style="text-align: center;display:table-cell" title="mcwcustomrats@mcw.edu"><a href="mailto:mcwcustomrats@mcw.edu?subject=${strain.strainSymbol}" ><i class="fa fa-envelope" aria-hidden="true"  style="color:steelblue"></i></a></td>
                                            </c:when>
                                            <c:otherwise>
                                                <td></td>
                                            </c:otherwise>
                                        </c:choose>

                                    </tr>

                                </c:otherwise>
                            </c:choose>

                        </c:if>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <c:forEach items="${strains}" var="strain">
                        <c:if test="${entry.key.geneSymbol==strain.geneSymbol}">
                            <tr class="header1" style="display:table-row;">
                                <td></td>
                                <td  class="geneSymbol"><a href="/rgdweb/report/gene/main.html?id=${strain.geneRgdId}"target="_blank" title="Gene Symbol">${entry.key.geneSymbol}</a></td>
                                <td title="Gene">${entry.key.gene}</td>
                                <td style="text-align:center;" title="No. of Models">${fn:length(entry.value)}</td>
                                <td>${strain.backgroundStrain}</td>
                                <td style="line-height: 26pt"><a href="/rgdweb/report/strain/main.html?id=${strain.strainRgdId}"target="_blank" title="Strain Symbol">${strain.strainSymbol}</a></td>
                                <td title="Alias">
                                    <c:set var="first" value="true"/>
                                    <c:forEach items="${strain.aliases}" var="alias">
                                        <c:choose>
                                            <c:when test="${first=='true'}">
                                                ${alias}
                                                <c:set var="first" value="false"/>
                                            </c:when>
                                            <c:otherwise>;<br> ${alias}</c:otherwise>
                                        </c:choose>

                                    </c:forEach>
                                </td>
                                <td>${strain.method}</td>
                                <td title="Availability">${strain.availability}</td>
                                <td title="Source">${strain.source}</td>
                                <c:choose>
                                    <c:when test="${strain.experimentRecordCount gt 0}">
                                        <td><a href="${strain.phenominerUrl}" target="_blank" title="Phenominer Link"><img src="/rgdweb/common/images/phenominer_icon.png" alt="Phenominer Link" style="width:25px; height: 25px"/></a></td>
                                    </c:when>
                                    <c:otherwise>
                                        <td></td>
                                    </c:otherwise>
                                </c:choose>
                                <td  >
                                    <c:if test="${fn:length(strain.references)>0}">
                                        <a href="javascript:void(0)" onclick="myModal('${strain.strainRgdId}')" title="Publications"><img src="/rgdweb/common/images/nav/Publications.png" alt="Publications" title="Publications" style="width:20px;height:20px"></a>
                                    </c:if>
                                </td>
                                <c:choose>
                                    <c:when test="${strain.source.contains('physgen') || strain.source.contains('gerrc')|| strain.source.contains('PhysGen')}">
                                        <td style="text-align: center;display:table-cell" title="mcwcustomrats@mcw.edu"><a href="mailto:mcwcustomrats@mcw.edu?subject=${strain.strainSymbol}" ><i class="fa fa-envelope" aria-hidden="true"  style="color:steelblue"></i></a></td>
                                    </c:when>
                                    <c:otherwise>
                                        <td></td>
                                    </c:otherwise>
                                </c:choose>

                            </tr>
                        </c:if>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </c:forEach>
        </tbody>
    </table>

</div>
<div style="background-color:#24609c;width:75%;margin-left:16%">
    <div id="pager1" class="pager" style="float:right;margin-top:2%">
        <form>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/first.png" class="first"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/prev.png" class="prev"/>
            <input type="text" class="pagedisplay"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/next.png" class="next"/>
            <img src="/rgdweb/common/tablesorter-2.18.4/addons/pager/icons/last.png" class="last"/>

        </form>
    </div>
</div>
