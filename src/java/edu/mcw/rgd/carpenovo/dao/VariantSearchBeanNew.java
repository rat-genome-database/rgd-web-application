package edu.mcw.rgd.carpenovo.dao;

/**
 * Created by jthota on 7/1/2019.
 */
//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

import edu.mcw.rgd.datamodel.MappedGene;
import edu.mcw.rgd.datamodel.VariantSearchBean;
import edu.mcw.rgd.util.Zygosity;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;





public class VariantSearchBeanNew  extends VariantSearchBean{
    private long variantId = -1L;
    protected final Log log = LogFactory.getLog(this.getClass());
    public List<Integer> sampleIds = new ArrayList();
    public List<String> zygosity = new ArrayList();
    public List<Integer> alleleCount = new ArrayList();
    public List<String> genicStatus = new ArrayList();
    public List<String> genes = new ArrayList();
    private String chromosome;
    private long startPosition = -1L;
    private long stopPosition = -1L;
    private int minDepth = -1;
    private int maxDepth = -1;
    private int minQualityScore = -1;
    private int maxQualityScore = -1;
    private int minPercentRead = -1;
    private int maxPercentRead = -1;
    private List<String> polyphen = new ArrayList();
    private List<String> location = new ArrayList();
    private List<String> variantType = new ArrayList();
    private List<String> clinicalSignificance = new ArrayList();
    public List<String> nearSpliceSite = new ArrayList();
    private String isPrematureStop;
    private String isReadthrough;
    private List<String> aaChange = new ArrayList();
    private String isNovelDBSNP;
    private String isKnownDBSNP;
    private boolean hetDiffFromRef = false;
    private boolean excludePossibleError = false;
    private boolean onlyPseudoautosomal = false;
    private boolean excludePseudoautosomal = false;
    private HashMap geneMap = new HashMap();
    private HashMap termAccMap = new HashMap();
    private boolean showDifferences = false;
    private float minConservation = -1.0F;
    private float maxConservation = -1.0F;
    private String isProteinCoding;
    private String isFrameshift;
    private String connective = "OR";
    private int mapKey;
    private List<MappedGene> mappedGenes = new ArrayList();

    public boolean isHuman() {
        return this.mapKey == 17 || this.mapKey == 38;
    }

    public List<MappedGene> getMappedGenes() {
        return this.mappedGenes;
    }

    public void setMappedGenes(List<MappedGene> mappedGenes) {
        this.mappedGenes = mappedGenes;
    }

    public HashMap getTermAccMap() {
        return this.termAccMap;
    }

    public void setTermAccMap(HashMap termAccMap) {
        this.termAccMap = termAccMap;
    }

    public HashMap getGeneMap() {
        return this.geneMap;
    }

    public void setGeneMap(HashMap geneMap) {
        this.geneMap = geneMap;
    }

    public VariantSearchBeanNew(int mapKey) {
        super(0);
        this.mapKey = mapKey;
    }

    public boolean isShowDifferences() {
        return this.showDifferences;
    }

    public void setShowDifferences(boolean showDifferences) {
        this.showDifferences = showDifferences;
    }

    public List<Integer> getSampleIds() {
        return sampleIds;
    }

    public void setSampleIds(List<Integer> sampleIds) {
        this.sampleIds = sampleIds;
    }

    public int getMapKey() {
        return this.mapKey;

    }

    public void setMapKey(int mapKey) {
        this.mapKey = mapKey;
    }

    private boolean isGenic() {
        if(this.getAAChangeSQL().isEmpty() && this.getPolyphenSQL().isEmpty() && this.getClinicalSignificanceSQL().isEmpty() && this.getIsPrematureStopSQL().isEmpty() && this.getIsReadthroughSQL().isEmpty()) {
            Iterator var1 = this.genicStatus.iterator();

            String status;
            do {
                if(!var1.hasNext()) {
                    return this.genicStatus.size() > 0;
                }

                status = (String)var1.next();
                this.log.debug("int status = " + status);
            } while(!status.equals("INTERGENIC"));

            return false;
        } else {
            return true;
        }
    }

