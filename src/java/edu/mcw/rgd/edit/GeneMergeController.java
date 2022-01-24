package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.process.Utils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 3/19/13
 * Time: 4:08 PM
 */
public class GeneMergeController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse httpServletResponse) throws Exception {

        GeneMergeBean bean = new GeneMergeBean();

        String action = request.getParameter("action");
        boolean isPreview = action!=null && action.equals("preview");
        boolean isCommit = action!=null && action.equals("commit");

        int rgdIdFrom = Integer.parseInt(request.getParameter("rgdIdFrom"));
        int rgdIdTo = Integer.parseInt(request.getParameter("rgdIdTo"));
        String sessionObj = "gene-merge-"+rgdIdFrom+"-"+rgdIdTo;

        if( isCommit ) {
            bean = (GeneMergeBean) request.getSession().getAttribute(sessionObj);
            commitAliases(bean);
            commitNotes(bean);
            commitCuratedRef(bean);
            commitAnnots(bean);
            commitXdbIds(bean);
            commitNomen(bean);
            commitRgdIdHistory(bean);
            commitMapData(bean);

            request.getSession().removeAttribute(sessionObj);
        }
        else if( isPreview ) {
            bean = (GeneMergeBean) request.getSession().getAttribute(sessionObj);

            handleAliases(bean, request);
            handleNotes(bean);
            handleReferences(bean);
            handleAnnots(bean);
            handleXdbIds(bean);
            handleNomens(bean);
            handleMapData(bean);

        } else {

            AliasDAO aliasDAO = new AliasDAO();
            AnnotationDAO annotationDAO = new AnnotationDAO();
            AssociationDAO associationDAO = new AssociationDAO();
            RGDManagementDAO managementDAO = new RGDManagementDAO();
            GeneDAO geneDAO = associationDAO.getGeneDAO();
            NotesDAO notesDAO = new NotesDAO();
            XdbIdDAO xdbIdDAO = new XdbIdDAO();
            NomenclatureDAO nomenclatureDAO = new NomenclatureDAO();

            bean.setRgdIdFrom(managementDAO.getRgdId2(rgdIdFrom));
            bean.setRgdIdTo(managementDAO.getRgdId2(rgdIdTo));

            bean.setGeneFrom(geneDAO.getGene(rgdIdFrom));
            bean.setGeneTo(geneDAO.getGene(rgdIdTo));
            bean.setGeneTypes(geneDAO.getTypes());

            bean.getNotesInRgd().addAll(notesDAO.getNotes(rgdIdTo));
            bean.getNotesNew().addAll(notesDAO.getNotes(rgdIdFrom));

            bean.getCuratedRefInRgd().addAll(associationDAO.getReferenceAssociations(rgdIdTo));
            bean.getCuratedRefNew().addAll(associationDAO.getReferenceAssociations(rgdIdFrom));
            for( Reference ref: bean.getCuratedRefNew() ) {
                ref.setSpeciesTypeKey(-1); // artificially mark reference as coming from 'from-gene'
            }

            bean.getAliasesInRgd().addAll(aliasDAO.getAliases(rgdIdTo));
            // remove array_id aliases
            Iterator<Alias> it = bean.getAliasesInRgd().iterator();
            while( it.hasNext() ) {
                Alias alias = it.next();
                if( alias.getTypeName()!=null && alias.getTypeName().startsWith("array_id") )
                    it.remove();
            }
            bean.getAliasesNew().addAll(aliasDAO.getAliases(rgdIdFrom));
            // remove array_id aliases
            it = bean.getAliasesNew().iterator();
            while( it.hasNext() ) {
                Alias alias = it.next();
                if( alias.getTypeName()!=null && alias.getTypeName().startsWith("array_id") )
                    it.remove();
            }

            bean.getAnnotsInRgd().addAll(annotationDAO.getAnnotations(rgdIdTo));
            bean.getAnnotsNew().addAll(annotationDAO.getAnnotations(rgdIdFrom));

            XdbId filter = new XdbId();
            filter.setRgdId(rgdIdTo);
            bean.getXdbidsInRgd().addAll(xdbIdDAO.getXdbIds(filter));
            filter.setRgdId(rgdIdFrom);
            bean.getXdbidsNew().addAll(xdbIdDAO.getXdbIds(filter));

            // nomenclature
            bean.getNomenInRgd().addAll(nomenclatureDAO.getNomenclatureEvents(rgdIdTo));
            bean.getNomenNew().addAll(nomenclatureDAO.getNomenclatureEvents(rgdIdFrom));

            // map data
            MapDAO mapDAO = new MapDAO();
            bean.getMapDataInRgd().addAll(mapDAO.getMapData(rgdIdTo));
            bean.getMapDataNew().addAll(mapDAO.getMapData(rgdIdFrom));

            // save the bean named 'gene-merge-rgdIdFrom-rgdIdTo' in session
            request.getSession().setAttribute(sessionObj, bean);
        }



