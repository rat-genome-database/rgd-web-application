<%@ page import="java.util.List" %>
<%@ page import="edu.mcw.rgd.datamodel.Strain" %>
<%@ page import="edu.mcw.rgd.datamodel.QTL" %>
<%@ page import="edu.mcw.rgd.reporting.Link" %>
<%-- to be included as a line in info.jsp --%>
<%
    List<Strain> mstrains = strainDAO.isMarkerFor(obj.getRgdId());
    List<QTL> mqtls = qtlDAO.isMarkerFor(obj.getRgdId());
    List<Gene> mgenes = null;
    if( objectType.equals("marker") ) {
        mgenes = associationDAO.getGeneAssociationsBySslp(obj.getKey());
    }
    else {
        mgenes = new ArrayList<Gene>(0);
    }

    if( mstrains.size()+mqtls.size()+mgenes.size() > 0 ) { %>
        <tr>
            <td class="label">Is Marker For:</td>
            <td><%
                if( mstrains.size()>0 ) {
                    out.print("<b>Strains:</b> &nbsp; ");
                    int count=0;
                    for( Strain astrain: mstrains ) { %>
                <%
                    ++count;
                    boolean isLastStrain = (count==mstrains.size());
                %>
                <a href="<%=Link.strain(astrain.getRgdId())%>"><%=astrain.getSymbol()%></a><%=!isLastStrain?" ; ":""%><%
                        }
                        out.println("<br>");
                    }

        if( mqtls.size()>0 ) {
            out.print("<b>QTLs:</b> &nbsp; ");
            for( QTL aqtl: mqtls ) { %>
                <a href="<%=Link.qtl(aqtl.getRgdId())%>"><%=aqtl.getSymbol()%></a> &nbsp;<%
            }
            out.println("<br>");
        }

        if( mgenes.size()>0 ) {
            out.print("<b>Genes:</b> &nbsp; ");
            for( Gene agene: mgenes ) { %>
                <a href="<%=Link.gene(agene.getRgdId())%>"><%=agene.getSymbol()%></a> &nbsp;<%
            }
            out.println("<br>");
         }%>
            </td>
        </tr>
    <%}%>
