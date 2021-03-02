package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.process.Utils;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.Date;
import java.util.Iterator;

/**
 * User: mtutaj
 * Date: 3/19/13
 */
public class StrainMergeController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse httpServletResponse) throws Exception {

        StrainMergeBean bean = new StrainMergeBean();

        String action = request.getParameter("action");
        boolean isPreview = action!=null && action.equals("preview");
        boolean isCommit = action!=null && action.equals("commit");

        int rgdIdFrom = Integer.parseInt(request.getParameter("rgdIdFrom"));
        int rgdIdTo = Integer.parseInt(request.getParameter("rgdIdTo"));
        String sessionObj = "strain-merge-"+rgdIdFrom+"-"+rgdIdTo;

        if( isCommit ) {
            bean = (StrainMergeBean) request.getSession().getAttribute(sessionObj);

            commitAliases(bean);
            commitNotes(bean);
            commitCuratedRef(bean);
            commitAnnots(bean);
            commitXdbIds(bean);
            commitNomen(bean);
            commitRgdIdHistory(bean);
            commitMapData(bean);
            commitQtlAssociations(bean);

            request.getSession().removeAttribute(sessionObj);
        }
        else if( isPreview ) {
            bean = (StrainMergeBean) request.getSession().getAttribute(sessionObj);

            handleAliases(bean, request);
            handleNotes(bean);
            handleReferences(bean);
            handleAnnots(bean);
            handleXdbIds(bean);
            handleNomens(bean);
            handleMapData(bean);
            handleQtlAssociations(bean);

        } else {

            AliasDAO aliasDAO = new AliasDAO();
            AnnotationDAO annotationDAO = new AnnotationDAO();
            AssociationDAO associationDAO = new AssociationDAO();
            NomenclatureDAO nomenclatureDAO = new NomenclatureDAO();
            NotesDAO notesDAO = new NotesDAO();
            RGDManagementDAO managementDAO = new RGDManagementDAO();
            StrainDAO strainDAO = new StrainDAO();
            XdbIdDAO xdbIdDAO = new XdbIdDAO();

            bean.setRgdIdFrom(managementDAO.getRgdId2(rgdIdFrom));
            bean.setRgdIdTo(managementDAO.getRgdId2(rgdIdTo));

            bean.setStrainFrom(strainDAO.getStrain(rgdIdFrom));
            bean.setStrainTo(strainDAO.getStrain(rgdIdTo));

            // ALIASES
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

            // NOTES
            bean.getNotesInRgd().addAll(notesDAO.getNotes(rgdIdTo));
            bean.getNotesNew().addAll(notesDAO.getNotes(rgdIdFrom));

            // CURATED REFERENCES
            bean.getCuratedRefInRgd().addAll(associationDAO.getReferenceAssociations(rgdIdTo));
            bean.getCuratedRefNew().addAll(associationDAO.getReferenceAssociations(rgdIdFrom));
            for( Reference ref: bean.getCuratedRefNew() ) {
                ref.setSpeciesTypeKey(-1); // artificially mark reference as coming from 'from-gene'
            }

            // ANNOTATIONS
            bean.getAnnotsInRgd().addAll(annotationDAO.getAnnotations(rgdIdTo));
            bean.getAnnotsNew().addAll(annotationDAO.getAnnotations(rgdIdFrom));

            // XDB IDS
            XdbId filter = new XdbId();
            filter.setRgdId(rgdIdTo);
            bean.getXdbidsInRgd().addAll(xdbIdDAO.getXdbIds(filter));
            filter.setRgdId(rgdIdFrom);
            bean.getXdbidsNew().addAll(xdbIdDAO.getXdbIds(filter));

            // NOMENCLATURE
            bean.getNomenInRgd().addAll(nomenclatureDAO.getNomenclatureEvents(rgdIdTo));
            bean.getNomenNew().addAll(nomenclatureDAO.getNomenclatureEvents(rgdIdFrom));

            // MAP DATA
            MapDAO mapDAO = new MapDAO();
            bean.getMapDataInRgd().addAll(mapDAO.getMapData(rgdIdTo));
            bean.getMapDataNew().addAll(mapDAO.getMapData(rgdIdFrom));

            // QTL ASSOCIATIONS
            bean.getQtlsInRgd().addAll(associationDAO.getQTLAssociationsForStrain(rgdIdTo));
            bean.getQtlsNew().addAll(associationDAO.getQTLAssociationsForStrain(rgdIdFrom));


            // save the bean named 'strain-merge-rgdIdFrom-rgdIdTo' in session
            request.getSession().setAttribute(sessionObj, bean);
        }

