package edu.mcw.rgd.nomenclatureinterface;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Feb 7, 2008
 * Time: 10:22:21 AM
 * To change this template use File | Settings | File Templates.
 */

/**
 * Constants class used to hold dates used by the nomenclature manager interface
 */
public final class NomenclatureDates {

    private NomenclatureDates() {
    }

    public static final Date TODAY = new Date();
    public static final Date UNTOUCHABLE = new GregorianCalendar(2200,9,1).getTime(); // Oct 1, 2200
    public static final Date REVIEWABLE = new GregorianCalendar(2100,9,1).getTime();  // Oct 1, 2100
    public static final Date ONEYEAR = addOneYear(TODAY).getTime();
    public static final Date START = new GregorianCalendar(1974,9,1).getTime();  // Oct 1, 1974
    public static final Date TOMORROW = getTomorrow(TODAY).getTime();

    private static GregorianCalendar addOneYear(Date date) {
        GregorianCalendar gc = new GregorianCalendar();
        gc.setTime(date);
        gc.add(Calendar.YEAR,1);
        return gc;
    }

    private static GregorianCalendar getTomorrow(Date date) {
        GregorianCalendar gc = new GregorianCalendar();
        gc.setTime(date);
        gc.add(Calendar.DAY_OF_YEAR,1);
        return gc;
    }

}
