package edu.mcw.rgd.vv;

import edu.mcw.rgd.vv.vvservice.VVService;
import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.GeneLociDAO;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.datamodel.GeneLoci;
import edu.mcw.rgd.datamodel.MappedGene;
import edu.mcw.rgd.datamodel.Sample;
import edu.mcw.rgd.datamodel.VariantSearchBean;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 10/21/11
 * Time: 9:53 AM
 */
public class DistributionController extends HaplotyperController {
    private List<String> gSymbols;
  //  private List<String> sampleIdsFromResultSet;


    VVService service= new VVService();
    GeneLociDAO geneLociDAO=new GeneLociDAO();


    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);

        List regionList = new ArrayList();
        List<String> regionList1=new ArrayList<>();
        Map<String,Map<String,Integer>> resultHash = Collections.emptyMap();
        String[][] matrix= null;
        StringBuilder sb=new StringBuilder();
        VariantSearchBean vsb = null;
        int maxValue =0;

        String chromosome = req.getParameter("chr");
        String start = req.getParameter("start").replaceAll(",","");
        String stop = req.getParameter("stop").replaceAll(",","");

        ArrayList errors = new ArrayList();

        // load sample ids
        List<String> sampleIds = loadSampleIds(request);

        // load map_key; if not given, derive it from sample ids
        int mapKey = loadMapKey(req, sampleIds);
        request.setAttribute("mapKey", mapKey );

        // derive species from mapKey
       // int speciesTypeKey = MapManager.getInstance().getMap(mapKey).getSpeciesTypeKey();
     // System.out.println("MAPKEY IN DIST CONTRL:"+ mapKey+ "\tchromosome: "+chromosome+"\tstart: "+start+"\tstop:" +stop);
        String env="test";
        String index=new String();
        if(mapKey==17) {
            index = "variants_human"+mapKey+"_"+env;
        }
        if(mapKey==360 || mapKey==70 || mapKey==60)
              //  index= "variants_rat"+mapKey+"_dev";
            index= "variants_rat"+mapKey+"_"+env;
        if(mapKey==631 || mapKey==600 )
            index= "variants_dog"+mapKey+"_"+env;
        VVService.setVariantIndex(index);
        List<String> symbols=new ArrayList<>();
        vsb = new VariantSearchBean(mapKey);
        vsb.setPosition(chromosome, start, stop);

     //   try {

             Set<String> masterKeySet = new HashSet<String>();
           GeneDAO gdao = new GeneDAO();

     if (!req.getParameter("geneList").equals("") && !req.getParameter("geneList").contains("|")) {
            symbols= Utils.symbolSplit(req.getParameter("geneList"));
        }

        if (sampleIds.size() > 0) {

            if (!req.getParameter("chr").equals("")) {
                vsb.setChromosome(req.getParameter("chr"));
            }
           //vsb.sampleIds.add(Integer.parseInt(sample));
            for (String sample: sampleIds) {
                vsb.sampleIds.add(Integer.parseInt(sample));
            }



            // conservation parameters
            float conLow = -1;
            float conHigh = -1;
            switch (req.getParameter("con")) {
                case "n":
                    conLow = 0;
                    conHigh = 0;
                    break;
                case "l":
                    conLow = .01f;
                    conHigh = .49f;
                    break;
                case "m":
                    conLow = .5f;
                    conHigh = .749f;
                    break;
                case "h":
                    conLow = .75f;
                    conHigh = 1f;
                    break;
            }
            if(symbols.size()>0){
                vsb.setGenes(symbols);
            }
             vsb.setConnective(req.getParameter("connective"));
             vsb.setAAChange(req.getParameter("synonymous"), req.getParameter("nonSynonymous"));
             vsb.setGenicStatus(req.getParameter("genic"), req.getParameter("intergenic"));
             vsb.setIsPrematureStop(req.getParameter("prematureStopCodon"));
             vsb.setIsReadthrough(req.getParameter("readthroughMutation"));
             vsb.setConScore(conLow, conHigh);
             vsb.setDepth(req.getParameter("depthLowBound"), req.getParameter("depthHighBound"));
             vsb.setNearSpliceSite(req.getParameter("nearSpliceSite"));
             vsb.setZygosity(req.getParameter("het"), req.getParameter("hom"), req.getParameter("possiblyHom"), req.getParameter("hemi"), req.getParameter("probablyHemi"), req.getParameter("possiblyHemi"), req.getParameter("excludePossibleError"), req.getParameter("hetDiffFromRef"));
             vsb.setScore(req.getParameter("scoreLowBound"), req.getParameter("scoreHighBound"));
             vsb.setDBSNPNovel(req.getParameter("notDBSNP"), req.getParameter("foundDBSNP"));
             vsb.setLocation(req.getParameter("intron"), req.getParameter("3prime"), req.getParameter("5prime"), req.getParameter("proteinCoding"));
             //vsb.setPseudoautosomal(req.getParameter("excludePsudoautosomal"), req.getParameter("onlyPsudoautosomal"));
             vsb.setAlleleCount(req.getParameter("alleleCount1"),req.getParameter("alleleCount2"),req.getParameter("alleleCount3"),req.getParameter("alleleCount4"));
             vsb.setVariantType(req.getParameter("snv"),req.getParameter("ins"),req.getParameter("del"));
             vsb.setIsFrameshift(req.getParameter("frameshift"));
             vsb.setPolyphen(req.getParameter("benign"), req.getParameter("possibly"), req.getParameter("probably"));
             vsb.setClinicalSignificance(req.getParameter("cs_pathogenic"), req.getParameter("cs_benign"), req.getParameter("cs_other"));

     // resultHash = vdao.getVariantToGeneCountMap(vsb);

            resultHash =this.getVariantToGeneCountMap(vsb, req);

            if(symbols.size()==0){
                vsb.genes.addAll(gSymbols);
            }

            for(Map<String,Integer> map: resultHash.values()) {
                masterKeySet.addAll(map.keySet());
       //         vsb.genes.addAll(map.keySet());             //add gene symbols from the results returned by search response.
                for (Object o : map.keySet()) {
                    int value = map.get(o);
                    if (value > maxValue) {
                        maxValue = value;
                    }
                }
            }
        }

        String symbol = "";
        String lastGene="";
        String first = "";

        //need to be different for functional search

        if (vsb.genes.size()==0) {
            if(resultHash.size()>0) {
                List<MappedGene> mappedGenes = gdao.getActiveMappedGenes(vsb.getChromosome(), vsb.getStartPosition(), vsb.getStopPosition(), vsb.getMapKey());
                lastGene = "";
                for (MappedGene mg : mappedGenes) {

                    symbol = mg.getGene().getSymbol();

                    if (first.equals("")) {
                        first = symbol;
                    }

                    if (!lastGene.equals("")) {
                        if (masterKeySet.contains(lastGene + "|" + mg.getGene().getSymbol())) {
                            regionList.add(lastGene + "|" + mg.getGene().getSymbol());
                            masterKeySet.remove(lastGene + "|" + mg.getGene().getSymbol());
                        }
                    }

                    if (vsb.getGeneMap().size() > 0) {
                        if (vsb.getGeneMap().containsKey(symbol)) {
                            regionList.add(symbol);
                        }
                    } else {
                        regionList.add(symbol);
                    }

                    masterKeySet.remove(symbol);
                    lastGene = symbol;

                }

                Iterator masterIt = masterKeySet.iterator();
                while (masterIt.hasNext()) {

                    String key = (String) masterIt.next();

                    if (key.startsWith(symbol + "|")) {
                        regionList.add(key);
                    } else if (key.endsWith("|" + first)) {
                        regionList.add(0, key);
                    }
                }
            }
        }else {
            regionList = vsb.genes;
            if (req.getParameter("geneList").indexOf("|") != -1) {
                regionList.add(req.getParameter("geneList"));
            }
        }

            if (!errors.isEmpty()) {
                request.setAttribute("error", errors);
            }
            if(chromosome!=null && !chromosome.equals("") ) {
                if(resultHash.size()>0) {
                    List<GeneLoci> loci = geneLociDAO.getGeneLociByRegionName(mapKey, chromosome, (List<String>) regionList);
                    for (GeneLoci l : loci) {
                        if (!regionList1.contains(l.getGeneSymbols())) {
                            regionList1.add(l.getGeneSymbols());
                        }
                    }
                }
            }else{
                regionList1=gSymbols;
            }
            Collections.sort(sampleIds);
            request.setAttribute("regionList", regionList1);
            request.setAttribute("sampleIds", sampleIds);
            request.setAttribute("resultHash", resultHash);
            request.setAttribute("json",sb.toString() );
            request.setAttribute("vsb", vsb);
            request.setAttribute("maxValue", maxValue);
        ModelMap model=new ModelMap();
        model.addAttribute("matrix", matrix);
            return new ModelAndView("/WEB-INF/jsp/vv/dist.jsp", model);

     //   }catch (Exception e) {
        /*    errors.add(e.getMessage());
            request.setAttribute("error", errors);
            request.setAttribute("json",this.sb.toString() );
            request.setAttribute("regionList", regionList);
            //    request.setAttribute("sampleIds", sampleIds);
            request.setAttribute("sampleIds", sampleIdsFromResultSet);
            request.setAttribute("resultHash", resultHash);
            request.setAttribute("vsb", vsb);
            request.setAttribute("maxValue", maxValue);

            return new ModelAndView("/WEB-INF/jsp/vv/dist.jsp");*/
     //   }

    }

    List<String> loadSampleIds(HttpServletRequest request) throws Exception{

        List<String> sampleIds = new ArrayList<String>();
        if(request.getParameter("sample1")!=null) {

            if (request.getParameter("sample1").equals("all")) {

                SampleDAO sdao = new SampleDAO();
                sdao.setDataSource(DataSourceFactory.getInstance().getDataSource("variant"));
                int mapKey = Integer.parseInt(request.getParameter("mapKey"));
                List<Sample> samples=new ArrayList<>();
                if(mapKey==17){
                    List<String> populations= new ArrayList<>(Arrays.asList("FIN","GBR"));
                    for(String p:populations){
                        samples .addAll(sdao.getSamplesByMapKey(mapKey, p));
                    }
                }else {
                    samples= sdao.getSamplesByMapKey(mapKey);
                }

                for (Sample s : samples) {
                    sampleIds.add(s.getId() + "");
                }

            } else {


                for (int i = 0; i < 1000; i++) {
                    if (request.getParameter("sample" + i) != null) {
                        sampleIds.add(request.getParameter("sample" + i));
                    }
                }
            }
        }else{
            SampleDAO sdao = new SampleDAO();
            sdao.setDataSource(DataSourceFactory.getInstance().getDataSource("variant"));
            int mapKey = Integer.parseInt(request.getParameter("mapKey"));
            List<Sample> samples = sdao.getSamplesByMapKey(mapKey);

            for (Sample s : samples) {
                sampleIds.add(s.getId() + "");
            }

        }
        return sampleIds;
    }

    int loadMapKey(HttpRequestFacade req, List<String> sampleIds) throws Exception {
        int mapKey;
        try {
            mapKey = Integer.parseInt(req.getParameter("mapKey"));
        }
        catch (NumberFormatException e) {
            // try to guess map key from sample ids
            mapKey = 0;
            for( String sampleId: sampleIds ) {
                if (sampleId != null) {
                    Sample s= SampleManager.getInstance().getSampleName(Integer.parseInt(sampleId));
                    if(s!=null){
                    int sampleMapKey = s.getMapKey();
                    if (sampleMapKey > 0) {
                        if (mapKey == 0) {
                            mapKey = sampleMapKey;
                        } else if (mapKey != sampleMapKey) {
                            throw new Exception("Map Key Required. Samples having multiple map keys.");
                        }
                    }
                }
            }}
            if( mapKey==0 )
                throw new Exception("Map Key Required.  Please choose an assembly.");
        }
        return mapKey;
    }

    private boolean hasAnnotation(HttpRequestFacade req) {
        return !(req.getParameter("rdo_acc_id").isEmpty() && req.getParameter("pw_acc_id").isEmpty()
                && req.getParameter("mp_acc_id").isEmpty() && req.getParameter("chebi_acc_id").isEmpty());
    }
    public Map<String,Map<String, Integer>> getVariantToGeneCountMap(VariantSearchBean vsb, HttpRequestFacade req) throws IOException {


        Set<String> geneKeys=new HashSet<>();
        List<String> symbols = new ArrayList<>();
        Map<String, Map<String, Integer>> variantGeneCountMap=new HashMap<>();

            if(!req.getParameter("showDifferences").equals("true")){
            SearchResponse sr=service.getAggregations(vsb, req);

            Terms samplesAgg = sr.getAggregations().get("sampleId");
            List<Terms.Bucket> samplebkts = (List<Terms.Bucket>) samplesAgg.getBuckets();
            List<String> sampleIdsFromResultSet= new ArrayList<>();
            for (Terms.Bucket b : samplebkts) {
                    Map<String, Integer> geneCountMap = new HashMap<>();
                    Terms geneAggs = b.getAggregations().get("region");
                    int totalDocCount = 0;
                    for (Terms.Bucket gb : geneAggs.getBuckets()) {
                        totalDocCount = totalDocCount + (int) gb.getDocCount();
                        geneCountMap.put((String) gb.getKey(), (int) gb.getDocCount());
                        geneKeys.add((String) gb.getKey());

                    }
                    if (totalDocCount > 0) {
                     /*   boolean flag=false;
                        for(int id:vsb.sampleIds){
                            if(id==(((Long) b.getKey()))){
                                flag=true;
                            }
                        }*/
                      //  if(flag) {
                      //      sampleIdsFromResultSet.add(String.valueOf(b.getKey()));
                            variantGeneCountMap.put(String.valueOf(b.getKey()), geneCountMap);
                       // }
                    }

                }
                //    Collections.sort(sampleIdsFromResultSet);
             //   this.setSampleIdsFromResultSet(sampleIdsFromResultSet);

        }  else{

                SearchResponse sr=service.getAggregations(vsb, req);

                Terms regionAgg = sr.getAggregations().get("regionName");

                List<Terms.Bucket> regionbkts = (List<Terms.Bucket>) regionAgg.getBuckets();

                for (Terms.Bucket b : regionbkts) {

                     geneKeys.add((String) b.getKey());


                    Terms posAggs = b.getAggregations().get("startPos");

                    for(Terms.Bucket pos:posAggs.getBuckets()){
                         Terms sampleAggs= pos.getAggregations().get("sample");

                        if(sampleAggs.getBuckets().size()< vsb.sampleIds.size()) {
                            for (Terms.Bucket samp : sampleAggs.getBuckets()) {
                                if (samp.getDocCount() < vsb.sampleIds.size()) {
                                    Map<String, Integer> geneVarCountsOfSample = variantGeneCountMap.get(samp.getKey().toString());
                                    if (geneVarCountsOfSample != null) {
                                        Integer varNucCountOfGeneOfSample = geneVarCountsOfSample.get(b.getKey());
                                        if (varNucCountOfGeneOfSample != null) {
                                            varNucCountOfGeneOfSample = varNucCountOfGeneOfSample + (int) samp.getDocCount();
                                            geneVarCountsOfSample.put(b.getKey().toString(), varNucCountOfGeneOfSample);

                                        } else {
                                            geneVarCountsOfSample.put(b.getKey().toString(), (int) samp.getDocCount());
                                        }

                                        variantGeneCountMap.put(samp.getKey().toString(), geneVarCountsOfSample);
                                    }else{
                                        geneVarCountsOfSample=new HashMap<>();
                                        geneVarCountsOfSample.put(b.getKey().toString(),(int) samp.getDocCount());
                                        variantGeneCountMap.put(samp.getKey().toString(), geneVarCountsOfSample);
                                    }

                                }
                            }
                        }

                    }


                }

           }
        gene:
        for (String g : geneKeys) {
            for (Map.Entry e : variantGeneCountMap.entrySet()) {
                Map<String, Integer> geneDocCount = (Map) e.getValue();
                for (Map.Entry e1 : geneDocCount.entrySet()) {
                    String g1 = (String) e1.getKey();
                    int docCount = (int) e1.getValue();
                    if (g1.equals(g)) {
                        if (docCount > 0) {
                            symbols.add(g);
                            continue gene;
                        }
                    }
                }
            }
        }

        this.setgSymbols(symbols);


       return variantGeneCountMap;
    }


    public VVService getService() {
        return service;
    }

    public void setService(VVService service) {
        this.service = service;
    }



    public List<String> getgSymbols() {
        return gSymbols;
    }
    public void setgSymbols(List<String> gSymbols) {
        this.gSymbols = gSymbols;
    }

}
