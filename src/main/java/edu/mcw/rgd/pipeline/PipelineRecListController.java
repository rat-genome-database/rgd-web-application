package edu.mcw.rgd.pipeline;

import edu.mcw.rgd.dao.impl.PipelineLogDAO;
import edu.mcw.rgd.dao.impl.PipelineLogFlagDAO;
import edu.mcw.rgd.dao.impl.XdbIdDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.pipeline.PipelineFlag;
import edu.mcw.rgd.xml.XomBeautifier;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Mar 19, 2010
 * Time: 9:02:37 AM
 */
public class PipelineRecListController implements Controller {

    static String _rgdUrl, _egRatUrl, _egMouseUrl, _egHumanUrl;
    static String _mgdMouseUrl, _hgncHumanUrl, _hprdHumanUrl;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelAndView mv = new ModelAndView("/WEB-INF/jsp/curation/pipeline/pipelineLogRec.jsp");

        // pipeline key
        int plog = 0; // pipeline_log_key as integer
        String param = request.getParameter("plog");
        if( param!=null && param.trim().length()>0 ) {
            plog = Integer.parseInt(param);
        }
        mv.addObject("plog", Integer.toString(plog));

        // flag value
        String flag = request.getParameter("flag");
        mv.addObject("flag", flag);

        // pageNr and pageSize
        int pageNr = 0, pageSize = 0;
        param = request.getParameter("pagenr");
        if( param!=null && param.trim().length()>0 ) {
            pageNr = Integer.parseInt(param);
        }
        mv.addObject("pagenr", pageNr);

        param = request.getParameter("pagesize");
        if( param!=null && param.trim().length()>0 ) {
            pageSize = Integer.parseInt(param);
        }
        if( pageSize <= 0 )
            pageSize = 20; // default page size
        mv.addObject("pagesize", pageSize);

