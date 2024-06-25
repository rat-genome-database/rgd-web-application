package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.dao.impl.XdbIdDAO;
import edu.mcw.rgd.dao.spring.StringMapQuery;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermXRef;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.Link;

import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 4/2/13
 * Time: 12:41 PM
 * DAO utility methods to be used by report pages jsp
 */
public class DaoUtils {

    private DaoUtils() {}

    // initialization on-demand holder idiom for lazy loaded singletons
    static private class LazyHolder {
        private static final DaoUtils INSTANCE = new DaoUtils();
    }

    static public DaoUtils getInstance() {
        return LazyHolder.INSTANCE;
    }

    private AnnotationDAO annotationDAO = new AnnotationDAO();
    private OntologyXDAO ontologyDAO = new OntologyXDAO();
    private XdbIdDAO xdbIdDAO = new XdbIdDAO();
    private XdbIdRefSeqComparator xdbIdRefSeqComparator = new XdbIdRefSeqComparator();

    public List<XdbId> getExternalDbLinks(int rgdId, int speciesTypeKey) throws Exception {

        XdbId xi = new XdbId();
        xi.setRgdId(rgdId);
        List<XdbId> ei = xdbIdDAO.getXdbIds(xi, speciesTypeKey);

        // do not show PUBMED ids, KEGG pathway ids, GeneBank Nucleotides nor GeneBank Proteins not PID
        Iterator<XdbId> eiit = ei.iterator();
        while( eiit.hasNext() ) {
            XdbId xid = eiit.next();

            if (xid.getXdbKey()==XdbId.XDB_KEY_PUBMED
             || xid.getXdbKey()==XdbId.XDB_KEY_KEGGPATHWAY
             || xid.getXdbKey()==XdbId.XDB_KEY_PID
             || xid.getXdbKey()==XdbId.XDB_KEY_GENEBANKNU
             || xid.getXdbKey()==XdbId.XDB_KEY_GENEBANKPROT
             || xid.getXdbKey()==XdbId.XDB_KEY_ENSEMBL_PROTEIN
             || xid.getXdbKey()==XdbId.XDB_KEY_TRANSPOSAGEN){
                eiit.remove();
            }
        }

        Collections.sort(ei, new Comparator<XdbId>() {
            public int compare(XdbId o1, XdbId o2) {
                // first compare by xdb keys, then by accession ids
                int r = Utils.stringsCompareToIgnoreCase(o1.getXdbKeyAsString(), o2.getXdbKeyAsString());
                if (r != 0)
                    return r;
                String link1 = o1.getLinkText() == null ? o1.getAccId() : o1.getLinkText();
                String link2 = o2.getLinkText() == null ? o2.getAccId() : o2.getLinkText();
                r = Utils.stringsCompareToIgnoreCase(link1, link2);
                if (r != 0)
                    return r;
                return Utils.stringsCompareToIgnoreCase(o1.getSrcPipeline(), o2.getSrcPipeline());
            }
        });

        // merge xdb_ids having the same xdb_key and acc_id
        mergeSrcPipeline(ei);

        return ei;
    }

    public List<XdbId> getExternalDbLinksForGATool(List xdbIds, int rgdId) throws Exception {

        List<XdbId> ei = xdbIdDAO.getXdbIdsByRgdId(xdbIds, rgdId);

        Collections.sort(ei, new Comparator<XdbId>() {
            public int compare(XdbId o1, XdbId o2) {
                // pubmed ids should appear at the very end
                String xdbName1 = o1.getXdbKeyAsString();
                if( o1.getXdbKey()==XdbId.XDB_KEY_PUBMED )
                    xdbName1 = "ZZZ" + xdbName1;
                String xdbName2 = o2.getXdbKeyAsString();
                if( o2.getXdbKey()==XdbId.XDB_KEY_PUBMED )
                    xdbName2 = "ZZZ" + xdbName2;

                // first compare by xdb keys, then by accession ids
                int r = Utils.stringsCompareToIgnoreCase(xdbName1, xdbName2);
                if (r != 0)
                    return r;
                r = Utils.stringsCompareToIgnoreCase(o1.getAccId(), o2.getAccId());
                if (r != 0)
                    return r;
                return Utils.stringsCompareToIgnoreCase(o1.getSrcPipeline(), o2.getSrcPipeline());
            }
        });

        // merge xdb_ids having the same xdb_key and acc_id
        mergeSrcPipeline(ei);

        return ei;
    }

    private void mergeSrcPipeline(List<XdbId> ei) {

        if( ei.size()>1 ) {

            XdbId xidPrev = ei.get(ei.size()-1);
            for( int i=ei.size()-2; i>=0; i-- ) {
                XdbId xi = ei.get(i);
                if( xi.getXdbKey()==xidPrev.getXdbKey() &&
                    Utils.stringsAreEqualIgnoreCase(xi.getAccId(), xidPrev.getAccId())) {
                    // duplicate found -- merge SRC_PIPELINE
                    if(xidPrev.getSrcPipeline()!=null ) {
                        if( xi.getSrcPipeline()==null || xi.getSrcPipeline().isEmpty() )
                            xi.setSrcPipeline(xidPrev.getSrcPipeline());
                        else
                            xi.setSrcPipeline(xi.getSrcPipeline()+", "+xidPrev.getSrcPipeline());
                    }
                    // and drop duplicate item
                    ei.remove(i+1);
                }
                xidPrev = xi;
            }
        }
    }

