package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.dao.impl.QTLDAO;
import edu.mcw.rgd.dao.impl.StrainDAO;
import edu.mcw.rgd.dao.impl.variants.VariantDAO;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.variants.VariantMapData;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.process.mapping.MapManager;
import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;
import edu.mcw.rgd.web.HttpRequestFacade;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class CNVariantsRsIdController implements Controller {
    protected VariantDAO vdao = new VariantDAO();
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        String path = "/WEB-INF/jsp/report/";

        HttpRequestFacade req = new HttpRequestFacade(request);

        List<VariantMapData> objects = null;
        String geneId = request.getParameter("geneId");
        String qtlId = request.getParameter("qtlId");
        String p = request.getParameter("p");
        String rsId = request.getParameter("id");
        String locType = Utils.isStringEmpty(request.getParameter("locType"))? "":request.getParameter("locType").toLowerCase();
        boolean exon = false;
        boolean intron = false;
        if (Utils.isStringEmpty(locType)){
            locType = "all";
        }
        else if (Utils.stringsAreEqual(locType, "exon")){
            exon = true;
        }
        else if (Utils.stringsAreEqual(locType,"intron")){
            intron=true;
        }
        else {
            locType = "all";
            exon =false;
            intron = false;
        }
        int page = 1;
        try {
            if (!Utils.isStringEmpty(p))
                page = Integer.parseInt(p);
        }catch (Exception e){
            page = 1;
        }
        if (page<=0)
            page=1;
//        int k = 0;
        try {

            if (Utils.isStringEmpty(geneId) && Utils.isStringEmpty(rsId) && Utils.isStringEmpty(qtlId))
                error.add("No ID is given!");
            else{
                if (rsId!=null) {
                    if (!Utils.isStringEmpty(rsId) && !rsId.equals(".")) {
                        objects = vdao.getAllVariantByRsId(rsId);
                    } else
                        error.add("Invalid rs ID!");
                }
                else if (geneId != null){
                    if (!Utils.isStringEmpty(geneId)) {
                        int maxPage = 0, offset = 1, size = 0;
                        int rgdId = Integer.parseInt(geneId);
                        Gene g = getGene(rgdId);
                        final MapManager mm = MapManager.getInstance();
                        Map activeMap = mm.getReferenceAssembly(g.getSpeciesTypeKey());
                        MapData mapData = getMapData(rgdId, activeMap);
                        if (mapData == null) {
                            error.add("We have no variants in given assembly for " + g.getSymbol() + "!");
                        } else {
                            if (exon){
                                size = vdao.getVariantsWithTranscriptLocationNameCount(activeMap.getKey(), mapData.getChromosome(), mapData.getStartPos(), mapData.getStopPos(), "Exon");
                                maxPage = size / 1000;
                                if (size % 1000 != 0)
                                    maxPage++;
                                if (page > maxPage)
                                    page = maxPage;
                                offset = ((page - 1) * 1000) + 1;
                                objects = vdao.getVariantsWithTranscriptLocationNameLimited(activeMap.getKey(), mapData.getChromosome(), mapData.getStartPos(), mapData.getStopPos(), "Exon", offset);
                            }
                            else if (intron){
                                size = vdao.getVariantsWithTranscriptLocationNameCount(activeMap.getKey(), mapData.getChromosome(), mapData.getStartPos(), mapData.getStopPos(), "Intron");
                                maxPage = size / 1000;
                                if (size % 1000 != 0)
                                    maxPage++;
                                if (page > maxPage)
                                    page = maxPage;
                                offset = ((page - 1) * 1000) + 1;
                                objects = vdao.getVariantsWithTranscriptLocationNameLimited(activeMap.getKey(), mapData.getChromosome(), mapData.getStartPos(), mapData.getStopPos(), "Intron", offset);
                            }
                            else {
                                size = vdao.getVariantsCountWithGeneLocation(activeMap.getKey(), mapData.getChromosome(), mapData.getStartPos(), mapData.getStopPos());
                                maxPage = size / 1000;
                                if (size % 1000 != 0)
                                    maxPage++;
                                if (page > maxPage)
                                    page = maxPage;
                                offset = ((page - 1) * 1000) + 1;
                                objects = vdao.getVariantsWithGeneLocationLimited(activeMap.getKey(), mapData.getChromosome(), mapData.getStartPos(), mapData.getStopPos(), offset);
                            }
                            request.setAttribute("p",page);
                            request.setAttribute("maxPage", maxPage);
                            request.setAttribute("pageId","geneId");
                            request.setAttribute("symbol", g.getSymbol());
                            request.setAttribute("rgdId", rgdId);
                            request.setAttribute("start", mapData.getStartPos());
                            request.setAttribute("stop", mapData.getStopPos());
                            request.setAttribute("chr", mapData.getChromosome());
                            request.setAttribute("locType",locType);
                            request.setAttribute("totalSize", size);
                            request.setAttribute("mapKey",activeMap.getKey());
                            request.setAttribute("species",g.getSpeciesTypeKey());
                        }
                    } else
                        error.add("No proper ID given!");
                }
                else if (qtlId != null){

                }
                else {

                }

            }



//            Enumeration<String> parameterNames = request.getParameterNames();

//            while (parameterNames.hasMoreElements()) {
//                String paramName = parameterNames.nextElement();
//                switch (paramName){
//                    case "geneId":
//                        String[] paramValues = request.getParameterValues(paramName);
//                        for (int i = 0; i < paramValues.length; i++) {
//                            String paramValue = paramValues[i];
//                            if (!Utils.isStringEmpty(paramValue)) {
//                                int rgdId = Integer.parseInt(paramValue);
//                                Gene g = getGene(rgdId);
//                                final MapManager mm = MapManager.getInstance();
//                                Map activeMap = mm.getReferenceAssembly(g.getSpeciesTypeKey());
//                                MapData mapData = getMapData(rgdId, activeMap);
//                                if (mapData == null) {
//                                    error.add("We have no variants in given assembly for " + g.getSymbol() + "!");
//                                } else {
//                                    objects = vdao.getVariantsWithGeneLocation(activeMap.getKey(), mapData.getChromosome(), mapData.getStartPos(), mapData.getStopPos());
//                                    request.setAttribute("symbol", g.getSymbol());
//                                    request.setAttribute("rgdId", rgdId);
//                                    request.setAttribute("start", mapData.getStartPos());
//                                    request.setAttribute("stop", mapData.getStopPos());
//                                    request.setAttribute("chr", mapData.getChromosome());
//                                }
//                            } else
//                                error.add("No proper ID given!");
//                        }
//                        break;
//                    case "qtlId":
//                        break;
//                    case "strainId":
//                        break;
//                    case "id":
//
//                        break;
//                    case "p":
//
//                        break;
//                    default:
//                        error.add("No given geneId/qtlId/strainId/id!");
//                }
//                k++;
//            }

            if (objects == null) {
                error.add("Invalid ID!");
            } else if (objects.isEmpty() && Utils.isStringEmpty(geneId)) {
                error.add("No variants with given ID!");
            }
        }
        catch( Exception e ) {
//            System.out.println(e);
            error.add(e.getMessage());
        }
// show distinct rgd ids, rs715 an example to go right to page

//        if (k>1){
//            error.add("Too many IDs given! Reduce down to 1 ID!");
//        }

        HashMap<Long, Boolean> duplicateRgdId = new HashMap<>();
        List<VariantMapData> objectsNonDupe = new ArrayList<>();
        if (objects != null) {
            for (VariantMapData obj : objects) {
                if (duplicateRgdId.get(obj.getId()) == null) {
                    duplicateRgdId.put(obj.getId(), true);
                    objectsNonDupe.add(obj);
                }
            }
        }

        request.setAttribute("reportObjects", objectsNonDupe);
        request.setAttribute("requestFacade", req);

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);


        if (error.size() > 0) {
            return new ModelAndView("/WEB-INF/jsp/search/searchByPosition.jsp");
        } else if (objectsNonDupe.size()==1){
            request.setAttribute("reportObject", objectsNonDupe.get(0));
            return new ModelAndView("/WEB-INF/jsp/report/cnVariants/main.jsp");
        } else{
            return new ModelAndView("/WEB-INF/jsp/report/rsIds/main.jsp");
        }
    }

    public Gene getGene(int rgdId) throws Exception{
        GeneDAO gdao = new GeneDAO();
        return gdao.getGene(rgdId);
    }
    public QTL getQtl(int rgdId) throws Exception{
        QTLDAO qdao = new QTLDAO();
        return qdao.getQTL(rgdId);
    }
    public Strain getStrain(int rgdId) throws Exception{
        StrainDAO sdao = new StrainDAO();
        return sdao.getStrain(rgdId);
    }
    public MapData getMapData(int rgdId, Map map) throws Exception{
        MapDAO mapDAO = new MapDAO();
        MapData md = null;
        List<MapData> mapData = mapDAO.getMapData(rgdId);
        for (MapData m : mapData){
            if (m.getMapKey()==map.getKey()) {
                md = m;
                return m;
            }
        }
        return null;
    }

}
