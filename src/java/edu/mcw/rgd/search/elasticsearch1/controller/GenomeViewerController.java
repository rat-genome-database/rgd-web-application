package edu.mcw.rgd.search.elasticsearch1.controller;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

/**
 * Created by jthota on 5/18/2017.
 */
public class GenomeViewerController implements Controller {
    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) {


        MapDAO mdao = new MapDAO();
        String rgdIds = request.getParameter("rgdIds");
       String mapKey = (request.getParameter("mapKey"));
        String species = request.getParameter("species");
        String oKey = request.getParameter("oKey");

        StringTokenizer tokenizer = new StringTokenizer(rgdIds, ",");
        List<Integer> rgdIdsList = new ArrayList<>();
        while (tokenizer.hasMoreTokens()) {
            rgdIdsList.add(Integer.valueOf(tokenizer.nextToken()));
        }
        List<MapData> mapDataList = new ArrayList<>();
        try {
            for (int rgdid : rgdIdsList) {
                int key = Integer.parseInt(mapKey);
                List<MapData> mdata = mdao.getMapData(rgdid, key);
                mapDataList.addAll(mdata);
            }

        }catch (Exception e){}
        Report report = null;
        try {
            report = this.getReport(rgdIdsList, oKey, mapKey);
        } catch (Exception e) {
           // e.printStackTrace();
        }
        request.setAttribute("mapDataList", mapDataList);
        request.setAttribute("species", species);
        request.setAttribute("oKey", oKey);
        request.setAttribute("mapKey", mapKey);
        request.setAttribute("report", report);
        return new ModelAndView("/WEB-INF/jsp/search/elasticsearch/gviewer.jsp");

    }

    public Report getReport(List<Integer> rgdIdsList, String oKey, String mapKey) throws Exception {
        MapDAO mdao = new MapDAO();

        Report r = new Report();
        Record rec = new Record();
        rec.append("Symbol");
        rec.append("Chromosome");
        rec.append("Start Position");
        rec.append("Stop Position");
        rec.append("Assembly");
        r.append(rec);
        if (oKey.equals("5")) {
            StrainDAO sdao = new StrainDAO();
            for (int rgdid : rgdIdsList) {
                Strain s = new Strain();
                s = sdao.getStrain(rgdid);
                List<MapData> mdList = mdao.getMapData(rgdid, Integer.parseInt(mapKey));
                if (mdList.size() > 0) {

                    MapData md = mdList.get(0);
                    if (md != null) {
                        rec = new Record();
                        rec.append("<a onclick='geneList(" + rgdid + ")' href='javascript:void(0)'>" + s.getSymbol() + "</a>");
                        rec.append(md.getChromosome());
                        rec.append(md.getStartPos() + "");
                        rec.append(md.getStopPos() + "");
                        rec.append(MapManager.getInstance().getMap(md.getMapKey()).getName());
                        r.append(rec);
                    }
                }

            }
        }
        if (oKey.equals("6")) {
            QTLDAO qdao = new QTLDAO();
            for (int rgdid : rgdIdsList) {
                QTL qtl= new QTL();
                qtl=qdao.getQTL(rgdid);
                List<MapData> mdList = mdao.getMapData(rgdid, Integer.parseInt(mapKey));
                if (mdList.size() > 0) {

                    MapData md = mdList.get(0);
                    if (md != null) {
                        rec = new Record();
                        rec.append("<a onclick='geneList(" + rgdid + ")' href='javascript:void(0)'>" + qtl.getSymbol() + "</a>");
                        rec.append(md.getChromosome());
                        rec.append(md.getStartPos() + "");
                        rec.append(md.getStopPos() + "");
                        rec.append(MapManager.getInstance().getMap(md.getMapKey()).getName());
                        r.append(rec);
                    }
                }

            }
        }
        if (oKey.equals("3")) {
            SSLPDAO sslpdao= new SSLPDAO();
            for (int rgdid : rgdIdsList) {
                SSLP sslp= new SSLP();
                sslp= sslpdao.getSSLP(rgdid);
                List<MapData> mdList = mdao.getMapData(rgdid, Integer.parseInt(mapKey));
                if (mdList.size() > 0) {

                    MapData md = mdList.get(0);
                    if (md != null) {
                        rec = new Record();
                        rec.append("<a onclick='geneList(" + rgdid + ")' href='javascript:void(0)'>" + sslp.getName() + "</a>");
                        rec.append(md.getChromosome());
                        rec.append(md.getStartPos() + "");
                        rec.append(md.getStopPos() + "");
                        rec.append(MapManager.getInstance().getMap(md.getMapKey()).getName());
                        r.append(rec);
                    }
                }

            }
        }
        if (oKey.equals("7")) {
            VariantInfoDAO vdao= new VariantInfoDAO();
            for (int rgdid : rgdIdsList) {
                VariantInfo v= new VariantInfo();
                v= vdao.getVariant(rgdid);
                List<MapData> mdList = mdao.getMapData(rgdid, Integer.parseInt(mapKey));
                if (mdList.size() > 0) {

                    MapData md = mdList.get(0);
                    if (md != null) {
                        rec = new Record();
                        rec.append("<a onclick='geneList(" + rgdid + ")' href='javascript:void(0)'>" + v.getSymbol() + "</a>");
                        rec.append(md.getChromosome());
                        rec.append(md.getStartPos() + "");
                        rec.append(md.getStopPos() + "");
                        rec.append(MapManager.getInstance().getMap(md.getMapKey()).getName());
                        r.append(rec);
                    }
                }

            }
        }
return r;
    }
}