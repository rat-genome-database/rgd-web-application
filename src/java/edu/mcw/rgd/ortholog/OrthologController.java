package edu.mcw.rgd.ortholog;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.OrthologDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.MappedGene;
import edu.mcw.rgd.datamodel.Ortholog;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.reporting.*;

import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;
import java.util.stream.Collectors;

/**
 * Created by hsnalabolu on 4/10/2019.
 */
public class OrthologController implements Controller {


    HttpServletRequest request = null;
    HttpServletResponse response = null;
    HttpRequestFacade req = null;
    int inSpeciesTypeKey=-1;
    int outSpeciesTypeKey=-1;
    int inMapKey=-1;
    int outMapKey=-1;
    String chr = "";
    int start = 0;
    int stop = 0;
    List<String> symbols=null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        String fmt = Utils.NVL(request.getParameter("fmt"), "full");

        this.request = request;
        this.response = response;
        req=new HttpRequestFacade(request);

        if (!request.getParameter("inSpecies").equals("")) {
            this.inSpeciesTypeKey = Integer.parseInt(request.getParameter("inSpecies"));
        }
        if (!request.getParameter("outSpecies").equals("")) {
            this.outSpeciesTypeKey = Integer.parseInt(request.getParameter("outSpecies"));
        }
        if (!request.getParameter("genes").equals("")) {
            this.symbols = Utils.symbolSplit(request.getParameter("genes"));
            this.symbols = symbols.stream().map(s-> s.toLowerCase()).collect(
                    Collectors.toList());
        } else this.symbols = null;
        this.inMapKey = Integer.parseInt(request.getParameter("inMapKey"));
        this.outMapKey = Integer.parseInt(request.getParameter("outMapKey"));

        if(!req.getParameter("chr").equals(""))
            this.chr = req.getParameter("chr");
        if(!req.getParameter("start").equals(""))
            this.start = Integer.parseInt(req.getParameter("start"));
        else this.start = 0;
        if(!req.getParameter("stop").equals(""))
            this.stop = Integer.parseInt(req.getParameter("stop"));
        else this.stop = 0;

        this.setOrthologs(request,response);
         request.setAttribute("error", error);