        String page = isPreview ? "/WEB-INF/jsp/curation/edit/strainMergePreview.jsp"
                : isCommit ? "/WEB-INF/jsp/curation/edit/strainMergeSummary.jsp"
                : "/WEB-INF/jsp/curation/edit/strainMerge.jsp";
        ModelAndView mv = new ModelAndView(page);
        mv.addObject("bean", bean);
        return mv;
    }


    void handleAliases(StrainMergeBean bean, HttpServletRequest request) {

        // shall from-strain symbol be added as alias to to-strain?
        String param = request.getParameter("symbol");
        if( param!=null && !param.isEmpty() ) {
            Alias alias = new Alias();
            alias.setRgdId(bean.getRgdIdTo().getRgdId());
            alias.setTypeName("old_strain_symbol");
            alias.setValue(param);
            alias.setNotes("created by StrainMerge tool on "+MergeUtils.printDate());
            bean.getAliasesNew().add(alias);
        }

        // shall from-strain name be added as alias to to-strain?
        param = request.getParameter("name");
        if( param!=null && !param.isEmpty() ) {
            Alias alias = new Alias();
            alias.setRgdId(bean.getRgdIdTo().getRgdId());
            alias.setTypeName("old_strain_name");
            alias.setValue(param);
            alias.setNotes("created by StrainMerge tool on "+MergeUtils.printDate());
            bean.getAliasesNew().add(alias);
        }

        // remove duplicates
        Iterator<Alias> it = bean.getAliasesNew().iterator();
        while( it.hasNext() ) {
            Alias alias = it.next();
            for( Alias alias2: bean.getAliasesInRgd() ) {
                if( MergeUtils.compareTo(alias, alias2)==0 ) {
                    bean.getAliasesNewIgnored().add(alias);
                    it.remove();
                    break;
                }
            }
        }
    }

    // determine which of the new aliases are already in RGD and move them to ignored list
    void handleNotes(StrainMergeBean bean) {

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
    void handleReferences(StrainMergeBean bean) {

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
    void handleAnnots(StrainMergeBean bean) {

        Iterator<Annotation> it = bean.getAnnotsNew().iterator();
        while( it.hasNext() ) {
            Annotation ann = it.next();
            for( Annotation ann2: bean.getAnnotsInRgd() ) {
                // annotations
                if( MergeUtils.compareTo(ann, ann2)==0 ) {
                    // duplicate annotation
                    bean.getAnnotsIgnored().add(ann);
                    it.remove();
                    break;
                }
            }
        }
    }

    void handleXdbIds(StrainMergeBean bean) {

        Iterator<XdbId> it = bean.getXdbidsNew().iterator();
        while( it.hasNext() ) {
            XdbId xdbId = it.next();

            for( XdbId xdbId2: bean.getXdbidsInRgd() ) {

                if( MergeUtils.compareTo(xdbId, xdbId2)==0 ) {
                    bean.getXdbidsIgnored().add(xdbId);
                    it.remove();
                    break;
                }
            }
        }
    }

    void handleNomens(StrainMergeBean bean) {

        // create nomenclature event for 'to-strain'
        NomenclatureEvent ev = new NomenclatureEvent();
        ev.setDesc("Data Merged");
        ev.setEventDate(new Date());
        ev.setName(bean.getStrainTo().getName());
        ev.setNomenStatusType("APPROVED");
        ev.setNotes("StrainMerge from RGD ID " + bean.getRgdIdFrom().getRgdId() + " to RGD ID " + bean.getRgdIdTo().getRgdId());
        ev.setOriginalRGDId(bean.getRgdIdFrom().getRgdId());
        ev.setPreviousName(bean.getStrainFrom().getName());
        ev.setPreviousSymbol(bean.getStrainFrom().getSymbol());
        ev.setRefKey("9333");
        ev.setRgdId(bean.getRgdIdTo().getRgdId());
        ev.setSymbol(bean.getStrainTo().getSymbol());
        bean.getNomenNew().add(ev);

        Iterator<NomenclatureEvent> it = bean.getNomenNew().iterator();
        while( it.hasNext() ) {
            ev = it.next();
            for( NomenclatureEvent ev2: bean.getNomenInRgd() ) {

                if( MergeUtils.compareTo(ev, ev2)==0 ) {
                    bean.getNomenIgnored().add(ev);
                    it.remove();
                    break;
                }
            }
        }
    }

    void handleMapData(StrainMergeBean bean) {

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

    void handleQtlAssociations(StrainMergeBean bean) {

        Iterator<QTL> it = bean.getQtlsNew().iterator();
        while( it.hasNext() ) {
            QTL qtl = it.next();

            for( QTL qtl2: bean.getQtlsInRgd() ) {

                if( qtl.getRgdId()==qtl2.getRgdId() ) {
                    bean.getQtlsNewIgnored().add(qtl);
                    it.remove();
                    break;
                }
            }
        }
    }


    void commitAliases(StrainMergeBean bean) throws Exception {
        MergeUtils.insertAliases(bean.getAliasesNew());
    }

    void commitNotes(StrainMergeBean bean) throws Exception {
        MergeUtils.commitNotes(bean.getNotesNew(), bean.getRgdIdTo().getRgdId());
    }

    void commitCuratedRef(StrainMergeBean bean) throws Exception {
        MergeUtils.commitCuratedRef(bean.getCuratedRefNew(), bean.getRgdIdTo().getRgdId());
    }

    void commitAnnots(StrainMergeBean bean) throws Exception {
        MergeUtils.commitAnnots(bean.getAnnotsNew(), bean.getStrainTo());
    }

    void commitXdbIds(StrainMergeBean bean) throws Exception {
        MergeUtils.commitXdbIds(bean.getXdbidsNew(), bean.getRgdIdTo().getRgdId(), "StrainMerge");
    }

    void commitNomen(StrainMergeBean bean) throws Exception {
        MergeUtils.commitNomen(bean.getNomenNew(), bean.getRgdIdTo().getRgdId(), "StrainMerge");
    }

    void commitRgdIdHistory(StrainMergeBean bean) throws Exception {
        MergeUtils.commitRgdIdHistory(bean.getRgdIdFrom(), bean.getRgdIdTo());
    }

    void commitMapData(StrainMergeBean bean) {

    }

    void commitQtlAssociations(StrainMergeBean bean) throws Exception {

        if( !bean.getQtlsNew().isEmpty() ) {

            AssociationDAO assocDAO = new AssociationDAO();
            int rgdIdTo = bean.getRgdIdTo().getRgdId();

            for( QTL qtl: bean.getQtlsNew() ) {
                assocDAO.insertStrainToQTLAssociation(rgdIdTo, qtl.getRgdId());
            }
        }
    }

}
