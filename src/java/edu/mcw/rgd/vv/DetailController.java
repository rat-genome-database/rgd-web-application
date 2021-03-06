package edu.mcw.rgd.vv;

import edu.mcw.rgd.dao.impl.variants.VariantDAO;
import edu.mcw.rgd.search.elasticsearch.client.ClientInit;
import edu.mcw.rgd.vv.vvservice.VVService;
import edu.mcw.rgd.vv.vvservice.VariantIndexClient;
import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.TranscriptDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: 9/25/12
 * Time: 9:49 AM
 */
public class DetailController extends HaplotyperController {
    VariantController ctrl=new VariantController();
    VariantDAO vdao= new VariantDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

         try {
             return handle(request);
         }catch (Exception e) {
            // do not print stack trace for Exceptions that are 'expected' by us
            if( !(e instanceof VVException) ) {
                e.printStackTrace();
            }

            request.setAttribute("error",e.getMessage());
            return new ModelAndView("/WEB-INF/jsp/vv/region.jsp");
        }
    }

    ModelAndView handle(HttpServletRequest request) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        String vid = req.getParameter("vid");
        String sid = req.getParameter("sid");

        int mapKey = 360; // map key defaults to rat assembly 6.0
        String mapKeyStr = request.getParameter("mapKey");
        if( mapKeyStr!=null && !mapKeyStr.isEmpty() )
            mapKey = Integer.parseInt(mapKeyStr);
        else
        if(vid!=null && !vid.isEmpty() && !vid.equals("0") && !vid.contains("|")){
            mapKey=vdao.getMapKeyByVariantId(Integer.parseInt(vid));
        }

        String index = new String();
        String species = SpeciesType.getCommonName(SpeciesType.getSpeciesTypeKeyForMap(mapKey));
        index = RgdContext.getESVariantIndexName("variants_" + species.toLowerCase() + mapKey);
        VVService.setVariantIndex(index);

        List<SearchResult> allResults = new ArrayList<SearchResult>();

        VariantSearchBean vsb = new VariantSearchBean(mapKey);
        if (!sid.isEmpty())
            vsb.sampleIds.add(Integer.parseInt(sid));
        if(req.getParameter("chr")!=null &&
                req.getParameter("start")!=null &&
                req.getParameter("stop") !=null &&
        !req.getParameter("chr").equals("") &&
               ! req.getParameter("start").equals("") &&
                req.getParameter("stop") .equals("")){

            vsb.setPosition(req.getParameter("chr"), req.getParameter("start"), req.getParameter("stop"));

            List<VariantResult> vr = ctrl.getVariantResults(vsb, req, true);
            SearchResult sr = new SearchResult();

            sr.setVariantResults(vr);
            allResults.add(sr);
            request.setAttribute("searchResults", allResults);
            return new ModelAndView("/WEB-INF/jsp/vv/detail.jsp", "searchResult", sr);


       }else{
             if(vid !=null && !vid.isEmpty() && !vid.equals("0")) {

                 String[] vids = vid.split("\\|");
                 for (int i = 0; i < vids.length; i++) {
                     SearchResult sr = new SearchResult();

                     vsb.setVariantId(Long.parseLong(vids[i]));
                     List<VariantResult> vr = ctrl.getVariantResults(vsb, req, true);
                     sr.setVariantResults(vr);
                     allResults.add(sr);
                 }}
            request.setAttribute("searchResults", allResults);
            return new ModelAndView("/WEB-INF/jsp/vv/detail.jsp");

       }
    }


    //   public List<TranscriptResult> getTranscriptResults(String chr, long startPos,long endPos, String refNuc, String varNuc) throws IOException {
        public List<TranscriptResult> getTranscriptResults(Variant v, int mapKey) throws IOException {
        int speciesTypeKey=SpeciesType.getSpeciesTypeKeyForMap(mapKey);
            List<TranscriptResult> tds = new ArrayList<>();

            SearchSourceBuilder srb = new SearchSourceBuilder();
            // srb.query(QueryBuilders.termQuery("startPos", startPos));

            srb.query(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("chromosome", v.getChromosome()))
                            .filter(QueryBuilders.termQuery("startPos", v.getStartPos()))
                    //  .filter(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("refNuc", refNuc)).must(QueryBuilders.termQuery("varNuc", varNuc)))

            );
            srb.size(10000);
            SearchRequest request = new SearchRequest("transcripts_human_dev");

            request.source(srb);

            SearchResponse sr = ClientInit.getClient().search(request, RequestOptions.DEFAULT);


            if (sr.getHits().getTotalHits().value > 0) {
                for (SearchHit h : sr.getHits().getHits()) {
                    TranscriptResult tr = new TranscriptResult();
                    AminoAcidVariant aa = new AminoAcidVariant();
                    java.util.Map source = h.getSourceAsMap();

                    aa.setTripletError((String) source.get("tripletError"));
                    aa.setSynonymousFlag((String) source.get("synStatus"));
                    aa.setPolyPhenStatus((String) source.get("polyphenStatus"));
                    aa.setNearSpliceSite((String) source.get("nearSpliceSite"));
                    aa.setGeneSpliceStatus((String) source.get("genespliceStatus"));
                    // tr.set.setFrameShift((String) source.get("frameShift"));
                    tr.setTranscriptId(source.get("transcriptRgdId").toString());
                    aa.setLocation((String) source.get("locationName"));
                    aa.setReferenceAminoAcid((String) source.get("refAA"));
                    aa.setVariantAminoAcid((String) source.get("varAA"));
                    if (source.get("fullRefAA") != null)
                        aa.setAASequence(source.get("fullRefAA").toString());
                    if (source.get("fullRefNuc") != null)
                        aa.setDNASequence(source.get("fullRefNuc").toString());
                    if (source.get("fullRefAAPos") != null)
                        aa.setAaPosition((Integer) source.get("fullRefAAPos"));
                    if (source.get("fullRefNucPos") != null)
                        aa.setDnaPosition((Integer) source.get("fullRefNucPos"));
                    aa.setTranscriptSymbol(this.getTranscriptSymbol(tr.getTranscriptId()));
                    tr.setAminoAcidVariant(aa);
                    tds.add(tr);

                }
            }

        return tds;

    }
    public String getTranscriptSymbol(String transcriptId){
        TranscriptDAO tdao=new TranscriptDAO();
        Transcript tr= null;
        try {
            tr = tdao.getTranscript(Integer.parseInt(transcriptId));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return tr.getAccId();
    }

}
