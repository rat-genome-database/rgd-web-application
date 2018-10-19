package edu.mcw.rgd.models;

import edu.mcw.rgd.dao.impl.GeneticModelsDAO;
import edu.mcw.rgd.datamodel.models.GeneticModel;
import edu.mcw.rgd.process.Utils;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by jthota on 6/22/2017.
 */
public class DownloadController extends GeneticModelsController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        GeneticModelsDAO geneticModelsDAO= new GeneticModelsDAO();
        List<GeneticModel> strains = geneticModelsDAO.getGerrcModels();
        List<GeneticModel> strainsWithAliasesInfo= this.getStrainWithAliases(strains);
        Collections.sort(strainsWithAliasesInfo, new Comparator<GeneticModel>() {
            @Override
            public int compare(GeneticModel o1, GeneticModel o2) {
                return Utils.stringsCompareToIgnoreCase(o1.getGeneSymbol(), o2.getGeneSymbol());
            }
        });
        HSSFWorkbook workbook = new HSSFWorkbook();
        HSSFSheet sheet = workbook.createSheet("models");
        int rownum = 0;
        int hcellnum=0;
        Row headerRow = sheet.createRow(rownum++);
        Cell cell= headerRow.createCell(hcellnum++);
        cell.setCellValue("Gene");
        cell=headerRow.createCell(hcellnum++);
        cell.setCellValue("Gene Symbol");
        cell=headerRow.createCell(hcellnum++);
        cell.setCellValue("Gene_RGD_ID");

        cell=headerRow.createCell(hcellnum++);
        cell.setCellValue("Allele Symbol");
        cell=headerRow.createCell(hcellnum++);
        cell.setCellValue("Allele_RGD_ID");

        cell=headerRow.createCell(hcellnum++);
        cell.setCellValue("Strain Symbol");
        cell=headerRow.createCell(hcellnum++);
        cell.setCellValue("Strain_RGD_ID");

        cell=headerRow.createCell(hcellnum++);
        cell.setCellValue("Background Strain");
        cell=headerRow.createCell(hcellnum++);
        cell.setCellValue("Background_strain_rgd_id");

        cell=headerRow.createCell(hcellnum++);
        cell.setCellValue("Method");

        cell=headerRow.createCell(hcellnum++);
        cell.setCellValue("Availability");
        cell=headerRow.createCell(hcellnum++);
        cell.setCellValue("Source");





            for(GeneticModel m: strainsWithAliasesInfo){
                Row row = sheet.createRow(rownum++);
                int cellnum = 0;
                Cell bcell = row.createCell(cellnum++);
                bcell.setCellValue(m.getGene());

                bcell=row.createCell(cellnum++);
                bcell.setCellValue(m.getGeneSymbol());

                bcell=row.createCell(cellnum++);
                bcell.setCellValue(m.getGeneRgdId());

                bcell=row.createCell(cellnum++);
                bcell.setCellValue(m.getAlleleSymbol());

                bcell=row.createCell(cellnum++);
                bcell.setCellValue(m.getAlleleRgdId());

                bcell=row.createCell(cellnum++);
                bcell.setCellValue(m.getStrainSymbol());

               bcell=row.createCell(cellnum++);
               bcell.setCellValue(m.getStrainRgdId());

                bcell=row.createCell(cellnum++);
                bcell.setCellValue(m.getBackgroundStrain());

                bcell=row.createCell(cellnum++);
                bcell.setCellValue(m.getBackgroundStrainRgdId());

                bcell=row.createCell(cellnum++);
                bcell.setCellValue(m.getMethod());

                bcell=row.createCell(cellnum++);
                bcell.setCellValue(m.getAvailability());

                bcell=row.createCell(cellnum++);
                bcell.setCellValue(m.getSource());


            }
        long val = new Date().getTime();


        response.setContentType("application/msexcel");
        response.setHeader( "Content-Disposition", "attachment;filename="+"models"+"_" + val + ".xls" );

        workbook.write(response.getOutputStream());
        return null;

    }
}
