<%@ include file="../sectionHeader.jsp"%>
<h1>I am here</h1>
<%
    XdbId xi = new XdbId();
    xi.setRgdId(obj.getRgdId());
    List<XdbId> ei = xdbDAO.getXdbIds(xi, obj.getSpeciesTypeKey());

    if (ei.size() > 0) {

%>


<%=ui.dynOpen("xdbAsscociation", "External Database Links")%>    <br>

<table border="0" >
<%



    int lastXdbKey=0;
    String lastLink="";
    for (XdbId xid: ei) {
  //      if (!xdbDAO.getXdbName(xid.getXdbKey()).equals("PubMed") ") || xdbDAO.getXdbName(xid.getXdbKey()).equals("GenBank Protein")) {
    //        continue;
   //     }

%>


    <tr>
           <%
               if (lastXdbKey != xid.getXdbKey()) {
                   lastXdbKey= xid.getXdbKey();
                   lastLink=xdbDAO.getXdbUrl(xid.getXdbKey(), obj.getSpeciesTypeKey());
            %>

               <td style="background-color:#e2e2e2;"><b><%=xdbDAO.getXdbName(xid.getXdbKey())%></b></td>
           <% } else {%>
               <td style="background-color:#e2e2e2;">&nbsp;</td>
           <% } %>

               <td style="background-color:#e2e2e2;"><a href="<%=lastLink%><%=xid.getAccId()%>"><%=xid.getAccId()%></a></td>
           </tr>
<%

    }

%>
</tr>
        </table>
<br>
<%=ui.dynClose("xdbAsscociation")%>

<%
    }

%>

<%@ include file="../sectionFooter.jsp"%>