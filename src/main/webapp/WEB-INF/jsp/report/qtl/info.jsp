<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.report.*" %>


<%@ include file="../sectionHeader.jsp"%>
<%
    RgdId id = managementDAO.getRgdId(obj.getRgdId());
    List<Note> notes;

    List<Term> traitTerms = DaoUtils.getInstance().getTraitTermsForObject(obj.getRgdId());
    if( traitTerms.isEmpty() ) {
        notes = noteDAO.getNotes(obj.getRgdId(), "qtl_trait");
        if( !notes.isEmpty() ) {
            Term traitTerm = new Term();
            traitTerm.setTerm(notes.get(0).getNotes());
            traitTerms.add(traitTerm);
        }
    }

    List<Term> measurementTerms = DaoUtils.getInstance().getMeasurementTermsForObject(obj.getRgdId());
    if( measurementTerms.isEmpty() ) {
        notes = noteDAO.getNotes(obj.getRgdId(), "qtl_subtrait");
        if( !notes.isEmpty() ) {
            Term measurementTerm = new Term();
            measurementTerm.setTerm(notes.get(0).getNotes());
            measurementTerms.add(measurementTerm);
        }
    } else if( measurementTerms.size()>1 ) {
        // multiple CMO terms -- pick the most significant CMO term if available
        if( !Utils.isStringEmpty(obj.getMostSignificantCmoTerm()) ) {
            Term term = ontologyDAO.getTermWithStatsCached(obj.getMostSignificantCmoTerm());
            if( term!=null ) {
                measurementTerms.clear();
                measurementTerms.add(term);
            }
        }
    }

    notes = noteDAO.getNotes(obj.getRgdId(), "qtl_cross_type");
    String crossType;
    if (notes.size() > 0) {
        crossType = notes.get(0).getNotes();
    }else{
        crossType = "Not Available";
    }

    List<Strain> sts = associationDAO.getStrainAssociationsForQTL(obj.getRgdId());
    String strainsCrossed = "";
    if(obj.getSpeciesTypeKey() == SpeciesType.RAT){
        for (Strain strain: sts) {
            strainsCrossed += "<a href='" + Link.strain(strain.getRgdId()) + "'>" + strain.getSymbol() + "</a>&nbsp;";
        }
    }else if(obj.getSpeciesTypeKey() == SpeciesType.HUMAN){
        notes = noteDAO.getNotes(obj.getRgdId(), "qtl_population");
        if(notes.size()>0){
            strainsCrossed = notes.get(0).getNotes();
        }else{
            strainsCrossed = "Not Available";
        }
    }

    String lodValue;
    if(fu.chkNullNA(obj.getLod()).equalsIgnoreCase("Not Available")){
        notes = noteDAO.getNotes(obj.getRgdId(), "qtl_statistics");
        if(notes.size()>0){
            lodValue = notes.get(0).getNotes();
        }else{
            lodValue = "Not Available";
        }
    }else{
        lodValue = obj.getLod().toString();
    }
