package edu.mcw.rgd.phenominer.frontend;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;

import edu.mcw.rgd.phenominer.elasticsearch.service.Colors;
import edu.mcw.rgd.phenominer.elasticsearch.service.PhenominerService;

import edu.mcw.rgd.web.HttpRequestFacade;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.util.*;
import java.util.List;
import java.util.stream.Collectors;


public class PivotTableController implements Controller {
    Gson gson = new Gson();
    PhenominerService service=new PhenominerService();
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        PhenominerService.setPhenominerIndex("phenominer_index_dev");
        SearchResponse sr = service.getSearchResponse(req, getFilterMap(request));
        Map<String, List<Terms.Bucket>> aggregations = service.getAggregationsBeforeFilters(req);
        request.setAttribute("aggregations", aggregations);
        Map<String, List<Terms.Bucket>> filteredAggregations = new HashMap<>();

        boolean facetSearch = req.getParameter("facetSearch").equals("true");
        if (facetSearch) {

                SearchResponse searchResponse = service.getFilteredAggregations(getFilterMap(request), req);
                if (searchResponse != null) {
                    Map<String, List<Terms.Bucket>> filtered = service.getSearchAggregations(searchResponse);
                    filtered.putAll(filtered);
                    request.setAttribute("filteredAggregations", filteredAggregations);

                }
        setSelectAllCheckBox(request);

        }else{
         //   request.setAttribute("selectedFilters", setSelectedFilters(aggregations));
        }


