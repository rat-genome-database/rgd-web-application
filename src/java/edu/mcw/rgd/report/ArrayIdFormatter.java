package edu.mcw.rgd.report;

import edu.mcw.rgd.datamodel.Alias;

import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Dec 9, 2010
 * Time: 4:52:49 PM
 */
public class ArrayIdFormatter {

    public static String format(List<Alias> aliases) {
        String affy = "";
        String ensembl="";

        for (Alias a: aliases) {
            String chipType = a.getTypeName().replace("array_id_", "");

            if (chipType.endsWith("_affymetrix")) {
                affy += "<tr><td>" + a.getValue() + "</td><td>" + chipType.replace("_affymetrix", "") + "</td></tr>\n";
            } else if (chipType.endsWith("_ensembl")) {
                ensembl += "<tr><td>" + a.getValue() + "</td><td>" + chipType.replace("_ensembl", "") + "</td></tr>\n";
            }
        }

        if( affy.length()+ensembl.length()>0 ) {
            return "<table border='0'><tr><td valign='top'><b>Ensembl</b>\n" +
                    "<table border=1 cellspacing=0 cellpadding=4><tr><td><b>Probe Set ID</b></td><td><b>Chip Type</b></td></tr>\n" +
                    ensembl +
                    "</table></td><td>&nbsp;</td><td valign='top'><b>Affymetrix</b>\n" +
                    "<table border=1 cellspacing=0 cellpadding=4><tr><td><b>Probe Set ID</b></td><td><b>Chip Type</b></td></tr>\n" +
                    affy + "</table></td></tr></table>\n";
        } else {
            return "<b>No array ids found.</b>";
        }

    }

}
