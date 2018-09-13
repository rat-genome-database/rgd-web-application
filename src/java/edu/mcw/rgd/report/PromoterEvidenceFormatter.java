package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.Link;

import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Jun 23, 2012
 * Time: 11:32:44 AM
 */
public class PromoterEvidenceFormatter {

    static PromoterEvidenceFormatter _instance = null;
    private PromoterEvidenceFormatter() {}

    AssociationDAO associationDAO = new AssociationDAO();
    GenomicElementDAO geDAO = new GenomicElementDAO();
    MapDAO mapDAO = new MapDAO();

    static public synchronized PromoterEvidenceFormatter getInstance() {
        if( _instance==null )
            _instance = new PromoterEvidenceFormatter();
        return _instance;
    }

    boolean loadData(int rgdId,
                     final java.util.Map<GenomicElement, List<MapData>> mapPromoterToLoc,
                     List<GenomicElement> promoters) throws Exception {

        List<Association> associations = associationDAO.getAssociationsForDetailRgdId(rgdId, "promoter_to_gene");

        // for every promoter, load its map data
        for( Association assoc: associations ) {
            GenomicElement promoter = geDAO.getElement(assoc.getMasterRgdId());
            if( promoter==null )
                continue;
            List<MapData> mapData = mapDAO.getMapData(promoter.getRgdId());
            mapPromoterToLoc.put(promoter, mapData);
            promoters.add(promoter);
        }

        // sort promoters by their position
        Collections.sort(promoters, new Comparator<GenomicElement>() {
            public int compare(GenomicElement o1, GenomicElement o2) {
                List<MapData> mapData1 = mapPromoterToLoc.get(o1);
                List<MapData> mapData2 = mapPromoterToLoc.get(o2);
                if (mapData1 == null || mapData1.isEmpty())
                    return 1;
                if (mapData2 == null || mapData2.isEmpty())
                    return -1;
                MapData md1 = mapData1.get(0);
                MapData md2 = mapData2.get(0);
                return Utils.intsCompareTo(md1.getStartPos(), md2.getStartPos());
            }
        });

        return !mapPromoterToLoc.isEmpty();
    }

    public String buildTable(int rgdId, int speciesTypeKey) throws Exception{

        final java.util.Map<GenomicElement, List<MapData>> mapPromoterToLoc = new HashMap<GenomicElement, List<MapData>>();
        List<GenomicElement> promoters = new ArrayList<GenomicElement>();
        if( !loadData(rgdId, mapPromoterToLoc, promoters) )
            return null;

        StringBuilder buf = new StringBuilder(1000);
        for( GenomicElement promoter: promoters ) {
            List<MapData> mapData = mapPromoterToLoc.get(promoter);

            buf.append("<table width=\"100%\" border=\"0\" style=\"background-color: rgb(249, 249, 249);padding-bottom:12px;\">\n")
                .append("<tr>")
                .append("<td class=\"label\" valign=\"top\" width=\"164\">RGD ID:</td>").append("<td><a href=\"").append(Link.ge(promoter.getRgdId())).append("\">").append(promoter.getRgdId()).append("<a/></td>")
                .append("</tr>\n");

            buf.append("<tr>");
            buf.append("<td class=\"label\" valign=\"top\">Promoter ID:</td>");
            buf.append("<td><a href=\"").append(Link.ge(promoter.getRgdId())).append("\">").append(promoter.getSymbol()).append("</a></td>");
            buf.append("</tr>\n");

            if( promoter.getObjectType()!=null ) {
                buf.append("<tr>");
                buf.append("<td class=\"label\" valign=\"top\">Type:</td>");
                buf.append("<td>").append(promoter.getObjectType()).append("</td>");
                buf.append("</tr>\n");
            }

            if( promoter.getName()!=null ) {
                buf.append("<tr>");
                buf.append("<td class=\"label\" valign=\"top\">Name:</td>");
                buf.append("<td>").append(promoter.getName()).append("</td>");
                buf.append("</tr>\n");
            }

            if( promoter.getDescription()!=null ) {
                buf.append("<tr>");
                buf.append("<td class=\"label\" valign=\"top\">Description:</td>");
                buf.append("<td>").append(promoter.getDescription()).append("</td>");
                buf.append("</tr>\n");
            }

            buf.append("<tr>");
            buf.append("<td class=\"label\" valign=\"top\">SO ACC ID:</td>");
            buf.append("<td>").append(promoter.getSoAccId()).append("</td>");
            buf.append("</tr>\n");

            buf.append("<tr>");
            buf.append("<td class=\"label\" valign=\"top\">Source:</td>");
            buf.append("<td>").append(promoter.getSource());
            if( promoter.getSource()!=null && promoter.getSource().equals("MPromDB") ) {
                buf.append(" (Mammalian Promoter Database, <a href='http://mpromdb.wistar.upenn.edu/'>http://mpromdb.wistar.upenn.edu/</a>)");
            }
            else
            if( promoter.getSource()!=null && promoter.getSource().startsWith("EPD") ) {
                buf.append(" (Eukaryotic Promoter Database, <a href='http://epd.vital-it.ch//'>http://epd.vital-it.ch/</a>)");
            }
            buf.append("</td>");
            buf.append("</tr>\n");

            if( promoter.getNotes()!=null ) {
                buf.append("<tr>");
                buf.append("<td class=\"label\" valign=\"top\">Notes:</td>");
                buf.append("<td>").append(promoter.getNotes()).append("</td>");
                buf.append("</tr>\n");
            }

            handleAltPromoters(promoter.getRgdId(), buf);
            handleNeighPromoters(promoter.getRgdId(), buf);
            handleExpressionData(promoter.getRgdId(), buf);

            buf.append("<tr>");
            buf.append("<td class=\"label\" valign=\"top\">Position:</td>");
            buf.append("<td>").append(MapDataFormatter.buildTable(speciesTypeKey, mapData)).append("</td>");
            buf.append("</tr>\n");

            buf.append("</table>\n");
        }

        return buf.toString();
    }

