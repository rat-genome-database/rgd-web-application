package edu.mcw.rgd.vv;

import co.elastic.clients.elasticsearch._types.aggregations.LongTermsAggregate;
import co.elastic.clients.elasticsearch._types.aggregations.LongTermsBucket;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsAggregate;
import co.elastic.clients.elasticsearch._types.aggregations.StringTermsBucket;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.vv.vvservice.VVService;
import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.GeneLociDAO;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.Map;
import java.util.stream.Collectors;

public class DistributionController extends HaplotyperController {
    private List<String> gSymbols;

    GeneLociDAO geneLociDAO=new GeneLociDAO();
    GeneDAO gdao = new GeneDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);

        List<String> regionList = new ArrayList<>();
        Map<String,Map<String,Integer>> resultHash = Collections.emptyMap();
        int maxValue =0;

        String chromosome = req.getParameter("chr");

        ArrayList errors = new ArrayList();


        Set<String> masterKeySet = new HashSet<String>();

        VariantSearchBean vsb = this.fillBean(req);
        request.setAttribute("mapKey", vsb.getMapKey() );

        // derive species from mapKey
        int speciesTypeKey = MapManager.getInstance().getMap(vsb.getMapKey()).getSpeciesTypeKey();
        request.setAttribute("speciesTypeKey", speciesTypeKey);
       try {

        if (!req.getParameter("geneList").equals("") && !req.getParameter("geneList").contains("|")) {
            mapGeneSymbols(req.getParameter("geneList"),vsb);
        }

        if (vsb.getSampleIds().size() > 0) {

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

            try {
                resultHash = this.getVariantToGeneCountMap(vsb, req);
            }catch (VVException e){
                throw e;
            }


            for(Map<String,Integer> map: resultHash.values()) {
                masterKeySet.addAll(map.keySet());
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

        if (vsb.getGenes().size()==0) {
            if(resultHash.size()>0) {
                List<MappedGene> mappedGenes = gdao.getActiveMappedGenes(vsb.getChromosome(), vsb.getStartPosition(), vsb.getStopPosition(), vsb.getMapKey());
                lastGene = "";
                for (MappedGene mg : mappedGenes) {

                    symbol = mg.getGene().getSymbol();

                    if (first.equals("")) {
                        first = symbol;
                    }

                    if (!lastGene.equals("")) {
                        if (masterKeySet.contains(lastGene.toLowerCase() + "|" + mg.getGene().getSymbol().toLowerCase())) {
                            regionList.add(lastGene.toLowerCase() + "|" + mg.getGene().getSymbol().toLowerCase());
                            masterKeySet.remove(lastGene.toLowerCase() + "|" + mg.getGene().getSymbol().toLowerCase());
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

                    if (key.startsWith(symbol.toLowerCase() + "|")) {
                        regionList.add(key);
                    } else if (key.endsWith("|" + first)) {
                        regionList.add(0, key);
                    }
                }
            }
        }else {
            regionList = vsb.getGenes();
            if (URLDecoder.decode(req.getParameter("geneList"), StandardCharsets.UTF_8).contains("|")) {
                regionList.add(req.getParameter("geneList"));
            }
        }

        if (!errors.isEmpty()) {
            request.setAttribute("error", errors);
        }
        if(chromosome!=null && !chromosome.equals("") ) {
            if(resultHash.size()>0 && regionList.size()>0 ) {
                if(regionList.size()<=1000) {
                    List<GeneLoci> loci = geneLociDAO.getGeneLociByRegionName(vsb.getMapKey(), chromosome, (List<String>) regionList);
                    for (GeneLoci l : loci) {
                        if (!regionList.contains(l.getGeneSymbols())) {
                            regionList.add(l.getGeneSymbols());
                        }
                    }
                }else{
                  Collection[] collections=  split(regionList, 1000);
                    List<GeneLoci> loci=new ArrayList<>();
                    for (int i = 0; i < collections.length; i++) {
                      List<GeneLoci> geneLoci= geneLociDAO.getGeneLociByRegionName(vsb.getMapKey(), chromosome, (List<String>) collections[i]);
                       if(geneLoci!=null && geneLoci.size()>0)
                        loci.addAll(geneLoci);
                    }
                    for (GeneLoci l : loci) {
                        if (!regionList.contains(l.getGeneSymbols())) {
                            regionList.add(l.getGeneSymbols());
                        }
                    }
                }
            }
        }
     String geneList=  regionList.stream().filter(p->!p.contains("|")).collect(Collectors.joining("+"));
        request.setAttribute("regionList", regionList);
        request.setAttribute("geneListStr", geneList);

        request.setAttribute("sampleIds", vsb.getSampleIds());
        request.setAttribute("resultHash", resultHash);
        request.setAttribute("vsb", vsb);
        request.setAttribute("maxValue", maxValue);

        return new ModelAndView("/WEB-INF/jsp/vv/dist.jsp");

       }catch (Exception e) {

           errors.add(e.getMessage());
            request.setAttribute("error", errors);
            request.setAttribute("regionList", regionList);
            request.setAttribute("sampleIds", vsb.getSampleIds());
            request.setAttribute("resultHash", resultHash);
            request.setAttribute("vsb", vsb);
            request.setAttribute("maxValue", maxValue);

            return new ModelAndView("/WEB-INF/jsp/vv/dist.jsp");
         }

    }
    private static final int GENE_BATCH_SIZE = 200;

    public Map<String,Map<String, Integer>> getVariantToGeneCountMap(VariantSearchBean vsb, HttpRequestFacade req) throws VVException {

        Set<String> geneKeys=new HashSet<>();
        List<String> symbols = new ArrayList<>();
        Map<String, Map<String, Integer>> variantGeneCountMap=new HashMap<>();

        // batch large gene lists to avoid ES too_many_buckets / search_phase_execution errors
        List<String> allGenes = vsb.getGenes();
        List<List<String>> geneBatches = new ArrayList<>();
        if (allGenes != null && allGenes.size() > GENE_BATCH_SIZE) {
            for (int i = 0; i < allGenes.size(); i += GENE_BATCH_SIZE) {
                geneBatches.add(allGenes.subList(i, Math.min(i + GENE_BATCH_SIZE, allGenes.size())));
            }
        } else {
            geneBatches.add(allGenes);
        }

        if(!req.getParameter("showDifferences").equals("true")){
            for (List<String> batch : geneBatches) {
                vsb.setGenes(batch);
                SearchResponse<java.util.Map> sr = getAggregations(vsb, req);
                if (sr == null) continue;

                LongTermsAggregate samplesAgg = sr.aggregations().get("sampleId").lterms();
                for (LongTermsBucket b : samplesAgg.buckets().array()) {
                    String sampleIdKey = String.valueOf(b.key());
                    Map<String, Integer> geneCountMap = variantGeneCountMap.getOrDefault(sampleIdKey, new HashMap<>());
                    StringTermsAggregate geneAggs = b.aggregations().get("region").sterms();
                    for (StringTermsBucket gb : geneAggs.buckets().array()) {
                        String geneKey = gb.key().stringValue().toLowerCase();
                        geneCountMap.merge(geneKey, (int) gb.docCount(), Integer::sum);
                        geneKeys.add(geneKey);
                    }
                    if (!geneCountMap.isEmpty()) {
                        variantGeneCountMap.put(sampleIdKey, geneCountMap);
                    }
                }
            }

        }  else{
            for (List<String> batch : geneBatches) {
                vsb.setGenes(batch);
                SearchResponse<java.util.Map> sr = getAggregations(vsb, req);
                if (sr == null) continue;

                StringTermsAggregate regionAgg = sr.aggregations().get("regionName").sterms();

                for (StringTermsBucket b : regionAgg.buckets().array()) {
                    String regionKey = b.key().stringValue();
                    geneKeys.add(regionKey);

                    LongTermsAggregate posAggs = b.aggregations().get("startPos").lterms();

                    for (LongTermsBucket pos : posAggs.buckets().array()) {
                        LongTermsAggregate sampleAggs = pos.aggregations().get("sample").lterms();

                        if (sampleAggs.buckets().array().size() < vsb.sampleIds.size()) {
                            for (LongTermsBucket samp : sampleAggs.buckets().array()) {
                                if (samp.docCount() < vsb.sampleIds.size()) {
                                    String sampKey = String.valueOf(samp.key());
                                    Map<String, Integer> geneVarCountsOfSample = variantGeneCountMap.get(sampKey);
                                    if (geneVarCountsOfSample != null) {
                                        Integer varNucCountOfGeneOfSample = geneVarCountsOfSample.get(regionKey.toLowerCase());
                                        if (varNucCountOfGeneOfSample != null) {
                                            varNucCountOfGeneOfSample = varNucCountOfGeneOfSample + (int) samp.docCount();
                                            geneVarCountsOfSample.put(regionKey.toLowerCase(), varNucCountOfGeneOfSample);

                                        } else {
                                            geneVarCountsOfSample.put(regionKey.toLowerCase(), (int) samp.docCount());
                                        }

                                        variantGeneCountMap.put(sampKey, geneVarCountsOfSample);
                                    } else {
                                        geneVarCountsOfSample = new HashMap<>();
                                        geneVarCountsOfSample.put(regionKey.toLowerCase(), (int) samp.docCount());
                                        variantGeneCountMap.put(sampKey, geneVarCountsOfSample);
                                    }

                                }
                            }
                        }

                    }


                }
            }

        }
        // restore full gene list
        vsb.setGenes(allGenes);
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

    public SearchResponse<java.util.Map> getAggregations(VariantSearchBean vsb, HttpRequestFacade req) throws VVException {
        VVService vvService=new VVService(vsb,req);
       return vvService.getAggregations();
    }

    public void setgSymbols(List<String> gSymbols) {
        this.gSymbols = gSymbols;
    }

    public Collection[] split(List<String> symbols, int size) throws Exception {
        int numOfBatches = symbols.size() / size + 1;
        Collection[] batches = new Collection[numOfBatches];

        for(int index = 0; index < numOfBatches; ++index) {
            int count = index + 1;
            int fromIndex = Math.max((count - 1) * size, 0);
            int toIndex = Math.min(count * size, symbols.size());
            batches[index] = symbols.subList(fromIndex, toIndex);
        }

        return batches;
    }

}