    public String getVariantTable() {
        return this.isHuman()?" variant_human ":(this.isGenic()?" variant_genic ":" variant ");
    }

    public String getConScoreTable() {
        switch(this.getMapKey()) {
            case 17:
                return " B37_CONSCORE_PART_IOT ";
            case 38:
                return " CONSERVATION_SCORE_HG38 ";
            case 60:
                if(this.isGenic()) {
                    return " CONSERVATION_SCORE_GENIC ";
                }

                return " CONSERVATION_SCORE ";
            case 70:
                return " CONSERVATION_SCORE_5 ";
            case 360:
                return " CONSERVATION_SCORE_6 ";
            default:
                return " CONSERVATION_SCORE_6 ";
        }
    }

    public boolean isLimited() {
        String sql = this.getDepthSQL() + this.getScoreSql() + this.getAAChangeSQL() + this.getZygositySQL() + this.getNearSpliceSiteSQL() + this.getIsPrematureStopSQL() + this.getIsReadthroughSQL() + this.getDBSNPSQL() + this.getPolyphenSQL() + this.getClinicalSignificanceSQL() + this.getAlleleCountSQL() + this.getPsudoautosomalSQL() + this.getReadDepthSql();
        return !sql.equals("");
    }

    public String getChromosome() {
        return this.chromosome;
    }

    public Long getStartPosition() {
        return Long.valueOf(this.startPosition);
    }

    public Long getStopPosition() {
        return Long.valueOf(this.stopPosition);
    }

    public String getConnective() {
        return this.connective;
    }

    public void setConnective(String connective) {
        this.connective = connective;
    }

    public long getVariantId() {
        return this.variantId;
    }

    public void setVariantId(long variantId) {
        this.variantId = variantId;
    }

    public boolean hasTranscript() {
        return this.polyphen.size() > 0?true:(this.nearSpliceSite.size() > 0?true:(this.isTrue(this.isPrematureStop)?true:(this.isTrue(this.isReadthrough)?true:(this.aaChange.size() > 0?true:(this.location.size() > 0?true:(this.isTrue(this.isProteinCoding)?true:this.isTrue(this.isFrameshift)))))));
    }

    public boolean hasOnlyTranscript() {
        return this.nearSpliceSite.size() > 0?true:(this.isTrue(this.isPrematureStop)?true:(this.isTrue(this.isReadthrough)?true:(this.aaChange.size() > 0?true:(this.location.size() > 0?true:(this.isTrue(this.isProteinCoding)?true:this.isTrue(this.isFrameshift))))));
    }

    public boolean hasDBSNP() {
        return (this.isKnownDBSNP != null || this.isNovelDBSNP != null) && (!this.isTrue(this.isKnownDBSNP) || !this.isTrue(this.isNovelDBSNP));
    }

    public boolean hasConScore() {
        return this.minConservation >= 0.0F || this.maxConservation >= 0.0F;
    }

    public boolean hasPolyphen() {
        return this.polyphen.size() != 0;
    }

    public boolean hasClinicalSignificance() {
        return !this.clinicalSignificance.isEmpty();
    }

    public boolean hasPosition() {
        return this.chromosome != null;
    }

    public boolean getKnownDBSNP() {
        return this.isTrue(this.isKnownDBSNP);
    }

    public void setIsPrematureStop(String prematureStop) {
        this.isPrematureStop = prematureStop;
    }

    public void setIsReadthrough(String readthrough) {
        this.isReadthrough = readthrough;
    }

    public void setIsFrameshift(String frameshift) {
        this.isFrameshift = frameshift;
    }

    public boolean getNovelDBSNP() {
        return this.isTrue(this.isNovelDBSNP);
    }

    public void setPosition(String chr, String startPosition, String stopPosition) {
        if(chr != null && !chr.equals("")) {
            this.chromosome = chr;

            try {
                this.startPosition = Long.parseLong(startPosition);
            } catch (Exception var6) {
                ;
            }

            try {
                this.stopPosition = Long.parseLong(stopPosition);
            } catch (Exception var5) {
                ;
            }
        }

    }

    public void setChromosome(String chr) {
        this.chromosome = chr;
    }

