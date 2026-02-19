package edu.mcw.rgd.vv;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.datamodel.Sample;

import java.util.concurrent.ConcurrentHashMap;

/**
 *
 * Singleton class used to retrieve and store sample names.  Use of this class eliminates repeated queries to the database
 *
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 9/28/12
 * Time: 9:45 AM
 */
public class SampleManager {

    private ConcurrentHashMap<Integer,Sample> samples = new ConcurrentHashMap<>();

    private static SampleManager sm = new SampleManager();

    private SampleManager() {

    }

    public static SampleManager getInstance() {
        return sm;
    }


    /**
     * Returns the sample name as a string based on the sample id.  If name is not in memory a call to the datastore will be made
     */
    public Sample getSampleName(int sampleId) throws Exception {

        Sample sample = samples.get(sampleId);
        if( sample==null ) {
            SampleDAO sampleDAO = new SampleDAO();
         //   sampleDAO.setDataSource(DataSourceFactory.getInstance().getDataSource("variant"));
               sampleDAO.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

            sample = sampleDAO.getSample(sampleId);
            this.samples.put(sampleId, sample);
        }
        return sample;
    }

}
