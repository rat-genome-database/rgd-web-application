<%@ include file="../sectionHeader.jsp"%>

<% if (obj.getSpeciesTypeKey()==SpeciesType.HUMAN) {
VariantInfoDAO vidao = new VariantInfoDAO();
VariantInfo clinVar = vidao.getVariant(obj.getRgdId());
List<HgvsName> hgvsNames = new VariantInfoDAO().getHgvsNames(obj.getRgdId());
// hgvs names, evaluated, clinical significance, age of onset, prevalence
if (clinVar!=null){
%>
<link rel='stylesheet' type='text/css' href='/rgdweb/css/treport.css'>
<div class="reportTable light-table-border" id="ClinVarTableWrapper">
    <div class="sectionHeading" id="ClinVar">ClinVar Data</div>
    <div id="ClinVarTableDiv" class="annotation-detail">
        <table id="ClinVarTable" border='0' cellpadding='2' cellspacing='2'>
            <tr>
                <%if (hgvsNames!=null && !hgvsNames.isEmpty()) {%>
                <td>HGVS Name(s)</td>
                <% } %>
                <td>Last Evaluated</td>
                <% if( clinVar.getMolecularConsequence()!=null ) { %>
                <td>Molecular Consequence</td>
                <% } %>
                <td>Clinical Significance</td>
                <% if( clinVar.getAgeOfOnset()!=null ) { %>
                <td>Age of Onset</td>
                <% } %>
                <% if( clinVar.getPrevalence()!=null ) { %>
                <td>Prevalence</td>
                <% } %>
                <td>Trait Synonyms</td>
            </tr>
            <tr>
                <%if (hgvsNames!=null && !hgvsNames.isEmpty()){
                    String lessTerms = "";
                    String moreTerms = "";
                    for (int i = 0 ; i < hgvsNames.size() ; i ++){
                        if (i<4){
                            lessTerms += hgvsNames.get(i).getName()+"<br>";
                        }
                        else{
                            moreTerms += hgvsNames.get(i).getName()+"<br>";
                        }
                    }%>
                <td>
                    <%=lessTerms%>
                    <% if (hgvsNames.size()>4) {%>
                    <span class="more" style="display: none;"><%=moreTerms%> </span><a href="" class="moreLink" title="Click to see more"> More...</a>
                    <% } %>
                </td>
                <% } %>
                <td><%=fu.chkNull(clinVar.getDateLastEvaluated())%></td>
                <% if( clinVar.getMolecularConsequence()!=null ) { %>
                <td><%=clinVar.getMolecularConsequence()%></td>
                <% } %>
                <td><%=fu.chkNull(clinVar.getClinicalSignificance())%></td>
                <% if( clinVar.getAgeOfOnset()!=null ) { %>
                <td><%=clinVar.getAgeOfOnset()%></td>
                <% } %>
                <% if( clinVar.getPrevalence()!=null ) { %>
                <td><%=clinVar.getPrevalence()%></td>
                <% }
                    List<Alias> aliases = aliasDAO.getAliases(obj.getRgdId());
                    if (aliases.size() > 0 ) {
                        // sort aliases alphabetically by alias value
                        Collections.sort(aliases, new Comparator<Alias>() {
                            public int compare(Alias o1, Alias o2) {
                                return Utils.stringsCompareToIgnoreCase(o1.getValue(), o2.getValue());
                            }
                        });
                %>
                <td><%=Utils.concatenate("; ", aliases, "getValue")%></td>
                <% } %>
            </tr>
        </table>
    </div>
<% }
} %>

<%@ include file="../sectionFooter.jsp"%>