package edu.mcw.rgd.vv;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.dao.impl.SSLPDAO;
import edu.mcw.rgd.dao.impl.SampleDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.Map;
import edu.mcw.rgd.datamodel.search.Position;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.web.servlet.mvc.Controller;

import java.net.URLDecoder;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 10/23/12
 * Time: 4:13 PM
 */
public abstract class HaplotyperController implements Controller {

    // class logger
    Log log = LogFactory.getLog(HaplotyperController.class);

    /**
     * Figures out the position information based on a gene symbol or region
     *
     * @param geneSymbol
     * @param geneStart
     * @param geneStop
     * @return
     * @throws Exception
     */
    protected Position getPosition(String geneSymbol, String geneStart, String geneStop, int mapKey) throws Exception {

        MapDAO mdao = new MapDAO();
        GeneDAO gdao = new GeneDAO();

        Position p = new Position();
        int speciesTypeKey=mdao.getSpeciesTypeKeyForMap(mapKey);
        if (!geneSymbol.equals("")) {
            if (geneSymbol.indexOf('|') != -1) {
                String[] genes = geneSymbol.split("\\|");

                Gene g1 = gdao.getGenesBySymbol(genes[0],speciesTypeKey);
                Gene g2 = gdao.getGenesBySymbol(genes[1], speciesTypeKey);

                List<MapData> mdList1 = mdao.getMapData(g1.getRgdId(), mapKey);
                List<MapData> mdList2 = mdao.getMapData(g2.getRgdId(), mapKey);

                MapData md1 = mdList1.get(0);
                MapData md2 = mdList2.get(0);

                p.setChromosome(md1.getChromosome());
                p.setStart(md1.getStopPos() + 1);
                p.setStop(md2.getStartPos() - 1);
            } else if (geneSymbol.indexOf('*') != -1) {
                String[] genes = geneSymbol.split("\\*");

                Gene g1 = gdao.getGenesBySymbol(genes[0], speciesTypeKey);
                Gene g2 = gdao.getGenesBySymbol(genes[1], speciesTypeKey);

                List<MapData> mdList1 = mdao.getMapData(g1.getRgdId(), mapKey);
                List<MapData> mdList2 = mdao.getMapData(g2.getRgdId(), mapKey);

                MapData md1 = mdList1.get(0);
                MapData md2 = mdList2.get(0);

                p.setChromosome(md1.getChromosome());

                int start = 0;
                int stop = 0;

                if (md1.getStartPos() > md2.getStartPos()) {
                    start = md1.getStartPos();
                } else {
                    start = md2.getStartPos();
                }

                if (md1.getStopPos() > md2.getStopPos()) {
                    stop = md2.getStopPos();
                } else {
                    stop = md1.getStopPos();
                }

                p.setStart(start);
                p.setStop(stop);

            } else if (Utils.symbolSplit(geneSymbol).size() == 1) {

                Map m = MapManager.getInstance().getMap(mapKey);
                Gene gene;
                try {
                    int rgdId = Integer.parseInt(geneSymbol);
                    gene = gdao.getGene(rgdId);
                }
                catch (Exception e){
                    gene = gdao.getGenesBySymbol(geneSymbol, m.getSpeciesTypeKey());
                }

                if (gene == null) {
                    throw new VVException("Gene not found for symbol " + geneSymbol);
                }

                List<MapData> mdList = mdao.getMapData(gene.getRgdId(), mapKey);
                if (mdList.isEmpty()) {
                    throw new VVException("Position not found for gene " + geneSymbol + ", map_key=" + mapKey);
                }

                MapData md = mdList.get(0);

                p.setChromosome(md.getChromosome());
                p.setStart(md.getStartPos());
                p.setStop(md.getStopPos());
            }

        } else if (!geneStart.equals("") && !geneStop.equals("")) {

            int rgdIdStart = 0;
            int rgdIdStop = 0;


            List geneList = new ArrayList();
            geneList.add(geneStart);

            ObjectMapper om = new ObjectMapper();
            om.mapSymbols(geneList, speciesTypeKey);

            List mapped = om.getMapped();

            //we may have an sslp
            //if (mapped.size() == 0) {
            if (mapped.get(0) instanceof String) {
                SSLPDAO sdao = new SSLPDAO();
                List sList = sdao.getActiveSSLPsByName(geneStart, speciesTypeKey);

                if (sList.size() > 0) {
                    SSLP ss = (SSLP) sList.get(0);
                    rgdIdStart = ss.getRgdId();
                } else {
                    throw new VVException("Symbol 1 not found");
                }

            } else if (mapped.get(0) instanceof Gene) {
                Gene g = (Gene) mapped.get(0);
                rgdIdStart = g.getRgdId();
            } else {
                throw new VVException("Symbol 1 not found");
            }


            geneList = new ArrayList();
            geneList.add(geneStop);

            om = new ObjectMapper();
            om.mapSymbols(geneList, 3);

            mapped = om.getMapped();


            //we may have an sslp
            if (mapped.get(0) instanceof String) {
                SSLPDAO sdao = new SSLPDAO();
                List sList = sdao.getActiveSSLPsByName(geneStop, speciesTypeKey);

                if (sList.size() > 0) {
                    SSLP ss = (SSLP) sList.get(0);
                    rgdIdStop = ss.getRgdId();
                } else {
                    throw new VVException("Symbol 2 not found");
                }

            } else if (mapped.get(0) instanceof Gene) {
                Gene g = (Gene) mapped.get(0);
                rgdIdStop = g.getRgdId();
            } else {
                throw new VVException("Symbol 2 not found");
            }
            //System.out.println("he8e");

            List<MapData> mdList1 = mdao.getMapData(rgdIdStart, mapKey);
            List<MapData> mdList2 = mdao.getMapData(rgdIdStop, mapKey);

            if (mdList1.size() == 0) {
                throw new VVException("Symbol 1 not found");
            }
            if (mdList2.size() == 0) {
                throw new VVException("Symbol 2 not found");
            }

            MapData md1 = mdList1.get(0);
            MapData md2 = mdList2.get(0);

            if (!md1.getChromosome().equals(md2.getChromosome())) {
                throw new VVException("Symbol 1 and Symbol 2 must be on the same chromosome.");
            }

            p.setChromosome(md1.getChromosome());
            p.setStart(md1.getStartPos());
            p.setStop(md2.getStopPos());

        }

        return p;

    }

