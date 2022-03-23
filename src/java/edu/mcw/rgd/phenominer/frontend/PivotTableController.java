package edu.mcw.rgd.phenominer.frontend;

import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.pheno.Condition;
import edu.mcw.rgd.datamodel.pheno.Record;
import edu.mcw.rgd.phenominer.elasticsearch.service.PhenominerService;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.DelimitedReportStrategy;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.math.BigDecimal;
import java.util.*;

/**
 * Created by jdepons on 5/11/2017.
 */
public class PivotTableController implements Controller {

    PhenominerService service=new PhenominerService();
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        PhenominerService.setPhenominerIndex("phenominer_index_dev");
        SearchResponse sr=service.getSearchResponse(req);
       // service.getAggregations(req);
        Map<String, List<Terms.Bucket>>aggregations=service.getSearchAggregations(sr);
        request.setAttribute("aggregations",aggregations);
        request.setAttribute("sr", sr);
        System.out.println("TOTAL HITS:"+ sr.getHits().getTotalHits());
        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominer_elasticsearch/table.jsp", "", null);
    }
    public Map<String, String> getFilterMap(HttpServletRequest req){
        Map<String, String> filterMap=new HashMap<>();
        Map<String, String> mappings=new HashMap<>();
        Map<String, String> selectedFilters=new HashMap<>();
        filterMap.put("cmoTerm","");
        filterMap.put("mmoTerm","");
        filterMap.put("xcoTerm","");
        filterMap.put("rsTerm","");
        filterMap.put("sex","");
        filterMap.put("units","");

        for(String param:filterMap.keySet())
        {
            if (req.getParameterValues(param) != null) {
                List<String> values = Arrays.asList(req.getParameterValues(param));
                if (values.size() > 0) {
                    filterMap.put(param, String.join(",", values));
                    selectedFilters.put(param, String.join(",", values));
                }
            }
        }
        req.setAttribute("selectedFilters", selectedFilters);

        return filterMap;
    }



}