    public void setDepth(String minStr, String maxStr) {
        int min = -1;
        int max = -1;

        try {
            min = Integer.parseInt(minStr);
        } catch (Exception var7) {
            ;
        }

        try {
            max = Integer.parseInt(maxStr);
        } catch (Exception var6) {
            ;
        }

        this.setDepth(min, max);
    }

    public void setDepth(int min, int max) {
        this.minDepth = min;
        this.maxDepth = max;
    }

    public void setAAChange(String synonymous, String nonSynonymous) {
        if(this.isTrue(synonymous)) {
            this.log.debug("setting aa change to  synonymous");
            this.aaChange.add("synonymous");
        }

        if(this.isTrue(nonSynonymous)) {
            this.log.debug("setting aa change to  non");
            this.aaChange.add("nonsynonymous");
        }

    }

    public void setDBSNPNovel(String novel, String known) {
        if(this.isTrue(novel)) {
            this.isNovelDBSNP = novel;
        }

        if(this.isTrue(known)) {
            this.isKnownDBSNP = known;
        }

    }

    public void setPseudoautosomal(String exclude, String only) {
        this.excludePseudoautosomal = this.isTrue(exclude);
        this.onlyPseudoautosomal = this.isTrue(only);
    }

    public String getPsudoautosomalSQL() {
        String sql = "";
        if(this.excludePseudoautosomal) {
            sql = sql + " and v.zygosity_in_pseudo=\'N\' ";
        }

        if(this.onlyPseudoautosomal) {
            sql = sql + " and v.zygosity_in_pseudo=\'Y\' ";
        }

        return sql;
    }

    public void setAlleleCount(String one, String two, String three, String four) {
        if(this.isTrue(one)) {
            this.alleleCount.add(Integer.valueOf(1));
        }

        if(this.isTrue(two)) {
            this.alleleCount.add(Integer.valueOf(2));
        }

        if(this.isTrue(three)) {
            this.alleleCount.add(Integer.valueOf(3));
        }

        if(this.isTrue(four)) {
            this.alleleCount.add(Integer.valueOf(4));
        }

    }

    public void setAlleleCountFromCommaList(String alleleCountString) {
        if(alleleCountString != null) {
            String[] alleleArray = alleleCountString.split(",");
            String[] var3 = alleleArray;
            int var4 = alleleArray.length;

            for(int var5 = 0; var5 < var4; ++var5) {
                String alleleStr = var3[var5];
                if(alleleStr.equals("1")) {
                    this.alleleCount.add(Integer.valueOf(1));
                }

                if(alleleStr.equals("2")) {
                    this.alleleCount.add(Integer.valueOf(2));
                }

                if(alleleStr.equals("3")) {
                    this.alleleCount.add(Integer.valueOf(3));
                }

                if(alleleStr.equals("4")) {
                    this.alleleCount.add(Integer.valueOf(4));
                }
            }
        }

    }

    public void setZygosity(String het, String hom, String possiblyHom, String hemi, String probablyHemi, String possiblyHemi, String excludePossibleError, String hetDiffFromRef) {
        if(this.isTrue(het)) {
            this.zygosity.add(Zygosity.HETEROZYGOUS);
        }

        if(this.isTrue(hemi)) {
            this.zygosity.add(Zygosity.HEMIZYGOUS);
        }

        if(this.isTrue(hom)) {
            this.zygosity.add(Zygosity.HOMOZYGOUS);
        }

        if(this.isTrue(possiblyHom)) {
            this.zygosity.add(Zygosity.POSSIBLY_HOMOZYGOUS);
        }

        if(this.isTrue(probablyHemi)) {
            this.zygosity.add(Zygosity.PROBABLY_HEMIZYGOUS);
        }

        if(this.isTrue(possiblyHemi)) {
            this.zygosity.add(Zygosity.POSSIBLY_HEMIZYGOUS);
        }

        this.excludePossibleError = this.isTrue(excludePossibleError);
        this.hetDiffFromRef = this.isTrue(hetDiffFromRef);
    }

