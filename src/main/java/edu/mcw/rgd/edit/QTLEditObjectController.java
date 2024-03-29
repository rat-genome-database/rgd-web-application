package edu.mcw.rgd.edit;

import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;

import jakarta.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;

/**
 * @author jdepons
 * @since Jun 2, 2008
 */
public class QTLEditObjectController extends EditObjectController {

    QTLDAO dao = new QTLDAO();

    public String getViewUrl() throws Exception {
       return "editQTL.jsp";
    }

    public int getObjectTypeKey() {
        return 6;
    }
    
    public Object getObject(int rgdId) throws Exception{        
        return dao.getQTL(rgdId);
    }

    public Object getSubmittedObject(int submissionKey) throws Exception {
        return null;
    }

    public Object newObject() throws Exception{
        QTL qtl = new QTL();
        qtl.setRgdId(-1);        
        qtl.setKey(-1);
        return qtl;
    }

    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        if (req.getParameter("key").equals("")) {
            return null;
        }

        List<NomenclatureEvent> nomenEvents = new ArrayList<>();
        List<Alias> aliases = new ArrayList<>();

        boolean isNew = false;

        String symbol = req.getParameter("symbol");
        this.checkSet("Symbol", symbol);

        String name = req.getParameter("name");
        this.checkSet("Name", name);

        int rgdId = Integer.parseInt(req.getParameter("rgdId"));

        QTL qtl;
        if (rgdId == -1) {
            isNew = true;
            qtl = new QTL();
        } else {
            qtl = dao.getQTL(rgdId);

            if (!Utils.stringsAreEqual(qtl.getSymbol(), symbol) || !Utils.stringsAreEqual(qtl.getName(), name)) {
                NomenclatureEvent ne = new NomenclatureEvent();
                ne.setDesc("Symbol and/or name change");
                ne.setEventDate(new Date());
                ne.setName(name);
                ne.setSymbol(symbol);
                ne.setNomenStatusType("APPROVED");
                ne.setOriginalRGDId(qtl.getRgdId());
                ne.setPreviousName(qtl.getName());
                ne.setPreviousSymbol(qtl.getSymbol());
                ne.setRefKey("853");
                ne.setRgdId(rgdId);
                nomenEvents.add(ne);

                if( !Utils.stringsAreEqual(qtl.getSymbol(), symbol) ) {
                    Alias alias = new Alias();
                    alias.setRgdId(rgdId);
                    alias.setTypeName("old_qtl_symbol");
                    alias.setValue(qtl.getSymbol());
                    alias.setNotes("created by QTL Edit on "+new Date());
                    aliases.add(alias);
                }

                if( !Utils.stringsAreEqual(qtl.getName(), name) ) {
                    Alias alias = new Alias();
                    alias.setRgdId(rgdId);
                    alias.setTypeName("old_qtl_name");
                    alias.setValue(qtl.getName());
                    alias.setNotes("created by QTL Edit on "+new Date());
                    aliases.add(alias);
                }
            }
        }

        qtl.setSymbol(symbol);
        qtl.setName(name);

        if (this.checkInteger("Peak Offset", req.getParameter("peakOffset"), false)) {
            qtl.setPeakOffset(Integer.parseInt(req.getParameter("peakOffset")));
        }

        if (this.checkChromosome(req.getParameter("chromosome"), false)) {
            qtl.setChromosome(req.getParameter("chromosome"));
        }

        if (this.checkNumeric("LOD", req.getParameter("lod"), false)) {
            qtl.setLod(Double.parseDouble(req.getParameter("lod")));
        } else {
            qtl.setLod(null);
        }

        if (this.checkNumeric("P Value", req.getParameter("pValue"), false)) {
            qtl.setPValue(Double.parseDouble(req.getParameter("pValue")));
        } else {
            qtl.setPValue(null);
        }

        if (this.checkNumeric("Variance", req.getParameter("variance"), false)) {
            qtl.setVariance(Double.parseDouble(req.getParameter("variance")));
        } else {
            qtl.setVariance(null);
        }

        if (this.checkInteger("Flank 1 RGD ID", req.getParameter("flank1RgdId"), false)) {
            qtl.setFlank1RgdId(Integer.parseInt(req.getParameter("flank1RgdId")));
        }
        if (this.checkInteger("Flank 2 RGD ID", req.getParameter("flank2RgdId"), false)) {
            qtl.setFlank2RgdId(Integer.parseInt(req.getParameter("flank2RgdId")));
        }

        if (this.checkInteger("Peak RGD ID", req.getParameter("peakRgdId"), false)) {
            qtl.setPeakRgdId(Integer.parseInt(req.getParameter("peakRgdId")));
        }

        qtl.setInheritanceType(req.getParameter("inheritanceType"));
        qtl.setLodImage(req.getParameter("lodImage"));
        qtl.setLinkageImage(req.getParameter("linkageImage"));
        qtl.setSourceUrl(req.getParameter("sourceUrl"));
        qtl.setMostSignificantCmoTerm(req.getParameter("mostSignificantCmoTerm"));

        if (persist) {
            if (isNew) {
                dao.insertQTL(qtl, req.getParameter("objectStatus"), SpeciesType.parse(req.getParameter("speciesType")));
            } else {
                dao.updateQTL(qtl);
                addNomenEvents(nomenEvents);
                insertAliases(aliases);
            }
        }
        return qtl;
    }
}
