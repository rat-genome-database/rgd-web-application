package edu.mcw.rgd.overgo;

import java.util.List;
import java.util.ArrayList;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Apr 27, 2011
 * Time: 1:28:29 PM
 * To change this template use File | Settings | File Templates.
 */

/**
 * Bean class to hold an oligo spawn response
 */
public class OligoSpawnResponse {

    private String header = "";
    private List<String> forward = new ArrayList();
    private List<String> reverse = new ArrayList();
    private String error = "";
    private String region;

    /**
     * Returns the fasta header
     * @return
     */
    public String getHeader() {
        return header;
    }

    /**
     * Sets the fasta header
     * @param header
     */
    public void setHeader(String header) {
        this.header = header;
    }

    /**
     * Gets the forward probe sequence
     * @return
     */
    public List<String> getForward() {
        return forward;
    }

    public void setForward(List forward) {
        this.forward = forward;
    }

    /**
     * gets the reverse probe sequence
     * @return
     */
    public List<String> getReverse() {
        return reverse;
    }

    public void setReverse(List reverse) {
        this.reverse = reverse;
    }

    /**
     * Gets the region number
     * @return
     */
    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    /**
     * Returns the response from std error.  Note that this will contain a value even when the program
     * works without error.  It is just passing on the std error stream
     * @return
     */
    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }
}
