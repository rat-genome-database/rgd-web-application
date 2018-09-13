<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%@ page import="java.util.*" %>
<%@ page import="org.jcp.xml.dsig.internal.dom.*" %>
<%@ include file="../sectionHeader.jsp"%>
<%
    String objType = "{unknown object type}";
    RgdId rgdId = managementDAO.getRgdId2(obj.getRgdId());
    if( rgdId!=null ) {
        objType = rgdId.getObjectTypeName();
    }
%>

<table width="100%" border="0" style="background-color: rgb(249, 249, 249)">
    <tr><td colspan="2"><h3><%=objType%> : <%=obj.getSymbol()%>&nbsp;<%=obj.getName()!=null?"("+obj.getName()+")":""%>&nbsp;<%=SpeciesType.getTaxonomicName(obj.getSpeciesTypeKey())%></h3></td></tr>
    <tr>
        <td class="label">Symbol:</td>
        <td><%=obj.getSymbol()%></td>
    </tr>
    <tr>
        <td class="label">Name:</td>
        <td><%=fu.chkNull(obj.getName())%></td>
    </tr>
    <tr>
        <td class="label">Type:</td>
        <td><%=fu.chkNull(obj.getObjectType())%></td>
    </tr>
    <tr>
        <td class="label">Description:</td>
        <td><%=fu.chkNullNA(obj.getDescription())%></td>
    </tr>
    <%
        List<Alias> aliases = aliasDAO.getAliases(obj.getRgdId());
        if (aliases.size() > 0 ) {
    %>
    <tr>
        <td class="label" valign="top">Also&nbsp;known&nbsp;as:</td>
        <td>
            <%
                int printedAliases = 0;
                for (Alias a : aliases) {
                    if( printedAliases>0 ) {// don't print ';' before 1st alias printed
                        out.print("; ");
                    }
                    out.print(a.getValue());
                    printedAliases++;
                }
            %>
        </td>
    </tr>
    <% } %>
    <%@ include file="../markerFor.jsp"%>
    <%@ include file="relatedGenes.jsp"%>
    <tr>
        <td class="label">Source:</td>
        <td><%=obj.getSource()%><%
            if( obj.getSource()!=null && obj.getSource().equals("MPromDB") ) {
                out.print(" (Mammalian Promoter Database, <a href='http://mpromdb.wistar.upenn.edu/'>http://mpromdb.wistar.upenn.edu/</a>)");
            }
            else
            if( obj.getSource()!=null && obj.getSource().startsWith("EPD") ) {
                out.print(" (Eukaryotic Promoter Database, <a href='http://epd.vital-it.ch//'>http://epd.vital-it.ch/</a>)");
            }
        %></td>
    </tr>
    <tr>
        <td class="label">SO Acc Id:</td>
        <td>
        <% if( obj.getSoAccId()==null ) { %>
            N/A
        <% } else { %>
            <a href="<%=Link.ontView(obj.getSoAccId())%>" title="click to go to sequence ontology"><%=obj.getSoAccId()%></a>
        <% } %>
        </td>
    </tr>
    <%
        List<Association> altPromoters = associationDAO.getAssociationsForMasterRgdId(obj.getRgdId(), "alternative_promoter");
        if( !altPromoters.isEmpty() ) {
            String altInfo = altPromoters.get(0).getAssocSubType();
    %><tr>
        <td class="label" valign="top">Alternative Promoters:</td>
        <td><%=altInfo%>; see also
            <% for( Association assoc: altPromoters ) {
            GenomicElement altPromoter = geDAO.getElement(assoc.getDetailRgdId());
            if( altPromoter==null )
                continue;
            %><a href="<%=Link.ge(altPromoter.getRgdId())%>"><%=altPromoter.getSymbol()%></a> &nbsp;
        <%}
        %></td>
    </tr><%
        }
    %>

    <%
        List<Association> neighPromoters = associationDAO.getAssociationsForMasterRgdId(obj.getRgdId(), "neighboring_promoter");
        if( !neighPromoters.isEmpty() ) {
    %><tr>
        <td class="label" valign="top">Neighboring Promoters:</td>
        <td><% for( Association assoc: neighPromoters ) {
            GenomicElement neighPromoter = geDAO.getElement(assoc.getDetailRgdId());
            if( neighPromoter==null )
                continue;
            %><a href="<%=Link.ge(neighPromoter.getRgdId())%>"><%=neighPromoter.getSymbol()%></a> &nbsp;
        <%}
        %></td>
    </tr><%
        }
    %>

    <%  List<ExpressionData> attrs = geDAO.getExpressionData(obj.getRgdId());
        if( !attrs.isEmpty() ) {
            Set<String> tissueSet = new java.util.TreeSet<String>();
            Set<String> transcriptSet = new java.util.TreeSet<String>();
            Set<String> expDataSet = new java.util.TreeSet<String>();
            Set<String> regulationSet = new java.util.TreeSet<String>();

            for( ExpressionData attr: attrs ) {
                // combine tissue
                if( attr.getTissue()!=null )
                    tissueSet.add(attr.getTissue());

                // combine transcripts
                String trs = attr.getTranscripts();
                if( trs!=null ) {
                    for( String tr: trs.split("[,]") ) {
                        transcriptSet.add(tr);
                    }
                }

                // combine exp data
                if( attr.getExperimentMethods()!=null )
                    expDataSet.add(attr.getExperimentMethods());

                // combine regulation data
                if( attr.getRegulation()!=null )
                    regulationSet.add(attr.getRegulation());
            }
            String tissues = Utils.concatenate(tissueSet, ", &nbsp; ");
            String transcripts = Utils.concatenate(transcriptSet, ", &nbsp; ");
            String expMethods = Utils.concatenate(expDataSet, ", &nbsp; ");
            String regulation = Utils.concatenate(regulationSet, "; &nbsp; ");
            if( !tissues.isEmpty() ) {
            %><tr>
                <td class="label" valign="top">Tissues & Cell Lines:</td>
                <td><%=tissues%></td>
            </tr>
            <% }
                if( !transcripts.isEmpty() ) {%>
            <tr>
                <td class="label" valign="top">Transcripts:</td>
                <td><%=transcripts%></td>
            </tr>
            <% }
                if( !expMethods.isEmpty() ) {%>
            <tr>
                <td class="label" valign="top">Experiment Methods:</td>
                <td><%=expMethods%></td>
            </tr>
            <% }
                if( !regulation.isEmpty() ) {%>
            <tr>
                <td class="label" valign="top">Regulation:</td>
                <td><%=regulation%></td>
            </tr>
         <% }
        } %>

    <tr>
        <td class="label">Position</td>
        <td><%=MapDataFormatter.buildTable(obj.getRgdId(),obj.getSpeciesTypeKey())%></td>
    </tr>
</table>
<br>



<%@ include file="../sectionFooter.jsp"%>




