<%@ include file="../sectionHeader.jsp"%>
<%--<%--%>
<%--    List<Author> authors = referenceDAO.getAuthors(obj.getKey());--%>
<%--//    List<Author> authors = referenceDAO.getAuthors(135138);--%>
<%--    List<XdbId> pmIds = xdbDAO.getXdbIdsByRgdId(2, obj.getRgdId());--%>
<%--    RgdId id = managementDAO.getRgdId(obj.getRgdId());--%>

<%--    String pmId = "";--%>
<%--    if (pmIds.size() > 0) {--%>
<%--        pmId = pmIds.get(0).getAccId();--%>
<%--    }--%>

<%--    String pmcId = "";--%>
<%--    List<XdbId> pmcIds = xdbDAO.getXdbIdsByRgdId(146, obj.getRgdId());--%>
<%--    if (pmcIds.size() > 0) {--%>
<%--        pmcId = pmcIds.get(0).getAccId();--%>
<%--    }--%>
<%--%>--%>

<%--<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">--%>
<%--    <tr><td colspan="2"><h3><%=obj.getTitle()%></h3></td></tr>--%>
<%--    <tr>--%>
<%--        <td class="label">Authors:</td>--%>
<%--        <td>--%>
<%--            <% for (Author a: authors) {--%>
<%--                if( a.getLastName()!=null ) {--%>
<%--                    out.print(a.getLastName());--%>
<%--                    out.print(", ");--%>
<%--                }--%>
<%--                if( a.getFirstName()!=null ) {--%>
<%--                    out.print(a.getFirstName());--%>
<%--                }--%>
<%--                out.print("&nbsp; ");--%>
<%--            }--%>
<%--            %>--%>
<%--        </td>--%>
<%--    </tr>--%>
<%--    <tr>--%>
<%--        <td class="label">Citation:</td>--%>
<%--        <td><%=obj.getCitation()%></td>--%>
<%--    </tr>--%>
<%--    <tr>--%>
<%--        <td class="label"><%=RgdContext.getSiteName(request)%> ID:</td>--%>
<%--        <td><%=id.getRgdId()%></td>--%>
<%--    </tr>--%>

<%--    &lt;%&ndash; show optional URL_WEB_REFERENCE &ndash;%&gt;--%>
<%--    <% if( obj.getUrlWebReference()!=null ) { %>--%>
<%--    <tr>--%>
<%--        <td class="label">Web Url:</td>--%>
<%--        <td><a href="<%=obj.getUrlWebReference()%>"><%=obj.getUrlWebReference()%></a></td>--%>
<%--    </tr>--%>
<%--    <% } %>--%>

<%--    <%--%>
<%--        if (pmIds.size() > 0) {--%>
<%--    %>--%>
<%--    <tr>--%>
<%--        <td class="label">Pubmed:</td>--%>
<%--        <td>PMID:<%=pmId%> &nbsp; <a href="https://www.ncbi.nlm.nih.gov/pubmed/<%=pmId%>">(View Abstract at PubMed)</a></td>--%>
<%--    </tr>--%>
<%--    <% } %>--%>

<%--    <% if( !pmcId.isEmpty() ) {%>--%>
<%--    <tr>--%>
<%--        <td class="label">PMCID:</td>--%>
<%--        <td><%=pmcId%> &nbsp; <a href="https://www.ncbi.nlm.nih.gov/pmc/articles/<%=pmcId%>">(View Article at PubMed Central)</a></td>--%>
<%--    </tr>--%>
<%--    <% } %>--%>

<%--    <%--%>
<%--        if((obj.getDoi()!=null) && (!(obj.getDoi().equalsIgnoreCase("NULL"))) && (!(obj.getDoi().contains("[pii]")))){--%>
<%--    %>--%>
<%--    <tr>--%>
<%--        <td class="label">DOI:</td>--%>
<%--        <td>DOI:<%=obj.getDoi()%> &nbsp; <a href="http://dx.doi.org/<%=obj.getDoi()%>">(Journal Full-text)</a></td>--%>
<%--    </tr>--%>
<%--    <% } %>--%>


