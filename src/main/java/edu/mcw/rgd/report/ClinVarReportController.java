package edu.mcw.rgd.report;

import com.google.gson.Gson;
import edu.mcw.rgd.dao.impl.VariantInfoDAO;
import edu.mcw.rgd.dao.impl.variants.VariantDAO;
import edu.mcw.rgd.datamodel.VariantInfo;
import edu.mcw.rgd.datamodel.variants.VariantMapData;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Feb 22, 2012
 */
public class ClinVarReportController extends ReportController {
   private String url;
    public String getViewUrl() throws Exception {
        return url;
    }

    public Object getObject(int rgdId) throws Exception{
        VariantMapData variant= new VariantDAO().getVariant(rgdId);
        if(variant==null) {
            VariantInfoDAO variantDAO = new VariantInfoDAO();
            VariantInfo variantInfo = variantDAO.getVariant(rgdId);
            this.url="variant/main.jsp";
            return variantInfo;
        }else {
            this.url="cnVariants/main.jsp";
            return variant;
        }

    }
}