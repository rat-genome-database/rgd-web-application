package edu.mcw.rgd.report;

import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.Strain;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.HTMLTableReportStrategy;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.RgdContext;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * @author mtutaj
 * @since 4/3/12
 * used by GeneTermAnnotationsController to pass data to its jsp page(s)
 */
public class GeneTermAnnotationsBean {

    private RgdId rgdId;
    private String accId;
    private Object rgdObject;
    private Term term;
    private String CasRN; // chemical CasRN if available
    private String MeshID; // chemical MESH id if available
    private List<Annotation> annotations;

    public RgdId getRgdId() {
        return rgdId;
    }

    public void setRgdId(RgdId rgdId) {
        this.rgdId = rgdId;
    }

    public String getAccId() {
        return accId;
    }

    public void setAccId(String accId) {
        this.accId = accId;
    }

    public Object getRgdObject() {
        return rgdObject;
    }

    public void setRgdObject(Object rgdObject) {
        this.rgdObject = rgdObject;
    }

    public Term getTerm() {
        return term;
    }

    public void setTerm(Term term) {
        this.term = term;
    }

    public String getCasRN() {
        return CasRN;
    }

    public void setCasRN(String casRN) {
        CasRN = casRN;
    }

    public String getMeshID() {
        return MeshID;
    }

    public void setMeshID(String meshID) {
        MeshID = meshID;
    }

    public List<Annotation> getAnnotations() {
        return annotations;
    }

    public void setAnnotations(List<Annotation> annotations) {
        this.annotations = annotations;
    }

    public String getAnnotTable(String site) throws Exception {

        Report report = new Report();

        Record rec = new Record();
        rec.append("Object Symbol");
        rec.append("Qualifier");
        rec.append("Evidence");
        rec.append("With");
        rec.append("Reference");
        rec.append("Source");
        rec.append("Notes");
        rec.append("Original Reference(s)");

        boolean userIsCurator = RgdContext.isCurator();
        if( userIsCurator )
            rec.append("Curation");

        report.append(rec);

        HTMLTableReportStrategy strategy = new HTMLTableReportStrategy();
        strategy.setTdProperties(new String[]{
                "valign='top'", // qualifier
                "valign='top'", // evidence
                "valign='top'", // with
                "valign='top'", // reference
                "valign='top'", // source
                "valign='top'", // notes
                "valign='top'", // orig refer
        });

        // sort annotations by evidence,qualifier,with_info,reference,notes
        Collections.sort(getAnnotations(), new Comparator<Annotation>() {
            public int compare(Annotation o1, Annotation o2) {

                // SORT ORDER
                // 1. data_source: 'RGD','CTD',...
                // 2. evidence
                // 3. with_info
                // 4. xrefs
                int r = getDataSourceRank(o1.getDataSrc()) - getDataSourceRank(o2.getDataSrc());
                if( r!=0 ) {
                    return r;
                }
                r = o1.getEvidence().compareTo(o2.getEvidence());
                if( r!=0 )
                    return r;
                r = Utils.stringsCompareTo(o1.getQualifier(), o2.getQualifier());
                if( r!=0 )
                    return r;
                r = Utils.stringsCompareTo(o1.getWithInfo(), o2.getWithInfo());
                if( r!=0 )
                    return r;
                r = Utils.intsCompareTo(o1.getRefRgdId(), o2.getRefRgdId());
                if( r!=0 )
                    return r;
                r = Utils.stringsCompareToIgnoreCase(o1.getNotes(), o2.getNotes());
                if( r!=0 )
                    return r;
                return Utils.stringsCompareTo(o1.getXrefSource(), o2.getXrefSource());
            }

            int getDataSourceRank(String dataSrc) {
                switch(dataSrc) {
                    case "RGD": return -10;
                    case "OMIM": return -9;
                    case "CTD": return -8;
                    default: return Character.codePointAt(dataSrc, 0);
                }
            }
        });

        for (Annotation a : getAnnotations()) {

            rec = new Record();

            if(a.getObjectSymbol() == null) {
                rec.append("&nbsp;");
            }else {
                rec.append(a.getObjectSymbol());
            }
            if (a.getQualifier() == null) {
                rec.append("&nbsp;");
            } else {
                rec.append(a.getQualifier());
            }

            rec.append(a.getEvidence());

            if (a.getWithInfo() == null) {
                rec.append("&nbsp;");
            } else {
                rec.append(AnnotationFormatter.formatWithInfo(a.getWithInfo(),a));


            }

            if( a.getRefRgdId()!=null && a.getRefRgdId()>0 ) {
                rec.append("<a href='" + Link.ref(a.getRefRgdId()) + "' title='show reference'>" + a.getRefRgdId() + "</a>");
            }
            else {
                rec.append("&nbsp;");
            }

            rec.append(site.equals("RGD")? a.getDataSrc() : a.getDataSrc().replaceAll("RGD", site));

            if (a.getNotes() == null) {
                rec.append("&nbsp;");
            } else {
                if(a.getAspect().equalsIgnoreCase("P")//GO
                        || a.getAspect().equalsIgnoreCase("C")//GO
                        || a.getAspect().equalsIgnoreCase("F")//GO
                        || (a.getAspect().equalsIgnoreCase("H") && !a.getDataSrc().equalsIgnoreCase("RGD"))//HP
                        || a.getAspect().equalsIgnoreCase("N"))//MP

                {
                    rec.append(AnnotationFormatter.formatXdbUrls(a.getNotes(), a.getRgdObjectKey()).replace("; ", "<br><br>")+"<br><br>");
                } else{
                    rec.append(a.getNotes());
                }

            }

            if (a.getXrefSource() == null) {
                rec.append("&nbsp;");
            } else {

                rec.append(AnnotationFormatter.formatXdbUrls(a.getXrefSource(), a.getRgdObjectKey()));
            }

            if( userIsCurator ) {
                rec.append("<a href=\"/rgdweb/curation/edit/editAnnotation.html?rgdId="+a.getKey()+"\">(Edit Me!)</a>");
            }

            report.append(rec);
        }

        return strategy.format(report);
    }
}
