package edu.mcw.rgd.cytoscape;

import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.NodeManager;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.process.Utils;

import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.search.elasticsearch1.model.Species;
import edu.mcw.rgd.web.HttpRequestFacade;

import org.bbop.commandline.StringValue;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by jthota on 4/5/2016.
 */


public class CyController implements Controller {

    private NodeManager nodeManager= new NodeManager();
    private ModelMap model = new ModelMap();
    private List<Edge> edges= new ArrayList<>();
    private Set<Object> log = new HashSet<>();
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        Date timeStamp= new Date();
        HttpRequestFacade req= new HttpRequestFacade(request);
        System.out.println("StartTime:" + timeStamp);
        String species = request.getParameter("species");

        if(species!=null ){
            boolean flag=false;
            for(int key:SpeciesType.getSpeciesTypeKeys()){
                if(species.equals(String.valueOf(key))){
                    flag=true;
                    break;
                }
            }
            if(!flag){
                if(species.equalsIgnoreCase("all")){
                    species="0";
                }else
               species=String.valueOf(SpeciesType.parse(request.getParameter("species")));
            }
        }


        String query = request.getParameter("identifiers");
        String browser= request.getParameter("browser");
        if(browser==null){
            browser="12";
        }
        Integer browserVersion= Integer.parseInt(browser);
        ModelMap model = new ModelMap();


        if(req.getParameter("doc").equals("helpDoc")){
            return new ModelAndView("/WEB-INF/jsp/cytoscape/help.jsp");
        }

        if (query==null || query.equals("")) {
            String msg = "Please enter Search data and submit";
            return new ModelAndView("/WEB-INF/jsp/cytoscape/query.jsp", "msg", msg);
        }
        List<String> symbolList = Utils.symbolSplit(query);
        if(symbolList.size()>500){
            String msg="Your query has " + symbolList.size() + " protein/gene Symbols. Maximum list size allowed is 500 proteins/genes. Please reduce the size of your list. ";
            return new ModelAndView("/WEB-INF/jsp/cytoscape/query.jsp", "msg", msg);
        }
        Set<Object> resultSet= this.objectMapper(symbolList,species);

        int interactionCount= this.getInteractionsCount(resultSet);
        List<String> nodes= nodeManager.getNodes(resultSet);
        if(nodes!=null) {
           if (nodes.size() > 0) {
               List<String> edges = nodeManager.getEdges();
               model.put("nodes", nodes); //Nodes in string Format
               model.put("edges", edges); //Edges in String format
               model.put("nodeList", nodeManager.getNodeList()); //Nodes in 'Node' Format
               model.put("matched", nodeManager.getMatched());
               Set<Edge> interactions=  nodeManager.getEdgeList();
               model.put("interactions", nodeManager.getEdgeList()); //Edges in 'Edge' format
               model.put("typeColorMap", nodeManager.getTypeMap()); //Interaction Type Map
               model.put("typeMapJson", nodeManager.getTypeMapJson()); // Interaction Type Map JSON format
               model.put("log", this.getLog());
               model.put("query", query);
               model.put("species", species);
               if(req.getParameter("report").equals("full")){
                     Report report= this.getFullReport(interactions);
                     request.setAttribute("report", report);
                     return new ModelAndView("/WEB-INF/jsp/cytoscape/cyFullReport.jsp", "model", model);
               }
               if(req.getParameter("d").equals("true")){
                   Report report= this.getFullReport(interactions);
                   request.setAttribute("report", report);
                   return new ModelAndView("/WEB-INF/jsp/cytoscape/download.jsp", "model", model);
               }


               if(interactionCount>10000){
                   String msg="Your query returns " + interactionCount + " interactions. Please reduce your query list to return less than 10000 interactions";
                   return new ModelAndView("/WEB-INF/jsp/cytoscape/query.jsp", "msg", msg);
               }

               if (nodes.size() <= 500 && browserVersion >= 11) {
                 //if (nodes.size() <= 500 && browserVersion > 11) {
                   System.out.println("End Time" + new Date());
                   return new ModelAndView("/WEB-INF/jsp/cytoscape/cy2.jsp", "model", model);
               } else {
                   if (nodes.size() > 500 && edges.size()<10000) {
                       String msg = "Your query returned " + nodes.size() + " participants (nodes) and " + edges.size() + " binary interactions (Edges).<br> Network visualization is limited to 500 nodes [participants] for better performance and interactivity. So you are provided only data and no visualization.";
                       model.put("msg", msg);
                       System.out.println("End Time: " + new Date());
                       return new ModelAndView("/WEB-INF/jsp/cytoscape/cyTable.jsp", "model", model);
                   }else{
                       if(edges.size()>=10000){
                           String msg= "Your search returned " + edges.size() +" interactions and " + nodes.size() + " participants. Please narrow down your search to return less than 500 participants for data visualization";
                           return new ModelAndView("/WEB-INF/jsp/cytoscape/query.jsp", "msg", msg);
                       }

                   }
                    if (browserVersion < 11) {
                       String msg = "Your Browser Version is not supported for Data Visualization. So you are provided only data, no visualization";
                       model.put("msg", msg);
                       return new ModelAndView("/WEB-INF/jsp/cytoscape/cyTable.jsp", "model", model);
                   }
               }
           } else {
               String sb = Utils.concatenate(symbolList, ", ");
               List<String> speciesList= new ArrayList<>(Arrays.asList("1","2","3","0","6","9"));
               model.put("speciesType", SpeciesType.getCommonName(Integer.parseInt(species)));
               model.put("log", nodeManager.getLog());
               model.put("msg", "0 binary interactions found for selected species");
               model.put("symbolList", sb);
               model.put("species", species);
               model.put("speciesList", speciesList);
           }
           this.setModel(model);
           System.out.println("End TIME:" + new Date());
           return new ModelAndView("/WEB-INF/jsp/cytoscape/query.jsp", "model", model);
        }