    /**
     * initializes a VariantSearchBean based on data supplied in the HTTP Request object
     *
     * @param req
     * @return
     * @throws Exception
     */
    protected VariantSearchBean fillBean(HttpRequestFacade req) throws Exception {

        VariantSearchBean vsb = new VariantSearchBean(0);

        if (req.getParameter("sample1").equals("all")) {
            //get all the samples

            SampleDAO sdao = new SampleDAO();
            sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());

            int mapKey = 372;
            try {
               mapKey= Integer.parseInt(req.getParameter("mapKey"));
            }catch (Exception e){throw new VVException("INVALIED MAPKEY:"+ req.getParameter("mapKey"));}
            if(mapKey>0) {
                List<Sample> samples = sdao.getSamplesByMapKey(mapKey);
                vsb.setMapKey(mapKey);
                for (Sample s : samples) {
                    vsb.sampleIds.add(s.getId());
                }
            }
        } else {
            ArrayList<Integer> al = new ArrayList<Integer>();
            for (int i = 0; i < 999; i++) {
                String sample = req.getParameter("sample" + i);
                if (!sample.isEmpty()) {
                    int sampleId=0;
                    try {
                       sampleId= Integer.parseInt(sample);
                    }catch (Exception e){
                        throw new VVException("Invalid Sample Id:"+ sample);
                    }
                    if(sampleId>0)
                    al.add(sampleId);
                }
            }

            if (al.size() > 0) {
                SampleDAO sdao = new SampleDAO();
                sdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
                List<Sample> samples = sdao.getSampleBySampleId(al);

                // System.out.println("samples.len = " + samples.size());
                // determine mapKey from samples
                int cnt = 0;
                for (Sample sampleObj: samples)  {
                    cnt++;

                    // if bean map key not set, derive it from sample
                    if (vsb.getMapKey() == 0) {
                        vsb.setMapKey(sampleObj.getMapKey());
                        vsb.sampleIds.add(sampleObj.getId());
                    } else {
                        // bean map key already set -- validate it
                        if (sampleObj.getMapKey() == vsb.getMapKey()) {
                            vsb.sampleIds.add(sampleObj.getId());
                        } else {
                            // assembly mixup, ignore the sample
                            System.out.println("ERROR: assembly mixup");
                        }
                    }

                }
            }

            // determine mapKey from samples
        /*    for (int i = 0; i < 100; i++) {
                String sample = req.getParameter("sample" + i);
                if (!sample.isEmpty()) {
                    int sampleId = Integer.parseInt(sample);
                    Sample sampleObj = SampleManager.getInstance().getSampleName(sampleId);

                    // if bean map key not set, derive it from sample
                    if (vsb.getMapKey() == 0) {
                        vsb.setMapKey(sampleObj.getMapKey());
                        vsb.sampleIds.add(sampleId);
                    } else {
                        // bean map key already set -- validate it
                        if (sampleObj.getMapKey() == vsb.getMapKey()) {
                            vsb.sampleIds.add(sampleId);
                        } else {
                            // assembly mixup, ignore the sample
                            System.out.println("ERROR: assembly mixup");
                        }
                    }
                }
            }*/

        }
        // if map key was not explicitly given, set the map key to value determined from sample ids
        int mapKey = vsb.getMapKey();
        if (vsb.getMapKey() == 0) {
            String mapKeyString = req.getParameter("mapKey");
            if (!mapKeyString.isEmpty()) {
                mapKey = Integer.parseInt(mapKeyString);
            }
            // if map key still not determined, set it to map key of primary reference assembly
            if (mapKey == 0) {
                mapKey = MapManager.getInstance().getReferenceAssembly(SpeciesType.RAT).getKey();
                //    mapKey=372;
            }
            vsb.setMapKey(mapKey);
        }


