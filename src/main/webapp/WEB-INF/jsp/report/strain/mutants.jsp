<%@ include file="../sectionHeader.jsp"%>
<%
    String ontId = ontologyDAO.getStrainOntIdForRgdId(obj.getRgdId());
    List<TermWithStats> congenics = ontologyDAO.getActiveChildTerms(ontId,SpeciesType.RAT);
    List records = new ArrayList();
    boolean foundOne = false;

    for (TermWithStats term: congenics) {
        if (ontologyDAO.isDescendantOf(term.getAccId(),"RS:0000461")) {
            if (!foundOne)  {
                foundOne=true;
//                out.println(ui.dynOpen("mutantAsscociation", "Mutant Strains"));
                out.println("<div id=\"mutantAsscociationTableDiv\" class=\"light-table-border\">");
                out.println("<div class=\"sectionHeading\" id=\"mutantAsscociation\">Mutant Strains</div>");
            }

            int rgdIdForStrain = ontologyDAO.getRgdIdForStrainOntId(term.getAccId());

            if (rgdIdForStrain == 0) {
                records.add("<tr><td><a href='/rgdweb/ontology/view.html?acc_id=" + term.getAccId() + "'>" + term.getTerm() + "</a></td></tr>");
            }else {
                records.add("<tr><td><a href=\"" + Link.strain(rgdIdForStrain) + "\">" + term.getTerm() + "</a></td></tr>");
            }
        }
    }

if (foundOne) {
    out.print(formatter.buildTable(records, 2));
    out.println("</div>");
//    out.println(ui.dynClose("mutantAsscociation"));
}

%>
<%@ include file="../sectionFooter.jsp"%>
