package edu.mcw.rgd.search.elasticsearch1.service;

import edu.mcw.rgd.search.elasticsearch1.model.SearchBean;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;
import org.apache.lucene.search.join.ScoreMode;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.client.RequestOptions;
import org.elasticsearch.index.query.*;
import org.elasticsearch.search.aggregations.AggregationBuilder;
import org.elasticsearch.search.aggregations.AggregationBuilders;
import org.elasticsearch.search.aggregations.BucketOrder;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.elasticsearch.search.fetch.subphase.highlight.HighlightBuilder;
import org.elasticsearch.search.sort.NestedSortBuilder;
import org.elasticsearch.search.sort.SortBuilders;
import org.elasticsearch.search.sort.SortOrder;

import java.io.IOException;
import java.util.*;

/**
 * Service for building and executing Elasticsearch queries.
 */
public class QueryService1 {

    // Category constants
    private static final String GENERAL = "general";
    private static final String GENE = "Gene";
    private static final String STRAIN = "Strain";
    private static final String QTL = "QTL";
    private static final String SSLP = "SSLP";
    private static final String VARIANT = "variant";
    private static final String ONTOLOGY = "Ontology";

    // Field constants
    private static final String KEYWORD_SUFFIX = ".keyword";
    private static final String SYMBOL_FIELD = "symbol.symbol";
    private static final String TERM_FIELD = "term.symbol";
    private static final String CATEGORY_KEYWORD = "category.keyword";
    private static final String SPECIES_KEYWORD = "species.keyword";

    // Boost values
    private static final float EXACT_MATCH_BOOST = 2000f;
    private static final float GENE_BOOST = 1200f;
    private static final float STRAIN_BOOST = 1100f;
    private static final float QTL_BOOST = 1000f;
    private static final float VARIANT_BOOST = 900f;
    private static final float SSLP_BOOST = 500f;
    private static final float NGRAM_BOOST = 200f;

    // Aggregation sizes
    private static final int DEFAULT_AGG_SIZE = 20;
    private static final int LARGE_AGG_SIZE = 500;
    private static final int MEDIUM_AGG_SIZE = 200;
    private static final int ASSEMBLY_AGG_SIZE = 100;

    private static final List<String> SEARCH_PRIMARY_FIELDS = Arrays.asList("name", "symbol");
    private static final List<String> AGG_FIELDS = Arrays.asList("species", "category", "type", "trait", "assembly");
    private static final Set<String> SPECIES_SET = Set.of("rat", "human", "mouse", "bonobo", "squirrel", "dog", "chinchilla");
    private static final Set<String> CATEGORY_SET = Set.of(
            "gene", "genes", "strain", "strains", "qtl", "qtls", "sslp", "sslps",
            "reference", "references", "ontology", "ontologies", "variant", "variants",
            "promoter", "promoters", "cell lines", "cell line"
    );


    public SearchResponse getSearchResponse(String term, SearchBean sb) throws IOException {
        SearchSourceBuilder sourceBuilder = new SearchSourceBuilder();
        sourceBuilder.query(boolQueryBuilder(term, sb));

        if (sb != null) {
            applySorting(sourceBuilder, sb);
            applyAggregations(sourceBuilder, sb);
            applyPaginationAndHighlighting(sourceBuilder, sb);
            applyPostFilters(sourceBuilder, sb);
        }

        SearchRequest searchRequest = new SearchRequest(RgdContext.getESIndexName("search"));
        searchRequest.source(sourceBuilder);
        return ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
    }

    private void applySorting(SearchSourceBuilder sourceBuilder, SearchBean sb) {
        String sortBy = sb.getSortBy();
        String category = sb.getCategory();
        SortOrder order = "asc".equalsIgnoreCase(sb.getSortOrder()) ? SortOrder.ASC : SortOrder.DESC;

        if ("relevance".equalsIgnoreCase(sortBy) && !VARIANT.equalsIgnoreCase(category)) {
            sourceBuilder.sort(SortBuilders.scoreSort().order(SortOrder.DESC));
            return;
        }

        if ("symbol".equalsIgnoreCase(sortBy)) {
            sourceBuilder.sort(SortBuilders.fieldSort(sortBy + KEYWORD_SUFFIX)
                    .missing("_last")
                    .order(order));
            return;
        }

        // Nested sort for map data
        String sortField = VARIANT.equalsIgnoreCase(category)
                ? "mapDataList.rank"
                : "mapDataList." + sortBy;
        SortOrder nestedOrder = VARIANT.equalsIgnoreCase(category) ? SortOrder.ASC : order;

        sourceBuilder.sort(SortBuilders.fieldSort(sortField)
                .missing("_last")
                .order(nestedOrder)
                .setNestedSort(new NestedSortBuilder("mapDataList")));
    }