    public void setVariantType(String snv, String ins, String del) {
        this.log.debug("setting variant");
        this.log.debug("snv = " + snv);
        this.log.debug("ins = " + ins);
        this.log.debug("del = " + del);
        if(this.isTrue(snv)) {
            this.variantType.add("snp");
            this.variantType.add("snv");
        }

        if(this.isTrue(ins)) {
            this.variantType.add("ins");
        }

        if(this.isTrue(del)) {
            this.variantType.add("del");
        }

    }

    public void setPolyphen(String benign, String possiblyDamaging, String probablyDamaging) {
        if(this.isTrue(benign)) {
            this.polyphen.add("benign");
        }

        if(this.isTrue(possiblyDamaging)) {
            this.polyphen.add("possibly damaging");
        }

        if(this.isTrue(probablyDamaging)) {
            this.polyphen.add("probably damaging");
        }

    }

    public void setPolyphen(String polyphenPrediction) {
        if(polyphenPrediction != null && !polyphenPrediction.equals("")) {
            this.polyphen.add(polyphenPrediction.toLowerCase());
        }

    }

    public void setClinicalSignificance(String pathogenic, String benign, String other) {
        if(this.isTrue(pathogenic)) {
            this.clinicalSignificance.add("pathogenic");
        }

        if(this.isTrue(benign)) {
            this.clinicalSignificance.add("benign");
        }

        if(this.isTrue(other)) {
            this.clinicalSignificance.add("conflicting");
            this.clinicalSignificance.add("uncertain");
        }

    }

    public void setNearSpliceSite(String nearSpliceSite) {
        if(this.isTrue(nearSpliceSite)) {
            this.nearSpliceSite.add("T");
        }

    }

    public void setGenicStatus(String genic, String intergenic) {
        if(this.isTrue(genic)) {
            this.genicStatus.add("GENIC");
        }

        if(this.isTrue(intergenic)) {
            this.genicStatus.add("INTERGENIC");
        }

    }

    public void setLocation(String intronic, String threePrimeUTR, String fivePrimeUTR, String proteinCoding) {
        this.isProteinCoding = proteinCoding;
        if(this.isTrue(intronic)) {
            this.location.add("INTRON,NON-CODING");
            this.location.add("3UTRS,INTRON");
            this.location.add("5UTRS,INTRON");
            this.location.add("5UTRS,INTRON,NON-CODING");
            this.location.add("INTRON,NON-CODING");
            this.location.add("3UTRS,3UTRS,INTRON");
            this.location.add("INTRON");
            this.location.add("5UTRS,5UTRS,INTRON");
            this.location.add("3UTRS,INTRON,NON-CODING");
        }

        if(this.isTrue(threePrimeUTR)) {
            if(!this.isTrue(intronic)) {
                this.location.add("3UTRS,INTRON");
                this.location.add("3UTRS,3UTRS,INTRON");
                this.location.add("3UTRS,INTRON,NON-CODING");
            }

            this.location.add("3UTRS,EXON,NON-CODING");
        }

        if(this.isTrue(fivePrimeUTR)) {
            if(!this.isTrue(intronic)) {
                this.location.add("5UTRS,INTRON");
                this.location.add("5UTRS,INTRON,NON-CODING");
                this.location.add("5UTRS,5UTRS,INTRON");
            }

            this.location.add("5UTRS,EXON,NON-CODING");
        }

    }

    public void setScore(String minStr, String maxStr) {
        try {
            this.minQualityScore = Integer.parseInt(minStr);
        } catch (Exception var5) {
            ;
        }

        try {
            this.maxQualityScore = Integer.parseInt(maxStr);
        } catch (Exception var4) {
            ;
        }

    }

    public void setPercentRead(int min, int max) {
        this.minPercentRead = min;
        this.maxPercentRead = max;
    }

    public void setScore(int min, int max) {
        this.minQualityScore = min;
        this.maxQualityScore = max;
    }

    public void setConScore(float min, float max) {
        this.minConservation = min;
        this.maxConservation = max;
    }

