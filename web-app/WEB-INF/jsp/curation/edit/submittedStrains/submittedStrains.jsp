<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions"  prefix="fn" %>
<%@ taglib prefix="m" uri="/WEB-INF/tld/geneticModel.tld" %>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">
<script src="/rgdweb/js/lookup.js"></script>
<script src="/rgdweb/js/windowfiles/dhtmlwindow.js"></script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.js"> </script>
<script src="/rgdweb/common/tablesorter-2.18.4/js/jquery.tablesorter.widgets.js"></script>


<script src="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.js"></script>
<link href="/rgdweb/common/tablesorter-2.18.4/addons/pager/jquery.tablesorter.pager.css"/>

<link href="/rgdweb/common/tablesorter-2.18.4/css/filter.formatter.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.jui.css" rel="stylesheet" type="text/css"/>
<link href="/rgdweb/common/tablesorter-2.18.4/css/theme.blue.css" rel="stylesheet" type="text/css"/>
<script>
$(function() {
$("#submittedStrains").tablesorter({
theme : 'blue'

});
});
</script>
<div><span style="color:green">${model.msg}</span></div>
<h3 style="color:grey">Submitted & Incomplete Strains (${fn:length(model.submittedStrains)})</h3>
<hr>
<div>

        <table class="tablesorter" id="submittedStrains">
            <thead>
            <tr>
                <th style="font-size:small;">Key</th>
                <th style="font-size:small;">Submitted Gene</th>
                <th style="font-size:small;">Submitted Allele</th>
                <th style="font-size:small;">Submitted Strain</th>
                <th style="font-size:small;">Submitted Gene RgdId</th>
                <th style="font-size:small;">Submitted Allele RgdId</th>
                <th style="font-size:small;">Submitted Strain RgdId</th>
                <th style="font-size:small;">Matched RGD Gene</th>
                <th style="font-size:small;">Matched RGD Allele</th>
                <th style="font-size:small;">Matched RGD Strain </th>

                <th style="font-size:small">Display Status</th>
                <th style="font-size:small;width:15%">Origination</th>
                <th style="font-size:small" class="sorter-false">Status</th>
                <th style="font-size:small;" class="sorter-false">Action</th>
            </tr>
            </thead>
            <tbody>
            <!--c:set var="sortedStrains" value="$--{m:sortByGeneSymbol(model.submittedStrains)}"/-->
            <c:forEach items="${model.submittedStrains}" var="s">
            <tr>
                <td id="key">${s.submittedStrainKey}</td>
                <c:choose>
                    <c:when test="${fn:toLowerCase(s.geneSymbol)==fn:toLowerCase(s.gene.symbol)}">
                        <td>${s.geneSymbol}</td>
                    </c:when>
                    <c:otherwise>
                        <td><span style="color:red" title="Gene not in RGD, Click to create"><a href="editSubmittedGeneObject.html?submissionKey=${s.submittedStrainKey}&geneType=gene" target="_blank" style="color:red;text-decoration: underline"><c:out value="${s.geneSymbol}"/></a></span></td>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${fn:toLowerCase(s.alleleSymbol)==fn:toLowerCase(s.allele.symbol)}">
                        <td>${s.alleleSymbol}</td>
                    </c:when>
                    <c:otherwise>
                        <td><span style="color:red" title="Allele not in RGD, click 'create allele' button to create">${s.alleleSymbol}</span></td>
                        <!--td><input type="text" id="allelergdid"> <a href="javascript:geneassoc_lookup_prerender('allelergdid',3 ,'GENES')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a> </td-->
                    </c:otherwise>
                </c:choose>
                    <!--td>$--{s.alleleSymbol}</td-->
                <c:choose>
                    <c:when test="${fn:toLowerCase(s.strain.name)==fn:toLowerCase(s.strainSymbol)}">
                        <td>${s.strainSymbol}</td>
                    </c:when>
                    <c:otherwise>
                        <td style="color:red">${s.strainSymbol}</td>
                    </c:otherwise>
                </c:choose>

                <td><c:choose>
                    <c:when test="${s.geneRgdId>0 && s.geneRgdId==s.gene.rgdId}">
                        ${s.geneRgdId}
                    </c:when>
                    <c:otherwise>
                        <c:if test="${s.geneRgdId>0}">
                        <span style="color:red">${s.geneRgdId}</span>
                        </c:if>
                    </c:otherwise>
                </c:choose>
                </td>
                <td><c:choose>
                    <c:when test="${s.alleleRgdId>0 && s.alleleRgdId==s.allele.rgdId}">
                        ${s.alleleRgdId}
                    </c:when>
                    <c:otherwise>
                        <c:if test="${s.alleleRgdId>0}">
                            <span style="color:red">${s.alleleRgdId}</span>
                        </c:if>
                    </c:otherwise>
                </c:choose>
                </td>
