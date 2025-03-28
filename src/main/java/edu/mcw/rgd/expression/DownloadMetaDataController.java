package edu.mcw.rgd.expression;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.Reference;
import edu.mcw.rgd.datamodel.XdbId;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermSynonym;
import edu.mcw.rgd.datamodel.pheno.Condition;
import edu.mcw.rgd.datamodel.pheno.GeneExpressionRecord;
import edu.mcw.rgd.datamodel.pheno.Sample;
import edu.mcw.rgd.datamodel.pheno.Study;
import edu.mcw.rgd.process.Utils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.io.BufferedReader;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.TimeUnit;

public class DownloadMetaDataController implements Controller {
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        PhenominerDAO pdao = new PhenominerDAO();
        GeneExpressionDAO gdao = new GeneExpressionDAO();
        OntologyXDAO xdao = new OntologyXDAO();
        ReferenceDAO rdao = new ReferenceDAO();
        XdbIdDAO xdbIdDAO = new XdbIdDAO();
        ArrayList<String> error = new ArrayList<String>();
        try {
            StringBuilder buffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
                buffer.append(System.lineSeparator());
            }
            JSONObject obj = new JSONObject(buffer.toString());
            reader.close();

            String eSearchUrl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=biosample&term="; // use gsm
            String eLinkUrl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/elink.fcgi?dbfrom=biosample&db=sra&id="; // use gsm ID from search
            String eSummaryUrl = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esummary.fcgi?db=sra&id="; // use SRA ID from link

            String gse = obj.get("gse").toString();
            String title = obj.get("title").toString();
            String species = obj.get("species").toString();

            Study study = gdao.getStudyByGeoIdWithReferences(gse);
            String pmids = "";
            for (int i = 0; i < study.getRefRgdIds().size(); i++){
                Integer rgdId = study.getRefRgdIds().get(i);
                Reference r = rdao.getReferenceByRgdId(rgdId);
                List<XdbId> xdbs = xdbIdDAO.getXdbIdsByRgdId(2,r.getRgdId());
                XdbId xdb = xdbs.get(0);
//                xdbIdDAO.getAllXdbIdsByRgdId()
                if (i == study.getRefRgdIds().size()-1){
                    pmids += xdb.getAccId();
                }
                else {
                    pmids += xdb.getAccId()+";";
                }

            }
            if (Utils.isStringEmpty(pmids))
                pmids=null;
            request.setAttribute("pmids",pmids);
            List<Sample> samples = pdao.getGeoRecordSamplesByStatus(gse,species,"loaded");
            HashMap<String, String> sampleConditionsMap = new HashMap<>();
            HashMap<String, Term> tissueMap = new HashMap<>();
            HashMap<String, Term> strainMap = new HashMap<>();
            HashMap<String, String> strainLinkMap = new HashMap<>();
            HashMap<String, List<String>> sampleSRR = new HashMap<>();
            for (Sample s : samples){
                // get conditions and apply to map
                if (!Utils.isStringEmpty(s.getTissueAccId()) && tissueMap.get(s.getTissueAccId())==null) {
                    Term tissue = xdao.getTermByAccId(s.getTissueAccId().trim());
                    tissueMap.put(s.getTissueAccId(), tissue);
                }
                if (!Utils.isStringEmpty(s.getStrainAccId()) && strainMap.get(s.getStrainAccId())==null){
                    Term strain = xdao.getTermByAccId(s.getStrainAccId().trim());
                    strainMap.put(s.getStrainAccId(), strain);
                    List<TermSynonym> syns = xdao.getTermSynonyms(strain.getAccId());

                    for (TermSynonym syn : syns){
                        if (syn.getName().startsWith("RGD")){
                            String strainSyn = syn.getName().replace("RGD ID: ","");
                            strainLinkMap.put(strain.getAccId(),strainSyn);
                            break;
                        }
                    }
                    strainLinkMap.putIfAbsent(s.getGeoSampleAcc(), "");
                }
                try {
                    Document doc = Jsoup.connect(eSearchUrl + s.getGeoSampleAcc()).get(); // getting ncbi ID for GSM
                    Elements idlist = doc.select("IdList");
                    Element gsmList = idlist.get(0);
                    String gsmId = gsmList.text();
//                String body = doc.data();
                    TimeUnit.SECONDS.sleep(3); // wait a second to not hammer ncbi with requests
                    Document sra = Jsoup.connect(eLinkUrl + gsmId).get(); // getting SRA ID from GSM Id
                    Elements sraLink = sra.select("Link");
                    Element linkId = sraLink.get(0);
                    String sraId = linkId.text();
                    TimeUnit.SECONDS.sleep(3);
                    Document summary = Jsoup.connect(eSummaryUrl + sraId).get();
                    Elements items = summary.select("Item");
                    Element runs = null;
                    for (int i = 0; i < items.size(); i++) {
                        Element e = items.get(i);
                        String name = e.attr("Name");
                        if (Utils.stringsAreEqualIgnoreCase(name, "Runs")) {
                            runs = e;
                            break;
                        }
                    }
                    String[] accSplit = runs.text().split("<Run acc=\"");

                    List<String> srrIds = new ArrayList<>();
                    if (accSplit.length > 2) {
                        for (int x = 1; x < accSplit.length; x++) {
                            if (!accSplit[x].startsWith("SRR"))
                                continue;
                            int index = accSplit[x].indexOf("\"");
                            String srrId = accSplit[x].substring(0, index);
                            srrIds.add(srrId);
                        }
                    } else {
                        int index = accSplit[1].indexOf("\"");
                        String srrId = accSplit[1].substring(0, index);
                        srrIds.add(srrId);
                    }
//                System.out.println("SRR IDS for "+s.getGeoSampleAcc()+": "+srrIds.size());
                    sampleSRR.put(s.getGeoSampleAcc(), srrIds);
                    TimeUnit.SECONDS.sleep(3);
                }
                catch (Exception e){
                    // unable to find SRR
                    sampleSRR.put(s.getGeoSampleAcc(),new ArrayList<>());
                }
                GeneExpressionRecord r = gdao.getGeneExpressionRecordBySampleId(s.getId());
                List<Condition> conditions = gdao.getConditions(r.getId());
                String condNames = "";
                for (int i = 0; i < conditions.size(); i++){
                    Condition c = conditions.get(i);
                    Term t = xdao.getTermByAccId(c.getOntologyId());
                    if (i == conditions.size()-1) {
                        condNames += t.getTerm();
                    }
                    else {
                        condNames += t.getTerm()+";";
                    }
                }
                if (Utils.isStringEmpty(condNames))
                    sampleConditionsMap.put(s.getGeoSampleAcc(),null);
                else
                    sampleConditionsMap.put(s.getGeoSampleAcc(),condNames);
            }

            request.setAttribute("gse", gse);
            request.setAttribute("samples",samples);
            request.setAttribute("title",title);
            request.setAttribute("conditionMap", sampleConditionsMap);
            request.setAttribute("tissueMap", tissueMap);
            request.setAttribute("strainMap", strainMap);
            request.setAttribute("sampleSrrMap", sampleSRR);
            request.setAttribute("pmIds", pmids);
            request.setAttribute("strainSynMap", strainLinkMap);

        }
        catch (Exception e){
            StringWriter sw = new StringWriter();
            PrintWriter pw = new PrintWriter(sw);
            e.printStackTrace(pw);
            String sStackTrace = sw.toString();
            error.add(sStackTrace);
        }
        request.setAttribute("error",error);
        return new ModelAndView("/WEB-INF/jsp/curation/expression/downloadMetaData.jsp");
    }
}