    private String buildOr(String name, List values, boolean isString) {
        Iterator it = values.iterator();
        String sql = "( ";
        String qualifier = "";
        if(isString) {
            qualifier = "\'";
        }

        if(it.hasNext()) {
            sql = sql + name + "=" + qualifier + it.next() + qualifier;
        }

        while(it.hasNext()) {
            sql = sql + " or " + name + "=" + qualifier + it.next() + qualifier;
        }

        sql = sql + ") ";
        this.log.debug(sql);
        return sql;
    }

    private String buildOrLike(String name, List<String> values) {
        Iterator it = values.iterator();
        String sql = "( ";
        if(it.hasNext()) {
            sql = sql + name + " like \'%" + it.next() + "%\'";
        }

        while(it.hasNext()) {
            sql = sql + " or " + name + " like \'%" + it.next() + "%\'";
        }

        sql = sql + ") ";
        this.log.debug(sql);
        return sql;
    }

    private String buildRange(String name, int min, int max) {
        return min == -1 && max != -1?"(" + name + " <= " + max + ")":(min != -1 && max == -1?"(" + name + " >= " + min + ")":"(" + name + " >= " + min + " and " + name + " <= " + max + ")");
    }

    public String getIsPrematureStopSQL() {
        return this.isPrematureStop != null && this.isTrue(this.isPrematureStop)?" and (vt.ref_aa != vt.var_aa and vt.var_aa=\'*\') ":"";
    }

    public String getIsReadthroughSQL() {
        return this.isReadthrough != null && this.isTrue(this.isReadthrough)?" and (vt.ref_aa != vt.var_aa and vt.ref_aa=\'*\') ":"";
    }

    public String getIsFrameshiftSQL() {
        return this.isFrameshift != null && this.isTrue(this.isFrameshift)?" and vt.frameshift=\'T\' ":"";
    }

    public String getPositionSQL() {
        String sql = "";
        if(this.hasPosition()) {
            sql = sql + " and ( v.chromosome=\'" + this.chromosome + "\' ";
            if(this.startPosition != -1L) {
                sql = sql + " and v.start_pos >= " + this.startPosition;
            }

            if(this.stopPosition != -1L) {
                sql = sql + " and v.start_pos <=" + this.stopPosition;
            }

            sql = sql + ") ";
        }

        return sql;
    }

    public String getMapsDataPositionSQL() {
        String sql = "";
        if(this.hasPosition()) {
            sql = sql + " and ( md.chromosome=\'" + this.chromosome + "\' ";
            if(this.startPosition != -1L) {
                sql = sql + "and  md.stop_pos >= " + this.startPosition;
            }

            if(this.stopPosition != -1L) {
                sql = sql + " and  md.start_pos <=" + this.stopPosition;
            }

            sql = sql + ") ";
        }

        return sql;
    }

    public String getNearSpliceSiteSQL() {
        return this.nearSpliceSite.size() == 0?"":" and " + this.buildOr("vt.near_splice_site", this.nearSpliceSite, true);
    }

    public String getSampleSQLOverlap() {
        String sql = "";
        if(this.sampleIds.size() == 0) {
            return "";
        } else {
            sql = sql + " and v.sample_id=" + this.sampleIds.get(0);

            for(int i = 0; i < this.sampleIds.size(); ++i) {
                if(i != 0) {
                    sql = sql + " and (v.chromosome=v" + i + ".chromosome and v.var_nuc=v" + i + ".var_nuc and v.start_pos=v" + i + ".start_pos and v" + i + ".sample_id=" + this.sampleIds.get(i) + ")";
                }
            }

            return sql;
        }
    }

    public String getSampleSQL() {
        String sql = "";
        if(this.sampleIds.size() == 0) {
            return "";
        } else if(this.connective.equals("AND")) {
            return this.getSampleSQLOverlap();
        } else {
            sql = sql + " and (v.sample_id=" + this.sampleIds.get(0);

            for(int i = 1; i < this.sampleIds.size(); ++i) {
                sql = sql + " or v.sample_id=" + this.sampleIds.get(i);
            }

            sql = sql + " )";
            return sql;
        }
    }

    public String getDepthSQL() {
        return this.minDepth == -1 && this.maxDepth == -1?"":" and " + this.buildRange("v.total_depth", this.minDepth, this.maxDepth);
    }

