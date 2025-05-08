package edu.mcw.rgd.report;

import edu.mcw.rgd.datamodel.MapData;
import edu.mcw.rgd.datamodel.Map;
import edu.mcw.rgd.dao.impl.MapDAO;
import edu.mcw.rgd.datamodel.RgdId;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.mapping.MapManager;
import edu.mcw.rgd.web.FormUtility;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 9, 2011
 */
public class  MapDataFormatter {

    public static String buildTable(int rgdId, int speciesTypeKey) throws Exception{
        return buildTable(rgdId, speciesTypeKey, 0);
    }

    public static String buildTable(int speciesTypeKey, List<MapData> mapData) throws Exception{
        return buildTable(speciesTypeKey, mapData, 0);
    }

    public static String buildTable(String rsId, int speciesTypeKey, int mapKey) throws Exception{
        MapDAO mdao = new MapDAO();
        List<MapData> mapData = mdao.getMapData(rsId,mapKey);
        if (mapData.size()>1){
            MapData m = mapData.get(0);
            mapData.clear();
            mapData.add(m);
        }
        return buildTable(speciesTypeKey,mapData,0);
    }

    public static String buildTable(int rgdId, int speciesTypeKey, int objectKey) throws Exception {

        MapDAO mdao = new MapDAO();
        List<MapData> mapData = mdao.getMapData(rgdId);
        return buildTable(speciesTypeKey, mapData, objectKey);
    }

    public static String buildTable(int speciesTypeKey, List<MapData> mapData, int objectKey) throws Exception {
        return buildTable(speciesTypeKey, mapData, objectKey, null);
    }

    public static String buildTable(int rgdId, int speciesTypeKey, int objectKey, String objectSymbol) throws Exception {

        MapDAO mdao = new MapDAO();
        List<MapData> mapData = mdao.getMapData(rgdId);
        return buildTable(speciesTypeKey, mapData, objectKey, objectSymbol);
    }

