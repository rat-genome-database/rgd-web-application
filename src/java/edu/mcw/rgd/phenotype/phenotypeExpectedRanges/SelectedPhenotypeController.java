package edu.mcw.rgd.phenotype.phenotypeExpectedRanges;


import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.dao.PhenotypeExpectedRangeDao;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.dao.StrainGroupDao;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.ExpectedRangeRecord;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.PhenotypeObject;

import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.*;

/**
 * Created by jthota on 3/5/2018.
 */
public class SelectedPhenotypeController implements Controller {
    StrainGroupDao sdao= new StrainGroupDao();
    PhenotypeExpectedRangeDao dao = new PhenotypeExpectedRangeDao();
    private Map<String, PhenotypeObject> cache= new HashMap<>();
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {


        ModelMap model= new ModelMap();
        PhenotypeObject object= new PhenotypeObject();
        HttpSession session= request.getSession();

        String cmoID=request.getParameter("cmo");
        String phenotype=dao.getTerm(cmoID).getTerm();

        List<String> age= new ArrayList<>(Arrays.asList("0 - 79", "80 - 99", "100 - 999", "0 - 999"));

        List<String> methods= new ArrayList<>(Arrays.asList("Vascular", "Tail Cuff", "Mixed"));


        List<PhenotypeObject> phenotypes= (List<PhenotypeObject>) request.getSession().getAttribute("phenotypes");
        List<ExpectedRangeRecord> records=dao.getPhenotypeExpectedRangeRecordsByPhenotype(phenotype);

        ExpectedRangeRecord normalRecord=dao.getPhenotypeExpectedRangeRecordNormal(records,"Mixed");
        ExpectedRangeRecord normalMaleRecord=dao.getPhenotypeExpectedRangeRecordNormal(records,"Male");
        ExpectedRangeRecord normalFemaleRecord=dao.getPhenotypeExpectedRangeRecordNormal(records,"Female");

        List<String> sex=  this.getSex(records);
        List<String> methodAccIds=new ArrayList<>();
        List<String> conditionAccIds= new ArrayList<>();
        List<String> strainGroups= dao.getDistinctStrainGroups(records);

        if(cache.containsKey(phenotype)){
            object=cache.get(phenotype);
        }else{
            object=dao.getPhenotypeObject(records, methodAccIds,conditionAccIds );
            cache.put(phenotype, object);
        }

        if(normalRecord!=null){
            object.setNormalAll(normalRecord);
         //   System.out.println("NORMAL RECORD:" +object.getNormalAll().getGroupLow()+"\t" +object.getNormalAll().getGroupHigh());
        }
        if(normalMaleRecord!=null) {
            object.setNormalMale(normalMaleRecord);
         }

        if(normalFemaleRecord!=null) {
            object.setNormalFemale(normalFemaleRecord);
        }

     //   List<String> sex=new ArrayList<>(Arrays.asList("Both", "Female", "Male"));

        object.setSex(sex);


        session.setAttribute("phenotypeObject", object);
        session.setAttribute("phenotypes", phenotypes);

        model.addAttribute("normalRecord", normalRecord);
        model.addAttribute("phenotype", phenotype);
        model.addAttribute("phenotypeAccId",cmoID);

        model.addAttribute("sex", sex);
        model.addAttribute("age", age);
        model.addAttribute("strainGroups", strainGroups);
        model.addAttribute("plotData",  dao.getPlotData(records, "phenotype"));
        model.addAttribute("records", records);
        model.addAttribute("phenotypeObject", object);
        model.addAttribute("phenotypes", phenotypes);
        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominerExpectedRanges/selectedPhenotype.jsp","model",model);
    }

    public List<String> getSex(List<ExpectedRangeRecord> records){
        List<String> sex= new ArrayList<>();
        for(ExpectedRangeRecord r: records){
            if(!sex.contains(r.getSex()))
            sex.add(r.getSex());
        }
        return sex;
    }

}
