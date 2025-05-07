package edu.mcw.rgd.web;

import edu.mcw.rgd.datamodel.Chromosome;
import edu.mcw.rgd.datamodel.MapData;
import edu.mcw.rgd.datamodel.variants.VariantMapData;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jul 3, 2008
 * Time: 8:02:12 AM
 * <p>
 * Utility class for working with form data
 */
public class FormUtility {

    private static FormUtility _instance = new FormUtility();

    /**
     * Used to see if we need "selected" in the option tag
     *
     * if the checkValue = option value, return "value=[checkValue] selected"
     * if the checkValue !=, leave off selected.
     * @param checkValue
     * @param optionValue
     * @return
     */
    public String optionParams(int checkValue, int optionValue) {
        return optionParams(Integer.toString(checkValue), Integer.toString(optionValue));
    }

    /**
     * Used to see if we need "selected" in the option tag
     *
     * if the checkValue = option value, return "value=[checkValue] selected"
     * if the checkValue !=, leave off selected.
     * @param checkValue
     * @param optionValue
     * @return
     */
    public String optionParams(String checkValue, String optionValue) {
        // make sure the parameters are never null
        if( checkValue==null )
            checkValue = "";
        if( optionValue==null )
            optionValue = "";

        if (checkValue.equals(optionValue)) {
            return " value=\"" + optionValue + "\" selected ";
        }         
        return " value=\"" + optionValue + "\" ";
    }

    /**
     * Returns a - (dash) if the value passed in is 0 (zero)
     * @param value
     * @return
     */
    public String dashFor0(int value) {
        if (value == 0) {
            return "-";
        }
        return Integer.toString(value);
    }

    public String chkNull(Double i) {
        if (i == null) {
            return "";
        }else {
            return i.toString();
        }
    }

    public String chkNullNA(Double i) {
        if (i == null) {
            return "Not Available";
        }else {
            return i.toString();
        }
    }

    public String chkNull(Integer i) {
        if (i == null) {
            return "";
        }else {
            return i.toString();
        }
    }

    private static SimpleDateFormat sdf = new SimpleDateFormat("MM/dd/yyyy");
    public String chkNull(Date d) {
        if (d == null) {
            return "";
        }else {
            return sdf.format(d);
        }
    }

    public String chkNull(String str) {
        if (str == null) {
            return "";
        }else {
            return str;
        }

    }

    public String chkNullNA(String str) {
        if (str == null) {
            return "Not Available";
        }else {
            return str;
        }

    }

    public String render(String param, String value, edu.mcw.rgd.web.HttpRequestFacade req, ArrayList errors) {
        if (errors.size() > 0) {
            return req.getParameter("param");
        }else {
            return chkNull(value);
        }
    }

    public String render(String param, int value, edu.mcw.rgd.web.HttpRequestFacade req, ArrayList errors) {
        return render(param, Integer.toString(value), req, errors);
    }

    //   <select name="type">
//       <option value="protein-coding" <%=fu.optionParams(dm.out("type",gene.getType()), "protein-coding")%>>protein-coding</option>
//       <option value="gene" <%=fu.optionParams(dm.out("type",gene.getType()), "gene")%>>gene</option>

    public String buildSelectList(String name, List<String> values, String selectedValue) {
        StringBuilder ret = new StringBuilder();
        ret.append("<select name=\"").append(name).append("\">");
        for (String nxt : values) {
            ret.append("<option ").append(this.optionParams(selectedValue, nxt)).append(">")
               .append(nxt).append("</option>");
        }

        ret.append("</select>");
        return ret.toString();
    }

    public String buildSelectList(String name, List<String> values, String selectedValue,String onChange) {
        StringBuilder ret = new StringBuilder();
        ret.append("<select onChange=\"" + onChange + "\" name=\"").append(name).append("\">");
        for (String nxt : values) {
            ret.append("<option ").append(this.optionParams(selectedValue, nxt)).append(">")
                    .append(nxt).append("</option>");
        }

        ret.append("</select>");
        return ret.toString();
    }