<td>
                <c:choose>
                    <c:when test="${s.strain.rgdId>0 && s.strain.rgdId==s.strainRgdId}">
                        ${s.strainRgdId}
                    </c:when>
                    <c:otherwise>
                        <c:if test="${s.strainRgdId>0}">
                        <span style="color:red">${s.strainRgdId}</span>
                        </c:if>
                    </c:otherwise>
                </c:choose>
</td>
                <td><a href="/rgdweb/report/gene/main.html?id=${s.gene.rgdId}">${s.gene.symbol}</a></td>
                <td><a href="/rgdweb/report/gene/main.html?id=${s.allele.rgdId}">${s.allele.symbol}</a></td>
                <td><a href="/rgdweb/report/gene/main.html?id=${s.strain.rgdId}">${s.strain.symbol}</a></td>

                <td>${s.displayStatus}</td>

                    <td>${s.source}</td>
                <td style="width: 10%">
                <form action="editStrains.html?statusUpdate=true&submissionKey=${s.submittedStrainKey}" method="post">
                <select class="form-control " class="status" name="status" onchange="this.form.submit()" >
                    <option  value="${s.approvalStatus}" selected >${s.approvalStatus}</option>
                    <c:if test="${s.approvalStatus!='submitted'}">
                        <option value="submitted">submitted</option>
                    </c:if>
                    <c:if test="${s.approvalStatus!='incomplete'}">
                        <option value="incomplete">incomplete</option>
                    </c:if>
                    <c:if test="${s.approvalStatus!='complete'}">
                        <option value="complete">complete</option>
                    </c:if>
                    <c:if test="${s.approvalStatus!='denied'}">
                        <option value="denied">denied</option>
                   </c:if>
               </select>
                    </form>
                    </td>

                <!--td>$--{s.approvalStatus}</td-->
                <td>
                    <!--a href="/rgdweb/curation/edit/editStrain.html?act=submitted&objectType=editStrain.html&submissionKey=${s.submittedStrainKey}&speciesType=Rat&objectStatus=ACTIVE" class="iconStrain submitted" target="_blank"> <i class="fa fa-pencil-square-o" aria-hidden="true" style="color:#24609c;" title="Create Strain" ></i></a-->
                    <a href="editStrainButton.html?submissionKey=${s.submittedStrainKey}" target="_blank"> <i class="fa fa-pencil-square-o" aria-hidden="true" style="color:#24609c;" title="Create Strain" ></i></a>
                    &nbsp;&nbsp;<a href="editSubmittedGeneObject.html?submissionKey=${s.submittedStrainKey}&geneType=allele"  target="_blank" title="Create Allele"><i class="fa fa-pencil-square-o" aria-hidden="true" style="color:orange;" title="Create Allele" ></i></a>
                    &nbsp;&nbsp;<!--a href="editStrains.html?delete=true&submissionKey=$--{s.submittedStrainKey}"><i class="fa fa-trash-o" aria-hidden="true"></i></a-->
                </td>
                    <!--c:choose-->
                        <!--c:when test="$-{s.geneRgdId!=0}">
                            <td>
                                <script>
                                    var submissionKey=$--{s.submittedStrainKey}
                                </script>
                                <a href="/rgdweb/curation/edit/editStrain.html?act=submitted&objectType=editStrain.html&submissionKey=${s.submittedStrainKey}&speciesType=Rat&objectStatus=ACTIVE"" class="iconStrain submitted" target="_blank"> <i class="fa fa-pencil-square-o" aria-hidden="true" style="color:#24609c;" title="Create Strain" ></i></a>
                                &nbsp;&nbsp;&nbsp;&nbsp;<a href="#"><i class="fa fa-trash-o" aria-hidden="true"></i></a>
                            </td>
                        <!--/c:when-->
                        <!--c:otherwise>
                            <td><!--a href="/rgdweb/curation/knockoutStrains/editSubmittedStrain.html?a=none&object=strain&act=new&speciesType=Rat&objectType=editStrain.html&objectStatus=ACTIVE&geneSymbol=${s.geneSymbol}&alleleSymbol=${s.alleleSymbol}&strainSymbol=${s.strainSymbol}"title="Create Strain"-->
                                <!--a href="/rgdweb/curation/edit/editStrain.html?act=submitted&objectType=editStrain.html&submissionKey=${s.submittedStrainKey}&speciesType=Rat&objectStatus=ACTIVE" class="iconStrain" target="_blank"> <i class="fa fa-pencil-square-o" aria-hidden="true" style="color:#24609c;" ></i></a>
                                &nbsp;&nbsp;&nbsp;&nbsp;<!--a href="/rgdweb/curation/edit/editGene.html?act=submitted&objectType=editGene.html&submissionKey=${s.submittedStrainKey}&speciesType=Rat&objectStatus=ACTIVE" class="icon-gene submitted" target="blank"><i class="fa fa-pencil-square-o" aria-hidden="true" style="color:red;" title="Create Gene" ></i></a--><!--&nbsp;&nbsp;&nbsp;&nbsp;<a href="#" class="icon-delete"><i class="fa fa-trash-o" aria-hidden="true"></i></a>
                            <!--/td>

                        <!--/c:otherwise-->

                    <!--/c:choose-->

            </tr>
            </c:forEach>
            </tbody>
        </table>
