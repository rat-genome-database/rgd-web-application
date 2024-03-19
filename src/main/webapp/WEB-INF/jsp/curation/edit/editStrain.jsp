<%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="edu.mcw.rgd.web.FormUtility" %>
<%@ page import="edu.mcw.rgd.web.DisplayMapper" %>
<%@ page import="edu.mcw.rgd.datamodel.*" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="java.util.*" %>

<%
    String pageTitle = "Edit Strain";
    String headContent = "";
    String pageDescription = "";
%>
<%@ include file="/common/headerarea.jsp"%>
<%@ include file="editHeader.jsp" %>
<%

    Strain strain = (Strain) request.getAttribute("editObject");
    StrainDAO sdao= new StrainDAO();
    int rgdId = strain.getRgdId();
    int displayRgdId = rgdId;
    int key = strain.getKey();
    String symbol = strain.getSymbol();
    String submittedAlleleRgdId= (String) request.getAttribute("submittedAlleleRgdId");
    String references= (String) request.getAttribute("references");

    if (isClone) {
        strain = (Strain) request.getAttribute("cloneObject");
        displayRgdId = strain.getRgdId();
        symbol = strain.getSymbol() + " (COPY)";
    }

    List geneticStatus = new ArrayList();
    geneticStatus.add("");
    geneticStatus.add("Heterozygous");
    geneticStatus.add("Homozygous");
    geneticStatus.add("Hemizygous");
    geneticStatus.add("Wild Type");

    List<String> yesNoList = new ArrayList();
    yesNoList.add("N/A");
    yesNoList.add("Yes");
    yesNoList.add("No");

    String lastStatusDate = "";
    if( strain.getLastStatus().contains("as of") ) {
        int pos = strain.getLastStatus().indexOf("as of");
        lastStatusDate = strain.getLastStatus().substring(pos+6, pos+6+10);
    }
    StrainDAO strainDAO = new StrainDAO();
%>


<h1>Edit Strain: <%=dm.out("symbol",symbol)%></h1>
<%if(request.getAttribute("additionalInfo")!=null && !(request.getAttribute("additionalInfo").equals(""))){
    if(!request.getAttribute("additionalInfo").equals("null")){%>
<p style="color:red"><span style="text-decoration:underline">Additional information provided by USER:</span><span style="color:blue"><%=request.getAttribute("additionalInfo")%></span> </p>
<%}}%>
<% if(request.getParameter("submittedAlleleRgdIdInfo")!=null && !(request.getParameter("submittedAlleleRgdIdInfo").equals(""))){
    if(!request.getParameter("submittedAlleleRgdIdInfo").equals("null")){%>
        <p style="color:blue">Submitter provided allele RGD ID:<span style="color:red"> <%=request.getParameter("submittedAlleleRgdIdInfo")%> </span>Make association if you don't see this information in Gene and Allele Marker Section.</p>
  <%  }
}%>
<table>
    <tr>
        <td>

<form action="editStrain.html" method="get">
<input type="hidden" name="rgdId" value="<%=rgdId%>" />
<input type="hidden" name="key" value="<%=strain.getKey()%>" />
<input type="hidden" name="submittedAlleleRgdId" value="<%=submittedAlleleRgdId%>"/>
<input type="hidden" name="references" value="<%=references%>"/>
    <% if (isNew) {%>
        <input type="hidden" name="act" value="add"/>
    <% } else { %>
        <input type="hidden" name="act" value="upd"/>
    <% } %>
