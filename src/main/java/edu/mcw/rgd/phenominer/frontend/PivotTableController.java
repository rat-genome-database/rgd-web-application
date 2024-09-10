package edu.mcw.rgd.phenominer.frontend;

import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;

import edu.mcw.rgd.datamodel.pheno.IndividualRecord;
import edu.mcw.rgd.phenominer.elasticsearch.service.Colors;
import edu.mcw.rgd.phenominer.elasticsearch.service.PhenominerService;

import edu.mcw.rgd.web.HttpRequestFacade;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.aggregations.bucket.terms.Terms;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.awt.*;
import java.io.IOException;
import java.util.*;
import java.util.List;
import java.util.stream.Collectors;


public class PivotTableController implements Controller {
    Gson gson = new Gson();
    PhenominerService service=new PhenominerService();
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        int refRgdId=0;
        try {
            refRgdId = Integer.parseInt(req.getParameter("refRgdId"));
            if(refRgdId>0) request.setAttribute("refRgdId", refRgdId);
        } catch (NumberFormatException e) { }
        String formatStr=req.getParameter("fmt");
        if (formatStr.equals("")) {
            formatStr="1";
        }
        int speciesTypeKey=3;
        if(req.getParameter("species")!=null && !req.getParameter("species").equals("") && !req.getParameter("species").equals("null"))
            speciesTypeKey= Integer.parseInt(req.getParameter("species"));
        request.setAttribute("species", speciesTypeKey);
        int format = Integer.parseInt(formatStr);
        if(format==3){
            response.sendRedirect("/rgdweb/phenominer/download.html?fmt="+format+"&terms="+request.getParameter("terms") +"&refRgdId="+refRgdId);
            return null;
        } else {

            PhenominerService.setPhenominerIndex(RgdContext.getESIndexName("phenominer"));
            SearchResponse sr = service.getSearchResponse(req, getFilterMap(request));
            Map<String, List<Terms.Bucket>> aggregations = service.getSearchAggregations(sr);
            Map<String, List<Terms.Bucket>> filteredAggregations = new HashMap<>();
            Map<String, String> filterMap = getFilterMap(request);
            boolean facetSearch = req.getParameter("facetSearch").equals("true");
            //  System.out.println("FILTERMAP SIZE:" + filterMap.size() + "\t" + gson.toJson(filterMap));
            if (facetSearch) {
                if (filterMap.size() == 1 || (filterMap.size() == 2 && filterMap.containsKey("experimentName"))) {
                    filteredAggregations = service.getFilteredAggregations(filterMap, req);
                    aggregations.putAll(filteredAggregations);

                }
                setSelectAllCheckBox(request);
            }
            request.setAttribute("aggregations", aggregations);


            List<String> labels = new ArrayList<>();
            List<String> backgroundColors = new ArrayList<>();
            Map<String, String> legend = new HashMap<>();
            Map<String, Map<String, Double>> errorBars = new HashMap<>();
            Set<String> unitsSet = new HashSet<>();
            for (SearchHit hit : sr.getHits().getHits()) {
                String unit = (String) hit.getSourceAsMap().get("units");
                unitsSet.add(unit.trim());
            }
            if (unitsSet.size() == 1) {
                request.setAttribute("plotData", getPlotDataWithIndividualRecords(sr, labels, backgroundColors, legend, errorBars, request));
                request.setAttribute("yaxisLabel", unitsSet.iterator().next());

            }

            request.setAttribute("labels", gson.toJson(labels));
            request.setAttribute("columns", getTableColumns(sr));
            request.setAttribute("sr", sr);
            request.setAttribute("facetSearch", facetSearch);
            request.setAttribute("terms", String.join(",", req.getParameterValues("terms")));
            //   System.out.println("TOTAL HITS:" + sr.getHits().getTotalHits());
            return new ModelAndView("/WEB-INF/jsp/phenominer/table.jsp", "", null);

        }