    public static String buildTable(int speciesTypeKey, List<MapData> mapData, int objectKey, String objectSymbol) throws Exception{

        if( mapData.isEmpty() ) {
            return "No map positions available.";
        }

        final MapManager mm = MapManager.getInstance();

        Map activeMap = mm.getReferenceAssembly(speciesTypeKey);
        String mapColumnTitle = SpeciesType.getCommonName(speciesTypeKey)+" Assembly";

        // sort map data by order specified in the database
        Collections.sort(mapData, new Comparator<MapData>() {
            @Override
            public int compare(MapData o1, MapData o2) {
                int rank1 = 0, rank2 = 0;
                Map map = mm.getMap(o1.getMapKey());
                if( map!=null ) {
                    rank1 = map.getRank();
                }
                map = mm.getMap(o2.getMapKey());
                if( map!=null ) {
                    rank2 = map.getRank();
                }
                return rank1 - rank2;
            }
        });

        StringBuilder ret = new StringBuilder("<table border=\"0\" class=\"mapDataTable\" width=\"670\">");
        if( objectKey==RgdId.OBJECT_KEY_GENES ) {
            ret.append("<tr><th align=\"left\" rowspan=\"2\"><b>").append(mapColumnTitle).append("</b></th>");
            ret.append("<th align=\"left\" rowspan=\"2\">Chr</th>");
            ret.append("<th align=\"left\" rowspan=\"2\">Position (strand)</th>");
            ret.append("<th align=\"left\" rowspan=\"2\">Source</th>");
            ret.append("<th colspan=\"4\">Genome Browsers</th>");
            ret.append("</tr>");
            ret.append("<tr><th>JBrowse</th><th>NCBI</th><th>UCSC</th><th>Ensembl</th></tr>");
        } else {
            ret.append("<tr><th align=\"left\"><b>").append(mapColumnTitle).append("</b></th>");
            ret.append("<th align=\"left\">Chr</th>");
            ret.append("<th align=\"left\">Position (strand)</th>");
            ret.append("<th align=\"left\">Source</th>");
            if( objectKey==RgdId.OBJECT_KEY_QTLS ||
                    objectKey==RgdId.OBJECT_KEY_SSLPS ||
                    objectKey==RgdId.OBJECT_KEY_STRAINS ) {
                ret.append("<th align=\"left\">JBrowse</th>");
            }
            ret.append("</tr>");
        }
      List<String> activeMapChr=new ArrayList<>();
        for(MapData mdObj: mapData){
            Map map= mm.getMap(mdObj.getMapKey());
            if( map==null ) {
                // map not known
                //ret.append("<td>&nbsp;</td>");
                continue;
            }

            if (map.getKey() == activeMap.getKey()) {
                activeMapChr.add(mdObj.getChromosome());
            }
        }
        for (MapData mdObj: mapData) {
            Map map = mm.getMap(mdObj.getMapKey());
            if( map==null ) {
                map = new MapDAO().getMap(mdObj.getMapKey());
            }
			if( map==null ) {
                // map not known
                ret.append("<td>&nbsp;</td>");
            }
            else
            if (map.getKey() == activeMap.getKey()) {

                ret.append("<td><a style='color:blue;font-weight:700;font-size:11px;' href='")
                        .append(SpeciesType.getNCBIAssemblyDescriptionForSpecies(map.getSpeciesTypeKey()))
                        .append("'>").append(map.getName())
                        .append("</a></td>");

            }else {
                ret.append("<td>").append(map.getName()).append("</td>");
            }
            if(activeMapChr.size()>1){
                ret.append("<td style='color:red;font-weight:bold;'>").append(mdObj.getChromosome()).append("</td>");
            }else{
                if(activeMapChr.size()==1) {
                    for (String chr : activeMapChr) {
                        if (mdObj.getChromosome().equals(chr))
                            ret.append("<td>").append(mdObj.getChromosome()).append("</td>");
                        else
                            ret.append("<td style='color:red;font-weight:bold;'>").append(mdObj.getChromosome()).append("</td>");
                    }
                }else {
                    ret.append("<td>").append(mdObj.getChromosome()).append("</td>");
                }
            }

            if (map!=null && map.getUnit().equals("bp")) {
                ret.append("<td>")
                   .append(FormUtility.formatThousands(mdObj.getStartPos()))
                   .append("&nbsp;-&nbsp;")
                   .append(FormUtility.formatThousands(mdObj.getStopPos()));
                if( mdObj.getStrand()!=null ) {
                    ret.append(" (").append(mdObj.getStrand()).append(")");
                }
                ret.append("</td>");
            } else if (mdObj.getAbsPosition() != null){
                ret.append("<td>").append(mdObj.getAbsPosition()).append("</td>");

            } else if (mdObj.getFishBand() != null) {
                ret.append("<td>").append(mdObj.getFishBand()).append("</td>");
            } else {
                ret.append("<td>&nbsp;</td>");
            }

            String src = "RGD";
            if (mdObj.getSrcPipeline() != null) {
                src=mdObj.getSrcPipeline();
            }
            ret.append("<td>").append(src).append("</td>");

            // JBrowse links - removed genes, qtls for jbrowse2
            if(objectKey==RgdId.OBJECT_KEY_SSLPS ||
                    objectKey==RgdId.OBJECT_KEY_STRAINS) {
                ret.append("<td>");
                generateJBrowseLink(ret, objectKey, mdObj);
                ret.append("</td>");
            }
            if(objectKey==RgdId.OBJECT_KEY_QTLS){
                ret.append("<td>");
                generateJBrowse2Link(ret, objectKey, mdObj);
                ret.append("</td>");
            }
            if(objectKey==RgdId.OBJECT_KEY_GENES) {
                //Jbrowse2 link for genes
                ret.append("<td>");
                generateJBrowse2Link(ret, objectKey, mdObj);
                ret.append("</td>");
                // NCBI links
                ret.append("<td>");
                if( map!=null ) {
                    generateNcbiGDVLink(ret, objectSymbol, map.getRefSeqAssemblyAcc(), map.getName());
                }
                ret.append("</td>");

                // UCSC links
                ret.append("<td>");
                generateUcscLink(ret, objectKey, mdObj);
                ret.append("</td>");

                // Ensembl links
                ret.append("<td>");
                generateEnsemblLink(ret, objectKey, mdObj);
                ret.append("</td>");
            }

            ret.append("</tr>");

        }
        ret.append("</table>");

        return ret.toString();
    }

