package edu.mcw.rgd.ontology;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.EvidenceCode;
import edu.mcw.rgd.datamodel.MapData;
import edu.mcw.rgd.datamodel.Reference;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermSynonym;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import edu.mcw.rgd.datamodel.pheno.Condition;
import edu.mcw.rgd.datamodel.pheno.Record;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.web.FormUtility;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.text.DecimalFormat;
import java.util.*;

public class OntAnnotController implements Controller {

    // decimal format for showing the thousand separator
    static DecimalFormat _numFormat = new DecimalFormat("###,###,###,###");
    static ReferencePipelines refPipe = new ReferencePipelines();


    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelAndView mv = null;
        int maxAnnotCount = OntAnnotBean.MAX_ANNOT_COUNT;
        OntAnnotBean bean = new OntAnnotBean();
        if (request.getParameter("a") != null && request.getParameter("a").equals("1")) {
            mv = new ModelAndView("/WEB-INF/jsp/ontology/annotDetail.jsp");
        }else if (request.getParameter("d") != null && request.getParameter("d").equals("1")) {
            // download to a file -- no annotation limit
            maxAnnotCount = Integer.MAX_VALUE-10;
            bean.setIsDownload(true);
            mv = new ModelAndView("/WEB-INF/jsp/ontology/downloadAnnotation.jsp");
        }else {
            mv = new ModelAndView("/WEB-INF/jsp/ontology/annot.jsp");
        }


        mv.addObject("bean", bean);

        // load annotations
        OntologyXDAO dao = new OntologyXDAO();

        loadAnnotations(bean, dao, request, maxAnnotCount);
        // handle missing or unknown acc_id
        if( bean.getAccId()==null || bean.getTerm()==null ) {

            // redirect to general search
            OntGeneralSearchController searchController = new OntGeneralSearchController();
            if( bean.getAccId()!=null )
                request.setAttribute("term", bean.getAccId());
            return searchController.handleRequest(request, response);
        }

        // load paths (from given term to the root term)
        // path type (all, shortest, longest, etc)
        String param = request.getParameter("path_type");
        if( param==null || param.isEmpty() )
            param = "5"; // default is to show '"one shortest and longest"'
        // path type is an integer
        int pathType = 0;
        try { pathType = Integer.parseInt(param); } catch(NumberFormatException e) {}
        // validate the path type
        if( pathType<=0 || pathType>6 ) {
            pathType = 5; // default is 5
        }
        bean.setPathType(Integer.toString(pathType));