<input type="hidden" name="speciesType" value="<%=request.getParameter("speciesType")%>"/>
<input type="hidden" name="objectType" value="<%=request.getParameter("objectType")%>"/>
<input type="hidden" name="objectStatus" value="<%=request.getParameter("objectStatus")%>"/>

    <table>
        <% if (!isNew) { %>
        <tr>
            <td class="label">Key:</td>
            <td><%=strain.getKey()%></td>
        </tr>
        <% } %>
        <tr>
            <td class="label">Symbol:</td>
            <td><input type="text" name="symbol" size="90" value="<%=dm.out("symbol",symbol)%>" />&nbsp;<a href="javascript:lookup_render('', 3,'STRAINS')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a></td>
        </tr>
        <tr>
            <td class="label">Name:</td>
            <td><input type="text" name="name" size="90" value="<%=dm.out("name",strain.getName())%>" /> </td>
        </tr>
        <tr>
            <td class="label">Strain:</td>
            <td><input type="text" name="strain" size="90" value="<%=dm.out("strain",strain.getStrain())%>" /></td>
        </tr>
        <tr>
            <td class="label">Substrain:</td>
            <td><input type="text" name="subStrain" size="90" value="<%=dm.out("subStrain",strain.getSubstrain())%>" /></td>
        </tr>
        <tr>
            <td class="label">Type:</td>
            <td><%=fu.buildSelectList("strainTypeName", strainDAO.getStrainTypes(), dm.out("strainTypeName",strain.getStrainTypeName()))%></td>
        </tr>
        <tr>
            <td class="label">Genetics:</td>
            <td><input type="text" name="genetics" size="90" value="<%=dm.out("genetics",strain.getGenetics())%>" /></td>
        </tr>
        <tr>
            <td class="label">Genetic Status:</td>
            <td><%=fu.buildSelectList("geneticStatus",geneticStatus, dm.out("geneticStatus",strain.getGeneticStatus()))%></td>
        </tr>
        <tr>
            <td class="label">Inbred Generation:</td>
            <td><input type="text" name="inbredGen" size="90" value="<%=dm.out("inbredGen",strain.getInbredGen())%>" /></td>
        </tr>
        <tr>
            <td class="label">Background Strain Rgd ID:</td>
            <td><input type="text" name="backgroundStrainRgdId" id="backgroundStrainRgdId" size="50" value="<%=dm.out("backgroundStrainRgdId",strain.getBackgroundStrainRgdId())%>" />&nbsp;<a href="javascript:lookup_render('backgroundStrainRgdId', 3,'STRAINS')"><img src="/rgdweb/common/images/glass.jpg" border="0"/></a></td>
        </tr>
        <% if(request.getAttribute("submittedBackgroundStrain")!=null && !(request.getAttribute("submittedBackgroundStrain").equals(""))){
            if(!request.getAttribute("submittedBackgroundStrain").equals("null")){%>
        <tr>

            <td class="label">Background Strain:</td>
            <td><span style="color:blue"><%=request.getAttribute("submittedBackgroundStrain")%></span> </td>

        </tr>
        <%}}%>

        <tr>
            <td class="label">Modification Method:</td>
            <% String method= strain.getModificationMethod();
               List<String> existingMethods= strainDAO.getModificationMethods();
                boolean flag=false;
                if(method!=null){
                for(String m: existingMethods){
                    if(method.equalsIgnoreCase(m)){
                        flag=true;
                        break;
                    }
                }
            if(!flag){%>
            <td><%=fu.buildSelectList("modificationMethod", strainDAO.getModificationMethods(), "Other")%>&nbsp;&nbsp;
                <span style="font-weight:bold">Submitted Method:  </span>
                <span style="color:blue" ><%=strain.getModificationMethod()%></span>&nbsp;&nbsp;
           <% } else{%>
            <td><%=fu.buildSelectList("modificationMethod", strainDAO.getModificationMethods(), Utils.NVL(strain.getModificationMethod(),"N/A"))%></td>
            <%}}else{%>
               <td><%=fu.buildSelectList("modificationMethod", strainDAO.getModificationMethods(), Utils.NVL(strain.getModificationMethod(),"N/A"))%></td>
          <%  }%>
        </tr>
        <tr>
            <td class="label">Description:</td>
            <td><textarea rows="4" name="description" cols="90" ><%=dm.out("description",strain.getDescription())%></textarea></td>
        </tr>

        <tr>
            <td class="label">Color:</td>
            <td><textarea rows="4" name="color" cols="90" ><%=dm.out("color",strain.getColor())%></textarea></td>
        </tr>
        <tr>
            <td class="label">Chr Altered:</td>
            <td><input type="text" name="chrAltered" size="90" value="<%=dm.out("chrAltered",strain.getChrAltered())%>" /></td>
        </tr>
        <tr>
            <td class="label">Available Source:</td>
            <td><textarea cols="90" rows="5" name="source"><%=dm.out("source",strain.getSource())%></textarea></td>
        </tr>
        <tr>
            <td class="label">Origination:</td>
            <td><textarea cols="90" rows="5" name="origination"><%=dm.out("source",strain.getOrigination())%></textarea></td>
        </tr>
        <tr>
            <td class="label">Image URL:</td>
            <% if(strain.getImageUrl()!=null){ %>
            <td><a href="/rgdweb/curation/edit/imageDisplay.html?image=<%=strain.getImageUrl()%>" target="_blank"><%=strain.getImageUrl()%></a></td>
            <%}else{%>
            <td><input type="text" name="imageUrl" size="90" value="<%=dm.out("imageUrl",strain.getImageUrl())%>" /></td>

          <%  }%>
        </tr>

        <tr>
            <td class="label">Last Status:</td>
            <%
                String lastStatus = strain.getLastStatus();
                if( request.getAttribute("submittedAvailability")!=null && !(request.getAttribute("submittedAvailability").equals(""))) {
                    lastStatus = (String) request.getAttribute("submittedAvailability");
                }
            %>
            <td>
                Live Animals: <%=fu.buildSelectList("live_animals", yesNoList, lastStatus.contains("Unknown")?"N/A":lastStatus.contains("Live")?"Yes":"No")%>
                Cryopreserved Embryo: <%=fu.buildSelectList("embryo", yesNoList, lastStatus.contains("Unknown")?"N/A":lastStatus.contains("Embryo")?"Yes":"No")%>
                Cryopreserved Sperm: <%=fu.buildSelectList("sperm", yesNoList, lastStatus.contains("Unknown")?"N/A":lastStatus.contains("Sperm")?"Yes":"No")%>
                Cryorecovery: <%=fu.buildSelectList("cryorecovery", yesNoList, lastStatus.contains("Unknown")?"N/A":lastStatus.contains("ryorecovery")?"Yes":"No")%>
            </td>
        </tr>
        <tr>
            <td class="label">Status Log:</td>
            <td><div style="margin-left:25px; color:dimgray;">
                <% int si=0;
                for( Strain.Status st: strain.getStatusLog() ) {
                    si++;
            %>
                <%=si%>. <%=st.toString()%><br>
            <% } %></div>
            </td>
        </tr>

        <tr>
            <td class="label">Research Use:</td>
            <td><input type="text" name="researchUse" size="90" value="<%=dm.out("researchUse",strain.getResearchUse())%>" /></td>
        </tr>
        <tr>
            <td class="label">Notes:</td>
            <td><textarea rows="6" name="notes" cols="90" ><%=dm.out("notes",strain.getNotes())%></textarea></td>
        </tr>
        <tr>
            <td colspan="2" align="center">
                <% if (isNew) { %>
                    <input type="submit" value="Create Strain"/>
                <%} else { %>
                    <input type="button" value="Update Strain" onclick="makePOSTRequest(this.form)"/>
                <% } %>
            </td>
        </tr>
    </table>
</form>

</td>
<td>&nbsp;&nbsp;</td>
<td valign="top">
    <%@ include file="idInfo.jsp" %>
</td>
</tr>
</table>

<%
    String notesObjectType = "strains";
%>

<%@ include file="aliasData.jsp" %>
<%@ include file="strain2geneAssociationData.jsp" %>
<%@ include file="strain2sslpAssociationData.jsp" %>
<%@ include file="strainAssociationData.jsp" %>
<%@ include file="notesData.jsp" %>
<%@ include file="externalLinksData.jsp" %>

<%@ include file="/common/footerarea.jsp" %>

