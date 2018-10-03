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
        System.out.println("TRAIT EXISTS:"+traitExists);
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
        records.sort((o1, o2) -> Utils.stringsCompareToIgnoreCase(o1.getStrainGroupName(), o2.getStrainGroupName()));

        session.setAttribute("phenotypes", phenotypes);
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

}
