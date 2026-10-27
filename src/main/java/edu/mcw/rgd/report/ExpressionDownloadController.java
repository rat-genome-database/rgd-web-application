package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.datamodel.Gene;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.json.JSONObject;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.io.BufferedReader;

public class ExpressionDownloadController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        try {
            StringBuilder buffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
                buffer.append(System.lineSeparator());
            }
            JSONObject obj = new JSONObject(buffer.toString());
            reader.close();
            // probably send rgdId
            int rgdId = obj.getInt("rgdId");
            GeneDAO geneDAO = new GeneDAO();
            Gene g = geneDAO.getGene(rgdId);
            request.setAttribute("geneSymbol",g.getSymbol());
            String term = obj.getString("term");
            request.setAttribute("rgdId",rgdId);
            request.setAttribute("termAcc", term); //"UBERON:9999999"
            // The assembly the report page was showing. A sample aligned to several assemblies is
            // one expression record per assembly, so without this the csv repeats every sample
            // once per assembly and does not match the counts the user clicked. Optional: an
            // older page, or a gene with one assembly, sends nothing and gets every assembly.
            if( obj.has("mapKey") && !obj.isNull("mapKey") ) {
                String mapKey = obj.get("mapKey").toString().trim();
                if( !mapKey.isEmpty() ) {
                    request.setAttribute("mapKey", Integer.valueOf(mapKey));
                }
            }
//            String rsId = obj.get("rsId").toString();
//            request.setAttribute("rsId", rsId);
        }
        catch (Exception e){
            System.out.println(e);
            return null;
        }
        return new ModelAndView("/WEB-INF/jsp/report/gene/expressionDownload.jsp");
    }
}
