package edu.mcw.rgd.phenotype.phenotypeExpectedRanges;


import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.dao.PhenotypeExpectedRangeDao;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.dao.StrainGroupDao;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.ExpectedRangeRecord;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.PhenotypeObject;
import edu.mcw.rgd.phenotype.phenotypeExpectedRanges.model.StrainObject;

import edu.mcw.rgd.process.Utils;
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
public class PhenotypeExpectedRangeController  implements Controller{
    PhenotypeExpectedRangeDao dao = new PhenotypeExpectedRangeDao();
    StrainGroupDao sdao=new StrainGroupDao();
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ModelMap model= new ModelMap();
       Map<String, String> traitMap= dao.getTraits();
       List<String> phenotypes= dao.getDistinctPhenotypes();
       List<String> strainGroups= dao.getDistinctStrainGroups();

       List<PhenotypeObject> counts= new ArrayList<>();
        List<StrainObject> strainObjects= new ArrayList<>();

       for(String p:phenotypes) {
            PhenotypeObject count=new PhenotypeObject();
            List<ExpectedRangeRecord> records = new ArrayList<>();
            records = dao.getPhenotypeExpectedRangeRecordsByPhenotype(p);
            count.setClinicalMeasurementId(this.getClinicalMeasurementId(records));
            count.setPhenotype(p);
            count.setRecords(records);
            ExpectedRangeRecord normalRecord=dao.getPhenotypeExpectedRangeRecordNormal(records,"Mixed");
           if(normalRecord!=null)
            count.setOverall(normalRecord.getGroupLow() + " - " + normalRecord.getGroupHigh());
            count.setRecordsCountByStrain(this.getRecordCountByStrain(records));
            count.setRecordsCountBySex(dao.getExpectedRangeRecordsCountBySex(records));
           count.setRecordsCountByAge(dao.getExpectedRangeRecordsCountByAge(records));
            counts.add(count);
        }
        counts.sort(new Comparator<PhenotypeObject>() {
            @Override
            public int compare(PhenotypeObject o1, PhenotypeObject o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getPhenotype(), o2.getPhenotype());
            }
        });
        /*********************************STRAIN GROUP OBJECTS**************************************************/
       for(String s: strainGroups){
            StrainObject object= new StrainObject();
            String strainGroupName=sdao.getStrainGroupName(Integer.parseInt(s));
            if(!strainGroupName.contains("normal")) {
                object.setStrainGroupId(s);
                object.setStrainGroupName(strainGroupName);
                //    List<ExpectedRangeRecord> records= dao1.getPhenotypeExpectedRangeRecordsByStrainGroupId(s);

                //     System.out.println(sdao.getStrainGroupName(Integer.parseInt(s))+"||" + records.size());
              //  int phenotypeCount = dao1.getDistinctPhenotypeCountByStrainGroupId(s);
                List<String> cmoIds= dao.getDistinctPhenotypesByStrainGroupId(s);
                object.setCmoAccIds(cmoIds);
                strainObjects.add(object);
          //   System.out.println(s + "||" + sdao.getStrainGroupName(Integer.parseInt(s)) + "||" +cmoIds.size());
            }

        }
        strainObjects.sort(new Comparator<StrainObject>() {
            @Override
            public int compare(StrainObject o1, StrainObject o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getStrainGroupName(),o2.getStrainGroupName());
            }
        });
        model.addAttribute("strainObjects", strainObjects);
        /********************************************************************************************************/
        HttpSession session= request.getSession();
        session.setAttribute("phenotypes",counts);

        model.addAttribute("counts", counts);
        model.addAttribute("phenotypes", phenotypes);
        model.addAttribute("traitMap", traitMap);
        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominerExpectedRanges/home.jsp", "model", model);
    }


    public int getRecordCountByStrain(List<ExpectedRangeRecord> records){
        Set<Integer> groupIds= new HashSet<>();
        for(ExpectedRangeRecord r: records) {
            if (!r.getStrainGroupName().contains("normal")) {
                int strainGroupId = r.getStrainGroupId();
                groupIds.add(strainGroupId);
            }
        }
        return groupIds.size();
    }
    public String getOverallValues(List<ExpectedRangeRecord> records){
        List<Double> values= new ArrayList<>();
        for(ExpectedRangeRecord record: records){
            values.add(record.getGroupValue());
        }
        Double min=Collections.min(values);
        Double max=Collections.max(values);
        return min + " - "+max;
    }
public String getClinicalMeasurementId(List<ExpectedRangeRecord> records){
   return records.get(0).getClinicalMeasurementAccId();
}
}
