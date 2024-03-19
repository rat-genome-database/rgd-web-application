<%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.process.Utils" %>
<%@ page import="java.util.ArrayList" %>
<% if (!isNew) {

    List<edu.mcw.rgd.datamodel.Reference> refs = associationDAO.getReferenceAssociations(rgdId);
    if (refs.size() > 1 ) {
        // sort references by citation
        Collections.sort(refs, new Comparator<edu.mcw.rgd.datamodel.Reference>() {
            public int compare(edu.mcw.rgd.datamodel.Reference o1, edu.mcw.rgd.datamodel.Reference o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getCitation(), o2.getCitation());
            }
        });
    }
    //*************TO DIPLAY SUBMITTED REFERENCES *************************//
    String refsCurated= (String) request.getParameter("references");
    String ref= "";
    if(refsCurated!=null && !refsCurated.equals("")){
        if(!"null".equals(refsCurated)){
            ref="Submitter provided reference: " +  refsCurated;
        }
    }
    //*************************************************************//
%>
<p style="color:blue"><%=ref%></p>
<form action="updateCuratedReferences.html" >
<input type="hidden" name="rgdId" value="<%=rgdId%>"/>
<table id="curatedRefTable" border="1" width="600" class="updateTile" cellspacing="0" >
    <tbody>
    <tr>
        <td colspan="2" style="background-color:#2865a3;color:white; font-weight: 700;">Curated References</td>
        <td align="right" style="background-color:#2865a3;color:white; font-weight: 700;"><input type="button" value="Update" onclick="makePOSTRequest(this.form)"/></td>
    </tr>
    <tr>
        <td colspan="3" align="right"><a href="javascript:addCuratedRef(); void(0);" style="font-weight:700; color: green;">Add Reference</a></td>
    </tr>

    <tr>
        <td class="label">Citation</td>
        <td colspan="2" class="label">Ref Rgd Id</td>
    </tr>

    <%
        int curatedRefCount=1;
        for (edu.mcw.rgd.datamodel.Reference reference : refs) {
            if (rgdId != displayRgdId) {
                reference.setKey(0);
            }
    %>
<tr id="curatedRefRow<%=curatedRefCount%>">
    <td id="refCitation<%=curatedRefCount%>"><%=reference.getCitation()%></td>
    <td><input type="text" size="12" id="refRgdId<%=curatedRefCount%>" value="<%=reference.getRgdId()%>" name="refRgdId" readonly/>
        <a href="javascript:curatedref_lookup_prerender('refRgdId<%=curatedRefCount%>',<%=speciesTypeKey%>,'REFERENCES')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a>
    </td>
    <td align="right">
        <a style="color:red; font-weight:700;"
                         href="javascript:removeCuratedRef('curatedRefRow<%=curatedRefCount%>') ;void(0);"><img
            src="/rgdweb/common/images/del.jpg" border="0"/></a></td>
</tr>
<%
        curatedRefCount++;
    }
    %>
    </tbody>
</table>
</form>

<% } %>

<script>
  function curatedref_lookup_prerender(oid, specieskey, objecttype) {

      lookup_callbackfn = curatedref_lookup_postrender;
      lookup_render(oid, specieskey, objecttype);
  }
  function curatedref_lookup_postrender(oid, varRgdId) {
      var oid2 = oid.replace('refRgdId','refCitation');
      var url;
      if( pageTitle.equals("Edit Gene") )
          url = '/rgdweb/curation/edit/editGene.html?act=symbol&rgdId='+varRgdId;
      else if(pageTile.equals("Edit Variant"))
           url = '/rgdweb/curation/edit/editVariant.html?act=symbol&rgdId='+varRgdId;
      else
          url = '/rgdweb/curation/edit/editSSLP.html?act=symbol&rgdId='+varRgdId;
      loadDiv(url, oid2);
  }

  function removeCuratedRef(rowId) {
    var d = document.getElementById(rowId);
    d.parentNode.removeChild(d);
  }

    var curatedRefCreatedCount = 1;
    function addCuratedRef() {

        var tbody = document.getElementById("curatedRefTable").getElementsByTagName("TBODY")[0];

        var row = document.createElement("TR");
        row.id = "curatedRefRowCreated" + curatedRefCreatedCount;

        var td = document.createElement("TD");
        td.id = "refCitationCreated"+curatedRefCreatedCount;
        row.appendChild(td);

        td = document.createElement("TD");
        td.innerHTML = '<input type="text" size="12" id="refRgdIdCreated'+curatedRefCreatedCount+'" name="refRgdId" value="0"> ';
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:curatedref_lookup_prerender('refRgdIdCreated" + curatedRefCreatedCount + "',<%=speciesTypeKey%>,'REFERENCES') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/glass.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        td = document.createElement("TD");
        td.align = "right";
        rLink = document.createElement("A");
        rLink.border="0";
        rLink.href = "javascript:removeCuratedRef('curatedRefRowCreated" + curatedRefCreatedCount + "') ;void(0);";
        rLink.innerHTML = '<img src="/rgdweb/common/images/del.jpg" border="0"/>';
        td.appendChild(rLink);
        row.appendChild(td);

        tbody.appendChild(row);

        curatedRefCreatedCount++;
        enableAllOnChangeEvents();
    }
</script>
