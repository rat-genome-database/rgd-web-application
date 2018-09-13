package edu.mcw.rgd.pipeline;

import edu.mcw.rgd.dao.impl.PipelineLogDAO;
import edu.mcw.rgd.dao.impl.PipelineLogFlagDAO;
import edu.mcw.rgd.datamodel.*;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.object.MappingSqlQuery;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.Types;
import java.util.*;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Mar 15, 2010
 * Time: 11:10:02 AM
 * To change this template use File | Settings | File Templates.
 */
public class PipelineListController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // nr of displayed pipeline logs on the page (ignore the rest)
        int pipelineLogsOnPage = 12;

        // get list of all pipelines
        PipelineLogDAO plogDAO = new PipelineLogDAO();
        List<Pipeline> pipelines = plogDAO.getPipelines();
        PipelineLogFlagDAO plogFlagDAO = new PipelineLogFlagDAO();

        // always add empty pipeline
        Pipeline pip = new Pipeline();
        pip.setName("All pipelines");
        pipelines.add(0, pip);

        request.setAttribute("pipelines", pipelines);

        // is a pipeline selected
        int pkey = 0; // pipeline_key as integer
        String pipelineKey = request.getParameter("pkey");
        if( pipelineKey!=null && pipelineKey.trim().length()>0 )
            pkey = Integer.parseInt(pipelineKey);

        request.setAttribute("pkey", pkey);

        List<PipelineLog> plogs = null;
        if( pkey > 0 ) {
            plogs = plogDAO.getPipelineLogs(pkey, pipelineLogsOnPage);

            // for every pipeline log get general attributes
            for( PipelineLog plog: plogs ) {
                // if pipeline_key is 0, Pipeline object contains only pipeline key; we need to load the pipeline
                // properties now
                plog.setPipeline(plogDAO.getPipeline(plog.getPipeline().getPipelineKey()));

                loadLogProps(plog, plogDAO, plogFlagDAO);
            }
        }
        request.setAttribute("plogs", plogs);


        return new ModelAndView("/WEB-INF/jsp/curation/pipeline/pipelineLogList.jsp");
    }

    public static void loadLogProps(PipelineLog plog, PipelineLogDAO plogDAO, PipelineLogFlagDAO plogFlagDAO) throws Exception {

        plog.addLogProps(plogDAO.getLogProps(plog, PipelineLog.LOGPROP_DATERANGE, -1));
        plog.addLogProps(plogDAO.getLogProps(plog, PipelineLog.LOGPROP_RECCOUNT, -1));
        plog.addLogProps(plogDAO.getLogProps(plog, PipelineLog.LOGPROP_ERRORMESSAGE, -1));
        plog.addLogProps(plogDAO.getLogProps(plog, PipelineLog.LOGPROP_TOTAL, -1));

        // load flags' summary from PIPELINE_LOG_PROPERTIES table
        HashMap<String,Integer> freqMap = plogDAO.getRecordSummary(plog, PipelineLog.LOGPROP_REC_FLAG);
        // append flags' summary from PIPELINE_LOG_FLAGS table
        freqMap.putAll(plogFlagDAO.getFlagSummary(plog.getPipelineLogKey()));

        // create custom log props from flag summaries
        for( Map.Entry<String,Integer> entry: freqMap.entrySet() ) {
            // add custom log props
            PipelineLog.LogProp prop = plog.createLogProp();
            prop.setKey("CUSTOM_FLAG");
            prop.setInfo(entry.getValue().toString());
            prop.setValue(entry.getKey());
            plog.addLogProp(prop);
        }

        plog.sortLogPropsByValue();
    }

}
