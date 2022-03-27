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
import edu.mcw.rgd.phenominer.elasticsearch.service.PlotData;
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
import java.awt.*;
import java.math.BigDecimal;
import java.util.*;
import java.util.List;
import java.util.stream.Collectors;


public class PivotTableController implements Controller {
    HashMap<Integer, String> colorMap=new HashMap<>();
    PhenominerService service=new PhenominerService();
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        PhenominerService.setPhenominerIndex("phenominer_index_dev");
        SearchResponse sr=service.getSearchResponse(req, getFilterMap(request));
        Map<String, List<Terms.Bucket>>aggregations=service.getSearchAggregations(sr);
        request.setAttribute("aggregations", aggregations);

        boolean facetSearch=req.getParameter("facetSearch").equals("true");
        if(facetSearch) {
            if(getFilterMap(request).size()==1) {
                SearchResponse searchResponse = service.getFilteredAggregations(getFilterMap(request), req);
                if (searchResponse != null) {
                    Map<String, List<Terms.Bucket>> filtered = service.getSearchAggregations(searchResponse);
                    aggregations.putAll(filtered);
                    request.setAttribute("aggregations", aggregations);

                }
            }

        }
        Gson gson=new Gson();

        List<String> labels=new ArrayList<>();
        List<String> backgroundColors=new ArrayList<>();
        Map<String, String> colors=new HashMap<>();
        List<Map<String, Double>> errorBars=new ArrayList<>();        request.setAttribute("plotData", getPlotData(sr,labels, backgroundColors,colors, errorBars));
      //  request.setAttribute("colors", Colors.colors);
        request.setAttribute("backgroundColor", gson.toJson(backgroundColors));
        request.setAttribute("errorBars", gson.toJson(errorBars));
        request.setAttribute("legend", colors);
        request.setAttribute("labels",gson.toJson( labels));
    //    request.setAttribute("aggregations",aggregations);
        request.setAttribute("sr", sr);
        request.setAttribute("terms", String.join(",", req.getParameterValues("terms")));
        System.out.println("TOTAL HITS:"+ sr.getHits().getTotalHits());
    //    System.out.println("COLORS:"+ gson.toJson(colors.colors));
        return new ModelAndView("/WEB-INF/jsp/phenominer/phenominer_elasticsearch/table.jsp", "", null);
    }
    public LinkedHashMap<String, List<Double>> getPlotData(SearchResponse sr, List<String> labels, List<String> backgroundColors, Map<String, String> colors,List<Map<String, Double>> errorBars ) throws Exception {
        LinkedHashMap<String, List<Double>> plotData=new LinkedHashMap<>();
        List<Double> values=new ArrayList<>();
        int i=0;

        for(SearchHit hit:sr.getHits().getHits()){
            Map<String, Double> errorBarMap=new HashMap<>();
         double value= Double.valueOf((String) hit.getSourceAsMap().get("value"));
         String strain= (String) hit.getSourceAsMap().get("rsTerm");
         String sex= (String) hit.getSourceAsMap().get("sex");
         int noOfAnimals= (int) hit.getSourceAsMap().get("numberOfAnimals");
       List<String> conditions= (List<String>) hit.getSourceAsMap().get("xcoTerm");
        String condition=conditions.stream().collect(Collectors.joining(", "));
        if(!colors.containsKey(condition)){
            colors.put(condition,Colors.colors.get(i));
            backgroundColors.add(Colors.colors.get(i));

            i++;
        }else{
            backgroundColors.add(colors.get(condition));
        }
        errorBarMap.put("plus", Double.parseDouble( hit.getSourceAsMap().get("sem").toString()));
        errorBarMap.put("minus", 0-Double.parseDouble( hit.getSourceAsMap().get("sem").toString()));
        errorBars.add(errorBarMap);
      /*   List<Double> values=new ArrayList<>();
         if(plotData.get(strain)!=null){
             values.addAll(plotData.get(strain));
         }*/
         values.add(value);
         labels.add(strain+"_"+sex +"_animals("+noOfAnimals+")");
       //  plotData.put(strain,values );
        }

        plotData.put("Values",values );

        Gson gson=new Gson();
        System.out.println(gson.toJson(plotData));
        System.out.println("COLORS:"+gson.toJson(colors));
        System.out.println("ERRORBARS:"+gson.toJson(errorBars));
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
