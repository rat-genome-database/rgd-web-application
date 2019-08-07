package edu.mcw.rgd.ontology;

import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.report.AnnotationFormatter;
import edu.mcw.rgd.reporting.Link;

import java.util.*;


/**
 * @author mtutaj
 * @since Apr 4, 2011
 * similar to Annotation class, but it has only the properties used by the view
 */
public class OntAnnotation  {

    private int rgdId; // gene rgd id
    private String symbol; // gene symbol
    private String name; // gene name
    private String evidenceWithInfo;
    private String evidence;
    private String reference; // <a> link fully setup
    private String chr = "";
    private String startPos = "";
    private String stopPos = "";
    private String qualifier;
    private int rgdObjectKey;
    private int speciesTypeKey;
    private String JBrowseLink; // link to JBrowse -- customized by species
    private String dataSource;
    private String xrefSource = "";
    private String notes;

    private Set<String> xrefs = new TreeSet<String>(new Comparator<String>() {
        @Override
        public int compare(String o1, String o2) {
            if( o1.startsWith("PMID:") && o2.startsWith("PMID:") ) {
                int i1 = Integer.parseInt(o1.substring(5));
                int i2 = Integer.parseInt(o2.substring(5));
                return i1-i2;
            }
            return o1.compareTo(o2);
        }
    });

    public void addXrefs(String xrefString) throws Exception {
        int oldXrefCount = xrefs.size();
        if( !Utils.isStringEmpty(xrefString) ) {
            for( String xref: xrefString.split("[\\|]") ) {
                xrefs.add(xref);
            }
        }
        if( xrefs.size()>oldXrefCount ) {
            setXrefSource(Utils.concatenate(xrefs,"|"));
        }
    }

    public int getRgdId() {
        return rgdId;
    }

    public void setRgdId(int rgdId) {
        this.rgdId = rgdId;
    }

    public String getSymbol() {
        return symbol;
    }

    public void setSymbol(String symbol) {
        this.symbol = symbol;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setEvidenceWithInfo(String evidence, String withInfo) throws Exception {

        this.evidence = evidence;

        // load the evidence
        StringBuilder buf = new StringBuilder(evidence);

        if( withInfo!=null && withInfo.length() > 0 ) {
            // if WITH-INFO is present, add the contents of WITH-INFO;
            buf.append(" (from ").append(AnnotationFormatter.formatXdbUrls(withInfo, rgdObjectKey)).append(")");
        }

        evidenceWithInfo = buf.toString();
    }

    public String getEvidenceWithInfo() {
        return evidenceWithInfo;
    }

    public String getReference() {
        return reference;
    }

    public void setRefRgdId(int refRgdId) throws Exception {
        if( refRgdId>0 ) {
            this.reference = "<a href=\""+ Link.ref(refRgdId)+"\">RGD:"+refRgdId+"</a>";
        }
        else
            this.reference = "";
    }

    public void setRefRgdIds(String refRgdIds) throws Exception {
        if( refRgdIds!=null ) {
            this.reference = "";
            List<Integer> rgdIds = new ArrayList<Integer>();
            for(String refRgdId: refRgdIds.split(", ") ) {
                int rgdId = 0;
                try {
                    rgdId = Integer.parseInt(refRgdId);
                } catch( NumberFormatException e) {

                }
                if( rgdId!=0 ) {
                    rgdIds.add(rgdId);
                }
            }
            Collections.sort(rgdIds);
            for(int refRgdId: rgdIds) {
                this.reference += "<a href=\""+ Link.ref(refRgdId)+"\">RGD:"+refRgdId+"</a><br>";
            }
        }
        else
            this.reference = "";
    }

    public void setReference(String reference) throws Exception {
        this.reference = reference==null ? "" : reference;
    }

    public String getChr() {
        return chr;
    }

    public void setChr(String chr) {
        this.chr = chr;
    }

    public String getStartPos() {
        return startPos;
    }

    public void setStartPos(String startPos) {
        this.startPos = startPos;
    }

    public String getStopPos() {
        return stopPos;
    }

    public void setStopPos(String stopPos) {
        this.stopPos = stopPos;
    }

    public String getQualifier() {
        return qualifier;
    }

    public void setQualifier(String qualifier) {
        this.qualifier = qualifier;
    }

    public int getRgdObjectKey() {
        return this.rgdObjectKey;
    }

    public void setRgdObjectKey(int rgdObjectKey) {
        this.rgdObjectKey = rgdObjectKey;
    }

    public boolean isGene() {
        return this.rgdObjectKey== RgdId.OBJECT_KEY_GENES;
    }

    public boolean isQtl() {
        return this.rgdObjectKey== RgdId.OBJECT_KEY_QTLS;
    }

    public boolean isStrain() {
        return this.rgdObjectKey== RgdId.OBJECT_KEY_STRAINS;
    }

    public String getRgdObjectName() {
        return this.rgdObjectKey== RgdId.OBJECT_KEY_GENES ? "gene" :
            this.rgdObjectKey== RgdId.OBJECT_KEY_QTLS ? "qtl" :
            this.rgdObjectKey== RgdId.OBJECT_KEY_STRAINS ? "strain" :
            this.rgdObjectKey== RgdId.OBJECT_KEY_VARIANTS ? "variant" :
            "unknown";
    }

    public int getSpeciesTypeKey() {
        return speciesTypeKey;
    }

    public void setSpeciesTypeKey(int speciesTypeKey) {
        this.speciesTypeKey = speciesTypeKey;
    }

    public String getJBrowseLink() {
        return JBrowseLink;
    }

    public void setJBrowseLink(String JBrowseLink) {
        this.JBrowseLink = JBrowseLink;
    }

    public String getEvidence() {
        return evidence;
    }

    public void setEvidence(String evidence) {
        this.evidence = evidence;
    }

    public String getDataSource() {
        return dataSource;
    }

    public void setDataSource(String dataSource) {
        this.dataSource = dataSource;
    }

    public String getXrefSource() {
        return xrefSource;
    }

    public void setXrefSource(String xrefSource) throws Exception {
        this.xrefSource = AnnotationFormatter.formatXdbUrls(xrefSource, rgdObjectKey);
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes==null ? "" : notes;
    }
}
