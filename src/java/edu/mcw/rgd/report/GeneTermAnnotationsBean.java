package edu.mcw.rgd.report;

import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.ontology.OntAnnotation;
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
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 4/3/12
 * Time: 2:57 PM
 * <p>used by GeneTermAnnotationsController to pass data to its jsp page(s)</p>
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

        // sort annotations by evidence,qualifier,with_info,reference,source,notes
        Collections.sort(getAnnotations(), new Comparator<Annotation>() {
            public int compare(Annotation o1, Annotation o2) {
                int r = o1.getEvidence().compareTo(o2.getEvidence());
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
                r = Utils.stringsCompareTo(o1.getDataSrc(), o2.getDataSrc());
                if( r!=0 )
                    return r;
                r = Utils.stringsCompareToIgnoreCase(o1.getNotes(), o2.getNotes());
                if( r!=0 )
                    return r;
                return Utils.stringsCompareTo(o1.getXrefSource(), o2.getXrefSource());
            }
        });

        for (Annotation a : getAnnotations()) {

            rec = new Record();
            if (a.getQualifier() == null) {
                rec.append("&nbsp;");
            } else {
                rec.append(a.getQualifier());
            }

            rec.append(a.getEvidence());

            if (a.getWithInfo() == null) {
                rec.append("&nbsp;");
            } else {
                String withInfo = site.equals("RGD")? a.getWithInfo() : a.getWithInfo().replaceAll("RGD", site);

                try {
                    //System.out.println("adding with Info:\n");
                    if(withInfo.contains("|")){
                        String[] multipleInfos = withInfo.split("\\|");
                        String withInfoField="";
                        for(String info:multipleInfos){
                            withInfoField += "<a href='" + Link.it(info) + "'>" + info + "</a> ";
                        }
                        rec.append(withInfoField);
                    }else{
                        rec.append("<a href='" + Link.it(withInfo) + "'>" + withInfo + "</a>");
                    }
                } catch (Exception e) {
                    rec.append(withInfo);
                }
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
                rec.append(a.getNotes().replace("; ", "<br><br>")+"<br><br>");
            }

            if (a.getXrefSource() == null) {
                rec.append("&nbsp;");
            } else {
                rec.append(OntAnnotation.makeHyperlinks(a.getXrefSource()));
            }

            if( userIsCurator ) {
                rec.append("<a href=\"/rgdweb/curation/edit/editAnnotation.html?rgdId="+a.getKey()+"\">(Edit Me!)</a>");
            }
            report.append(rec);
        }

        return strategy.format(report);
    }
}
