package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.web.FormUtility;

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

    /**
     * Everything the section shows about one promoter, gathered before anything is rendered -
     * the layout depends on which fields turn out to be the same across all of a gene's
     * promoters, so nothing can be written until they have all been read.
     */
    static class Row {
        GenomicElement promoter;
        List<MapData> mapData;

        String assembly = "";   // assembly name, when every location agrees on one
        String position = "";   // chrN:start-stop (strand), one entry per location

        String neighbors = "";  // neighboring promoters, as links
        String tissues = "", transcripts = "", expMethods = "", regulation = "";

        String notes() {
            return Utils.defaultString(promoter.getNotes());
        }
    }

    /**
     * The Promoters section: one row per promoter in a single table, with the fields that are the
     * same for every promoter of the gene lifted into a line under the heading.
     *
     * <p>This used to be one label/value table per promoter, ten rows apiece, each carrying its own
     * nested position table. In the data that is almost entirely repetition: a gene has one or two
     * promoters, and across them the type, SO accession, source, description and experiment methods
     * are identical, so only the id, name, position and RGD id actually differ. The "alternative
     * promoters" row was pure cross-reference - promoter A naming B and B naming A - and says
     * nothing once both are rows of the same table, so it is gone.
     *
     * <p>A field is only hoisted into the header line when every promoter agrees on it; when they
     * differ it becomes a column instead, so a gene with promoters from two sources loses nothing.
     * The uncommon fields - notes, neighboring promoters, and the expression details - hang under
     * their promoter as a detail line, and only when they are present.
     */
    public String buildTable(int rgdId, int speciesTypeKey) throws Exception{

        final java.util.Map<GenomicElement, List<MapData>> mapPromoterToLoc = new HashMap<GenomicElement, List<MapData>>();
        List<GenomicElement> promoters = new ArrayList<GenomicElement>();
        if( !loadData(rgdId, mapPromoterToLoc, promoters) )
            return null;

        List<Row> rows = new ArrayList<Row>();
        for( GenomicElement promoter: promoters ) {
            Row row = new Row();
            row.promoter = promoter;
            row.mapData = mapPromoterToLoc.get(promoter);
            fillPosition(row);
            row.neighbors = promoterLinks(
                    associationDAO.getAssociationsForMasterRgdId(promoter.getRgdId(), "neighboring_promoter"));
            fillExpressionData(row);
            rows.add(row);
        }

        return render(rows);
    }

    /**
     * The section markup for a set of promoters. Split from the loading above so the layout
     * decisions - which fields are shared, which become columns - can be exercised without a
     * database behind them.
     */
    static String render(List<Row> rows) {

        // a field goes in the header line when every promoter agrees, and becomes a column when
        // they do not; with a single promoter everything is trivially shared, which is the point
        boolean sameType = allSame(rows, "type");
        boolean sameSo = allSame(rows, "so");
        boolean sameSource = allSame(rows, "source");
        boolean sameDescription = allSame(rows, "description");
        boolean sameMethods = allSame(rows, "methods");
        boolean sameAssembly = allSame(rows, "assembly");

        StringBuilder buf = new StringBuilder(1000);

        // ---- the line of shared fields, under the section heading
        StringBuilder shared = new StringBuilder();
        if( sameType )        appendShared(shared, field(rows.get(0), "type"), "promoter type", null, null);
        if( sameSo )          appendShared(shared, field(rows.get(0), "so"), "Sequence Ontology accession", null, null);
        if( sameSource )      appendSharedSource(shared, field(rows.get(0), "source"));
        if( sameMethods )     appendShared(shared, field(rows.get(0), "methods"), "experiment methods", null, null);
        if( sameDescription ) appendShared(shared, field(rows.get(0), "description"), "description", null, null);
        if( shared.length()>0 ) {
            buf.append("<div class=\"promoterMeta\">").append(shared).append("</div>\n");
        }

        // ---- the table
        buf.append("<table border=\"0\" class=\"rgdCompactTable rgdCompactTable--fit\">\n<thead>\n<tr>");
        buf.append("<th>Promoter ID</th>");
        buf.append("<th>Name</th>");
        buf.append("<th>Position");
        if( sameAssembly && !field(rows.get(0), "assembly").isEmpty() ) {
            buf.append(" (").append(field(rows.get(0), "assembly")).append(")");
        }
        buf.append("</th>");
        if( !sameType )        buf.append("<th>Type</th>");
        if( !sameSo )          buf.append("<th>SO acc id</th>");
        if( !sameSource )      buf.append("<th>Source</th>");
        if( !sameMethods )     buf.append("<th>Experiment methods</th>");
        if( !sameDescription ) buf.append("<th>Description</th>");
        buf.append("<th>RGD ID</th>");
        buf.append("</tr>\n</thead>\n<tbody>\n");

        int columnCount = 4
                + (sameType ? 0 : 1) + (sameSo ? 0 : 1) + (sameSource ? 0 : 1)
                + (sameMethods ? 0 : 1) + (sameDescription ? 0 : 1);

        for( Row row: rows ) {
            String reportLink = Link.ge(row.promoter.getRgdId());

            buf.append("<tr>");
            buf.append("<td class=\"rgdCellStrong rgdCellNowrap\"><a href=\"").append(reportLink).append("\">")
                    .append(Utils.defaultString(row.promoter.getSymbol())).append("</a></td>");
            buf.append("<td>").append(Utils.defaultString(row.promoter.getName())).append("</td>");
            buf.append("<td class=\"rgdCellNowrap\">").append(
                    sameAssembly ? row.position : prefixAssembly(row)).append("</td>");
            if( !sameType )        buf.append("<td>").append(field(row, "type")).append("</td>");
            if( !sameSo )          buf.append("<td>").append(field(row, "so")).append("</td>");
            if( !sameSource )      buf.append("<td>").append(field(row, "source")).append("</td>");
            if( !sameMethods )     buf.append("<td>").append(field(row, "methods")).append("</td>");
            if( !sameDescription ) buf.append("<td>").append(field(row, "description")).append("</td>");
            buf.append("<td class=\"rgdCellMuted rgdCellNowrap\"><a href=\"").append(reportLink).append("\">")
                    .append(row.promoter.getRgdId()).append("</a></td>");
            buf.append("</tr>\n");

            appendDetailRow(buf, row, columnCount);
        }

        buf.append("</tbody>\n</table>\n");
        return buf.toString();
    }

    /** the fields that only some promoters carry, on a line under the promoter they belong to */
    static void appendDetailRow(StringBuilder buf, Row row, int columnCount) {

        StringBuilder detail = new StringBuilder();
        appendDetail(detail, "Notes", row.notes());
        appendDetail(detail, "Neighboring promoters", row.neighbors);
        appendDetail(detail, "Tissues &amp; cell lines", row.tissues);
        appendDetail(detail, "Transcripts", row.transcripts);
        appendDetail(detail, "Regulation", row.regulation);
        if( detail.length()==0 ) {
            return;
        }

        buf.append("<tr class=\"promoterDetail\"><td colspan=\"").append(columnCount).append("\">")
                .append(detail).append("</td></tr>\n");
    }

    static void appendDetail(StringBuilder buf, String label, String value) {
        if( Utils.isStringEmpty(value) ) {
            return;
        }
        if( buf.length()>0 ) {
            buf.append(" <span class=\"promoterDetailSep\">&middot;</span> ");
        }
        buf.append("<span class=\"promoterDetailLabel\">").append(label).append("</span> ").append(value);
    }

    /** one shared field on the line under the heading */
    static void appendShared(StringBuilder buf, String value, String title, String url, String urlTitle) {
        if( Utils.isStringEmpty(value) ) {
            return;
        }
        if( buf.length()>0 ) {
            buf.append(" <span class=\"promoterMetaSep\">&middot;</span> ");
        }
        if( url==null ) {
            buf.append("<span title=\"").append(title).append("\">").append(value).append("</span>");
        } else {
            buf.append("<a href=\"").append(url).append("\" title=\"").append(urlTitle).append("\">")
                    .append(value).append("</a>");
        }
    }

    /** the source, linked to the database it names where we know the url */
    static void appendSharedSource(StringBuilder buf, String source) {
        if( Utils.isStringEmpty(source) ) {
            return;
        }
        if( source.equals("MPromDB") ) {
            appendShared(buf, source, null, "http://mpromdb.wistar.upenn.edu/", "Mammalian Promoter Database");
        } else if( source.startsWith("EPD") ) {
            appendShared(buf, source, null, "http://epd.vital-it.ch/", "Eukaryotic Promoter Database");
        } else {
            appendShared(buf, source, "source", null, null);
        }
    }

    /** chrN:start-stop (strand) for every location the promoter has, and the assembly they are on */
    void fillPosition(Row row) throws Exception {

        if( row.mapData==null || row.mapData.isEmpty() ) {
            return;
        }

        StringBuilder pos = new StringBuilder();
        Set<String> assemblies = new LinkedHashSet<String>();

        for( MapData md: row.mapData ) {
            edu.mcw.rgd.datamodel.Map map = MapManager.getInstance().getMap(md.getMapKey());
            assemblies.add(map==null ? String.valueOf(md.getMapKey()) : Utils.defaultString(map.getName()));

            if( pos.length()>0 ) {
                pos.append("<br>");
            }
            pos.append("chr").append(Utils.defaultString(md.getChromosome())).append(":")
                    .append(FormUtility.formatThousands(md.getStartPos()))
                    .append("-")
                    .append(FormUtility.formatThousands(md.getStopPos()));
            if( md.getStrand()!=null ) {
                pos.append(" (").append(md.getStrand()).append(")");
            }
        }

        row.position = pos.toString();
        // only name the assembly in the column header when there is exactly one to name
        row.assembly = assemblies.size()==1 ? assemblies.iterator().next() : "";
    }

    /** the position with its assembly spelled out, for when the column header cannot carry it */
    static String prefixAssembly(Row row) {
        if( row.position.isEmpty() || row.assembly.isEmpty() ) {
            return row.position;
        }
        return "<span class=\"rgdCellMuted\">" + row.assembly + "</span> " + row.position;
    }

    /** the promoters an association list points at, as a comma separated run of links */
    String promoterLinks(List<Association> associations) throws Exception {
        StringBuilder links = new StringBuilder();
        for( Association assoc: associations ) {
            GenomicElement el = geDAO.getElement(assoc.getDetailRgdId());
            if( el==null )
                continue;
            if( links.length()>0 ) {
                links.append(", ");
            }
            links.append("<a href=\"").append(Link.ge(el.getRgdId())).append("\">")
                    .append(el.getSymbol()).append("</a>");
        }
        return links.toString();
    }

    void fillExpressionData(Row row) throws Exception {

        List<ExpressionData> attrs = geDAO.getExpressionData(row.promoter.getRgdId());
        if( attrs.isEmpty() ) {
            return;
        }

        Set<String> tissueSet = new TreeSet<String>();
        Set<String> transcriptSet = new TreeSet<String>();
        Set<String> expDataSet = new TreeSet<String>();
        Set<String> regulationSet = new TreeSet<String>();

        for( ExpressionData attr: attrs ) {
            if( attr.getTissue()!=null )
                tissueSet.add(attr.getTissue());

            String trs = attr.getTranscripts();
            if( trs!=null ) {
                Collections.addAll(transcriptSet, trs.split("[,]"));
            }

            if( attr.getExperimentMethods()!=null )
                expDataSet.add(attr.getExperimentMethods());

            if( attr.getRegulation()!=null )
                regulationSet.add(attr.getRegulation());
        }

        // ", &nbsp; " between values padded every list out; a plain comma is enough
        row.tissues = Utils.concatenate(tissueSet, ", ");
        row.transcripts = Utils.concatenate(transcriptSet, ", ");
        row.expMethods = Utils.concatenate(expDataSet, ", ");
        row.regulation = Utils.concatenate(regulationSet, "; ");
    }

    /** the value of one hoistable field, so the "is it the same everywhere" test has one source */
    static String field(Row row, String name) {
        if( name.equals("type") )        return Utils.defaultString(row.promoter.getObjectType());
        if( name.equals("so") )          return Utils.defaultString(row.promoter.getSoAccId());
        if( name.equals("source") )      return Utils.defaultString(row.promoter.getSource());
        if( name.equals("description") ) return Utils.defaultString(row.promoter.getDescription());
        if( name.equals("methods") )     return Utils.defaultString(row.expMethods);
        if( name.equals("assembly") )    return Utils.defaultString(row.assembly);
        return "";
    }

    /** true when every promoter carries the same value for this field - what makes it hoistable */
    static boolean allSame(List<Row> rows, String name) {
        String first = field(rows.get(0), name);
        for( Row row: rows ) {
            if( !Utils.stringsAreEqual(field(row, name), first) ) {
                return false;
            }
        }
        return true;
    }
}
