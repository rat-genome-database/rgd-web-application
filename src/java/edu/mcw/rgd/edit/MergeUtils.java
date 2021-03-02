package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.process.Utils;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

public class MergeUtils {

    public static void insertAliases(List<Alias> aliases) throws Exception {

        // are there any aliases to insert?
        if( !aliases.isEmpty() ) {
            AliasDAO aliasDAO = new AliasDAO();
            aliasDAO.insertAliases(aliases);
        }
    }

    public static void commitRgdIdHistory(RgdId idFrom, RgdId idTo) throws Exception {

        int rgdIdFrom = idFrom.getRgdId();
        int rgdIdTo = idTo.getRgdId();
        RGDManagementDAO dao = new RGDManagementDAO();
        int rgdId = dao.getRgdIdFromHistory(rgdIdFrom);
        if( rgdId!=rgdIdTo )
            dao.recordIdHistory(rgdIdFrom, rgdIdTo);
        dao.retire(idFrom);

        dao.updateLastModifiedDate(rgdIdFrom);
        dao.updateLastModifiedDate(rgdIdTo);
    }

    public static void commitNomen(List<NomenclatureEvent> nomenEvents, int rgdIdTo, String toolName) throws Exception {

        if( !nomenEvents.isEmpty() ) {

            NomenclatureDAO dao = new NomenclatureDAO();

            for( NomenclatureEvent event: nomenEvents ) {

                event.setRgdId(rgdIdTo);

                String notes = "created by "+toolName+" from RGD ID "+event.getRgdId();
                if( event.getNotes()==null )
                    event.setNotes(notes);
                else
                    event.setNotes(event.getNotes()+"; "+notes);

                dao.createNomenEvent(event);
            }
        }
    }

    public static void commitAnnots(List<Annotation> annots, Identifiable toObj) throws Exception {

        if( !annots.isEmpty() ) {

            AnnotationDAO dao = new AnnotationDAO();

            for( Annotation ann: annots) {

                ann.setAnnotatedObjectRgdId(toObj.getRgdId());
                ann.setObjectName(((ObjectWithName)toObj).getName());
                ann.setObjectSymbol(((ObjectWithSymbol)toObj).getSymbol());
                int annInRgdKey = dao.getAnnotationKey(ann);
                if( annInRgdKey==0 ) {
                    dao.insertAnnotation(ann);
                }
            }
        }
    }

    public static void commitXdbIds(List<XdbId> xdbIds, int rgdIdTo, String toolName) throws Exception {

        if( !xdbIds.isEmpty() ) {

            XdbIdDAO dao = new XdbIdDAO();

            for( XdbId obj: xdbIds ) {

                obj.setRgdId(rgdIdTo);

                String notes = "created by "+toolName+" from RGD ID "+obj.getRgdId();
                if( obj.getNotes()==null )
                    obj.setNotes(notes);
                else if( !obj.getNotes().contains(notes) ) {
                    obj.setNotes(obj.getNotes()+"; "+notes);
                }

                obj.setCreationDate(new Date());
                obj.setModificationDate(new Date());
            }

            dao.insertXdbs(xdbIds);
        }
    }


    // compare by unique key, except annotation object rgd id
    public static int compareTo(Annotation a1, Annotation a2) {

        int r = Utils.intsCompareTo(a1.getRefRgdId(), a2.getRefRgdId());
        if( r!=0 )
            return r;
        r = Utils.stringsCompareTo(a1.getTermAcc(), a2.getTermAcc());
        if( r!=0 )
            return r;
        r = Utils.stringsCompareTo(a1.getXrefSource(), a2.getXrefSource());
        if( r!=0 )
            return r;
        r = Utils.stringsCompareTo(a1.getQualifier(), a2.getQualifier());
        if( r!=0 )
            return r;
        r = Utils.stringsCompareTo(a1.getWithInfo(), a2.getWithInfo());
        if( r!=0 )
            return r;
        r = Utils.stringsCompareTo(a1.getEvidence(), a2.getEvidence());
        return r;
    }

    // compare by unique key, except rgd id
    public static int compareTo(XdbId x1, XdbId x2) {

        int r = x1.getXdbKey() - x2.getXdbKey();
        if( r!=0 )
            return r;
        r = Utils.stringsCompareTo(x1.getAccId(), x2.getAccId());
        return r;
    }

    public static int compareTo(NomenclatureEvent e1, NomenclatureEvent e2) {

        int r = Utils.stringsCompareTo(e1.getNomenStatusType(), e2.getNomenStatusType());
        if( r!=0 )
            return r;
        r = Utils.stringsCompareTo(e1.getDesc(), e2.getDesc());
        if( r!=0 )
            return r;
        r = Utils.stringsCompareTo(e1.getSymbol(), e2.getSymbol());
        if( r!=0 )
            return r;
        r = Utils.stringsCompareTo(e1.getName(), e2.getName());
        if( r!=0 )
            return r;
        r = Utils.stringsCompareTo(e1.getPreviousSymbol(), e2.getPreviousSymbol());
        if( r!=0 )
            return r;
        r = Utils.stringsCompareTo(e1.getPreviousName(), e2.getPreviousName());
        if( r!=0 )
            return r;
        // compare year, month and day of event date
        r = compareDateTo(e1.getEventDate(), e2.getEventDate());
        return r;
    }

    public static int compareTo(Alias a1, Alias a2) {

        int r = Utils.stringsCompareToIgnoreCase(a1.getTypeName(), a2.getTypeName());
        if( r!=0 )
            return r;
        r = Utils.stringsCompareToIgnoreCase(a1.getValue(), a2.getValue());
        return r;
    }

    public static int compareDateTo(Date d1, Date d2) {
        int r = d1.getYear() - d2.getYear();
        if( r!=0 )
            return r;
        r = d1.getMonth() - d2.getMonth();
        if( r!=0 )
            return r;
        r = d1.getDay() - d2.getDay();
        return r;
    }

    public static String printDate(Date dt) {

        return _dateFormat.format(dt);
    }
    public static String printDate() {

        return printDate(new Date());
    }
    static SimpleDateFormat _dateFormat = new SimpleDateFormat("yyyy-MM-dd");

}
