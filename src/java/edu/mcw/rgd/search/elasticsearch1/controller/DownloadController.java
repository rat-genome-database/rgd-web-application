package edu.mcw.rgd.search.elasticsearch1.controller;



import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.jsoup.Jsoup;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;

import java.util.List;
import java.util.StringTokenizer;

/**
 * Created by jthota on 5/24/2017.
 */
public class DownloadController implements Controller {


    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

           String format=request.getParameter("format");
            String objectKey = request.getParameter("oKey");
            String rgdIds = request.getParameter("rgdIds");
            String mapKey = request.getParameter("mapKey");

            StringTokenizer tokenizer = new StringTokenizer(rgdIds, ",");
            List<Integer> rgdidsList = new ArrayList<>();
            List<String> accIds = new ArrayList<>();

            if (!objectKey.equals("0")) {

                while (tokenizer.hasMoreTokens()) {
                    rgdidsList.add(Integer.valueOf(tokenizer.nextToken()));
                }
            } else {

                while (tokenizer.hasMoreTokens()) {
                    accIds.add(tokenizer.nextToken());
                }
            }


            String obj = objectKey.equals("5") ? "Strains" : objectKey.equals("3") ? "SSLPs" : objectKey.equals("6") ? "QTLs" : objectKey.equals("7") ? "Variants" : objectKey.equals("12") ? "Reference" : objectKey.equals("0") ? "Ontology"
                    : objectKey.equals("1") ? "Genes":objectKey.equals("11")?"cell_lines":objectKey.equals("16")?"Promoters":"unknown";


