package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.StudySampleMetadataDAO;
import edu.mcw.rgd.datamodel.StudySampleMetadata;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.PrintWriter;
import java.util.List;

public class ExpressionStudyDownloadController extends ReportController {

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        String strRgdId = req.getParameter("id");
        strRgdId = strRgdId.replaceAll("RGD:", "");
        strRgdId = strRgdId.replaceAll("\\)", "");

        try {
            int studyId = Integer.parseInt(strRgdId);

            StudySampleMetadataDAO dao = new StudySampleMetadataDAO();
            List<StudySampleMetadata> allData = dao.getStudySampleMetadata(studyId);

            response.setContentType("text/csv");
            response.setCharacterEncoding("UTF-8");
            String filename = "ExpressionStudy_" + studyId + "_metadata.csv";
            response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

            PrintWriter writer = response.getWriter();

            writer.println("\"geo_accession\",\"Tissue\",\"Strain\",\"Sex\",\"Computed Sex\",\"Age(in days)\",\"Life Stage\",\"Experimental_Conditions\",\"Cell Type\",\"Dose\",\"Duration\",\"Application Method\",\"Notes\"");

            for (StudySampleMetadata data : allData) {
                StringBuilder row = new StringBuilder();

                // 1. GEO Accession
                row.append(escapeCsvField(data.getGeoSampleAcc() != null ? data.getGeoSampleAcc() : "")).append(",");

                // 2. Tissue
                row.append(escapeCsvField(data.getTissue() != null ? data.getTissue() : "")).append(",");

                // 3. Strain
                row.append(escapeCsvField(data.getStrain() != null ? data.getStrain() : "")).append(",");

                // 4. Sex
                row.append(escapeCsvField(data.getSex() != null ? data.getSex() : "")).append(",");

                // 5. Computed Sex
                row.append(escapeCsvField(data.getComputedSex() != null ? data.getComputedSex() : "")).append(",");

                // 6. Age
                String ageText = "";
                Double lowBound = data.getAgeDaysFromDobLowBound();
                Double highBound = data.getAgeDaysFromDobHighBound();
                if (lowBound != null && highBound != null) {
                    if (lowBound.equals(highBound)) {
                        ageText = String.valueOf(lowBound.intValue());
                    } else {
                        ageText = lowBound.intValue() + "-" + highBound.intValue();
                    }
                }
                row.append(escapeCsvField(ageText)).append(",");

                // 7. Life Stage
                row.append(escapeCsvField(data.getLifeStage() != null ? data.getLifeStage() : "")).append(",");

                // 8. Experimental Conditions
                row.append(escapeCsvField(data.getExperimentalConditions() != null ? data.getExperimentalConditions() : "")).append(",");

                // 9. Cell Type
                row.append(escapeCsvField(data.getCellType() != null ? data.getCellType() : "")).append(",");

                // 10. Dose
                String doseText = "";
                Double minVal = data.getExpCondAssocValueMin();
                Double maxVal = data.getExpCondAssocValueMax();
                String units = data.getExpCondAssocUnits();
                if (minVal != null && maxVal != null && units != null) {
                    if (minVal.equals(maxVal)) {
                        doseText = minVal + " " + units;
                    } else {
                        doseText = minVal + " " + units + " - " + maxVal + " " + units;
                    }
                }
                row.append(escapeCsvField(doseText)).append(",");

                // 11. Duration
                String durationText = "";
                Double durLow = data.getExpCondDurSecLowBound();
                Double durHigh = data.getExpCondDurSecHighBound();
                if (durLow != null && durHigh != null && durLow != 0.0) {
                    durationText = durLow.equals(durHigh)
                            ? durLow.toString()
                            : durLow + " - " + durHigh;
                }
                row.append(escapeCsvField(durationText)).append(",");

                // 12. Application Method
                row.append(escapeCsvField(data.getExpCondApplicationMethod() != null ? data.getExpCondApplicationMethod() : "")).append(",");

                // 13. Notes
                row.append(escapeCsvField(data.getExpCondNotes() != null ? data.getExpCondNotes() : ""));

                writer.println(row.toString());
            }

            writer.flush();
            writer.close();

        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid study ID");
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error generating CSV: " + e.getMessage());
        }

        return null;
    }

    /**
     * Escapes a field for CSV format by wrapping in quotes and escaping internal quotes
     */
    private String escapeCsvField(Object value) {
        if (value == null) {
            return "\"\"";
        }

        String str = value.toString();
        // If field contains comma, quote, or newline, wrap in quotes and escape internal quotes
        if (str.contains(",") || str.contains("\"") || str.contains("\n") || str.contains("\r")) {
            str = str.replace("\"", "\"\""); // Escape quotes by doubling them
            return "\"" + str + "\"";
        } else {
            return "\"" + str + "\""; // Always wrap in quotes for consistency
        }
    }

    @Override
    public String getViewUrl() throws Exception {
        return null;
    }

    @Override
    public Object getObject(int rgdId) throws Exception {
        return null;
    }
}