package edu.mcw.rgd.edit;

import org.springframework.web.servlet.mvc.Controller;
import org.springframework.web.servlet.ModelAndView;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.dao.impl.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.Iterator;
/**
 * Created by IntelliJ IDEA.
 * User: mtutaj
 * Date: March 15, 2013
 */
public class MapsEditObjectController implements Controller {

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        MapDAO mdao = new MapDAO();

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        int geneRgdId = Integer.parseInt(request.getParameter("rgdId"));

        List<MapData> incomingData = parseParameters(request, geneRgdId);
        List<MapData> existingData = mdao.getMapData(geneRgdId);

        removeSharedData(incomingData, existingData);

        // add new map positions
        mdao.insertMapData(incomingData);

        // remove obsolete map positions
        mdao.deleteMapData(existingData);
        status.add("Update Successful");

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView("/WEB-INF/jsp/curation/edit/status.jsp");

    }

    List<MapData> parseParameters(HttpServletRequest request, int geneRgdId) {

        String[] chrs = request.getParameterValues("chr");
        String[] fishBands = request.getParameterValues("fishBand");
        String[] mapKeys = request.getParameterValues("mapKey");
        String[] startPos = request.getParameterValues("startPos");
        String[] stopPos = request.getParameterValues("stopPos");
        String[] srcPipelines = request.getParameterValues("srcPipeline");
        String[] strand = request.getParameterValues("strand");
        int rowCount = chrs.length;

        List<MapData> mds = new ArrayList<MapData>(rowCount);
        for( int i=0; i<rowCount; i++ ) {
            MapData md = new MapData();
            md.setMapKey(Integer.parseInt(mapKeys[i]));
            md.setRgdId(geneRgdId);
            md.setChromosome(chrs[i]);
            md.setFishBand(fishBands[i]);

            String pos = startPos[i];
            if( !pos.isEmpty() )
                md.setStartPos(Integer.parseInt(pos));
            pos = stopPos[i];
            if( !pos.isEmpty() )
                md.setStopPos(Integer.parseInt(pos));

            md.setSrcPipeline(srcPipelines[i]);
            md.setStrand(strand[i]);
            mds.add(md);
        }
        return mds;
    }

    int removeSharedData(List<MapData> incomingData, List<MapData> existingData) throws Exception {

        int updatedCount = 0;

        Iterator<MapData> it1 = incomingData.iterator();
        while( it1.hasNext() ) {
            MapData var1 = it1.next();

            Iterator<MapData> it2 = existingData.iterator();
            while( it2.hasNext() ) {
                MapData var2 = it2.next();

                if( var1.equalsByGenomicCoords(var2) ) {

                    updatedCount++;
                    it1.remove();
                    it2.remove();
                    break; // break inner loop
                }
            }
        }
        return updatedCount;
    }
}