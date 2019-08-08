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
    List<String> symbols=null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        String fmt = Utils.NVL(request.getParameter("fmt"), "full");
        this.request = request;
        this.response = response;
        req=new HttpRequestFacade(request);


        if (!req.getParameter("inSpecies").equals("")) {
            inSpeciesTypeKey = Integer.parseInt(req.getParameter("inSpecies"));
        }
        if (!req.getParameter("outSpecies").equals("")) {
            outSpeciesTypeKey = Integer.parseInt(req.getParameter("outSpecies"));
        }
        if (!req.getParameter("genes").equals("")) {
            symbols = Utils.symbolSplit(req.getParameter("genes"));
            symbols = symbols.stream().map(s-> s.toLowerCase()).collect(
                    Collectors.toList());
        } else symbols = null;
        inMapKey = Integer.parseInt(req.getParameter("inMapKey"));
        outMapKey = Integer.parseInt(req.getParameter("outMapKey"));

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
        List<String> symbolsNotFound = new ArrayList<>();

        ObjectMapper om = buildMapper(null,request,response);

        List<Integer> mappedIds = om.getMappedRgdIds();
        if(mappedIds.size() != 0 ) {
            List<MappedGene> rgdIds = gdao.getActiveMappedGenesByIds(this.inMapKey, mappedIds);
            Map<Integer, List<MappedGene>> geneMap = rgdIds.stream().collect(
                    Collectors.groupingBy(MappedGene -> MappedGene.getGene().getRgdId()));
            List<Integer> geneRgdIds = geneMap.keySet().stream().collect(Collectors.toList());

            Set<String> symbolsFound = new TreeSet<>();

            Map<Integer, Integer> orthologMap = null;
            Map<Integer, List<MappedGene>> mappedGeneMap = null;
            if (geneRgdIds.size() != 0) {
                List<Ortholog> orthologs = odao.getOrthologsForSourceRgdIds(geneRgdIds, outSpeciesTypeKey);
                orthologMap = orthologs.stream().collect(
                        Collectors.toMap(Ortholog::getSrcRgdId, Ortholog::getDestRgdId));

                List<Integer> orthologIds = orthologs.stream().map(Ortholog::getDestRgdId).collect(
                        Collectors.toList());
                List<MappedGene> positions = gdao.getActiveMappedGenesByIds(outMapKey, orthologIds);
                mappedGeneMap = positions.stream().collect(
                        Collectors.groupingBy(MappedGene -> MappedGene.getGene().getRgdId()));

                String inSpecies = SpeciesType.getCommonName(inSpeciesTypeKey);
                String outSpecies = SpeciesType.getCommonName(outSpeciesTypeKey);


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



            request.setAttribute("geneMap", geneMap);
            request.setAttribute("orthologMap", orthologMap);
            request.setAttribute("mappedGenes", mappedGeneMap);
        }

        request.setAttribute("report", report);


        request.setAttribute("inSpecies",inSpeciesTypeKey);
        request.setAttribute("outSpecies",outSpeciesTypeKey);
        request.setAttribute("inMapKey",inMapKey);
        request.setAttribute("outMapKey",outMapKey);
        request.setAttribute("genes",this.symbols);
        request.setAttribute("notFound",om.getLog());

    }

    private ObjectMapper buildMapper(String integerIdType,HttpServletRequest req,HttpServletResponse res) throws Exception{
        ObjectMapper om = new ObjectMapper();


        if (symbols == null  ) {
            om.mapPosition(req.getParameter("chr"), Integer.parseInt(req.getParameter("start")), Integer.parseInt(req.getParameter("stop")), inMapKey);
            Iterator symbolIt = om.getMapped().iterator();
            symbols = new ArrayList<>();
            while (symbolIt.hasNext()) {
                Object obj = symbolIt.next();
                if (obj instanceof Gene) {
                    Gene g = (Gene) obj;
                    symbols.add(g.getSymbol());
                }
            }

        } else
            om.mapSymbols(symbols, this.inSpeciesTypeKey, integerIdType);
        return om;
    }
}
