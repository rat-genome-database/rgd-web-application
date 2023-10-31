<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.report.DaoUtils" %>
<%@ page import="java.util.*" %>

<%
    String pageTitle = "Edit QTL";
    String headContent = "";
    String pageDescription = "";
    try {
%>

<%@ include file="/common/headerarea.jsp" %>
<%@ include file="editHeader.jsp" %>

<%
    QTL qtl = (QTL) request.getAttribute("editObject");

    int rgdId = qtl.getRgdId();
    int displayRgdId = rgdId;
    int key = qtl.getKey();
    String symbol = qtl.getSymbol();

    NotesDAO noteDAO = new NotesDAO();
    List<Note> notes = noteDAO.getNotes(qtl.getRgdId(), "qtl_cross_type");
    String crossType;
    if (notes.size() > 0) {
        crossType = notes.get(0).getNotes();
    }else{
        crossType = "Not Available";
    }

    java.util.Map<String, String> mostSignificantCmos = null;
    {
        List<Term> measurementTerms = DaoUtils.getInstance().getMeasurementTermsForObject(qtl.getRgdId());
        if (measurementTerms.size() > 1) {
            mostSignificantCmos = new LinkedHashMap<>();
            mostSignificantCmos.put("", "None");
            for( Term term: measurementTerms ) {
                mostSignificantCmos.put(term.getAccId(), term.getTerm());
            }
        }
    }

    if (isClone) {
        QTL clone = (QTL) request.getAttribute("cloneObject");
        qtl = clone;
        displayRgdId = qtl.getRgdId();
        symbol = qtl.getSymbol() + " (COPY)";
    }
%>

<h1>Edit QTL: <%=dm.out("symbol", symbol)%></h1>


<table>
    <tr>
        <td  valign="top">

    <form action="editQTL.html" >
        <input type="hidden" name="rgdId" value="<%=rgdId + ""%>"/>
        <input type="hidden" name="key" value="<%=key%>"/>

        <% if (isNew) {%>
            <input type="hidden" name="act" value="add"/>
        <% } else { %>
            <input type="hidden" name="act" value="upd"/>
        <% } %>

        <%
            String species = request.getParameter("speciesType");
            if (species == null) {
                species = SpeciesType.getCommonName(qtl.getSpeciesTypeKey());
            }
        %>

        <input type="hidden" name="speciesType" value="<%=species%>"/>
        <input type="hidden" name="objectType" value="<%=request.getParameter("objectType")%>"/>
        <input type="hidden" name="objectStatus" value="<%=request.getParameter("objectStatus")%>"/>

        <table border="0" width="600" >
            <% if (!isNew) { %>
            <tr>
                <td class="label" >Key:</td>
                <td><%=dm.out("key", key)%></td>
            </tr>
            <% } %>
            <tr>
                <td class="label">Symbol:</td>
                <td><input name="symbol" type="text" size="45" value="<%=dm.out("symbol", symbol)%>"/>&nbsp;<a href="javascript:lookup_render('', 3, 'QTLS')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a></td>
            </tr>
            <tr>
                <td class="label">Name:</td>
                <td><input name="name" type="text" size="45" value="<%=dm.out("name",qtl.getName())%>"/></td>
            </tr>
            <tr>
                <td class="label">Chromosome:</td>
                <td><input name="chromosome" type="text" size="5"
                           value="<%=dm.out("chromosome",qtl.getChromosome())%>"/></td>
            </tr>
            <tr>
                <td class="label">LOD:</td>
                <td><input name="lod" type="text" size="5" value="<%=dm.out("lod",qtl.getLod())%>"/></td>
            </tr>
            <tr>
                <td class="label">P Value:</td>
                <td><input name="pValue" type="text" size="5" value="<%=dm.out("pValue",qtl.getPValue())%>"/></td>
            </tr>
            <tr>
                <td class="label">Variance:</td>
                <td><input name="variance" type="text" size="5" value="<%=dm.out("variance",qtl.getVariance())%>"/>
                </td>
            </tr>
            <tr>
                <td class="label">Peak Offset:</td>
                <td><input name="peakOffset" type="text" size="5" value="<%=dm.out("peakOffset",qtl.getPeakOffset())%>"/></td>
            </tr>
            <%--<tr>
                <td class="label">Cross Type</td>
                <td><input name="crossType" type="text" value="<%=dm.out("crossType",crossType)%>"/></td>
            </tr>--%>

            <tr>
                <td class="label">Flank 1 RGD ID:</td>
                <td><input id="flank1RgdId" name="flank1RgdId" type="text" size="9" value="<%=dm.out("flank1RgdId",qtl.getFlank1RgdId())%>"/>&nbsp;
                    <a href="javascript:lookup_render('flank1RgdId', <%=SpeciesType.parse(species)%>)"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a></td>
            </tr>
            <tr>
                <td class="label">Flank 2 RGD ID:</td>
                <td ><input id="flank2RgdId" name="flank2RgdId" type="text" size="9" value="<%=dm.out("flank2RgdId",qtl.getFlank2RgdId())%>"/>&nbsp;
                    <a href="javascript:lookup_render('flank2RgdId', <%=SpeciesType.parse(species)%>)"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a></td>
            </tr>
            <tr>
                <td class="label">Peak RGD ID:</td>
                <td><input id="peakRgdId" name="peakRgdId" type="text" size="9" value="<%=dm.out("peakRgdId",qtl.getPeakRgdId())%>"/>&nbsp;
                    <a href="javascript:lookup_render('peakRgdId', <%=SpeciesType.parse(species)%>)"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a></td>
            </tr>
            <tr>
                <td class="label">Inheritance Type:</td>
                <td><%=fu.buildSelectList("inheritanceType", new QTLDAO().getInheritanceTypes(), dm.out("inheritanceType", qtl.getInheritanceType()), true)%>
                </td>
            </tr>
            <tr>
                <td class="label">LOD Image:</td>
                <td><input name="lodImage" type="text" size="45" value="<%=dm.out("lodImage",qtl.getLodImage())%>"/>
                </td>
            </tr>
            <tr>
                <td class="label">Linkage Image:</td>
                <td><input name="linkageImage" type="text" size="45"
                           value="<%=dm.out("linkageImage",qtl.getLinkageImage())%>"/></td>
            </tr>
            <tr>
                <td class="label">Source URL:</td>
                <td><input name="sourceUrl" type="text" size="45"
                           value="<%=dm.out("sourceUrl",qtl.getSourceUrl())%>"/></td>
            </tr>

            <% if( mostSignificantCmos!=null ) { %>
            <tr>
                <td class="label">Most Significant Measurement Type:</td>
                <td><%=fu.buildSelectList("mostSignificantCmoTerm", mostSignificantCmos, qtl.getMostSignificantCmoTerm())%></td>
            </tr>
            <% } %>

            <tr>
                <td colspan="2" align="center">
                    <% if (isNew) { %>
                        <input type="submit" value="Add QTL" />
                    <% } else {%>
                        <input type="button" value="Update QTL" onclick="makePOSTRequest(this.form)"/>
                    <% } %>
                </td>
            </tr>
        </table>
    </form>

        </td>
        <td>&nbsp;&nbsp;</td>
        <td valign="top">
           <%@ include file="idInfo.jsp" %>
           <br>
           <!--%@ include file="mapData.jsp" %>-->
        </td>
    </tr>
</table>

<%  String notesObjectType = "qtls"; %>

<%@ include file="aliasData.jsp" %>
<%@ include file="qtlAssociationData.jsp" %>
<%@ include file="notesData.jsp" %>

<%@ include file="/common/footerarea.jsp" %>

<% } catch (Exception e) {
       e.printStackTrace();
   }
%>