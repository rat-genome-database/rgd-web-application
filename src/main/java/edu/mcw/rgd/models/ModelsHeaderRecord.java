package edu.mcw.rgd.models;

/**
 * Created by jthota on 9/28/2016.
 */
public class ModelsHeaderRecord {
    private String gene;
    private String geneSymbol;
    private int count;
    private String backgroundStrain;
    private String status;

    public String getGene() {
        return gene;
    }

    public void setGene(String gene) {
        this.gene = gene;
    }

    public String getGeneSymbol() {
        return geneSymbol;
    }

    public void setGeneSymbol(String geneSymbol) {
        this.geneSymbol = geneSymbol;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public String getBackgroundStrain() {
        return backgroundStrain;
    }

    public void setBackgroundStrain(String backgroundStrain) {
        this.backgroundStrain = backgroundStrain;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
