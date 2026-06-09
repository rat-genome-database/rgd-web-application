package edu.mcw.rgd.search.elasticsearch1.service;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch._types.FieldValue;
import co.elastic.clients.elasticsearch._types.SortOptions;
import co.elastic.clients.elasticsearch._types.SortOrder;
import co.elastic.clients.elasticsearch._types.aggregations.Aggregation;
import co.elastic.clients.elasticsearch._types.query_dsl.BoolQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.ChildScoreMode;
import co.elastic.clients.elasticsearch._types.query_dsl.DisMaxQuery;
import co.elastic.clients.elasticsearch._types.query_dsl.Operator;
import co.elastic.clients.elasticsearch._types.query_dsl.Query;
import co.elastic.clients.elasticsearch._types.query_dsl.TextQueryType;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Highlight;
import co.elastic.clients.elasticsearch.core.search.HighlightField;
import co.elastic.clients.json.JsonData;
import co.elastic.clients.util.NamedValue;
import edu.mcw.rgd.search.elasticsearch1.model.SearchBean;
import edu.mcw.rgd.services.ClientInit;
import edu.mcw.rgd.web.RgdContext;

import java.io.IOException;
import java.util.*;

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


    public SearchResponse<Map> getSearchResponse(String term, SearchBean sb) throws IOException {
        Query mainQuery = boolQuery(term, sb);
        List<SortOptions> sort = (sb != null) ? buildSort(sb) : Collections.emptyList();
        Map<String, Aggregation> aggs = (sb != null && !sb.isPage()) ? buildAggregations() : Collections.emptyMap();
        Query postFilter = (sb != null) ? buildPostFilter(sb) : null;
        Highlight highlight = (sb != null) ? buildHighlights() : null;
        int from = (sb != null) ? sb.getFrom() : 0;
        int size = (sb != null) ? sb.getSize() : 10;

        ElasticsearchClient client = ClientInit.getClient();
        return client.search(s -> {
            s.index(RgdContext.getESIndexName("search"))
                    .query(mainQuery)
                    .from(from)
                    .size(size);
            if (!sort.isEmpty()) {
                s.sort(sort);
            }
            if (!aggs.isEmpty()) {
                s.aggregations(aggs);
            }
            if (postFilter != null) {
                s.postFilter(postFilter);
            }
            if (highlight != null) {
                s.highlight(highlight);
            }
            return s;
        }, Map.class);
    }

    private List<SortOptions> buildSort(SearchBean sb) {
        String sortBy = sb.getSortBy();
        String category = sb.getCategory();
        SortOrder order = "asc".equalsIgnoreCase(sb.getSortOrder()) ? SortOrder.Asc : SortOrder.Desc;

        if ("relevance".equalsIgnoreCase(sortBy) && !VARIANT.equalsIgnoreCase(category)) {
            return List.of(SortOptions.of(s -> s.score(sc -> sc.order(SortOrder.Desc))));
        }

        if ("symbol".equalsIgnoreCase(sortBy)) {
            return List.of(SortOptions.of(s -> s.field(f -> f
                    .field(sortBy + KEYWORD_SUFFIX)
                    .missing("_last")
                    .order(order))));
        }

        // Nested sort for map data
        String sortField = VARIANT.equalsIgnoreCase(category)
                ? "mapDataList.rank"
                : "mapDataList." + sortBy;
        SortOrder nestedOrder = VARIANT.equalsIgnoreCase(category) ? SortOrder.Asc : order;

        return List.of(SortOptions.of(s -> s.field(f -> f
                .field(sortField)
                .missing("_last")
                .order(nestedOrder)
                .nested(ns -> ns.path("mapDataList")))));
    }

    private Map<String, Aggregation> buildAggregations() {
        Map<String, Aggregation> aggs = new LinkedHashMap<>();
        for (String field : AGG_FIELDS) {
            Aggregation agg = buildAggregation(field);
            if (agg != null) {
                aggs.put(field, agg);
            }
        }
        return aggs;
    }

    private Query buildPostFilter(SearchBean sb) {
        boolean hasSpecies = isNotBlank(sb.getSpecies());
        boolean isGeneralCategory = GENERAL.equalsIgnoreCase(sb.getCategory());

        if (hasSpecies && !isGeneralCategory) {
            return speciesAndCategoryPostFilter(sb);
        } else {
            return generalPostFilter(sb);
        }
    }

    private Query speciesAndCategoryPostFilter(SearchBean sb) {
        BoolQuery.Builder b = new BoolQuery.Builder();
        b.filter(termFilter(SPECIES_KEYWORD, sb.getSpecies()));
        b.filter(termFilter(CATEGORY_KEYWORD, sb.getCategory()));

        if (isNotBlank(sb.getType()) && !"null".equals(sb.getType())) {
            b.filter(termFilter("type.keyword", sb.getType()));
            return Query.of(q -> q.bool(b.build()));
        } else if (isNotBlank(sb.getTrait())) {
            b.filter(termFilter("trait.keyword", sb.getTrait()));
            return Query.of(q -> q.bool(b.build()));
        } else if (sb.getType() != null) {
            return Query.of(q -> q.bool(b.build()));
        }
        return null;
    }

    private Query generalPostFilter(SearchBean sb) {
        if (isNotBlank(sb.getSpecies())) {
            return termFilter(SPECIES_KEYWORD, sb.getSpecies());
        }

        String category = sb.getCategory();
        if (!GENERAL.equalsIgnoreCase(category) && isNotBlank(category)) {
            if (ONTOLOGY.equalsIgnoreCase(category) && isNotBlank(sb.getSubCat())) {
                BoolQuery.Builder b = new BoolQuery.Builder();
                b.filter(termFilter(CATEGORY_KEYWORD, category));
                b.filter(termFilter("subcat.keyword", sb.getSubCat()));
                return Query.of(q -> q.bool(b.build()));
            } else {
                return termFilter(CATEGORY_KEYWORD, category);
            }
        }
        return null;
    }

    private Query termFilter(String field, String value) {
        return Query.of(q -> q.term(t -> t.field(field).value(FieldValue.of(value))));
    }

    private boolean isNotBlank(String str) {
        return str != null && !str.isEmpty();
    }

    public Query boolQuery(String term, SearchBean sb) {
        BoolQuery.Builder b = new BoolQuery.Builder();
        b.must(getDisMaxQuery(term, sb));

        if (sb == null) {
            return Query.of(q -> q.bool(b.build()));
        }

        // Basic filters
        addCategoryFilter(b, sb);
        addSpeciesFilter(b, sb);
        addAssemblyFilter(b, sb);
        addChromosomeFilter(b, sb);
        addPositionRangeFilter(b, sb);

        // Additional filters
        addTermFilter(b, "polyphenStatus.keyword", sb.getPolyphenStatus());
        addTermFilter(b, "variantCategory.keyword", sb.getVariantCategory());
        addTermFilter(b, "analysisName.keyword", sb.getSample());
        addTermFilter(b, "regionName.keyword", sb.getRegion());
        addTermFilter(b, "expressionLevel.keyword", sb.getExpressionLevel());
        addTermFilter(b, "strainTerms.keyword", sb.getStrainTerms());
        addTermFilter(b, "tissueTerms.keyword", sb.getTissueTerms());
        addTermFilter(b, "cellTypeTerms.keyword", sb.getCellTypeTerms());
        addTermFilter(b, "conditionTerms.keyword", sb.getConditions());
        addTermFilter(b, "expressionSource.keyword", sb.getExpressionSource());

        return Query.of(q -> q.bool(b.build()));
    }

    private void addCategoryFilter(BoolQuery.Builder b, SearchBean sb) {
        String category = sb.getCategory();
        if (isNotBlank(category) && !GENERAL.equalsIgnoreCase(category)) {
            b.filter(termFilter(CATEGORY_KEYWORD, category));
        }
    }

    private void addSpeciesFilter(BoolQuery.Builder b, SearchBean sb) {
        if (isNotBlank(sb.getSpecies())) {
            b.filter(termFilter(SPECIES_KEYWORD, sb.getSpecies()));
        }
    }

    private void addAssemblyFilter(BoolQuery.Builder b, SearchBean sb) {
        String assembly = sb.getAssembly();
        if (isNotBlank(assembly) && !"all".equalsIgnoreCase(assembly)) {
            b.filter(nestedMapQuery(termFilter("mapDataList.map", assembly)));
        }
    }

    private void addChromosomeFilter(BoolQuery.Builder b, SearchBean sb) {
        String chr = sb.getChr();
        if (isNotBlank(chr) && !"all".equalsIgnoreCase(chr)) {
            b.filter(nestedMapQuery(termFilter("mapDataList.chromosome", chr)));
        }
    }

    private void addPositionRangeFilter(BoolQuery.Builder b, SearchBean sb) {
        if (!isNotBlank(sb.getStart()) || !isNotBlank(sb.getStop())) {
            return;
        }

        BoolQuery.Builder rb = new BoolQuery.Builder();
        rb.must(Query.of(q -> q.range(r -> r.untyped(u -> u.field("mapDataList.startPos").lte(JsonData.of(sb.getStop()))))));
        rb.must(Query.of(q -> q.range(r -> r.untyped(u -> u.field("mapDataList.stopPos").gte(JsonData.of(sb.getStart()))))));

        String assembly = sb.getAssembly();
        boolean hasAssembly = isNotBlank(assembly) && !"all".equalsIgnoreCase(assembly);

        if (hasAssembly) {
            rb.must(termFilter("mapDataList.map", assembly));
            if (sb.getChr() != null) {
                rb.must(Query.of(q -> q.range(r -> r.untyped(u -> u.field("mapDataList.chromosome").lte(JsonData.of(sb.getStop()))))));
            }
        }

        BoolQuery rangeQuery = rb.build();
        BoolQuery.Builder outer = new BoolQuery.Builder();
        outer.filter(Query.of(q -> q.nested(n -> n
                .path("mapDataList")
                .query(qq -> qq.bool(rangeQuery))
                .scoreMode(ChildScoreMode.None))));
        b.filter(Query.of(q -> q.bool(outer.build())));
    }

    private void addTermFilter(BoolQuery.Builder b, String field, String value) {
        if (isNotBlank(value)) {
            b.filter(termFilter(field, value));
        }
    }

    private Query nestedMapQuery(Query query) {
        return Query.of(q -> q.nested(n -> n
                .path("mapDataList")
                .query(qq -> qq.bool(b -> b.must(query)))
                .scoreMode(ChildScoreMode.None)));
    }


    public Query getCategoryOrSpeciesQuery(String term, Map<String, String> filterMap) {
        if (SPECIES_SET.contains(term.toLowerCase())) {
            BoolQuery.Builder b = new BoolQuery.Builder();
            b.must(Query.of(q -> q.matchPhrase(m -> m.field("species").query(term))));
            return Query.of(q -> q.bool(b.build()));
        }

        if (CATEGORY_SET.contains(term.toLowerCase())) {
            String categoryTerm = normalizeCategoryTerm(term);
            BoolQuery.Builder b = new BoolQuery.Builder();
            b.must(Query.of(q -> q.matchPhrase(m -> m.field("category").query(categoryTerm))));
            return Query.of(q -> q.bool(b.build()));
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

    public Query getDisMaxQuery(String term, SearchBean sb) {
        List<Query> queries = new ArrayList<>();
        // If term is numeric
        if (term.matches("\\d+")) {
            queries.add(Query.of(q -> q.matchPhrase(m -> m.field("term_acc").query(term))));
        } else {
            // Handle empty term
            if (!isNotBlank(term) && sb != null) {
                final String cat = sb.getCategory();
                BoolQuery.Builder bb = new BoolQuery.Builder();
                bb.must(Query.of(q -> q.matchAll(ma -> ma)));
                bb.must(termFilter(CATEGORY_KEYWORD, cat));
                queries.add(Query.of(q -> q.bool(bb.build())));
                return Query.of(q -> q.disMax(DisMaxQuery.of(d -> d.queries(queries))));
            }

            // Handle null search bean
            if (sb == null) {
                queries.add(termFilter("term_acc", term));
                return Query.of(q -> q.disMax(DisMaxQuery.of(d -> d.queries(queries))));
            }

            // Handle specific match types
            String matchType = sb.getMatchType();
            if (isNotBlank(matchType) && !"contains".equalsIgnoreCase(matchType)) {
                buildQuery(sb, queries);
                return Query.of(q -> q.disMax(DisMaxQuery.of(d -> d.queries(queries))));
            }

            // Build default query with category-specific boosting
            addCategoryBoostedQueries(queries, term, sb);
            addExactMatchQueries(queries, term);

            if (isAccessionId(term)) {
                final String t = term;
                BoolQuery.Builder bb = new BoolQuery.Builder();
                bb.must(termFilter("synonyms.symbol", t));
                bb.must(termFilter(CATEGORY_KEYWORD, ONTOLOGY));
                bb.boost(EXACT_MATCH_BOOST);
                queries.add(Query.of(q -> q.bool(bb.build())));
                queries.add(Query.of(q -> q.term(tq -> tq.field("xdbIdentifiers.lc").value(FieldValue.of(t)).boost(EXACT_MATCH_BOOST))));
            } else {
                addMultiMatchQueries(queries, term);
            }
        }
        return Query.of(q -> q.disMax(DisMaxQuery.of(d -> d.queries(queries))));
    }

    private void addCategoryBoostedQueries(List<Query> queries, String term, SearchBean sb) {
        String category = sb.getCategory();

        // Add category-specific boosted queries
        if (matchesCategory(category, "gene")) {
            addBoostedSymbolQuery(queries, term, GENE, GENE_BOOST);
        }
        if (matchesCategory(category, "sslp")) {
            addBoostedSymbolQuery(queries, term, SSLP, SSLP_BOOST);
        }
        if (matchesCategory(category, "strain")) {
            addBoostedSymbolQuery(queries, term, STRAIN, STRAIN_BOOST);
            // Also add ngram match for strains
            final String t = term;
            BoolQuery.Builder bb = new BoolQuery.Builder();
            bb.must(termFilter("htmlStrippedSymbol.ngram", t));
            bb.must(termFilter(CATEGORY_KEYWORD, STRAIN));
            bb.boost(NGRAM_BOOST);
            queries.add(Query.of(q -> q.bool(bb.build())));
        }
        if (matchesCategory(category, "variant")) {
            addBoostedSymbolQuery(queries, term, "Variant", VARIANT_BOOST);
        }
        if (matchesCategory(category, "qtl")) {
            addBoostedSymbolQuery(queries, term, QTL, QTL_BOOST);
        }
    }

    private boolean matchesCategory(String category, String targetCategory) {
        return category != null && (
                category.isEmpty() ||
                category.equalsIgnoreCase(targetCategory) ||
                GENERAL.equalsIgnoreCase(category));
    }

    private void addBoostedSymbolQuery(List<Query> queries, String term, String categoryValue, float boost) {
        BoolQuery.Builder bb = new BoolQuery.Builder();
        bb.must(termFilter(SYMBOL_FIELD, term));
        bb.must(termFilter(CATEGORY_KEYWORD, categoryValue));
        bb.boost(boost);
        queries.add(Query.of(q -> q.bool(bb.build())));
    }

    private void addExactMatchQueries(List<Query> queries, String term) {
        final String t = term;
        queries.add(Query.of(q -> q.term(tq -> tq.field(SYMBOL_FIELD).value(FieldValue.of(t)).boost(EXACT_MATCH_BOOST))));
        queries.add(Query.of(q -> q.term(tq -> tq.field(TERM_FIELD).value(FieldValue.of(t)).boost(EXACT_MATCH_BOOST))));
        queries.add(Query.of(q -> q.term(tq -> tq.field("expressedGeneSymbols.symbol").value(FieldValue.of(t)).boost(EXACT_MATCH_BOOST))));
    }

    private void addMultiMatchQueries(List<Query> queries, String term) {
        final String t = term;
        queries.add(Query.of(q -> q.multiMatch(m -> m
                .query(t)
                .fields(SYMBOL_FIELD + "^100", TERM_FIELD + "^100")
                .analyzer("standard")
                .type(TextQueryType.PhrasePrefix)
                .boost(10f))));

        queries.add(Query.of(q -> q.multiMatch(m -> m
                .query(t)
                .type(TextQueryType.PhrasePrefix)
                .analyzer("standard")
                .boost(8f))));

        queries.add(Query.of(q -> q.multiMatch(m -> m
                .query(t)
                .type(TextQueryType.Phrase)
                .analyzer("standard")
                .boost(5f))));

        queries.add(Query.of(q -> q.multiMatch(m -> m
                .query(t)
                .type(TextQueryType.CrossFields)
                .operator(Operator.And)
                .boost(3f))));
    }

    private boolean isAccessionId(String term) {
        return term != null && term.contains(":");
    }

    public void buildQuery(SearchBean sb, List<Query> queries) {
        switch (sb.getMatchType()) {
            case "equals" -> addExactMatchQueriesSb(queries, sb);
            case "begins" -> addBeginsWithQueries(queries, sb);
            case "ends" -> addEndsWithQueries(queries, sb);
            default -> { }
        }
    }

    private void addExactMatchQueriesSb(List<Query> queries, SearchBean sb) {
        String term = sb.getTerm();
        String category = sb.getCategory();
        float boost = 1000f;

        queries.add(buildCategoryMatchQuery(SYMBOL_FIELD, term, category, boost));
        queries.add(buildCategoryMatchQuery("name.symbol", term, category, boost));
    }

    private void addBeginsWithQueries(List<Query> queries, SearchBean sb) {
        final String term = sb.getTerm();
        final String category = sb.getCategory();
        final float boost = 1000f;

        BoolQuery.Builder b1 = new BoolQuery.Builder();
        b1.must(Query.of(q -> q.matchPhrasePrefix(m -> m.field("symbol").query(term))));
        b1.must(Query.of(q -> q.term(t -> t.field(CATEGORY_KEYWORD).value(FieldValue.of(category)).caseInsensitive(true))));
        b1.boost(boost);
        queries.add(Query.of(q -> q.bool(b1.build())));

        BoolQuery.Builder b2 = new BoolQuery.Builder();
        b2.must(Query.of(q -> q.matchPhrasePrefix(m -> m.field("name.symbol").query(term))));
        b2.must(Query.of(q -> q.term(t -> t.field(CATEGORY_KEYWORD).value(FieldValue.of(category)).caseInsensitive(true))));
        b2.boost(boost);
        queries.add(Query.of(q -> q.bool(b2.build())));
    }

    private void addEndsWithQueries(List<Query> queries, SearchBean sb) {
        final String term = sb.getTerm();
        final String category = sb.getCategory();
        final String regexPattern = ".*(" + term + ")";
        final float boost = 1000f;

        for (String field : SEARCH_PRIMARY_FIELDS) {
            final String f1 = field + ".symbol";
            BoolQuery.Builder b1 = new BoolQuery.Builder();
            b1.must(Query.of(q -> q.regexp(r -> r.field(f1).value(regexPattern).caseInsensitive(true))));
            b1.must(termFilter(CATEGORY_KEYWORD, category));
            b1.boost(boost);
            queries.add(Query.of(q -> q.bool(b1.build())));

            final String f2 = field + KEYWORD_SUFFIX;
            BoolQuery.Builder b2 = new BoolQuery.Builder();
            b2.must(Query.of(q -> q.regexp(r -> r.field(f2).value(regexPattern).caseInsensitive(true))));
            b2.must(termFilter(CATEGORY_KEYWORD, category));
            b2.boost(boost);
            queries.add(Query.of(q -> q.bool(b2.build())));
        }
    }

    private Query buildCategoryMatchQuery(String field, String term, String category, float boost) {
        BoolQuery.Builder b = new BoolQuery.Builder();
        b.must(termFilter(field, term));
        b.must(Query.of(q -> q.term(t -> t.field(CATEGORY_KEYWORD).value(FieldValue.of(category)).caseInsensitive(true))));
        b.boost(boost);
        return Query.of(q -> q.bool(b.build()));
    }

    public Aggregation buildAggregation(String aggField) {
        return switch (aggField.toLowerCase()) {
            case "species" -> buildSpeciesAggregation(aggField);
            case "category" -> buildCategoryAggregation(aggField);
            case "assembly" -> buildAssemblyAggregation(aggField);
            default -> buildDefaultAggregation(aggField);
        };
    }

    private Aggregation buildSpeciesAggregation(String aggField) {
        Map<String, Aggregation> categorySubAggs = new LinkedHashMap<>();
        categorySubAggs.put("typeFilter", termsAgg("type.keyword", DEFAULT_AGG_SIZE));
        categorySubAggs.put("trait", termsAgg("trait.keyword", LARGE_AGG_SIZE));
        categorySubAggs.put("polyphen", termsAgg("polyphenStatus.keyword", DEFAULT_AGG_SIZE));
        categorySubAggs.put("region", termsAgg("regionName.keyword", MEDIUM_AGG_SIZE));
        categorySubAggs.put("expressionLevel", termsAgg("expressionLevel.keyword", DEFAULT_AGG_SIZE));
        categorySubAggs.put("strainTerms", termsAgg("strainTerms.keyword", LARGE_AGG_SIZE));
        categorySubAggs.put("tissueTerms", termsAgg("tissueTerms.keyword", LARGE_AGG_SIZE));
        categorySubAggs.put("cellTypeTerms", termsAgg("cellTypeTerms.keyword", LARGE_AGG_SIZE));
        categorySubAggs.put("conditions", termsAgg("conditionTerms.keyword", LARGE_AGG_SIZE));
        categorySubAggs.put("expressionSource", termsAgg("expressionSource.keyword", DEFAULT_AGG_SIZE));
        categorySubAggs.put("sample", termsAgg("analysisName.keyword", MEDIUM_AGG_SIZE));
        categorySubAggs.put("variantCategory", termsAgg("variantCategory.keyword", LARGE_AGG_SIZE));

        Aggregation categoryFilter = Aggregation.of(a -> a
                .terms(t -> t.field(CATEGORY_KEYWORD).size(DEFAULT_AGG_SIZE))
                .aggregations(categorySubAggs));

        Aggregation ontologies = Aggregation.of(a -> a
                .terms(t -> t.field("subcat.keyword").size(50)
                        .order(List.of(NamedValue.of("_key", SortOrder.Asc)))));

        Map<String, Aggregation> assemblySubAggs = new LinkedHashMap<>();
        assemblySubAggs.put("assembly", Aggregation.of(a -> a
                .terms(t -> t.field("mapDataList.map").size(ASSEMBLY_AGG_SIZE)
                        .order(List.of(NamedValue.of("_key", SortOrder.Asc))))));
        Aggregation assemblyAggs = Aggregation.of(a -> a
                .nested(n -> n.path("mapDataList"))
                .aggregations(assemblySubAggs));

        Map<String, Aggregation> speciesSubAggs = new LinkedHashMap<>();
        speciesSubAggs.put("categoryFilter", categoryFilter);
        speciesSubAggs.put("ontologies", ontologies);
        speciesSubAggs.put("assemblyAggs", assemblyAggs);

        return Aggregation.of(a -> a
                .terms(t -> t.field(aggField + KEYWORD_SUFFIX).size(DEFAULT_AGG_SIZE))
                .aggregations(speciesSubAggs));
    }

    private Aggregation buildCategoryAggregation(String aggField) {
        Map<String, Aggregation> subAggs = new LinkedHashMap<>();
        subAggs.put("speciesFilter", termsAgg(SPECIES_KEYWORD, DEFAULT_AGG_SIZE));
        subAggs.put("subspecies", termsAgg(SPECIES_KEYWORD, DEFAULT_AGG_SIZE));
        subAggs.put("typeFilter", termsAgg("type.keyword", DEFAULT_AGG_SIZE));
        subAggs.put("polyphen", termsAgg("polyphenStatus.keyword", DEFAULT_AGG_SIZE));
        subAggs.put("region", termsAgg("regionName.keyword", DEFAULT_AGG_SIZE));
        subAggs.put("expressionLevel", termsAgg("expressionLevel.keyword", DEFAULT_AGG_SIZE));
        subAggs.put("sample", termsAgg("analysisName.keyword", DEFAULT_AGG_SIZE));
        subAggs.put("variantCategory", termsAgg("variantCategory.keyword", DEFAULT_AGG_SIZE));
        subAggs.put("ontologies", Aggregation.of(a -> a
                .terms(t -> t.field("subcat.keyword").size(DEFAULT_AGG_SIZE)
                        .order(List.of(NamedValue.of("_key", SortOrder.Asc))))));

        return Aggregation.of(a -> a
                .terms(t -> t.field(aggField + KEYWORD_SUFFIX).size(DEFAULT_AGG_SIZE))
                .aggregations(subAggs));
    }

    private Aggregation buildAssemblyAggregation(String aggField) {
        Map<String, Aggregation> subAggs = new LinkedHashMap<>();
        subAggs.put(aggField, Aggregation.of(a -> a
                .terms(t -> t.field("mapDataList.map").size(ASSEMBLY_AGG_SIZE)
                        .order(List.of(NamedValue.of("_key", SortOrder.Asc))))));
        return Aggregation.of(a -> a
                .nested(n -> n.path("mapDataList"))
                .aggregations(subAggs));
    }

    private Aggregation buildDefaultAggregation(String aggField) {
        Map<String, Aggregation> subAggs = new LinkedHashMap<>();
        subAggs.put("subspecies", termsAgg(SPECIES_KEYWORD, DEFAULT_AGG_SIZE));
        subAggs.put("ontologies", Aggregation.of(a -> a
                .terms(t -> t.field("subcat.keyword").size(ASSEMBLY_AGG_SIZE)
                        .order(List.of(NamedValue.of("_key", SortOrder.Asc))))));
        return Aggregation.of(a -> a
                .terms(t -> t.field(aggField + KEYWORD_SUFFIX))
                .aggregations(subAggs));
    }

    private Aggregation termsAgg(String field, int size) {
        return Aggregation.of(a -> a.terms(t -> t.field(field).size(size)));
    }

    public Highlight buildHighlights() {
        return Highlight.of(h -> h.fields(List.of(
                NamedValue.of("*", HighlightField.of(f -> f)))));
    }

    public SearchResponse<Map> getSearchResponseByTermAcc(String term) throws Exception {
        ElasticsearchClient client = ClientInit.getClient();
        return client.search(s -> s
                        .index(RgdContext.getESIndexName("search"))
                        .query(q -> q.term(t -> t.field("term_acc").value(FieldValue.of(term)))),
                Map.class);
    }
}
