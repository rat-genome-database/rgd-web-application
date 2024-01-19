package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.HTMLTableReportStrategy;
import edu.mcw.rgd.reporting.Link;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;

import java.util.*;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Dec 6, 2010
 */
public class AnnotationFormatter {

    OntologyXDAO odao = null;

    public String buildTable(List<String> records, int columns) {

        int rowCount = (int) Math.ceil(records.size() / columns) + 1;

        StringBuilder table = new StringBuilder("<table class=\"annotationTable\" width='95%' border=0><tr>");

        for (int i = 0; i < records.size(); i++) {
            String str = records.get(i);

            if (i == 0) {
                table.append("<td valign='top'><table>");
            } else if ((i % rowCount == 0)) {
                table.append("</table></td><td valign='top'><table>");
            }

            table.append(str);

        }
        table.append("</table></td></tr></table>");

        return table.toString();

    }

    public String createGridFormatAnnotations(List<Annotation> annotationList, int objectId, int columns) throws Exception {

        List<String> records = new ArrayList<String>();

        String evidence = "";
        String termAcc = "";
        String annotatedRgdId = "";
        String term = "";
        int refRgdId=0;
        // by default, CHEBI annots link to new tabular report
        // other annots link to default list-like report
        String annotUrl = null;

        for (Annotation a : annotationList) {

            // compute url based on first term on the list
            if (annotUrl == null) {
                if (!a.getTermAcc().startsWith("CHEBI")) {
                    annotUrl = "/rgdweb/report/annotation/main.html";
                } else {
                    annotUrl = "/rgdweb/report/annotation/table.html";
                }
            }

            if (a.getTermAcc().equals(termAcc)) {
                // same term -- combine evidence codes
                if (!evidence.contains(a.getEvidence())) {
                    evidence += "," + a.getEvidence();
                }
            } else {

                // pathway diagram icon, if applicable
                String pwStr = "";
                if( a.getAspect().equals("W") ) {
                    boolean pwTermHasDiagram = hasPathwayDiagram(a.getTermAcc());
                    if( pwTermHasDiagram ) {
                        pwStr = "&nbsp;<a href=\"/rgdweb/pathway/pathwayRecord.html?acc_id="+a.getTermAcc()+"\" class=\"diaglnk\" title=\"view interactive pathway diagram\"></a>";
                    }
                }

                if (!term.equals("") && objectId != refRgdId) {
                    records.add("<tr>" +
                            "<td><a href=\"" + annotUrl + "?term=" + termAcc + "&id=" + annotatedRgdId + "\">" + term +
                            " </a>"+pwStr+"<span style=\"font-size:10px;\">&nbsp;(" + evidence + ")</span></td></tr>");
                } else if(!term.equals("")){
                    records.add("<tr>" +
                            "<td><a href=\"" + annotUrl + "?term=" + termAcc + "&id=" + refRgdId + "\">" + term +
                            " </a>"+pwStr+"<span style=\"font-size:10px;\">&nbsp;(" + evidence + ")</span></td></tr>");
                }
                termAcc = a.getTermAcc();
                annotatedRgdId = a.getAnnotatedObjectRgdId() + "";
                term = a.getTerm();
                evidence = a.getEvidence();
                refRgdId = a.getRefRgdId();

            }
        }

        if(objectId != refRgdId) {
            records.add("<tr>" +
                    "<td><a href=\"" + annotUrl + "?term=" + termAcc + "&id=" + annotatedRgdId + "\">" + term +
                    " </a><span style=\"font-size:10px;\">&nbsp;(" + evidence + ")</span></td></tr>");
        }
        else records.add("<tr>" +
                "<td><a href=\"" + annotUrl + "?term=" + termAcc + "&id=" + refRgdId + "\">" + term +
                " </a><span style=\"font-size:10px;\">&nbsp;(" + evidence + ")</span></td></tr>");
        return this.buildTable(records, columns);
    }

