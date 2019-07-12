package edu.mcw.rgd.carpenovo.vvservice;

import edu.mcw.rgd.carpenovo.dao.VariantSearchBeanNew;
import edu.mcw.rgd.datamodel.MappedGene;
import edu.mcw.rgd.datamodel.VariantSearchBean;
import edu.mcw.rgd.search.elasticsearch.client.ClientInit;
import edu.mcw.rgd.search.elasticsearch1.model.SearchBean;
import edu.mcw.rgd.web.RgdContext;
import org.elasticsearch.action.search.SearchRequestBuilder;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.search.SearchType;
import org.elasticsearch.index.query.*;

import java.util.List;

/**
 * Created by jthota on 7/1/2019.
 */
public class VVService {

    public SearchResponse getVariants(VariantSearchBeanNew vsb){
        System.out.println(vsb.getChromosome()+"\t"+ vsb.getMapKey()+"\t"+ vsb.getStartPosition()+"\t"+vsb.getStopPosition()
        +"\t"+ vsb.getSampleIds());
     BoolQueryBuilder builder=this.boolQueryBuilder(vsb);
        SearchRequestBuilder srb = ClientInit.getClient().prepareSearch(RgdContext.getESIndexName("variant"))
                .setQuery(builder)
                .setSize(10000);
        return srb
                .setSearchType(SearchType.QUERY_THEN_FETCH)
                .setRequestCache(true)
                .execute().actionGet();


    }

    public BoolQueryBuilder boolQueryBuilder(VariantSearchBeanNew vsb){
        BoolQueryBuilder builder=new BoolQueryBuilder();
        builder.must(this.getDisMaxQuery(vsb));
        return builder;
    }
    public QueryBuilder getDisMaxQuery(VariantSearchBeanNew vsb){
        DisMaxQueryBuilder dqb=new DisMaxQueryBuilder();
        List<Integer> sampleIds=vsb.getSampleIds();
        String chromosome=vsb.getChromosome();
        BoolQueryBuilder qb=
               (QueryBuilders.boolQuery().must(QueryBuilders.matchAllQuery())
                 .filter(QueryBuilders.matchQuery("chromosome", chromosome))
                     .filter(QueryBuilders.termsQuery("sampleId", sampleIds.toArray()))

               );
        if(vsb.getStartPosition()!=null && vsb.getStartPosition()>=0 && vsb.getStopPosition()!=null && vsb.getStartPosition()>0){
            qb.filter(QueryBuilders.rangeQuery("startPos").from(vsb.getStartPosition()).to(vsb.getStopPosition()).includeLower(true).includeUpper(true));
        }
        if(vsb.getMappedGenes()!=null){
            for(MappedGene g:vsb.getMappedGenes()){
                System.out.println(g.getGene().getSymbol());
            }
        }

          dqb.add(qb);
        return dqb;

    }
}
