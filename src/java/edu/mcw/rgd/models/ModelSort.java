package edu.mcw.rgd.models;

import edu.mcw.rgd.datamodel.models.GeneticModel;

import java.util.Collections;
import java.util.List;



/**
 * Created by jthota on 9/23/2016.
 */
public final class ModelSort {
    public static List<GeneticModel> sortByGeneSymbol(java.util.List<GeneticModel> modelList){
        Collections.sort(modelList, GeneticModel.GeneSymbolComparator);
        return modelList;
    }
}
