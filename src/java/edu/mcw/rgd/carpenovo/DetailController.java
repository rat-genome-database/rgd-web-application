package edu.mcw.rgd.carpenovo;

import edu.mcw.rgd.carpenovo.vvservice.VVService;
import edu.mcw.rgd.carpenovo.vvservice.VariantIndexClient;
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
            return new ModelAndView("/WEB-INF/jsp/haplotyper/region.jsp");
        }
    }

    ModelAndView handle(HttpServletRequest request) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        String vid = req.getParameter("vid");
        String sid = req.getParameter("sid");

        int mapKey = 60; // map key defaults to rat assembly 3.4
        String mapKeyStr = request.getParameter("mapKey");
        if( mapKeyStr!=null && !mapKeyStr.isEmpty() )
           mapKey = Integer.parseInt(mapKeyStr);
        System.out.println("VID:"+ vid);
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

         //   VariantDAO vdao = new VariantDAO();
         //   vdao.setDataSource(DataSourceFactory.getInstance().getCarpeNovoDataSource());
            VariantController ctrl=new VariantController();
            SearchResult sr = new SearchResult();
         //   List<VariantResult> vr = vdao.getVariantResults(vsb);
            String index= new String();
            if(mapKey==17) {
                if(!vsb.getChromosome().equals(""))
                    index = "variants_human_chr"+vsb.getChromosome()+"_dev1";
                else index="variants_human_*_dev1";
            }
            System.out.println("VARIANTS INDEX: "+ index);
            service.setVariantIndex(index);
            List<VariantResult> vr = ctrl.getVariantResults(vsb,req);
            List<TranscriptResult> tResults=new ArrayList<>();

            System.out.println("VARIANT RESULT SIZE :"+ vr.size());

            for(VariantResult r:vr){
                Variant v=r.getVariant();
                tResults=getTranscriptResults(v.getChromosome(), v.getStartPos(), v.getEndPos(), v.getReferenceNucleotide(), v.getVariantNucleotide());
                r.setTranscriptResults(tResults);
                System.out.println("VARIANT TRANSCRIPT RESULTS SIZE: "+r.getTranscriptResults().size());
                System.out.println(r.getVariant().getChromosome()+"\t"+r.getVariant().getStartPos()+"\t"+ r.getVariant().getReferenceNucleotide()+
                        "\t"+r.getVariant().getVariantNucleotide());

            }
            sr.setVariantResults(vr);


            allResults.add(sr);
            request.setAttribute("searchResults",allResults);
            return new ModelAndView("/WEB-INF/jsp/haplotyper/detail.jsp", "searchResult", sr);

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

            return new ModelAndView("/WEB-INF/jsp/haplotyper/detail.jsp");
        }
    }
    public List<TranscriptResult> getTranscriptResults(String chr, long startPos,long endPos, String refNuc, String varNuc) throws IOException {
        SearchSourceBuilder srb=new SearchSourceBuilder();
        // srb.query(QueryBuilders.termQuery("startPos", startPos));
        System.out.println("CHROMOSOME: "+ chr+"\tSTARTPOS:"+startPos);
        srb.query(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("chromosome", chr))
                        .filter(QueryBuilders.termQuery("startPos", startPos))
                //  .filter(QueryBuilders.boolQuery().must(QueryBuilders.termQuery("refNuc", refNuc)).must(QueryBuilders.termQuery("varNuc", varNuc)))

        );
        srb.size(10000);
        //    SearchRequest request=new SearchRequest("transcripts_human_dev1"); //chr 21 transcripts
        SearchRequest request=new SearchRequest("transcripts_human_test2"); // chr 1 transcripts
        request.source(srb);


        //   RestHighLevelClient client=ESClient.getInstance();
        SearchResponse sr= VariantIndexClient.getClient().search(request, RequestOptions.DEFAULT);
        List<TranscriptResult> tds= new ArrayList<>();
        System.out.println("TRANSCRIPT HITS SIZE: "+sr.getHits().getTotalHits().value);
        if(sr.getHits().getTotalHits().value >0) {
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
                if(source.get("fullRefAAPos")!=null)
                aa.setAaPosition((Integer) source.get("fullRefAAPos"));
                if(source.get("fullRefNucPos")!=null)
                aa.setDnaPosition((Integer) source.get("fullRefNucPos"));
                aa.setTranscriptSymbol(this.getTranscriptSymbol(tr.getTranscriptId()));
                tr.setAminoAcidVariant(aa);
                tds.add(tr);

            }
       }
    //    VariantIndexClient.getClient().close();
        // System.out.println("TRANSCIPTS SIZE: "+tds.size());
        return tds;
        //   return null;
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
    public static void main(String[] args){
        DetailController controller=new DetailController();
        try {
            List<TranscriptResult> results= controller.getTranscriptResults("13",  19748024,19748025, "", "" );
            System.out.println("TRANSCRIPT RESULTS SIZE in main: "+results.size());
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
