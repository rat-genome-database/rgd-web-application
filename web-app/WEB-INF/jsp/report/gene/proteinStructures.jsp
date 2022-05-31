<%@ include file="../sectionHeader.jsp"%>
<%
List<ProteinStructure> protStructs = new ProteinStructureDAO().getProteinStructuresForGene(obj.getRgdId());
if( !protStructs.isEmpty() ) {

    boolean showVideoCol = false;
    int alphaFoldFragments = 0;
    for (ProteinStructure ps: protStructs) {
        if( !Utils.isStringEmpty(ps.getVideoUrl()) ) {
            showVideoCol = true;
        }
        if( ps.getModeller().equals("AlphaFold") ) {
            alphaFoldFragments++;
        }
    }

    Collections.sort(protStructs, new Comparator<ProteinStructure>() {
        @Override
        public int compare(ProteinStructure o1, ProteinStructure o2) {
            int start1 = 0, end1 = 0;
            int start2 = 0, end2 = 0;
            String range1 = o1.getProteinAaRange();
            if( range1!=null ) {
                int dashPos = range1.indexOf('-');
                if( dashPos>0 ) {
                    start1 = Integer.parseInt(range1.substring(0, dashPos).trim());
                    end1 = Integer.parseInt(range1.substring(dashPos+1).trim());
                }
            }
            String range2 = o2.getProteinAaRange();
            if( range2!=null ) {
                int dashPos = range2.indexOf('-');
                if( dashPos>0 ) {
                    start2 = Integer.parseInt(range2.substring(0, dashPos).trim());
                    end2 = Integer.parseInt(range2.substring(dashPos+1).trim());
                }
            }

            int r = start1 - start2;
            if( r!=0 ) {
                return r;
            }
            return end1 - end2;
        }
    });
%>

<div class="light-table-border">
    <div class="sectionHeading" id="proteinStructures">Protein Structures</div>
<table cellpadding="5" cellspacing="1" class="sortable" id="protStruTab">
    <tr class="headerRow">
        <td title="click to sort by name">Name</td>
        <td title="click to sort by modeller">Modeler</td>
        <td title="click to sort by protein">Protein Id</td>
        <td title="click to sort by aminoacid range">AA Range</td>
        <td>Protein Structure</td>
        <% if( showVideoCol ) { %>
        <td>Video</td>
        <% } %>
    </tr>
<%
    String rowClass="oddRow";
    for (ProteinStructure ps: protStructs) {

        // alternate rows {even,odd}
        if( rowClass.equals("oddRow") )
            rowClass = "evenRow";
        else
            rowClass = "oddRow";

        String videoUrl="&nbsp;";
        if( ps.getVideoUrl()!=null ) {
            videoUrl = "<A HREF=\""+ps.getVideoUrl()+"\">view video</A>";
        }
%>
    <tr class="<%=rowClass%>">
        <td><%=ps.getName()%></td>
        <td><%=ps.getModeller()%></td>
        <td><%=ps.getProteinAccId()%></td>
        <td><%=ps.getProteinAaRange()%></td>
        <% if( ps.getModeller().equals("AlphaFold") ) {
                if( alphaFoldFragments==1 ) {%>
            <td><a href="https://alphafold.com/entry/<%=ps.getProteinAccId()%>">view protein structure</a></td>
            <% } else { // protein with multiple fragments are not available at AlphaFold website; thus we use RGD jmol browser to show them %>
            <td><a href="/rgdweb/jsmol/alphafold.jsp?p=<%=ps.getName()%>&species=<%=SpeciesType.getShortName(obj.getSpeciesTypeKey())%>">view protein structure</a></td>
            <% } %>
        <% } else { %>
        <td><a href="/rgdweb/jsmol/rgd.jsp?d=<%=ps.getName()%>">view protein structure</a></td>
        <% } %>
        <% if( showVideoCol ) { %>
        <td><%=videoUrl%></td>
        <% } %>
    </tr>
    <% } %>
</table>
<br>
</div>
<% } %>

<%@ include file="../sectionFooter.jsp"%>
