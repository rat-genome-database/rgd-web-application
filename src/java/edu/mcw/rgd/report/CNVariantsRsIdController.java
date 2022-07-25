package edu.mcw.rgd.report;

import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.dao.impl.variants.VariantDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.Map;
import edu.mcw.rgd.datamodel.MapData;
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

        String rsId = req.getParameter("id");
        String geneId = req.getParameter("geneId");
        List<VariantMapData> objects = null;

        try {
            if ( !Utils.isStringEmpty(rsId) && Utils.isStringEmpty(geneId) ) {
                if (!rsId.equals(".")) {
                    objects = vdao.getAllVariantByRsId(rsId);
                } else
                    error.add("Invalid rs ID!");
            }
            else if (!Utils.isStringEmpty(geneId)){
                int rgdId=Integer.parseInt(geneId);
                Gene g = getGene(rgdId);
                final MapManager mm = MapManager.getInstance();
                Map activeMap = mm.getReferenceAssembly(g.getSpeciesTypeKey());
                MapData mapData = getMapData(rgdId,activeMap);
                if (mapData == null){
                    error.add("We have no variants in given assembly for "+g.getSymbol()+"!");
                }
                else {
                    objects = vdao.getVariantsWithGeneLocation(activeMap.getKey(),mapData.getChromosome(),mapData.getStartPos(),mapData.getStopPos());
                    request.setAttribute("gene", g.getSymbol());
                }
            }
            else
                error.add("No proper ID given!");

            if (objects == null) {
                error.add("Invalid rs ID!");
            } else if (objects.isEmpty()) {
                error.add("No variants with given rs ID!");
            }
        }
        catch( Exception e ) {
            error.add(e.getMessage());
        }
// show distinct rgd ids, rs715 an example to go right to page


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
