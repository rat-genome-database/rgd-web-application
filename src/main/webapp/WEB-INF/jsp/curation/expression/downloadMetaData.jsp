<%@ page import="edu.mcw.rgd.datamodel.pheno.Sample"%><%@ page import="java.util.List"%><%@ page import="java.util.HashMap"%><%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term"%><%@ page import="edu.mcw.rgd.process.Utils"%><%@ page import="java.util.ArrayList"%><%@ page contentType="text/plain;charset=UTF-8" language="java" %><%
String gse = request.getParameter("gse");
response.setHeader("Content-disposition","attachment;filename=\""+gse+"_AccList.txt\"");
ArrayList<String> error = (ArrayList<String>) request.getAttribute("error");
//System.out.println(error.size());

if (error.isEmpty()){
    ArrayList<Sample> samples = (ArrayList<Sample>) request.getAttribute("samples");
    String title = (String) request.getAttribute("title");
    HashMap<String, String> conditionMap = (HashMap<String, String>) request.getAttribute("conditionMap");
    HashMap<String, Term> tissueMap = (HashMap<String, Term>) request.getAttribute("tissueMap");
    HashMap<String, Term> strainMap = (HashMap<String, Term>) request.getAttribute("strainMap");
    HashMap<String, List<String>> sampleSrrMap = (HashMap<String, List<String>>) request.getAttribute("sampleSrrMap");
    String pmids = (String) request.getAttribute("pmids");
    String geoPath = "https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc="+gse;

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
    out.println("Sample_characteristics");
//System.out.println("Before for");
    for(Sample s: samples){
//        System.out.println(s.getGeoSampleAcc());
        Term tis = tissueMap.get(s.getTissueAccId());
        Term str = strainMap.get(s.getStrainAccId());
        String strain = str.getTerm().replaceAll("[-+*!<>?\"|]","");
        strain = strain.replaceAll("[:\\\\/() .]","_");
        String conds = conditionMap.get(s.getGeoSampleAcc());
//        System.out.println(tis.getTerm()+"|"+str.getTerm()+"|"+conds);
        List<String> srrIds = sampleSrrMap.get(s.getGeoSampleAcc());
//        System.out.println(srrIds);
//        System.out.println(srrIds.size());
        if (srrIds.size()>1){
            for (String srrId : srrIds){
                out.print(srrId);
                out.print("\t");
                out.print(s.getGeoSampleAcc());
                out.print("\t");
                out.print(tis.getTerm());
                out.print("\t");
                out.print(strain);
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
                out.print(pmids);
                out.print("\t");
                out.print(geoPath);
                out.print("\t");
                out.print(title);
                out.print("\t");
                out.println(conds);
            }
        }
        else if (srrIds.size()==1){
            out.print(srrIds.get(0));
//out.print("");
            out.print("\t");
            out.print(s.getGeoSampleAcc());
            out.print("\t");
            out.print(tis.getTerm());
            out.print("\t");
            out.print(strain);
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
            out.print(pmids);
            out.print("\t");
            out.print(geoPath);
            out.print("\t");
            out.print(title);
            out.print("\t");
            out.println(conds);
        }
        else{
            out.print("");
            out.print("\t");
            out.print(s.getGeoSampleAcc());
            out.print("\t");
            out.print(tis.getTerm());
            out.print("\t");
            out.print(strain);
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
            out.print(pmids);
            out.print("\t");
            out.print(geoPath);
            out.print("\t");
            out.print(title);
            out.print("\t");
            out.println(conds);
        }
    }
//    System.out.println("After for");
}
else {
    for (String err : error){
        out.println(err);
    }
}
%>