package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.DataSourceFactory;
import edu.mcw.rgd.dao.impl.VariantInfoDAO;
import edu.mcw.rgd.dao.impl.variants.CarpenovoVariantInfoDAO;
import edu.mcw.rgd.dao.impl.variants.VariantDAO;
import edu.mcw.rgd.datamodel.SearchResult;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.datamodel.VariantResult;
import edu.mcw.rgd.datamodel.VariantSearchBean;
import edu.mcw.rgd.datamodel.variants.VariantIndex;
import edu.mcw.rgd.vv.DetailController;
import edu.mcw.rgd.vv.VariantController;
import org.springframework.web.servlet.ModelAndView;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: Feb 22, 2012
 */
public class ClinVarReportController extends ReportController {
    public String getViewUrl() throws Exception {
        return "cnVariants/main.jsp";
    }

    public Object getObject(int rgdId) throws Exception{
        return new VariantDAO().getVariant(rgdId);
    }
}