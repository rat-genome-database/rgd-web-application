package edu.mcw.rgd.overgo;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Apr 27, 2011
 * Time: 1:26:38 PM
 * To change this template use File | Settings | File Templates.
 */

/**
 * Bean class to hold request parameters for oligospawn
 */

public class OligoSpawnRequest {

    private int contigSize;
    private List options;
    private String inputFile;
    private long contigIndex;

    public OligoSpawnRequest(int contigSize, List options, String inputFile, long contigIndex) {
        this.contigSize = contigSize;
        this.options = options;
        this.inputFile = inputFile;
        this.contigIndex = contigIndex;
    }

    /**
     * get the region size.  Each region will have oligo spawn run
     * @return
     */
    public int getContigSize() {
        return contigSize;
    }

    /**
     * List of options for oligo spawn
     * @return
     */
    public List getOptions() {
        return options;
    }

    /**
     * Returns a path to the input fasta file
     * @return
     */
    public String getInputFile() {
        return inputFile;
    }

    /**
     * Set to the region number for this request in context of the fasta file
     * @return
     */
    public long getContigIndex() {
        return contigIndex;
    }
}
