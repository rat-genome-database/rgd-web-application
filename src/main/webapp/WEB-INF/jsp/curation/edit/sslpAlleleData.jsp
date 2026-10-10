<%@ page import="java.util.*" %>
<%
    SslpsAlleleDAO sslpsAlleleDAO = new SslpsAlleleDAO();
    List<SslpsAllele> sslpsAlleles = sslpsAlleleDAO.getSslpsAlleleByKey(key);

    if (!isNew) {
%>

<form action="updateSslpAlleles.html" >
<input type="hidden" name="sslpKey" value="<%=key%>"/>
<table id="sslpAlleleTable" border="1" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td colspan="4" style="background-color:#2865a3;color:white; font-weight: 700;">Sslp Allele</td>
        <td colspan="2" align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest2(this.form,'sslpAlleleMsg')"/></td>
    </tr>
    <tr>
        <td colspan="4" id="sslpAlleleMsg"></td>
        <td colspan="2" align="right"><a href="javascript:addSslpAlleleData(); void(0);" style="font-weight:700; color: green;">Add Sslp Allele Data</a></td>
    </tr>

    <tr>
        <td class="label">Strain Symbol</td>
        <td class="label">Strain Rgd Id</td>
        <td class="label">Size 1</td>
        <td class="label">Size 2</td>
        <td colspan="2" class="label">Allele Notes</td>
    </tr>

    <%
        int sslpAlleleCount=1;
        for (SslpsAllele sslpsAllele: sslpsAlleles) {
            if (rgdId != displayRgdId) {
                sslpsAllele.setKey(0);
            }
    %>
<tr id="sslpAlleleRow<%=sslpAlleleCount%>">
    <td id="strainSymbol<%=sslpAlleleCount%>"><%=sslpsAllele.getStrainSymbol()%></td>
    <td><input type="text" size="10" value="<%=sslpsAllele.getStrainRgdId()%>" name="strain_rgd_id" id="strainRgdId<%=sslpAlleleCount%>"/>
        <a href="javascript:sslpAllele_lookup_prerender('strainRgdId<%=sslpAlleleCount%>',<%=speciesTypeKey%>,'STRAINS')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>    </td>
    <td><input type="text" size="7" value="<%=fu.chkNull(sslpsAllele.getSize1())%>" name="size1" /></td>
    <td><input type="text" size="7" value="<%=sslpsAllele.getSize2()>0 ? sslpsAllele.getSize2() : ""%>" name="size2" /></td>
    <td><input type="text" size="10" value="<%=fu.chkNull(sslpsAllele.getNotes())%>" name="allele_notes" /></td>
    <td align="right">
        <a style="color:red; font-weight:700;"
                         href="javascript:removeSslpAlleleData('sslpAlleleRow<%=sslpAlleleCount%>') ;void(0);"><img
            src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
</tr>
<%
        sslpAlleleCount++;
    }
    %>
    </tbody>
</table>
</form>

<% } %>

<script>
  function sslpAllele_lookup_prerender(oid, specieskey, objecttype) {

      lookup_callbackfn = sslpAllele_lookup_postrender;
      lookup_render(oid, specieskey, objecttype);
  }
  function sslpAllele_lookup_postrender(oid, varRgdId) {
      // oid: replace 'strainRgdId' with 'strainSymbol'
      var oid2 = oid.replace('strainRgdId','strainSymbol');
      var url = '/rgdweb/curation/edit/editStrain.html?act=symbol&rgdId='+varRgdId;
      loadDiv(url, oid2);
  }

  function removeSslpAlleleData(rowId) {
      var d = document.getElementById(rowId);
      d.parentNode.removeChild(d);
    }

      var sslpAlleleCreatedCount = 1;
      function addSslpAlleleData() {

          var tbody = document.getElementById("sslpAlleleTable").getElementsByTagName("TBODY")[0];

          var row = document.createElement("TR");
          row.id = "sslpAlleleRowCreated" + sslpAlleleCreatedCount;

          td = document.createElement("TD");
          td.id = "strainSymbolCreated"+sslpAlleleCreatedCount;
          row.appendChild(td);

          td = document.createElement("TD");
          td.innerHTML = '<input type="text" size="10" name="strain_rgd_id" id="strainRgdIdCreated'+sslpAlleleCreatedCount+'"/>'+
      '<a href="javascript:sslpAllele_lookup_prerender(\'strainRgdIdCreated'+sslpAlleleCreatedCount+'\',<%=speciesTypeKey%>,\'STRAINS\')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>    </td>';
          row.appendChild(td);

          td = document.createElement("TD");
          td.innerHTML = '<input type="text" size="7" name="size1" />';
          row.appendChild(td);

          td = document.createElement("TD");
          td.innerHTML = '<input type="text" size="7" name="size2" />';
          row.appendChild(td);

          td = document.createElement("TD");
          td.innerHTML = '<input type="text" size="10" name="allele_notes" />';
          row.appendChild(td);

          td = document.createElement("TD");
          td.align = "right";
          rLink = document.createElement("A");
          rLink.border="0";
          rLink.href = "javascript:removeSslpAlleleData('sslpAlleleRowCreated" + sslpAlleleCreatedCount + "') ;void(0);";
          rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
          td.appendChild(rLink);
          row.appendChild(td);

          tbody.appendChild(row);

          sslpAlleleCreatedCount++;
          enableAllOnChangeEvents();
      }
</script>
