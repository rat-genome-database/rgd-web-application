<% if (!isNew) {
    AssociationDAO aDao = new AssociationDAO();
    List<Strain2MarkerAssociation> variantAssocList = aDao.getStrain2VariantAssociations(displayRgdId);
%>

<form action="updateStrainAssociations.html" >
<input type="hidden" name="rgdId" value="<%=rgdId%>">
<input type="hidden" name="markerClass" value="strain2var">
<table id="varAssocTable" border="1" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td colspan="4" style="background-color:#2865a3;color:white; font-weight: 700;">Associations - Variant Markers</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
    </tr>
    <tr>
        <td colspan="5" align="right"><a href="javascript:addvarAssoc(); void(0);" style="font-weight:700; color: green;">Add Variant Marker</a></td>
    </tr>

    <tr>
        <td class="label">Variant rs ID</td>
        <td class="label">Variant RgdId</td>
        <td class="label">Marker Type</td>
        <td colspan="2" class="label">Region Name</td>
    </tr>

    <%
        int varAssocCnt=1;
        for (Strain2MarkerAssociation varAssoc: variantAssocList) {
            String markerType = Utils.NVL(varAssoc.getMarkerType(), "allele");
    %>
<tr id="varAssocRow<%=varAssocCnt%>">
    <td id="varSymbol<%=varAssocCnt%>"><%=varAssoc.getMarkerSymbol()%></td>
    <td><input type="text" size="12" id="varRgdId<%=varAssocCnt%>" value="<%=varAssoc.getMarkerRgdId()%>" name="varRgdId">
        <a href="javascript:varassoc_lookup_prerender('varRgdId<%=varAssocCnt%>','<%=strain.getSpeciesTypeKey()%>','varS')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>
    </td>
    <td>
        <select id="varMarkerType<%=varAssocCnt%>" name="varMarkerType">
            <option <%=markerType.equals("flank 1")?"selected":""%>>flank 1</option>
            <option <%=markerType.equals("flank 2")?"selected":""%>>flank 2</option>
            <option <%=markerType.equals("allele")?"selected":""%>>allele</option>
        </select>
    </td>
    <td><input type="text" size="20" id="varRegionName<%=varAssocCnt%>" name="varRegionName" value="<%=varAssoc.getRegionName()%>" />
    </td>
    <td align="right">
        <a style="color:red; font-weight:700;"
                         href="javascript:removevarAssoc('varAssocRow<%=varAssocCnt%>') ;void(0);"><img
            src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
</tr>
<%
        varAssocCnt++;
    }
    %>
    </tbody>
</table>
</form>

<% } %>

<script>
  function varassoc_lookup_prerender(oid, specieskey, objecttype) {

      lookup_callbackfn = varassoc_lookup_postrender;
      lookup_render(oid, specieskey, objecttype);
  }
  function varassoc_lookup_postrender(oid, varRgdId) {
      // oid: replace 'varRgdId' with 'strainSymbol'
      var oid2 = oid.replace('varRgdId','varSymbol');
      var url = '/rgdweb/curation/edit/editStrain.html?act=name&rgdId='+varRgdId;
      loadDiv(url, oid2);
  }

  function removevarAssoc(rowId) {
    var d = document.getElementById(rowId);
    d.parentNode.removeChild(d);
  }

    var varAssocCreatedCount = 1;
    function addvarAssoc() {

        var tbody = document.getElementById("varAssocTable").getElementsByTagName("TBODY")[0];

        var row = document.createElement("TR");
        row.id = "createdvarAssocRow" + varAssocCreatedCount;

        var td = document.createElement("TD");
        td.id = "varSymbolCreated"+varAssocCreatedCount;
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="12" id="varRgdIdCreated'+varAssocCreatedCount+'" name="varRgdId" value="0"> ';
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:varassoc_lookup_prerender('varRgdIdCreated" + varAssocCreatedCount + "',<%=strain.getSpeciesTypeKey()%>,'varS') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/glass.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<select id="varMarkerType'+varAssocCreatedCount+'" name="varMarkerType"><option selected>flank 1</option><option>flank 2</option><option>allele</option></select>';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="20" id="varRegionName'+varAssocCreatedCount+'" name="varRegionName" value="1"> ';
        row.appendChild(td);

        td = document.createElement("TD");
        td.align="right";
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:removevarAssoc('createdvarAssocRow" + varAssocCreatedCount + "') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        tbody.appendChild(row);

        varAssocCreatedCount++;
        enableAllOnChangeEvents();
    }
</script>