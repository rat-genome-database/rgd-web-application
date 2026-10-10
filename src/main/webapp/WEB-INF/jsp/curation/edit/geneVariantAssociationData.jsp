<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.ArrayList" %>
<% if (!isNew) {

    RgdVariantDAO rdao = new RgdVariantDAO();
    List<RgdVariant> variants = rdao.getVariantsFromGeneRgdId(displayRgdId);
    AssociationDAO dao = new AssociationDAO();
%>

<form action="updateGeneVariantAssociations.html" >
    <input type="hidden" name="rgdId" value="<%=rgdId%>"/>
    <table id="variantAssocTable" border="1" width="600" class="updateTile" cellspacing="0" >
        <tbody>
        <tr>
            <td colspan="2" style="background-color:#2865a3;color:white; font-weight: 700;">Variant Associations</td>
            <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
        </tr>
        <tr>
            <td colspan="3" align="right"><a href="javascript:addVariantAssoc(); void(0);" style="font-weight:700; color: green;">Add Variant</a></td>
        </tr>

        <tr>
            <td class="label">Variant Symbol</td>
            <td colspan="2" class="label">Variant Rgd Id</td>
        </tr>

        <%
            int variantAssocCnt=1;
            for (RgdVariant var : variants) {

        %>
        <tr id="variantAssocRow<%=variantAssocCnt%>">
            <input type="hidden" name="variantRgdId" value="<%=var.getRgdId()%>"/>
            <td id="variantSymbol<%=variantAssocCnt%>"><%=var.getName()%></td>
            <td><input type="text" size="12" id="variantRgdId<%=variantAssocCnt%>" value="<%=var.getRgdId()%>" readonly/>
                <a href="javascript:variantassoc_lookup_prerender('variantRgdId<%=variantAssocCnt%>','<%=var.getSpeciesTypeKey()%>','VARIANTS')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>
            </td>
            <td align="right">
                <a style="color:red; font-weight:700;"
                   href="javascript:removeVariantAssoc('variantAssocRow<%=variantAssocCnt%>') ;void(0);"><img
                        src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
        </tr>
        <%
                variantAssocCnt++;
            }
        %>
        </tbody>
    </table>
</form>

<% } %>

<script>
  function variantassoc_lookup_prerender(oid, specieskey, objecttype) {

      lookup_callbackfn = variantassoc_lookup_postrender;
      lookup_render(oid, specieskey, objecttype);
  }
  function variantassoc_lookup_postrender(oid, varRgdId) {
      // oid: replace 'strainRgdId' with 'strainSymbol'
      var oid2 = oid.replace('variantRgdId','variantSymbol');
      var url = '/rgdweb/curation/edit/editGene.html?act=symbol&rgdId='+varRgdId;
      loadDiv(url, oid2);
  }

  function removeVariantAssoc(rowId) {
      var d = document.getElementById(rowId);
      d.parentNode.removeChild(d);
  }

  var variantAssocCreatedCount = 1;
  function addVariantAssoc() {

      var tbody = document.getElementById("variantAssocTable").getElementsByTagName("TBODY")[0];

      var row = document.createElement("TR");
      row.id = "createdVariantAssocRow" + variantAssocCreatedCount;

      var td = document.createElement("TD");
      td.id = "variantSymbolCreated"+variantAssocCreatedCount;
      row.appendChild(td);

      td = document.createElement("TD");
      td.innerHTML = '<input type="text" size="12" id="variantRgdIdCreated'+variantAssocCreatedCount+'" name="variantRgdId" value="0"> ';
      rLink = document.createElement("A");
      rLink.border="0";
      rLink.href = "javascript:variantassoc_lookup_prerender('variantRgdIdCreated" + variantAssocCreatedCount + "',3,'VARIANTS') ;void(0);";
      rLink.innerHTML = '<img src="/rgdweb/common/images/glass.jpg" border="0"/>';
      td.appendChild(rLink);
      row.appendChild(td);

      td = document.createElement("TD");
      td.align = "right";
      rLink = document.createElement("A");
      rLink.border="0";
      rLink.href = "javascript:removeVariantAssoc('createdVariantAssocRow" + variantAssocCreatedCount + "') ;void(0);";
      rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
      td.appendChild(rLink);
      row.appendChild(td);

      tbody.appendChild(row);

      variantAssocCreatedCount++;
      enableAllOnChangeEvents();
  }
</script>