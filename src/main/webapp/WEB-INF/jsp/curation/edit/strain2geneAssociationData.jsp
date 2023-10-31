<% if (!isNew) {
    AssociationDAO aDao = new AssociationDAO();
    GeneDAO geneDAO= new GeneDAO();

    List<Strain2MarkerAssociation> geneAssocList = new ArrayList<>();

    String submittedRgdIdOfAllele=request.getParameter("submittedAlleleRgdId");
    String msg=new String();

    if(submittedRgdIdOfAllele!=null && !submittedRgdIdOfAllele.equals("")){
        if(!(submittedRgdIdOfAllele).equals("null") && !submittedRgdIdOfAllele.equals("0")){
            Strain2MarkerAssociation a= new Strain2MarkerAssociation();
        msg="Click 'Update Button' of 'Assocation-Gene Markers and Alleles' to make association";
            int subAlleleRgdId= Integer.parseInt(submittedRgdIdOfAllele);
            if(subAlleleRgdId>0){
                try {
                   a.setMarkerSymbol(geneDAO.getGene(subAlleleRgdId).getSymbol());
                    a.setMarkerRgdId(subAlleleRgdId);
                    a.setMarkerType("allele");
                    geneAssocList.add(a);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
    }}else{

        geneAssocList = aDao.getStrain2GeneAssociations(displayRgdId);

    }
%>
<p id="msg" style="color:red"><%=msg%></p>
<form action="updateStrainAssociations.html" >
<input type="hidden" name="rgdId" value="<%=rgdId%>">
<input type="hidden" name="markerClass" value="strain2gene">
<input type="hidden" name="submittedAlleleRgdId" value="<%=request.getAttribute("submittedAlleleRgdId")%>"/>
<table id="geneAssocTable" border="1" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td colspan="4" style="background-color:#2865a3;color:white; font-weight: 700;">Associations - Gene Markers And Alleles</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
    </tr>
    <tr>
        <td colspan="5" align="right"><a href="javascript:addGeneAssoc(); void(0);" style="font-weight:700; color: green;">Add Gene Marker</a></td>
    </tr>

    <tr>
        <td class="label">Gene Symbol</td>
        <td class="label">Gene RgdId</td>
        <td class="label">Marker Type</td>
        <td colspan="2" class="label">Region Name</td>
    </tr>

     <%
        int geneAssocCount=1;
        for (Strain2MarkerAssociation geneAssoc: geneAssocList) {
            String markerType = Utils.NVL(geneAssoc.getMarkerType(), "allele");
    %>
    <tr id="geneAssocRow<%=geneAssocCount%>">
    <td id="geneSymbol<%=geneAssocCount%>"><%=geneAssoc.getMarkerSymbol()%></td>
    <td><input type="text" size="12" id="geneRgdId<%=geneAssocCount%>" value="<%=geneAssoc.getMarkerRgdId()%>" name="geneRgdId">
        <a href="javascript:geneassoc_lookup_prerender('geneRgdId<%=geneAssocCount%>',<%=strain.getSpeciesTypeKey()%>,'GENES')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>
    </td>
    <td>
        <select id="geneMarkerType<%=geneAssocCount%>" name="geneMarkerType">
            <option <%=markerType.equals("flank 1")?"selected":""%>>flank 1</option>
            <option <%=markerType.equals("flank 2")?"selected":""%>>flank 2</option>
            <option <%=markerType.equals("allele")?"selected":""%>>allele</option>
        </select>
    </td>
    <td><input type="text" size="20" id="geneRegionName<%=geneAssocCount%>" name="geneRegionName" value="<%=Utils.defaultString(geneAssoc.getRegionName())%>" />
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
        rLink.href = "javascript:geneassoc_lookup_prerender('geneRgdIdCreated" + geneAssocCreatedCount + "',<%=strain.getSpeciesTypeKey()%>,'GENES') ;void(0);";
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