%>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr><td colspan="2"><h3>QTL: <%=obj.getSymbol()%>&nbsp;(<%=obj.getName()%>)&nbsp;<%=SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey())%></h3></td></tr>
    <tr>
        <td class="label">Symbol:</td>
        <td><%=obj.getSymbol()%></td>
    </tr>
    <tr>
        <td class="label">Name:</td>
        <td><%=obj.getName()%></td>
    </tr>
    <tr>
        <td class="label"><%=RgdContext.getSiteName(request)%> ID:</td>
        <td><%=id.getRgdId()%></td>
    </tr>
    <%
        List<Alias> aliases = aliasDAO.getAliases(obj.getRgdId());
        if( !aliases.isEmpty() ) {
    %>
    <tr>
        <td class="label" valign="top">Previously&nbsp;known&nbsp;as:</td>
        <td><%=Utils.concatenate("; ", aliases, "getValue")%></td>
    </tr>
    <% } %>

    <% if( !traitTerms.isEmpty() ) { %>
    <tr>
        <td class="label">Trait:</td>
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
    <% } %>

    <% if( !measurementTerms.isEmpty() ) { %>
    <tr>
        <td class="label">Measurement Type:</td>
        <td><% for( Term term: measurementTerms ) {
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
    <% } %>

    <tr>
        <td class="label">LOD&nbsp;Score:</td>
        <td><%=fu.chkNullNA(lodValue)%></td>
    </tr>
    <tr>
        <td class="label">P&nbsp;Value:</td>
        <% if ((obj.getPValue() == null || obj.getPValue() == 0) && obj.getpValueMlog()!=null) {
            double w = obj.getpValueMlog();
            int x = (int) Math.ceil(w);
            double y = x-w;
            int z = (int) Math.round(Math.pow(10,y));
            String convertedPVal = z+"E-"+x;
//            System.out.println(convertedPVal);
        %>
        <td><%=convertedPVal%></td>
        <%} else {%>
        <td><%=fu.chkNullNA(obj.getPValue())%></td>
        <% } %>
    </tr>
    <tr>
        <td class="label">Variance:</td>
        <td><%=fu.chkNullNA(obj.getVariance())%></td>
    </tr>

    <% if( obj.getInheritanceType()!=null ) { %>
    <tr>
        <td class="label">Inheritance&nbsp;Type:</td>
        <td><%=obj.getInheritanceType()%></td>
    </tr>
    <% } %>

    <tr>
        <td class="label">Position</td>
        <td><%=MapDataFormatter.buildTable(obj.getRgdId(), obj.getSpeciesTypeKey(), rgdId.getObjectKey(), obj.getSymbol())%></td>
    </tr>
    <%if (obj.getSpeciesTypeKey()!=1){%>
    <tr>
        <td class="label">Cross&nbsp;Type:</td>
        <td><%=crossType%></td>
    </tr>
    <% } %>
    <tr>
        <% if(obj.getSpeciesTypeKey() == SpeciesType.RAT){ %>
        <td class="label">Strains&nbsp;Crossed:</td>
        <td><%=strainsCrossed%></td>
        <%
            }else if(obj.getSpeciesTypeKey() == SpeciesType.HUMAN){
        %>
        <td class="label">Population&nbsp;Stats:</td>
        <td><%=strainsCrossed%></td>
        <%
            }
        %>
    </tr>

    <%-- show model JBrowse mini chart for genes having positions on current reference assembly --%>
    <% if(fu.mapPosIsValid(md)) {
        String dbJBrowse = obj.getSpeciesTypeKey()==SpeciesType.HUMAN ? "data_hg38"
                : obj.getSpeciesTypeKey()==SpeciesType.MOUSE ? "data_mm38"
                : obj.getSpeciesTypeKey()==SpeciesType.RAT ? "data_rn7_2"
                : obj.getSpeciesTypeKey()==SpeciesType.CHINCHILLA ? "data_cl1_0"
                : "";
        String tracks = obj.getSpeciesTypeKey()==SpeciesType.CHINCHILLA ? "GFF3_track" : "AQTLS";
        String jbUrl = "https://rgd.mcw.edu/jbrowse?data="+dbJBrowse+"&tracks="+tracks+"&highlight=&tracklist=0&nav=0&overview=0&loc="+FormUtility.getJBrowseLoc(md);
    %>
    <tr>
        <td  class="label">JBrowse:</td>
        <td align="left">
            <% if( fu.mapPosIsValid(md) ){ %>
            <a href="https://rgd.mcw.edu/jbrowse?data=data_rn7_2&loc=<%=fu.getJBrowseLoc(md)%>&tracks=AQTLS">View Region in Genome Browser (JBrowse)</a>
            <% } %>
        </td>
    </tr>
    <tr>
        <td class="label">Model</td>
        <td><div style="width:750px; align:left;">
            <iframe id="jbrowseMini" style="border: 1px solid black" width="660"></iframe>
        </div></td>
    </tr>
    <script>
        $(document).ready(function() {
            document.getElementById('jbrowseMini').src = '<%=jbUrl%>';
        });
    </script>
    <% } %>


</table>
<br>

<%@ include file="../sectionFooter.jsp"%>
