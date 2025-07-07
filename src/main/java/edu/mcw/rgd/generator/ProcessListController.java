package edu.mcw.rgd.generator;

import com.google.gson.Gson;
import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.generator.GeneratorCommandParser;
import edu.mcw.rgd.process.generator.OLGAParser;
import edu.mcw.rgd.process.generator.OLGAResult;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.commons.collections4.ListUtils;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class ProcessListController implements Controller {

    protected HttpServletRequest request = null;
    protected HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        this.request=request;
        this.response=response;

        HttpRequestFacade req = new HttpRequestFacade(request);

        OLGAParser op = new OLGAParser();

        int oKey=1;
        if(request.getParameter("oKey")!=null){
            oKey=Integer.parseInt(request.getParameter("oKey"));
        }

        int mapKey = MapManager.getInstance().getReferenceAssembly(SpeciesType.RAT).getKey();

        try {
            mapKey = Integer.parseInt(request.getParameter("mapKey"));
        }catch(Exception e) {
        }

        String opl = "";
        if (req.getParameter("a") != null) {
            opl= req.getParameter("a");
        }

        OLGAResult or = op.parse(oKey,mapKey, opl);
        request.setAttribute("mapKey",mapKey);
        request.setAttribute("accIds", or.getAccIds());
        request.setAttribute("om", or.getOm());
        request.setAttribute("operators", or.getOperators());
        request.setAttribute("objectSymbols", or.getObjectSymbols());
        request.setAttribute("omLog",or.getOmLog());
        request.setAttribute("resultSet",or.getResultSet());
        request.setAttribute("exclude",or.getExclude());
        request.setAttribute("messages", or.getMessages());
        request.setAttribute("oKey", oKey);

        String action = req.getParameter("act");

        if (action.equals("excel")) {

            this.writeExcelFile(oKey,or.getResultSet(),or);

            return null;
        }else if (action.equals("browse")) {
            return new ModelAndView("/WEB-INF/jsp/generator/gviewer.jsp");
        }else if (action.equals("json")) {
            Gson gson = new Gson();

            //response.getWriter().write(gson.toJson(or.getResultSet()));

            String json = gson.toJson(or.getResultSet());
            byte[] jsonBytes = json.getBytes(StandardCharsets.UTF_8);

            response.setContentType("application/json;charset=UTF-8");
            response.setContentLength(jsonBytes.length); // ✅ Ensures Apache can cache it
            response.getOutputStream().write(jsonBytes);

            return null;
        }else {
            return new ModelAndView("/WEB-INF/jsp/generator/list.jsp");
        }

    }


    public void writeExcelFile(int oKey, HashMap allObjects, OLGAResult or) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);
        int speciesTypeKey= edu.mcw.rgd.datamodel.SpeciesType.getSpeciesTypeKeyForMap(Integer.parseInt(request.getParameter("mapKey")));

        HSSFWorkbook workbook = new HSSFWorkbook();
        HSSFSheet sheet = workbook.createSheet("Genes");

        int rownum =0;
        int cellnum = 0;

        MapDAO mdao = new MapDAO();
        OntologyXDAO odao = new OntologyXDAO();
        //String errors = "";
        //Report r = new Report();

        String union = 	"\u222A";
        String intersect = "\u2229";
        String subtract = "-";
        List<String> accIds =or.getAccIds();
        Row row = sheet.createRow(rownum++);
        if (!or.getAccIds().isEmpty()) {
            Cell c = row.createCell(0);
            String title = "";
            for (int i = 0; i < accIds.size(); i++) {
                String accId = accIds.get(i);
                String identifier = null;
                if (accId.toLowerCase().startsWith("chr")) {
                    identifier=accId;
                }else if (accId.toLowerCase().startsWith("lst")) {
                    identifier = "User List";
                } else if (accId.toLowerCase().startsWith("qtl")) {
                    identifier = accId.substring(4);
                } else {
                    Term t = odao.getTermByAccId(accId);
                    identifier = t.getTerm();
                }
                if (i != 0) {
                    switch (or.getOperators().get(i)) {
                        case "~":
                            title += " " + union;
                            break;
                        case "^":
                            title += " " + subtract;
                            break;
                        case "!":
                            title += " " + intersect;
                            break;
                    }
                    title += " " + identifier + " )";
                } else {
                    for (int j = 1; j < accIds.size(); j++)
                        title += "( ";
                    title += identifier;
                }
            }
            c.setCellValue(title);
        }
        row = sheet.createRow(rownum++);
        Cell cell = row.createCell(cellnum++);
        cell.setCellValue("RGD ID");
        cell = row.createCell(cellnum++);
        cell.setCellValue("Symbol");
        cell = row.createCell(cellnum++);
        cell.setCellValue("Chromosome");
        cell = row.createCell(cellnum++);
        cell.setCellValue("Start Position");
        cell = row.createCell(cellnum++);
        cell.setCellValue("Stop Position");
        cell = row.createCell(cellnum++);
        cell.setCellValue("Assembly");

        Iterator it = allObjects.keySet().iterator();
        while (it.hasNext()) {

         try {

             if (oKey == 1) {


                 Gene gene = (Gene)allObjects.get(it.next());

                 String assembly = req.getParameter("mapKey");
                 if (assembly.equals("")) {
                     assembly = mdao.getPrimaryRefAssembly(speciesTypeKey).getKey() + "";
                 }

                 List<MapData> mdList = mdao.getMapData(gene.getRgdId(),Integer.parseInt(assembly));

                 cellnum=0;
                 if (mdList.size() > 0) {
                     MapData md = mdList.get(0);

                     row = sheet.createRow(rownum++);
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(gene.getRgdId());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(gene.getSymbol());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(md.getChromosome());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(md.getStartPos());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(md.getStopPos());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(MapManager.getInstance().getMap(md.getMapKey()).getName());

                 }else {
                     row = sheet.createRow(rownum++);
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(gene.getRgdId());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(gene.getSymbol());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue("");
                     cell = row.createCell(cellnum++);
                     cell.setCellValue("");
                     cell = row.createCell(cellnum++);
                     cell.setCellValue("");
                     cell = row.createCell(cellnum++);
                     cell.setCellValue("");

                 }
             }else if (oKey == 5) {

                 Strain strain = (Strain)allObjects.get(it.next());

                 String assembly = req.getParameter("mapKey");
                 if (assembly.equals("")) {
                     assembly = mdao.getPrimaryRefAssembly(speciesTypeKey).getKey() + "";
                 }

                 List<MapData> mdList = mdao.getMapData(strain.getRgdId(),Integer.parseInt(assembly));

                 cellnum=0;
                 if (mdList.size() > 0) {
                     MapData md = mdList.get(0);

                     row = sheet.createRow(rownum++);
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(strain.getRgdId());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(strain.getSymbol());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(md.getChromosome());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(md.getStartPos());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(md.getStopPos());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(MapManager.getInstance().getMap(md.getMapKey()).getName());

                 }else {
                     row = sheet.createRow(rownum++);
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(strain.getRgdId());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(strain.getSymbol());
                     cell = row.createCell(cellnum++);
                     cell.setCellValue("");
                     cell = row.createCell(cellnum++);
                     cell.setCellValue("");
                     cell = row.createCell(cellnum++);
                     cell.setCellValue("");
                     cell = row.createCell(cellnum++);
                     cell.setCellValue("");

                 }

             }else if (oKey == 6) {
                //qtl

                 QTL qtl = (QTL)allObjects.get(it.next());

                 String assembly = req.getParameter("mapKey");
                 if (assembly.equals("")) {
                     assembly = mdao.getPrimaryRefAssembly(speciesTypeKey).getKey() + "";
                 }

                 List<MapData> mdList = mdao.getMapData(qtl.getRgdId(),Integer.parseInt(assembly));

                 cellnum=0;
                 if (mdList.size() > 0) {
                     MapData md = mdList.get(0);

                     row = sheet.createRow(rownum++);
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(qtl.getRgdId());
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

                 }else {
                     row = sheet.createRow(rownum++);
                     cell = row.createCell(cellnum++);
                     cell.setCellValue(qtl.getRgdId());
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

         }catch (Exception e) {
             e.printStackTrace();
         }

       }

        long val = new Date().getTime();


        response.setContentType("application/msexcel");
        response.setHeader( "Content-Disposition", "attachment;filename=olga_" + val + ".xls" );

        workbook.write(response.getOutputStream());
    }

}