    public String buildSelectListWithCss(String name, List<String> values, String selectedValue,String className) {
        StringBuilder ret = new StringBuilder();
        ret.append("<select name=\"").append(name).append("\" ").append("class=\"").append(className).append("\">");
        for (String nxt : values) {
            ret.append("<option ").append(this.optionParams(selectedValue, nxt)).append(">")
                    .append(nxt).append("</option>");
        }

        ret.append("</select>");
        return ret.toString();
    }

    public String buildChrSelectList(String name, List<Chromosome> values, String selectedValue) {
        StringBuilder ret = new StringBuilder();
        ret.append("<select name=\"").append(name).append("\">");
        for (Chromosome nxt : values) {
            ret.append("<option ").append(this.optionParams(selectedValue, nxt.getChromosome())).append(">")
                    .append(nxt.getChromosome()).append("</option>");
        }

        ret.append("</select>");
        return ret.toString();
    }
    public String buildChrSelectListWithCss(String name, List<Chromosome> values, String selectedValue,String className) {
        StringBuilder ret = new StringBuilder();
        ret.append("<select name=\"").append(name).append("\" ").append("class=\"").append(className).append("\">");
        for (Chromosome nxt : values) {
            ret.append("<option ").append(this.optionParams(selectedValue, nxt.getChromosome())).append(">")
                    .append(nxt.getChromosome()).append("</option>");
        }

        ret.append("</select>");
        return ret.toString();
    }

    static public String buildSelectDropDown(String name, List<String> values, String selectedValue) {
        return _instance.buildSelectList(name, values, selectedValue);
    }

    public String buildSelectListNewValue(String name, List<String> values, String selectedValue, boolean isCUnits) {
        StringBuilder ret = new StringBuilder();
        if(isCUnits){//Added to create both name & id (dynamic)
            ret.append("<select name= \"cUnits\"").append("id=\"").append(name).append("\">");
        }else //For any other input other than cUnit(earlier code)
            ret.append("<select name=\"").append(name).append("\">");
        String newValueStr = "REQUEST NEW VALUE";
        for (String nxt : values) {
            ret.append("<option ").append(this.optionParams(selectedValue, nxt)).append(">")
               .append(nxt).append("</option>");
        }

        ret.append("<option ").append(this.optionParams(selectedValue, newValueStr)).append(">")
           .append(newValueStr).append("</option>");

        ret.append("</select>");
        return ret.toString();
    }

    public String buildSelectListNewValue(String name, List<String> values, String selectedValue, boolean isCUnits, String onChange ) {
        StringBuilder ret = new StringBuilder();
        if(isCUnits){//Added to create both name & id (dynamic)
            ret.append("<select onChange=\"" + onChange + "\" name= \"cUnits\"").append("id=\"").append(name).append("\">");
        }else //For any other input other than cUnit(earlier code)
            ret.append("<select onChange=\"" + onChange + "\" name=\"").append(name).append("\">");
        String newValueStr = "REQUEST NEW VALUE";
        for (String nxt : values) {
            ret.append("<option ").append(this.optionParams(selectedValue, nxt)).append(">")
                    .append(nxt).append("</option>");
        }

        ret.append("<option ").append(this.optionParams(selectedValue, newValueStr)).append(">")
                .append(newValueStr).append("</option>");

        ret.append("</select>");
        return ret.toString();
    }

    public String blank(String str) {
        if (str == null) {
            return "&nbsp;";
        }else {
            return str;
        }

    }

    public String buildSelectListLabelsNewValue(String name, List<String> labelValues, String selectedValue,String onChange) {
        StringBuilder ret = new StringBuilder();
        ret.append("<select onChange=\"" + onChange + "\" name=\"").append(name).append("\">");
        String newValueStr = "REQUEST NEW VALUE";
        for (int i = 0; i < labelValues.size(); i++) {
            String[] strings = labelValues.get(i).split("\\|");
            int value_index = i>0 ? 1 : 0;
            ret.append("<option ").append(this.optionParams(selectedValue, strings[value_index])).append(">")
               .append(strings[0]).append("</option>");
        }

        ret.append("<option ").append(this.optionParams(selectedValue, newValueStr)).append(">")
           .append(newValueStr).append("</option>");

        ret.append("</select>");
        return ret.toString();
    }