        //  return  new ModelAndView("/WEB-INF/jsp/phenominer/phenominer_elasticsearch/errorBarExample.jsp", "", null);
    }
    public  Map<String, String> getTableColumns(SearchResponse sr){
        Map<String, String> columnMap=new HashMap<>();
        for(SearchHit hit:sr.getHits()){
            Map<String, Object> sourceMap=hit.getSourceAsMap();
            for(String key:sourceMap.keySet()){
                columnMap.put(key, "");
            }
        }
        return columnMap;
    }
    public LinkedHashMap<String, List<Double>> getPlotData(SearchResponse sr, List<String> labels, List<String> backgroundColors, Map<String, String> legend,Map<String,Map<String, Double>> errorBars, HttpServletRequest request ) throws Exception {
        LinkedHashMap<String, List<Double>> plotData = new LinkedHashMap<>();
        List<Double> values = new ArrayList<>();
        String colorBy= request.getParameter("colorBy");
        boolean facetSearch = false;
        if (request.getParameter("facetSearch") != null)
            facetSearch = request.getParameter("facetSearch").equals("true");
        int i = 0;
        Map<String, String> map = new HashMap<>();
        ObjectMapper mapper = new ObjectMapper();
        String legendJson = request.getParameter("legendJson");
        if(legendJson!=null && !legendJson.equals("")) {
            map = mapper.readValue(legendJson, Map.class);
        }

        for (SearchHit hit : sr.getHits().getHits()) {
            Map<String, Double> errorValues = new HashMap<>();
            double value = Double.valueOf((String) hit.getSourceAsMap().get("value"));
            String strain = (String) hit.getSourceAsMap().get("rsTerm");
            String sex = (String) hit.getSourceAsMap().get("sex");
          String condition=new String();
          if(colorBy!=null && !colorBy.equals("")) {
              if (colorBy.equalsIgnoreCase("condition")) {
                  condition = hit.getSourceAsMap().get("xcoTerm").toString().trim();
              } else if (colorBy.equalsIgnoreCase("strain")) {
                  condition = hit.getSourceAsMap().get("rsTerm").toString().trim();
              } else if (colorBy.equalsIgnoreCase("method")) {
                  condition = hit.getSourceAsMap().get("mmoTerm").toString().trim();
              } else if (colorBy.equalsIgnoreCase("sex")) {
                  condition = hit.getSourceAsMap().get("sex").toString().trim();
              } else if (colorBy.equalsIgnoreCase("phenotype")) {
                  condition = hit.getSourceAsMap().get("cmoTerm").toString().trim();
              }
          }else {
              condition=hit.getSourceAsMap().get("xcoTerm").toString().trim();//default color by condition term
          }

            if (facetSearch) {
                if(map.size()>0) {
                    if(map.get(condition)!=null) {
                        backgroundColors.add(map.get(condition));
                        legend.put(condition, map.get(condition));
                    }else{

                      for(int k=0;k<Colors.colors.size();k++) {
                          String newColor=  Colors.colors.get(k);

                          if(!map.containsValue(newColor)) {
                              map.put(condition, newColor);
                              legend.put(condition, newColor);
                              backgroundColors.add(newColor);
                              break;
                          }
                      }
                    }
                }
                else {
                    if (!legend.containsKey(condition)) {
                        legend.put(condition, Colors.colors.get(i));
                        backgroundColors.add(Colors.colors.get(i));
                        i++;
                    }else {
                        backgroundColors.add(legend.get(condition));
                    }
                    //legend.put(condition, map.get(condition));
                }
            } else {
                if (!legend.containsKey(condition)) {
                    legend.put(condition, Colors.colors.get(i));
                    backgroundColors.add(Colors.colors.get(i));

                    i++;
                }else {
                    backgroundColors.add(legend.get(condition));
                }
            }

        //    String e = strain + "_" + sex + "_animals(" + noOfAnimals + ")_" + measurement;
            String e = strain + "_" + sex;
            if(hit.getSourceAsMap().get("sem")!=null) {
                errorValues.put("plus", Double.parseDouble(hit.getSourceAsMap().get("sem").toString()));
                errorValues.put("minus", 0 - Double.parseDouble(hit.getSourceAsMap().get("sem").toString()));
                errorBars.put(e, errorValues);
            }else{
               /* errorValues.put("plus", (double) 0);
                errorValues.put("minus", (double) 0);*/
            }
            values.add(value);
            labels.add(e);
        }
        request.setAttribute("backgroundColor", gson.toJson(backgroundColors));
        request.setAttribute("errorBars", gson.toJson(errorBars));
        request.setAttribute("legend", legend);
        if(request.getParameter("legendJson")!=null && !request.getParameter("legendJson").equals(""))
      //      request.setAttribute("legendJson", request.getParameter("legendJson"));
        request.setAttribute("legendJson", gson.toJson(map));

        else
            request.setAttribute("legendJson", gson.toJson(legend));

        request.setAttribute("colorBy", colorBy);
     //   System.out.println("LEGEND JSON:"+ legendJson);
     //   System.out.println("LEGEND:"+ legend);
        plotData.put("Value", values);
        //     System.out.println("COLORS WORKING:"+gson.toJson(Colors.colors));
        //      System.out.println(gson.toJson(plotData));
        return plotData;
    }
    public LinkedHashMap<String, List<Double>> getPlotDataWithIndividualRecords(SearchResponse sr, List<String> labels, List<String> backgroundColors, Map<String, String> legend,Map<String,Map<String, Double>> errorBars, HttpServletRequest request ) throws Exception {
        LinkedHashMap<String, List<Double>> plotData = new LinkedHashMap<>();
        List<Integer> recordIds=new ArrayList<>();
        List<Double> values = new ArrayList<>();
            int testIndCount=0;
        Map<Integer, List<IndividualRecord>> individualRecords=new HashMap<>();
        LinkedHashMap<Integer, List<Double>> sampleData=new LinkedHashMap<>();
        LinkedHashMap<Integer, List<String>> animalIds=new LinkedHashMap<>();
        String colorBy= request.getParameter("colorBy");
        boolean facetSearch = false;
        if (request.getParameter("facetSearch") != null)
            facetSearch = request.getParameter("facetSearch").equals("true");
        int i = 0;
        Map<String, String> map = new HashMap<>();
        ObjectMapper mapper = new ObjectMapper();
        mapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);

        String legendJson = request.getParameter("legendJson");
        if(legendJson!=null && !legendJson.equals("")) {
            map = mapper.readValue(legendJson, Map.class);
        }
        int cursorPosition=0;
        for (SearchHit hit : sr.getHits().getHits()) {

            Map<String, Double> errorValues = new HashMap<>();
            double value = Double.valueOf((String) hit.getSourceAsMap().get("value"));
            String strain = (String) hit.getSourceAsMap().get("rsTerm");
            String sex = (String) hit.getSourceAsMap().get("sex");
            int recordId = (int) hit.getSourceAsMap().get("recordId");
            String condition=new String();
          //  System.out.println("COLOR BY:"+ colorBy);
         //   System.out.println("COLOR MAP:"+ gson.toJson(map));
            if(colorBy!=null && !colorBy.equals("")) {
                if (colorBy.equalsIgnoreCase("condition")) {
                    condition = hit.getSourceAsMap().get("xcoTerm").toString().trim();
                } else if (colorBy.equalsIgnoreCase("strain")) {
                    condition = hit.getSourceAsMap().get("rsTerm").toString().trim();
                } else if (colorBy.equalsIgnoreCase("method")) {
                    condition = hit.getSourceAsMap().get("mmoTerm").toString().trim();
                } else if (colorBy.equalsIgnoreCase("sex")) {
                    condition = hit.getSourceAsMap().get("sex").toString().trim();
                } else if (colorBy.equalsIgnoreCase("phenotype")) {
                    condition = hit.getSourceAsMap().get("cmoTerm").toString().trim();
                }
            }else {
                condition=hit.getSourceAsMap().get("xcoTerm").toString().trim();//default color by condition term
            }

            if (facetSearch) {
                if(map.size()>0) {
                    if(map.get(condition)!=null) {
                        backgroundColors.add(map.get(condition));
                        legend.put(condition, map.get(condition));
                    }else{

                        for(int k=0;k<Colors.colors.size();k++) {
                            String newColor=  Colors.colors.get(k);

                            if(!map.containsValue(newColor)) {
                                map.put(condition, newColor);
                                legend.put(condition, newColor);
                                backgroundColors.add(newColor);
                                break;
                            }
                        }
                    }
                }
                else {
                    if (!legend.containsKey(condition)) {
                        legend.put(condition, Colors.colors.get(i));
                        backgroundColors.add(Colors.colors.get(i));
                        i++;
                    }else {
                        backgroundColors.add(legend.get(condition));
                    }
                    //legend.put(condition, map.get(condition));
                }
            } else {
                if (!legend.containsKey(condition)) {
                    legend.put(condition, Colors.colors.get(i));
                    backgroundColors.add(Colors.colors.get(i));

                    i++;
                }else {
                    backgroundColors.add(legend.get(condition));
                }
            }

            //    String e = strain + "_" + sex + "_animals(" + noOfAnimals + ")_" + measurement;
            String e = strain + "_" + sex;
            if(hit.getSourceAsMap().get("sem")!=null) {
                errorValues.put("plus", Double.parseDouble(hit.getSourceAsMap().get("sem").toString()));
                errorValues.put("minus", 0 - Double.parseDouble(hit.getSourceAsMap().get("sem").toString()));
                errorBars.put(e, errorValues);
            }else{
               /* errorValues.put("plus", (double) 0);
                errorValues.put("minus", (double) 0);*/
            }
            values.add(value);

           List iRecords= (List) hit.getSourceAsMap().get("individualRecords");
     //     if(testIndCount<1){
           if(iRecords!=null && iRecords.size()>0) {
               int k=0;
             //  System.out.println( hit.getSourceAsMap().get("individualRecords"));
               List<IndividualRecord> individualRecordList=new ArrayList<>();
               for (Object entry:iRecords) {
                    Map<String, Object> record= (Map<String, Object>) entry;
                   IndividualRecord record1= mapper.readValue( gson.toJson(entry), IndividualRecord.class);
                   individualRecordList.add(record1);
                   List<Double> individualValues=new ArrayList<>();
                   List<String> individualNames=new ArrayList<>();
                   if(sampleData.get(k)!=null)
                   individualValues.addAll(sampleData.get(k));
                   else{

                       if(cursorPosition>0) {
                           // valueLength = sampleData.get(0).size();
                           for (int l = 0; l < cursorPosition; l++) {
                               individualValues.add(null);
                           }
                       }
                   }

                   individualValues.add(Double.parseDouble(String.valueOf(record.get("measurementValue"))));

                   sampleData.put(k, individualValues);
                  /* if(animalIds.get(k)!=null){
                       individualNames.addAll(animalIds.get(k));
                   }
                   individualNames.add((String) record.get("animalId"));
                   animalIds.put(k, individualNames);*/
                   k++;
               }

               Collections.sort(individualRecordList, new Comparator<IndividualRecord>() {
                   @Override
                   public int compare(IndividualRecord a, IndividualRecord b) {
                       double mv1=Double.parseDouble( a.getMeasurementValue());
                       double mv2=Double.parseDouble(b.getMeasurementValue());
                       return Double.compare(mv1,mv2);
                   }
               });

             individualRecords.put(recordId, individualRecordList);

               }
           else{

               if(sampleData.size()>0) {
                //   System.out.println("SAMPLE DATA:"+ gson.toJson(sampleData));
                   for (int key : sampleData.keySet()) {
                       List<Double> individualValues=new ArrayList<>();
                       if (sampleData.get(key) != null)
                           individualValues.addAll(sampleData.get(key));
                       individualValues.add(null);
                       sampleData.put(key, individualValues);
                   }
               }

           }
      //     testIndCount++;
      //    }
            cursorPosition++;
            for(Map.Entry entry:sampleData.entrySet()) {
                int key= (int) entry.getKey();
                List<Double> indVals= (List<Double>) entry.getValue();
                if (indVals.size()>0 && indVals.size()  < cursorPosition ) {
                    for (int l = 0; l < (cursorPosition-indVals.size()); l++) {
                        indVals.add(null);
                    }
                }
                sampleData.put(key, indVals);
            }
            recordIds.add(recordId);
            labels.add(e);
        }

        request.setAttribute("recordIds", recordIds);

        request.setAttribute("sortedIndividualRecords", individualRecords);
        request.setAttribute("sampleData", sampleData);
        request.setAttribute("animalIds", gson.toJson(animalIds));

        request.setAttribute("sampleDataJson", gson.toJson(sampleData));
        request.setAttribute("backgroundColor", gson.toJson(backgroundColors));
        request.setAttribute("errorBars", gson.toJson(errorBars));
        request.setAttribute("legend", legend);
        if(request.getParameter("legendJson")!=null && !request.getParameter("legendJson").equals(""))
            //      request.setAttribute("legendJson", request.getParameter("legendJson"));
            request.setAttribute("legendJson", gson.toJson(map));

        else
            request.setAttribute("legendJson", gson.toJson(legend));

        request.setAttribute("colorBy", colorBy);
      //    System.out.println("LEGEND JSON:"+ legendJson);
      //    System.out.println("LEGEND:"+ legend);
        plotData.put("Value", values);
     //   plotData.put("IndividualValues", individualValues);

        //     System.out.println("COLORS WORKING:"+gson.toJson(Colors.colors));
        //      System.out.println(gson.toJson(plotData));
        return plotData;
    }
    public Map<String, String> getFilterMap(HttpServletRequest req) throws IOException {
        Map<String, String> filterMap = new HashMap<>();
        LinkedHashMap<String, String> selectedFilters = new LinkedHashMap<>();
        String filterJsonString=req.getParameter("selectedFiltersJson");
        String unchecked= req.getParameter("unchecked");
        String uncheckedAll= req.getParameter("uncheckedAll");
       // System.out.println("UNCHECKED:"+ req.getParameter("unchecked"));
       // System.out.println("UNCHECKED ALL:"+ req.getParameter("uncheckedAll"));

        List<String> params = new ArrayList<>(Arrays.asList("cmoTerm", "mmoTerm", "xcoTerm", "rsTerm", "sex", "units","experimentName"));

        if(filterJsonString!=null) {
            ObjectMapper mapper = new ObjectMapper();
            Map<String, String> filterJson = mapper.readValue(filterJsonString, Map.class);
            if (filterJson != null) {
                for (Map.Entry e : filterJson.entrySet()) {
                    List<String> filterValues= Arrays.asList(e.getValue().toString().split(","));
                   // System.out.println(e.getKey() + "\t" + e.getValue().toString());
                    String key= (String) e.getKey();
                    List<String> keyValues= new ArrayList<>();
                    if(selectedFilters.get(key)!=null)
                        keyValues.addAll(Arrays.asList(selectedFilters.get(key).split(",")));
                    if(uncheckedAll!=null && !uncheckedAll.equalsIgnoreCase(key))
                    for(String filterValue:filterValues){
                        if(unchecked!=null && !filterValue.equalsIgnoreCase(unchecked)){
                            if(!keyValues.contains(filterValue))
                           keyValues.add(filterValue);
                        }
                    }
                    if(keyValues.size()>0)
                    selectedFilters.put(key, String.join(",", keyValues));
                }
            }
        }
        for (String param : params) {
            if (req.getParameterValues(param) != null) {
                List<String> values = Arrays.asList(req.getParameterValues(param));
                List<String> keyValues= new ArrayList<>();
                if(selectedFilters.get(param)!=null)
                    keyValues.addAll(Arrays.asList(selectedFilters.get(param).split(",")));
                if (values.size() > 0) {
                    for(String val:values){
                        if(!keyValues.contains(val)){
                           keyValues.add(val);
                        }
                    }
                    filterMap.put(param, String.join(",", keyValues));
                    selectedFilters.put(param, String.join(",", keyValues));
                }
            }
        }
        req.setAttribute("selectedFilters", selectedFilters);
        req.setAttribute("selectedFiltersJson" , gson.toJson(selectedFilters));

     //   System.out.println("SELECTED FILTERS:"+ gson.toJson(selectedFilters));
     //   return filterMap;
        return selectedFilters;
    }
    public void setSelectAllCheckBox( HttpServletRequest request) {
        Map<String, String> selectAllCheckBox=new HashMap<>();
        boolean facetSearch=false;
        if(request.getParameter("facetSearch")!=null)
        facetSearch=request.getParameter("facetSearch").equals("true");
        if(facetSearch) {
            if (request.getParameter("rsAll") != null && request.getParameter("rsAll").equals("on")) {
                selectAllCheckBox.put("rsAll", request.getParameter("rsAll"));
            }
            if (request.getParameter("cmoAll") != null && request.getParameter("cmoAll").equals("on")) {
                selectAllCheckBox.put("cmoAll", request.getParameter("cmoAll"));
            }
            if (request.getParameter("mmoAll") != null && request.getParameter("mmoAll").equals("on")) {
                selectAllCheckBox.put("mmoAll", request.getParameter("mmoAll"));
            }
            if (request.getParameter("xcoAll") != null && request.getParameter("xcoAll").equals("on")) {
                selectAllCheckBox.put("xcoAll", request.getParameter("xcoAll"));
            }
            if (request.getParameter("sexAll") != null && request.getParameter("sexAll").equals("on")) {
                selectAllCheckBox.put("sexAll", request.getParameter("sexAll"));
            }
            if (request.getParameter("unitsAll") != null && request.getParameter("unitsAll").equals("on")) {
                selectAllCheckBox.put("unitsAll", request.getParameter("unitsAll"));
            }
        }
        request.setAttribute("selectAllCheckBox", selectAllCheckBox);

    }
   
        public Map<String, String> setSelectedFilters( Map<String, List<Terms.Bucket>> aggregations){

        Map<String, String> selectedFilters = new HashMap<>();
        for(Map.Entry e:aggregations.entrySet()){
         //   System.out.println(e.getKey());
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
