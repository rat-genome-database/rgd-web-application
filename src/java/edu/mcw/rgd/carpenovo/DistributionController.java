package edu.mcw.rgd.carpenovo;

import edu.mcw.rgd.carpenovo.vvservice.VVService;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import edu.mcw.rgd.datamodel.search.Position;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.json.JSONObject;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.*;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 10/21/11
 * Time: 9:53 AM
 */
public class DistributionController extends HaplotyperController {
    private List<String> gSymbols;
    private List<String> sampleIdsFromResultSet;
    private StringBuilder sb;

    public StringBuilder getSb() {
        return sb;
    }

    public void setSb(StringBuilder sb) {
        this.sb = sb;
    }

    public VVService getService() {
        return service;
    }

    public void setService(VVService service) {
        this.service = service;
    }

    public List<String> getSampleIdsFromResultSet() {
        return sampleIdsFromResultSet;
    }

    public void setSampleIdsFromResultSet(List<String> sampleIdsFromResultSet) {
        this.sampleIdsFromResultSet = sampleIdsFromResultSet;
    }

    public List<String> getgSymbols() {
        return gSymbols;
    }
    public void setgSymbols(List<String> gSymbols) {
        this.gSymbols = gSymbols;
    }
    VVService service= new VVService();



    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);
        ModelMap model=new ModelMap();
        List regionList = new ArrayList();
        Map<String,Map<String,Integer>> resultHash = Collections.emptyMap();
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
        request.setAttribute("mapKey", mapKey);

        // derive species from mapKey
        int speciesTypeKey = MapManager.getInstance().getMap(mapKey).getSpeciesTypeKey();
        System.out.println("MAPKEY:"+ mapKey +"\t CHROMOSOME: "+ chromosome);
        String index=new String();
        if(mapKey==17) {
            if(!chromosome.equals(""))
            index = "variants_human_chr"+chromosome+"_dev1";
            else index="variants_human_*_dev1";
        }
   //   index= RgdContext.getESIndexName("variant_"+SpeciesType.getCommonName(speciesTypeKey).toLowerCase());
        if(mapKey==360 || mapKey==70 || mapKey==60)
                index= "variant_rat_index_dev1";
        if(mapKey==631 || mapKey==600 )
            index= "variant_dog_index_dev2";
            service.setVariantIndex(index);
        List<String> symbols=new ArrayList<>();
        vsb = new VariantSearchBean(mapKey);
        vsb.setPosition(chromosome, start, stop);

        try {

            if ((start.isEmpty() || stop.isEmpty()) && !this.hasAnnotation(req)) {

                if (req.getParameter("geneList").equals("") && req.getParameter("geneStart").equals("") && req.getParameter("geneStop").equals("")) {
                    throw new Exception("Please define a region");
                }

                Position p = this.getPosition(req.getParameter("geneList"), req.getParameter("geneStart"), req.getParameter("geneStop"), mapKey);
                chromosome = p.getChromosome();
                start = p.getStart() + "";
                stop = p.getStop() + "";
            }

            Set<String> masterKeySet = new HashSet<String>();

            VariantDAO vdao = new VariantDAO();
            vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

            List<MappedGene> mgs = new ArrayList<MappedGene>();

            GeneDAO gdao = new GeneDAO();

        if (this.hasAnnotation(req)) {

            String rdoTerm =  req.getParameter("rdo_acc_id");
            String pwTerm = req.getParameter("pw_acc_id");
            String mpTerm = req.getParameter("mp_acc_id");
            String chebiTerm = req.getParameter("chebi_acc_id");

            List<String> rdoGenes = new ArrayList<String>();
            List<String> pwGenes = new ArrayList<String>();
            List<String> mpGenes = new ArrayList<String>();
            List<String> chebiGenes = new ArrayList<String>();

            if (req.getParameter("chr").equals("")) {
                throw new Exception("Chromosome can not be empty.  Please select a chromosome.");
            }

            AnnotationDAO adao = new AnnotationDAO();
            ArrayList accIds = new ArrayList();
            OntologyXDAO xdao = new OntologyXDAO();

            int geneCount = 0;
            int rdoCount=0;
            int pwCount=0;
            int mpCount=0;
            int chebiCount=0;

            if (!rdoTerm.equals("")) {
                TermWithStats tws = xdao.getTermWithStatsCached(rdoTerm, null);

                rdoCount = tws.getRatGeneCountForTermAndChildren();
                geneCount += rdoCount;
                accIds.add(rdoTerm);
            }
            if (!pwTerm.equals("")) {
                TermWithStats tws = xdao.getTermWithStatsCached(pwTerm, null);

                pwCount = tws.getRatGeneCountForTermAndChildren();
                geneCount += pwCount;
                accIds.add(pwTerm);
            }
            if (!mpTerm.equals("")) {
                TermWithStats tws = xdao.getTermWithStatsCached(mpTerm, null);

                mpCount = tws.getRatGeneCountForTermAndChildren();
                geneCount += mpCount;
                accIds.add(mpTerm);
            }
            if (!chebiTerm.equals("")) {
                TermWithStats tws = xdao.getTermWithStatsCached(chebiTerm, null);

                chebiCount = tws.getRatGeneCountForTermAndChildren();
                geneCount += chebiCount;
                accIds.add(chebiTerm);
            }

            if (geneCount > 200000) {

                errors.add("Total gene count can not be greater than 2000.  Please select a child term to limit annotated genes.<br><br>Disease:&nbsp;&nbsp;" + rdoCount + "<br>Pathway:&nbsp;&nbsp;" + pwCount + "<br>Phenotype:&nbsp;&nbsp;" + mpCount + "<br>Drug/Chemical:&nbsp;&nbsp;" + chebiCount);
                request.setAttribute("error", errors);

                return new ModelAndView("/WEB-INF/jsp/haplotyper/annotation.jsp");
            }

            Integer startPos=null;
            Integer stopPos=null;

            try {
                startPos=Integer.parseInt(start);
            }catch (Exception e) {

            }

            try {
                stopPos=Integer.parseInt(stop);
            }catch (Exception e) {

            }

            Iterator it = accIds.iterator();
            while (it.hasNext()) {
                String acc = (String) it.next();
            }

            //why is gene symbols list size zero.

            List<String> geneSymbols = adao.getAnnotatedGeneSymbols(accIds, mapKey, chromosome, startPos, stopPos);

            if (geneSymbols.size() > 0) {

                if (!rdoTerm.equals("")) {
                    accIds = new ArrayList();
                    accIds.add(rdoTerm);
                    rdoGenes = adao.getAnnotatedGeneSymbols(accIds,mapKey,chromosome, startPos, stopPos);
                }

                request.setAttribute("rdoGenes", rdoGenes);
                if (!pwTerm.equals("")) {
                    accIds = new ArrayList();
                    accIds.add(pwTerm);
                    pwGenes = adao.getAnnotatedGeneSymbols(accIds,mapKey,chromosome, startPos, stopPos);
                }

                request.setAttribute("pwGenes", pwGenes);
                if (!mpTerm.equals("")) {
                    accIds = new ArrayList();
                    accIds.add(mpTerm);
                    mpGenes = adao.getAnnotatedGeneSymbols(accIds,mapKey,chromosome, startPos, stopPos);
                }

                request.setAttribute("mpGenes", mpGenes);
                if (!chebiTerm.equals("")) {
                    accIds = new ArrayList();
                    accIds.add(chebiTerm);
                    chebiGenes = adao.getAnnotatedGeneSymbols(accIds,mapKey,chromosome, startPos, stopPos);

                }

                request.setAttribute("chebiGenes", chebiGenes);
                HashMap termMap =  new HashMap();
                termMap.put(req.getParameter("rdo_acc_id"), req.getParameter("rdo_term"));

               mgs = gdao.getActiveMappedGenes(mapKey,geneSymbols);
            }

        } else if (!req.getParameter("geneList").equals("") && !req.getParameter("geneList").contains("|")) {
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

            sb.append("[");
            boolean first=true;
            for(Map.Entry e:resultHash.entrySet()){
                String sample= (String) e.getKey();

                Map<String, Integer> geneCountMap= (Map<String, Integer>) e.getValue();

                for(Map.Entry e1:geneCountMap.entrySet()){
                    String gene= (String) e1.getKey();
                    int value= (int) e1.getValue();
                    if(first) {
                        sb.append("{\"sample\": \"" + sample + "\", ");
                        sb.append("\"gene\": \"" + gene + "\", ");
                        sb.append(" \"value\":" + value + "}");
                        first=false;
                    }else{
                        sb.append(", {\"sample\": \"" + sample + "\", ");
                        sb.append("\"gene\": \"" + gene + "\", ");
                        sb.append(" \"value\": " + value + "}");
                    }
                }

            }
            sb.append("]");
            this.sb=sb;
      //      System.out.println(sb.toString());
            System.out.println("SYMBOLS SIZE: "+ gSymbols.size());
            System.out.println("GSYMBOLS SIZE: "+ gSymbols.size());
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
        System.out.println("GENES SIZE IN VSB:"+vsb.genes.size());
        if (vsb.genes.size()==0) {

            List<MappedGene> mappedGenes = gdao.getActiveMappedGenes(vsb.getChromosome(), vsb.getStartPosition(), vsb.getStopPosition(), vsb.getMapKey());

            lastGene="";
            for (MappedGene mg: mappedGenes) {

                symbol = mg.getGene().getSymbol();

                if (first.equals("")) {
                    first=symbol;
                }

                if (!lastGene.equals(""))  {
                    if (masterKeySet.contains(lastGene + "|" + mg.getGene().getSymbol())) {
                        regionList.add(lastGene + "|" + mg.getGene().getSymbol());
                        masterKeySet.remove(lastGene + "|" + mg.getGene().getSymbol());
                    }
                }

                if (vsb.getGeneMap().size() > 0) {
                    if (vsb.getGeneMap().containsKey(symbol)) {
                        regionList.add(symbol);
                    }
                }else {
                    regionList.add(symbol);
                }

                masterKeySet.remove(symbol);
                lastGene=symbol;

            }

            Iterator masterIt = masterKeySet.iterator();
            while (masterIt.hasNext()) {

                String key = (String) masterIt.next();

                if (key.startsWith(symbol + "|")) {
                    regionList.add(key);
                }else if (key.endsWith("|" + first)){
                    regionList.add(0,key);
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



            request.setAttribute("json", this.sb.toString());
            request.setAttribute("regionList", regionList);
        //    request.setAttribute("sampleIds", sampleIds);
            request.setAttribute("sampleIds", sampleIdsFromResultSet);
            request.setAttribute("resultHash", resultHash);
            request.setAttribute("json",sb.toString() );
            request.setAttribute("vsb", vsb);
            request.setAttribute("maxValue", maxValue);


            return new ModelAndView("/WEB-INF/jsp/haplotyper/dist.jsp");

        }catch (Exception e) {
            errors.add(e.getMessage());
            request.setAttribute("error", errors);
            request.setAttribute("json",this.sb.toString() );
            request.setAttribute("regionList", regionList);
            //    request.setAttribute("sampleIds", sampleIds);
            request.setAttribute("sampleIds", sampleIdsFromResultSet);
            request.setAttribute("resultHash", resultHash);
            request.setAttribute("vsb", vsb);
            request.setAttribute("maxValue", maxValue);

            return new ModelAndView("/WEB-INF/jsp/haplotyper/dist.jsp");
        }
    }

    List<String> loadSampleIds(HttpServletRequest request) throws Exception{

        List<String> sampleIds = new ArrayList<String>();
        if(request.getParameter("sample1")!=null) {

            if (request.getParameter("sample1").equals("all")) {

                SampleDAO sdao = new SampleDAO();
                sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
                int mapKey = Integer.parseInt(request.getParameter("mapKey"));
                List<Sample> samples = sdao.getSamplesByMapKey(mapKey);

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
            sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
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
                    Sample s=SampleManager.getInstance().getSampleName(Integer.parseInt(sampleId));
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
            System.out.println("TOOK: "+ sr.getTook());
            Terms samplesAgg = sr.getAggregations().get("sampleId");
            List<Terms.Bucket> samplebkts = (List<Terms.Bucket>) samplesAgg.getBuckets();
            List<String> sampleIdsFromResultSet= new ArrayList<>();
            for (Terms.Bucket b : samplebkts) {
                Map<String, Integer> geneCountMap = new HashMap<>();
                Terms geneAggs = b.getAggregations().get("region");
                int totalDocCount=0;
                for (Terms.Bucket gb : geneAggs.getBuckets()) {
                    totalDocCount=totalDocCount+(int) gb.getDocCount();
                    geneCountMap.put((String) gb.getKey(), (int) gb.getDocCount());
                    geneKeys.add((String) gb.getKey());

                }
            //    System.out.println("GENE COUNT: "+ totalDocCount + "\t"+b.getKey());
                if(totalDocCount>0) {
                    sampleIdsFromResultSet.add(String.valueOf(b.getKey()));
                    variantGeneCountMap.put(String.valueOf(b.getKey()), geneCountMap);
                }
            }
            //    Collections.sort(sampleIdsFromResultSet);
            this.setSampleIdsFromResultSet(sampleIdsFromResultSet);

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
                                 //      System.out.print(b.getKey() + "\t" + samp.getKey() + "\t" + samp.getDocCount() + "\t");

                                        variantGeneCountMap.put(samp.getKey().toString(), geneVarCountsOfSample);
                                    }else{
                                        geneVarCountsOfSample=new HashMap<>();
                                        geneVarCountsOfSample.put(b.getKey().toString(),(int) samp.getDocCount());
                                        variantGeneCountMap.put(samp.getKey().toString(), geneVarCountsOfSample);
                                    }

                                }
                               // System.out.print("\n");
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
                 //   System.out.println(e.getKey()+"\t"+e1.getKey()+"\t"+ e1.getValue());
                }
            }
        }
        Collections.sort(symbols, new Comparator<String>() {
            @Override
            public int compare(String o1, String o2) {
                return Utils.stringsCompareToIgnoreCase(o1, o2);
            }
        });
        this.setgSymbols(symbols);


       return variantGeneCountMap;
    }
}