    public String buildSelectListLabelsNewValue(String name, List<String> labelValues, String selectedValue) {
        StringBuilder ret = new StringBuilder();
        ret.append("<select name=\"").append(name).append("\">");
        String newValueStr = "REQUEST NEW VALUE";
        for (int i = 0; i < labelValues.size(); i++) {
            String[] strings = labelValues.get(i).split("\\|");
            int value_index = i>0 ? 1 : 0;
            ret.append("<option ").append(this.optionParams(selectedValue, strings[value_index])).append(">")
                    .append(strings[0]).append("</option>");
        }

        ret.append("<option ").append(this.optionParams(selectedValue, newValueStr)).append(">")
                .append(newValueStr).append("</option>");

        ret.append("</select>");
        return ret.toString();
    }


    public String buildAutoComplete(String name, List<String> values, String selectedValue) {
        StringBuilder ret = new StringBuilder();
        ret.append("<div class=\"ui-widget\">");
        ret.append("<select id=\"combobox\" name=\"").append(name).append("\">");

        for (String nxt : values) {
            ret.append("<option ").append(this.optionParams(selectedValue, nxt)).append(">")
               .append(nxt).append("</option>");
        }
        ret.append("</select>");
        ret.append("</div>");
        return ret.toString();
    }

    public String buildSelectList(String name, Map<String, String> values, String selectedValue, String onChange) {

        StringBuilder ret = new StringBuilder();
        ret.append("<select onChange=\"" + onChange + "\" name=\"").append(name).append("\">");

        for (String key : values.keySet()) {
            String value = values.get(key);
            ret.append("<option ").append(this.optionParams(selectedValue, key)).append(">")
                    .append(value).append("</option>");
        }

        ret.append("</select>");
        return ret.toString();
    }
    public String buildSelectList(String name, Map<String, String> values, String selectedValue) {

        StringBuilder ret = new StringBuilder();
        ret.append("<select name=\"").append(name).append("\">");

        for (String key : values.keySet()) {
            String value = values.get(key);
            ret.append("<option ").append(this.optionParams(selectedValue, key)).append(">")
                    .append(value).append("</option>");
        }

        ret.append("</select>");
        return ret.toString();
    }

    public String buildSelectListWithCss(String name, Map<String, String> values, String selectedValue,String className) {

        StringBuilder ret = new StringBuilder();
        ret.append("<select name=\"").append(name).append("\" ").append("class=\"").append(className).append("\">");

        for (String key : values.keySet()) {
            String value = values.get(key);
            ret.append("<option ").append(this.optionParams(selectedValue, key)).append(">")
                    .append(value).append("</option>");
        }

        ret.append("</select>");
        return ret.toString();
    }

    public String buildAutoComplete(String name, Map<String, String> values, String selectedValue) {

        StringBuilder ret = new StringBuilder();
        ret.append("<div class=\"ui-widget\">");

        ret.append("<select id=\"combobox\" name=\"").append(name).append("\">");

        for (Map.Entry<String, String> entry: values.entrySet() ) {
            ret.append("<option ").append(this.optionParams(selectedValue, entry.getKey())).append(">")
               .append(entry.getValue()).append("</option>");
        }
        ret.append("</select>");
        ret.append("</div>");
        return ret.toString();
    }

    public String buildSelectList(String name, List<String> values, String selectedValue, boolean includeNone) {
        StringBuilder ret = new StringBuilder();
        ret.append("<select name=\"").append(name).append("\">");

        if (includeNone) {
            ret.append("<option value=\"\" >None</option>");
        }

        for (String nxt : values) {
            ret.append("<option ").append(this.optionParams(selectedValue, nxt)).append(">")
               .append(nxt).append("</option>");
        }
        ret.append("</select>");
        return ret.toString();
    }

    // format genomic positions with a thousands (grouping) separators
    // f.e. 12345678 is shown as 12,345,678
    public static String formatThousands(Integer i) {
        if( i==null )
            return "";
        return _thFmt.format(i);
    }

    public static String formatThousands(Long i) {
        if( i==null )
            return "";
        return _thFmt.format(i);
    }

