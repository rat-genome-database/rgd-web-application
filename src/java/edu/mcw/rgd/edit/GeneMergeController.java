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
 * @author mtutaj
 * @since 3/19/13
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

    void handleAliases(GeneMergeBean bean, HttpServletRequest request) {

        // shall from-gene symbol be added as alias to to-gene?
        String param = request.getParameter("symbol");
        if( param!=null && !param.isEmpty() ) {
            Alias alias = new Alias();
            alias.setRgdId(bean.getRgdIdTo().getRgdId());
            alias.setTypeName("old_gene_symbol");
            alias.setValue(param);
            alias.setNotes("created by GeneMerge tool on "+MergeUtils.printDate());
            bean.getAliasesNew().add(alias);
        }

        // shall from-gene name be added as alias to to-gene?
        param = request.getParameter("name");
        if( param!=null && !param.isEmpty() ) {
            Alias alias = new Alias();
            alias.setRgdId(bean.getRgdIdTo().getRgdId());
            alias.setTypeName("old_gene_name");
            alias.setValue(param);
            alias.setNotes("created by GeneMerge tool on "+MergeUtils.printDate());
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
    void handleNotes(GeneMergeBean bean) {

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
    void handleReferences(GeneMergeBean bean) {

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
    void handleAnnots(GeneMergeBean bean) {

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

    void handleXdbIds(GeneMergeBean bean) {

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

                if( MergeUtils.compareTo(xdbId, xdbId2)==0 ) {
                    bean.getXdbidsIgnored().add(xdbId);
                    it.remove();
                    break;
                }
            }
        }
    }

    void handleNomens(GeneMergeBean bean) {

        // create nomenclature event for 'to-gene'
        NomenclatureEvent ev = new NomenclatureEvent();
        ev.setDesc("Data Merged");
        ev.setEventDate(new Date());
        ev.setName(bean.getGeneTo().getName());
        ev.setNomenStatusType("APPROVED");
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

                if( MergeUtils.compareTo(ev, ev2)==0 ) {
                    bean.getNomenIgnored().add(ev);
                    it.remove();
                    break;
                }
            }
        }
    }

    void handleMapData(GeneMergeBean bean) {

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
        MergeUtils.insertAliases(bean.getAliasesNew());
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
        MergeUtils.commitAnnots(bean.getAnnotsNew(), bean.getGeneTo());
    }

    void commitXdbIds(GeneMergeBean bean) throws Exception {
        MergeUtils.commitXdbIds(bean.getXdbidsNew(), bean.getRgdIdTo().getRgdId(), "GeneMerge");
    }

    void commitNomen(GeneMergeBean bean) throws Exception {
        MergeUtils.commitNomen(bean.getNomenNew(), bean.getRgdIdTo().getRgdId(), "GeneMerge");
    }

    void commitRgdIdHistory(GeneMergeBean bean) throws Exception {
        MergeUtils.commitRgdIdHistory(bean.getRgdIdFrom(), bean.getRgdIdTo());
    }

    void commitMapData(GeneMergeBean bean) throws Exception {

    }
}
