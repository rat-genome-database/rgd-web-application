<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions"  prefix="fn" %>
<%@ taglib prefix="m" uri="/WEB-INF/tld/geneticModel.tld" %>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.4.0/css/font-awesome.min.css">
<script src="/rgdweb/jquery/jquery-1.12.4.min.js"></script>
<script src="/rgdweb/js/lookup.js"></script>
<script src="/rgdweb/js/windowfiles/dhtmlwindow.js"></script>


<div id="div1"></div>
<div><span style="color:green">${model.msg}</span></div>
<h3 style="color:grey">SUBMITTED & INCOMPLETE STRAINS</h3>
<div style="background:#24609c;width:100%">
   <p style="color:white"> Submitted Strains Count=${fn:length(model.submittedStrains)}</p>
</div>
<div>

        <table class="table table-striped" >
            <thead>
            <tr>
                <th style="font-size:small;">Key</th>
                <th style="font-size:small;">Gene Symbol</th>
                <th style="font-size:small;">Allele Symbol</th>
                <th style="font-size:small;">Strain Symbol</th>
                <th style="font-size:small">Display Status</th>
                <th style="font-size:small;width:15%">Origination</th>
                <th style="font-size:small">Status</th>
                <th style="font-size:small;">Action</th>
            </tr>
            </thead>
            <tbody>
            <!--c:set var="sortedStrains" value="$--{m:sortByGeneSymbol(model.submittedStrains)}"/-->
            <c:forEach items="${model.submittedStrains}" var="s">
            <tr>
                <td id="key">${s.submittedStrainKey}</td>
                <c:choose>
                    <c:when test="${s.geneRgdId!=0}">
                        <td><a href="/rgdweb/report/gene/main.html?id=${s.geneRgdId}" title="RGD Gene Report" target="_blank">${s.geneSymbol}</a></td>
                    </c:when>
                    <c:otherwise>
                        <td><span style="color:red" title="Gene not in RGD, Click to create"><a href="editSubmittedGeneObject.html?submissionKey=${s.submittedStrainKey}&geneType=gene" target="_blank" style="color:red;text-decoration: underline"><c:out value="${s.geneSymbol}"/></a></span></td>
                    </c:otherwise>
                </c:choose>
                <c:choose>
                    <c:when test="${s.alleleRgdId!=0}">
                        <td><a href="/rgdweb/report/gene/main.html?id=${s.alleleRgdId}" title="RGD Allele Report" target="_blank">${s.alleleSymbol}</a></td>
                    </c:when>
                    <c:otherwise>
                        <td><span style="color:red" title="Allele not in RGD, click 'create allele' button to create">${s.alleleSymbol}</span></td>
                        <!--td><input type="text" id="allelergdid"> <a href="javascript:geneassoc_lookup_prerender('allelergdid',3 ,'GENES')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a> </td-->
                    </c:otherwise>
                </c:choose>
                    <!--td>$--{s.alleleSymbol}</td-->
                <c:choose>
                    <c:when test="${s.strainRgdId>0}">
                        <td><a href="/rgdweb/report/strain/main.html?id=${s.strainRgdId}" target="_blank">${s.strainSymbol}</a></td>
                    </c:when>
                    <c:otherwise>
                        <td>${s.strainSymbol}</td>
                    </c:otherwise>
                </c:choose>


                <td>${s.displayStatus}</td>

                    <td>${s.source}</td>
                <td>
                <form action="editStrains.html?statusUpdate=true&submissionKey=${s.submittedStrainKey}" method="post">
                <select class="form-control" class="status" name="status" onchange="this.form.submit()" >
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