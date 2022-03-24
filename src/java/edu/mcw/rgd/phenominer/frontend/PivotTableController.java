package edu.mcw.rgd.phenominer.frontend;

import com.google.gson.Gson;
import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.pheno.Condition;
import edu.mcw.rgd.datamodel.pheno.Record;
import edu.mcw.rgd.datamodel.phenominerExpectedRange.PlotValues;
import edu.mcw.rgd.phenominer.elasticsearch.service.Colors;
import edu.mcw.rgd.phenominer.elasticsearch.service.PhenominerService;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.DelimitedReportStrategy;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.math.BigDecimal;
import java.util.*;


public class PivotTableController implements Controller {

    PhenominerService service=new PhenominerService();
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        PhenominerService.setPhenominerIndex("phenominer_index_dev");
        SearchResponse sr=service.getSearchResponse(req, getFilterMap(request));
        Map<String, List<Terms.Bucket>>aggregations=service.getSearchAggregations(sr);
        boolean facetSearch=req.getParameter("facetSearch").equals("true");
        if(facetSearch) {
            if(getFilterMap(request).size()==1) {
                SearchResponse searchResponse = service.getFilteredAggregations(getFilterMap(request), req);
                if (searchResponse != null) {
                    Map<String, List<Terms.Bucket>> filtered = service.getSearchAggregations(searchResponse);
                    aggregations.putAll(filtered);
                }
            }

        }
        Gson gson=new Gson();
        Colors colors=new Colors();
        Set<String> labels=new HashSet<>();
        request.setAttribute("plotData", getPlotData(sr,labels));
        request.setAttribute("labels",gson.toJson( labels));
        request.setAttribute("colors", colors.colors);
        request.setAttribute("aggregations",aggregations);
        request.setAttribute("sr", sr);
        System.out.println("TOTAL HITS:"+ sr.getHits().getTotalHits());
        System.out.println("COLORS:"+ gson.toJson(colors.colors));
        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominer_elasticsearch/table.jsp", "", null);
    }
    public LinkedHashMap<String, List<Double>> getPlotData(SearchResponse sr, Set<String> labels){
        LinkedHashMap<String, List<Double>> plotData=new LinkedHashMap<>();
        for(SearchHit hit:sr.getHits().getHits()){
         double sd= Double.valueOf((String) hit.getSourceAsMap().get("sd"));
         String strain= (String) hit.getSourceAsMap().get("rsTerm");
         String condition=  hit.getSourceAsMap().get("xcoTerm").toString();
         List<Double> values=new ArrayList<>();
         if(plotData.get(condition)!=null){
             values.addAll(plotData.get(condition));
         }
         values.add(sd);
         labels.add(strain+"_"+hit.getSourceAsMap().get("sex"));
         plotData.put(condition,values );
        }
        Gson gson=new Gson();
        System.out.println(gson.toJson(plotData));
       return plotData;
    }
    public Map<String, String> getFilterMap(HttpServletRequest req){
        Map<String, String> filterMap=new HashMap<>();
        Map<String, String> selectedFilters=new HashMap<>();
        List<String> params=new ArrayList<>(Arrays.asList("cmoTerm", "mmoTerm","xcoTerm","rsTerm","sex","units"));


        for(String param:params)
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
