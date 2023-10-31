package edu.mcw.rgd.vv;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: 2/12/15
 * Time: 3:59 PM
 * <p>
 * VariantVisualizer Exception -- this is to distinguish exceptions that are allowed by the logic (expected exceptions)
 * from exceptions that are unexpected
 * </p>
 */
public class VVException extends Exception {
    public VVException(String msg) {
        super(msg);
    }
}