    static void generateJBrowseLink(StringBuilder buf, int objectKey, MapData md) {

        String track = null;
        switch( objectKey ) {
            case RgdId.OBJECT_KEY_GENES:
                track = "ARGD_curated_genes";
                break;
            case RgdId.OBJECT_KEY_QTLS:
                track = "AQTLS";
                break;
            case RgdId.OBJECT_KEY_SSLPS:
                track = "SSLP";
                break;
            case RgdId.OBJECT_KEY_STRAINS:
                track = "CongenicStrains,MutantStrains";
                break;
        }

        String db = null, link = null;
        switch(md.getMapKey()) {
            case 13: // human build 36
                db = "data_hg18"; link = "NCBI36";
                break;
            case 17: // human build 37
                db = "data_hg19"; link = "GRCh37";
                break;
            case 38: // human build 38
                db = "data_hg38"; link = "GRCh38";
                break;
            case 40: // human build 38
                db = "data_hg38"; link = "GRCh38";
                if( track != null && track.equals("ARGD_curated_genes"))
                    track = "Ensembl_genes";
                break;

            case 18: // mouse build 37
                db = "data_mm37"; link = "GRCm37";
                break;
            case 35: // mouse build 38
                db = "data_mm38"; link = "GRCm38";
                break;
            case 39: // mouse build 38
                db = "data_mm38"; link = "GRCm38";
                if( track != null && track.equals("ARGD_curated_genes"))
                    track = "Ensembl_genes";
                break;
            case 239: // NCBI GRCm39
                db = "data_mm39"; link = "GRCm39";
                break;

            case 60: // RGSC 3.4
                db = "data_rgd3_4"; link = "RGSC3.4";
                break;
            case 70: // Rnor5.0
                db = "data_rgd5"; link = "Rnor5.0";
                break;
            case 360: // Rnor6.0
                db = "data_rgd6"; link = "Rnor6.0";
                break;
            case 361: // Rnor6.0
                db = "data_rgd6"; link = "Rnor6.0";
                if( track != null && track.equals("ARGD_curated_genes"))
                    track = "Ensembl_genes";
                break;

            case 372:
                db = "data_rn7_2"; link = "mRatBN7.2";
                break;
            case 301:
                db = "data_uth_shr"; link = "Rnor_SHR";
                break;
            case 302:
                db = "data_uth_shrsp"; link = "Rnor_SHRSP";
                break;
            case 303:
                db = "data_uth_wky"; link = "Rnor_WKY";
                break;

            case 44: // chinchilla
                db = "data_cl1_0"; link = "ChiLan1.0";
                break;
            case 45: // chinchilla
                db = "data_cl1_0"; link = "ChiLan1.0";
                if( track != null && track.equals("ARGD_curated_genes"))
                    track = "Ensembl_genes";
                break;

            case 511: // panpan1.1
                db = "data_bonobo1_1"; link = "panpan1.1";
                break;
            case 512: // panpan1.1
                db = "data_bonobo1_1"; link = "panpan1.1";
                if( track != null && track.equals("ARGD_curated_genes"))
                    track = "Ensembl_genes";
                break;
            case 513:
                db = "data_bonobo2"; link = "Mhudiblu_PPA_v0";
                break;

            case 631: // CanFam3.1
                db = "data_dog3_1"; link = "CanFam3.1";
                break;
            case 632: // CanFam3.1
                db = "data_dog3_1"; link = "CanFam3.1";
                if( track != null && track.equals("ARGD_curated_genes"))
                    track = "Ensembl_genes";
                break;

            case 720: // SpeTri2.0
                db = "data_squirrel2_0"; link = "SpeTri2.0";
                break;
            case 721: // SpeTri2.0
                db = "data_squirrel2_0"; link = "SpeTri2.0";
                if( track != null && track.equals("ARGD_curated_genes"))
                    track = "Ensembl_genes";
                break;

            case 911: // PIG
                db = "data_pig11_1"; link = "Sscrofa11.1";
                break;
            case 912: // PIG
                db = "data_pig11_1"; link = "Sscrofa11.1";
                if( track != null && track.equals("ARGD_curated_genes"))
                    track = "Ensembl_genes";
                break;
            case 910:
                db = "data_pig10_2"; link = "Sscrofa10.2";
                break;

            case 1311: // Green Monkey (vervet) chlSab2
                db = "data_chlSab2"; link = "ChlSab1.1";
                break;
            case 1312: // chlSab2 Ensembl
                db = "data_chlSab2"; link = "ChlSab1.1";
                if( track != null && track.equals("ARGD_curated_genes"))
                    track = "Ensembl_genes";
                break;
            case 1313: // Green Monkey (vervet) Vero_WHO_p1.0
                db = "data_veroWho"; link = "Vero_WHO_p1.0";
                break;

            case 1410: // naked mole rat NCBI
                db = "data_hetGla2"; link = "HetGla_female_1.0";
                break;
            case 1411: // naked mole rat Ensembl
                db = "data_hetGla2"; link = "HetGla_female_1.0";
                if( track != null && track.equals("ARGD_curated_genes"))
                    track = "Ensembl_genes";
                break;
        }

        if( db!=null && track!=null ) {
            buf.append("<a style=\"font-size:11px;font-weight:bold\" href=\"/jbrowse/index.html?data=")
                .append(db).append("&tracks=").append(track).append("&highlight=&loc=")
                .append(FormUtility.getJBrowseLoc(md))
            .append("\">").append(link).append("</a>");
        }
    }
    static void generateJBrowse2Link(StringBuilder buf, int objectKey, MapData md) throws Exception {
        String url=generateJbrowse2URL(objectKey,md);
        if(url!=null) {
            String linkName= MapManager.getInstance().getMap(md.getMapKey()).getName();
//                buf.append("<a style=\"font-size:11px;font-weight:bold\" href=\"/jbrowse2/?loc=")
//                        .append(FormUtility.getJBrowse2Loc(md, chrPrefix))
//                        .append("&assembly=").append(assembly)
//                        .append("&tracklist=true")
//                        .append("&tracks=").append(tracks)
//                        .append("\">").append(link).append("</a>");
                buf.append("<a style=\"font-size:11px;font-weight:bold\" href=\"")
                        .append(url).append("\">").append(linkName).append("</a>");

        }
    }

