package edu.mcw.rgd.phenominer.expectedRanges.controller;

import edu.mcw.rgd.dao.impl.OntologyXDAO;


import edu.mcw.rgd.dao.impl.PhenominerExpectedRangeDao;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.PhenominerExpectedRange;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.PhenotypeObject;

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

        String cmoID = request.getParameter("cmoId");
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

        List<PhenominerExpectedRange> records = dao.getExpectedRanges(cmoID, null, null, null, null, null, isPGA);


       PhenominerExpectedRange normalRecord=getPhenotypeExpectedRangeRecordNormal(records,"Mixed");
       PhenominerExpectedRange normalMaleRecord=getPhenotypeExpectedRangeRecordNormal(records,"Male");
        PhenominerExpectedRange normalFemaleRecord=getPhenotypeExpectedRangeRecordNormal(records,"Female");

        records.sort((o1, o2) -> Utils.stringsCompareToIgnoreCase(o1.getStrainGroupName(), o2.getStrainGroupName()));

        session.setAttribute("phenotypes", phenotypes);
        if(normalRecord!=null){
            model.addAttribute("normalAll", normalRecord);
            //   System.out.println("NORMAL RECORD:" +object.getNormalAll().getGroupLow()+"\t" +object.getNormalAll().getGroupHigh());
        }
        if(normalMaleRecord!=null) {
           model.addAttribute("normalMale",normalMaleRecord);
        }

        if(normalFemaleRecord!=null) {
            model.addAttribute("normalFemale",normalFemaleRecord);
        }


        model.addAttribute("overAllMethods", process.getMethodOptions(records));
        model.addAttribute("records", process.addExtraAttributes(records));
        model.addAttribute("phenotype", phenotype);
        model.addAttribute("cmo", cmoID);
        model.addAttribute("phenotypes", phenotypes);
        model.addAttribute("plotData", process.getPlotData(records, "phenotype"));
        model.addAttribute("traitOntId", traitOntId);
        model.addAttribute("trait", trait);
        model.addAttribute("strainGroupMap", process.getStrainGroupMap(records));
        model.addAttribute("conditions", Arrays.asList("Control Conditions"));
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
