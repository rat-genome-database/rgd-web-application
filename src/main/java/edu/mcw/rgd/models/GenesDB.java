package edu.mcw.rgd.models;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.datamodel.Gene;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by jthota on 8/9/2016.
 */
public class GenesDB {

    private int totalGenes;
    private List<String> genes;
    GeneDAO geneDAO= new GeneDAO();
    public GenesDB() throws Exception {
        genes= new ArrayList<>(Arrays.asList("a2m", "prkdc", "adora2a", "adcy2") );
        totalGenes=genes.size();
    }

    public List<String> getGenes(String query) throws Exception {
        List<Gene> genesList= geneDAO.getAllGenesBySubSymbol(query, 3);
        List<String> genes= new ArrayList<>();
        for(Gene g:genesList){
            genes.add(g.getSymbol());
        }
        List<String> matched = new ArrayList<>();
       if(query!=null) {
           query = query.toLowerCase();
            for (String gene1 : genes) {
               String gene = gene1.toLowerCase();
               if (gene.startsWith(query)) {
                   matched.add(gene);
               }
           }
       }
        return matched;
     }

}