    public static String generateJbrowse2URL(int objectKey, MapData md) throws Exception {
        String assembly=null,tracks=null,link=null,url=null;
        String chrPrefix = "chr"; // Default lowercase
        switch (md.getMapKey()){
            //Rat
            case 380:
                assembly="GRCr8";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Rat%20GRCr8%20(rn8)%20Genes%20and%20Transcripts-GRCr8";
                }
                link="GRCr8";
                break;

            case 372:
                assembly="mRatBN7.2";
                if(objectKey==RgdId.OBJECT_KEY_GENES){
                tracks="Rat%20mRatBN7.2%20(rn7)%20Genes%20and%20Transcripts-mRatBN7.2";
                }
                else if(objectKey==RgdId.OBJECT_KEY_QTLS){
                    tracks="Rat%20mRatBN7.2%20(rn7)%20QTLs-mRatBN7.2";
                }
                link="mRatBN7.2";
                break;

//            case 373:
//                assembly="mRatBN7.2";
//                tracks="Ensembl%20(mRatBN7.2.110)%20Features-mRatBN7.2";
//                link="mRatBN7.2.Ensembl";
//                break;

            case 360: //has an ensembl with mapkey 361
                assembly="Rnor_6.0";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Rat%20Rnor_6.0%20(rn6)%20Genes%20and%20Transcripts-Rnor_6.0";
                }
                else if(objectKey==RgdId.OBJECT_KEY_QTLS){
                    tracks="Rat%20Rnor_6.0%20(rn6)%20QTLs-Rnor_6.0";
                }
                link = "Rnor6.0";
                break;
            //ensembl
//            case 361:
//                assembly="Rnor_6.0";
//                tracks="Rat%20Rnor_6.0%20(rn6)%20Genes%20and%20Transcripts-Rnor_6.0";
//                link = "Rnor6.0";
//                break;