    private void applyAggregations(SearchSourceBuilder sourceBuilder, SearchBean sb) {
        if (sb.isPage()) {
            return;
        }

        for (String field : AGG_FIELDS) {
            AggregationBuilder agg = buildAggregations(field);
            if (agg != null) {
                sourceBuilder.aggregation(agg);
            }
        }
    }

    private void applyPaginationAndHighlighting(SearchSourceBuilder sourceBuilder, SearchBean sb) {
        sourceBuilder.highlighter(buildHighlights())
                .from(sb.getFrom())
                .size(sb.getSize());
    }

    private void applyPostFilters(SearchSourceBuilder sourceBuilder, SearchBean sb) {
        boolean hasSpecies = isNotBlank(sb.getSpecies());
        boolean isGeneralCategory = GENERAL.equalsIgnoreCase(sb.getCategory());

        if (hasSpecies && !isGeneralCategory) {
            applySpeciesAndCategoryFilters(sourceBuilder, sb);
        } else {
            applyGeneralFilters(sourceBuilder, sb);
        }
    }

    private void applySpeciesAndCategoryFilters(SearchSourceBuilder sourceBuilder, SearchBean sb) {
        BoolQueryBuilder filter = QueryBuilders.boolQuery()
                .filter(QueryBuilders.termQuery(SPECIES_KEYWORD, sb.getSpecies()))
                .filter(QueryBuilders.termQuery(CATEGORY_KEYWORD, sb.getCategory()));

        if (isNotBlank(sb.getType()) && !"null".equals(sb.getType())) {
            filter.filter(QueryBuilders.termQuery("type.keyword", sb.getType()));
            sourceBuilder.postFilter(filter);
        } else if (isNotBlank(sb.getTrait())) {
            filter.filter(QueryBuilders.termQuery("trait.keyword", sb.getTrait()));
            sourceBuilder.postFilter(filter);
        } else if (sb.getType() != null) {
            sourceBuilder.postFilter(filter);
        }
    }

    private void applyGeneralFilters(SearchSourceBuilder sourceBuilder, SearchBean sb) {
        if (isNotBlank(sb.getSpecies())) {
            sourceBuilder.postFilter(QueryBuilders.termQuery(SPECIES_KEYWORD, sb.getSpecies()));
        }

        String category = sb.getCategory();
        if (!GENERAL.equalsIgnoreCase(category) && isNotBlank(category)) {
            if (ONTOLOGY.equalsIgnoreCase(category) && isNotBlank(sb.getSubCat())) {
                sourceBuilder.postFilter(QueryBuilders.boolQuery()
                        .filter(QueryBuilders.termQuery(CATEGORY_KEYWORD, category))
                        .filter(QueryBuilders.termQuery("subcat.keyword", sb.getSubCat())));
            } else {
                sourceBuilder.postFilter(QueryBuilders.termQuery(CATEGORY_KEYWORD, category));
            }
        }
    }

    private boolean isNotBlank(String str) {
        return str != null && !str.isEmpty();
    }

    public BoolQueryBuilder boolQueryBuilder(String term, SearchBean sb) {
        BoolQueryBuilder builder = new BoolQueryBuilder();
        builder.must(getDisMaxQuery(term, sb));

        if (sb == null) {
            return builder;
        }

        // Basic filters
        addCategoryFilter(builder, sb);
        addSpeciesFilter(builder, sb);
        addAssemblyFilter(builder, sb);
        addChromosomeFilter(builder, sb);
        addPositionRangeFilter(builder, sb);

        // Additional filters
        addTermFilter(builder, "polyphenStatus.keyword", sb.getPolyphenStatus());
        addTermFilter(builder, "variantCategory.keyword", sb.getVariantCategory());
        addTermFilter(builder, "analysisName.keyword", sb.getSample());
        addTermFilter(builder, "regionName.keyword", sb.getRegion());
        addTermFilter(builder, "expressionLevel.keyword", sb.getExpressionLevel());
        addTermFilter(builder, "strainTerms.keyword", sb.getStrainTerms());
        addTermFilter(builder, "tissueTerms.keyword", sb.getTissueTerms());
        addTermFilter(builder, "cellTypeTerms.keyword", sb.getCellTypeTerms());
        addTermFilter(builder, "conditionTerms.keyword", sb.getConditions());
        addTermFilter(builder, "expressionSource.keyword", sb.getExpressionSource());

        return builder;
    }