</div>

<script>
    function geneassoc_lookup_prerender(oid, specieskey, objecttype) {

        lookup_callbackfn = geneassoc_lookup_postrender;
        lookup_render(oid, specieskey, objecttype);
    }
    function geneassoc_lookup_postrender(oid, varRgdId) {
        // oid: replace 'geneRgdId' with 'strainSymbol'
        var oid2 = oid.replace('allelergdid','geneSymbol');
        var url = '/rgdweb/curation/edit/editStrain.html?act=name&rgdId='+varRgdId;
        loadDiv(url, oid2);
    }

    function removeGeneAssoc(rowId) {
        var d = document.getElementById(rowId);
        d.parentNode.removeChild(d);
    }

    var geneAssocCreatedCount = 1;
    function addGeneAssoc() {

        var tbody = document.getElementById("geneAssocTable").getElementsByTagName("TBODY")[0];

        var row = document.createElement("TR");
        row.id = "createdGeneAssocRow" + geneAssocCreatedCount;

        var td = document.createElement("TD");
        td.id = "geneSymbolCreated"+geneAssocCreatedCount;
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="12" id="geneRgdIdCreated'+geneAssocCreatedCount+'" name="geneRgdId" value="0"> ';
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:geneassoc_lookup_prerender('geneRgdIdCreated" + geneAssocCreatedCount + "',3,'GENES') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/glass.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<select id="geneMarkerType'+geneAssocCreatedCount+'" name="geneMarkerType"><option selected>flank 1</option><option>flank 2</option><option>allele</option></select>';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="20" id="geneRegionName'+geneAssocCreatedCount+'" name="geneRegionName" value="1"> ';
        row.appendChild(td);

        td = document.createElement("TD");
        td.align="right";
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:removeGeneAssoc('createdGeneAssocRow" + geneAssocCreatedCount + "') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        tbody.appendChild(row);

        geneAssocCreatedCount++;
        enableAllOnChangeEvents();
    }



</script>