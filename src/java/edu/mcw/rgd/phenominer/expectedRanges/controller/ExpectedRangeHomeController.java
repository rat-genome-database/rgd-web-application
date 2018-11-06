package edu.mcw.rgd.phenominer.expectedRanges.controller;


import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.PhenotypeObject;

import edu.mcw.rgd.datamodel.phenominerExpectedRange.StrainObject;
import edu.mcw.rgd.process.Utils;

import edu.mcw.rgd.process.pheno.phenominerExpectedRanges.ExpectedRangeProcess;

import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;


import java.util.*;

/**
 * Created by jthota on 10/22/2018.
 */
public class ExpectedRangeHomeController implements Controller {
    private Map<String, List<PhenotypeObject>> overAllObjectsCache = new HashMap<>();
    private Map<String, List<Term>> distinctTraitsCache = new HashMap<>();
    private Map<Term, Integer> facetCounts= new HashMap<>();

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        OntologyXDAO xdao=new OntologyXDAO();
        ExpectedRangeProcess process= new ExpectedRangeProcess();

        ModelMap model=new ModelMap();
        String traitOntId=request.getParameter("trait");
        List<PhenotypeObject> overAllObjects= new ArrayList<>();
        List<Term> distinctTraits = new ArrayList<>();
        Map<List<Term>, List<PhenotypeObject>> objectsNTraits;

        List<String> phenotypes=process.getPhenotypesByAncestorTrait(traitOntId);
        boolean selectByTrait=false;
        String trait = null;
        if(traitOntId!=null) {
            if(!traitOntId.equals("")) {
                selectByTrait = true;
                trait = xdao.getTerm(traitOntId).getTerm();
            }
           }

        if(selectByTrait){
            if(overAllObjectsCache.get(traitOntId)!=null  && distinctTraitsCache.get(traitOntId)!=null){
                overAllObjects=overAllObjectsCache.get(traitOntId);
                distinctTraits=distinctTraitsCache.get(traitOntId);

            }else{
                objectsNTraits= process.getOverAllObjectsNDistinctTraits(phenotypes,traitOntId, selectByTrait);
                for(Map.Entry e:objectsNTraits.entrySet()){
                    distinctTraits.addAll((List<Term>) e.getKey());
                    overAllObjects.addAll((List<PhenotypeObject>) e.getValue());
                }
                overAllObjects.sort((o1, o2) -> Utils.stringsCompareToIgnoreCase(o1.getClinicalMeasurement(), o2.getClinicalMeasurement()));
                distinctTraits.sort((o1,o2)->Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm()));
                overAllObjectsCache.put(traitOntId, overAllObjects);
                distinctTraitsCache.put(traitOntId, distinctTraits);

            }

        }else{
            if(overAllObjectsCache.get("all")!=null  && distinctTraitsCache.get("all")!=null){ //check if the overallObjects is cached
                overAllObjects=overAllObjectsCache.get("all");
                distinctTraits=distinctTraitsCache.get("all");

            }else{

                objectsNTraits= process.getOverAllObjectsNDistinctTraits(phenotypes,null, selectByTrait);
                for(Map.Entry e:objectsNTraits.entrySet()){
                    distinctTraits.addAll((List<Term>) e.getKey());
                    overAllObjects.addAll((List<PhenotypeObject>) e.getValue());
                }
                overAllObjects.sort((o1, o2) -> Utils.stringsCompareToIgnoreCase(o1.getClinicalMeasurement(), o2.getClinicalMeasurement()));
                distinctTraits.sort((o1,o2)->Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm()));
                overAllObjectsCache.put("all", overAllObjects);
                distinctTraitsCache.put("all", distinctTraits);

            }
        }
        System.out.println("FACETCOUNTS SIZE: "+ facetCounts.size());
        if(facetCounts.size()==0) {
            facetCounts.putAll(process.getAggregationByTraitCounts());
        }

        Map<Term, Integer> sortedFacets = new TreeMap<Term, Integer>(new Comparator<Term>() {
            @Override
            public int compare(Term o1, Term o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm());
            }
        });
        List<PhenotypeObject> phenotypeObjects= new ArrayList<>();
        for(PhenotypeObject obj:overAllObjects){
            if(!containsObj(phenotypeObjects, obj)){
                phenotypeObjects.add(obj);
            }
        }
        sortedFacets.putAll(facetCounts);
        model.put("objectsSize", overAllObjects.size());
        model.put("traitMap", process.getDistinctExpectedRangeTraits());
        List<StrainObject> strainObjects=process.getStrainGroups(traitOntId);
        HttpSession session= request.getSession();
        session.setAttribute("phenotypes",phenotypeObjects);
        session.setAttribute("strainObjects", strainObjects);

        Map<Term, List<PhenotypeObject>> traitSubtraitMap= process.getTraitSubtraitMap(distinctTraits, overAllObjects);

        model.addAttribute("traitSubtraitMap",traitSubtraitMap);
        model.addAttribute("counts", overAllObjects);
        model.addAttribute("traitOntId", traitOntId);
        model.addAttribute("strainObjects", strainObjects);
        model.addAttribute("facets", sortedFacets);
        if(trait!=null)
            model.addAttribute("trait", trait);
        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominerExpectedRanges/views/home.jsp", "model", model);

    }

    public boolean containsObj(List<PhenotypeObject> objects, PhenotypeObject obj){
        for(PhenotypeObject o:objects){
            if(obj.getClinicalMeasurementOntId().equals(o.getClinicalMeasurementOntId())){
                return true;
            }
        }
        return false;
    }
}

