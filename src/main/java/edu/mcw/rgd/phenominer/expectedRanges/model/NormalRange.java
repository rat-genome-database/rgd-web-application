package edu.mcw.rgd.phenominer.expectedRanges.model;

import edu.mcw.rgd.datamodel.phenominerExpectedRange.PhenominerExpectedRange;

/**
 * Created by jthota on 6/3/2019.
 */
public class NormalRange {
   private PhenominerExpectedRange mixed;
    private PhenominerExpectedRange male;
    private PhenominerExpectedRange female;

    public PhenominerExpectedRange getMixed() {
        return mixed;
    }

    public void setMixed(PhenominerExpectedRange mixed) {
        this.mixed = mixed;
    }

    public PhenominerExpectedRange getMale() {
        return male;
    }

    public void setMale(PhenominerExpectedRange male) {
        this.male = male;
    }

    public PhenominerExpectedRange getFemale() {
        return female;
    }

    public void setFemale(PhenominerExpectedRange female) {
        this.female = female;
    }
}