        if( plog > 0 ) {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");

            // get list of all pipelines
            PipelineLogDAO plogDAO = new PipelineLogDAO();
            PipelineLog pipelineLog = plogDAO.getPipelineLog(plog);
            XdbIdDAO xdbDAO = new XdbIdDAO();
            PipelineLogFlagDAO plogFlagDAO = new PipelineLogFlagDAO();

            // url links to display EG, MGD, HGNC or HPRD records are stored as static variables
            // to avoid costly loading from database
            loadUrls(xdbDAO);

            // load general log props not tied up to specific records
            PipelineListController.loadLogProps(pipelineLog, plogDAO, plogFlagDAO);

            // count nr of records with specific flag
            int recordCount = 0;
            List<PipelineLog.LogProp> logProps = pipelineLog.getLogProps("CUSTOM_FLAG");
            for( PipelineLog.LogProp logProp: logProps ) {
                if( flag==null || flag.length()==0 )
                    recordCount += Integer.parseInt(logProp.getInfo());
                else
                if( logProp.getValue().equals(flag) ) {
                    recordCount = Integer.parseInt(logProp.getInfo());
                    break;
                }
            }

            // examine record count and determine if there are enough rows to show next page
            boolean showNextPage = recordCount > (1+pageNr)*pageSize;
            mv.addObject("showNextPage", showNextPage);
            mv.addObject("firstRecNo", 1+pageNr*pageSize);
            mv.addObject("lastRecNo", Math.min((1+pageNr)*pageSize, recordCount));
            mv.addObject("recordCount", recordCount);

            // load log props tied to specific records
            List<PipelineLog.LogProp> recProps = null;
            if( flag!=null ) {
                // original code -- obsolete once all pipeline will be using PIPELINE_LOG_FLAGS
                recProps = plogDAO.getRecords(pipelineLog, PipelineLog.LOGPROP_REC_FLAG, flag.trim(), pageNr, pageSize );

                // new code -- to be used once all pipelines will be using PIPELINE_LOG_FLAGS
                if( recProps.isEmpty() ) {
                    recProps = plogDAO.getRecordsForFlag(pipelineLog, flag.trim(), pageNr, pageSize );
                }
            }
            else
            if( request.getParameter("recxml")!=null && request.getParameter("recxml").trim().length()>0 ) {
                // single record is to be shown
                recProps = plogDAO.getLogProps(plog, Integer.parseInt(request.getParameter("recxml")));
            }
            else {
                // original code -- obsolete once all pipeline will be using PIPELINE_LOG_FLAGS
                recProps = plogDAO.getRecords(pipelineLog, PipelineLog.LOGPROP_REC_FLAG, pageNr, pageSize );
                // new code -- to be used once all pipelines will be using PIPELINE_LOG_FLAGS
                if( recProps.isEmpty() ) {
                    recProps = plogDAO.getRecords(pipelineLog, PipelineLog.LOGPROP_REC_XML, pageNr, pageSize );
                }
            }

            // now convert these recProps into records (map key is record nr)
            HashMap records = new HashMap<Integer, HashMap<String, Object>>();
            HashMap<String, Object> record;
            TreeSet<Prop> props = null;
            Integer recno;

            for( PipelineLog.LogProp prop: recProps ) {

                // access the given record; if not found in map, create new one
                recno = prop.getRecNo();
                record = (HashMap<String, Object>) records.get(recno);
                if( record == null ) {
                    record = new HashMap<String, Object>();
                    records.put(recno, record);

                    record.put("recno", recno);
                    record.put("date", sdf.format(prop.getDate()));
                    record.put("props", new TreeSet<Prop>());
                }
                props = (TreeSet<Prop>) record.get("props");

                // record value
                String value = "";
                if( prop.getKey().equals(PipelineLog.LOGPROP_REC_RGDID) )
                  value = prop.getValue();
                else if( prop.getKey().equals(PipelineLog.LOGPROP_REC_XDBID) )
                  value = prop.getInfo() + " - " + prop.getValue();
                else if( prop.getKey().equals(PipelineLog.LOGPROP_REC_FLAG) ) {
                    value = prop.getValue() + ": " + prop.getInfo();
                    if( prop.getXml()!=null )
                        value += "<hr/>"+prop.getXml();
                }
                else if( prop.getKey().equals(PipelineLog.LOGPROP_REC_XML) ) {
                    if( prop.getXml()!=null ) {
                        XomBeautifier bea = new XomBeautifier();
                        String xml = bea.convert(prop.getXml());

                        // now find <NCBIGeneID> (and others) and make it clickable links
                        switch(pipelineLog.getPipeline().getSpeciesTypeKey()) {
                            case SpeciesType.RAT:
                                xml = makeLink(xml, "&lt;NCBIGeneID&gt;", "&lt;/NCBIGeneID&gt;", _egRatUrl);
                                xml = makeLink(xml, "&lt;MatchingRGDID&gt;", "&lt;/MatchingRGDID&gt;", _rgdUrl);
                                break;
                            case SpeciesType.MOUSE:
                                xml = makeLink(xml, "&lt;NCBIGeneID&gt;", "&lt;/NCBIGeneID&gt;", _egMouseUrl);
                                xml = makeLink(xml, "&lt;MatchingRGDID&gt;", "&lt;/MatchingRGDID&gt;", _rgdUrl);
                                xml = makeLink(xml, "name=\"MGD\" id=\"MGI:", "\"/&gt;", _mgdMouseUrl);
                                break;
                            case SpeciesType.HUMAN:
                                xml = makeLink(xml, "&lt;NCBIGeneID&gt;", "&lt;/NCBIGeneID&gt;", _egHumanUrl);
                                xml = makeLink(xml, "&lt;MatchingRGDID&gt;", "&lt;/MatchingRGDID&gt;", _rgdUrl);
                                xml = makeLink(xml, "name=\"HGNC ID\" id=\"", "\"/&gt;", _hgncHumanUrl);
                                xml = makeLink(xml, "name=\"HPRD ID\" id=\"", "\"/&gt;", _hprdHumanUrl);
                                break;
                        }
                        value += xml;
                    }
                    record.put("recxml", prop.getXml());

                    // load pipeline log flags (from PIPELINE_LOG_FLAGS table) -- SEP'11 -- MT
                    for( PipelineFlag pflag: plogFlagDAO.getFlagsForRecord(pipelineLog.getPipelineLogKey(), recno, null) ){
                        props.add(new Prop("FLAG", pflag.getSymbol()+": "+pflag.getDescription(), null));
                    }
                }
                else {
                    if( prop.getInfo()!=null )
                      value += prop.getInfo() + " - ";
                    if( prop.getValue()!=null )
                      value += prop.getValue() + " - ";
                    if( prop.getXml()!=null ) {
                        XomBeautifier bea = new XomBeautifier();
                        value += bea.convert(prop.getXml());

                        // parse xml code and convert some ids into links
                    }
                }
                props.add(new Prop(prop.getKey(), value, prop.getDate()));

            }
            mv.addObject("records", records.values());
            
            request.setAttribute("pipelineLog", pipelineLog);
        }