<%--    <%--%>
<%--        if(req.getParameter("abstract")!=null){--%>
<%--            if(!(req.getParameter("abstract").equals("0"))){--%>
<%--    %>--%>
<%--    <tr>--%>
<%--        <td colspan="2"><br>--%>
<%--            <%--%>
<%--                if (obj.getRefAbstract() != null) {--%>
<%--                    out.print(obj.getRefAbstract());--%>
<%--                } else {--%>
<%--                    out.print("Abstract for this paper unavailable");--%>
<%--                }--%>
<%--            %>--%>
<%--        </td>--%>
<%--    </tr>--%>


<%--    <%--%>
<%--    }else{--%>
<%--        if(!RgdContext.isProduction() || !RgdContext.isDev() ){%>--%>

<%--    <tr>--%>
<%--        <td colspan="2"><br>--%>
<%--            <%--%>
<%--                if (obj.getRefAbstract() != null) {--%>
<%--                    out.print(obj.getRefAbstract());--%>
<%--                } else {--%>
<%--                    out.print("Abstract for this paper unavailable");--%>
<%--                }--%>
<%--            %>--%>
<%--        </td>--%>
<%--    </tr>--%>

<%--    <%         }--%>
<%--    }--%>
<%--    }else{--%>
<%--    %>--%>
<%--    <tr>--%>
<%--        <td colspan="2"><br>--%>
<%--            <%--%>
<%--                if (obj.getRefAbstract() != null) {--%>
<%--                    out.print(obj.getRefAbstract());--%>
<%--                } else {--%>
<%--                    out.print("Abstract for this paper unavailable");--%>
<%--                }--%>
<%--            %>--%>
<%--        </td>--%>
<%--    </tr>--%>
<%--    <%--%>
<%--        }--%>
<%--    %>--%>

<%--</table>--%>
<%
ProjectDAO pdao1 = new ProjectDAO();
List<Project> project1 = pdao1.getProjectByRgdId(Integer.parseInt("476081962"));
%>

<h1>Project: <% for(Project i:project1){ %><%= i.getName() %><% } %></h1>
<br>
<h3>Description:</h3><% for(Project i:project1){ %><%= i.getDesc() %><% } %>.
<br>
<%--<br><h3>RGD References:</h3>--%>
<%
    ReferenceDAO test = new ReferenceDAO();
    List<Reference> p=test.getReferencesForObject(476081962);
//    Reference p1=test.getReference(476081962);
//    out.println(p1.getCitation());
%>
<%--<% for (Reference i:p){%>--%>
<%--<p><b><%=i.getTitle()%></b>.<%=i.getCitation()%>. RGD ID:<%=i.getRgdId()%></p>--%>
<%--<%}--%>
<%--%>--%>
<br>
<div class ="subTitle" id="references">RGD References</div>
<br>
<% for (Reference i:p){%>
<p><b><%=i.getTitle()%></b>.<br><%=i.getCitation()%>. RGD ID: <a class="mylink"href=""><%=i.getRgdId()%></a> </p>
<%}
%>
<style>

     .mylink {
        color: #5072A7;
    }
</style>
<br>
<%
    PhenominerDAO phDAO1 = new PhenominerDAO();
    List<Record> allRecords = phDAO1.getFullRecordsForProject(476081962);

%>
<%--<h1><%=obj.getRgdId()%></h1>--%>
<%--<h1><%=allRecords.get(2).getClinicalMeasurement()%></h1>--%>

<%--    <%for(Record i:allRecords){%>--%>
<%--<tr id="b">--%>
<%--    <td class="he"><%= i.getClinicalMeasurement() %></td>--%>
<%--&lt;%&ndash;    <td class="he"><%= i.getExperimentNotes() %></td>&ndash;%&gt;--%>
<%--&lt;%&ndash;    <td class="he"><%= i.getSample() %></td>&ndash;%&gt;--%>
<%--</tr>--%>
<%--<%}%>--%>
<%
    List<Integer> refRgdIds = new ProjectDAO().getReferenceRgdIdsForProject(obj.getRgdId());
    List<Annotation> annotList = annotationDAO.getAnnotationsByReference(refRgdIds.get(1));
%>





<%@ include file="../sectionFooter.jsp"%>