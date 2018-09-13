package edu.mcw.rgd.gviewer;

import edu.mcw.rgd.dao.impl.AnnotationDAO;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.MapData;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 * To change this template use File | Settings | File Templates.
 */
public class DownloadController extends GviewerController {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        this.init(request, response);

        ObjectMapper om = new ObjectMapper();
        try {

            om = this.buildMapper(req.getParameter("idType"));

        }catch (Exception e) {
            error.add(e.getMessage());
        }

        request.setAttribute("objectMapper", om);
        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);




           // ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");
    AnnotationDAO adao = new AnnotationDAO();
    GeneDAO gdao = new GeneDAO();
    HttpRequestFacade req = new HttpRequestFacade(request);
    int speciesTypeKey= edu.mcw.rgd.datamodel.SpeciesType.getSpeciesTypeKeyForMap(Integer.parseInt(request.getParameter("mapKey")));

    HSSFWorkbook workbook = new HSSFWorkbook();
    HSSFSheet sheet = workbook.createSheet("Genes");

    int rownum =0;
    int cellnum = 0;

    MapDAO mdao = new MapDAO();

    String errors = "";
    Report r = new Report();

    Row row = sheet.createRow(rownum++);
    Cell cell = row.createCell(cellnum++);
    cell.setCellValue("Symbol");
    cell = row.createCell(cellnum++);
    cell.setCellValue("Chromosome");
    cell = row.createCell(cellnum++);
    cell.setCellValue("Start Position");
    cell = row.createCell(cellnum++);
    cell.setCellValue("Stop Position");
    cell = row.createCell(cellnum++);
    cell.setCellValue("Assembly");

   for (String match: Utils.symbolSplit(om.getMappedAsString())) {
     try {

         Gene gene = gdao.getGenesBySymbol(match, speciesTypeKey);

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
             cell.setCellValue(gene.getSymbol());
             cell = row.createCell(cellnum++);
             cell.setCellValue(md.getChromosome());
             cell = row.createCell(cellnum++);
             cell.setCellValue(md.getStartPos());
             cell = row.createCell(cellnum++);
             cell.setCellValue(md.getStopPos());
             cell = row.createCell(cellnum++);
             cell.setCellValue(MapManager.getInstance().getMap(md.getMapKey()).getName());

         }
     }catch (Exception e) {
         e.printStackTrace();
     }

   }

    response.setContentType("application/msexcel");
     response.setHeader( "Content-Disposition", "attachment;filename=rgd_gene_download.xls" );

//    response.getOutputStream()

    workbook.write(response.getOutputStream());
  //  out.close();



        return null;

        //return new ModelAndView("/WEB-INF/jsp/gviewer/download.jsp","hello", null);
    }



}