    public String createGridFormatAnnotationsTable(List<Annotation> annotationList) throws Exception {
        return createGridFormatAnnotationsTable(annotationList, "RGD");

    }

    public static boolean compare(String str1, String str2) {
        return (str1 == null ? str2 == null : str1.equals(str2));
    }

    boolean hasPathwayDiagram( String termAcc ) {
        if( odao == null ) {
            odao = new OntologyXDAO();
        }
        TermWithStats t = odao.getTermWithStatsCached(termAcc);
        return t.getDiagramCount(0) != 0;
    }

    public String createGridFormatAnnotationsTable(List<Annotation> annotationList, String site) throws Exception {

        // by default, CHEBI annots link to new tabular report
        // other annots link to default list-like report
        String annotUrl = null;

        Report report = new Report();

        Record rec = new Record();
        rec.append("Term");
        rec.append("Qualifier");
        rec.append("Evidence");
        rec.append("With");
        rec.append("Reference");
        rec.append("Notes");
        rec.append("Source");
        rec.append("Original Reference(s)");

        report.append(rec);

        Map<Integer,List> index = new HashMap<>();

        //Find the annotations that are same with multiple references.
        for(int i = 0; i < annotationList.size(); i++){
            Annotation current = annotationList.get(i);
            List val = new ArrayList<>();

            for(int j = 0; j < annotationList.size(); j++) {
                if(i != j){
                    Annotation a = annotationList.get(j);

                    if(a.getTerm().equalsIgnoreCase(current.getTerm()) &&
                       a.getEvidence().equalsIgnoreCase(current.getEvidence())){

                        if(compare(a.getQualifier(),current.getQualifier()) && compare(a.getWithInfo(),current.getWithInfo())
                                && compare(a.getNotes(),current.getNotes()) && compare(a.getXrefSource(),current.getXrefSource())) {
                            val.add(j);
                        }
                    }
                }

            }
            if(val.size() != 0) {
                index.put(i, val);
            }
        }

        List repeat = new ArrayList<>();
        for (int i = 0;i < annotationList.size() ; i++) {

            //Check for annotations with multiple references and remove them from display to avoid duplicate rows
            if (repeat.size() == 0 || !repeat.contains(i)) {
                Annotation a = annotationList.get(i);

                rec = new Record();

                // compute url based on first term on the list
                if (annotUrl == null) {
                    if (!a.getTermAcc().startsWith("CHEBI")) {
                        annotUrl = "/rgdweb/report/annotation/main.html";
                    } else {
                        annotUrl = "/rgdweb/report/annotation/table.html";
                    }
                }

                String termString = "<a href='" + annotUrl + "?term=" + a.getTermAcc() + "&id=" + a.getAnnotatedObjectRgdId() + "'>" + a.getTerm() + " </a>";
                // pathway diagram icon, if applicable
                if( a.getAspect().equals("W") ) {
                    boolean pwTermHasDiagram = hasPathwayDiagram(a.getTermAcc());
                    if( pwTermHasDiagram ) {
                        termString += "&nbsp;<a href=\"/rgdweb/pathway/pathwayRecord.html?acc_id="+a.getTermAcc()+"\" class=\"diaglnk\" title=\"view interactive pathway diagram\"></a>";
                    }
                }

                rec.append(termString);

                if (a.getQualifier() == null) {
                    rec.append("&nbsp;");
                } else {
                    rec.append(a.getQualifier());
                }
                rec.append(a.getEvidence());

                if (a.getWithInfo() == null) {
                    rec.append("&nbsp;");
                } else {
                    if(a.getRgdObjectKey() == 5){
                        rec.append(formatWithInfo(a.getWithInfo(),a));
                    }else{
                        rec.append(formatXdbUrlsShort(a.getWithInfo(), a));
                    }
                }

                if (!index.keySet().contains(i)) {
                    if (a.getRefRgdId() != null && a.getRefRgdId() > 0) {
                        rec.append("<a href='" + Link.ref(a.getRefRgdId()) + "' title='show reference'>" + a.getRefRgdId() + "</a>");
                    } else {
                        rec.append("&nbsp;");
                    }
                } else {
                    List<Integer> values = index.get(i);
                    String link = "<a href='" + Link.ref(a.getRefRgdId()) + "' title='show reference'>" + a.getRefRgdId() + "</a>";
                    repeat.addAll(values);
                    for (int j : values) {
                        Annotation current = annotationList.get(j);
                        link += "; <a href='" + Link.ref(current.getRefRgdId()) + "' title='show reference'>" + current.getRefRgdId() + "</a>";
                    }

                    rec.append(link);
                }


                // notes: some could be as big as 4k of text; every sentence ends with "; ",
                //  we display only first sentence followed by "..." link
                if( a.getNotes()==null ) {
                    rec.append("&nbsp;");
                }
                else {
                    rec.append(formatXdbUrlsShort(a.getNotes(), a));
                }

                rec.append(a.getDataSrc());

                if (a.getXrefSource() == null) {
                    rec.append("&nbsp;");
                } else {
                    rec.append(formatXdbUrlsShort(a.getXrefSource(), a));
                }

                report.append(rec);
            }
        }

        return new HTMLTableReportStrategy().format(report);
    }

