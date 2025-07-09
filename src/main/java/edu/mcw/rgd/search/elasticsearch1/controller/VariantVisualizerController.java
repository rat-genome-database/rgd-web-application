package edu.mcw.rgd.search.elasticsearch1.controller;

import edu.mcw.rgd.dao.impl.AssociationDAO;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by jthota on 9/18/2017.
 */
public class VariantVisualizerController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {


        String rgdIdsStr=request.getParameter("rgdIds");
        String mapKey=request.getParameter("mapKey");
        String species=request.getParameter("species");

        AssociationDAO associationDAO = new AssociationDAO();
        GeneDAO geneDAO = new GeneDAO();

        Set<Integer> genes = new HashSet<>();
        StringBuilder geneList = new StringBuilder();

        if(rgdIdsStr!=null) {
            StringTokenizer tokenizer = new StringTokenizer(rgdIdsStr, ",");

            while (tokenizer.hasMoreTokens()) {
                String token = tokenizer.nextToken();
                int rgdId = Integer.parseInt(token);


                List<Gene> relatedGenes = associationDAO.getAssociatedGenesForMasterRgdId(rgdId, "variant_to_gene");
                if (relatedGenes.size() > 0) {

                    // sort by gene symbol
                    Collections.sort(relatedGenes, new Comparator<Gene>() {
                        public int compare(Gene o1, Gene o2) {
                            return Utils.stringsCompareToIgnoreCase(o1.getSymbol(), o2.getSymbol());
                        }
                    });
                }
                for (Gene g : relatedGenes) {
                    //System.out.println(g);
                    genes.add(g.getRgdId());
                }

             //   System.out.println("+++++++++++++++++++++++++++++++++");
            }
        }
        boolean first=true;
        for(int id:genes){
            Gene g= geneDAO.getGene(id);
            if(first){
                geneList.append(g.getSymbol());
                first=false;
            }else{
                geneList.append(",").append(g.getSymbol());
            }


        }
        String sample=null;
        if(species!=null){
            if(species.equalsIgnoreCase("human")){
                sample="2";
            }else{
                sample="all";
            }
        }
        String redirectUrl= RgdContext.getHostname() + "/rgdweb/front/variants.html?start=&stop=&chr=&geneStart=&geneStop=&con=&depthLowBound=8&depthHighBound=&sample1="+sample+"&mapKey=" + mapKey + "&geneList=" + geneList;
                //"/rgdweb/front/config.html?geneList="+geneList+"&sample1="+sample+"&mapKey="+mapKey;
        response.sendRedirect(redirectUrl);
        return null;
    }
}