    void handleAltPromoters(int rgdId, StringBuilder buf) throws Exception {
        List<Association> altPromoters = associationDAO.getAssociationsForMasterRgdId(rgdId, "alternative_promoter");
        if( !altPromoters.isEmpty() ) {
            String altInfo = altPromoters.get(0).getAssocSubType();
            buf.append("<tr>");
            buf.append("<td class=\"label\" valign=\"top\">Alternative Promoters:</td>");
            buf.append("<td>").append(altInfo).append("; see also");

            for( Association assoc2: altPromoters ) {
                GenomicElement altPromoter = geDAO.getElement(assoc2.getDetailRgdId());
                if( altPromoter==null )
                    continue;
                buf.append("<a href=\"").append(Link.ge(altPromoter.getRgdId())).append("\">").append(altPromoter.getSymbol()).append("</a> &nbsp;");
            }
            buf.append("</td>");
            buf.append("</tr>\n");
        }
    }

    void handleNeighPromoters(int rgdId, StringBuilder buf) throws Exception {

        List<Association> neighPromoters = associationDAO.getAssociationsForMasterRgdId(rgdId, "neighboring_promoter");
        if( !neighPromoters.isEmpty() ) {
            buf.append("<tr>");
            buf.append("<td class=\"label\" valign=\"top\">Neighboring Promoters:</td>");
            buf.append("<td>");
            for( Association assoc2: neighPromoters ) {
                GenomicElement neighPromoter = geDAO.getElement(assoc2.getDetailRgdId());
                if( neighPromoter==null )
                    continue;
                buf.append("<a href=\"").append(Link.ge(neighPromoter.getRgdId())).append("\">").append(neighPromoter.getSymbol()).append("</a> &nbsp;");
            }
            buf.append("</td>");
            buf.append("</tr>\n");
        }
    }

    void handleExpressionData(int rgdId, StringBuilder buf) throws Exception {

        List<ExpressionData> attrs = geDAO.getExpressionData(rgdId);
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
                    Collections.addAll(transcriptSet, trs.split("[,]"));
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
                buf.append("<tr>");
                buf.append("<td class=\"label\" valign=\"top\">Tissues & Cell Lines:</td>");
                buf.append("<td>").append(tissues).append("</td>");
                buf.append("</tr>\n");
            }

            if( !transcripts.isEmpty() ) {
                buf.append("<tr>");
                buf.append("<td class=\"label\" valign=\"top\">Transcripts:</td>");
                buf.append("<td>").append(transcripts).append("</td>");
                buf.append("</tr>\n");
            }

            if( !expMethods.isEmpty() ) {
                buf.append("<tr>");
                buf.append("<td class=\"label\" valign=\"top\">Experiment Methods:</td>");
                buf.append("<td>").append(expMethods).append("</td>");
                buf.append("</tr>\n");
            }

            if( !regulation.isEmpty() ) {
                buf.append("<tr>");
                buf.append("<td class=\"label\" valign=\"top\">Regulation:</td>");
                buf.append("<td>").append(regulation).append("</td>");
                buf.append("</tr>");
            }
        }
    }
}
