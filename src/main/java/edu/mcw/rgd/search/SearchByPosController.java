package edu.mcw.rgd.search;


import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.vv.SampleManager;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchScrollRequest;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.core.TimeValue;
import org.elasticsearch.index.query.BoolQueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.Arrays;
import java.util.List;
import java.util.Map;


public class SearchByPosController implements Controller {



    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String fmt = Utils.NVL(request.getParameter("fmt"), "full");

        String path = "/WEB-INF/jsp/search/";
        if(fmt.equalsIgnoreCase("csv")) {

            String chr = request.getParameter("chr");
            int start =  Integer.valueOf(request.getParameter("start"));
            int stop = Integer.valueOf(request.getParameter("stop"));
            int mapKey = Integer.valueOf(request.getParameter("mapKey"));
            String objType = request.getParameter("objType");
            Report report = new Report();
            Record header = new Record();
            header.append("RGD ID");
            header.append("Symbol");
            header.append("Name");
            header.append("Type");
            header.append("Chr");
            header.append("Start");
            header.append("Stop");
            report.append(header);
            if(objType.equalsIgnoreCase("gene") || objType.equalsIgnoreCase("all")) {
                GeneDAO gdao = new GeneDAO();

                List<MappedGene> genes = gdao.getActiveMappedGenes(chr,start,stop,mapKey);

                for(MappedGene gene: genes){
                    Record record = new Record();
                    record.append(String.valueOf(gene.getGene().getRgdId()));
                    record.append(gene.getGene().getSymbol());
                    record.append(gene.getGene().getName());
                    record.append("GENE");
                    record.append(gene.getChromosome());
                    record.append(String.valueOf(gene.getStart()));
                    record.append(String.valueOf(gene.getStop()));
                    report.append(record);
                }

            }
            if(objType.equalsIgnoreCase("qtl") || objType.equalsIgnoreCase("all")){
                QTLDAO qdao = new QTLDAO();
                List<MappedQTL> qtls = qdao.getActiveMappedQTLs(chr,start,stop,mapKey);
                for(MappedQTL qtl: qtls){
                    Record record = new Record();
                    record.append(String.valueOf(qtl.getQTL().getRgdId()));
                    record.append(qtl.getQTL().getSymbol());
                    record.append(qtl.getQTL().getName());
                    record.append("QTL");
                    record.append(qtl.getChromosome());
                    record.append(String.valueOf(qtl.getStart()));
                    record.append(String.valueOf(qtl.getStop()));
                    report.append(record);
                }

            }
            if(objType.equalsIgnoreCase("sslp") || objType.equalsIgnoreCase("all")){
                SSLPDAO sdao = new SSLPDAO();
                List<MappedSSLP> sslps = sdao.getActiveMappedSSLPs(chr,start,stop,mapKey);
                for(MappedSSLP sslp: sslps){
                    Record record = new Record();
                    record.append(String.valueOf(sslp.getSSLP().getRgdId()));
                    record.append(sslp.getSSLP().getName());
                    record.append(sslp.getSSLP().getName());
                    record.append("SSLP");
                    record.append(sslp.getChromosome());
                    record.append(String.valueOf(sslp.getStart()));
                    record.append(String.valueOf(sslp.getStop()));
                    report.append(record);
                }

            }
            if (objType.equalsIgnoreCase("strain") || objType.equalsIgnoreCase("all")){
                StrainDAO strainDAO = new StrainDAO();
                List<MappedStrain> strains = strainDAO.getActiveMappedStrainPositions(chr,start,stop,mapKey);
                for (MappedStrain s : strains){
                    Record record = new Record();
                    record.append(String.valueOf(s.getStrain().getRgdId()));
                    record.append(s.getStrain().getSymbol());
                    record.append(s.getStrain().getName());
                    record.append("STRAIN");
                    record.append(s.getChromosome());
                    record.append(String.valueOf(s.getStart()) );
                    record.append(String.valueOf(s.getStop()) );
                    report.append(record);
                }
            }
            if (objType.equalsIgnoreCase("variant") || objType.equalsIgnoreCase("all")) {
                try {
                    String species = SpeciesType.getCommonName(SpeciesType.getSpeciesTypeKeyForMap(mapKey)).replace(" ", "");
                    String indexName = RgdContext.getESVariantIndexName("variants_" + species.toLowerCase() + mapKey);

                    BoolQueryBuilder qb = QueryBuilders.boolQuery()
                            .must(QueryBuilders.termQuery("chromosome.keyword", chr))
                            .filter(QueryBuilders.rangeQuery("startPos").gte(start).lte(stop));

                    SearchSourceBuilder srb = new SearchSourceBuilder();
                    srb.query(qb);
                    srb.size(10000);
                    srb.sort("startPos", org.elasticsearch.search.sort.SortOrder.ASC);

                    // Change header for variant-only downloads
                    if (objType.equalsIgnoreCase("variant")) {
                        report = new Report();
                        Record varHeader = new Record();
                        varHeader.append("Variant RGD ID");
                        varHeader.append("rsID");
                        varHeader.append("Chr");
                        varHeader.append("Position");
                        varHeader.append("Ref Nucleotide");
                        varHeader.append("Var Nucleotide");
                        varHeader.append("Variant Type");
                        varHeader.append("Sample ID");
                        varHeader.append("Sample Name");
                        report.append(varHeader);
                    }

                    SearchRequest searchRequest = new SearchRequest(indexName);
                    searchRequest.source(srb);
                    searchRequest.scroll(TimeValue.timeValueMinutes(1L));

                    SearchResponse sr = ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
                    String scrollId = sr.getScrollId();

                    for (SearchHit hit : sr.getHits().getHits()) {
                        Map<String, Object> src = hit.getSourceAsMap();
                        Record record = new Record();
                        record.append(String.valueOf(src.getOrDefault("variant_id", "")));
                        record.append(String.valueOf(src.getOrDefault("rsId", "")));
                        record.append(String.valueOf(src.getOrDefault("chromosome", "")));
                        record.append(String.valueOf(src.getOrDefault("startPos", "")));
                        record.append(String.valueOf(src.getOrDefault("refNuc", "")));
                        record.append(String.valueOf(src.getOrDefault("varNuc", "")));
                        record.append(String.valueOf(src.getOrDefault("variantType", "")));
                        Object sampleIdObj = src.getOrDefault("sampleId", "");
                        record.append(String.valueOf(sampleIdObj));
                        try {
                            int sid = Integer.parseInt(String.valueOf(sampleIdObj));
                            Sample sample = SampleManager.getInstance().getSampleName(sid);
                            record.append(sample != null ? sample.getAnalysisName() : "");
                        } catch (Exception ex) { record.append(""); }
                        report.append(record);
                    }

                    while (sr.getHits().getHits().length > 0) {
                        SearchScrollRequest scrollRequest = new SearchScrollRequest(scrollId);
                        scrollRequest.scroll(TimeValue.timeValueSeconds(60));
                        sr = ClientInit.getClient().scroll(scrollRequest, RequestOptions.DEFAULT);
                        scrollId = sr.getScrollId();
                        for (SearchHit hit : sr.getHits().getHits()) {
                            Map<String, Object> src = hit.getSourceAsMap();
                            Record record = new Record();
                            record.append(String.valueOf(src.getOrDefault("variant_id", "")));
                            record.append(String.valueOf(src.getOrDefault("rsId", "")));
                            record.append(String.valueOf(src.getOrDefault("chromosome", "")));
                            record.append(String.valueOf(src.getOrDefault("startPos", "")));
                            record.append(String.valueOf(src.getOrDefault("refNuc", "")));
                            record.append(String.valueOf(src.getOrDefault("varNuc", "")));
                            record.append(String.valueOf(src.getOrDefault("variantType", "")));
                            record.append(String.valueOf(src.getOrDefault("sampleId", "")));
                            report.append(record);
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            request.setAttribute("report",report);
            return new ModelAndView(path + "report_csv.jsp");
        }
        return new ModelAndView(path + "searchByPosition.jsp");
        }
    }