    public String getAlleleCountSQL() {
        String sql = "";
        if(this.alleleCount.size() != 0) {
            sql = sql + " and " + this.buildOr("v.zygosity_num_allele", this.alleleCount, false);
        }

        return sql;
    }

    public String getZygositySQL() {
        String sql = "";
        if(this.zygosity.size() != 0) {
            sql = sql + " and " + this.buildOr("v.zygosity_status", this.zygosity, true);
        }

        if(this.hetDiffFromRef) {
            sql = sql + " and (v.zygosity_status=\'heterozygous\' and zygosity_ref_allele=\'N\') ";
        }

        if(this.excludePossibleError) {
            sql = sql + " and v.zygosity_poss_error=\'N\' ";
        }

        return sql;
    }

    public String getAAChangeSQL() {
        return this.aaChange.size() == 0?"":" and " + this.buildOr("vt.syn_status", this.aaChange, true);
    }

    public String getPolyphenSQL() {
        return this.polyphen.size() == 0?"":" and " + this.buildOr("p.prediction", this.polyphen, true);
    }

    public String getClinicalSignificanceSQL() {
        return this.clinicalSignificance.size() == 0?"":" and " + this.buildOrLike("cv.clinical_significance", this.clinicalSignificance);
    }

    public String getVariantTypeSQL() {
        return this.variantType.size() == 0?"":" and " + this.buildOr("v.variant_type", this.variantType, true);
    }

    public String getGenicStatusSQL() {
        return this.genicStatus.size() == 0?"":" and " + this.buildOr("v.genic_status", this.genicStatus, true);
    }

    public String getVariantIdSql() {
        return this.variantId == -1L?"":" and v.variant_id=" + this.variantId;
    }

    public String getLocationSQL() {
        String retString = "";
        this.log.debug("isProteinCoding = " + this.isProteinCoding);
        if(this.isTrue(this.isProteinCoding)) {
            retString = retString + " AND vt.ref_aa is not null ";
        }

        return this.location.size() == 0?retString:retString + " and " + this.buildOr("vt.location_name", this.location, true);
    }

    public String getScoreSql() {
        return this.minQualityScore != -1 && this.maxQualityScore != -1?" and " + this.buildRange("v.QUALITY_SCORE", this.minQualityScore, this.maxQualityScore):"";
    }

    public String getReadDepthSql() {
        return this.minPercentRead != -1 && this.maxPercentRead != -1?" and " + this.buildRange("v.ZYGOSITY_PERCENT_READ", this.minPercentRead, this.maxPercentRead):"";
    }

    public String getConScoreSQL() {
        return this.hasConScore()?(this.minConservation == 0.0F && this.maxConservation == 0.0F?" and (cs.score=0) ":" and (cs.score>=" + this.minConservation + " and cs.score <= " + this.maxConservation + " )"):"";
    }

    public String getGeneMapSQL() {
        String sql = "";
        if(this.mappedGenes.size() > 0) {
            sql = sql + " and gl.gene_symbols_lc in ( ";
            Iterator it = this.mappedGenes.iterator();

            MappedGene mg;
            for(boolean first = true; it.hasNext(); sql = sql + "\'" + mg.getGene().getSymbol().toLowerCase() + "\'") {
                mg = (MappedGene)it.next();
                if(!first) {
                    sql = sql + ",";
                } else {
                    first = false;
                }
            }

            sql = sql + ")";
        }

        return sql;
    }

    public String getGenesSQL() {
        return "";
    }

    public String getMappedGenesSQL2() {
        String sql = "";
        boolean first = true;

        MappedGene mg;
        for(Iterator var3 = this.mappedGenes.iterator(); var3.hasNext(); sql = sql + "(v.start_pos > " + mg.getStart() + " and v.start_pos < " + mg.getStop() + ")") {
            mg = (MappedGene)var3.next();
            if(first) {
                sql = sql + " and (";
                first = false;
            } else {
                sql = sql + " or ";
            }
        }

        if(!first) {
            sql = sql + ")";
        }

        return sql;
    }