    private void addCategoryFilter(BoolQueryBuilder builder, SearchBean sb) {
        String category = sb.getCategory();
        if (isNotBlank(category) && !GENERAL.equalsIgnoreCase(category)) {
            builder.filter(QueryBuilders.termQuery(CATEGORY_KEYWORD, category));
        }
    }

    private void addSpeciesFilter(BoolQueryBuilder builder, SearchBean sb) {
        if (isNotBlank(sb.getSpecies())) {
            builder.filter(QueryBuilders.termQuery(SPECIES_KEYWORD, sb.getSpecies()));
        }
    }

    private void addAssemblyFilter(BoolQueryBuilder builder, SearchBean sb) {
        String assembly = sb.getAssembly();
        if (isNotBlank(assembly) && !"all".equalsIgnoreCase(assembly)) {
            builder.filter(buildNestedMapQuery(
                    QueryBuilders.termQuery("mapDataList.map", assembly)));
        }
    }

    private void addChromosomeFilter(BoolQueryBuilder builder, SearchBean sb) {
        String chr = sb.getChr();
        if (isNotBlank(chr) && !"all".equalsIgnoreCase(chr)) {
            builder.filter(buildNestedMapQuery(
                    QueryBuilders.termQuery("mapDataList.chromosome", chr)));
        }
    }

    private void addPositionRangeFilter(BoolQueryBuilder builder, SearchBean sb) {
        if (!isNotBlank(sb.getStart()) || !isNotBlank(sb.getStop())) {
            return;
        }

        BoolQueryBuilder rangeQuery = QueryBuilders.boolQuery()
                .must(QueryBuilders.rangeQuery("mapDataList.startPos").lte(sb.getStop()))
                .must(QueryBuilders.rangeQuery("mapDataList.stopPos").gte(sb.getStart()));

        String assembly = sb.getAssembly();
        boolean hasAssembly = isNotBlank(assembly) && !"all".equalsIgnoreCase(assembly);

        if (hasAssembly) {
            rangeQuery.must(QueryBuilders.termQuery("mapDataList.map", assembly));
            if (sb.getChr() != null) {
                rangeQuery.must(QueryBuilders.rangeQuery("mapDataList.chromosome").lte(sb.getStop()));
            }
        }

        builder.filter(QueryBuilders.boolQuery().filter(
                QueryBuilders.nestedQuery("mapDataList", rangeQuery, ScoreMode.None)));
    }

    private void addTermFilter(BoolQueryBuilder builder, String field, String value) {
        if (isNotBlank(value)) {
            builder.filter(QueryBuilders.termQuery(field, value));
        }
    }

    private QueryBuilder buildNestedMapQuery(QueryBuilder query) {
        return QueryBuilders.nestedQuery("mapDataList",
                QueryBuilders.boolQuery().must(query), ScoreMode.None);
    }


    public BoolQueryBuilder getCategoryOrSpeciesQuery(String term, Map<String, String> filterMap) {
        BoolQueryBuilder builder = new BoolQueryBuilder();

        if (SPECIES_SET.contains(term.toLowerCase())) {
            return builder.must(QueryBuilders.matchPhraseQuery("species", term));
        }

        if (CATEGORY_SET.contains(term.toLowerCase())) {
            String categoryTerm = normalizeCategoryTerm(term);
            return builder.must(QueryBuilders.matchPhraseQuery("category", categoryTerm));
        }

        return null;
    }

