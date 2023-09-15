package edu.mcw.rgd.phenotype.phenotypeExpectedRanges;


import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.dao.PhenotypeExpectedRangeDao;

import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.ExpectedRangeRecord;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.PhenotypeObject;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.*;

/**
 * Created by jthota on 3/7/2018.
 */
public class SelectedStrainController implements Controller{
    PhenotypeExpectedRangeDao dao= new PhenotypeExpectedRangeDao();
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelMap model= new ModelMap();
        PhenotypeObject phenotypeObject= (PhenotypeObject) request.getSession().getAttribute("phenotypeObject");
        List<PhenotypeObject> phenotypes= (List<PhenotypeObject>) request.getSession().getAttribute("phenotypes");

        HttpSession session= request.getSession();
        session.setAttribute("phenotypeObject", phenotypeObject);

        String strainsSelected=request.getParameter("selectedStrains");
        String conditionsSelected=request.getParameter("selectedConditions");
        String methodsSelected= request.getParameter("selectedMethods");
        String ageSelected=request.getParameter("selectedAge");
        String sexSelected= request.getParameter("selectedSex");
        String phenotypeAccId=request.getParameter("cmo");
        String phenotype=dao.getTerm(phenotypeAccId).getTerm();


        List<Integer> selectedStrains= new ArrayList<>();
        List<String> selectedConditions= new ArrayList<>();
        List<String> selectedMethods= new ArrayList<>();
        List<String> selectedSex= new ArrayList<>();
        List<Integer> selectedAgeLow=new ArrayList<>();
        List<Integer> selectedAgeHigh= new ArrayList<>();
        List<String> selectedAge= new ArrayList<>();

     /*   if(conditionsSelected!=null){
            if(!conditionsSelected.equals("")){
                selectedConditions=this.getSelectedCondtions(conditionsSelected);
            }
        }*/
        if(strainsSelected!=null){
            if(!strainsSelected.equals("")){
                selectedStrains=this.getSelectedStrainsGroupIds(strainsSelected);
            }
        }
       if(methodsSelected!=null){
            //System.out.println("methods selected: "+ methodsSelected);
            if(!methodsSelected.equals(""))
            selectedMethods=this.getSelectedMethods(methodsSelected);
        }
        if(sexSelected!=null){
            if(!sexSelected.equals("")){
                selectedSex=this.getSelectedSex(sexSelected);
            }
        }
        if(ageSelected!=null){
            if(!ageSelected.equals("")){
                selectedAgeLow= this.getSelectedAge(ageSelected, "low");
                selectedAgeHigh=this.getSelectedAge(ageSelected, "high");
                selectedAge= this.getSelectedAgeRange(ageSelected);
            }
        }
        String normalRecordSex=new String();
        if(selectedSex.size()>1 || selectedSex.size()==0){
           normalRecordSex="Both";
        }else{
            normalRecordSex=selectedSex.get(0);
        }
        PhenotypeObject newPhenotypeObject= new PhenotypeObject();

        List<ExpectedRangeRecord> records=this.getExpectedRangeRecords(phenotype, selectedStrains, selectedSex,selectedAge, selectedMethods);
     //   List<ExpectedRangeRecord> records=dao1.getPhenotypeExpectedRangeRecordsByPhenotype(phenotype, selectedStrains, selectedSex, selectedAgeLow,selectedAgeHigh, selectedMethods);
            if(records!=null){
                if(records.size()>0){
                    List<String> methodAccIds=new ArrayList<>();
                   /* for(ExpectedRangeRecord record:records){
                        for(String m:record.getMethodAccIds()){
                            if(!methodAccIds.contains(m)){
                                methodAccIds.addAll(record.getMethodAccIds());
                            }
                        }

                    }*/
                    newPhenotypeObject =dao.getPhenotypeObject(records, methodAccIds, selectedConditions);
                    ExpectedRangeRecord normalRecord=dao.getPhenotypeExpectedRangeRecordNormal(records,normalRecordSex);
                    model.addAttribute("normalRecord", normalRecord);
                    model.addAttribute("newPhenotypeObject", newPhenotypeObject);
                    model.addAttribute("selectedMethods", methodsSelected);
                }else{
                   model.addAttribute("selectedStrains", selectedStrains);
                    model.addAttribute("selectedConditions", conditionsSelected);
                    model.addAttribute("selectedMethods", methodsSelected);
                }
            }
        List<String> sex=new ArrayList<>(Arrays.asList("Both", "Female", "Male"));
        List<String> age= new ArrayList<>(Arrays.asList("0 - 79", "80 - 99", "100 - 999", "0 - 999"));
        model.addAttribute("plotData",  dao.getPlotData(records,"phenotype"));
        model.addAttribute("records", records);
        model.addAttribute("phenotype", phenotype);
        model.addAttribute("phenotypes", phenotypes);
        model.addAttribute("phenotypeAccId",phenotypeAccId);
        model.addAttribute("phenotypeObject", phenotypeObject);

