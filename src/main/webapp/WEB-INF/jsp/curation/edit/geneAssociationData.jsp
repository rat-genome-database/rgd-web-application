<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.ArrayList" %>
<% if (!isNew) {

    StrainDAO strainDAO = new StrainDAO();
    List<Strain> strains = strainDAO.getAssociatedStrains(displayRgdId);
%>

<form action="updateGeneAssociations.html" >
<input type="hidden" name="rgdId" value="<%=rgdId%>"/>
<table id="strainAssocTable" border="1" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td colspan="2" style="background-color:#2865a3;color:white; font-weight: 700;">Strain Associations</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
    </tr>
    <tr>
        <td colspan="3" align="right"><a href="javascript:addStrainAssoc(); void(0);" style="font-weight:700; color: green;">Add Strain</a></td>
    </tr>

    <tr>
        <td class="label">Strain Symbol</td>
        <td colspan="2" class="label">Strain Rgd Id</td>
    </tr>

    <%
        int strainAssocCount=1;
        for (Strain strain : strains) {
            if (rgdId != displayRgdId) {
                strain.setKey(0);
            }
    %>
<tr id="strainAssocRow<%=strainAssocCount%>">
    <input type="hidden" name="strainRgdId" value="<%=strain.getRgdId()%>"/>
    <td id="strainSymbol<%=strainAssocCount%>"><%=strain.getSymbol()%></td>
    <td><input type="text" size="12" id="strainRgdId<%=strainAssocCount%>" value="<%=strain.getRgdId()%>" readonly/>
        <a href="javascript:strainassoc_lookup_prerender('strainRgdId<%=strainAssocCount%>',<%=strain.getSpeciesTypeKey()%>,'STRAINS')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>
    </td>
    <td align="right">
        <a style="color:red; font-weight:700;"
                         href="javascript:removeStrainAssoc('strainAssocRow<%=strainAssocCount%>') ;void(0);"><img
            src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
</tr>
<%
        strainAssocCount++;
    }
    %>
    </tbody>
</table>
</form>

<% } %>

<script>
  function strainassoc_lookup_prerender(oid, specieskey, objecttype) {

      lookup_callbackfn = strainassoc_lookup_postrender;
      lookup_render(oid, specieskey, objecttype);
  }
  function strainassoc_lookup_postrender(oid, varRgdId) {
      // oid: replace 'strainRgdId' with 'strainSymbol'
      var oid2 = oid.replace('strainRgdId','strainSymbol');
      var url = '/rgdweb/curation/edit/editGene.html?act=symbol&rgdId='+varRgdId;
      loadDiv(url, oid2);
  }

  function removeStrainAssoc(rowId) {
    var d = document.getElementById(rowId);
    d.parentNode.removeChild(d);
  }

    var strainAssocCreatedCount = 1;
    function addStrainAssoc() {

        var tbody = document.getElementById("strainAssocTable").getElementsByTagName("TBODY")[0];

        var row = document.createElement("TR");
        row.id = "createdStrainAssocRow" + strainAssocCreatedCount;

        var td = document.createElement("TD");
        td.id = "strainSymbolCreated"+strainAssocCreatedCount;
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="12" id="strainRgdIdCreated'+strainAssocCreatedCount+'" name="strainRgdId" value="0"> ';
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:strainassoc_lookup_prerender('strainRgdIdCreated" + strainAssocCreatedCount + "',3,'STRAINS') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/glass.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        td = document.createElement("TD");
        td.align = "right";
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:removeStrainAssoc('createdStrainAssocRow" + strainAssocCreatedCount + "') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        tbody.appendChild(row);

        strainAssocCreatedCount++;
        enableAllOnChangeEvents();
    }
</script>