    if(fmt.equalsIgnoreCase("csv")) {
        return new ModelAndView("/WEB-INF/jsp/ortholog/report_csv.jsp", "hello", null);
    }
    else
        return new ModelAndView("/WEB-INF/jsp/ortholog/report.jsp", "hello", null);

    }
    protected void setOrthologs(HttpServletRequest request, HttpServletResponse response) throws Exception {

        GeneDAO gdao = new GeneDAO();
        OrthologDAO odao = new OrthologDAO();
        Report report = new Report();

        Map<Integer, Integer> orthologMap = new HashMap<>();
        Map<Integer, List<MappedGene>> geneMap = new HashMap<>();
        ObjectMapper om = buildMapper(null,request,response);
        Map<Integer, List<MappedGene>> mappedGeneMap = new HashMap<>();
        List<Integer> mappedIds = om.getMappedRgdIds();



        if(mappedIds.size() != 0 ) {
            List<MappedGene> rgdIds = gdao.getActiveMappedGenesByIds(this.inMapKey, mappedIds);
            geneMap = rgdIds.stream().collect(
                    Collectors.groupingBy(MappedGene -> MappedGene.getGene().getRgdId()));
            Set<Integer> geneSet = geneMap.keySet().stream().collect(Collectors.toSet());
            List<Integer> geneRgdIds = new ArrayList<>();
            geneRgdIds.addAll(geneSet);

            Set<String> symbolsFound = new TreeSet<>();



            if (geneRgdIds.size() != 0) {
                List<Ortholog> orthologs;
                List<Integer> orthologIds;
                if(inSpeciesTypeKey == outSpeciesTypeKey) {

                    orthologIds = mappedIds;
                    orthologMap = mappedIds.stream().collect(Collectors.toMap(x->x,x->x));
                }else {

                    orthologs = odao.getOrthologsForSourceRgdIds(geneRgdIds, outSpeciesTypeKey);
                    for(Ortholog o:orthologs){
                        orthologMap.put(o.getSrcRgdId(),o.getDestRgdId());
                    }
                    //orthologMap = orthologs.stream().collect(
                    //        Collectors.toMap(Ortholog::getSrcRgdId, Ortholog::getDestRgdId));
                    orthologIds = orthologs.stream().map(Ortholog::getDestRgdId).collect(
                            Collectors.toList());
                }


                List<MappedGene> positions = gdao.getActiveMappedGenesByIds(outMapKey, orthologIds);
                mappedGeneMap = positions.stream().collect(
                        Collectors.groupingBy(MappedGene -> MappedGene.getGene().getRgdId()));

                String inSpecies = SpeciesType.getCommonName(inSpeciesTypeKey)+"_"+ MapManager.getInstance().getMap(inMapKey).getName();
                String outSpecies = SpeciesType.getCommonName(outSpeciesTypeKey)+"_"+ MapManager.getInstance().getMap(outMapKey).getName();


                edu.mcw.rgd.reporting.Record rec = new edu.mcw.rgd.reporting.Record();
                rec.append(inSpecies + "_Rgd Id");
                rec.append(inSpecies + "_GeneSymbol");
                rec.append(inSpecies + "_Chromosome");
                rec.append(inSpecies + "_Position Start");
                rec.append(inSpecies + "_Position End");
                rec.append(inSpecies + "_Strand");
                rec.append(outSpecies + "_Rgd Id");
                rec.append(outSpecies + "_GeneSymbol");
                rec.append(outSpecies + "_Chromosome");
                rec.append(outSpecies + "_Position Start");
                rec.append(outSpecies + "_Position End");
                rec.append(outSpecies + "_Strand");
                report.append(rec);

                for (Integer rgdId : geneMap.keySet()) {
                    symbolsFound.add(geneMap.get(rgdId).get(0).getGene().getSymbol().toLowerCase());
                    for (MappedGene inputGene : geneMap.get(rgdId)) {

                        if ((orthologMap.keySet().contains(rgdId))) {
                            if ((mappedGeneMap.keySet().contains(orthologMap.get(rgdId)))) {

                                for (MappedGene ortholog : mappedGeneMap.get(orthologMap.get(rgdId))) {

                                    rec = new edu.mcw.rgd.reporting.Record();
                                    rec.append(String.valueOf(rgdId));
                                    rec.append(inputGene.getGene().getSymbol());
                                    rec.append(inputGene.getChromosome());
                                    rec.append(String.valueOf(inputGene.getStart()));
                                    rec.append(String.valueOf(inputGene.getStop()));
                                    rec.append(inputGene.getStrand());
                                    rec.append(String.valueOf(ortholog.getGene().getRgdId()));
                                    rec.append(ortholog.getGene().getSymbol());
                                    rec.append(ortholog.getChromosome());
                                    rec.append(String.valueOf(ortholog.getStart()));
                                    rec.append(String.valueOf(ortholog.getStop()));
                                    rec.append(ortholog.getStrand());
                                    report.append(rec);
                                }
                            } else {
                                rec = new edu.mcw.rgd.reporting.Record();
                                rec.append(String.valueOf(rgdId));
                                rec.append(inputGene.getGene().getSymbol());
                                rec.append(inputGene.getChromosome());
                                rec.append(String.valueOf(inputGene.getStart()));
                                rec.append(String.valueOf(inputGene.getStop()));
                                rec.append(inputGene.getStrand());
                                rec.append(String.valueOf(orthologMap.get(rgdId)));
                                rec.append(gdao.getGene(orthologMap.get(rgdId)).getSymbol());
                                rec.append("No Position found for this gene");
                                report.append(rec);
                            }
                        } else {
                            rec = new edu.mcw.rgd.reporting.Record();
                            rec.append(String.valueOf(rgdId));
                            rec.append(inputGene.getGene().getSymbol());
                            rec.append(inputGene.getChromosome());
                            rec.append(String.valueOf(inputGene.getStart()));
                            rec.append(String.valueOf(inputGene.getStop()));
                            rec.append(inputGene.getStrand());
                            rec.append("No ortholog found for this gene");
                            report.append(rec);
                        }
                    }
                }
            }


        }

        request.setAttribute("report", report);


        request.setAttribute("geneMap", geneMap);
        request.setAttribute("orthologMap", orthologMap);
        request.setAttribute("mappedGenes", mappedGeneMap);

        request.setAttribute("inSpecies",inSpeciesTypeKey);
        request.setAttribute("outSpecies",outSpeciesTypeKey);
        request.setAttribute("inMapKey",inMapKey);
        request.setAttribute("outMapKey",outMapKey);
        request.setAttribute("genes",this.symbols);
        request.setAttribute("notFound",om.getLog());
        request.setAttribute("chr",chr);
        request.setAttribute("start",this.start);
        request.setAttribute("stop",this.stop);
    }

    private ObjectMapper buildMapper(String integerIdType,HttpServletRequest req,HttpServletResponse res) throws Exception{
        ObjectMapper om = new ObjectMapper();


        if (symbols == null  ) {

            om.mapPosition(chr,start,stop, inMapKey);
            Iterator symbolIt = om.getMapped().iterator();
            symbols = new ArrayList<>();
            while (symbolIt.hasNext()) {
                Object obj = symbolIt.next();
                if (obj instanceof Gene) {
                    Gene g = (Gene) obj;
                    if (!g.getSymbol().contains("NEWGENE_"))
                        symbols.add(g.getSymbol());
                }
            }

        } else
            om.mapSymbols(symbols, this.inSpeciesTypeKey, integerIdType);
        return om;
    }
}
