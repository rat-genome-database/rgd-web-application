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
 * Created by jthota on 3/28/2018.
 */
public class ExpectedRangeHomeController implements Controller {
    private Map<String, List<PhenotypeObject>> overAllObjectsCache= new HashMap<>();
    private Map<String,  List<Term>> distinctTraitsCache=new HashMap<>();

   @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
       ExpectedRangeProcess process = new ExpectedRangeProcess();


        OntologyXDAO xdao = new OntologyXDAO();


       ModelMap model = new ModelMap();
       String traitOntId = request.getParameter("trait"); // if selected trait facet
       String trait = null;
       boolean isPGA = false;

       if (traitOntId != null && !traitOntId.equals("") && !traitOntId.equalsIgnoreCase("pga")) trait = xdao.getTerm(traitOntId).getTerm();
       if (traitOntId != null && traitOntId.equalsIgnoreCase("pga")) isPGA = true;

       if(traitOntId != null &&traitOntId.equals("")){
           traitOntId=null;
       }
     List<String> phenotypes = process.getPhenotypesByAncestorTrait(traitOntId);
   //    List<String> phenotypes =new ArrayList<>(Arrays.asList("CMO:0001556"));

       Map<String, String> tMap = process.getDistinctExpectedRangeTraits();
       Map<List<Term>, List<PhenotypeObject>> objectsNTraits;
       List<PhenotypeObject> overallObjects = new ArrayList<>();
       List<Term> distinctTraits = new ArrayList<>();
       Term pgaTerm = new Term();
       pgaTerm.setTerm("pga");
       distinctTraits.add(pgaTerm);
       if(traitOntId==null){
           if(overAllObjectsCache.get("all")!=null  && distinctTraitsCache.get("all")!=null){ //check if the overallObjects is cached
               overallObjects=overAllObjectsCache.get("all");
               distinctTraits=distinctTraitsCache.get("all");
            //   System.out.println("OVERALL OBJECT SIZE:"+overallObjects.size());
           }else{
               // Map<list of traits, List of phenotypeObjects>
               objectsNTraits= process.getOverAllObjectsNDistinctTraits(phenotypes,null, isPGA);
               for(Map.Entry e:objectsNTraits.entrySet()){
                  distinctTraits.addAll((List<Term>) e.getKey());
                 overallObjects.addAll((List<PhenotypeObject>) e.getValue());
               }
                overallObjects.sort((o1, o2) -> Utils.stringsCompareToIgnoreCase(o1.getClinicalMeasurement(), o2.getClinicalMeasurement()));
                   overAllObjectsCache.put("all", overallObjects);
                   distinctTraitsCache.put("all", distinctTraits);

           }
       }else{
           if(overAllObjectsCache.get(traitOntId)!=null  && distinctTraitsCache.get(traitOntId)!=null){
               overallObjects=overAllObjectsCache.get(traitOntId);
               distinctTraits=distinctTraitsCache.get(traitOntId);
           //    System.out.println("OVERALL OBJECT SIZE:"+overallObjects.size());
           }else{
               objectsNTraits= process.getOverAllObjectsNDistinctTraits(phenotypes,traitOntId, isPGA);
               for(Map.Entry e:objectsNTraits.entrySet()){
                   distinctTraits.addAll((List<Term>) e.getKey());
                   overallObjects.addAll((List<PhenotypeObject>) e.getValue());
               }
               overallObjects.sort((o1, o2) -> Utils.stringsCompareToIgnoreCase(o1.getClinicalMeasurement(), o2.getClinicalMeasurement()));


               if(!traitOntId.equalsIgnoreCase("pga")) {
                   overAllObjectsCache.put(traitOntId, overallObjects);
                   distinctTraitsCache.put(traitOntId, distinctTraits);
               }
           }
       }

       distinctTraits.sort((o1,o2)->Utils.stringsCompareToIgnoreCase(o1.getTerm(), o2.getTerm()));

       List<StrainObject> strainObjects=process.getStrainGroups(traitOntId);
        HttpSession session= request.getSession();
        session.setAttribute("phenotypes",overallObjects);
        session.setAttribute("strainObjects", strainObjects);

        Map<Term, List<PhenotypeObject>> traitSubtraitMap= process.getTraitSubtraitMap(distinctTraits, overallObjects);
      //  System.out.println("TRAIT SUBTRAIT SIZE:"+traitSubtraitMap.size());

        model.addAttribute("traitSubtraitMap",traitSubtraitMap);
        model.addAttribute("counts", overallObjects);
        model.addAttribute("traitOntId", traitOntId);
        model.addAttribute("traitMap", tMap);
        model.addAttribute("strainObjects", strainObjects);

        if(trait!=null)
        model.addAttribute("trait", trait);
        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominerExpectedRanges/views/home.jsp", "model", model);
    }

}
