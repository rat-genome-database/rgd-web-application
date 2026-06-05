package edu.mcw.rgd.search;


import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch._types.SortOrder;
import co.elastic.clients.elasticsearch._types.Time;
import co.elastic.clients.elasticsearch.core.ScrollResponse;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import co.elastic.clients.json.JsonData;
import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.reporting.Record;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.vv.SampleManager;
import edu.mcw.rgd.web.RgdContext;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
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

                    final int startF = start;
                    final int stopF = stop;
                    final String chrF = chr;
                    ElasticsearchClient client = ClientInit.getClient();
                    SearchResponse<java.util.Map> sr = client.search(s -> s
                                    .index(indexName)
                                    .size(10000)
                                    .scroll(Time.of(t -> t.time("1m")))
                                    .query(q -> q.bool(b -> b
                                            .must(m -> m.term(t -> t.field("chromosome.keyword").value(FieldValue.of(chrF))))
                                            .filter(f -> f.range(r -> r.untyped(u -> u
                                                    .field("startPos")
                                                    .gte(JsonData.of(startF))
                                                    .lte(JsonData.of(stopF)))))
                                    ))
                                    .sort(sort -> sort.field(fs -> fs.field("startPos").order(SortOrder.Asc))),
                            java.util.Map.class);
                    String scrollId = sr.scrollId();

                    for (Hit<java.util.Map> hit : sr.hits().hits()) {
                        @SuppressWarnings("unchecked")
                        Map<String, Object> src = (Map<String, Object>) hit.source();
                        appendVariantRecord(report, src);
                    }

                    boolean variantOnly = objType.equalsIgnoreCase("variant");
                    int pageHits = sr.hits().hits().size();
                    while (pageHits > 0) {
                        final String scrollIdF = scrollId;
                        ScrollResponse<java.util.Map> scrollResp = client.scroll(sb -> sb
                                        .scrollId(scrollIdF)
                                        .scroll(Time.of(t -> t.time("60s"))),
                                java.util.Map.class);
                        scrollId = scrollResp.scrollId();
                        pageHits = scrollResp.hits().hits().size();
                        for (Hit<java.util.Map> hit : scrollResp.hits().hits()) {
                            @SuppressWarnings("unchecked")
                            Map<String, Object> src = (Map<String, Object>) hit.source();
                            if (variantOnly) {
                                appendVariantRecord(report, src);
                            } else {
                                appendVariantRecordSimple(report, src);
                            }
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

    private void appendVariantRecord(Report report, Map<String, Object> src) {
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

    private void appendVariantRecordSimple(Report report, Map<String, Object> src) {
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