    public static String formatWithInfo(String info, Annotation a) throws Exception{
        try {
            String[] multiInfos = info.split("(,\\b)|\\b,|\\b\\s|([|;])");
            String[] separator = Arrays.stream(info.split("[^,|]")).filter(e -> e.trim().length() > 0).toArray(String[]::new);
            String infoField = "";

            for (int i = 0; i < multiInfos.length; i++){
                infoField+=formatXdbUrl(multiInfos[i],a.getRgdObjectKey());
                if (separator.length>0 && i < multiInfos.length-1){
                    if (separator[i].equals("|"))
                        infoField+=" or ";
                    else if (separator[i].equals(","))
                        infoField+=" and ";
                }
            }
            return infoField;
        }
        catch (Exception e){
            return info;
        }
    }

    public static String formatXdbUrls(String info, int objectKey) throws Exception {

        try {
            info = info.replaceAll("[()]", "");
            String[] multipleInfos = info.split("(,\\b)|\\b,|\\b\\s|([|;])");
            String infoField="";
            for(String inf: multipleInfos) {
                if( !infoField.isEmpty() ) {
                    infoField += " ";
                }
                infoField += formatXdbUrl(inf, objectKey);
            }
            return infoField;
        } catch (Exception e) {
            return info;
        }
    }

    // show at most 2 links; if there are more than two, show the first one followed by link 'more ...' leading to detail page
    public static String formatXdbUrlsShort(String info, Annotation a) throws Exception {

        if( info==null ) {
            return "";
        }

        int objectKey = a.getRgdObjectKey();
        if( Utils.stringsAreEqualIgnoreCase(a.getDataSrc(), "ClinVar") ) {
            // see comments in ClinVar pipeline annotator
            if( a.getSpeciesTypeKey()==SpeciesType.HUMAN )
                objectKey = RgdId.OBJECT_KEY_VARIANTS; // ClinVar gene annotations derived from variant annotations
            else if( a.getSpeciesTypeKey()==SpeciesType.MOUSE ||  a.getSpeciesTypeKey()==SpeciesType.RAT )
                objectKey = RgdId.OBJECT_KEY_GENES;
            else
                objectKey = 0; // determine the object type by querying the db
        }
        if(a.getAspect().equalsIgnoreCase("P")//GO
                || a.getAspect().equalsIgnoreCase("C")//GO
                || a.getAspect().equalsIgnoreCase("F")//GO
                || (a.getAspect().equalsIgnoreCase("H") && !a.getDataSrc().equalsIgnoreCase("RGD"))//HP
                || a.getAspect().equalsIgnoreCase("N"))//MP

            {
            info = info.replaceAll("[()]", "");
        }

        String[] multipleInfos;
        if(!info.contains("|") && !info.contains("UniProt")){
            multipleInfos = info.split("(,\\b)|\\b,|([|;])");
        }else{
            multipleInfos = info.split("(,\\b)|\\b,|\\b\\s|([|;])");
        }
        String infoField;
        if( multipleInfos.length==1 ) {
            infoField = formatXdbUrl(multipleInfos[0], objectKey);
        }
        else if( multipleInfos.length==2 ) {
            infoField = formatXdbUrl(multipleInfos[0], objectKey)+" and "+ formatXdbUrl(multipleInfos[1], objectKey);
        } else {
            infoField = formatXdbUrl(multipleInfos[0], objectKey)+makeGeneTermAnnotLink(a.getAnnotatedObjectRgdId(), a.getTermAcc(), "pmore");
        }
        return infoField;
    }

