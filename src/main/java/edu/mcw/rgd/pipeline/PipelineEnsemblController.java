package edu.mcw.rgd.pipeline;

import edu.mcw.rgd.dao.impl.PipelineLogDAO;
import edu.mcw.rgd.datamodel.PipelineLog;
import edu.mcw.rgd.datamodel.SpeciesType;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

/**
 * @author mtutaj
 * @since 9/20/11
 * <p>
 * CLASS DESCRIPTION HERE
 */
public class PipelineEnsemblController implements Controller {

    PipelineLogDAO dao = new PipelineLogDAO();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // load id of last pipeline log for EnsemblRat
        PipelineLog plog = dao.getLastPipelineLog("Ensembl", SpeciesType.RAT, "download+process", null);

        // map of summary variables
        Map<String, String> summaryMap = new TreeMap<String, String>();

        // count of objects in the pipeline log
        String recordCount = getCountOfPipelineLogRecords(plog);
        summaryMap.put("1. # of Ensembl rat genes processed", recordCount);

        // count of ensembl genes with no rgd ids
        Integer count = getFlagCount(plog, "RGDIDS_MISSING");
        summaryMap.put("2. # of Ensembl genes with missing RGD IDS", count.toString());

        count = getFlagCount(plog, "NCBIGENE_MISSING");
        summaryMap.put("3. # of Ensembl genes with missing NCBI Gene IDS", count.toString());

        count = getFlagIntersectCount(plog, "RGDIDS_MISSING", "NCBIGENE_MISSING");
        summaryMap.put("4. # of Ensembl genes with missing both NCBI Gene IDS and RGD IDs", count.toString());

        count = getFlagMinusCount(plog, "RGDIDS_MISSING", "NCBIGENE_MISSING");
        summaryMap.put("5. # of Ensembl genes with missing RGD IDs, but present NCBI Gene Ids", count.toString());

        count = getFlagMinusCount(plog, "NCBIGENE_MISSING", "RGDIDS_MISSING");
        summaryMap.put("6. # of Ensembl genes with missing NCBI Gene Ids, but present RGD IDs", count.toString());

        count = getFlagCount(plog, "RGDIDS_MULTI_MATCH");
        summaryMap.put("7. # of Ensembl genes with multiple rgd ids", count.toString());

        recordCount = getCountOfMultipleEnsemblIdsMappedToOneRgdId(plog);
        summaryMap.put("8. # of multiple Ensembl gene ids mapped to a single rgd id", recordCount);

        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/curation/pipeline/ensembl.jsp");
        mv.addObject("summaryMap", summaryMap);

        // STAGE 2: extract all entries  having properties of type WARN
        List<PipelineLog.LogProp> logProps = dao.getLogProps(plog, PipelineLog.LOGPROP_WARNMESSAGE, -1);
        // extract values for logprops with INFO set to "CONFLICT_BIN1"
        StringBuilder bin1 = new StringBuilder(100000);
        int bin1Count = 0;
        for( PipelineLog.LogProp logProp: logProps ) {
            if( logProp.getInfo()!=null && logProp.getInfo().equals("CONFLICT_BIN1") ) {
                bin1.append(logProp.getValue());
                bin1Count++;
            }
        }
        mv.addObject("bin1", bin1.toString());
        mv.addObject("bin1_count", bin1Count);

        return mv;
    }

    String getCountOfPipelineLogRecords(PipelineLog plog) throws Exception {

        List<PipelineLog.LogProp> logProps = dao.getLogProps(plog, "RECCOUNT", -1);
        if( logProps.isEmpty() )
            return "0";
        return logProps.get(0).getValue();
    }

    String getCountOfMultipleEnsemblIdsMappedToOneRgdId(PipelineLog plog) throws Exception {

        for( PipelineLog.LogProp logProp: dao.getLogProps(plog, "TOTAL", -1) ) {
            if( logProp.getInfo().contains("multiple ensembl gene ids mapped to a single rgd id") )
                return logProp.getValue();
        }
        return "0";
    }

    int getFlagCount(PipelineLog plog, String flagSymbol) throws Exception {

        String query =
            "SELECT COUNT(*) cnt\n"+
            "  FROM pipeline_log_flags pf, pipeline_flags f\n"+
            "  WHERE pipeline_log_key=? AND f.pipeline_flag_id=pf.pipeline_flag_id AND pipeline_flag_symbol=?\n";

        return dao.getCount(query, plog.getPipelineLogKey(), flagSymbol);
    }

    Integer getFlagIntersectCount(PipelineLog plog, String flagSymbol1, String flagSymbol2) throws Exception {

        String query =
            "SELECT COUNT(*) cnt FROM( \n"+
            " SELECT pipeline_log_record_no \n"+
            " FROM pipeline_log_flags pf, pipeline_flags f \n"+
            " WHERE pipeline_log_key=? AND f.pipeline_flag_id=pf.pipeline_flag_id AND pipeline_flag_symbol=? \n"+
            "INTERSECT \n"+
            " SELECT pipeline_log_record_no \n"+
            " FROM pipeline_log_flags pf, pipeline_flags f \n"+
            " WHERE pipeline_log_key=? AND f.pipeline_flag_id=pf.pipeline_flag_id AND pipeline_flag_symbol=? \n"+
            ")";
        return dao.getCount(query, plog.getPipelineLogKey(), flagSymbol1, plog.getPipelineLogKey(), flagSymbol2);
    }

    Integer getFlagMinusCount(PipelineLog plog, String flagSymbol1, String flagSymbol2) throws Exception {

        String query =
            "SELECT COUNT(*) cnt FROM( \n"+
            " SELECT pipeline_log_record_no \n"+
            " FROM pipeline_log_flags pf, pipeline_flags f \n"+
            " WHERE pipeline_log_key=? AND f.pipeline_flag_id=pf.pipeline_flag_id AND pipeline_flag_symbol=? \n"+
            "MINUS \n"+
            " SELECT pipeline_log_record_no \n"+
            " FROM pipeline_log_flags pf, pipeline_flags f \n"+
            " WHERE pipeline_log_key=? AND f.pipeline_flag_id=pf.pipeline_flag_id AND pipeline_flag_symbol=? \n"+
            ")";
        return dao.getCount(query, plog.getPipelineLogKey(), flagSymbol1, plog.getPipelineLogKey(), flagSymbol2);
    }
}