    public String getDBSNPSQL() {
        return this.hasDBSNP()?(this.isTrue(this.isKnownDBSNP)?" AND dbs.SNP_NAME is not null \n":(this.isTrue(this.isNovelDBSNP)?"   AND dbs.SNP_NAME is null  \n":"")):"";
    }

    public String[] getTableJoinSQL(String sqlFrom, boolean limit) {
        String vtTable = this.isHuman()?"variant_transcript_human":"variant_transcript";
        String sql = "";
        if(limit) {
            if(this.hasOnlyTranscript()) {
                sql = sql + " inner join " + vtTable + " vt on v.variant_id=vt.variant_id ";
                sqlFrom = sqlFrom + ",vt.* ";
                sql = sql + " inner join transcripts t on ( vt.transcript_rgd_id = t.transcript_rgd_id ) ";
            }

            if(this.hasPolyphen()) {
                sql = sql + " inner join polyphen p on (v.variant_id=p.variant_id and p.protein_status=\'100 PERC MATCH\') ";
                sqlFrom = sqlFrom + ",p.* ";
            }

            if(this.hasDBSNP()) {
                if(this.hasDBSNP() || this.getNovelDBSNP()) {
                    sql = sql + " left outer JOIN sample s ON (v.sample_id=s.sample_id AND s.MAP_KEY=" + this.mapKey + ")  left outer JOIN  db_snp dbs ON  ( v.START_POS = dbs.POSITION     AND v.CHROMOSOME = dbs.CHROMOSOME      AND v.VAR_NUC = dbs.ALLELE      AND dbs.SOURCE = s.DBSNP_SOURCE \n    AND dbs.MAP_KEY = s.MAP_KEY ) \n ";
                }

                sqlFrom = sqlFrom + ",dbs.* , dbsa.* , dbsa.snp_name as MCW_DBSA_SNP_NAME, dbs.snp_name as MCW_DBS_SNP_NAME";
            }

            if(this.hasConScore()) {
                sql = sql + " inner join  " + this.getConScoreTable() + " cs on (cs.chr=v.chromosome and cs.position = v.start_pos) ";
                sqlFrom = sqlFrom + ",cs.* ";
            }

            if(this.hasClinicalSignificance()) {
                this.log.info(" getTableJoinSql hasClinicalSignificance");
                sql = sql + " inner join clinvar cv on (v.rgd_id=cv.rgd_id) ";
                sqlFrom = sqlFrom + ",cv.* ";
            }
        } else {
            sql = sql + " left outer join " + vtTable + " vt on v.variant_id=vt.variant_id ";
            sqlFrom = sqlFrom + ",vt.* ";
            sql = sql + " left outer join transcripts t on vt.transcript_rgd_id = t.transcript_rgd_id   ";
            sqlFrom = sqlFrom + ",t.* ";
            sql = sql + " left outer join polyphen p on (vt.variant_transcript_id=p.variant_transcript_id and p.protein_status=\'100 PERC MATCH\') ";
            sqlFrom = sqlFrom + ",p.* ";
            sql = sql + " left outer join clinvar cv on (v.rgd_id=cv.rgd_id) ";
            sqlFrom = sqlFrom + ",cv.* ";
            sql = sql + " left outer join " + this.getConScoreTable() + " cs on (cs.chr=v.chromosome and cs.position = v.start_pos) ";
            sqlFrom = sqlFrom + ",cs.* ";
            sql = sql + " left outer JOIN sample s ON (v.sample_id=s.sample_id AND s.MAP_KEY=" + this.mapKey + ")  left outer join db_snp dbs ON (  v.START_POS  = dbs.POSITION      AND v.CHROMOSOME = dbs.CHROMOSOME       AND v.VAR_NUC = dbs.ALLELE      AND dbs.SOURCE = s.DBSNP_SOURCE \n    AND dbs.MAP_KEY = s.MAP_KEY ) \n ";
            sqlFrom = sqlFrom + ",dbs.*  ";
        }

        sql = sql + " where 1=1  ";
        return new String[]{sqlFrom, sql};
    }

    private boolean isTrue(String booleanString) {
        return booleanString != null && booleanString.toLowerCase().equals("true");
    }
}