        // load paths from a given term to the root term
        // load also the child terms
        loadPaths(bean.getTerm().getAccId(), pathType, bean.getSpeciesTypeKey(), bean, dao);
        loadGviewerRgdIds(bean, dao, request,maxAnnotCount);
        return mv;
    }


    static public void loadAnnotations(OntAnnotBean bean, OntologyXDAO dao, HttpServletRequest request, int maxAnnotCount) throws Exception {


        String oKey = "1";
        if (request.getParameter("o") != null && !request.getParameter("o").equals("")) {
            oKey=request.getParameter("o");

        }

        loadAnnotations(bean, dao,
                 request.getParameter("acc_id"),
                 request.getParameter("species"),
                 request.getParameter("with_children"),
                 request.getParameter("sort_by"),
                 request.getParameter("sort_desc"),
                 oKey,
                 request.getParameter("x"),
                 maxAnnotCount);
    }

    static public void loadAnnotations(OntAnnotBean bean, OntologyXDAO dao, String accId, String species, String displayDescendants,
        String sortBy, String sortDesc, String objectKey, String extendedView, int maxAnnotCount) throws Exception {

        bean.setExtendedView(false);
        if( extendedView!=null ) {
            if( Integer.parseInt(extendedView)>0 )
                bean.setExtendedView(true);
        }

        bean.setAccId(accId);



        if (objectKey != null) {
            bean.setObjectKey(Integer.parseInt(objectKey));
        }

        boolean withChildren = true; // display gene annotations for term and all child terms; default is true
        int withKids = 1;
        if( displayDescendants!=null &&  displayDescendants.equals("0") ) {
            withChildren = false; // override to turn off showing the descendants
            withKids=0;
        }
        bean.setWithChildren(withChildren);

        // species filter (validate)
        if( species==null ) {
            species = "Rat";
        } else {
            int pos = species.indexOf('?');
            if( pos>0 )
                species = species.substring(0, pos);
        }
        int speciesTypeKey = SpeciesType.parse(species);
        if( speciesTypeKey==SpeciesType.UNKNOWN ) {
            speciesTypeKey = SpeciesType.RAT;
        }
        bean.setSpeciesTypeKey(speciesTypeKey);
        species = SpeciesType.getCommonName(speciesTypeKey);
        bean.setSpecies(species);

        TermWithStats ts = dao.getTermWithStatsCached(bean.getAccId());
        bean.setTerm(ts);
        // handle invalid term acc id
        if( bean.getTerm()==null ) {
            return; // invalid acc id -- nothing more to do
        }

        if (ts.getStat("annotated_object_count",speciesTypeKey,bean.getObjectKey(),withKids) < 1) {

            if (ts.getStat("annotated_object_count",speciesTypeKey,1,withKids) > 0){
                bean.setObjectKey(1);
            }else  if (ts.getStat("annotated_object_count",speciesTypeKey,6,withKids) > 0){
                bean.setObjectKey(6);
            }else  if (ts.getStat("annotated_object_count",speciesTypeKey,5,withKids) > 0){
                bean.setObjectKey(5);
            }else  if (ts.getStat("annotated_object_count",speciesTypeKey,7,withKids) > 0){
                bean.setObjectKey(7);
            }else  if (ts.getStat("annotated_object_count",speciesTypeKey,11,withKids) > 0){
                bean.setObjectKey(11);
            }
        }

        // load term synonyms
        List<TermSynonym> synonyms = dao.getTermSynonyms(accId);
        bean.setTermSynonyms(synonyms);
        // sort synonyms by type and name
        OntViewController.sortSynonyms(synonyms);

        Map<Term, List<OntAnnotation>> mapWithAnnots = new HashMap<Term, List<OntAnnotation>>();

        withKids = 0;
        if (bean.isWithChildren()) {
            withKids=1;
        }

        if (ts.getStat("annotated_object_count",bean.getSpeciesTypeKey(),bean.getObjectKey(),withKids) < maxAnnotCount) {
            mapWithAnnots = loadAnnotations(bean, withChildren, maxAnnotCount);
        }

        // load gene,qtl and strain annotations for the term
        bean.setAnnots(mapWithAnnots);

        // load map positions for the annotations specific to given species
        if( speciesTypeKey!=SpeciesType.ALL ) {
            loadMapPositions(mapWithAnnots, speciesTypeKey);
        }else {
            loadMapPositions(mapWithAnnots);
        }
        // the rest of parameters: 'sort_by' and 'sort_desc'
        if( sortBy==null || sortBy.isEmpty() )
            sortBy = "symbol"; // default sort by symbol
        if( !bean.isExtendedView() && bean.isExtendedSortBy(sortBy) )
            sortBy = "symbol"; // default sort by symbol
        bean.setSortBy(sortBy);

        if( sortDesc!=null && sortDesc.equals("1") )
            bean.setSortDesc(true);

        // sort the objects
        sort(mapWithAnnots, bean.getSortBy(), bean.isSortDesc());
    }

    void loadPaths(String termAcc, int pathType, int speciesTypeKey, OntAnnotBean bean, OntologyXDAO dao) throws Exception {

        bean.setPaths(dao.getPathsToRoot(termAcc, pathType));
        bean.setChildren(dao.getActiveChildTerms(termAcc, speciesTypeKey));
    }


    static Map<Term, List<OntAnnotation>> loadAnnotations(OntAnnotBean bean, boolean withChildren, int maxAnnotCount) throws Exception {


        final String accId = bean.getAccId();

        // build map with annotations
        Map<Term, List<OntAnnotation>> annotMap = new TreeMap<Term, List<OntAnnotation>>(new Comparator<Term>(){

            // the searched for term should always be on top; the other terms should be sorted alphabetically
            public int compare(Term o1, Term o2) {
                if( o1.getAccId().equals(accId) )
                    return -1;
                if( o2.getAccId().equals(accId) )
                    return +1;
                return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            }
        });

        if( accId.startsWith("RS:")
         || accId.startsWith("CMO:")
         || accId.startsWith("MMO:")
         || accId.startsWith("XCO:") ) {

            loadPhenominerAnnotations(bean, withChildren);
        }

        AnnotationDAO dao = new AnnotationDAO();
        MapDAO mdao = new MapDAO();
        List<Annotation> annots;
        if( bean.getSpeciesTypeKey()==SpeciesType.ALL ) {
            annots = dao.getAnnotationsGroupedByGene(accId, withChildren, 0, maxAnnotCount+1, bean.getObjectKey());
        } else {
            annots = dao.getAnnotationsGroupedByGene(accId, withChildren, bean.getSpeciesTypeKey(), maxAnnotCount+1, bean.getObjectKey());
        }

        // warn the user if there are more than 1000 annotations - we are showing only the first 1000
        if( annots.size()>maxAnnotCount ) {
            // remove the last annotation
            annots.remove(maxAnnotCount);
            // get array with status messages
        }

        // sort annots by term acc id, then by gene symbol
        Collections.sort(annots, new Comparator<Annotation>(){
            public int compare(Annotation o1, Annotation o2) {
                int diff = Utils.stringsCompareToIgnoreCase(o1.getTermAcc(), o2.getTermAcc());
                if( diff != 0 )
                    return diff;

                return Utils.stringsCompareToIgnoreCase(o1.getObjectSymbol(), o2.getObjectSymbol());
            }
        });


        Term term = null;
        OntAnnotation a = null; // last annotation
        List<OntAnnotation> annotList = null;
        for( Annotation annot: annots ) {

            // if term is different, new Term object and new annot list has to be created
            if( term==null || Utils.stringsCompareToIgnoreCase(term.getAccId(), annot.getTermAcc())!=0 ) {
                term = new Term();
                term.setAccId(annot.getTermAcc());
                term.setTerm(annot.getTerm());

                annotList = new ArrayList<OntAnnotation>();
                a = null;

                annotMap.put(term, annotList);
            }

            // get new annotation object
            if( a==null || a.getRgdId()!=annot.getAnnotatedObjectRgdId() ) {
                a = new OntAnnotation();
                a.setRgdId(annot.getAnnotatedObjectRgdId());
                a.setSymbol(annot.getObjectSymbol());
                if( annot.getObjectName()!=null )
                    a.setName(annot.getObjectName());
                else
                    a.setName("");

                // build annotation
                if(bean.getIsDownload()){
                    a.setPlainEvidence(annot.getEvidence());
                }else{
                    a.setEvidenceWithInfo(annot.getEvidence(), annot.getWithInfo(), term);
                }


                // originally ref_rgd_id was accessible by calling annot.getRefRgdId()
                // since the ontology annotation table was redesigned to show only one row per gene,
                // possible multiple ref_rgd_id, ", "-separated, are stored in the field 'relativeTo'
                a.setRefRgdIds(annot.getRelativeTo());
                //a.setRefRgdId(annot.getRefRgdId());

                a.setDataSource(annot.getDataSrc());
                if (annot.getRefRgdId()!=null && annot.getRefRgdId()!=0) {
                    if (!refPipe.search(annot.getRefRgdId())) {// not a pipeline reference
                        a.setHiddenPmId(annot.getRefRgdId());
                        a.setReferenceTurnedRGDRef("<a href='/rgdweb/report/reference/main.html?id=" + annot.getRefRgdId() + "'> RGD:" + annot.getRefRgdId() + "</a>");
                    } else { // is a pipeline
                        String refInfo = "<a href='/rgdweb/report/reference/main.html?id=" + annot.getRefRgdId() + "'>" + annot.getDataSrc() + "</a>";
                        if (!a.getReference().contains(refInfo))
                            a.setReference(refInfo);
                    }
                }
                a.setQualifier(Utils.NVL(annot.getQualifier(),""));
                if( !Utils.isStringEmpty(a.getQualifier()) ) {
                    bean.setHasQualifiers(true);
                }
                a.setRgdObjectKey(annot.getRgdObjectKey());
                // setDataSource original position
                a.addXrefs(annot.getXrefSource());

                a.setSpeciesTypeKey(annot.getSpeciesTypeKey());
                a.setNotes(annot.getNotes());
                a.setEnsemblData(mdao,_numFormat);
                annotList.add(a);
            } else {
                // merge data from multiple annotations (for the same term and object)
                a.setDataSource( htmlMerge(a.getDataSource(), annot.getDataSrc()) );

                if (!refPipe.search(annot.getRefRgdId())){ // not a pipeline reference
                    a.setHiddenPmId(annot.getRefRgdId());
                    a.setReferenceTurnedRGDRef("<a href='/rgdweb/report/reference/main.html?id=" + annot.getRefRgdId() + "'> RGD:" + annot.getRefRgdId() + "</a>");
                }
                else { // is a pipeline
                    String refInfo = "<a href='/rgdweb/report/reference/main.html?id=" + annot.getRefRgdId() + "'>" + annot.getDataSrc() + "</a>";
                    if(!a.getReference().contains(refInfo)) {
                        a.setReference(htmlMerge(a.getReference(), refInfo));
                    }
                }

                if(bean.getIsDownload()){
                    a.setPlainEvidence(annot.getEvidence());
                }else{
                    a.setEvidence( annot.getEvidence(), term );
                }

                a.setQualifier( htmlMerge(a.getQualifier(), annot.getQualifier()) );
                if( !Utils.isStringEmpty(a.getQualifier()) ) {
                    bean.setHasQualifiers(true);
                }

                a.addXrefs(annot.getXrefSource());
                a.setNotes( htmlMerge(a.getNotes(), annot.getNotes()) );
            }
        }
        return annotMap;
    }

    static String htmlMerge(String oldData, String newData) {
        // no new data -- nothing changed
        if( Utils.isStringEmpty(newData) ) {
            return oldData;
        }

        // there is new data -- there was no old data
        if( Utils.isStringEmpty(oldData) ) {
            return newData;
        }

        // there is new data -- there was old data -- merge if new data is new
        if( oldData.contains(newData) ) {
            return oldData; // new data is already within old data
        }
        return oldData+"<BR>"+newData;
    }

    static void loadPhenominerAnnotations(OntAnnotBean bean, boolean withChildren) throws Exception {

        //
        withChildren = false;

        // build map with annotations
        Set<Term> strainTerms = new TreeSet<Term>(new Comparator<Term>() {
            public int compare(Term t1, Term t2) {
                return Utils.stringsCompareToIgnoreCase(t1.getTerm(), t2.getTerm());
            }
        });

        Set<Term> cmoTerms = new TreeSet<Term>(new Comparator<Term>() {
            public int compare(Term t1, Term t2) {
                return Utils.stringsCompareToIgnoreCase(t1.getTerm(), t2.getTerm());
            }
        });

        Set<Term> mmoTerms = new TreeSet<Term>(new Comparator<Term>() {
            public int compare(Term t1, Term t2) {
                return Utils.stringsCompareToIgnoreCase(t1.getTerm(), t2.getTerm());
            }
        });

        Set<Term> xcoTerms = new TreeSet<Term>(new Comparator<Term>() {
            public int compare(Term t1, Term t2) {
                return Utils.stringsCompareToIgnoreCase(t1.getTerm(), t2.getTerm());
            }
        });


        // first get the list of record ids
        PhenominerDAO phDAO = new PhenominerDAO();
        OntologyXDAO ontDAO = new OntologyXDAO();

        List<Integer> annotIds;
        if( withChildren )
            annotIds = phDAO.getAnnotationsForTermAndDescendants(bean.getAccId());
        else
            annotIds = phDAO.getAnnotationsForTerm(bean.getAccId());

        for( int recordId: annotIds ) {
            Record rec = phDAO.getRecord(recordId);

            // strain ontology term
            String accId = rec.getSample().getStrainAccId();
            Term term = ontDAO.getTermWithStatsCached(accId);
            if( term!=null ) {
                strainTerms.add(term);
            }

            // cmo term
            accId = rec.getClinicalMeasurement().getAccId();
            term = ontDAO.getTermWithStatsCached(accId);
            if( term!=null ) {
                cmoTerms.add(term);
            }

            // mmo term
            accId = rec.getMeasurementMethod().getAccId();
            term = ontDAO.getTermWithStatsCached(accId);
            if( term!=null ) {
                mmoTerms.add(term);
            }

            // xco term
            for( Condition cond: rec.getConditions() ) {
                accId = cond.getOntologyId();
                term = ontDAO.getTermWithStatsCached(accId);
                if( term!=null ) {
                    xcoTerms.add(term);
                }
            }
        }

        bean.setPhenoStrains(strainTerms);
        bean.setPhenoCmoTerms(cmoTerms);
        bean.setPhenoMmoTerms(mmoTerms);
        bean.setPhenoXcoTerms(xcoTerms);
    }

    // loading map positions is very consuming - we use a static hashmap to store positions
    // for subsequent use;
    // key is rgd id; value is a list of map positions
    static Map<Integer, List<MapData>> _posMap = new HashMap<>();

    synchronized static List<MapData> getMapPositionsFromCache(int rgdId, int mapKey, MapDAO dao) throws Exception {
        List<MapData> mds = _posMap.get(rgdId);
        if( mds==null ) {
            // not in cache - load from database
            mds = dao.getMapData(rgdId, mapKey);
            _posMap.put(rgdId, mds);
        }
        return mds;
    }

    // load map positions on reference assembly for given species
    static void loadMapPositions(Map<Term, List<OntAnnotation>> annots, int speciesTypeKey) throws Exception {

        MapManager mm = MapManager.getInstance();
        MapDAO dao = new MapDAO();

        // get map key for primary ref assembly
        int mapKey = mm.getReferenceAssembly(speciesTypeKey).getKey();

        for( List<OntAnnotation> list: annots.values() ) {
            for( OntAnnotation a: list ) {

                // load positions from cache
                List<MapData> mds = getMapPositionsFromCache(a.getRgdId(), mapKey, dao);
                for( MapData md: mds ) {
                    addPositionToAnnotation(a, md, speciesTypeKey);
                    addJBrowseLink(a, md, speciesTypeKey);
                }

                // if chromosome is not present, then location information is not present
                // so we are setting the chromosome to empty string to cause lines
                // without position be placed at the end of the list of results
                if( a.getChr()==null || a.getChr().isEmpty() )
                    a.setChr("    ");
            }
        }
    }

    // load map positions on reference assembly for any species
    static void loadMapPositions(Map<Term, List<OntAnnotation>> annots) throws Exception {

        MapManager mm = MapManager.getInstance();
        MapDAO dao = new MapDAO();

        for( List<OntAnnotation> list: annots.values() ) {
            for( OntAnnotation a: list ) {

                int mapKey = mm.getReferenceAssembly(a.getSpeciesTypeKey()).getKey();
                List<MapData> mds = getMapPositionsFromCache(a.getRgdId(), mapKey, dao);

                for( MapData md: mds ) {
                    addPositionToAnnotation(a, md, a.getSpeciesTypeKey());
                    addJBrowseLink(a, md, a.getSpeciesTypeKey());
                }

                // if chromosome is not present, then location information is not present
                // so we are setting the chromosome to empty string to cause lines
                // without position be placed at the end of the list of results
                if( a.getChr()==null || a.getChr().isEmpty() )
                    a.setChr("    ");
            }
        }
    }

    static void addPositionToAnnotation(OntAnnotation a, MapData md, int speciesTypeKey) {
        // always set the species type key
        a.setSpeciesTypeKey(speciesTypeKey);

        // the map position must have a valid start-stop position
        if( md.getStartPos()==null || md.getStopPos()==null )
            return;

        String chr = md.getChromosome().toUpperCase();
        if( chr.length()==1 )
            chr = " "+chr; // left pad chromosome with space up to 2 char length
        if( chr.endsWith("X")||chr.endsWith("Y")||chr.endsWith("T") )
            chr = " "+chr; // X,Y,MT chromosomes should be always 3 character long

        // if chromosome is null, this is the first map position;
        // otherwise, it is another map position
        if( a.getChr().isEmpty() ) {
            a.setChr(chr);
            a.setStartPos(_numFormat.format(md.getStartPos()));
            a.setStopPos(_numFormat.format(md.getStopPos()));
            a.setFullNcbiPos();
        }
        else {
            // concatenate chromosomes and positions
            a.addToNcbiPos(chr,_numFormat.format(md.getStartPos()),_numFormat.format(md.getStopPos()));
            a.setChr(a.getChr()+"<br/>"+chr);
            a.setStartPos(a.getStartPos()+"<br/>"+_numFormat.format(md.getStartPos()));
            a.setStopPos(a.getStopPos()+"<br/>"+_numFormat.format(md.getStopPos()));
        }
    }

    static void addJBrowseLink(OntAnnotation a, MapData md, int speciesTypeKey) {

        // the map position must have a valid start-stop position
        if( md.getStartPos()==null || md.getStopPos()==null )
            return;

        StringBuilder buf = new StringBuilder(128);
        buf.append("/jbrowse/?highlight=&data=");
        if( speciesTypeKey==SpeciesType.RAT ){
            buf.append("data_rgd6");
        }else if( speciesTypeKey==SpeciesType.MOUSE ){
            buf.append("data_mm38"); // was mm37
        }else if( speciesTypeKey==SpeciesType.HUMAN ){
            buf.append("data_hg38"); // was hg19
        }else if (speciesTypeKey==SpeciesType.CHINCHILLA) {
            buf.append("data_cl1_0");
        }else if (speciesTypeKey==SpeciesType.DOG) {
            buf.append("data_dog3_1");
        }else if (speciesTypeKey==SpeciesType.BONOBO) {
            buf.append("data_bonobo2");
        }else if (speciesTypeKey==SpeciesType.SQUIRREL) {
            buf.append("data_squirrel2_0");
        }else if (speciesTypeKey==SpeciesType.PIG) {
            buf.append("data_pig11_1");
        }else if (speciesTypeKey==SpeciesType.NAKED_MOLE_RAT) {
            buf.append("HetGla 1.0");
        }else if (speciesTypeKey==SpeciesType.VERVET) {
            buf.append("ChlSab1.1");
        }

        if( a.isGene() ) {
            buf.append("&tracks=ARGD_curated_genes%2CEnsembl_genes");
        } else if( a.isQtl() ) {
            buf.append("&tracks=AQTLS");
        } else if( a.isStrain() ) {
            buf.append("&tracks=CongenicStrains,MutantStrains");
        }

        buf.append("&loc=");
        buf.append(FormUtility.getJBrowseLoc(md));

        a.setJBrowseLink(buf.toString());
    }

    // sort annotations
    static void sort(Map<Term, List<OntAnnotation>> annots, final String sortBy, final boolean sortDesc) {

        for( List<OntAnnotation> list: annots.values() ) {
            Collections.sort(list, new Comparator<OntAnnotation>(){
                public int compare(OntAnnotation o1, OntAnnotation o2) {

                // 1. annotations are grouped by object type: 1st go genes then qtls then strains
                int r = Utils.stringsCompareToIgnoreCase(o1.getRgdObjectName(), o2.getRgdObjectName());
                if( r!= 0 )
                    return r; // annotations belong to different object groups

                // 2. sort annotations within the same object group
                switch (sortBy) {
                    case "symbol":
                        r = Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
                        break;
                    case "object name":
                        r = Utils.stringsCompareToIgnoreCase(o1.getName(), o2.getName());
                        break;
                    case "qualifier":
                        r = Utils.stringsCompareToIgnoreCase(o1.getQualifier(), o2.getQualifier());
                        if (r == 0)
                            r = Utils.stringsCompareToIgnoreCase(o1.getEvidenceWithInfo(), o2.getEvidenceWithInfo());
                        break;
                    case "evidence":
                        r = Utils.stringsCompareToIgnoreCase(o1.getEvidenceWithInfo(), o2.getEvidenceWithInfo());
                        break;
                    case "position":
                        r = o1.getChr().length() - o2.getChr().length();
                        if (r == 0) {
                            r = o1.getChr().compareTo(o2.getChr());
                            if (r == 0) {
                                r = o1.getStartPos().length() - o2.getStartPos().length();
                                if (r == 0)
                                    r = o1.getStartPos().compareTo(o2.getStartPos());
                            }
                        }
                        break;
                    case "reference":
                        r = o1.getReference().compareTo(o2.getReference());
                        break;
                    case "source":
                        r = Utils.stringsCompareToIgnoreCase(o1.getDataSource(), o2.getDataSource());
                        if (r == 0)
                            r = Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
                        break;
                }

                // handle ascending / descending sort
                if( r!=0 && sortDesc )
                    r = -r;

                // 3. optionally sort by species type key, descending
                //  to ensure the results are in table tab order ('Chinchilla', 'Rat', 'Mouse', 'Human')
                if( r==0 )
                    r = o2.getSpeciesTypeKey() - o1.getSpeciesTypeKey();

                return r;
                }
            });
        }
    }

    static void loadGviewerRgdIds(OntAnnotBean bean, OntologyXDAO dao, HttpServletRequest request, int maxAnnotCount) throws Exception {
        String rgd_ids = "";
        OntologyXDAO xdao = new OntologyXDAO();
        TermWithStats tws = xdao.getTermWithStatsCached(bean.getAccId());
        OntAnnotBean bean2 = new OntAnnotBean();
        int withChildren = 0;
        if(bean.isWithChildren())
            withChildren = 1;

        if (tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),1,withChildren) > 0) {
            loadAnnotations(bean2, dao, request, maxAnnotCount, "1"); //5,6
            rgd_ids += addRgdIds(bean2.getAnnots());
            bean.setGeneRgdids(rgd_ids);
        }
        if (tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),6,withChildren) > 0) {
            rgd_ids = "";
            bean2 = new OntAnnotBean();
            loadAnnotations(bean2, dao, request, maxAnnotCount, "6");
            rgd_ids += addRgdIds(bean2.getAnnots());
            bean.setQtlRgdids(rgd_ids);
        }
        if (tws.getStat("annotated_object_count",bean.getSpeciesTypeKey(),5,withChildren) > 0) {
            rgd_ids = "";
            bean2 = new OntAnnotBean();
            loadAnnotations(bean2, dao, request, maxAnnotCount, "5");
            rgd_ids += addRgdIds(bean2.getAnnots());
            bean.setStrainRgdids(rgd_ids);
        }
        return;
    }
    
    static String addRgdIds(Map<Term, List<OntAnnotation>> mapWithAnnots) throws Exception {
        StringBuilder rgdIds = new StringBuilder();
        for( Map.Entry<Term, List<OntAnnotation>> entry: mapWithAnnots.entrySet() ) {
            for( OntAnnotation annot: entry.getValue() ) {
                if( rgdIds.length()>0 ) {
                    rgdIds.append(",");
                }
                rgdIds.append(annot.getRgdId());
            }
        }
        return rgdIds.toString();
    }

    static public void loadAnnotations(OntAnnotBean bean, OntologyXDAO dao, HttpServletRequest request, int maxAnnotCount, String oKey) throws Exception {

        loadAnnotations(bean, dao,
                request.getParameter("acc_id"),
                request.getParameter("species"),
                request.getParameter("with_children"),
                request.getParameter("sort_by"),
                request.getParameter("sort_desc"),
                oKey,
                request.getParameter("x"),
                maxAnnotCount);
    }

    static public void loadAnnotationsForReference(OntAnnotBean bean, OntologyXDAO dao, int rgdId, String species, String displayDescendants,
                                       String sortBy, String sortDesc, String objectKey, String extendedView, int maxAnnotCount) throws Exception {

        bean.setExtendedView(false);
        if( extendedView!=null ) {
            if( Integer.parseInt(extendedView)>0 )
                bean.setExtendedView(true);
        }


        if (objectKey != null) {
            bean.setObjectKey(Integer.parseInt(objectKey));
        }

        boolean withChildren = true; // display gene annotations for term and all child terms; default is true
        int withKids = 1;
        if( displayDescendants!=null &&  displayDescendants.equals("0") ) {
            withChildren = false; // override to turn off showing the descendants
            withKids=0;
        }
        bean.setWithChildren(withChildren);

        // species filter (validate)
        if( species==null ) {
            species = "Rat";
        } else {
            int pos = species.indexOf('?');
            if( pos>0 )
                species = species.substring(0, pos);
        }
        int speciesTypeKey = SpeciesType.parse(species);
        if( speciesTypeKey==SpeciesType.UNKNOWN ) {
            speciesTypeKey = SpeciesType.RAT;
        }
        bean.setSpeciesTypeKey(speciesTypeKey);
        species = SpeciesType.getCommonName(speciesTypeKey);
        bean.setSpecies(species);

//        TermWithStats ts = dao.getTermWithStatsCached(bean.getAccId());
//        bean.setTerm(ts);
        // handle invalid term acc id
//        if( bean.getTerm()==null ) {
//            return; // invalid acc id -- nothing more to do
//        }

//        if (ts.getStat("annotated_object_count",speciesTypeKey,bean.getObjectKey(),withKids) < 1) {
//
//            if (ts.getStat("annotated_object_count",speciesTypeKey,1,withKids) > 0){
//                bean.setObjectKey(1);
//            }else  if (ts.getStat("annotated_object_count",speciesTypeKey,6,withKids) > 0){
//                bean.setObjectKey(6);
//            }else  if (ts.getStat("annotated_object_count",speciesTypeKey,5,withKids) > 0){
//                bean.setObjectKey(5);
//            }else  if (ts.getStat("annotated_object_count",speciesTypeKey,7,withKids) > 0){
//                bean.setObjectKey(7);
//            }else  if (ts.getStat("annotated_object_count",speciesTypeKey,11,withKids) > 0){
//                bean.setObjectKey(11);
//            }
//        }

        // load term synonyms
//        List<TermSynonym> synonyms = dao.getTermSynonyms(accId);
//        bean.setTermSynonyms(synonyms);
//        // sort synonyms by type and name
//        OntViewController.sortSynonyms(synonyms);

//        Map<Term, List<OntAnnotation>> mapWithAnnots = new HashMap<Term, List<OntAnnotation>>();

        withKids = 0;
        if (bean.isWithChildren()) {
            withKids=1;
        }

//        if (ts.getStat("annotated_object_count",bean.getSpeciesTypeKey(),bean.getObjectKey(),withKids) < maxAnnotCount) {
//            mapWithAnnots = loadAnnotations(bean, withChildren, maxAnnotCount);
//        }
//
//        // load gene,qtl and strain annotations for the term
//        bean.setAnnots(mapWithAnnots);

        // load map positions for the annotations specific to given species
//        if( speciesTypeKey!=SpeciesType.ALL ) {
//            loadMapPositions(mapWithAnnots, speciesTypeKey);
//        }else {
//            loadMapPositions(mapWithAnnots);
//        }
        // the rest of parameters: 'sort_by' and 'sort_desc'
        if( sortBy==null || sortBy.isEmpty() )
            sortBy = "symbol"; // default sort by symbol
        if( !bean.isExtendedView() && bean.isExtendedSortBy(sortBy) )
            sortBy = "symbol"; // default sort by symbol
        bean.setSortBy(sortBy);

        if( sortDesc!=null && sortDesc.equals("1") )
            bean.setSortDesc(true);

        // sort the objects
//        sort(mapWithAnnots, bean.getSortBy(), bean.isSortDesc());
        loadPhenominerAnnotations(bean, rgdId, withChildren);
    }
    static void loadPhenominerAnnotations(OntAnnotBean bean, int rgdId, boolean withChildren) throws Exception {

        //
        withChildren = false;

        // build map with annotations
        Set<Term> strainTerms = new TreeSet<Term>(new Comparator<Term>() {
            public int compare(Term t1, Term t2) {
                return Utils.stringsCompareToIgnoreCase(t1.getTerm(), t2.getTerm());
            }
        });

        Set<Term> cmoTerms = new TreeSet<Term>(new Comparator<Term>() {
            public int compare(Term t1, Term t2) {
                return Utils.stringsCompareToIgnoreCase(t1.getTerm(), t2.getTerm());
            }
        });

        Set<Term> mmoTerms = new TreeSet<Term>(new Comparator<Term>() {
            public int compare(Term t1, Term t2) {
                return Utils.stringsCompareToIgnoreCase(t1.getTerm(), t2.getTerm());
            }
        });

        Set<Term> xcoTerms = new TreeSet<Term>(new Comparator<Term>() {
            public int compare(Term t1, Term t2) {
                return Utils.stringsCompareToIgnoreCase(t1.getTerm(), t2.getTerm());
            }
        });


        // first get the list of record ids
        PhenominerDAO phDAO = new PhenominerDAO();
        OntologyXDAO ontDAO = new OntologyXDAO();

        List<Record> records = phDAO.getFullRecords(rgdId);

//        List<Integer> annotIds;
//        if( withChildren )
//            annotIds = phDAO.getAnnotationsForTermAndDescendants(bean.getAccId());
//        else
//            annotIds = phDAO.getAnnotationsForTerm(bean.getAccId());

//        for( int recordId: annotIds ) {
        for (Record rec : records){
//            Record rec = record;

            // strain ontology term
            String accId = rec.getSample().getStrainAccId();
            Term term = ontDAO.getTermWithStatsCached(accId);
            if( term!=null ) {
                strainTerms.add(term);
            }

            // cmo term
            accId = rec.getClinicalMeasurement().getAccId();
            term = ontDAO.getTermWithStatsCached(accId);
            if( term!=null ) {
                cmoTerms.add(term);
            }

            // mmo term
            accId = rec.getMeasurementMethod().getAccId();
            term = ontDAO.getTermWithStatsCached(accId);
            if( term!=null ) {
                mmoTerms.add(term);
            }

            // xco term
            for( Condition cond: rec.getConditions() ) {
                accId = cond.getOntologyId();
                term = ontDAO.getTermWithStatsCached(accId);
                if( term!=null ) {
                    xcoTerms.add(term);
                }
            }
        }

        bean.setPhenoStrains(strainTerms);
        bean.setPhenoCmoTerms(cmoTerms);
        bean.setPhenoMmoTerms(mmoTerms);
        bean.setPhenoXcoTerms(xcoTerms);
    }


}