    // report page, section [Sequence] subsection [Protein Sequences]
    public List<XdbId> getProteinSequences(int rgdId, int speciesTypeKey) throws Exception {

        XdbId pxi = new XdbId();
        pxi.setRgdId(rgdId);
        pxi.setXdbKey(XdbId.XDB_KEY_GENEBANKPROT);
        List<XdbId> pei = xdbIdDAO.getXdbIds(pxi, speciesTypeKey);
        pxi.setXdbKey(XdbId.XDB_KEY_ENSEMBL_PROTEIN);
        List<XdbId> ensemblProt = xdbIdDAO.getXdbIds(pxi, speciesTypeKey);
        pei.addAll(ensemblProt);

        Collections.sort(pei, xdbIdRefSeqComparator);
        return pei;
    }

    // report page, section [Sequence] subsection [Nucleotide Sequences]
    public List<XdbId> getNucleotideSequences(int rgdId, int speciesTypeKey) throws Exception {

        XdbId nxi = new XdbId();
        nxi.setRgdId(rgdId);
        nxi.setXdbKey(XdbId.XDB_KEY_GENEBANKNU);
        List<XdbId> nei = xdbIdDAO.getXdbIds(nxi, speciesTypeKey);

        Collections.sort(nei, xdbIdRefSeqComparator);
        return nei;
    }

    /**
     * show list of definition dbxrefs (list of dbxrefs is loaded from database, if it had not been loaded yet)
     * @param term Term object
     * @return formatted string of dbxrefs
     */
    public String getTermXRefs(Term term) throws Exception {

        if( term==null )
            return null;

        // are dbxrefs loaded into the term object?
        if( term.getXRefs() == null) {
            term.setXRefs(ontologyDAO.getTermXRefs(term.getAccId()));

            // sort xrefs by value
            Collections.sort(term.getXRefs(), new Comparator<TermXRef>() {
                public int compare(TermXRef o1, TermXRef o2) {
                    return Utils.stringsCompareToIgnoreCase(o1.getXrefValue(), o2.getXrefValue());
                }
            });
        }

        // build xrefs string
        String xrefs = "";
        if( !term.getXRefs().isEmpty() ) {
            StringBuilder buf = new StringBuilder();
            for( TermXRef xref: term.getXRefs() ) {
                if( buf.length()>0 )
                    buf.append(", ");

                String formattedXrefValue = Utils.NVL(xref.getXrefValue(), xref.getXrefDescription()).replace("\\:",":").replace("\\,",",");
                int colonPos = xref.getXrefValue().indexOf(':');
                if( colonPos>0 ) {
                    String xrefType = formattedXrefValue.substring(0, colonPos).toUpperCase();
                    String xrefAcc = formattedXrefValue.substring(colonPos+1);
                    if( xrefType.equals("PMID") ) {
                        // hyperlinked PMID content
                        buildHyperlink(buf, XdbId.XDB_KEY_PUBMED, xrefAcc, formattedXrefValue);
                    }
                    else if( xrefType.equals("MIM") ) {
                        // hyperlinked MIM content
                        buildHyperlink(buf, XdbId.XDB_KEY_OMIM, xrefAcc, formattedXrefValue);
                    }
                    else if( xrefType.equals("MESH") && !xrefAcc.contains(".") ) {
                        // hyperlinked MESH content
                        buildHyperlink(buf, 47, xrefAcc, formattedXrefValue);
                    }
                    else if( xrefType.equals("HTTP") || xrefType.equals("HTTPS") ) {
                        // just a hyperlink
                        buf.append("<a href=\"").append(xref.getXrefValue()).append("\">")
                                .append(xref.getXrefValue())
                                .append("</a>");
                    }
                    else { // non-hyperlinked content
                        buf.append(formattedXrefValue);
                    }
                }

                if( !Utils.isStringEmpty(xref.getXrefDescription()) ) {
                    buf.append(" \"").append(xref.getXrefDescription()).append("\"");
                }

                if( !Utils.isStringEmpty(xref.getXrefDescription()) ) {
                    buf.append(" \"").append(xref.getXrefDescription()).append("\"");
                }
            }
            xrefs = buf.toString();
        }
        return xrefs;
    }

    private void buildHyperlink(StringBuilder buf, int xdbKey, String acc, String value) throws Exception {

        buf.append("<a href=\"")
            .append(XDBIndex.getInstance().getXDB(xdbKey).getUrl())
            .append(acc).append("\">")
            .append(value)
            .append("</a>");
    }