    private String normalizeCategoryTerm(String term) {
        // SSLP is a special case - don't strip the 's'
        if ("sslp".equalsIgnoreCase(term)) {
            return term;
        }

        // Strip trailing 's' for plural forms (genes -> gene, strains -> strain)
        if (term.endsWith("s") && term.length() > 1) {
            return term.substring(0, term.length() - 1);
        }

        return term;
    }

    public QueryBuilder getDisMaxQuery(String term, SearchBean sb) {
        DisMaxQueryBuilder dqb = new DisMaxQueryBuilder();

        // Handle empty term
        if (!isNotBlank(term) && sb != null) {
            return dqb.add(QueryBuilders.boolQuery()
                    .must(QueryBuilders.matchAllQuery())
                    .must(QueryBuilders.termQuery(CATEGORY_KEYWORD, sb.getCategory())));
        }

        // Handle null search bean
        if (sb == null) {
            return dqb.add(QueryBuilders.termQuery("term_acc", term));
        }

        // Handle specific match types
        String matchType = sb.getMatchType();
        if (isNotBlank(matchType) && !"contains".equalsIgnoreCase(matchType)) {
            buildQuery(sb, dqb);
            return dqb;
        }

        // Build default query with category-specific boosting
        addCategoryBoostedQueries(dqb, term, sb);
        addExactMatchQueries(dqb, term);

        if (isAccessionId(term)) {
            dqb.add(QueryBuilders.boolQuery()
                    .must(QueryBuilders.termQuery("synonyms.symbol", term))
                    .must(QueryBuilders.termQuery(CATEGORY_KEYWORD, ONTOLOGY))
                    .boost(EXACT_MATCH_BOOST));
        } else {
            addMultiMatchQueries(dqb, term);
        }

        return dqb;
    }

    private void addCategoryBoostedQueries(DisMaxQueryBuilder dqb, String term, SearchBean sb) {
        String category = sb.getCategory();

        // Add category-specific boosted queries
        if (matchesCategory(category, "gene")) {
            addBoostedSymbolQuery(dqb, term, GENE, GENE_BOOST);
        }
        if (matchesCategory(category, "sslp")) {
            addBoostedSymbolQuery(dqb, term, SSLP, SSLP_BOOST);
        }
        if (matchesCategory(category, "strain")) {
            addBoostedSymbolQuery(dqb, term, STRAIN, STRAIN_BOOST);
            // Also add ngram match for strains
            dqb.add(QueryBuilders.boolQuery()
                    .must(QueryBuilders.termQuery("htmlStrippedSymbol.ngram", term))
                    .must(QueryBuilders.termQuery(CATEGORY_KEYWORD, STRAIN))
                    .boost(NGRAM_BOOST));
        }
        if (matchesCategory(category, "variant")) {
            addBoostedSymbolQuery(dqb, term, "Variant", VARIANT_BOOST);
        }
        if (matchesCategory(category, "qtl")) {
            addBoostedSymbolQuery(dqb, term, QTL, QTL_BOOST);
        }
    }

    private boolean matchesCategory(String category, String targetCategory) {
        return category != null && (
                category.isEmpty() ||
                category.equalsIgnoreCase(targetCategory) ||
                GENERAL.equalsIgnoreCase(category));
    }

    private void addBoostedSymbolQuery(DisMaxQueryBuilder dqb, String term, String categoryValue, float boost) {
        dqb.add(QueryBuilders.boolQuery()
                .must(QueryBuilders.termQuery(SYMBOL_FIELD, term))
                .must(QueryBuilders.termQuery(CATEGORY_KEYWORD, categoryValue))
                .boost(boost));
    }

    private void addExactMatchQueries(DisMaxQueryBuilder dqb, String term) {
        dqb.add(QueryBuilders.termQuery(SYMBOL_FIELD, term).boost(EXACT_MATCH_BOOST));
        dqb.add(QueryBuilders.termQuery(TERM_FIELD, term).boost(EXACT_MATCH_BOOST));
        dqb.add(QueryBuilders.termQuery("expressedGeneSymbols.symbol", term).boost(EXACT_MATCH_BOOST));
    }

