package edu.mcw.rgd.phenominer.expectedRanges.controller;


import edu.mcw.rgd.dao.impl.PhenominerExpectedRangeDao;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.PhenominerExpectedRange;
import edu.mcw.rgd.process.pheno.phenominerExpectedRanges.ExpectedRangeProcess;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


/**
 * Created by jthota on 5/17/2018.
 */
public class PhenotypeOptionsController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ModelMap model= new ModelMap();
        ExpectedRangeProcess process= new ExpectedRangeProcess();
        PhenominerExpectedRangeDao dao=new PhenominerExpectedRangeDao();

        String strainsSelected=request.getParameter("phenotypestrains");
        String conditionsSelected=request.getParameter("selectedConditions");
        String methodsSelected= request.getParameter("methods");
        String ageSelected=request.getParameter("phenotypeage");
        String sexSelected= request.getParameter("phenotypesex");
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
            System.out.println("methods selected: "+ methodsSelected);
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

        model.addAttribute("plotData",  process.getPlotData(records,"phenotype"));
        model.addAttribute("records", process.addExtraAttributes(records));
        model.addAttribute("phenotype", phenotype);
        model.addAttribute("phenotypeAccId",phenotypeAccId);

        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominerExpectedRanges/views/rangePhenotypeContent.jsp", "model", model);

    }
}
