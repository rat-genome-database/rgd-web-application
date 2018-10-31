package edu.mcw.rgd.phenotype.phenotypeExpectedRanges;

import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.dao.PhenotypeExpectedRangeDao;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.dao.StrainGroupDao;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.ExpectedRangeRecord;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.PhenotypeObject;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.StrainObject;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by jthota on 3/12/2018.
 */
public class StrainExpectedRangeController implements Controller {
    StrainGroupDao sdao= new StrainGroupDao();
    PhenotypeExpectedRangeDao dao= new PhenotypeExpectedRangeDao();

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ModelMap model=new ModelMap();
     /*   String strainGroupId= request.getParameter("strainGroupId");
        String cmoAccIds= request.getParameter("cmoIds").replace("[", "").replace("]", "");
        StringTokenizer tokens= new StringTokenizer(cmoAccIds, ",");
        String strainGroupName=sdao.getStrainGroupName(Integer.parseInt(strainGroupId));

        StrainObject object= new StrainObject();
        object.setStrainGroupId(strainGroupId);
        object.setStrainGroupName(strainGroupName);
        List<String> strainGroupStrains=sdao.getStrainsOfStrainGroup(Integer.parseInt(strainGroupId));
        List<Integer> strainGroupIds=new ArrayList<>(Arrays.asList(Integer.parseInt(strainGroupId)));

        List<ExpectedRangeRecord> records= dao1.getPhenotypeExpectedRangeRecordsByStrainGroupId(strainGroupId);

        List<String> cmoIds=new ArrayList<>();
        Map<String, String> phenotypeNameIdMap= new HashMap<>();
       while(tokens.hasMoreTokens()){
           String term=tokens.nextToken().trim();
           cmoIds.add(term);

            phenotypeNameIdMap.put(term, dao1.getTerm(term).getTerm());
        }
        List<String> methodAccIds= new ArrayList<>(); List<String>  conditionAccIds= new ArrayList<>();
        PhenotypeObject strainPhenotypeObject=dao1.getStrainPhenotypeObject(records,methodAccIds, conditionAccIds , strainGroupIds,cmoIds);

        System.out.println("phenotype:"+strainPhenotypeObject.getPhenotype()+ "\nAGE:" + strainPhenotypeObject.getAge() +"\nStrains:" + strainPhenotypeObject.getStrainsSymbolsOfGroup().toString()
        +"\nConditions: " + strainPhenotypeObject.getXcoTerms().toString()+"\nMethods" + strainPhenotypeObject.getMmoTerms().toString() );

        object.setCmoAccIds(cmoIds);
        object.setRecords(records);
        object.setPhenotypeNameAccIdMap(phenotypeNameIdMap);

        model.addAttribute("strainObject", object);
        model.addAttribute("plotData",  dao1.getPlotData(records, "strain"));

       /* System.out.println("STRAIN GROUP ID:" + strainGroupId);
        System.out.println("STRAIN GROUP Name:" + strainGroupName);
        System.out.println("CMO IDS: " + cmoAccIds);*/
        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominerExpectedRanges/selectedStrain.jsp", "model", model);
    }
}
