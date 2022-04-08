package edu.mcw.rgd.vv.vvservice;


import edu.mcw.rgd.dao.impl.SequenceDAO;
import edu.mcw.rgd.dao.impl.TranscriptDAO;
import edu.mcw.rgd.dao.impl.VariantInfoDAO;
import edu.mcw.rgd.dao.impl.variants.PolyphenDAO;
import edu.mcw.rgd.dao.impl.variants.VariantTranscriptDao;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.prediction.PolyPhenPrediction;
import edu.mcw.rgd.datamodel.variants.VariantTranscript;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.search.elasticsearch.client.ClientInit;
import edu.mcw.rgd.search.elasticsearch.client.ElasticSearchClient;
import edu.mcw.rgd.vv.VVException;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchScrollRequest;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.common.unit.TimeValue;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.DisMaxQueryBuilder;
import org.elasticsearch.index.query.QueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.script.Script;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.AggregationBuilder;
import org.elasticsearch.search.aggregations.AggregationBuilders;
import org.elasticsearch.search.aggregations.BucketOrder;
import org.elasticsearch.search.builder.SearchSourceBuilder;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by jthota on 7/10/2019.
 */
public class VVService {
    VariantTranscriptDao dao=new VariantTranscriptDao();
    private static String variantIndex;
    // private static String env="cur";

    public static String getVariantIndex() {
        return variantIndex;
    }

    public static void setVariantIndex(String variantIndex) {
        VVService.variantIndex = variantIndex;
    }

    /* public static String getEnv() {
         return env;
     }

     public static void setEnv(String env) {
         VVService.env = env;
     }
 */
    public long getVariantsCount(VariantSearchBean vsb, HttpRequestFacade req) throws IOException {

        BoolQueryBuilder builder=this.boolQueryBuilder(vsb,req);
        SearchSourceBuilder srb=new SearchSourceBuilder();
        srb.query(builder);
        srb.size(0);
        SearchRequest searchRequest=new SearchRequest(variantIndex);
        searchRequest.source(srb);
        //   searchRequest.scroll(TimeValue.timeValueMinutes(1L));

        //     SearchResponse sr= VariantIndexClient.getClient().search(searchRequest, RequestOptions.DEFAULT);
        SearchResponse sr= ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);