    private void addMultiMatchQueries(DisMaxQueryBuilder dqb, String term) {
        dqb.add(QueryBuilders.multiMatchQuery(term)
                .field(SYMBOL_FIELD, 100)
                .field(TERM_FIELD, 100)
                .analyzer("standard")
                .type(MultiMatchQueryBuilder.Type.PHRASE_PREFIX)
                .boost(10));

        dqb.add(QueryBuilders.multiMatchQuery(term)
                .type(MultiMatchQueryBuilder.Type.PHRASE_PREFIX)
                .analyzer("standard")
                .boost(8));

        dqb.add(QueryBuilders.multiMatchQuery(term)
                .type(MultiMatchQueryBuilder.Type.PHRASE)
                .analyzer("standard")
                .boost(5));

        dqb.add(QueryBuilders.multiMatchQuery(term)
                .type(MultiMatchQueryBuilder.Type.CROSS_FIELDS)
                .operator(Operator.AND)
                .boost(3));
    }

    private boolean isAccessionId(String term) {
        return term != null && term.contains(":");
    }
    public void buildQuery(SearchBean sb, DisMaxQueryBuilder dqb) {
        switch (sb.getMatchType()) {
            case "equals" -> addExactMatchQueries(dqb, sb);
            case "begins" -> addBeginsWithQueries(dqb, sb);
            case "ends" -> addEndsWithQueries(dqb, sb);
            default -> { }
        }
    }

    private void addExactMatchQueries(DisMaxQueryBuilder dqb, SearchBean sb) {
        String term = sb.getTerm();
        String category = sb.getCategory();
        float boost = 1000f;

        dqb.add(buildCategoryMatchQuery(SYMBOL_FIELD, term, category, boost));
        dqb.add(buildCategoryMatchQuery("name.symbol", term, category, boost));
    }

    private void addBeginsWithQueries(DisMaxQueryBuilder dqb, SearchBean sb) {
        String term = sb.getTerm();
        String category = sb.getCategory();
        float boost = 1000f;

        dqb.add(QueryBuilders.boolQuery()
                .must(QueryBuilders.matchPhrasePrefixQuery("symbol", term))
                .must(QueryBuilders.termQuery(CATEGORY_KEYWORD, category).caseInsensitive(true))
                .boost(boost));

        dqb.add(QueryBuilders.boolQuery()
                .must(QueryBuilders.matchPhrasePrefixQuery("name.symbol", term))
                .must(QueryBuilders.termQuery(CATEGORY_KEYWORD, category).caseInsensitive(true))
                .boost(boost));
    }

    private void addEndsWithQueries(DisMaxQueryBuilder dqb, SearchBean sb) {
        String term = sb.getTerm();
        String category = sb.getCategory();
        String regexPattern = ".*(" + term + ")";
        float boost = 1000f;

        for (String field : SEARCH_PRIMARY_FIELDS) {
            dqb.add(QueryBuilders.boolQuery()
                    .must(QueryBuilders.regexpQuery(field + ".symbol", regexPattern).caseInsensitive(true))
                    .must(QueryBuilders.termQuery(CATEGORY_KEYWORD, category))
                    .boost(boost));

            dqb.add(QueryBuilders.boolQuery()
                    .must(QueryBuilders.regexpQuery(field + KEYWORD_SUFFIX, regexPattern).caseInsensitive(true))
                    .must(QueryBuilders.termQuery(CATEGORY_KEYWORD, category))
                    .boost(boost));
        }
    }

    private BoolQueryBuilder buildCategoryMatchQuery(String field, String term, String category, float boost) {
        return QueryBuilders.boolQuery()
                .must(QueryBuilders.termQuery(field, term))
                .must(QueryBuilders.termQuery(CATEGORY_KEYWORD, category).caseInsensitive(true))
                .boost(boost);
    }

    public AggregationBuilder buildAggregations(String aggField) {
        return switch (aggField.toLowerCase()) {
            case "species" -> buildSpeciesAggregation(aggField);
            case "category" -> buildCategoryAggregation(aggField);
            case "assembly" -> buildAssemblyAggregation(aggField);
            default -> buildDefaultAggregation(aggField);
        };
    }

