package edu.mcw.rgd.phenominer.expectedRanges.controller;

import edu.mcw.rgd.dao.impl.PhenominerExpectedRangeDao;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.PhenominerExpectedRange;
import edu.mcw.rgd.phenominer.expectedRanges.model.NormalRange;
import edu.mcw.rgd.process.pheno.phenominerExpectedRanges.ExpectedRangeProcess;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by jthota on 5/14/2018.
 */
public class StrainOptionsController implements Controller{
    PhenominerExpectedRangeDao dao= new PhenominerExpectedRangeDao();
    ExpectedRangeProcess process= new ExpectedRangeProcess();

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ModelMap model= new ModelMap();
        String selectedPhenotypes= request.getParameter("phenotypes");
        String selectedSex=request.getParameter("sex");
        String selectedAge=request.getParameter("age");
        String strainGroupId= request.getParameter("strainGroupId");
        String traitOntId= request.getParameter("trait");
        String methodsSelected= request.getParameter("methods");
        String strainGroupName=process.getStrainGroupName(Integer.parseInt(strainGroupId));
        List<String> sexList=new ArrayList<>();
        List<Integer> ageLow= new ArrayList<>();
        List<Integer> ageHigh=new ArrayList<>();
        List<String> selectedMethods= new ArrayList<>();
        HttpSession session = request.getSession();

        NormalRange normalRange= (NormalRange) session.getAttribute("normalRange");

        boolean isPGA=false;
        if(traitOntId==null){
            isPGA=true;
        }
        if(traitOntId!=null && traitOntId.equals("")){
            traitOntId=null;
        }
        if(selectedSex!=null && !selectedSex.equals("")){
         sexList.addAll(Arrays.asList(selectedSex.split(",")));
        }

        if(selectedAge!=null){
            if(!selectedAge.equals("")){
                ageLow= process.getSelectedAge(selectedAge, "low");
                ageHigh=process.getSelectedAge(selectedAge, "high");

            }
        }
        if(methodsSelected!=null){
           if(!methodsSelected.equals(""))
                selectedMethods=process.getSelectedMethods(methodsSelected);
        }
        List<PhenominerExpectedRange> records = dao.getExpectedRanges(Arrays.asList(selectedPhenotypes.split(",")), Arrays.asList(Integer.parseInt(strainGroupId)),sexList ,ageLow,ageHigh, selectedMethods,isPGA, null);
        model.put("strainGroup", strainGroupName);
        model.put("strainGroupId", strainGroupId);
        model.put("ranges", process.addExtraAttributes(records));
        model.addAttribute("plotData",  process.getPlotData(records, "strain"));
        model.addAttribute("normalRange", normalRange);
        String unitsStr=records.get(0).getUnits();
        String units=unitsStr.substring(1, unitsStr.length()-1);
        model.addAttribute("units", units);
        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominerExpectedRanges/views/rangeStrainContent.jsp","model", model);
    }
}
