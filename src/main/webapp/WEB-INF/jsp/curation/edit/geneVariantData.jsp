<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="java.util.ArrayList" %>

<% if (!isNew && gene.isVariant() ) {

   List<Gene> parentGenes =new ArrayList<>();
   Gene sParentGene=new Gene();
    String submittedAlleleParent= (String) request.getParameter("submittedParentGene");
    String msg= new String();
    if(submittedAlleleParent!=null && !submittedAlleleParent.equals("")){
        if(!submittedAlleleParent.equalsIgnoreCase("null")) {
            int submittedParentGeneRgdId= 0;
            sParentGene.setSymbol(submittedAlleleParent);
            try {
                submittedParentGeneRgdId= geneDAO.getRgdId(submittedAlleleParent);
                sParentGene.setRgdId(submittedParentGeneRgdId);
                sParentGene.setSpeciesTypeKey(3);
            } catch (Exception e) {
                e.printStackTrace();
        }
            parentGenes.add(sParentGene);
            msg="Click Update Button of Parent Gene to make asssociation";
       }
        }else{
        parentGenes = geneDAO.getGeneFromVariant(gene.getRgdId());
    }
%>
<div id="msg" style="color:red"><%=msg%></div>
<form action="updateGeneVariants.html" >
<input type="hidden" name="rgdId" value="<%=rgdId%>"/>
<table id="geneVariantTable" border="1" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td colspan="2" style="background-color:#2865a3;color:white; font-weight: 700;">Parent Gene</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
    </tr>
    <tr>
        <td colspan="3" align="right"><a href="javascript:addGeneVariant(); void(0);" style="font-weight:700; color: green;">Add Parent Gene</a></td>
    </tr>

    <tr>
        <td class="label">Gene Symbol</td>
        <td colspan="2" class="label">Gene Rgd Id</td>
    </tr>
    <%
        int parentGeneCount=1;
        for (Gene parentGene : parentGenes) {
            if (rgdId != displayRgdId) {
                parentGene.setKey(0);
            }
    %>
<tr id="geneVariantRow<%=parentGeneCount%>">
    <td id="geneVariantSymbolName<%=parentGeneCount%>"><%=parentGene.getSymbol()%></td>
    <td><input type="text" size="12" id="geneVariantRgdId<%=parentGeneCount%>" value="<%=parentGene.getRgdId()%>" name="parentGeneRgdId" readonly/>
        <a href="javascript:genevariant_lookup_prerender('geneVariantRgdId<%=parentGeneCount%>',<%=parentGene.getSpeciesTypeKey()%>,'GENES')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>
    </td>
    <td align="right">
        <a style="color:red; font-weight:700;"
                         href="javascript:removeGeneVariant('geneVariantRow<%=parentGeneCount%>') ;void(0);"><img
            src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
</tr>

<%
        parentGeneCount++;
    }
    %>
    </tbody>
</table>
</form>

<% } %>

<script>
  function genevariant_lookup_prerender(oid, specieskey, objecttype) {

      lookup_callbackfn = genevariant_lookup_postrender;
      lookup_render(oid, specieskey, objecttype);
  }
  function genevariant_lookup_postrender(oid, varRgdId) {
      // oid: replace 'geneVariantRgdId' with 'geneVariantSymbolName'
      var oid2 = oid.replace('geneVariantRgdId','geneVariantSymbolName');
      var url = '/rgdweb/curation/edit/editGene.html?act=symbol&rgdId='+varRgdId;
      loadDiv(url, oid2);
  }

  function removeGeneVariant(rowId) {
    var d = document.getElementById(rowId);
    d.parentNode.removeChild(d);
  }

    var geneVariantCreatedCount = 1;
    function addGeneVariant() {

        var tbody = document.getElementById("geneVariantTable").getElementsByTagName("TBODY")[0];

        var row = document.createElement("TR");
        row.id = "createdGeneVariantRow" + geneVariantCreatedCount;

        td = document.createElement("TD");
        td.id = "geneVariantSymbolNameCreated"+geneVariantCreatedCount;
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="12" id="geneVariantRgdIdCreated'+geneVariantCreatedCount+'" name="parentGeneRgdId" value="0" readonly> ';
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:genevariant_lookup_prerender('geneVariantRgdIdCreated" + geneVariantCreatedCount + "',3,'GENES') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/glass.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        td = document.createElement("TD");
        td.align = "right";
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:removeGeneVariant('createdGeneVariantRow" + geneVariantCreatedCount + "') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        tbody.appendChild(row);

        geneVariantCreatedCount++;
        enableAllOnChangeEvents();
    }


</script>