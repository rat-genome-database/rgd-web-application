<%@ page import="edu.mcw.rgd.datamodel.pheno.Sample"%><%@ page import="java.util.List"%><%@ page import="java.util.HashMap"%><%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term"%><%@ page import="edu.mcw.rgd.process.Utils"%><%@ page import="java.util.ArrayList"%><%@ page import="java.io.StringWriter"%><%@ page import="java.io.PrintWriter"%><%@ page contentType="text/plain;charset=UTF-8" language="java" %><%
String gse = (String) request.getAttribute("gse");
response.setHeader("Content-disposition","attachment;filename=\""+gse+"_AccList.txt\"");
ArrayList<String> error = (ArrayList<String>) request.getAttribute("error");

if (error.isEmpty()){
    try{
    ArrayList<Sample> samples = (ArrayList<Sample>) request.getAttribute("samples");
    String title = (String) request.getAttribute("title");
    HashMap<String, String> conditionMap = (HashMap<String, String>) request.getAttribute("conditionMap");
    HashMap<String, Term> tissueMap = (HashMap<String, Term>) request.getAttribute("tissueMap");
    HashMap<String, Term> strainMap = (HashMap<String, Term>) request.getAttribute("strainMap");
    HashMap<String, List<String>> sampleSrrMap = (HashMap<String, List<String>>) request.getAttribute("sampleSrrMap");
    HashMap<String, String> strainSynMap = (HashMap<String, String>) request.getAttribute("strainSynMap");
    String pmids = (String) request.getAttribute("pmids");
    String geoPath = "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc="+gse;
    String strainPath = "https://rgd.mcw.edu/rgdweb/report/strain/main.html?id=";

    out.print("Run");
    out.print("\t");
    out.print("geo_accession");
    out.print("\t");
    out.print("Tissue");
    out.print("\t");
    out.print("Strain");
    out.print("\t");
    out.print("Sex");
    out.print("\t");
    out.print("PMID");
    out.print("\t");
    out.print("GEOpath");
    out.print("\t");
    out.print("Title");
    out.print("\t");
    out.print("Sample_characteristics");
    out.print("\t");
    out.println("StrainInfo");
//System.out.println("Before for");
    for(Sample s: samples){
//        System.out.println(s.getGeoSampleAcc());
        Term tis = tissueMap.get(s.getTissueAccId());
        String term = null;
        if (tis != null){
            term = tis.getTerm();
            term = term.replace(" ","_");
        }
        Term str = strainMap.get(s.getStrainAccId());
        String strain = null;
        if (str != null){
            strain = str.getTerm().replaceAll("[+*!<>?\"|]","");
            strain = strain.replaceAll("[:\\\\/() .]","_");
            strain = strain.replace("__","_");
            strain = strain.replace("-_+","HET");
            strain = strain.replace("+_-","HET");
            strain = strain.replace("-_-","MUT");
            strain = strain.replace("+_+","WT");
            if (strain.endsWith("_"))
                strain=strain.substring(0,strain.length()-1);
        }
        String conds = conditionMap.get(s.getGeoSampleAcc());
//        System.out.println(tis.getTerm()+"|"+str.getTerm()+"|"+conds);
        List<String> srrIds = sampleSrrMap.get(s.getGeoSampleAcc());
        String strainId = strainSynMap.get(s.getStrainAccId());
//        System.out.println(srrIds);
//        System.out.println(srrIds.size());
        if (srrIds.size()>1){
            for (String srrId : srrIds){
                out.print(srrId);
                out.print("\t");
                out.print(s.getGeoSampleAcc());
                out.print("\t");
                out.print(Utils.NVL(term,"NA"));
                out.print("\t");
                out.print(Utils.NVL(strain,"NA"));
                out.print("\t");
                if (Utils.stringsAreEqualIgnoreCase(s.getSex(),"male")){
                    out.print("M");
                } else if(Utils.stringsAreEqualIgnoreCase(s.getSex(),"female")){
                    out.print("F");
                } else if(Utils.stringsAreEqualIgnoreCase(s.getSex(),"both")){
                    out.print("both");
                } else {
                    out.print("not_specified");
                }
                out.print("\t");
                out.print(Utils.NVL(pmids,"NA"));
                out.print("\t");
                out.print(geoPath);
                out.print("\t");
                out.print(title);
                out.print("\t");
                out.print(Utils.NVL(conds,"NA"));
                out.print("\t");
                if (!Utils.isStringEmpty(strainId))
                    out.println(strainPath+strainId);
                else
                    out.println("NA");
            }
        }
        else if (srrIds.size()==1){
            out.print(srrIds.get(0));
//out.print("");
            out.print("\t");
            out.print(s.getGeoSampleAcc());
            out.print("\t");
            out.print(Utils.NVL(term,"NA"));
            out.print("\t");
            out.print(Utils.NVL(strain,"NA"));
            out.print("\t");
            if (Utils.stringsAreEqualIgnoreCase(s.getSex(),"male")){
                out.print("M");
            } else if(Utils.stringsAreEqualIgnoreCase(s.getSex(),"female")){
                out.print("F");
            } else if(Utils.stringsAreEqualIgnoreCase(s.getSex(),"both")){
                out.print("both");
            } else {
                out.print("not_specified");
            }

            out.print("\t");
            out.print(Utils.NVL(pmids,"NA"));
            out.print("\t");
            out.print(geoPath);
            out.print("\t");
            out.print(title);
            out.print("\t");
            out.print(Utils.NVL(conds,"NA"));
            out.print("\t");
            if (!Utils.isStringEmpty(strainId))
                out.println(strainPath+strainId);
            else
                out.println("NA");
        }
        else{
            out.print("NA");
            out.print("\t");
            out.print(s.getGeoSampleAcc());
            out.print("\t");
            out.print(Utils.NVL(term,"NA"));
            out.print("\t");
            out.print(Utils.NVL(strain,"NA"));
            out.print("\t");
            if (Utils.stringsAreEqualIgnoreCase(s.getSex(),"male")){
                out.print("M");
            } else if(Utils.stringsAreEqualIgnoreCase(s.getSex(),"female")){
                out.print("F");
            } else if(Utils.stringsAreEqualIgnoreCase(s.getSex(),"both")){
                out.print("both");
            } else {
                out.print("not_specified");
            }
            out.print("\t");
            out.print(Utils.NVL(pmids,"NA"));
            out.print("\t");
            out.print(geoPath);
            out.print("\t");
            out.print(title);
            out.print("\t");
            out.print(Utils.NVL(conds,"NA"));
            out.print("\t");
            if (!Utils.isStringEmpty(strainId))
                out.println(strainPath+strainId);
            else
                out.println("NA");
        }
    }
//    System.out.println("After for");
    }catch (Exception e){
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        e.printStackTrace(pw);
        String sStackTrace = sw.toString();
        out.print(sStackTrace);
    }
}
else {
    for (String err : error){
        out.println(err);
    }
}
%>