    public static String formatThousands(String i) throws Exception{
        try {
            if( i==null || i.equals(""))
                return "";

            i=i.replaceAll(",","");

            int val = Integer.parseInt(i);

            return _thFmt.format(val);
        }catch (Exception e) {
            return i;
        }
    }

    private static DecimalFormat _thFmt = new DecimalFormat("###,###,###,###");

    public boolean mapPosIsValid(MapData md) {

        return md!=null
            && md.getChromosome()!=null
            && !md.getChromosome().equals("MT")
            && !md.getChromosome().equals("Un")
            && md.getStartPos()!=null
            && md.getStopPos()!=null;
    }
    public boolean mapPosIsValid(VariantMapData vmd) {
        Long start = vmd.getStartPos();
        Long stop = vmd.getEndPos();
        return vmd!=null
                && vmd.getChromosome()!=null
                && !vmd.getChromosome().equals("MT")
                && !vmd.getChromosome().equals("Un")
                && start!=null
                && stop!=null;
    }

    // return a locus string that could be passed to JBrowse
    // f.e. http://dev.rgd.mcw.edu/jbrowse/?data=data_mm37&loc=Chr8%3A74430455..74444798&tracks=ARGD_curated_genes&highlight=
    static public String getJBrowseLoc(MapData md) {
        // increase the locus region in JBrowse by 30% to left side and by 4% to the right side
        // for better visibility of the object
        int locusAdj = (md.getStopPos()-md.getStartPos()) / 10;
        int startPos = md.getStartPos() - 6*locusAdj;
        if( startPos<0 )
            startPos = 1;
        int stopPos = md.getStopPos() + locusAdj/2;
        return (md.getChromosome().length()>2?"":"Chr")+md.getChromosome()+"%3A"+startPos+".."+stopPos;
    }
    static public String getJBrowseLoc(VariantMapData vmd) {
        // increase the locus region in JBrowse by 30% to left side and by 4% to the right side
        // for better visibility of the object
        long locusAdj = (vmd.getEndPos()-vmd.getStartPos()) / 10;
        long startPos = vmd.getStartPos() - 6*locusAdj;
        if( startPos<0 )
            startPos = 1;
        long stopPos = vmd.getEndPos() + locusAdj/2;
        return (vmd.getChromosome().length()>2?"":"Chr")+vmd.getChromosome()+"%3A"+startPos+".."+stopPos;
    }

    static public String getJBrowse2Loc(MapData md,String charPrefix) {
        // for better visibility of the object
        int locusAdj = (md.getStopPos()-md.getStartPos());
        int startPos = (int) (md.getStartPos() - (0.33*locusAdj));
        if( startPos<0 )
            startPos = 1;
        int stopPos = (int) (md.getStopPos() + locusAdj*0.66);
        return (md.getChromosome().length()>2?"":charPrefix)+md.getChromosome()+":"+startPos+"-"+stopPos;
    }

    public String buildHiddenFormFieldsFromQueryString(String queryString) {
        //?chr=&start=&stop=&geneStart=&geneStop=&geneList=a2m&con=&polyphenPrediction=&depthLowBound=&depthHighBound=&sample1=510&sample2=505
        if (queryString.startsWith("?")) {
            queryString = queryString.substring(1,queryString.length());
        }

        Pattern p = Pattern.compile("&*([^=]+)\\=([^&]*)");
        Matcher m = p.matcher(queryString);

        StringBuilder hidden = new StringBuilder();
        while (m.find()) {
            hidden.append("<input type='hidden' name='").append(m.group(1)).append("' value='").append(m.group(2)).append("' />");
        }
        return hidden.toString();
    }

    // break sequence into several lines, 64 nucleotides per line
    static public String formatFasta(String seq) {
        if( seq==null || seq.isEmpty() ) {
            return "";
        }
        String seqFormatted = "";
        int loopCount = (seq.length() + 63) / 64;
        for (int i=0; i<loopCount; i++) {
            if( i+1 == loopCount ) {
                seqFormatted += seq.substring(i*64) + "<br>";
            }else {
                seqFormatted += seq.substring(i*64, (i+1)*64) + "<br>";
            }
        }
        return seqFormatted;
    }
}
