package edu.mcw.rgd.search.elasticsearch1.model;

import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.QTL;
import edu.mcw.rgd.datamodel.Strain;
import edu.mcw.rgd.datamodel.VariantInfo;

import java.util.List;

/**
 * Created by jthota on 6/13/2017.
 */
public class Species {
    private String name;
    private List<Gene> genes;
    private List<Strain> strains;
    private List<QTL> qtls;
    private List<VariantInfo> variants;
    private int geneCount;
    private int strainCount;
    private int qtlCount;
    private int variantCount;


    public int getGeneCount() {
        return geneCount;
    }

    public void setGeneCount(int geneCount) {
        this.geneCount = geneCount;
    }

    public int getStrainCount() {
        return strainCount;
    }

    public void setStrainCount(int strainCount) {
        this.strainCount = strainCount;
    }

    public int getQtlCount() {
        return qtlCount;
    }

    public void setQtlCount(int qtlCount) {
        this.qtlCount = qtlCount;
    }

    public int getVariantCount() {
        return variantCount;
    }

    public void setVariantCount(int variantCount) {
        this.variantCount = variantCount;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Gene> getGenes() {
        return genes;
    }

    public void setGenes(List<Gene> genes) {
        this.genes = genes;
    }

    public List<Strain> getStrains() {
        return strains;
    }

    public void setStrains(List<Strain> strains) {
        this.strains = strains;
    }

    public List<QTL> getQtls() {
        return qtls;
    }

    public void setQtls(List<QTL> qtls) {
        this.qtls = qtls;
    }

    public List<VariantInfo> getVariants() {
        return variants;
    }

    public void setVariants(List<VariantInfo> variants) {
        this.variants = variants;
    }
}