        if(format!=null){
            if(format.equalsIgnoreCase("excel")) {
            HSSFWorkbook workbook = new HSSFWorkbook();
            HSSFSheet sheet = obj != null ? workbook.createSheet(obj) : null;
            int rownum = 0;
            int cellnum = 0;

            MapDAO mdao = new MapDAO();
            if(sheet!=null) {
            Row row = sheet.createRow(rownum++);
            Cell cell = row.createCell(cellnum++);
            if (!objectKey.equals("12") && !objectKey.equals("0")) {
                cell.setCellValue("RGD ID");
                cell = row.createCell(cellnum++);
                cell.setCellValue("Symbol");
                cell = row.createCell(cellnum++);
                if(objectKey.equals("11") || objectKey.equals("16")){
                   
                    cell.setCellValue("Name");
                }
                if(!objectKey.equals("11")) {
                    cell.setCellValue("Chromosome");
                    cell = row.createCell(cellnum++);
                    cell.setCellValue("Start Position");
                    cell = row.createCell(cellnum++);
                    cell.setCellValue("Stop Position");
                    cell = row.createCell(cellnum);
                    cell.setCellValue("Assembly");
                }
            } else {
                if (!(objectKey.equals("0"))) {
                    cell.setCellValue("RGD ID");
                    cell = row.createCell(cellnum++);
                    cell.setCellValue("Title");
                    cell = row.createCell(cellnum++);
                    cell.setCellValue("Abtract");
                    cell = row.createCell(cellnum++);
                    cell.setCellValue("Citation");
                        cell = row.createCell(cellnum);
                    cell.setCellValue("Link");

                } else {
                    cell.setCellValue("ACC_ID");
                    cell = row.createCell(cellnum++);
                    cell.setCellValue("Term");
                        cell = row.createCell(cellnum);
                    cell.setCellValue("Def");

                }

            }

                if (objectKey.equals("1")) {
                    GeneDAO geneDAO=new GeneDAO();
                    for (int rgdId : rgdidsList) {
                       Gene g= geneDAO.getGene(rgdId);
                        List<MapData> m = mdao.getMapData(rgdId, Integer.parseInt(mapKey));
                        cellnum = 0;
                        if (m.size() > 0) {
                            MapData md = m.get(0);

                            row = sheet.createRow(rownum++);
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(rgdId);
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(g.getSymbol());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(md.getChromosome());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(md.getStartPos());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(md.getStopPos());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(MapManager.getInstance().getMap(md.getMapKey()).getName());

                        } else {
                            row = sheet.createRow(rownum++);
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(rgdId);
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(g.getSymbol());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue("");
                            cell = row.createCell(cellnum++);
                            cell.setCellValue("");
                            cell = row.createCell(cellnum++);
                            cell.setCellValue("");
                            cell = row.createCell(cellnum++);
                            cell.setCellValue("");

                        }

                    }


                }

            if (objectKey.equals("5")) {
                StrainDAO sdao = new StrainDAO();
                List<Strain> strains = sdao.getStrains(rgdidsList);

                for (Strain s : strains) {
                        String strain=s.getSymbol();
                        String htmlStripped=Jsoup.parse(strain).text();
                    List<MapData> m = mdao.getMapData(s.getRgdId(), Integer.parseInt(mapKey));
                    cellnum = 0;
                    if (m.size() > 0) {
                        MapData md = m.get(0);

                        row = sheet.createRow(rownum++);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(s.getRgdId());
                        cell = row.createCell(cellnum++);
                            cell.setCellValue(s.getSymbol());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(md.getChromosome());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(md.getStartPos());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(md.getStopPos());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(MapManager.getInstance().getMap(md.getMapKey()).getName());

                    } else {
                        row = sheet.createRow(rownum++);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(s.getRgdId());
                        cell = row.createCell(cellnum++);
                            cell.setCellValue(htmlStripped);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");

                    }


                }
            }
            //=====================================================
                if (objectKey.equals("11") || objectKey.equals("16")) {

                    GenomicElementDAO genomicElementDAO = new GenomicElementDAO();
                    List<GenomicElement> elements = genomicElementDAO.getElementsByRgdIds(rgdidsList);

                    for (GenomicElement s : elements) {
                        String strain = s.getSymbol();
                        String htmlStripped = Jsoup.parse(strain).text();
                        List<MapData> m = mdao.getMapData(s.getRgdId(), Integer.parseInt(mapKey));
                        cellnum = 0;
                        if (m.size() > 0) {
                            MapData md = m.get(0);

                            row = sheet.createRow(rownum++);
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(s.getRgdId());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(s.getSymbol());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(s.getName());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(md.getChromosome());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(md.getStartPos());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(md.getStopPos());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(MapManager.getInstance().getMap(md.getMapKey()).getName());

                        } else {
                            row = sheet.createRow(rownum++);
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(s.getRgdId());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(htmlStripped);
                            cell = row.createCell(cellnum++);
                            cell.setCellValue(s.getName());
                            cell = row.createCell(cellnum++);
                            cell.setCellValue("");
                            cell = row.createCell(cellnum++);
                            cell.setCellValue("");
                            cell = row.createCell(cellnum++);
                            cell.setCellValue("");
                            cell = row.createCell(cellnum++);
                            cell.setCellValue("");

                        }


                    }
                }
                //=======================================================
            if (objectKey.equals("3")) {
                SSLPDAO sslpdao = new SSLPDAO();
                List<SSLP> sslps = new ArrayList<>();
                for (int rgdId : rgdidsList) {
                    SSLP sslp = new SSLP();
                    sslp = sslpdao.getSSLP(rgdId);
                    List<MapData> m = mdao.getMapData(rgdId, Integer.parseInt(mapKey));
                    cellnum = 0;
                    if (m.size() > 0) {
                        MapData md = m.get(0);

                        row = sheet.createRow(rownum++);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(rgdId);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(sslp.getName());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(md.getChromosome());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(md.getStartPos());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(md.getStopPos());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(MapManager.getInstance().getMap(md.getMapKey()).getName());

                    } else {
                        row = sheet.createRow(rownum++);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(rgdId);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(sslp.getName());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");

                    }

                }


            }
            if (objectKey.equals("6")) {
                QTLDAO qdao = new QTLDAO();
                List<QTL> qtls = new ArrayList<>();
                for (int rgdId : rgdidsList) {
                    QTL qtl = new QTL();
                    qtl = qdao.getQTL(rgdId);
                    List<MapData> m = mdao.getMapData(rgdId, Integer.parseInt(mapKey));
                    cellnum = 0;
                    if (m.size() > 0) {
                        MapData md = m.get(0);

                        row = sheet.createRow(rownum++);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(rgdId);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(qtl.getSymbol());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(md.getChromosome());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(md.getStartPos());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(md.getStopPos());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(MapManager.getInstance().getMap(md.getMapKey()).getName());

                    } else {
                        row = sheet.createRow(rownum++);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(rgdId);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(qtl.getSymbol());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");

                    }

                }


            }

            if (objectKey.equals("7")) {
                VariantInfoDAO vdao = new VariantInfoDAO();
                List<VariantInfo> variants = new ArrayList<>();
                for (int rgdId : rgdidsList) {
                    VariantInfo v = new VariantInfo();
                    v = vdao.getVariant(rgdId);
                    List<MapData> m = mdao.getMapData(rgdId, Integer.parseInt(mapKey));
                    cellnum = 0;
                    if (m.size() > 0) {
                        MapData md = m.get(0);

                        row = sheet.createRow(rownum++);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(rgdId);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(v.getSymbol());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(md.getChromosome());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(md.getStartPos());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(md.getStopPos());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(MapManager.getInstance().getMap(md.getMapKey()).getName());

                    } else {
                        row = sheet.createRow(rownum++);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(rgdId);
                        cell = row.createCell(cellnum++);
                        cell.setCellValue(v.getSymbol());
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");
                        cell = row.createCell(cellnum++);
                        cell.setCellValue("");
                            cell = row.createCell(cellnum);
                        cell.setCellValue("");

                    }

                }


            }
            if (objectKey.equals("12")) {
                ReferenceDAO rdao = new ReferenceDAO();
                List<Reference> refs = new ArrayList<>();


                for (int rgdId : rgdidsList) {
                    Reference r = new Reference();
                    cellnum = 0;
                    r = rdao.getReferenceByRgdId(rgdId);
                    row = sheet.createRow(rownum++);
                    cell = row.createCell(cellnum++);
                    cell.setCellValue(rgdId);
                    cell = row.createCell(cellnum++);
                    cell.setCellValue(r.getTitle());
                    cell = row.createCell(cellnum++);
                    cell.setCellValue(r.getRefAbstract());
                    cell = row.createCell(cellnum++);
                    cell.setCellValue(r.getCitation());
                        cell = row.createCell(cellnum);
                    cell.setCellValue(r.getUrlWebReference());

                }


            }
            if (objectKey.equals("0")) {
                OntologyXDAO xdao = new OntologyXDAO();
                for (String accId : accIds) {
                    cellnum = 0;
                    Term t = new Term();
                    t = xdao.getTermByAccId(accId);
                    row = sheet.createRow(rownum++);
                    cell = row.createCell(cellnum++);
                    cell.setCellValue(accId);
                    cell = row.createCell(cellnum++);
                    cell.setCellValue(t.getTerm());
                        cell = row.createCell(cellnum);
                    cell.setCellValue(t.getDefinition());

                }

            }
            }
           // long val = new Date().getTime();


            response.setContentType("application/msexcel");
            response.setHeader("Content-Disposition", "attachment;filename=" + obj  + ".xls");

            workbook.write(response.getOutputStream());
        }else{
            if(format.equalsIgnoreCase("tab")){
                response.setContentType("text/tab");
                response.setHeader("Content-Disposition", "inline; filename=report.tab" );
                String header=new String();
                if(!objectKey.equals("12") && !objectKey.equals("0")){
                   header="RGD ID\tSymbol\tchromosome\tStart Position\tStop Position\tAssembly\n";
                }else{
                 if(objectKey.equals("12")){
                     header="RGD ID\tTitle\tAbstract\tCitation\tSLink\n";
                 }else{
                     if(objectKey.equals("0")){
                         header="ACC_ID\tTern\tDef\n";
                }
            }
        }
                response.getWriter().write(header);
        }
        }


        }
        return null;
    }
}