        model.addAttribute("selectedAge", selectedAge);
        model.addAttribute("selectedSex", selectedSex);
        model.addAttribute("sex", sex);
        model.addAttribute("age", age);


        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominerExpectedRanges/selectedPhenotype.jsp", "model", model);
    }
    public List<String> getSelectedCondtions(String conditionsSelected){
        List<String> selectedConditions= new ArrayList<>();
        StringTokenizer conditionTokens= new StringTokenizer(conditionsSelected,",");
        while (conditionTokens.hasMoreTokens()){
            selectedConditions.add(conditionTokens.nextToken());
        }
        return selectedConditions;
    }
    public List<Integer> getSelectedStrainsGroupIds(String strainsSelected){
        List<Integer> selectedStrains= new ArrayList<>();
        StringTokenizer strainTokens= new StringTokenizer(strainsSelected,",");
        while (strainTokens.hasMoreTokens()){
            selectedStrains.add(Integer.parseInt(strainTokens.nextToken()));
        }
        return selectedStrains;
    }
    public List<String> getSelectedMethods(String methodsSelected){
        List<String> selectedMethods= new ArrayList<>();
        StringTokenizer methodTokens= new StringTokenizer(methodsSelected, ",");
        while(methodTokens.hasMoreTokens()){
            String selectedMethod=methodTokens.nextToken();
            if(!selectedMethods.contains(selectedMethod))
            selectedMethods.add(selectedMethod);
        }
        return selectedMethods;
    }
    public List<String> getSelectedSex(String sexSelected){
        List<String> selectedSex= new ArrayList<>();
        StringTokenizer sexTokens= new StringTokenizer(sexSelected, ",");
        while(sexTokens.hasMoreTokens()){
            selectedSex.add(sexTokens.nextToken());
        }
        return selectedSex;
    }
    public List<Integer> getSelectedAge(String ageSelected, String lowOrHigh){
        List<Integer> selectedAgeLow= new ArrayList<>();
        List<Integer> selectedAgeHigh= new ArrayList<>();

        StringTokenizer ageTokens= new StringTokenizer(ageSelected, ",");

        while(ageTokens.hasMoreTokens()){
            String token=ageTokens.nextToken();
            String[] age= token.split("-");
            if(!age[0].trim().equals("0")) {
                int ageLow=Integer.parseInt(age[0].trim());
                if(!selectedAgeLow.contains(ageLow))
                selectedAgeLow.add(Integer.parseInt(age[0].trim()));
            }
            else selectedAgeLow.add(0);
            selectedAgeHigh.add(Integer.parseInt(age[1].trim()));
           }
        if(lowOrHigh.equalsIgnoreCase("low"))
        return selectedAgeLow;
        else
            return selectedAgeHigh;

    }

    public List<String> getSelectedAgeRange(String ageSelected){
       List<String> ageRange= new ArrayList<>();
        StringTokenizer ageTokens= new StringTokenizer(ageSelected, ",");

        while(ageTokens.hasMoreTokens()) {
            String token = ageTokens.nextToken();
            ageRange.add(token);
        }
    return ageRange;
    }
    public List<ExpectedRangeRecord> getExpectedRangeRecords(String phenotype, List<Integer> selectedStrains, List<String> selectedSex,List<String> selectedAge, List<String> selectedMethods) throws Exception {
       List<ExpectedRangeRecord> records= new ArrayList<>();

        for(String s:selectedAge){
            List<Integer> ageLow=new ArrayList<>();
            List<Integer> ageHigh= new ArrayList<>();
            String[] age= s.split("-");
            ageLow.add(Integer.parseInt(age[0].trim()));
            ageHigh.add(Integer.parseInt(age[1].trim()));
            records.addAll(dao.getPhenotypeExpectedRangeRecordsByPhenotype(phenotype, selectedStrains, selectedSex, ageLow,ageHigh, selectedMethods));
        }
        return records;
    }
}