    /**
     * build evidence link as that one shown on gene-term annotation report page
     * on the line starting with: 'The annotation has been inferred from ...'
     * @return String
     */
    public String buildEvidenceLink(String subPart, Annotation ann, RGDManagementDAO managementDAO) throws Exception {

        String link;

        if (subPart.startsWith("RGD")) {

            int withRgdId = Integer.parseInt(subPart.substring(subPart.indexOf(":") + 1, subPart.length()));

            String symbol = ann.getWithInfo();
            Speciated withObj = (Speciated) managementDAO.getObject(withRgdId);

            if( withObj==null ) {
                link = "/rgdweb/search/search.html?term="+withRgdId;
            }else if (withObj instanceof Gene) {
                Gene g = (Gene) withObj;
                symbol = g.getSymbol();
                link = Link.gene(withRgdId);
            }else if (withObj instanceof SSLP) {
                SSLP s = (SSLP) withObj;
                symbol = s.getName();
                link = Link.marker(withRgdId);
            }else if (withObj instanceof QTL) {
                QTL q = (QTL) withObj;
                symbol = q.getSymbol();
                link = Link.qtl(withRgdId);
            }else {
                link = Link.it(withRgdId);
            }

            if( withObj!=null ) {
                link = "<a href='" + link + "'>" + symbol + " (" + SpeciesType.getTaxonomicName(withObj.getSpeciesTypeKey()) + ")</a>";
            } else {
                link = "<a href='" + link + "'>" + symbol + "</a>";
            }

            if( EvidenceCode.isManualInOtherSpecies(ann.getEvidence()) ) { // evidence codes ISS ISA ISM ISO
                link += getEvidenceCodes(withRgdId, ann.getTermAcc(), ann.getRefRgdId());
            }
        }else{
            link = subPart;
        }
        return link;
    }

    private String getEvidenceCodes(int rgdId, String termAcc, int refRgdId) throws Exception {

        Set<String> evidences = null;
        for( Annotation annot: annotationDAO.getAnnotations(rgdId, termAcc) ) {
            // refRgdId must match
            if( annot.getRefRgdId()==null || annot.getRefRgdId()!=refRgdId )
                continue;
            // evidence code must not be manually curated in other species
            if( EvidenceCode.isManualInOtherSpecies(annot.getEvidence()) )
                continue;

            // add evidence to set of evidences
            if( evidences==null )
                evidences = new HashSet<String>();
            evidences.add(annot.getEvidence());
        }

        // format evidences
        if( evidences==null )
            return "";
        String relatedEvidences = null;
        for( String evidence: evidences ) {
            if( relatedEvidences==null )
                relatedEvidences = " [";
            else
                relatedEvidences += ", ";

            relatedEvidences += "("+evidence+") "+EvidenceCode.getName(evidence);
        }
        relatedEvidences += "]";
        return relatedEvidences;
    }

    /**
     * return VT ontology terms annotated to given RGD object, like qtl
     * @param rgdId object rgd id
     * @throws Exception
     */
    public List<Term> getTraitTermsForObject(int rgdId) throws Exception {
        return getTermsForObject(rgdId, "V"); // 'V' - aspect for VT ontology
    }

    /**
     * return CMO ontology terms annotated to given RGD object, like qtl
     * @param rgdId object rgd id
     * @throws Exception
     */
    public List<Term> getMeasurementTermsForObject(int rgdId) throws Exception {
        return getTermsForObject(rgdId, "L"); // 'L' - aspect for CMO ontology
    }

    private List<Term> getTermsForObject(int rgdId, String aspect) throws Exception {
        List<Term> terms = new ArrayList<>();
        for( StringMapQuery.MapPair pair: annotationDAO.getAnnotationTermAccIds(rgdId, aspect) ) {
            Term term = new Term();
            term.setAccId(pair.keyValue);
            term.setTerm(pair.stringValue);
            terms.add(term);
        }
        if( terms.size()>1 ) {
            Collections.sort(terms, new Comparator<Term>() {
                @Override
                public int compare(Term o1, Term o2) {
                    return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
                }
            });
        }
        return terms;
    }

    class XdbIdRefSeqComparator implements Comparator<XdbId>{

        // nucleotide/protein refseqs (NM_, NR_, XM_ or XR_ or NP_, XP_) go first; then the rest
        public int compare(XdbId o1, XdbId o2) {
            // refseq nucleotides go first
            int o1IsRefSeq = (o1.getAccId()!=null && o1.getAccId().length()>3 && o1.getAccId().charAt(2)=='_') ? 1 : 0;
            int o2IsRefSeq = (o2.getAccId()!=null && o2.getAccId().length()>3 && o2.getAccId().charAt(2)=='_') ? 1 : 0;
            int r = o2IsRefSeq - o1IsRefSeq;
            if( r!=0 )
                return r;
            // other nucleotides/proteins go later
            return Utils.defaultString(o1.getAccId()).compareTo(Utils.defaultString(o2.getAccId()));
        }
    }
}
