package edu.mcw.rgd.phenominer.expectedRanges.controller;

import edu.mcw.rgd.dao.impl.OntologyXDAO;


import edu.mcw.rgd.dao.impl.PhenominerExpectedRangeDao;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.PhenominerExpectedRange;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.PhenotypeObject;

import edu.mcw.rgd.phenominer.expectedRanges.model.NormalRange;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.pheno.phenominerExpectedRanges.ExpectedRangeProcess;

import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.*;

/**
 * Created by jthota on 3/29/2018.
 */
public class SelectedMeasurementController implements Controller {

    OntologyXDAO xdao = new OntologyXDAO();
    ExpectedRangeProcess process = new ExpectedRangeProcess();
    PhenominerExpectedRangeDao dao = new PhenominerExpectedRangeDao();

    private Map<String, PhenotypeObject> cache = new HashMap<>();

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelMap model = new ModelMap();


        HttpSession session = request.getSession();
        List<PhenotypeObject> phenotypes = (List<PhenotypeObject>) session.getAttribute("phenotypes");
        Map<String,Integer> strainGroupMap = (Map<String, Integer>) session.getAttribute("strainGroupMap");

        NormalRange normalRange= new NormalRange();

        String cmoID = request.getParameter("cmo");

        String phenotype = xdao.getTerm(cmoID).getTerm();
        String traitOntId = request.getParameter("trait");
        String traitExists= request.getParameter("traitExists");

        boolean isPGA = false;
        String trait= new String();
        if (traitOntId != null) {
            if (traitOntId.equals("pga")) {
                isPGA = true;

            }else
            if(!Objects.equals(traitOntId, ""))
                trait=xdao.getTerm(traitOntId).getTerm();
            else{
                if(traitExists!=null && traitExists.equals("false")){
                    isPGA=true;
                }else
                isPGA=false;
            }
        } else {
            isPGA = true;
        }
        String strainsSelected=request.getParameter("phenotypestrains");

        String conditionsSelected=request.getParameter("selectedConditions");
        String methodsSelected= request.getParameter("methods");
        String ageSelected=request.getParameter("phenotypeage");
        String sexSelected= request.getParameter("phenotypesex");
        List<String> selectedConditions= new ArrayList<>();
        List<String> selectedMethods= new ArrayList<>();
        List<String> selectedSex= new ArrayList<>();
        List<Integer> selectedAgeLow=new ArrayList<>();
        List<Integer> selectedAgeHigh= new ArrayList<>();
        List<Integer> selectedStrains= new ArrayList<>();

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

        List<PhenominerExpectedRange> records = dao.getExpectedRanges(cmoID, selectedStrains, selectedSex, selectedAgeLow,selectedAgeHigh, selectedMethods, isPGA);
        if(request.getParameter("options")!=null && request.getParameter("options").equalsIgnoreCase("true")) {
            normalRange= (NormalRange) session.getAttribute("normalRange");

            if(strainGroupMap==null ||  strainGroupMap.size()==0){
                strainGroupMap=process.getStrainGroupMap(records);
            }
        }else {
            PhenominerExpectedRange normalRecord = getPhenotypeExpectedRangeRecordNormal(records, "Mixed");
            PhenominerExpectedRange normalMaleRecord = getPhenotypeExpectedRangeRecordNormal(records, "Male");
            PhenominerExpectedRange normalFemaleRecord = getPhenotypeExpectedRangeRecordNormal(records, "Female");
            if (normalRecord != null) {
                normalRange.setMixed(normalRecord);
                //   System.out.println("NORMAL RECORD:" +object.getNormalAll().getGroupLow()+"\t" +object.getNormalAll().getGroupHigh());
            }
            if (normalMaleRecord != null) {
                normalRange.setMale(normalMaleRecord);
            }

            if (normalFemaleRecord != null) {
                normalRange.setFemale(normalFemaleRecord);

            }
           strainGroupMap=process.getStrainGroupMap(records);
        }
        records.sort((o1, o2) -> Utils.stringsCompareToIgnoreCase(o1.getStrainGroupName(), o2.getStrainGroupName()));
        String units=new String();
        if(records.size()>0){
            String  unitsStr  =records.get(0).getUnits();
            units= unitsStr.substring(1, unitsStr.length()-1);
        }

        session.setAttribute("phenotypes", phenotypes);
        session.setAttribute("normalRange", normalRange);
        session.setAttribute("strainGroupMap",strainGroupMap );


        model.addAttribute("units", units);
        model.addAttribute("overAllMethods", process.getMethodOptions(records));
        model.addAttribute("records", process.addExtraAttributes(records));

        model.addAttribute("phenotype", phenotype);
        model.addAttribute("cmo", cmoID);
        model.addAttribute("phenotypes", phenotypes);
        model.addAttribute("plotData", process.getPlotData(records, "phenotype"));
        model.addAttribute("traitOntId", traitOntId);
        model.addAttribute("trait", trait);
        model.addAttribute("strainGroupMap",strainGroupMap );
        model.addAttribute("conditions", Arrays.asList("Control Conditions"));
        model.addAttribute("normalRange", normalRange);
        model.addAttribute("selectedStrains", selectedStrains);
        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominerExpectedRanges/views/phenotype.jsp", "model", model);
    }

    public PhenominerExpectedRange getPhenotypeExpectedRangeRecordNormal(List<PhenominerExpectedRange> records, String sex){
        for(PhenominerExpectedRange r:records){
            PhenominerExpectedRange normalStrain= new PhenominerExpectedRange();

            if(r.getExpectedRangeName().contains("NormalStrain")){
                if(r.getSex().equalsIgnoreCase(sex) && r.getAgeLowBound()==0 && r.getAgeHighBound() == 999){
                    normalStrain.setRangeValue(r.getRangeValue());
                    normalStrain.setRangeLow(r.getRangeLow());
                    normalStrain.setRangeHigh(r.getRangeHigh());
                    return normalStrain;
                }

            }


        }
        return null;
    }

}