    static String formatXdbUrl(String info, int objectKey) throws Exception {

        String uri = null;
        String accId = "";
        int colonPos = info.indexOf(":");
        if( colonPos<=0 ) {
            return info;
        }
        OntologyXDAO odao = new OntologyXDAO();
        String dbName = info.substring(0, colonPos).trim();
        if(dbName.equalsIgnoreCase("MGI")){
            accId = info.substring(colonPos+1).contains("MGI") ? info.substring(colonPos+1) : "MGI:" + info.substring(colonPos+1);
        }else{
            accId = info.substring(colonPos+1);
        };

        switch(dbName) {
            case "RGD":
                try {
                    RGDManagementDAO managementDAO = new RGDManagementDAO();
                    int withRgdId = Integer.parseInt(info.substring(4));
                    String symbol = "";
                    Speciated withObj = (Speciated) managementDAO.getObject(withRgdId);

                    if( withObj==null ) {
                        uri = "/rgdweb/search/search.html?term="+withRgdId;
                    }else if (withObj instanceof Gene) {
                        Gene g = (Gene) withObj;
                        symbol = g.getSymbol();
                        uri = Link.gene(withRgdId);
                    }else if (withObj instanceof SSLP) {
                        SSLP s = (SSLP) withObj;
                        symbol = s.getName();
                        uri = Link.marker(withRgdId);
                    }else if (withObj instanceof QTL) {
                        QTL q = (QTL) withObj;
                        symbol = q.getSymbol();
                        uri = Link.qtl(withRgdId);
                    }else {
                        uri = Link.it(withRgdId);
                    }

                    if( withObj!=null ) {
                        uri = "<a href='" + uri + "'>" + symbol + " (" + SpeciesType.getTaxonomicName(withObj.getSpeciesTypeKey()) + ")</a>";
                    } else {
                        uri = "<a href='" + uri + "'>" + symbol + "</a>";
                    }
//                    uri = Link.it(Integer.parseInt(info.substring(4)), objectKey);
//                    uri = "<a href='" + uri + "'>" + info + "</a>";
                }catch(Exception e) {
                    uri = null;
                }
                break;
            case "UniProtKB":
                uri = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_UNIPROT).getALink(accId, info);
                break;
            case "InterPro":
                uri = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_INTERPRO).getALink(accId, info);
                break;
            case "PANTHER":
                uri = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_PANTHER).getALink(accId, info);
                break;
            case "Ensembl":
            case "ensembl":
                if( accId.startsWith("ENSRNOP") ) {
                    uri = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_ENSEMBL_PROTEIN).getALink(accId, info, SpeciesType.RAT);
                } else if( accId.startsWith("ENSMUSP") ) {
                    uri = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_ENSEMBL_PROTEIN).getALink(accId, info, SpeciesType.MOUSE);
                }
                break;
            case "SP_KW":
            case "UniProtKB-KW":
                uri = "<a href='http://www.uniprot.org/keywords/"+accId+"'>" + info + "</a>";
                break;
            case "PMID":
                uri = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_PUBMED).getALink(accId, info);
                break;
            case "OMIM":
                uri = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_OMIM).getALink(accId, info);
                break;
            case "ORPHA":
                uri = XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_ORPHANET).getALink(accId, info);
                break;
            case "REF_RGD_ID":
                uri = "<a href=\""+Link.ref(Integer.parseInt(accId))+"\">"+info+"</a>";
                break;

            // AGR genes
            case "MGI": // handle weirdness MGI:MGI:97751
                uri = XDBIndex.getInstance().getXDB(5).getALink(accId, info);
                break;
            case "SGD":
            case "WB":
            case "FB":
            case "ZFIN":
                uri = XDBIndex.getInstance().getXDB(63).getALink(info, info);
                break;
            case "XCO":
            case "CHEBI":
                String termAcc = info.trim();
                Term t = odao.getTermByAccId(termAcc);
                if( t!=null ) {
                    uri = "<a href=\"/rgdweb/ontology/annot.html?acc_id=" + termAcc + "\">" + t.getTerm() + "</a>";
                } else {
                    uri = "<a href=\"/rgdweb/ontology/annot.html?acc_id=" + termAcc + "\">" + termAcc + "</a>";
                }
                break;
        }

        return uri==null ? info : uri;
    }

    public String createGridFormatAnnotatedObjects(List<Annotation> annotationList, int columns) throws Exception {

        List<String> records = new ArrayList<>();

        for (Annotation a : annotationList) {

            String objSymbol = Utils.NVL(a.getObjectSymbol(), "NA");
            String objName = Utils.NVL(a.getObjectName(), "NA");

            records.add("<tr>" +
                    "<td><a href=\"" + Link.it(a.getAnnotatedObjectRgdId(), a.getRgdObjectKey()) + "\" class='geneList" + a.getSpeciesTypeKey() + "'>" + objSymbol +
                    " </a><span style=\"font-size:10px;\">&nbsp;(" + objName + ")</span></td></tr>");
        }

        return this.buildTable(records, columns);
    }

    /**
     * if id is a pubmed id, create a link to NCBI pubmed article;
     * else if id is a REF_RGD_ID, create a link to RGD reference report page;
     * otherwise just show the link
     */
    static public String makeRefLink(String id) throws Exception {
        if (id.startsWith("PMID:")) {
            return XDBIndex.getInstance().getXDB(XdbId.XDB_KEY_PUBMED).getALink(id.substring(5), id);
        }
        else if( id.startsWith("REF_RGD_ID:") ) {
            return "<a href=\""+Link.ref(Integer.parseInt(id.substring(11)))+"\">"+id+"</a>";
        }
        else {
            return id;
        }
    }

    static String makeGeneTermAnnotLink(int rgdId, String termAcc, String aclass) {

        String text = aclass.equals("imore") ? "&nbsp;&nbsp;&nbsp;" : "more ...";
        String str = " <a class=\"" + aclass + "\" href=\"/rgdweb/report/annotation/table.html?id=" + rgdId;
        str += "&term=" + termAcc +  "\">" + text + "</a>";
        return str;
    }

    /**
     * return a subset of annotations matching given aspect
     *
     * @param annotationList list of annotations
     * @param aspect         aspect
     * @return a subset of annotations matching given aspect; could be empty list
     */
    public List<Annotation> filterList(List<Annotation> annotationList, String aspect) {

        List<Annotation> returnList = new ArrayList<Annotation>();
        for (Annotation annot : annotationList) {
            if (annot.getAspect().equalsIgnoreCase(aspect)) {
                returnList.add(annot);
            }
        }

        // sort by term, case insensitive
        Collections.sort(returnList, new Comparator<Annotation>() {
            public int compare(Annotation o1, Annotation o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            }
        });
        return returnList;
    }

}