        model.put("log", nodeManager.getLog());
        model.put("msg", "0 binary interactions found");
        return new ModelAndView("/WEB-INF/jsp/cytoscape/query.jsp", "model", model);
    }

    public ModelMap getModel() {
        return model;
    }

    public void setModel(ModelMap model) {
        this.model = model;
    }

    public List<Edge> getEdges() {
        return edges;
    }

    public void setEdges(List<Edge> edges) {
        this.edges = edges;
    }

    public Set<Object> objectMapper(List<String> symbolList, String species) throws  Exception{
        Set<Object> log = new HashSet<>();
        ObjectMapper om = new ObjectMapper();
        List<Object> result = new ArrayList<>();
        Set<Object> resultSet= new HashSet<>();
        System.out.println("OM Start time: " + new Date());
        switch (species) {
            case "0":
                List<String> speciesList = new ArrayList<>(Arrays.asList("1", "2", "3", "6" ,"9"));

                for (String s : speciesList) {
                    om.mapProteinSymbols(symbolList, SpeciesType.parse(s), "rgd");
                    result.addAll(om.getMapped());
                    log.addAll(om.getLog());
                }
                resultSet.addAll(result);

                break;
            default:

                om.mapProteinSymbols(symbolList, SpeciesType.parse(species), "rgd");
                resultSet.addAll(om.getMapped());
                log.addAll(om.getLog());

                break;
        }
        this.setLog(log);
        return resultSet;
    }
    public Report getFullReport(Set<Edge> edges) throws Exception{
        Report report= new Report();
        Record rec= new Record();
        rec.append("Interactor A Protein Symbol");
        rec.append("Uniprot ID A");
        rec.append("Gene A");
        rec.append("Species A");
        rec.append("Interaction Type");
        rec.append("Interactor B Protein Symbol");
        rec.append("Uniprot Id B");
        rec.append("Gene B");
        rec.append("Species B");
        rec.append("Interaction AC");
        rec.append("IMEX ID");
        rec.append("Pubmed ID");
        rec.append("Source DB");
        report.append(rec);
        for(Edge e : edges){
            Record record= new Record();
            record.append(e.getSrcSymbol());
            record.append(e.getSource());
            List<String> srcGeneList= e.getSrcGeneList();
            String srcGene = Utils.concatenate(srcGeneList, ", ");
            record.append(srcGene);
            record.append(e.getSrcSpecies());
            record.append(e.getDescription());
            record.append(e.gettSymbol());
            record.append(e.getTarget());
            List<String> targetGeneList= e.getTargetGeneList();
            String targetGene = Utils.concatenate(targetGeneList, ", ");
            record.append(targetGene);
            record.append(e.getTargetSpecies());
            List<InteractionAttribute> attributes= e.getAttributes();
            List<String> intAc= new ArrayList<>();
            List<String> imex= new ArrayList<>();
            List<String> pubmed= new ArrayList<>();
            List<String> sourceDb= new ArrayList<>();
            for(InteractionAttribute a : attributes){
                if(a.getAttributeName().equals("interaction_ac"))
                    intAc.add(a.getAttributeValue());
            }
            String intAcStr= intAc.toString().replace("[", "");
            String intAcRec= intAcStr.replace("]", "");
            record.append(intAcRec);
            for(InteractionAttribute a : attributes){
                if(a.getAttributeName().equals("imex"))
                    imex.add(a.getAttributeValue());
            }
            String imexStr= imex.toString().replace("[", "");
            String imexRec= imexStr.replace("]", "");
            record.append(imexRec);
            for(InteractionAttribute a : attributes){
                if(a.getAttributeName().equals("pubmed"))
                   pubmed.add(a.getAttributeValue());
            }
            String pubmedStr= pubmed.toString().replace("[", "");
            String pubmedRec= pubmedStr.replace("]", "");
            record.append(pubmedRec);
            for(InteractionAttribute a : attributes){
                if(a.getAttributeName().equals("sourcedb"))
                  sourceDb.add(a.getAttributeValue());
            }
            String sourceStr= sourceDb.toString().replace("[", "");
            String sourceRec= sourceStr.replace("]", "");
            record.append(sourceRec);
            report.append(record);
        }

        return report;
    }

    public Set<Object> getLog() {
        return log;
    }

    public void setLog(Set<Object> log) {
        this.log = log;
    }

    public int getInteractionsCount(Set<Object> resultSet) throws Exception{
        List<Integer> symbolRgdIds= new ArrayList<>();
        Iterator i$ = resultSet.iterator();
        if(resultSet.size()>0){
            while (i$.hasNext()) {
                Object o = i$.next();
                if (o instanceof Gene) {
                    Gene g = (Gene) o;
                    int rgdId= g.getRgdId();
                    symbolRgdIds.add(rgdId);

                } else if (o instanceof Protein) {

                    Protein p = (Protein) o;
                    int rgdId= p.getRgdId();
                    symbolRgdIds.add(rgdId);
                }
            }
        }
        return nodeManager.getInteractionsCount(symbolRgdIds);
    }
}
