<%@ page import="edu.mcw.rgd.datamodel.models.SubmittedStrain" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
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
<%
    List<SubmittedStrain> submittedStrains = (List) request.getAttribute("submittedStrains");
%>
<div><span style="color:green"><%=Utils.NVL(msg,"")%></span></div>
<h3 style="color:grey">Submitted & Incomplete Strains (<%=submittedStrains.size()%>)</h3>
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
        <%--            <c:forEach items="${model.submittedStrains}" var="s">--%>
        <% for (SubmittedStrain s : submittedStrains) {%>
        <tr>
            <td id="key"><%=s.getSubmittedStrainKey()%></td>
            <%if (s.getGene() != null && Utils.stringsAreEqualIgnoreCase(s.getGeneSymbol(),s.getGene().getSymbol())) {%>
            <td><%=Utils.NVL(s.getGeneSymbol(),"")%></td>
            <%}
            else {%>
            <td><span style="color:red" title="Gene not in RGD, Click to create"><a href="editSubmittedGeneObject.html?submissionKey=<%=s.getSubmittedStrainKey()%>&geneType=gene" target="_blank" style="color:red;text-decoration: underline"><%=Utils.NVL(s.getGeneSymbol(),"")%></a></span></td>
            <% }
                if (s.getAllele() != null && Utils.stringsAreEqualIgnoreCase(s.getAlleleSymbol(),s.getAllele().getSymbol())) {%>
            <td><%=Utils.NVL(s.getAlleleSymbol(),"")%></td>
            <%}
            else {%>
            <td><span style="color:red" title="Allele not in RGD, click 'create allele' button to create"><%=Utils.NVL(s.getAlleleSymbol(),"")%></span></td>
            <% }
                if (s.getStrain() != null && Utils.stringsAreEqualIgnoreCase(s.getStrainSymbol(),s.getStrain().getSymbol())) {%>
            <td><%=Utils.NVL(s.getStrainSymbol(),"")%></td>
            <%}
            else {%>
            <td style="color:red"><%=Utils.NVL(s.getStrainSymbol(),"")%></td>
            <% } %>


            <td>
                <%if (s.getGene() != null && s.getGeneRgdId()>0 && s.getGeneRgdId()==s.getGene().getRgdId()) {
                    out.print(s.getGeneRgdId());
                } else if (s.getGeneRgdId()>0){ %>
                <span style="color:red"><%=s.getGeneRgdId()%></span>
                <% } %>
            </td>
            <td>
                <%if (s.getAllele() != null && s.getAlleleRgdId()>0 && s.getAlleleRgdId()==s.getAllele().getRgdId()) {
                    out.print(s.getAlleleRgdId());
                } else if (s.getAlleleRgdId()>0){ %>
                <span style="color:red"><%=s.getAlleleRgdId()%></span>
                <% } %>
            </td>
            <td>
                <% if (s.getStrain() != null && s.getStrainRgdId()>0 && s.getStrainRgdId()==s.getStrain().getRgdId()) {
                    out.print(s.getStrainRgdId());
                } else if (s.getStrainRgdId()>0){ %>
                <span style="color:red"><%=s.getStrainRgdId()%></span>
                <% } %>
            </td>
            <td>
                <%if (s.getGene() != null){%>
                <a href="/rgdweb/report/gene/main.html?id=<%=s.getGene().getRgdId()%>"><%=s.getGene().getRgdId()%></a>
                <% } %>
            </td>
            <td>
                <%if (s.getAllele() != null){%>
                <a href="/rgdweb/report/gene/main.html?id=<%=s.getAllele().getRgdId()%>"><%=s.getAllele().getRgdId()%></a>
                <% } %>
            </td>
            <td>
                <%if (s.getStrain() != null) {%>
<%--                <a href="/rgdweb/report/gene/main.html?id=<%=s.getStrain().getRgdId()%>"><%=s.getStrain().getRgdId()%></a>--%>
                <a href="<%=Link.it(s.getStrain().getRgdId())%>"><%=s.getStrain().getRgdId()%></a>
                <%}%>
            </td>

            <td><%=s.getDisplayStatus()%></td>

            <td><%=s.getSource()%></td>
            <td style="width: 10%">
                <form action="editStrains.html?statusUpdate=true&submissionKey=<%=s.getSubmittedStrainKey()%>" method="post">
                    <select class="form-control " class="status" name="status" onchange="this.form.submit()" >
                        <option  value="<%=s.getApprovalStatus()%>" selected ><%=s.getApprovalStatus()%></option>
                        <% if (!s.getApprovalStatus().equals("submitted")){%>
                        <option value="submitted">submitted</option>
                        <% }
                            if (!s.getApprovalStatus().equals("incomplete")){%>
                        <option value="incomplete">incomplete</option>
                        <% }
                            if (!s.getApprovalStatus().equals("complete")){%>
                        <option value="complete">complete</option>
                        <% }
                            if (!s.getApprovalStatus().equals("denied")){%>
                        <option value="denied">denied</option>
                        <% } %>
                    </select>
                </form>
            </td>

            <!--td>$--{s.approvalStatus}</td-->
            <td>
                <!--a href="/rgdweb/curation/edit/editStrain.html?act=submitted&objectType=editStrain.html&submissionKey=${s.submittedStrainKey}&speciesType=Rat&objectStatus=ACTIVE" class="iconStrain submitted" target="_blank"> <i class="fa fa-pencil-square-o" aria-hidden="true" style="color:#24609c;" title="Create Strain" ></i></a-->
                <a href="editStrainButton.html?submissionKey=<%=s.getSubmittedStrainKey()%>" target="_blank"> <i class="fa fa-pencil-square-o" aria-hidden="true" style="color:#24609c;" title="Create Strain" ></i></a>
                &nbsp;&nbsp;<a href="editSubmittedGeneObject.html?submissionKey=<%=s.getSubmittedStrainKey()%>&geneType=allele"  target="_blank" title="Create Allele"><i class="fa fa-pencil-square-o" aria-hidden="true" style="color:orange;" title="Create Allele" ></i></a>
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
        <%--            </c:forEach>--%>
        <% } %>
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