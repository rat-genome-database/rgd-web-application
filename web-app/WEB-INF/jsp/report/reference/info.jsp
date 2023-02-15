<%@ include file="../sectionHeader.jsp"%>
<%
    List<Author> authors = referenceDAO.getAuthors(obj.getKey());
    List<XdbId> pmIds = xdbDAO.getXdbIdsByRgdId(2, obj.getRgdId());
    RgdId id = managementDAO.getRgdId(obj.getRgdId());

    String pmId = "";
    if (pmIds.size() > 0) {
        pmId = pmIds.get(0).getAccId();
    }

    String pmcId = "";
    List<XdbId> pmcIds = xdbDAO.getXdbIdsByRgdId(146, obj.getRgdId());
    if (pmcIds.size() > 0) {
        pmcId = pmcIds.get(0).getAccId();
    }
%>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr><td colspan="2"><h3><%=obj.getTitle()%></h3></td></tr>
    <tr>
        <td class="label">Authors:</td>
        <td>
            <% for (Author a: authors) {
                if( a.getLastName()!=null ) {
                    out.print(a.getLastName());
                    out.print(", ");
                }
                if( a.getFirstName()!=null ) {
                    out.print(a.getFirstName());
                }
                out.print("&nbsp; ");
            }
            %>
        </td>
    </tr>
    <tr>
        <td class="label">Citation:</td>
        <td><%=obj.getCitation()%></td>
    </tr>
    <tr>
        <td class="label"><%=RgdContext.getSiteName(request)%> ID:</td>
        <td><%=id.getRgdId()%></td>
    </tr>

    <%-- show optional URL_WEB_REFERENCE --%>
    <% if( obj.getUrlWebReference()!=null ) { %>
    <tr>
        <td class="label">Web Url:</td>
        <td><a href="<%=obj.getUrlWebReference()%>"><%=obj.getUrlWebReference()%></a></td>
    </tr>
    <% } %>

    <%
        if (pmIds.size() > 0) {
    %>
    <tr>
        <td class="label">Pubmed:</td>
        <td>PMID:<%=pmId%> &nbsp; <a href="https://www.ncbi.nlm.nih.gov/pubmed/<%=pmId%>">(View Abstract at PubMed)</a></td>
    </tr>
    <% } %>

    <% if( !pmcId.isEmpty() ) {%>
    <tr>
        <td class="label">PMCID:</td>
        <td><%=pmcId%> &nbsp; <a href="https://www.ncbi.nlm.nih.gov/pmc/articles/<%=pmcId%>">(View Article at PubMed Central)</a></td>
    </tr>
    <% } %>

    <%
        if((obj.getDoi()!=null) && (!(obj.getDoi().equalsIgnoreCase("NULL"))) && (!(obj.getDoi().contains("[pii]")))){
    %>
    <tr>
        <td class="label">DOI:</td>
        <td>DOI:<%=obj.getDoi()%> &nbsp; <a href="http://dx.doi.org/<%=obj.getDoi()%>">(Journal Full-text)</a></td>
    </tr>
    <% } %>


    <%
        if(req.getParameter("abstract")!=null){
            if(!(req.getParameter("abstract").equals("0"))){
    %>
    <tr>
        <td colspan="2"><br>
            <%
                if (obj.getRefAbstract() != null) {
                    out.print(obj.getRefAbstract());
                } else {
                    out.print("Abstract for this paper unavailable");
                }
            %>
        </td>
    </tr>


    <%
    }else{
        if(!RgdContext.isProduction() || !RgdContext.isDev() ){%>

    <tr>
        <td colspan="2"><br>
            <%
                if (obj.getRefAbstract() != null) {
                    out.print(obj.getRefAbstract());
                } else {
                    out.print("Abstract for this paper unavailable");
                }
            %>
        </td>
    </tr>

    <%         }
    }
    }else{
    %>
    <tr>
        <td colspan="2"><br>
            <%
                if (obj.getRefAbstract() != null) {
                    out.print(obj.getRefAbstract());
                } else {
                    out.print("Abstract for this paper unavailable");
                }
            %>
        </td>
    </tr>
    <%
        }
    %>

</table>

<%@ include file="../sectionFooter.jsp"%>