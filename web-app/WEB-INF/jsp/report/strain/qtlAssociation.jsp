<%@ include file="../sectionHeader.jsp"%>
<%
  List<QTL> qtls = associationDAO.getQTLAssociationsForStrain(obj.getRgdId());
    if (qtls.size() > 0) {
        // sort annotations by TERM, then by EVIDENCE code
        // to enable createGridFormatAnnotations() to group evidence codes properly
        Collections.sort(qtls, new Comparator<QTL>() {

            public int compare(QTL o1, QTL o2) {
                int result = Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
                if( result!=0 )
                    return result;
                return o1.getChromosome().compareTo(o2.getChromosome());
            }
        });
%>


<%--<%=ui.dynOpen("strainQtlAssociation", "Strain QTL Data")%>--%>
<table cellpadding="3" cellspacing="3" >
<tr>
    <td><b>Symbol</b></td>
    <td><b>Name</b></td>
    <td><b>Trait</b></td>
</tr>
<%
    for (QTL qtl: qtls) {
        List<Term> traitTerms = DaoUtils.getInstance().getTraitTermsForObject(qtl.getRgdId());
        if( traitTerms.isEmpty() ) {
            List<Note> notes = noteDAO.getNotes(obj.getRgdId(), "qtl_trait");
            if( !notes.isEmpty() ) {
                Term traitTerm = new Term();
                traitTerm.setTerm(notes.get(0).getNotes());
                traitTerms.add(traitTerm);
            }
        }
    %>
        <tr>
            <td><a href="<%=Link.qtl(qtl.getRgdId())%>"><%=qtl.getSymbol()%></a> </td>
            <td><%=qtl.getName()%></td>
            <td><% for( Term term: traitTerms ) {
                if( term.getAccId()!=null ) { %>
                <%=term.getTerm()%> &nbsp; (<%=term.getAccId()%>) &nbsp; &nbsp;
                <a title="show term annotations" href="<%=Link.ontAnnot(term.getAccId())%>" ><img border="0" alt="" src="/rgdweb/images/icon-a.gif"></a>
                <a title="browse term tree" href="<%=Link.ontView(term.getAccId())%>"><img border="0" alt="" src="/rgdweb/common/images/tree.png"></a>
                <br>
                <% } else { %>
                <%=term.getTerm()%><br>
                <% }
                } %>
            </td>
        </tr>
    <%
    }
%>
</table>

<%--<%=ui.dynClose("strainQtlAssociation")%>--%>

<% } %>

<%@ include file="../sectionFooter.jsp"%>
