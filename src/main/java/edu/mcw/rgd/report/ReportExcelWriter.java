package edu.mcw.rgd.report;

import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;

import java.util.Iterator;

/**
 * A {@link Report} written to the response as an .xlsx download.
 *
 * It is not a {@link edu.mcw.rgd.reporting.ReportStrategy} - that interface returns a String, and a
 * workbook is binary - so every caller that wants one writes the response itself and returns a null
 * ModelAndView. This is the shared body of that: the search reports (RGDSearchController, fmt 7)
 * and the miRNA target report (MirnaTargetsController, fmt=excel) hand it the same Report their csv
 * format already renders, so the spreadsheet carries the section's own columns.
 *
 * .xlsx rather than .xls because a .xls sheet caps at 65,536 rows and these reports are not small -
 * the miRNA targets of one microRNA gene run to 8,739. SXSSF keeps a window of rows in memory and
 * streams the rest to a temp file, so a long report costs what a short one costs.
 */
public class ReportExcelWriter {

    /** how many rows SXSSF keeps in memory; the rest are flushed to a temp file */
    private static final int ROW_WINDOW = 100;

    /**
     * @param sheetName name for the single sheet, e.g. "Markers"
     * @param fileName  download name, already safe for a Content-disposition header -
     *                  see {@link #fileName}
     */
    public static void write(HttpServletResponse response, Report report, String sheetName, String fileName)
            throws Exception {

        SXSSFWorkbook workbook = new SXSSFWorkbook(ROW_WINDOW);
        try {
            Sheet sheet = workbook.createSheet(safeSheetName(sheetName));

            Font bold = workbook.createFont();
            bold.setBold(true);
            CellStyle headerStyle = workbook.createCellStyle();
            headerStyle.setFont(bold);

            // a Report's first record is its header row, which is why the style goes on row 0
            // rather than being written separately
            int rowNum = 0;
            for( Iterator recIt = report.iterator(); recIt.hasNext(); rowNum++ ) {
                Record rec = (Record) recIt.next();
                Row row = sheet.createRow(rowNum);
                int cellNum = 0;
                for( Iterator fieldIt = rec.iterator(); fieldIt.hasNext(); ) {
                    Cell cell = row.createCell(cellNum++);
                    cell.setCellValue(Utils.defaultString((String) fieldIt.next()));
                    if( rowNum==0 ) {
                        cell.setCellStyle(headerStyle);
                    }
                }
            }

            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-disposition", "attachment;filename=\""+fileName+"\"");
            workbook.write(response.getOutputStream());
        } finally {
            // the streamed rows sit in a temp file until this runs
            workbook.dispose();
        }
    }

    /**
     * A sheet name Excel will accept. POI rejects / \ ? * [ ] : outright and caps the name at 31
     * characters, so a caller deriving one from something else - a view name like
     * "advanced/cellLines.jsp", say - would otherwise take the whole download down with an
     * IllegalArgumentException. Applied inside {@link #write}, so no caller has to remember.
     */
    static String safeSheetName(String sheetName) {
        String clean = Utils.defaultString(sheetName).replaceAll("[/\\\\?*\\[\\]:]", " ").trim();
        if( clean.isEmpty() ) {
            return "Report";
        }
        return clean.length() > 31 ? clean.substring(0, 31) : clean;
    }

    /**
     * A download name a Content-disposition header can carry. A gene symbol or a search term can
     * hold characters - a quote, a semicolon, a newline - that would break the header or inject
     * another one, so only word characters, dot and dash survive.
     *
     * @param base     the identifying part, e.g. a gene symbol or an object type
     * @param fallback used when nothing of `base` survives sanitising
     */
    public static String fileName(String base, String fallback, String suffix) {
        String clean = Utils.defaultString(base).replaceAll("[^A-Za-z0-9._-]", "");
        return (clean.isEmpty() ? fallback : clean) + suffix + ".xlsx";
    }
}
