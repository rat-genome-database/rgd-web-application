package edu.mcw.rgd.phenominer.expectedRanges.controller;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.PhenominerExpectedRange;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.StrainObject;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.pheno.phenominerExpectedRanges.ExpectedRangeProcess;

import edu.mcw.rgd.reporting.Report;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.lang.reflect.Array;
import java.util.*;
import java.util.Map;

/**
 * Created by jthota on 5/2/2018.
 */
public class SelectedStrainController implements Controller{
    ExpectedRangeProcess process= new ExpectedRangeProcess();
    PhenominerExpectedRangeDao dao=new PhenominerExpectedRangeDao();
    VariantDAO vdao = new VariantDAO();
    PhenominerDAO pdao=new PhenominerDAO();
    StrainDAO sdao=new StrainDAO();

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
        ModelMap model= new ModelMap();
        String traitOntId= request.getParameter("trait");
        if(traitOntId!=null && traitOntId.equals("")){
            traitOntId=null;
        }
        HttpSession session=request.getSession();
        List<StrainObject> strainObjects= ( List<StrainObject>) session.getAttribute("strainObjects");
        String strainGroupId=request.getParameter("strainGroupId");

        String strainGroupName=process.getStrainGroupName(Integer.parseInt(strainGroupId));



        List<String> cmoIdList= dao.getDistinctPhenotypesByTrait(strainGroupId, traitOntId);
        List<Strain> strains = sdao.getStrainsByGroupId(Integer.parseInt(strainGroupId),SpeciesType.RAT);
        Map damagingVar = new HashMap<>();


        for(Strain s: strains) {
            List<edu.mcw.rgd.datamodel.Map> maps = new MapDAO().getMaps(SpeciesType.RAT);
            Map assemblyMap = new HashMap<>();
            for (edu.mcw.rgd.datamodel.Map map : maps) {
                Map details = new HashMap<>();
                int count = vdao.getCountofDamagingVariantsForStrainByAssembly(s.getRgdId(),String.valueOf(map.getKey()));
                if (count != 0) {
                    details.put("count",count);
                    details.put("rgdId",s.getRgdId());
                    details.put("map",map.getKey());
                    assemblyMap.put(map.getName(), details);
                }
            }
                if (assemblyMap.keySet().size() != 0)
                    damagingVar.put(s.getSymbol(), assemblyMap);

        }
        Map<String, String> phenotypeIdMap=new TreeMap<>();
        for(String s:cmoIdList){

            phenotypeIdMap.put( process.getTerm(s.trim()).getTerm(), s.trim());
        }
        String traitTerm=new String();
        if(traitOntId!=null && !"".equals(traitOntId)) {
            if (!traitOntId.equals("pga")) {
              traitTerm = process.getTerm(traitOntId).getTerm();
            } else traitTerm = "PGA";
        }
        List<PhenominerExpectedRange> records=process.getExpectedRangesByTraitNStrainGroupId(Integer.parseInt(strainGroupId), traitOntId);
        records.sort((o1,o2)-> Utils.stringsCompareToIgnoreCase(o1.getClinicalMeasurement(),o2.getClinicalMeasurement()));
        List<PhenominerExpectedRange> plotRecords= new ArrayList<>();

       String clinical_measurement=(records.get(0).getClinicalMeasurement());

        for(PhenominerExpectedRange r:records){
            if(r.getClinicalMeasurement().equals(clinical_measurement)){
                plotRecords.add(r);
            }
        }
        String unitsStr=plotRecords.get(0).getUnits();
        String units=unitsStr.substring(1, unitsStr.length()-1);
        model.addAttribute("units", units);
        model.put("phenotypesMap", phenotypeIdMap);
        model.addAttribute("overAllMethods", process.getMethodOptions(records));
        model.put("strainGroup", strainGroupName);
        model.put("strainGroupId", strainGroupId);
      //  model.put("ranges", process.addExtraAttributes(records));
        model.put("ranges", process.addExtraAttributes(plotRecords));
        model.put("traitOntId", traitOntId);
        model.put("trait", traitTerm);
        model.put("strainObjects", strainObjects);
        model.put("initialPlotPhenotype",clinical_measurement);
       model.put("damagingVariants",damagingVar);
       model.addAttribute("plotData",  process.getPlotData(plotRecords, "strain"));

        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominerExpectedRanges/views/strain.jsp","model", model);
    }
}
