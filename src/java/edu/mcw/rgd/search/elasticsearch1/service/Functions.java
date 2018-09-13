package edu.mcw.rgd.search.elasticsearch1.service;

import java.util.List;
import java.util.StringTokenizer;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by jthota on 2/6/2018.
 */
public class Functions {
    private Functions(){}
    public static String format(String str, String term){
        StringTokenizer tokens=new StringTokenizer(term, " ");
        StringBuilder pattern= new StringBuilder();
        StringBuffer sb= new StringBuffer(str.length());
        pattern.append("(");
        while(tokens.hasMoreTokens()){
            pattern.append("(");
            pattern.append(tokens.nextToken());
            pattern.append(")|");

        }
        pattern.append(")");

        Pattern p= Pattern.compile(pattern.toString(), Pattern.CASE_INSENSITIVE);
        Matcher m=p.matcher(str);

        while(m.find()){
            if(!m.group().equals("")){
                String text= "<em>"+ m.group()+"</em>";
                m.appendReplacement(sb, Matcher.quoteReplacement(text));
            }
        }
        m.appendTail(sb);
        return sb.toString();
    }

    public static void main(String[] args){
        Functions f=new Functions();
        String formattedString= Functions.format("abnormal blood pressure regulation", "blood pressure");
        System.out.println(formattedString);
    }
}
