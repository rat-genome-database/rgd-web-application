package edu.mcw.rgd.search;


import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;


public class SearchByPosController implements Controller {



    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String fmt = Utils.NVL(request.getParameter("fmt"), "full");

        String path = "/WEB-INF/jsp/search/";
        if(fmt.equalsIgnoreCase("csv")) {

            String chr = request.getParameter("chr");
            int start =  Integer.valueOf(request.getParameter("start"));
            int stop = Integer.valueOf(request.getParameter("stop"));
            int mapKey = Integer.valueOf(request.getParameter("mapKey"));
            String objType = request.getParameter("objType");
            Report report = new Report();
            Record header = new Record();
            header.append("RGD ID");
            header.append("Symbol");
            header.append("Name");
            header.append("Type");
            header.append("Chr");
            header.append("Start");
            header.append("Stop");
            report.append(header);
            if(objType.equalsIgnoreCase("gene") || objType.equalsIgnoreCase("all")) {
                GeneDAO gdao = new GeneDAO();

                List<MappedGene> genes = gdao.getActiveMappedGenes(chr,start,stop,mapKey);

                for(MappedGene gene: genes){
                    Record record = new Record();
                    record.append(String.valueOf(gene.getGene().getRgdId()));
                    record.append(gene.getGene().getSymbol());
                    record.append(gene.getGene().getName());
                    record.append("GENE");
                    record.append(gene.getChromosome());
                    record.append(String.valueOf(gene.getStart()));
                    record.append(String.valueOf(gene.getStop()));
                    report.append(record);
                }

            }
            if(objType.equalsIgnoreCase("qtl") || objType.equalsIgnoreCase("all")){
                QTLDAO qdao = new QTLDAO();
                List<MappedQTL> qtls = qdao.getActiveMappedQTLs(chr,start,stop,mapKey);
                for(MappedQTL qtl: qtls){
                    Record record = new Record();
                    record.append(String.valueOf(qtl.getQTL().getRgdId()));
                    record.append(qtl.getQTL().getSymbol());
                    record.append(qtl.getQTL().getName());
                    record.append("QTL");
                    record.append(qtl.getChromosome());
                    record.append(String.valueOf(qtl.getStart()));
                    record.append(String.valueOf(qtl.getStop()));
                    report.append(record);
                }

            }
            if(objType.equalsIgnoreCase("sslp") || objType.equalsIgnoreCase("all")){
                SSLPDAO sdao = new SSLPDAO();
                List<MappedSSLP> sslps = sdao.getActiveMappedSSLPs(chr,start,stop,mapKey);
                for(MappedSSLP sslp: sslps){
                    Record record = new Record();
                    record.append(String.valueOf(sslp.getSSLP().getRgdId()));
                    record.append(sslp.getSSLP().getName());
                    record.append(sslp.getSSLP().getName());
                    record.append("SSLP");
                    record.append(sslp.getChromosome());
                    record.append(String.valueOf(sslp.getStart()));
                    record.append(String.valueOf(sslp.getStop()));
                    report.append(record);
                }

            }
            if (objType.equalsIgnoreCase("strain") || objType.equalsIgnoreCase("all")){
                StrainDAO strainDAO = new StrainDAO();
                List<MappedStrain> strains = strainDAO.getActiveMappedStrainPositions(chr,start,stop,mapKey);
                for (MappedStrain s : strains){
                    Record record = new Record();
                    record.append(String.valueOf(s.getStrain().getRgdId()));
                    record.append(s.getStrain().getSymbol());
                    record.append(s.getStrain().getName());
                    record.append("STRAIN");
                    record.append(s.getChromosome());
                    record.append(String.valueOf(s.getStart()) );
                    record.append(String.valueOf(s.getStop()) );
                    report.append(record);
                }
            }
            request.setAttribute("report",report);
            return new ModelAndView(path + "report_csv.jsp");
        }
        return new ModelAndView(path + "searchByPosition.jsp");
        }
    }
