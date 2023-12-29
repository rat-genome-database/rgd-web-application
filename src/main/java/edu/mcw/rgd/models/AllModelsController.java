package edu.mcw.rgd.models;



import edu.mcw.rgd.dao.impl.GeneticModelsDAO;

import edu.mcw.rgd.datamodel.models.GeneticModel;


import edu.mcw.rgd.models.models1.GeneticModelsSingleton;
import org.apache.commons.collections4.map.HashedMap;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by jthota on 10/28/2016.
 */
public class AllModelsController extends GeneticModelsController implements Controller {

    private GeneticModelsDAO modelDao= new GeneticModelsDAO();
    @Override
    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {
//        ModelMap model = new ModelMap();
       // List<GeneticModel> strains = modelDao.getAllModels2();
      //  List<GeneticModel> strainsWithAliases= this.getStrainWithAliases(strains);
      //  List<GeneticModel> strainsWithAliases=models.deserializeGeneticModel("allModels");
        GeneticModelsSingleton instance= GeneticModelsSingleton.getInstance();
        List<GeneticModel> strainsWithAliases= instance.getAllModels();
        Set<String> genes= new HashSet<>();
        for(GeneticModel s:strainsWithAliases){
            String geneSymbol= s.getGeneSymbol();
            genes.add(geneSymbol);
        }
        this.setGenes(genes);
        Map<String, List<GeneticModel>> gsMap = new HashMap<String, List<GeneticModel>>();
        Map<ModelsHeaderRecord, List<GeneticModel>> hcMap = new HashedMap();
        gsMap= this.getGeneStrainMap(strainsWithAliases);
        hcMap= this.getHeaderRecords(strainsWithAliases);

      /* Collections.sort(strainsWithAliases, GeneticModel.GeneSymbolComparator);
        for(GeneticModel m:strainsWithAliases){
            System.out.println(m.getGeneSymbol() + "\n");
        }*/

        httpServletRequest.setAttribute("strains", strainsWithAliases);
        httpServletRequest.setAttribute("geneStrainMap", gsMap);
        httpServletRequest.setAttribute("headerChildMap", hcMap);
        backgroundStrainList(gsMap,httpServletRequest);
        return new ModelAndView("/WEB-INF/jsp/models/allModels.jsp");

    }

    public void backgroundStrainList(Map<String, List<GeneticModel>> gsMap, HttpServletRequest httpServletRequest) throws Exception{
        Map<String, String> bsl = new HashedMap<>();
        for (String gene : gsMap.keySet()){
            String bStrain = "";
            List<GeneticModel> models = gsMap.get(gene);
            List<String> strainNames = new ArrayList<>();
            for (int i = 0 ; i<models.size(); i++){
                GeneticModel m = models.get(i);
                try {
                    String str = m.getBackgroundStrain();
                    if (!strainNames.contains(str) && str!=null) {
                        if (!bStrain.isEmpty())
                            bStrain += ", ";
                        bStrain += str;
                        strainNames.add(str);
                    }
                }
                catch (Exception ignore){

                }
            }
            if (bStrain.isEmpty())
                bsl.put(gene,"No Background Strains Assigned");
            else
                bsl.put(gene,bStrain);
        }
        httpServletRequest.setAttribute("backStrainList", bsl);
        httpServletRequest.getSession().setAttribute("backStrainList", bsl);
        return;
    }
}
