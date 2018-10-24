package edu.mcw.rgd.phenominer.expectedRanges.dao;

import edu.mcw.rgd.dao.impl.PhenominerExpectedRangeDao;
import edu.mcw.rgd.dao.spring.phenominerExpectedRanges.PhenominerExpectedRangeQuery;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.PhenominerExpectedRange;

import java.util.List;

/**
 * Created by jthota on 7/2/2018.
 */
public class PhenominerExpectedRangeDaoExt extends PhenominerExpectedRangeDao {
    @Override
    public List<PhenominerExpectedRange> getExpectedRanges(String clinicalMeasurementOntId, List<Integer> strainGroupIds, List<String> sex, List<Integer> ageLow, List<Integer> ageHigh, List<String> selectedMethods, boolean isPGA) throws Exception {
        String sql = "SELECT * FROM PHENOMINER_EXPECTED_RANGE WHERE CLINICAL_MEASUREMENT_ONT_ID=? ";
        if(strainGroupIds != null) {
            sql = sql + this.buildIntQuery(strainGroupIds, "strain_group_id");
        }

        if(ageLow != null) {
            sql = sql + this.buildIntQuery(ageLow, "AGE_DAYS_FROM_DOB_LOW_BOUND");
        }

        if(ageHigh != null) {
            sql = sql + this.buildIntQuery(ageHigh, "AGE_DAYS_FROM_DOB_HIGH_BOUND");
        }

        if(sex != null) {
            sql = sql + this.buildStringQuery(sex, "SEX");
        }

        if(selectedMethods != null) {
            String query1 = this.buildMethodQuery(selectedMethods, "expected_range_name");
            if(query1 != null) {
                sql = sql + query1;
            }
        }

        if(isPGA) {
            sql = sql + " AND TRAIT_ONT_ID IS NULL ";
        }else{
            sql=sql + " AND TRAIT_ONT_ID is not null";
        }

        PhenominerExpectedRangeQuery query11 = new PhenominerExpectedRangeQuery(this.getDataSource(), sql);
        return this.execute(query11, new Object[]{clinicalMeasurementOntId});
    }
    public List<PhenominerExpectedRange> getExpectedRangesOfPhenotype(String clinicalMeasurementOntId, List<Integer> strainGroupIds, List<String> sex, List<Integer> ageLow, List<Integer> ageHigh, List<String> selectedMethods, boolean isPGA) throws Exception {
        String sql = "SELECT * FROM PHENOMINER_EXPECTED_RANGE WHERE CLINICAL_MEASUREMENT_ONT_ID=? ";
        if(strainGroupIds != null) {
            sql = sql + this.buildIntQuery(strainGroupIds, "strain_group_id");
        }

        if(ageLow != null) {
            sql = sql + this.buildIntQuery(ageLow, "AGE_DAYS_FROM_DOB_LOW_BOUND");
        }

        if(ageHigh != null) {
            sql = sql + this.buildIntQuery(ageHigh, "AGE_DAYS_FROM_DOB_HIGH_BOUND");
        }

        if(sex != null) {
            sql = sql + this.buildStringQuery(sex, "SEX");
        }

        if(selectedMethods != null) {
            String query1 = this.buildMethodQuery(selectedMethods, "expected_range_name");
            if(query1 != null) {
                sql = sql + query1;
            }
        }

        if(isPGA) {
            sql = sql + " AND TRAIT_ONT_ID IS NULL ";
        }

        PhenominerExpectedRangeQuery query11 = new PhenominerExpectedRangeQuery(this.getDataSource(), sql);
        return this.execute(query11, new Object[]{clinicalMeasurementOntId});
    }

}
