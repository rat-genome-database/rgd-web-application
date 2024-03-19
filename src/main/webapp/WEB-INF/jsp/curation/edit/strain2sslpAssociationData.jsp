<% if (!isNew) {
    AssociationDAO aDao = new AssociationDAO();
    List<Strain2MarkerAssociation> sslpAssocList = aDao.getStrain2SslpAssociations(displayRgdId);
%>

<form action="updateStrainAssociations.html" >
<input type="hidden" name="rgdId" value="<%=rgdId%>">
<input type="hidden" name="markerClass" value="strain2sslp">
<table id="sslpAssocTable" border="1" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td colspan="4" style="background-color:#2865a3;color:white; font-weight: 700;">Associations - Sslp Markers</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
    </tr>
    <tr>
        <td colspan="5" align="right"><a href="javascript:addSslpAssoc(); void(0);" style="font-weight:700; color: green;">Add Sslp Marker</a></td>
    </tr>

    <tr>
        <td class="label">Sslp Symbol</td>
        <td class="label">Sslp RgdId</td>
        <td class="label">Marker Type</td>
        <td colspan="2" class="label">Region Name</td>
    </tr>

    <%
        int sslpAssocCount=1;
        for (Strain2MarkerAssociation sslpAssoc: sslpAssocList) {
            String markerType = Utils.NVL(sslpAssoc.getMarkerType(), "allele");
    %>
<tr id="sslpAssocRow<%=sslpAssocCount%>">
    <td id="sslpSymbol<%=sslpAssocCount%>"><%=sslpAssoc.getMarkerSymbol()%></td>
    <td><input type="text" size="12" id="sslpRgdId<%=sslpAssocCount%>" value="<%=sslpAssoc.getMarkerRgdId()%>" name="sslpRgdId">
        <a href="javascript:sslpassoc_lookup_prerender('sslpRgdId<%=sslpAssocCount%>',<%=strain.getSpeciesTypeKey()%>,'SSLPS')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>
    </td>
    <td>
        <select id="sslpMarkerType<%=sslpAssocCount%>" name="sslpMarkerType">
            <option <%=markerType.equals("flank 1")?"selected":""%>>flank 1</option>
            <option <%=markerType.equals("flank 2")?"selected":""%>>flank 2</option>
            <option <%=markerType.equals("allele")?"selected":""%>>allele</option>
        </select>
    </td>
    <td><input type="text" size="20" id="sslpRegionName<%=sslpAssocCount%>" name="sslpRegionName" value="<%=sslpAssoc.getRegionName()%>" />
    </td>
    <td align="right">
        <a style="color:red; font-weight:700;"
                         href="javascript:removeSslpAssoc('sslpAssocRow<%=sslpAssocCount%>') ;void(0);"><img
            src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
</tr>
<%
        sslpAssocCount++;
    }
    %>
    </tbody>
</table>
</form>

<% } %>

<script>
  function sslpassoc_lookup_prerender(oid, specieskey, objecttype) {

      lookup_callbackfn = sslpassoc_lookup_postrender;
      lookup_render(oid, specieskey, objecttype);
  }
  function sslpassoc_lookup_postrender(oid, varRgdId) {
      // oid: replace 'sslpRgdId' with 'strainSymbol'
      var oid2 = oid.replace('sslpRgdId','sslpSymbol');
      var url = '/rgdweb/curation/edit/editStrain.html?act=name&rgdId='+varRgdId;
      loadDiv(url, oid2);
  }

  function removeSslpAssoc(rowId) {
    var d = document.getElementById(rowId);
    d.parentNode.removeChild(d);
  }

    var sslpAssocCreatedCount = 1;
    function addSslpAssoc() {

        var tbody = document.getElementById("sslpAssocTable").getElementsByTagName("TBODY")[0];

        var row = document.createElement("TR");
        row.id = "createdSslpAssocRow" + sslpAssocCreatedCount;

        var td = document.createElement("TD");
        td.id = "sslpSymbolCreated"+sslpAssocCreatedCount;
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="12" id="sslpRgdIdCreated'+sslpAssocCreatedCount+'" name="sslpRgdId" value="0"> ';
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:sslpassoc_lookup_prerender('sslpRgdIdCreated" + sslpAssocCreatedCount + "',<%=strain.getSpeciesTypeKey()%>,'SSLPS') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/glass.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<select id="sslpMarkerType'+sslpAssocCreatedCount+'" name="sslpMarkerType"><option selected>flank 1</option><option>flank 2</option><option>allele</option></select>';
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="20" id="sslpRegionName'+sslpAssocCreatedCount+'" name="sslpRegionName" value="1"> ';
        row.appendChild(td);

        td = document.createElement("TD");
        td.align="right";
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:removeSslpAssoc('createdSslpAssocRow" + sslpAssocCreatedCount + "') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        tbody.appendChild(row);

        sslpAssocCreatedCount++;
        enableAllOnChangeEvents();
    }
</script>