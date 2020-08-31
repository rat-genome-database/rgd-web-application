package edu.mcw.rgd.vv;

import edu.mcw.rgd.vv.vvservice.VVService;
import edu.mcw.rgd.vv.vvservice.VariantIndexClient;
import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.TranscriptDAO;
import edu.mcw.rgd.dao.impl.VariantDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
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
    VVService service= new VVService();
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
           List<SearchResult> allResults = new ArrayList<SearchResult>();
        if( vid.isEmpty() || vid.equals("0")) {

            VariantSearchBean vsb = new VariantSearchBean(mapKey);

            if( !sid.isEmpty() )
               vsb.sampleIds.add(Integer.parseInt(sid));
               vsb.setPosition(req.getParameter("chr"), req.getParameter("start"), req.getParameter("stop"));

            // there must be start and stop position
            if( Utils.isStringEmpty(vsb.getChromosome()) ||
                vsb.getStartPosition()==null || vsb.getStartPosition()<1 ||
                vsb.getStopPosition()==null || vsb.getStopPosition()<vsb.getStartPosition() ) {

                throw new VVException("variant detail: missing chr or start or stop");
            }

            VariantController ctrl=new VariantController();
            SearchResult sr = new SearchResult();
         //   List<VariantResult> vr = vdao.getVariantResults(vsb);
            String index= new String();
            if(mapKey==17)
                    index = "variants_human"+mapKey+"_dev1";
            if(mapKey==360 || mapKey==70 || mapKey==60)
                index= "variants_rat"+mapKey+"_prod";
            if(mapKey==631 || mapKey==600 )
                index= "variants_dog"+mapKey+"_dev";
            //   System.out.println("INDEX NAME: "+ index);
            //    index= "variants_dog_index_dev2";

            service.setVariantIndex(index);
            List<VariantResult> vr = ctrl.getVariantResults(vsb,req, true);
            List<TranscriptResult> tResults=new ArrayList<>();
            for(VariantResult r:vr){

                Variant v=r.getVariant();
              //  tResults=getTranscriptResults(v.getChromosome(), v.getStartPos(), v.getEndPos(), v.getReferenceNucleotide(), v.getVariantNucleotide());
                if(SpeciesType.getSpeciesTypeKeyForMap(mapKey)!=1){
                    tResults=r.getTranscriptResults();
                 //   System.out.println("transcripts size: "+ tResults.size());
                }else
                tResults=getTranscriptResults(v, mapKey);

                r.setTranscriptResults(tResults);
             }
            sr.setVariantResults(vr);
            allResults.add(sr);
            request.setAttribute("searchResults",allResults);
            return new ModelAndView("/WEB-INF/jsp/vv/detail.jsp", "searchResult", sr);

        } else {

            String[] vids = vid.split("\\|");

            VariantDAO vdao = new VariantDAO();


            for (int i=0; i < vids.length; i++) {

               SearchResult sr = new SearchResult();
               VariantSearchBean vsb = new VariantSearchBean(mapKey);
               vsb.setVariantId(Long.parseLong(vids[i]));

               vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
               List<VariantResult> vr = vdao.getVariantResults(vsb);

               sr.setVariantResults(vr);
               allResults.add(sr);
            }

            request.setAttribute("searchResults",allResults);

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

            SearchResponse sr = VariantIndexClient.getClient().search(request, RequestOptions.DEFAULT);


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
