<%@ page import="edu.mcw.rgd.datamodel.*" %><%@ page import="edu.mcw.rgd.process.mapping.ObjectMapper" %><%@ page import="edu.mcw.rgd.dao.impl.MapDAO" %><%@ page import="edu.mcw.rgd.reporting.Record" %><%@ page import="edu.mcw.rgd.reporting.Report" %><%@ page import="edu.mcw.rgd.process.Utils" %><%@ page import="edu.mcw.rgd.dao.impl.GeneDAO" %><%@ page import="edu.mcw.rgd.dao.impl.AnnotationDAO" %><%@ page import="edu.mcw.rgd.process.mapping.MapManager" %><%@ page import="edu.mcw.rgd.web.HttpRequestFacade" %><%@ page import="edu.mcw.rgd.reporting.DelimitedReportStrategy" %>
<%@ page import="org.apache.poi.hssf.usermodel.HSSFWorkbook" %>
<%@ page import="org.apache.poi.hssf.usermodel.HSSFSheet" %>
<%@ page import="org.apache.poi.ss.usermodel.Row" %>
<%@ page import="org.apache.poi.ss.usermodel.Cell" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.FileOutputStream" %>
<%@ page import="java.io.File" %>
<%
    ObjectMapper om = (ObjectMapper) request.getAttribute("objectMapper");
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

    FileOutputStream output = new FileOutputStream(new File("C:\\tmp\\new.xls"));



    workbook.write(out);
    out.close();


%>


<%


     /*
        java.util.Map<String, Object[]> data = new HashMap<String, Object[]>();

        data.put("1", new Object[] {"Emp No.", "Name", "Salary"});
        data.put("2", new Object[] {1d, "John", 1500000d});
        data.put("3", new Object[] {2d, "Sam", 800000d});
        data.put("4", new Object[] {3d, "Dean", 700000d});

        Set<String> keyset = data.keySet();
        int rownum = 0;
        for (String key : keyset) {
            Row row = sheet.createRow(rownum++);
            Object [] objArr = data.get(key);
            int cellnum = 0;
            for (Object obj : objArr) {
                Cell cell = row.createCell(cellnum++);
                if(obj instanceof Date)
                    cell.setCellValue((Date)obj);
                else if(obj instanceof Boolean)
                    cell.setCellValue((Boolean)obj);
                else if(obj instanceof String)
                    cell.setCellValue((String)obj);
                else if(obj instanceof Double)
                    cell.setCellValue((Double)obj);
            }
        }

            FileOutputStream output = new FileOutputStream(new File("C:\\tmp\\new.xls"));
            workbook.write(output);
            out.close();
            out.println("Excel written successfully..");
       */
%>