        String page = isPreview ? "/WEB-INF/jsp/curation/edit/geneMergePreview.jsp"
                : isCommit ? "/WEB-INF/jsp/curation/edit/geneMergeSummary.jsp"
                : "/WEB-INF/jsp/curation/edit/geneMerge.jsp";
        ModelAndView mv = new ModelAndView(page);
        mv.addObject("bean", bean);
        return mv;
    }

    void handleAliases(GeneMergeBean bean, HttpServletRequest request) throws Exception {

        // shall from-gene symbol be added as alias to to-gene?
        String param = request.getParameter("symbol");
        if( param!=null && !param.isEmpty() ) {
            Alias alias = new Alias();
            alias.setRgdId(bean.getRgdIdTo().getRgdId());
            alias.setTypeName("old_gene_symbol");
            alias.setValue(param);
            alias.setNotes("created by GeneMerge tool on "+printDate());
            bean.getAliasesNew().add(alias);
        }

        // shall from-gene name be added as alias to to-gene?
        param = request.getParameter("name");
        if( param!=null && !param.isEmpty() ) {
            Alias alias = new Alias();
            alias.setRgdId(bean.getRgdIdTo().getRgdId());
            alias.setTypeName("old_gene_name");
            alias.setValue(param);
            alias.setNotes("created by GeneMerge tool on "+printDate());
            bean.getAliasesNew().add(alias);
        }

        // remove duplicates
        Iterator<Alias> it = bean.getAliasesNew().iterator();
        while( it.hasNext() ) {
            Alias alias = it.next();
            for( Alias alias2: bean.getAliasesInRgd() ) {
                if( compareTo(alias, alias2)==0 ) {
                    bean.getAliasesNewIgnored().add(alias);
                    it.remove();
                    break;
                }
            }
        }
    }

    // determine which of the new aliases are already in RGD and move them to ignored list
    void handleNotes(GeneMergeBean bean) throws Exception {

        // remove duplicates
        Iterator<Note> it = bean.getNotesNew().iterator();
        while( it.hasNext() ) {
            Note note = it.next();
            for( Note note2: bean.getNotesInRgd() ) {
                // notes are the same if they have the same type and text
                if( Utils.stringsAreEqualIgnoreCase(note.getNotes(), note2.getNotes()) &&
                    Utils.stringsAreEqualIgnoreCase(note.getNotesTypeName(), note2.getNotesTypeName()) ) {
                    // same note is in rgd
                    bean.getNotesNewIgnored().add(note);
                    it.remove();
                    break;
                }
            }
        }
    }

    // determine which of the new references are already in RGD and move them to ignored list
    void handleReferences(GeneMergeBean bean) throws Exception {

        Iterator<Reference> it = bean.getCuratedRefNew().iterator();
        while( it.hasNext() ) {
            Reference ref = it.next();
            for( Reference ref2: bean.getCuratedRefInRgd() ) {
                // curated references are the same if they have the same rgd id
                if( ref.getRgdId()==ref2.getRgdId() ) {
                    // duplicate curated reference
                    bean.getCuratedRefIgnored().add(ref);
                    it.remove();
                    break;
                }
            }
        }
    }

    // determine which of the new annotations are already in RGD and move them to ignored list
    void handleAnnots(GeneMergeBean bean) throws Exception {

        Iterator<Annotation> it = bean.getAnnotsNew().iterator();
        while( it.hasNext() ) {
            Annotation ann = it.next();
            for( Annotation ann2: bean.getAnnotsInRgd() ) {
                // annotations
                if( compareTo(ann, ann2)==0 ) {
                    // duplicate annotation
                    bean.getAnnotsIgnored().add(ann);
                    it.remove();
                    break;
                }
            }
        }
    }

    void handleXdbIds(GeneMergeBean bean) throws Exception {

        Iterator<XdbId> it = bean.getXdbidsNew().iterator();
        while( it.hasNext() ) {
            XdbId xdbId = it.next();

            // all Gene Ids coming from 'from-gene' should be ignored
            if( xdbId.getXdbKey()==XdbId.XDB_KEY_NCBI_GENE ) {
                bean.getXdbidsIgnored().add(xdbId);
                it.remove();
                continue;
            }

            for( XdbId xdbId2: bean.getXdbidsInRgd() ) {

                if( compareTo(xdbId, xdbId2)==0 ) {
                    bean.getXdbidsIgnored().add(xdbId);
                    it.remove();
                    break;
                }
            }
        }
    }

    void handleNomens(GeneMergeBean bean) throws Exception {

        // create nomenclature event for 'to-gene'
        NomenclatureEvent ev = new NomenclatureEvent();
        ev.setDesc("Data Merged");
        ev.setEventDate(new Date());
        ev.setName(bean.getGeneTo().getName());
        ev.setNomenStatusType("PROVISIONAL");
        ev.setNotes("GeneMerge from RGD ID " + bean.getRgdIdFrom().getRgdId() + " to RGD ID " + bean.getRgdIdTo().getRgdId());
        ev.setOriginalRGDId(bean.getRgdIdFrom().getRgdId());
        ev.setPreviousName(bean.getGeneFrom().getName());
        ev.setPreviousSymbol(bean.getGeneFrom().getSymbol());
        ev.setRefKey("9333");
        ev.setRgdId(bean.getRgdIdTo().getRgdId());
        ev.setSymbol(bean.getGeneTo().getSymbol());
        bean.getNomenNew().add(ev);

        Iterator<NomenclatureEvent> it = bean.getNomenNew().iterator();
        while( it.hasNext() ) {
            ev = it.next();
            for( NomenclatureEvent ev2: bean.getNomenInRgd() ) {

                if( compareTo(ev, ev2)==0 ) {
                    bean.getNomenIgnored().add(ev);
                    it.remove();
                    break;
                }
            }
        }
    }

    void handleMapData(GeneMergeBean bean) throws Exception {

        Iterator<MapData> it = bean.getMapDataNew().iterator();
        while( it.hasNext() ) {
            MapData md = it.next();
            for( MapData md2: bean.getMapDataInRgd() ) {

                if( md.equalsByGenomicCoords(md2) ) {
                    bean.getMapDataIgnored().add(md);
                    it.remove();
                    break;
                }
            }
        }
    }



    void commitAliases(GeneMergeBean bean) throws Exception {

        // are there any aliases to insert?
        if( !bean.getAliasesNew().isEmpty() ) {
            AliasDAO aliasDAO = new AliasDAO();
            aliasDAO.insertAliases(bean.getAliasesNew());
        }
    }

    void commitNotes(GeneMergeBean bean) throws Exception {

        // are there any new notes to insert
        if( !bean.getNotesNew().isEmpty() ) {

            NotesDAO notesDAO = new NotesDAO();

            // to make the note insertable, its key must be made 0, and its rgd id set to target rgd id
            for( Note note: bean.getNotesNew() ) {

                note.setRgdId(bean.getRgdIdTo().getRgdId());
                note.setKey(0);
                notesDAO.updateNote(note);
            }
        }
    }

    void commitCuratedRef(GeneMergeBean bean) throws Exception {

        // are there any new curated references to insert
        if( !bean.getCuratedRefNew().isEmpty() ) {

            AssociationDAO associationDAO = new AssociationDAO();

            // we need to insert a reference association only
            for( Reference ref: bean.getCuratedRefNew() ) {

                associationDAO.insertReferenceeAssociation(bean.getRgdIdTo().getRgdId(), ref.getRgdId());
            }
        }
    }

    void commitAnnots(GeneMergeBean bean) throws Exception {

        if( !bean.getAnnotsNew().isEmpty() ) {

            AnnotationDAO dao = new AnnotationDAO();

            for( Annotation ann: bean.getAnnotsNew() ) {

                ann.setAnnotatedObjectRgdId(bean.getRgdIdTo().getRgdId());
                ann.setObjectName(bean.getGeneTo().getName());
                ann.setObjectSymbol(bean.getGeneTo().getSymbol());
                int annInRgdKey = dao.getAnnotationKey(ann);
                if( annInRgdKey==0 ) {
                    dao.insertAnnotation(ann);
                }
            }
        }
    }

    void commitXdbIds(GeneMergeBean bean) throws Exception {

        if( !bean.getXdbidsNew().isEmpty() ) {

            XdbIdDAO dao = new XdbIdDAO();

            for( XdbId obj: bean.getXdbidsNew() ) {

                String notes = "created by GeneMerge from RGD ID "+obj.getRgdId();
                if( obj.getNotes()==null )
                    obj.setNotes(notes);
                else if( !obj.getNotes().contains(notes) ) {
                    obj.setNotes(obj.getNotes()+"; "+notes);
                }

                obj.setRgdId(bean.getRgdIdTo().getRgdId());
                obj.setCreationDate(new Date());
                obj.setModificationDate(new Date());
            }

            dao.insertXdbs(bean.getXdbidsNew());
        }
    }

    void commitNomen(GeneMergeBean bean) throws Exception {

        if( !bean.getNomenNew().isEmpty() ) {

            NomenclatureDAO dao = new NomenclatureDAO();

            for( NomenclatureEvent event: bean.getNomenNew() ) {

                String notes = "created by GeneMerge from RGD ID "+event.getRgdId();
                if( event.getNotes()==null )
                    event.setNotes(notes);
                else
                    event.setNotes(event.getNotes()+"; "+notes);

                event.setRgdId(bean.getRgdIdTo().getRgdId());

                dao.createNomenEvent(event);
            }
        }
    }

    void commitRgdIdHistory(GeneMergeBean bean) throws Exception {

        RGDManagementDAO dao = new RGDManagementDAO();
        int rgdId = dao.getRgdIdFromHistory(bean.getRgdIdFrom().getRgdId());
        if( rgdId!=bean.getRgdIdTo().getRgdId() )
            dao.recordIdHistory(bean.getRgdIdFrom().getRgdId(), bean.getRgdIdTo().getRgdId());
        dao.retire(bean.getRgdIdFrom());

        dao.updateLastModifiedDate(bean.getRgdIdFrom().getRgdId());
        dao.updateLastModifiedDate(bean.getRgdIdTo().getRgdId());
    }

    void commitMapData(GeneMergeBean bean) throws Exception {

        if( !bean.getMapDataNew().isEmpty() ) {
            MapDAO mapDAO = new MapDAO();
            mapDAO.insertMapData(bean.getMapDataNew());
        }
    }

    int compareTo(Alias a1, Alias a2) {

        int r = Utils.stringsCompareToIgnoreCase(a1.getTypeName(), a2.getTypeName());
        if( r!=0 )
            return r;
        r = Utils.stringsCompareToIgnoreCase(a1.getValue(), a2.getValue());
        return r;
    }

    // compare by unique key, except annotation object rgd id
    int compareTo(Annotation a1, Annotation a2) {

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
    int compareTo(XdbId x1, XdbId x2) {

        int r = x1.getXdbKey() - x2.getXdbKey();
        if( r!=0 )
            return r;
        r = Utils.stringsCompareTo(x1.getAccId(), x2.getAccId());
        return r;
    }

    int compareTo(NomenclatureEvent e1, NomenclatureEvent e2) {

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

    int compareDateTo(Date d1, Date d2) {
        int r = d1.getYear() - d2.getYear();
        if( r!=0 )
            return r;
        r = d1.getMonth() - d2.getMonth();
        if( r!=0 )
            return r;
        r = d1.getDay() - d2.getDay();
        return r;
    }

    String printDate(Date dt) {

        return _dateFormat.format(dt);
    }
    String printDate() {

        return printDate(new Date());
    }
    static SimpleDateFormat _dateFormat = new SimpleDateFormat("yyyy-MM-dd");
}
