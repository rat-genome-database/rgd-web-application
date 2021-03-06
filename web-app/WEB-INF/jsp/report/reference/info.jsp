<%@ include file="../sectionHeader.jsp"%>
<%
    List<Author> authors = referenceDAO.getAuthors(obj.getKey());
    List pmIds = xdbDAO.getXdbIdsByRgdId(2, obj.getRgdId());
    RgdId id = managementDAO.getRgdId(obj.getRgdId());

    String pmId = "";
    if (pmIds.size() > 0) {
        pmId = xdbDAO.getXdbIdsByRgdId(2, obj.getRgdId()).get(0).getAccId();
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
        <td><a href="https://www.ncbi.nlm.nih.gov/pubmed/<%=pmId%>">(View Article at PubMed) </a>PMID:<%=pmId%></td>
    </tr>
    <% } %>

    <%
    if((obj.getDoi()!=null) && (!(obj.getDoi().equalsIgnoreCase("NULL"))) && (!(obj.getDoi().contains("[pii]")))){
    %>
        <tr>
        <td class="label">DOI:</td>
            <td>Full-text: <a href="http://dx.doi.org/<%=obj.getDoi()%>">DOI:<%=obj.getDoi()%></a></td>
        </tr>
    <%
    }
    %>



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