        return mv;
    }

    // replace values of all elements with a link, for example:
    // <RgdId>111</RgdId>
    // becomes
    // <RgdId><a href='http://rgd.mcw.edu/rgdweb/report/gene/main.html?id=111'>111</a></RgdId>
    String makeLink(String xml, String startElement, String endElement, String url) {

        Pattern pattern = Pattern.compile(startElement+"(\\d+)"+endElement);
        Matcher matcher = pattern.matcher(xml);
        return matcher.replaceAll(startElement+"<a href='"+url+"$1'>$1</a>"+endElement);
    }

    void loadUrls(XdbIdDAO xdbDAO) throws Exception {
        // check if the urls are already loaded
        if( _rgdUrl!=null )
            return;

        // load the urls
        _rgdUrl = "/tools/genes/genes_view.cgi?id=";
        _egRatUrl = xdbDAO.getXdbUrl(XdbId.XDB_KEY_NCBI_GENE, SpeciesType.RAT);
        _egMouseUrl = xdbDAO.getXdbUrl(XdbId.XDB_KEY_NCBI_GENE, SpeciesType.MOUSE);
        _egHumanUrl = xdbDAO.getXdbUrl(XdbId.XDB_KEY_NCBI_GENE, SpeciesType.HUMAN);
        _mgdMouseUrl = xdbDAO.getXdbUrl(XdbId.XDB_KEY_MGD, SpeciesType.MOUSE)+"MGI:";
        _hgncHumanUrl = xdbDAO.getXdbUrl(XdbId.XDB_KEY_HGNC, SpeciesType.HUMAN);// does not work
        _hgncHumanUrl = "http://www.genenames.org/data/hgnc_data.php?hgnc_id=";
        _hprdHumanUrl = xdbDAO.getXdbUrl(XdbId.XDB_KEY_HPRD, SpeciesType.HUMAN);
    }

    public class Prop implements Comparable<Prop> {
        String key;
        String value;
        java.util.Date date;

        public Prop(String key, String value, Date date) {
            this.key = key;
            this.value = value;
            this.date = date;
        }

        public int compareTo(Prop o) {
            // first, we compare by keys
            int r = this.key.compareTo(o.key);
            if( r!=0 )
                return r;

            // if keys are equal, compare by date
            if( this.date!=null && o.date!=null ) {
                long l = this.date.getTime() - o.date.getTime();
                if( l!=0 )
                    return l>0 ? -1 : 1;
            }

            // dates are equal -- compare by value
            return value.compareTo(o.value);
        }

        public String getKey() {
            return key;
        }

        public void setKey(String key) {
            this.key = key;
        }

        public String getValue() {
            return value;
        }

        public void setValue(String value) {
            this.value = value;
        }

        public Date getDate() {
            return date;
        }

        public void setDate(Date date) {
            this.date = date;
        }
    }
}

