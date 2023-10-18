package edu.mcw.rgd.nomenclatureinterface;

import edu.mcw.rgd.datamodel.Gene;

import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jan 14, 2008
 * Time: 11:07:18 AM
 * To change this template use File | Settings | File Templates.
 */

/**
 * Result bean for one search result.  Contains the origiginal Gene, ortholog list, and
 * gene with proposed nomenclature.
 */
public class NomenclatureResultBean {

    private Gene gene;
    private List orthologList;
    private Gene proposedGene;

    public Gene getProposedGene() {
        return proposedGene;
    }

    public void setPropoesedGene(Gene propoesedGene) {
        this.proposedGene = propoesedGene;
    }

    public Gene getGene() {
        return gene;
    }

    public void setGene(Gene gene) {
        this.gene = gene;
    }

    public List getOrthologList() {
        return orthologList;
    }

    public void setOrthologList(List orthologList) {
        this.orthologList = orthologList;
    }
}