    private AggregationBuilder buildSpeciesAggregation(String aggField) {
        var categoryFilter = AggregationBuilders.terms("categoryFilter").field(CATEGORY_KEYWORD)
                .subAggregation(AggregationBuilders.terms("typeFilter").field("type.keyword"))
                .subAggregation(AggregationBuilders.terms("trait").field("trait.keyword").size(LARGE_AGG_SIZE))
                .subAggregation(AggregationBuilders.terms("polyphen").field("polyphenStatus.keyword"))
                .subAggregation(AggregationBuilders.terms("region").field("regionName.keyword").size(MEDIUM_AGG_SIZE))
                .subAggregation(AggregationBuilders.terms("expressionLevel").field("expressionLevel.keyword"))
                .subAggregation(AggregationBuilders.terms("strainTerms").field("strainTerms.keyword").size(LARGE_AGG_SIZE))
                .subAggregation(AggregationBuilders.terms("tissueTerms").field("tissueTerms.keyword").size(LARGE_AGG_SIZE))
                .subAggregation(AggregationBuilders.terms("cellTypeTerms").field("cellTypeTerms.keyword").size(LARGE_AGG_SIZE))
                .subAggregation(AggregationBuilders.terms("conditions").field("conditionTerms.keyword").size(LARGE_AGG_SIZE))
                .subAggregation(AggregationBuilders.terms("expressionSource").field("expressionSource.keyword"))
                .subAggregation(AggregationBuilders.terms("sample").field("analysisName.keyword").size(MEDIUM_AGG_SIZE))
                .subAggregation(AggregationBuilders.terms("variantCategory").field("variantCategory.keyword").size(LARGE_AGG_SIZE));

        return AggregationBuilders.terms(aggField).field(aggField + KEYWORD_SUFFIX).size(DEFAULT_AGG_SIZE)
                .subAggregation(categoryFilter)
                .subAggregation(AggregationBuilders.terms("ontologies").field("subcat.keyword").size(50).order(BucketOrder.key(true)));
    }

    private AggregationBuilder buildCategoryAggregation(String aggField) {
        return AggregationBuilders.terms(aggField).field(aggField + KEYWORD_SUFFIX)
                .subAggregation(AggregationBuilders.terms("speciesFilter").field(SPECIES_KEYWORD).size(DEFAULT_AGG_SIZE))
                .subAggregation(AggregationBuilders.terms("subspecies").field(SPECIES_KEYWORD).size(DEFAULT_AGG_SIZE))
                .subAggregation(AggregationBuilders.terms("typeFilter").field("type.keyword"))
                .subAggregation(AggregationBuilders.terms("polyphen").field("polyphenStatus.keyword"))
                .subAggregation(AggregationBuilders.terms("region").field("regionName.keyword"))
                .subAggregation(AggregationBuilders.terms("expressionLevel").field("expressionLevel.keyword"))
                .subAggregation(AggregationBuilders.terms("sample").field("analysisName.keyword"))
                .subAggregation(AggregationBuilders.terms("variantCategory").field("variantCategory.keyword"))
                .subAggregation(AggregationBuilders.terms("ontologies").field("subcat.keyword").size(DEFAULT_AGG_SIZE).order(BucketOrder.key(true)));
    }

    private AggregationBuilder buildAssemblyAggregation(String aggField) {
        return AggregationBuilders.nested("assemblyAggs", "mapDataList")
                .subAggregation(AggregationBuilders.terms(aggField).field("mapDataList.map").size(ASSEMBLY_AGG_SIZE).order(BucketOrder.key(true)));
    }

    private AggregationBuilder buildDefaultAggregation(String aggField) {
        return AggregationBuilders.terms(aggField).field(aggField + KEYWORD_SUFFIX)
                .subAggregation(AggregationBuilders.terms("subspecies").field(SPECIES_KEYWORD).size(DEFAULT_AGG_SIZE))
                .subAggregation(AggregationBuilders.terms("ontologies").field("subcat.keyword").size(ASSEMBLY_AGG_SIZE).order(BucketOrder.key(true)));
    }

    public HighlightBuilder buildHighlights() {
        return new HighlightBuilder().field("*");
    }

    public SearchResponse getSearchResponseByTermAcc(String term) throws Exception {
        SearchSourceBuilder sourceBuilder = new SearchSourceBuilder()
                .query(QueryBuilders.termQuery("term_acc", term));

        SearchRequest searchRequest = new SearchRequest(RgdContext.getESIndexName("search"))
                .source(sourceBuilder);

        return ClientInit.getClient().search(searchRequest, RequestOptions.DEFAULT);
    }
}