        return sr.getHits().getTotalHits().value;

    }

    public List<SearchHit> getVariants(VariantSearchBean vsb, HttpRequestFacade req) throws VVException {




        System.out.println("31");
        BoolQueryBuilder builder=this.boolQueryBuilder(vsb,req);
        System.out.println("32");
        SearchSourceBuilder srb=new SearchSourceBuilder();
        System.out.println("33");
        srb.query(builder);
        System.out.println("34");
        srb.size(10000);
        System.out.println("variant index = " + variantIndex);
        SearchRequest searchRequest=new SearchRequest(variantIndex);
        System.out.println("35");
        searchRequest.source(srb);
        System.out.println("36");
        searchRequest.scroll(TimeValue.timeValueMinutes(1L));

        List<SearchHit> searchHits= new ArrayList<>();
        try {
            if (req.getParameter("showDifferences").equals("true")) {

                System.out.println("37");
                SearchResponse sr = ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
                System.out.println("38");
                String scrollId = sr.getScrollId();
                searchHits.addAll(Arrays.asList(sr.getHits().getHits()));
                System.out.println("39");

                do {
                    System.out.println("40");
                    SearchScrollRequest scrollRequest = new SearchScrollRequest(scrollId);
                    scrollRequest.scroll(TimeValue.timeValueSeconds(60));
                    sr = ClientInit.getClient().scroll(scrollRequest, RequestOptions.DEFAULT);
                    scrollId = sr.getScrollId();
                    searchHits.addAll(Arrays.asList(sr.getHits().getHits()));
                } while (sr.getHits().getHits().length != 0);
                return this.excludeCommonVariants(searchHits, vsb);

            } else {


                SearchResponse sr = ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
                String scrollId = sr.getScrollId();

                System.out.println("41");
                searchHits.addAll(Arrays.asList(sr.getHits().getHits()));

                do {
                    SearchScrollRequest scrollRequest = new SearchScrollRequest(scrollId);
                    System.out.println("sr.get hits = " + sr.getHits().getHits().length);
                    scrollRequest.scroll(TimeValue.timeValueSeconds(60));
                    sr = ClientInit.getClient().scroll(scrollRequest, RequestOptions.DEFAULT);
                    scrollId = sr.getScrollId();
                    searchHits.addAll(Arrays.asList(sr.getHits().getHits()));
                } while (sr.getHits().getHits().length != 0);
                return searchHits;
            }
        }catch (Exception e) {
            e.printStackTrace();
            throw new VVException("Too many buckets. Please limit number of samples/genes");

        }

    }

    public SearchResponse getAggregations(VariantSearchBean vsb, HttpRequestFacade req) throws VVException {
        BoolQueryBuilder builder=this.boolQueryBuilder(vsb,req);
        SearchSourceBuilder srb=new SearchSourceBuilder();
        srb.query(builder);
        if(req.getParameter("showDifferences").equals("true")){
            srb.aggregation(this.buildAggregations("regionName"));
        }else
            srb.aggregation(this.buildAggregations("sampleId"));
        SearchRequest searchRequest=new SearchRequest(variantIndex);
        searchRequest.source(srb);
        try {
            return ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
        } catch (IOException e) {
            throw new VVException("Too many bukckets. Please limit number of samples/genes");

        }

    }
    public List<SearchHit> excludeCommonVariants( List<SearchHit> searchHitList,VariantSearchBean vsb){

        List<SearchHit> nonSharedVariants=new ArrayList<>();
        List<Integer> verifiedPositions=new ArrayList<>();

        for (SearchHit hit : searchHitList) {
            List<SearchHit> tempList = new ArrayList<>();
            String chr = (String) hit.getSourceAsMap().get("chromosome");
            int startPos = (int) hit.getSourceAsMap().get("startPos");
            String varNuc = (String) hit.getSourceAsMap().get("varNuc");

            if (!verifiedPositions.contains(startPos)) {
                verifiedPositions.add(startPos);
                for (SearchHit h : searchHitList) {
                    String chr1 = (String) h.getSourceAsMap().get("chromosome");
                    int startPos1 = (int) h.getSourceAsMap().get("startPos");
                    String varNuc1 = (String) h.getSourceAsMap().get("varNuc");
                    if (chr1!=null && chr1.equals(chr) && startPos1 == startPos && varNuc1!=null  && varNuc1.equals(varNuc)) {
                        tempList.add(h);
                    }
                }
                if (tempList.size() > 0 && tempList.size() < vsb.sampleIds.size()) {
                    nonSharedVariants.addAll(tempList);
                }

            }
        }

        return nonSharedVariants;
    }

    public AggregationBuilder buildAggregations(String fieldName){
        AggregationBuilder aggs= null;
        if(fieldName.equalsIgnoreCase("sampleId")){
            aggs= AggregationBuilders.terms(fieldName).field(fieldName)
                    .size(1000).order(BucketOrder.key(true))
                    .subAggregation(AggregationBuilders.terms("region").field("regionName.keyword")
                            .size(10000));
        }

        if(fieldName.equalsIgnoreCase("regionName")){
            aggs= AggregationBuilders.terms(fieldName).field(fieldName+".keyword")
                    .size(100000)
                    .subAggregation(AggregationBuilders.terms("startPos").field("startPos")
                            .size(100000)
                            .subAggregation(AggregationBuilders.terms("sample").field("sampleId"))
                            .subAggregation(AggregationBuilders.terms("varNuc").field("varNuc.keyword")
                                    .size(100000)).order(BucketOrder.key(true)));
        }

        return aggs;
    }
    public BoolQueryBuilder boolQueryBuilder(VariantSearchBean vsb, HttpRequestFacade req){


        BoolQueryBuilder builder=new BoolQueryBuilder();
        builder.must(this.getDisMaxQuery(vsb, req));
        List<String> synStats= new ArrayList<>();
        List<String> genicStats= new ArrayList<>();
        List<String> vTypes= new ArrayList<>();
        List<String> locs=new ArrayList<>();
        List<String> zygosity=new ArrayList<>();
        List<Integer> alleleCount= new ArrayList<>();
        int depthLowBound=0;
        int depthHighBound=0;
        if(req.getParameter("nonSynonymous").equals("true")){ synStats.add("nonsynonymous");}
        if(req.getParameter("synonymous").equals("true")){synStats.add("synonymous");}
        if(synStats.size()>0){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termsQuery("variantTranscripts.synStatus", synStats.toArray())));
        }
        if(req.getParameter("genic").equals("true")){genicStats.add("GENIC");}
        if(req.getParameter("intergenic").equals("true")){genicStats.add("INTERGENIC");}
        if(genicStats.size()>0){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termsQuery("genicStatus.keyword", genicStats.toArray())));
        }
        if(req.getParameter("snv").equals("true")){ vTypes.add("snv");}
        if(req.getParameter("ins").equals("true")){ vTypes.add("ins");}
        if(req.getParameter("del").equals("true")){ vTypes.add("del");}
        if(vTypes.size()>0){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termsQuery("variantType.keyword", vTypes.toArray())));
        }
        if(req.getParameter("intron").equals("true")){locs.add("INTRON");}
        if(req.getParameter("3prime").equals("true")){locs.add("3UTRS"); }
        if(req.getParameter("5prime").equals("true")){locs.add("5UTRS"); }
        if(locs.size()>0){
            BoolQueryBuilder qb=new BoolQueryBuilder();
            for(String l:locs){
                qb.should(QueryBuilders.matchQuery("variantTranscripts.locationName", l));
            }
            builder.filter(qb);
        }
        if(req.getParameter("nearSpliceSite").equals("true")){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("variantTranscripts.nearSpliceSite.keyword", "T")));
        }
        if(req.getParameter("proteinCoding").equals("true")){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.existsQuery("variantTranscripts.refAA.keyword")));
        }
        if(req.getParameter("frameshift").equals("true")){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("variantTranscripts.frameShift.keyword","T")));

        }
        List<String> pPredictions=new ArrayList<>();
        if(req.getParameter("benign").equals("true")){pPredictions.add("benign");}
        if(req.getParameter("possibly").equals("true")){pPredictions.add("possibly damaging");}
        if(req.getParameter("probably").equals("true")){pPredictions.add("probably damaging");}
        if(pPredictions.size()>0){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termsQuery("variantTranscripts.polyphenStatus.keyword", pPredictions.toArray())));
        }

        List<String> clinicalSignificance=new ArrayList<>();
        if(req.getParameter("cs_pathogenic").equals("true")){clinicalSignificance.add("pathogenic");
            clinicalSignificance.add("pathogenic|likely pathogenic");}
        if(req.getParameter("cs_benign").equals("true")){clinicalSignificance.add("benign");
            clinicalSignificance.add("likely benign");}
        if(req.getParameter("cs_other").equals("true")){clinicalSignificance.add("uncertain significance");}
        if(clinicalSignificance.size()>0){
            builder.filter(QueryBuilders.boolQuery().must(QueryBuilders.termsQuery("clinicalSignificance.keyword", clinicalSignificance.toArray())));
        }

        /***************************zygosity************************************/
        if(req.getParameter("het").equals("true")){
            zygosity.add("heterozygous");
        }
        if(req.getParameter("hom").equals("true")){
            zygosity.add("homozygous");
        }
        if(req.getParameter("possiblyHom").equals("true")){
            zygosity.add("possibly homozygous");
        }
        if(zygosity.size()>0){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termsQuery("zygosityStatus.keyword", zygosity.toArray())));
        }
        /**********************alleleCount********************************/
        if(req.getParameter("alleleCount1").equals("true"))
            alleleCount.add(1);
        if(req.getParameter("alleleCount2").equals("true"))
            alleleCount.add(2);
        if(req.getParameter("alleleCount3").equals("true"))
            alleleCount.add(3);
        if(req.getParameter("alleleCount4").equals("true"))
            alleleCount.add(4);
        if(alleleCount.size()>0){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termsQuery("zygosityNumAllele", alleleCount.toArray())));

        }
        /********exclude possible error not working because new table structure doesn't have this data in the DB******/
        if(req.getParameter("excludePossibleError").equals("true")){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("zygosityPossError.keyword","N")));
        }
        if(req.getParameter("hetDiffFromRef").equals("true")){
            builder.filter(QueryBuilders.boolQuery().filter(QueryBuilders.termQuery("zygosityRefAllele.keyword","N")));
        }
        /**************************************LIMIT TO**********************************************/

        if(req.getParameter("prematureStopCodon").equals("true")){
            builder
                    .filter(QueryBuilders.boolQuery().must(QueryBuilders.scriptQuery(new Script("doc['variantTranscripts.refAA.keyword'].value != doc['variantTranscripts.varAA.keyword'].value")))
                            .filter(QueryBuilders.termQuery("variantTranscripts.varAA.keyword", "*"))
                    );
        }

        if(req.getParameter("readthroughMutation").equals("true")){
            builder
                    .filter(QueryBuilders.boolQuery().must(QueryBuilders.scriptQuery(new Script("doc['variantTranscripts.refAA.keyword'].value != doc['variantTranscripts.varAA.keyword'].value")))
                            .filter(QueryBuilders.termQuery("variantTranscripts.refAA.keyword", "*"))
                    );
        }
        /***********************readDepth****************************************/
        if(!req.getParameter("depthLowBound").equals(""))
            depthLowBound=Integer.parseInt(req.getParameter("depthLowBound"));
        if(!req.getParameter("depthHighBound").equals(""))
            depthHighBound=Integer.parseInt( req.getParameter("depthHighBound"));
        if((depthLowBound>0 && depthHighBound>0) || (depthLowBound==0 && depthHighBound>0 )) {
            builder.filter(QueryBuilders.rangeQuery("totalDepth").from(depthLowBound).to(depthHighBound).includeLower(true).includeUpper(true));

        }else if(depthLowBound>0){
            builder.filter(QueryBuilders.rangeQuery("totalDepth").from(depthLowBound).includeLower(true));

        }
        if((vsb.getMinConservation()==0.0F) && (vsb.getMaxConservation()==0.0F)){
            builder.filter(QueryBuilders.termQuery("conScores", 0));
        }else{
            if(vsb.getMinConservation()>0 && vsb.getMaxConservation()>0)
                builder.filter(QueryBuilders.rangeQuery("conScores").from(vsb.getMinConservation())
                        .to(vsb.getMaxConservation()).includeLower(true).includeUpper(true));
        }
        return builder;
    }
    public QueryBuilder getDisMaxQuery(VariantSearchBean vsb, HttpRequestFacade req){

        DisMaxQueryBuilder dqb=new DisMaxQueryBuilder();
        List<Integer> sampleIds=vsb.getSampleIds();
        String chromosome=vsb.getChromosome();
        String geneList=new String();
        try {
            geneList = java.net.URLDecoder.decode(req.getParameter("geneList"), "UTF-8");
            System.out.println("gene list = " + geneList);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        List<String> symbols= new ArrayList<>();

        System.out.println("contains = " + geneList.contains("|"));

        for (String g1: vsb.genes) {
            System.out.println("genes before = " + g1);
        }

        if (geneList != null) {
            if (vsb.genes == null || vsb.genes.size() == 0) {
                vsb.genes = Utils.symbolSplit(geneList);
            }
        }

        for (String g1: vsb.genes) {
            System.out.println("gene = " + g1);
        }

        if((chromosome==null || chromosome.equals("")) && !geneList.equals("") && !geneList.contains("|")){
           System.out.println("51");
            //System.out.println("CHRMoosme null");
            for(String s:vsb.genes){
                symbols.add(s.toLowerCase());
            }

            if(!symbols.get(0).equals("null"))
                dqb.add(QueryBuilders.boolQuery().must(QueryBuilders.termsQuery("regionNameLc.keyword", symbols.toArray()))
                        .filter(QueryBuilders.termsQuery("sampleId", vsb.getSampleIds())));

        }else {
            System.out.println("52");
            if(chromosome!=null && !chromosome.equals("") ){
                System.out.println("53");
                //System.out.println("CHROMOSOME NOT NULL");
                BoolQueryBuilder qb= QueryBuilders.boolQuery().must(
                        QueryBuilders.termQuery("chromosome.keyword", chromosome)
                );
                //     System.out.println("SAMPLE IDS SIZE: "+sampleIds.size());
                if ( sampleIds.size() > 0) {

                    qb.filter(QueryBuilders.termsQuery("sampleId", sampleIds.toArray()));
                }
                if (vsb.getStartPosition() != null && vsb.getStartPosition() >= 0 && vsb.getStopPosition() != null && vsb.getStopPosition() > 0
                        && req.getParameter("geneList").equals("")) {
                    //    qb.filter(QueryBuilders.rangeQuery("startPos").from(vsb.getStartPosition()).to(vsb.getStopPosition()).includeLower(true).includeUpper(true));
                    qb.filter(QueryBuilders.rangeQuery("startPos").gte(vsb.getStartPosition()).lt(vsb.getStopPosition()).includeLower(true).includeUpper(true));
                    qb.filter(QueryBuilders.rangeQuery("endPos").gt(vsb.getStartPosition()).lte(vsb.getStopPosition()).includeLower(true).includeUpper(true));

                }
                //   if (!req.getParameter("geneList").equals("") && !req.getParameter("geneList").contains("|")) {
                if (vsb.genes!=null && vsb.genes.size()>0 && !req.getParameter("geneList").contains("|")) {
                    for (String s : vsb.genes){

                        symbols.add(s.toLowerCase());
                    }
              /* for (String s : Utils.symbolSplit(geneList)) {

                  symbols.add(s.toLowerCase());
                }
                */
                    if (!symbols.get(0).equals("null"))
                        qb.filter(QueryBuilders.termsQuery("regionNameLc.keyword", symbols.toArray()));

                }

                dqb.add(qb);
            }else{

                System.out.println("54");
                if(vsb.getVariantId()!=0 && vsb.getSampleIds().size()>0 ){
                    BoolQueryBuilder qb= QueryBuilders.boolQuery().must(
                            QueryBuilders.termQuery("variant_id", vsb.getVariantId())
                    );
                    qb.filter(QueryBuilders.termsQuery("sampleId", sampleIds.toArray()));
                    dqb.add(qb);
                }
            }
        }
        return dqb;

    }
    public List<VariantResult> getVariantResults(VariantSearchBean vsb, HttpRequestFacade req, boolean requiredTranscripts) throws Exception {
        VVService service= new VVService();
        List<SearchHit> hits=service.getVariants(vsb,req);
        List<VariantResult> variantResults=new ArrayList<>();
        for (SearchHit h : hits) {
            java.util.Map<String, Object> m = h.getSourceAsMap();
            VariantResult vr = new VariantResult();

            Variant v = new Variant();
            v.setId((Integer) m.get("variant_id"));
            v.setChromosome((String) m.get("chromosome"));
            v.setStartPos((int) m.get("startPos"));
            v.setEndPos((int) m.get("endPos"));
            v.setReferenceNucleotide((String) m.get("refNuc"));
            v.setVariantNucleotide((String) m.get("varNuc"));
            v.setGenicStatus((String) m.get("genicStatus"));
            v.setPaddingBase((String) m.get("paddingBase"));
            v.setRegionName(m.get("regionName").toString());
            v.setVariantType((String) m.get("variantType"));
            v.setSampleId((int) m.get("sampleId"));
            v.setVariantFrequency((int) m.get("varFreq"));
            v.setDepth((Integer) m.get("totalDepth"));
            if(m.get("qualityScore")!=null)
                v.setQualityScore((int) m.get("qualityScore"));
            v.setZygosityStatus((String) m.get("zygosityStatus"));
            v.setZygosityInPseudo((String) m.get("zygosityInPseudo"));
            v.setZygosityNumberAllele((Integer) m.get("zygosityNumAllele"));
            double p= (double) m.get("zygosityPercentRead");
            v.setZygosityPercentRead((int) p);
            v.setZygosityPossibleError((String) m.get("zygosityPossError"));
            v.setZygosityRefAllele((String) m.get("zygosityRefAllele"));
            v.conservationScore.add(mapConservation(m));
            vr.setVariant(v);
            if(requiredTranscripts) {
                List<TranscriptResult> trs = this.getVariantTranscriptResults((Integer) m.get("variant_id"), vsb.getMapKey());
                vr.setTranscriptResults(trs);
            }

            if(vsb.getMapKey()==38){
                VariantInfo clinvar=getClinvarInfo(v.getId());
                vr.setClinvarInfo(clinvar);
            }
            variantResults.add(vr);

        }

        return variantResults;
    }
    List<TranscriptResult> getVariantTranscriptResults(int variantId, int mapKey) throws IOException {
        List<TranscriptResult> trs=new ArrayList<>();
        List<VariantTranscript> transcripts=new ArrayList<>();
        try {
            transcripts= dao.getVariantTranscripts(variantId,mapKey);
        } catch (Exception e) {
            e.printStackTrace();
        }
        try {
            for(VariantTranscript t:transcripts ){

                TranscriptResult tr = new TranscriptResult();
                AminoAcidVariant aa = new AminoAcidVariant();
                aa.setTripletError(t.getTripletError());
                aa.setSynonymousFlag(t.getSynStatus());
                aa.setPolyPhenStatus(t.getPolyphenStatus());
                aa.setNearSpliceSite(t.getNearSpliceSite());

                // tr.set.setFrameShift((String) source.get("frameShift"));
                tr.setTranscriptId(String.valueOf(t.getTranscriptRgdId()));
                aa.setLocation(t.getLocationName());
                aa.setReferenceAminoAcid(t.getRefAA());
                aa.setVariantAminoAcid(t.getVarAA());
           /*  if (source.get("fullRefAA") != null)
                 aa.setAASequence(source.get("fullRefAA").toString());
             if (source.get("fullRefNuc") != null)
                 aa.setDNASequence(source.get("fullRefNuc").toString());*/
                if (t.getFullRefAASeqKey() != 0) {
                    aa.setAASequence(getSequence(t.getFullRefAASeqKey()));
                }
                if (t.getFullRefNucSeqKey() != 0) {
                    aa.setDNASequence(getSequence(t.getFullRefNucSeqKey()));
                }
                if (t.getFullRefAAPos() != null) {
                    //    System.out.println("FULL REF AA PSOTION:" + t.getFullRefAAPos());
                    aa.setAaPosition(t.getFullRefAAPos());
                }
                if (t.getFullRefNucPos() != null) {
                    //    System.out.println("FULL REF AA PSOTION:" + t.getFullRefNucPos());
                    aa.setDnaPosition(t.getFullRefNucPos());
                }
                String trSymbol = getTranscriptSymbol(tr.getTranscriptId());
                if (trSymbol != null)
                    aa.setTranscriptSymbol(trSymbol);
                tr.setAminoAcidVariant(aa);
                //********************************************Polyphenprediction********//
                List<PolyPhenPrediction> polyPhenPredictions = getPolphenPredictionByVariantId(variantId,t.getTranscriptRgdId());
                if (polyPhenPredictions != null && polyPhenPredictions.size() > 0)
                    tr.setPolyPhenPrediction(polyPhenPredictions);
                trs.add(tr);
            }

        } catch (Exception exception) {
            exception.printStackTrace();
        }
        return  trs;
    }
    public List<PolyPhenPrediction> getPolphenPredictionByVariantId(int variantId, int transcriptId)
    {
        PolyphenDAO pdao=new PolyphenDAO();

        try {
            //   return pdao.getPloyphenDataByVariantId(86880133);
            return pdao.getPloyphenDataByVariantId(variantId, transcriptId);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    public String getSequence(int seqKey){
        SequenceDAO sequenceDAO=new SequenceDAO();
        List<Sequence>  sequences=new ArrayList<>();
        try {
            sequences= sequenceDAO.getObjectSequencesBySeqKey(seqKey);
        } catch (Exception e) {
            e.printStackTrace();
        }
        if(sequences!=null){
            return sequences.get(0).getSeqData();
        }
        return null;
    }
    public String getTranscriptSymbol(String transcriptId){
        TranscriptDAO tdao=new TranscriptDAO();
        Transcript tr= null;
        try {
            tr = tdao.getTranscript(Integer.parseInt(transcriptId));
        } catch (Exception e) {
            e.printStackTrace();
        }
        if(tr!=null)
            return tr.getAccId();
        return null;
    }
    VariantInfo getClinvarInfo(long variantRGDId) throws Exception {

        VariantInfoDAO dao= new VariantInfoDAO();
        return dao.getVariant((int) variantRGDId);

    }
    public ConservationScore mapConservation(java.util.Map m)  {
        List conScores= (List) m.get("conScores");
//        System.out.println(conScores.toString());
        ConservationScore  cs = new ConservationScore();

        try{
            if(conScores!=null && conScores.size()>=1 ) {
                if(conScores.get(0) instanceof Integer){
                    BigDecimal score=  BigDecimal.valueOf((Integer) conScores.get(0));
                    cs.setScore(score);
                    cs.setChromosome((String) m.get("chromosome"));
                    cs.setPosition((Integer) m.get("startPos"));
                    cs.setNuc((String) m.get("refNuc"));
                }else{
                    if(conScores.get(0) instanceof Double){
                        BigDecimal score= BigDecimal.valueOf((Double) conScores.get(0));
                        cs.setScore(score);
                        cs.setChromosome((String) m.get("chromosome"));
                        cs.setPosition((Integer) m.get("startPos"));
                        cs.setNuc((String) m.get("refNuc"));
                    }else{
                        if(conScores.get(0) instanceof BigDecimal){
                            BigDecimal score= (BigDecimal) conScores.get(0);
                            cs.setScore(score);
                            cs.setChromosome((String) m.get("chromosome"));
                            cs.setPosition((Integer) m.get("startPos"));
                            cs.setNuc((String) m.get("refNuc"));
                        }else{
                            if(conScores.get(0) instanceof String){
                                cs.setScore(BigDecimal.valueOf(Double.parseDouble((String) conScores.get(0))));
                                cs.setChromosome((String) m.get("chromosome"));
                                cs.setPosition((Integer) m.get("startPos"));
                                cs.setNuc((String) m.get("refNuc"));
                            }

                        }
                    }
                }
            }else{

                cs.setScore(BigDecimal.valueOf(-1));
                cs.setChromosome((String) m.get("chromosome"));
                cs.setPosition((Integer) m.get("startPos"));
                cs.setNuc((String) m.get("refNuc"));

            }
        }catch (Exception e){
            System.out.println("CONSCORE:"+conScores.get(0));
            e.printStackTrace();
        }

        return cs;



    }
}
