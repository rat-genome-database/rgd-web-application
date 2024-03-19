<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="edu.mcw.rgd.dao.impl.AssociationDAO" %>
<% if (!isNew) {

    List<Gene> genes = associationDAO.getGeneAssociationsBySslp(key);
%>

<form action="updateSslp2GeneAssociations.html" >
<input type="hidden" name="sslpRgdId" value="<%=rgdId%>"/>
<input type="hidden" name="sslpKey" value="<%=key%>"/>
<table id="sslp2geneAssocTable" border="1" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td colspan="2" style="background-color:#2865a3;color:white; font-weight: 700;">Gene Associations</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest2(this.form,'sslp2geneAssocMsg')"/></td>
    </tr>
    <tr>
        <td colspan="2" id="sslp2geneAssocMsg"></td>
        <td colspan="2" align="right"><a href="javascript:addSslp2GeneAssoc(); void(0);" style="font-weight:700; color: green;">Add Gene</a></td>
    </tr>

    <tr>
        <td class="label">Gene Symbol</td>
        <td colspan="2" class="label">Gene Rgd Id</td>
    </tr>

    <%
        int sslp2geneAssocCount=1;
        for (Gene gene: genes) {
            if (rgdId != displayRgdId) {
                gene.setKey(0);
            }
    %>
<tr id="sslp2geneAssocRow<%=sslp2geneAssocCount%>">
    <td id="geneSymbol<%=sslp2geneAssocCount%>"><%=gene.getSymbol()%></td>
    <td><input type="text" size="12" id="geneRgdId<%=sslp2geneAssocCount%>" value="<%=gene.getRgdId()%>" name="gene_rgd_id" readonly/>
        <a href="javascript:sslp2geneAssoc_lookup_prerender('geneRgdId<%=sslp2geneAssocCount%>',<%=speciesTypeKey%>,'GENES')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>
    </td>
    <td align="right">
        <a style="color:red; font-weight:700;"
                         href="javascript:removeSslp2GeneAssoc('sslp2geneAssocRow<%=sslp2geneAssocCount%>') ;void(0);"><img
            src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
</tr>
<%
        sslp2geneAssocCount++;
    }
    %>
    </tbody>
</table>
</form>

<% } %>

<script>
  function sslp2geneAssoc_lookup_prerender(oid, specieskey, objecttype) {

      lookup_callbackfn = sslp2geneAssoc_lookup_postrender;
      lookup_render(oid, specieskey, objecttype);
  }
  function sslp2geneAssoc_lookup_postrender(oid, varRgdId) {
      var oid2 = oid.replace('geneRgdId','geneSymbol');
      var url = '/rgdweb/curation/edit/editGene.html?act=symbol&rgdId='+varRgdId;
      loadDiv(url, oid2);
  }

  function removeSslp2GeneAssoc(rowId) {
    var d = document.getElementById(rowId);
    d.parentNode.removeChild(d);
  }

  var sslp2geneAssocCreatedCount = 1;
  function addSslp2GeneAssoc() {

        var tbody = document.getElementById("sslp2geneAssocTable").getElementsByTagName("TBODY")[0];

        var row = document.createElement("TR");
        row.id = "createdSslp2GeneAssocRow" + sslp2geneAssocCreatedCount;

        var td = document.createElement("TD");
        td.id = "geneSymbolCreated"+sslp2geneAssocCreatedCount;
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="12" id="geneRgdIdCreated'+sslp2geneAssocCreatedCount+'" name="gene_rgd_id" value="0" readonly> ';
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:sslp2geneAssoc_lookup_prerender('geneRgdIdCreated" + sslp2geneAssocCreatedCount + "',<%=speciesTypeKey%>,'GENES') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/glass.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        td = document.createElement("TD");
        td.align = "right";
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:removeSslp2GeneAssoc('createdSslp2GeneAssocRow" + sslp2geneAssocCreatedCount + "') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        tbody.appendChild(row);

        sslp2geneAssocCreatedCount++;
        enableAllOnChangeEvents();
    }
</script>