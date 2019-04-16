package edu.mcw.rgd.ortholog;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.OrthologDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.MappedGene;
import edu.mcw.rgd.datamodel.Ortholog;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.reporting.*;

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

    int inSpeciesTypeKey=-1;
    int outSpeciesTypeKey=-1;
    int inMapKey=-1;
    int outMapKey=-1;
    List<String> symbols=null;

    protected void init(HttpServletRequest request, HttpServletResponse response) {


        if (!request.getParameter("inSpecies").equals("")) {
            inSpeciesTypeKey = Integer.parseInt(request.getParameter("inSpecies"));
        }
        if (!request.getParameter("outSpecies").equals("")) {
            outSpeciesTypeKey = Integer.parseInt(request.getParameter("outSpecies"));
        }

        inMapKey = Integer.parseInt(request.getParameter("inMapKey"));
        outMapKey = Integer.parseInt(request.getParameter("outMapKey"));

        symbols = Utils.symbolSplit(request.getParameter("genes"));
    }
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        String fmt = Utils.NVL(request.getParameter("fmt"), "full");


        this.init(request,response);

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
        List<MappedGene> rgdIds = gdao.getActiveMappedGenes(this.inMapKey,this.symbols);
        Map<Integer, List<MappedGene>> geneMap = rgdIds.stream().collect(
                Collectors.groupingBy(MappedGene->MappedGene.getGene().getRgdId()));
        List<Integer> geneRgdIds = geneMap.keySet().stream().collect(Collectors.toList());


        List<Ortholog> orthologs = odao.getOrthologsForSourceRgdIds(geneRgdIds,outSpeciesTypeKey);
        Map<Integer, Integer> orthologMap = orthologs.stream().collect(
                Collectors.toMap(Ortholog::getSrcRgdId, Ortholog::getDestRgdId));

        List<Integer> orthologIds = orthologs.stream().map(Ortholog::getDestRgdId).collect(
                Collectors.toList());
        List<MappedGene> positions = gdao.getActiveMappedGenesByIds(outMapKey,orthologIds);
        Map<Integer, List<MappedGene>> mappedGeneMap = positions.stream().collect(
                Collectors.groupingBy(MappedGene->MappedGene.getGene().getRgdId()));

        String inSpecies = SpeciesType.getCommonName(inSpeciesTypeKey);
        String outSpecies = SpeciesType.getCommonName(outSpeciesTypeKey);

        Set<String> symbolsFound = new TreeSet<>();

        Report report = new Report();
        edu.mcw.rgd.reporting.Record rec = new edu.mcw.rgd.reporting.Record();
        rec.append(inSpecies+"_Rgd Id");
        rec.append(inSpecies+"_GeneSymbol");
        rec.append(inSpecies+"_Chromosome");
        rec.append(inSpecies+"_Position Start");
        rec.append(inSpecies+"_Position End");
        rec.append(inSpecies+"_Strand");
        rec.append(outSpecies+"_Rgd Id");
        rec.append(outSpecies+"_GeneSymbol");
        rec.append(outSpecies+"_Chromosome");
        rec.append(outSpecies+"_Position Start");
        rec.append(outSpecies+"_Position End");
        rec.append(outSpecies+"_Strand");
        report.append(rec);

        for (Integer rgdId: geneMap.keySet()) {
            symbolsFound.add(geneMap.get(rgdId).get(0).getGene().getSymbol().toLowerCase());
            if ((orthologMap.keySet().contains(rgdId))) {
                if ((mappedGeneMap.keySet().contains(orthologMap.get(rgdId)))) {
                    for (MappedGene inputGene : geneMap.get(rgdId)) {
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
                    }
                }
            }
        }
        List<String> symbolsNotFound = new ArrayList<>();
        for(Iterator<String> iterator = symbols.iterator(); iterator.hasNext();) {
            String symbol = iterator.next();
            if(!symbolsFound.contains(symbol.toLowerCase())){
                symbolsNotFound.add(symbol);
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
        request.setAttribute("notFound",symbolsNotFound);

    }
}
