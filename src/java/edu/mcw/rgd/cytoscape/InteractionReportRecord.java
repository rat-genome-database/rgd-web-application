package edu.mcw.rgd.cytoscape;

import edu.mcw.rgd.datamodel.Interaction;

/**
 * Created by jthota on 3/21/2019.
 */
public class InteractionReportRecord extends Interaction {
   private String proteinUniprotId1;
   private String proteinUniprotId2;
    private String species1;
    private String species2;
    private String attributes;
    private String geneSymbol1;
    private String geneRgdId1;
    private String geneSymbol2;
    private String geneRgdId2;

    public String getGeneSymbol1() {
        return geneSymbol1;
    }

    public void setGeneSymbol1(String geneSymbol1) {
        this.geneSymbol1 = geneSymbol1;
    }

    public String getGeneRgdId1() {
        return geneRgdId1;
    }

    public void setGeneRgdId1(String geneRgdId1) {
        this.geneRgdId1 = geneRgdId1;
    }

    public String getGeneSymbol2() {
        return geneSymbol2;
    }

    public void setGeneSymbol2(String geneSymbol2) {
        this.geneSymbol2 = geneSymbol2;
    }

    public String getGeneRgdId2() {
        return geneRgdId2;
    }

    public void setGeneRgdId2(String geneRgdId2) {
        this.geneRgdId2 = geneRgdId2;
    }

    public String getProteinUniprotId1() {
        return proteinUniprotId1;
    }

    public String getAttributes() {
        return attributes;
    }

    public void setAttributes(String attributes) {
        this.attributes = attributes;
    }

    public void setProteinUniprotId1(String proteinUniprotId1) {
        this.proteinUniprotId1 = proteinUniprotId1;
    }

    public String getProteinUniprotId2() {
        return proteinUniprotId2;
    }

    public void setProteinUniprotId2(String proteinUniprotId2) {
        this.proteinUniprotId2 = proteinUniprotId2;
    }

    public String getSpecies1() {
        return species1;
    }

    public void setSpecies1(String species1) {
        this.species1 = species1;
    }

    public String getSpecies2() {
        return species2;
    }

    public void setSpecies2(String species2) {
        this.species2 = species2;
    }
}
