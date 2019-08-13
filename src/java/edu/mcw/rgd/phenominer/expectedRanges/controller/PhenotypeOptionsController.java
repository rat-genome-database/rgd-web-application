package edu.mcw.rgd.phenominer.expectedRanges.controller;


import edu.mcw.rgd.dao.impl.PhenominerExpectedRangeDao;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.PhenominerExpectedRange;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.PhenotypeObject;
import edu.mcw.rgd.phenominer.expectedRanges.model.NormalRange;
import edu.mcw.rgd.process.pheno.phenominerExpectedRanges.ExpectedRangeProcess;
import org.springframework.http.HttpRequest;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;


/**
 * Created by jthota on 5/17/2018.
 */
public class PhenotypeOptionsController extends SelectedMeasurementController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ModelMap model= new ModelMap();
        ExpectedRangeProcess process= new ExpectedRangeProcess();
        PhenominerExpectedRangeDao dao=new PhenominerExpectedRangeDao();

        String strainsSelected=request.getParameter("phenotypestrains");
        String conditionsSelected=request.getParameter("selectedConditions");
        String methodsSelected= request.getParameter("phenotypemethods");
        String ageSelected=request.getParameter("phenotypeage");
        String sexSelected= request.getParameter("phenotypesex");
      //  String phenotypeAccId=request.getParameter("cmo");
        String phenotypeAccId=request.getParameter("cmo");
        String phenotype=process.getTerm(phenotypeAccId).getTerm();
        String traitOntId=request.getParameter("trait");

        List<String> cmoIds= new ArrayList<>(Arrays.asList(phenotypeAccId));

        boolean isPGA=false;
        if(traitOntId==null){
            isPGA=true;
        }

        List<Integer> selectedStrains= new ArrayList<>();

        List<String> selectedConditions= new ArrayList<>();
        List<String> selectedMethods= new ArrayList<>();
        List<String> selectedSex= new ArrayList<>();
        List<Integer> selectedAgeLow=new ArrayList<>();
        List<Integer> selectedAgeHigh= new ArrayList<>();


        if(conditionsSelected!=null){
            if(!conditionsSelected.equals("")){
                selectedConditions=process.getSelectedCondtions(conditionsSelected);
            }
        }
        if(strainsSelected!=null){
            if(!strainsSelected.equals("")){
                selectedStrains=process.getSelectedStrainsGroupIds(strainsSelected);
            }
        }
        if(methodsSelected!=null){
            System.out.println("selected methods: "+ methodsSelected);
            if(!methodsSelected.equals(""))
                selectedMethods=process.getSelectedMethods(methodsSelected);
        }
        if(sexSelected!=null){
            if(!sexSelected.equals("")){
                selectedSex=process.getSelectedSex(sexSelected);
            }
        }
        if(ageSelected!=null){
              if(!ageSelected.equals("")){
                selectedAgeLow= process.getSelectedAge(ageSelected, "low");
                selectedAgeHigh=process.getSelectedAge(ageSelected, "high");

            }
        }
        String normalRecordSex=new String();
        if(selectedSex.size()>1 || selectedSex.size()==0){
            normalRecordSex="Mixed";
        }else{
            normalRecordSex=selectedSex.get(0);
        }

        List<PhenominerExpectedRange> records=dao.getExpectedRanges(cmoIds, selectedStrains, selectedSex, selectedAgeLow,selectedAgeHigh, selectedMethods, isPGA, null);
        String units=new String();
        if(records.size()>0) {
            String unitsStr = records.get(0).getUnits();
           units=unitsStr.substring(1, unitsStr.length()-1);
        }

        HttpSession session= request.getSession();
        NormalRange normalRange= (NormalRange) session.getAttribute("normalRange");
        Map<String,Integer> strainGroupMap= (Map<String, Integer>) session.getAttribute("strainGroupMap");
        session.setAttribute("normalRange", normalRange);
        session.setAttribute("strainGroupMap", strainGroupMap);
        List<PhenotypeObject> phenotypes = (List<PhenotypeObject>) session.getAttribute("phenotypes");

        session.setAttribute("phenotypes", phenotypes);

        model.addAttribute("traitOntId", traitOntId);

        model.addAttribute("plotData",  process.getPlotData(records,"phenotype"));
        model.addAttribute("records", process.addExtraAttributes(records));
        model.addAttribute("phenotype", phenotype);
        model.addAttribute("phenotypeAccId",phenotypeAccId);
        model.addAttribute("cmo",phenotypeAccId);
        model.addAttribute("strainGroupMap", strainGroupMap);
        model.addAttribute("units", units);
        model.addAttribute("normalRange", normalRange);
        model.addAttribute("selectedStrains", selectedStrains);
        model.addAttribute("selectedSex", selectedSex);
        model.addAttribute("selectedMethods", selectedMethods);
        model.addAttribute("selectedAge", ageSelected);
        model.addAttribute("overAllMethods", process.getMethodOptions(records));

        model.addAttribute("phenotypes", phenotypes);
      //  return new ModelAndView("/WEB-INF/jsp/phenominer/phenominerExpectedRanges/views/rangePhenotypeContent.jsp", "model", model);
        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominerExpectedRanges/views/phenotype.jsp", "model", model);

    }
}
