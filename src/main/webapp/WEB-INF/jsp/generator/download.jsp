<%@ page import="edu.mcw.rgd.datamodel.*" %><%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %><%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %><%@ page import="edu.mcw.rgd.reporting.Record" %><%@ page import="edu.mcw.rgd.reporting.Report" %><%@ page import="edu.mcw.rgd.process.Utils" %><%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %><%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %><%@ page import="edu.mcw.rgd.process.mapping.MapManager" %><%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %><%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%@ page import="org.apache.poi.hssf.usermodel.HSSFWorkbook" %>
<%@ page import="org.apache.poi.hssf.usermodel.HSSFSheet" %>
<%@ page import="org.apache.poi.ss.usermodel.Row" %>
<%@ page import="org.apache.poi.ss.usermodel.Cell" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.FileOutputStream" %>
<%@ page import="java.io.File" %>
<%
    //ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");

    HashMap<Integer,Object> allObjects = (HashMap<Integer,Object>) request.getAttribute("allObjects");

    Integer oKey=Integer.parseInt(request.getParameter("oKey"));

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
         }else if (oKey == 5) {
            //strain
             Strain s = (Strain)allObjects.get(it.next());

             /*
             String assembly = req.getParameter("mapKey");
             if (assembly.equals("")) {
                 assembly = mdao.getPrimaryRefAssembly(speciesTypeKey).getKey() + "";
             }
             */

             //List<MapData> mdList = mdao.getMapData(gene.getRgdId(),Integer.parseInt(assembly));

             //cellnum=0;
             //if (mdList.size() > 0) {
                // MapData md = mdList.get(0);

                 row = sheet.createRow(rownum++);
                 cell = row.createCell(cellnum++);
                 cell.setCellValue(s.getRgdId());
                 cell = row.createCell(cellnum++);
                 cell.setCellValue(s.getSymbol());
             /*
                 cell = row.createCell(cellnum++);
                 cell.setCellValue(md.getStartPos());
                 cell = row.createCell(cellnum++);
                 cell.setCellValue(md.getStopPos());
                 cell = row.createCell(cellnum++);
                 cell.setCellValue(MapManager.getInstance().getMap(md.getMapKey()).getName());
              */
             //}

         }else if (oKey == 6) {
            //qtl

            //System.out.println("im here");

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
                 cell.setCellValue(qtl.getSymbol());
                 cell = row.createCell(cellnum++);
                 cell.setCellValue(md.getChromosome());
                 cell = row.createCell(cellnum++);
                 cell.setCellValue(md.getStartPos());
                 cell = row.createCell(cellnum++);
                 cell.setCellValue(md.getStopPos());
                 cell = row.createCell(cellnum++);
                 cell.setCellValue(MapManager.getInstance().getMap(md.getMapKey()).getName());

             }

         }
     }catch (Exception e) {
         e.printStackTrace();
     }

   }

    //FileOutputStream out = new FileOutputStream(new File("C:\\tmp\\new.xls"));

    workbook.write(response.getOutputStream());
    out.close();

%>