        String chromosome = req.getParameter("chr");
        String start = URLDecoder.decode(req.getParameter("start"), "UTF-8").replaceAll(",", "");
        String stop = URLDecoder.decode(req.getParameter("stop"), "UTF-8").replaceAll(",", "");

        if (chromosome.equals("") || start.equals("") || stop.equals("")) {

            Position p = this.getPosition(req.getParameter("geneList"), req.getParameter("geneStart"), req.getParameter("geneStop"), mapKey);
            chromosome = p.getChromosome();
            start = p.getStart() + "";
            stop = p.getStop() + "";

        } else {
            try {
                Integer.parseInt(start);
            } catch (Exception e) {
                throw new VVException("Start value must be numeric");
            }

            try {
                Integer.parseInt(stop);
            } catch (Exception e) {
                throw new VVException("Stop value must be numeric");
            }
        }

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

        vsb.setPosition(chromosome, start, stop);
        vsb.setAAChange(req.getParameter("synonymous"), req.getParameter("nonSynonymous"));
        vsb.setGenicStatus(req.getParameter("genic"), req.getParameter("intergenic"));
        vsb.setIsPrematureStop(req.getParameter("prematureStopCodon"));
        vsb.setShowDifferences(Boolean.parseBoolean(req.getParameter("showDifferences")));
        vsb.setIsReadthrough(req.getParameter("readthroughMutation"));
        vsb.setConScore(conLow, conHigh);
        vsb.setDepth(req.getParameter("depthLowBound"), req.getParameter("depthHighBound"));
        vsb.setNearSpliceSite(req.getParameter("nearSpliceSite"));
        vsb.setZygosity(req.getParameter("het"), req.getParameter("hom"), req.getParameter("possiblyHom"), req.getParameter("hemi"), req.getParameter("probablyHemi"), req.getParameter("possiblyHemi"), req.getParameter("excludePossibleError"), req.getParameter("hetDiffFromRef"));
        vsb.setScore(req.getParameter("scoreLowBound"), req.getParameter("scoreHighBound"));
        vsb.setDBSNPNovel(req.getParameter("notDBSNP"), req.getParameter("foundDBSNP"));
        vsb.setLocation(req.getParameter("intron"), req.getParameter("3prime"), req.getParameter("5prime"), req.getParameter("proteinCoding"));
        vsb.setPseudoautosomal(req.getParameter("excludePsudoautosomal"), req.getParameter("onlyPsudoautosomal"));
        vsb.setAlleleCount(req.getParameter("alleleCount1"), req.getParameter("alleleCount2"), req.getParameter("alleleCount3"), req.getParameter("alleleCount4"));
        vsb.setVariantType(req.getParameter("snv"), req.getParameter("ins"), req.getParameter("del"));
        vsb.setIsFrameshift(req.getParameter("frameshift"));
        vsb.setPolyphen(req.getParameter("benign"), req.getParameter("possibly"), req.getParameter("probably"));
        vsb.setClinicalSignificance(req.getParameter("cs_pathogenic"), req.getParameter("cs_benign"), req.getParameter("cs_other"));
        return vsb;
    }
    public void mapGeneSymbols(String geneList, VariantSearchBean vsb) throws Exception {
        GeneDAO gdao=new GeneDAO();
        List<String> symbols=null;
        int speciesTypeKey=SpeciesType.getSpeciesTypeKeyForMap(vsb.getMapKey());
        if(!geneList.contains("|")) {
            symbols= Utils.symbolSplit(geneList).stream().map(String::toLowerCase).collect(Collectors.toList());
        } else
            symbols= Collections.singletonList(geneList.toLowerCase());
        List<String> symbolsWithoutMutants= symbols.stream().filter(s->!s.contains("<")).collect(Collectors.toList());
        edu.mcw.rgd.process.mapping.ObjectMapper om = new edu.mcw.rgd.process.mapping.ObjectMapper();
        om.mapSymbols(symbolsWithoutMutants, speciesTypeKey);
        List result= om.getMapped();
        List<Gene> genes = new ArrayList<Gene>();

        Iterator it = result.iterator();
        while (it.hasNext()) {
            Object o = it.next();
            if (o instanceof Gene gene) {
                if(gene.getSymbol().contains("'")){
                    gene.setSymbol(gene.getSymbol().replace("'", "''"));
                }
                genes.add((Gene) o);
            }
        }
        List<MappedGene> mgs = new ArrayList<MappedGene>();
        mgs = gdao.getActiveMappedGenesByGeneList(vsb.getMapKey(),genes);
        List<String> geneSymbols=new ArrayList<>();
        for(MappedGene gene:mgs){
            geneSymbols.add(gene.getGene().getSymbol());
        }
        vsb.setGenes(geneSymbols);
    }
}