            case 70:
                assembly = "Rnor_5.0";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Rat%20Rnor_5.0%20(rn5)%20Genes%20and%20Transcripts-Rnor_5.0";
                }
                else if(objectKey==RgdId.OBJECT_KEY_QTLS){
                    tracks="Rat%20Rnor_5.0%20(rn5)%20QTLs-Rnor_5.0";
                }
                link = "Rnor5.0";
                break;

            case 60:
                assembly="RGSC_v3.4";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Rat%20RGSC_v3.4%20(rn4)%20Genes%20and%20Transcripts-RGSC_v3.4";
                }
                else if(objectKey==RgdId.OBJECT_KEY_QTLS){
                    tracks="Rat%20RGSC_v3.4%20(rn4)%20QTLs-RGSC_v3.4";
                }
                link = "RGSC3.4";
                break;

            case 301:
                assembly="UTH_Rnor_SHR_Utx";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "UTH_Rnor_SHR_Utx%20Genes%20and%20Transcripts-UTH_Rnor_SHR_Utx";
                }
                link = "Rnor_SHR";
                chrPrefix = "Chr";
                break;

            case 302:
                assembly="UTH_Rnor_SHRSP_BbbUtx_1.0";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "UTH_Rnor_SHRSP_BbbUtx_1.0%20Genes%20and%20Transcripts-UTH_Rnor_SHRSP_BbbUtx_1.0";
                }
                link = "Rnor_SHRSP";
                chrPrefix = "Chr";
                break;

            case 303:
                assembly="UTH_Rnor_WKY_Bbb_1.0";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "UTH_Rnor_WKY_Bbb_1.0%20Genes%20and%20Transcripts-UTH_Rnor_WKY_Bbb_1.0";
                }
                link = "Rnor_WKY";
                chrPrefix = "Chr";
                break;
            //Mouse
            case 239:
                assembly="GRCm39";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Mouse%20GRCm39%20(mm39)%20Genes%20and%20Transcripts-GRCm39";
                }
                else if(objectKey==RgdId.OBJECT_KEY_QTLS){
                    tracks="Mouse%20GRCm39%20(mm39)%20QTLs-GRCm39";
                }
                link = "GRCm39";
                break;

            case 35: //has an ensemble with map key 39
                assembly="GRCm38.p6";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Mouse%20GRCm38.p6%20(mm10)%20Genes%20and%20Transcripts-GRCm38.p6";
                }
                else if(objectKey==RgdId.OBJECT_KEY_QTLS){
                    tracks="Mouse%20GRCm38.p6%20(mm10)%20QTLs-GRCm38.p6";
                }
                link = "GRCm38.p6";
                break;

            case 18:
                assembly="MGSCv37";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Mouse%20MGSCv37%20(mm9)%20Genes%20and%20Transcripts-MGSCv37";
                }
                else if(objectKey==RgdId.OBJECT_KEY_QTLS){
                    tracks="Mouse%20MGSCv37%20(mm9)%20QTLs-MGSCv37";
                }
                link = "GRCm37";
                break;
            //human
            case 38: // has an ensemble with map key 40
                assembly="GRCh38.p14";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Human%20GRCh38.p14%20(hg38)%20Genes%20and%20Transcripts-GRCh38.p14";
                }
                else if(objectKey==RgdId.OBJECT_KEY_QTLS){
                    tracks="Human%20GRCh38.p14%20(hg38)%20QTLs-GRCh38.p14";
                }
                link = "GRCh38";
                break;

            case 17:
                assembly="GRCh37.p13";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Human%20GRCh37.p13%20(hg19)%20Genes%20and%20Transcripts-GRCh37.p13";
                }
                else if(objectKey==RgdId.OBJECT_KEY_QTLS){
                    tracks="Human%20GRCh37.p13%20(hg19)%20QTLs-GRCh37.p13";
                }
                link = "GRCh37";
                break;

            case 13:
                assembly="NCBI36";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Human%20NCBI36%20(hg18)%20Genes%20and%20Transcripts-NCBI36";
                }
                else if(objectKey==RgdId.OBJECT_KEY_QTLS){
                    tracks="Human%20NCBI36%20(hg18)%20QTLs-NCBI36";
                }
                link = "NCBI36";
                break;
            //Domestic Dog
            case 631: // has an ensemble with map key 632
                assembly="CanFam3.1";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Dog%20CanFam3.1%20(canFam3)%20Genes%20and%20Transcripts-CanFam3.1";
                }
                link = "CanFam3.1";
                chrPrefix = "Chr";
                break;

            case 633:
                assembly="Dog10K_Boxer_Tasha";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Dog%20Dog10K_Boxer_Tasha%20(canFam6)%20Genes%20and%20Transcripts-Dog10K_Boxer_Tasha";
                }
                link = "Dog10K Boxer Tasha";
                chrPrefix = "Chr";
                break;

            case 634: // has an ensemble with map key 638
                assembly="ROS_Cfam_1.0";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Dog%20ROS_Cfam_1.0%20(rOS_Cfam_1)%20Genes%20and%20Transcripts-ROS_Cfam_1.0";
                }
                link = "ROS Cfam";
                chrPrefix = "Chr";
                break;

            case 637: // has an ensemble with map key 639
                assembly="UU_Cfam_GSD_1.0";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Dog%20UU_Cfam_GSD_1.0%20(canFam4)%20Genes%20and%20Transcripts-UU_Cfam_GSD_1.0";
                }
                link = "UU Cfam";
                chrPrefix = "Chr";
                break;
            //Bonobo
            case 513:
                assembly="Mhudiblu_PPA_v0";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Bonobo%20Mhudiblu_PPA_v0%20(panPan3)%20Genes%20and%20Transcripts-Mhudiblu_PPA_v0";
                }
                link = "Mhudiblu_PPA_v0";
                break;

            case 511: //has an ensemble with map key 512
                assembly="panpan1.1";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Bonobo%20panpan1.1%20(panPan2)%20Genes%20and%20Transcripts-panpan1.1";
                }
                link = "panpan1.1";
                break;
            //squirrel
            case 720: //has an ensemble with map key 721
                assembly="SpeTri2.0";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Squirrel%20null%20(speTri2)%20Genes%20and%20Transcripts-SpeTri2.0";
                }
                link = "SpeTri2.0";
                break;
            //Chinchilla
            case 44: // has an ensemble with map key 45
                assembly="ChiLan1.0";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Chinchilla%20ChiLan1.0%20(chiLan1)%20Genes%20and%20Transcripts-ChiLan1.0";
                }
                link = "ChiLan1.0";
                break;
            //PIG
            case 911: //has an ensemble with map key 912
                assembly="Sscrofa11.1";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Pig%20Sscrofa11.1%20(susScr11)%20Genes%20and%20Transcripts-Sscrofa11.1";
                }
                link = "Sscrofa11.1";
                break;

            case 910:
                assembly="Sscrofa10.2";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Pig%20Sscrofa10.2%20(susScr3)%20Genes%20and%20Transcripts-Sscrofa10.2";
                }
                link = "Sscrofa10.2";
                break;
            //Green Monkey/Vervet
            case 1311: // has an ensemble with map key 1312
                assembly="Chlorocebus_sabeus1.1";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Green%20Monkey%20Chlorocebus_sabeus%201.1%20(chlSab2)%20Genes%20and%20Transcripts-Chlorocebus_sabeus1.1";
                }
                link = "ChlSab1.1";
                break;

            case 1313:
                assembly="Vero_WHO_p1.0";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Green%20Monkey%20Vero_WHO_p1.0%20(vero_WHO_p1)%20Genes%20and%20Transcripts-Vero_WHO_p1.0";
                }
                link = "Vero_WHO_p1.0";
                break;
            //Naked Mole-Rat
            case 1410: // has an ensemble with map key 1411
                assembly="HetGla_female_1.0";
                if(objectKey==RgdId.OBJECT_KEY_GENES) {
                    tracks = "Naked%20Mole-Rat%20HetGla_female_1.0%20(hetGla2)%20Genes%20and%20Transcripts-HetGla_female_1.0";
                }
                link = "HetGla_female_1.0";
                break;
        }

        if(assembly!=null&&tracks!=null) {
            url = "/jbrowse2/?loc=" + FormUtility.getJBrowse2Loc(md, chrPrefix) + "&assembly=" + assembly + "&tracklist=true" + "&tracks="
                    + tracks;
//            System.out.println(url);
        }
        return url;
    }

    static void generateNcbiGDVLink(StringBuilder buf, String objectSymbol, String refSeqAccId, String mapName) {
        //removed mRatBN7.2 Ensembl from the NCBI section as per RGDD-2799
        if(refSeqAccId!=null&&!(mapName.equals("mRatBN7.2 Ensembl"))&&!(mapName.equals("ROS_Cfam_1.0 Ensembl"))) {
            buf.append("<a style=\"font-size:11px;font-weight:bold\" href=\"https://www.ncbi.nlm.nih.gov/genome/gdv/browser/?id=")
                    .append(refSeqAccId)
                    .append("&q=").append(objectSymbol)
                    .append("&context=genome")
                    .append("\">").append(mapName).append("</a>");
        }
    }

    static void generateUcscLink(StringBuilder buf, int objectKey, MapData md) {

        String db = null;
        if( objectKey==RgdId.OBJECT_KEY_GENES ) {
            switch(md.getMapKey()) {
                case 13: // human build 36
                    db = "hg18";
                    break;
                case 17: // human build 37
                    db = "hg19";
                    break;
                case 40:
                case 38: // human build 38
                    db = "hg38";
                    break;

                case 14: // mouse build 36
                    db = "mm8";
                    break;
                case 18: // mouse build 37
                    db = "mm9";
                    break;
                case 35:
                case 39:// mouse build 38
                    db = "mm10";
                    break;
                case 239:// mouse build 39
                    db = "mm39";
                    break;

                case 60: // RGSC 3.4
                    db = "rn4";
                    break;
                case 70: // Rnor5.0
                    db = "rn5";
                    break;
                case 360:
                case 361: // Rnor6.0
                    db = "rn6";
                    break;

                case 510: // bonobo
                    db = "panPan1";
                    break;
                case 511:
                case 512:
                    db = "panPan2";
                    break;
                case 513: // Mhudiblu_PPA_v0
                    db = "panPan3";
                    break;

                case 631:
                case 632:// dog CanFam3.1
                    db = "canFam3";
                    break;

                case 910: // pig
                    db = "susScr3";
                    break;
                case 911:
                case 912:
                    db = "susScr11";
                    break;

                case 1311:
                case 1312:// green monkey (vervet)
                    db = "chlSab2";
                    break;

                case 1410:
                case 1411:// naked mole rat
                    db = "hetGla2";
                    break;
            }
        }
        if( db!=null ) {
            buf.append("<a style=\"font-size:11px;font-weight:bold\" href=\"https://genome.ucsc.edu/cgi-bin/hgTracks?db=")
                    .append(db).append("&position=chr")
                    .append(md.getChromosome()).append("%3A").append(md.getStartPos()).append("-").append(md.getStopPos())
                    .append("\">").append(db).append("</a>");
        }
    }

    static void generateEnsemblLink(StringBuilder buf, int objectKey, MapData md) {

        // http://useast.ensembl.org/info/website/archives/assembly.html

        String db = null, link = "";
        if( objectKey==RgdId.OBJECT_KEY_GENES ) {
            switch(md.getMapKey()) {
                case 380:
                    db = "http://useast.ensembl.org/Rattus_norvegicus/Location/View?r=";
                    link="GRCr8";
                    break;

                //rat build mRatBN7.2 Ensembl 373
                case 373:
                    db = "https://oct2024.archive.ensembl.org/Rattus_norvegicus/Location/View?r=";
                    link = "mRatBN7.2";
                    break;

                case 13: // human build 36
                    db = "http://may2009.archive.ensembl.org/Homo_sapiens/Location/View?r=";
                    link = "NCBI36";
                    break;
                case 17: // human build 37
                    db = "http://grch37.ensembl.org/Homo_sapiens/Location/View?r=";
                    link = "GRCh37";
                    break;
                case 38:
                case 40:// human build 38
                    db = "http://useast.ensembl.org/Homo_sapiens/Location/View?r=";
                    link = "GRCh38";
                    break;

                case 18: // mouse build 37
                    db = "http://may2012.archive.ensembl.org/Mus_musculus/Location/View?r=";
                    link = "NCBIm37";
                    break;

//                case 239:
                case 240:
                    db = "http://useast.ensembl.org/Mus_musculus/Location/View?r=";
                    link="GRCm39";
                    break;

                case 35:
                case 39: // mouse build 38
                    db = "http://nov2020.archive.ensembl.org/Mus_musculus/Location/View?r=";
                    link = "GRCm38";
                    break;

                //Removing RGSC3.4 and Rnor 5.0 from the ensembl section on the gene report pages as per RGDD-2799
//                case 60: // RGSC 3.4
//                    db = "http://may2012.archive.ensembl.org/Rattus_norvegicus/Location/View?r=";
//                    link = "RGSC3.4";
//                    break;
//                case 70: // Rnor5.0
//                    db = "http://mar2015.archive.ensembl.org/Rattus_norvegicus/Location/View?r=";
//                    link = "Rnor5.0";
//                    break;

                //bonobo
//                case 511: // panpan1.1
                case 512: // panpan1.1
                    db = "http://www.ensembl.org/Pan_paniscus/Location/View?r=";
                    link = "panpan1.1";
                    break;

                case 360:
                case 361:// Rnor6.0
                    db = "https://may2021.archive.ensembl.org/Rattus_norvegicus/Location/View?r=";
                    link = "Rnor6.0";
                    break;

                case 631:
                case 632:// CanFam3.1
                    db = "https://may2021.archive.ensembl.org/Canis_lupus_familiaris/Location/View?r=";
                    link = "CanFam3.1";
                    break;

                case 638:
                    db="https://www.ensembl.org/Canis_lupus_familiaris/Location/View?r=";
                    link="ROS_Cfam_1.0 Ensembl";
                    break;

                case 720: // SpeTri2.0
                    db = "http://useast.ensembl.org/Ictidomys_tridecemlineatus/Location/View?r=";
                    link = "SpeTri2.0";
                    break;

                    //green monkey
                case 1312:
                    db = "http://www.ensembl.org/Chlorocebus_sabaeus/Location/View?r=";
                    link = "Vervet-AGM";
                    break;

                case 911:
                case 912:// PIG
                    db = "http://useast.ensembl.org/Sus_scrofa/Location/View?r=";
                    link = "Sscrofa11.1";
                    break;

                case 1411:
                    db = "https://feb2023.archive.ensembl.org/Heterocephalus_glaber_female/Location/View?r=";
                    link = "HetGla_female_1.0 Ensembl";
                    break;
            }
        }
        if( db!=null ) {
            buf.append("<a style=\"font-size:11px;font-weight:bold\" href=\"")
                    .append(db)
                    .append(md.getChromosome()).append("%3A").append(md.getStartPos()).append("-").append(md.getStopPos())
                    .append("\">").append(link).append("</a>");
        }
    }
}
