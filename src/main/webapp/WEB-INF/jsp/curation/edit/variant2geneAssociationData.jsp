<% if (!isNew) {
    AssociationDAO aDao = new AssociationDAO();
    GeneDAO geneDAO= new GeneDAO();

    List<Association> geneAssocList = new ArrayList<>();


    String msg=new String();
    msg="Click 'Update Button' of 'Assocation-Gene Markers and Alleles' to make association";

    geneAssocList = aDao.getAssociationsForMasterRgdId(displayRgdId);


%>
<p id="msg" style="color:red"><%=msg%></p>
<form action="updateVariantAssociations.html" >
    <input type="hidden" name="rgdId" value="<%=rgdId%>">
    <input type="hidden" name="markerClass" value="variant_to_gene">
    <table id="geneAssocTable" border="1" width="500" class="updateTile" cellspacing="0" >
        <tbody>
        <tr>
            <td colspan="3" style="background-color:#2865a3;color:white; font-weight: 700;">Associations - Gene Markers And Alleles</td>
            <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
        </tr>
        <tr>
            <td colspan="4" align="right"><a href="javascript:addGeneAssoc(); void(0);" style="font-weight:700; color: green;">Add Gene Marker</a></td>
        </tr>

        <tr>
            <td class="label">Gene Symbol</td>
            <td class="label">Gene RgdId</td>
            <td colspan="2" class="label">Marker Type</td>

        </tr>

        <%
            int geneAssocCount=1;
            for (Association geneAssoc: geneAssocList) {
                String markerType = Utils.NVL(geneAssoc.getAssocSubType(), "allele");
        %>
        <tr id="geneAssocRow<%=geneAssocCount%>">
            <td id="geneSymbol<%=geneAssocCount%>"><%=geneDAO.getGene(geneAssoc.getDetailRgdId()).getSymbol()%></td>
            <td><input type="text" size="12" id="geneRgdId<%=geneAssocCount%>" value="<%=geneAssoc.getDetailRgdId()%>" name="geneRgdId">
                <a href="javascript:geneassoc_lookup_prerender('geneRgdId<%=geneAssocCount%>',<%=variant.getSpeciesTypeKey()%>,'GENES')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>
            </td>
            <td>
                <select id="geneMarkerType<%=geneAssocCount%>" name="geneMarkerType">
                    <option <%=markerType.equals("flank 1")?"selected":""%>>flank 1</option>
                    <option <%=markerType.equals("flank 2")?"selected":""%>>flank 2</option>
                    <option <%=markerType.equals("allele")?"selected":""%>>allele</option>
                </select>
            </td>

            <td align="right">
                <a style="color:red; font-weight:700;"
                   href="javascript:removeGeneAssoc('geneAssocRow<%=geneAssocCount%>') ;void(0);"><img
                        src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
        </tr>
        <%
                geneAssocCount++;
            }
        %>
        </tbody>
    </table>
</form>

<% } %>

<script>
    function geneassoc_lookup_prerender(oid, specieskey, objecttype) {

        lookup_callbackfn = geneassoc_lookup_postrender;
        lookup_render(oid, specieskey, objecttype);
    }
    function geneassoc_lookup_postrender(oid, varRgdId) {
        // oid: replace 'geneRgdId' with 'strainSymbol'
        var oid2 = oid.replace('geneRgdId','geneSymbol');
        var url = '/rgdweb/curation/edit/editVariant.html?act=name&rgdId='+varRgdId;
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
        rLink.href = "javascript:geneassoc_lookup_prerender('geneRgdIdCreated" + geneAssocCreatedCount + "',<%=variant.getSpeciesTypeKey()%>,'GENES') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/glass.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<select id="geneMarkerType'+geneAssocCreatedCount+'" name="geneMarkerType"><option selected>flank 1</option><option>flank 2</option><option>allele</option></select>';
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