        List<String> labels = new ArrayList<>();
        List<String> backgroundColors = new ArrayList<>();
        Map<String, String> legend = new HashMap<>();
        Map<String, Map<String, Double>> errorBars = new HashMap<>();
        request.setAttribute("plotData", getPlotData(sr, labels, backgroundColors, legend, errorBars, request));
        request.setAttribute("backgroundColor", gson.toJson(backgroundColors));
        request.setAttribute("errorBars", gson.toJson(errorBars));
        request.setAttribute("legend", legend);
        request.setAttribute("legendJson", gson.toJson(legend));
        request.setAttribute("labels", gson.toJson(labels));
        request.setAttribute("sr", sr);
        request.setAttribute("facetSearch", facetSearch);
        request.setAttribute("terms", String.join(",", req.getParameterValues("terms")));
        System.out.println("TOTAL HITS:" + sr.getHits().getTotalHits());
        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominer_elasticsearch/table.jsp", "", null);
        //  return  new ModelAndView("/WEB-INF/jsp/phenominer/phenominer_elasticsearch/errorBarExample.jsp", "", null);
    }
    public LinkedHashMap<String, List<Double>> getPlotData(SearchResponse sr, List<String> labels, List<String> backgroundColors, Map<String, String> legend,Map<String,Map<String, Double>> errorBars, HttpServletRequest request ) throws Exception {
        LinkedHashMap<String, List<Double>> plotData = new LinkedHashMap<>();
        List<Double> values = new ArrayList<>();
        Gson gson = new Gson();
        boolean facetSearch = false;
        if (request.getParameter("facetSearch") != null)
            facetSearch = request.getParameter("facetSearch").equals("true");
        int i = 0;
        Map<String, String> map = new HashMap<>();
        if (facetSearch) {
            ObjectMapper mapper = new ObjectMapper();
            String legendJson = request.getParameter("legendJson");
            map = mapper.readValue(legendJson, Map.class);
        }
        for (SearchHit hit : sr.getHits().getHits()) {
            Map<String, Double> errorValues = new HashMap<>();
            double value = Double.valueOf((String) hit.getSourceAsMap().get("value"));
            String strain = (String) hit.getSourceAsMap().get("rsTerm");
            String sex = (String) hit.getSourceAsMap().get("sex");
            int noOfAnimals = (int) hit.getSourceAsMap().get("numberOfAnimals");
            List<String> conditions = (List<String>) hit.getSourceAsMap().get("xcoTerm");
            String condition = conditions.stream().collect(Collectors.joining(", "));
            if (!legend.containsKey(condition)) {
                legend.put(condition, Colors.colors.get(i));
                backgroundColors.add(Colors.colors.get(i));

                i++;
            } else {
                if (facetSearch) {
                    backgroundColors.add(map.get(condition));
                    legend.put(condition, map.get(condition));
                } else {
                    backgroundColors.add(legend.get(condition));
                }
            }
            if(hit.getSourceAsMap().get("sem")!=null) {
                errorValues.put("plus", Double.parseDouble(hit.getSourceAsMap().get("sem").toString()));
                errorValues.put("minus", 0 - Double.parseDouble(hit.getSourceAsMap().get("sem").toString()));
                errorBars.put(strain + "_" + sex + "_animals(" + noOfAnimals + ")", errorValues);
            }else{
               /* errorValues.put("plus", (double) 0);
                errorValues.put("minus", (double) 0);*/
            }
            values.add(value);
            labels.add(strain + "_" + sex + "_animals(" + noOfAnimals + ")");
        }

        plotData.put("Value", values);


        System.out.println(gson.toJson(plotData));
        System.out.println("LEGEND:" + gson.toJson(legend));
        System.out.println("ERRORBARS:" + gson.toJson(errorBars));
    /*    List<PlotData> dataSet=new ArrayList<>();
        int i=0;
        for(Map.Entry entry:plotData.entrySet()) {
            PlotData data = new PlotData();
            String label = (String) entry.getKey();
            data.setLabel(label);
            data.setData((List<Double>) entry.getValue());
            data.setBackgroundColor( Colors.colors.get(i));
            data.setBorderWidth(2);
            data.setBorderColor(Colors.colors.get(i));
            dataSet.add(data);

            i++;
        }*/

        //     System.out.println("COLORS WORKING:"+gson.toJson(Colors.colors));

        //      System.out.println(gson.toJson(plotData));

        return plotData;
    }
    public Map<String, String> getFilterMap(HttpServletRequest req){
        Map<String, String> filterMap = new HashMap<>();
        Map<String, String> selectedFilters = new HashMap<>();
        List<String> params = new ArrayList<>(Arrays.asList("cmoTerm", "mmoTerm", "xcoTerm", "rsTerm", "sex", "units"));
        for (String param : params) {
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
    public void setSelectAllCheckBox( HttpServletRequest request) {
        System.out.println("rsAll:"+request.getParameter("rsAll"));
        Map<String, String> selectAllCheckBox=new HashMap<>();
        if(request.getParameter("rsAll")!=null && request.getParameter("rsAll").equals("on")) {
            selectAllCheckBox.put("rsAll", request.getParameter("rsAll"));
        }
        if(request.getParameter("cmoAll")!=null && request.getParameter("cmoAll").equals("on")) {
            selectAllCheckBox.put("cmoAll", request.getParameter("cmoAll"));
        }
        if(request.getParameter("mmoAll")!=null && request.getParameter("mmoAll").equals("on")) {
            selectAllCheckBox.put("mmoAll", request.getParameter("mmoAll"));
        }
        if(request.getParameter("xcoAll")!=null && request.getParameter("xcoAll").equals("on")) {
            selectAllCheckBox.put("xcoAll", request.getParameter("xcoAll"));
        }
        if(request.getParameter("sexAll")!=null && request.getParameter("sexAll").equals("on")) {
            selectAllCheckBox.put("sexAll", request.getParameter("sexAll"));
        }
        if(request.getParameter("unitsAll")!=null && request.getParameter("unitsAll").equals("on")) {
            selectAllCheckBox.put("unitsAll", request.getParameter("unitsAll"));
        }

        request.setAttribute("selectAllCheckBox", selectAllCheckBox);

    }

        public Map<String, String> setSelectedFilters( Map<String, List<Terms.Bucket>> aggregations){

        Map<String, String> selectedFilters = new HashMap<>();
        for(Map.Entry e:aggregations.entrySet()){
            System.out.println(e.getKey());
            List<Terms.Bucket> buckets= (List<Terms.Bucket>) e.getValue();
            String value=buckets.stream().map(b->b.getKey().toString()).collect(Collectors.joining(","));
            switch (e.getKey().toString()){
                case "mmoTermBkts":

                    selectedFilters.put("mmoTerm",value);
                    break;
                case "rsTermBkts":
                    selectedFilters.put("rsTerm",value);

                    break;
                case "unitBkts":
                    selectedFilters.put("units",value);

                    break;
                case "cmoTermBkts":
                    selectedFilters.put("cmoTerm",value);

                    break;
                case  "xcoTermBkts":
                    selectedFilters.put("xcoTerm",value);

                    break;
                case  "sexBkts":
                    selectedFilters.put("sex",value);

                    break;
                default:
            }
        }
        return  selectedFilters;
    }


}
