package edu.mcw.rgd.nomenclatureinterface;
import edu.mcw.rgd.dao.impl.AliasDAO;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.dao.impl.NomenclatureDAO;
import edu.mcw.rgd.dao.spring.XmlBeanFactoryManager;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;

import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author dli
 * <p>
 * Manager class used by the nomenclature interface
 * <p>
 * Much of this class was inherited from dli.  Updated by jdepons
 *
 */
public class NomenclatureManager {

    InformaticPrescreener informaticPrescreener;
    GeneDAO geneDAO = new GeneDAO();
    AliasDAO aliasDAO = new AliasDAO();
    NomenclatureDAO nomenDAO = new NomenclatureDAO();

    /**
     * Runs findGenesUpForReview().   Available from the shell.
     * @param args cmdline params (not used at the moment)
     * @throws Exception
     */
    public static void main(String[] args) throws Exception{
        NomenclatureManager nomenclatureManager=(NomenclatureManager) (XmlBeanFactoryManager.getInstance().getBean("nomenclatureManager"));
        nomenclatureManager.findGenesUpForReview();
    }

    /**
     * Accepts a nomenclature change and updates the data store.
     *
     * @param rgdId
     * @param name
     * @param symbol
     * @param nextNomenclatureReview
     * @throws Exception
     */
    public void acceptChange(int rgdId, String name, String symbol, Date nextNomenclatureReview) throws Exception{
        List<Gene> geneCheck = geneDAO.getActiveGenes(3, symbol);

        for (Gene gene : geneCheck) {
            if (gene.getRgdId() != rgdId) {
                throw new Exception("Gene symbol " + symbol + " already exists. RGD ID " + rgdId + " could not be updated");
            }
        }

        Gene gene = geneDAO.getGene(rgdId);

        String oldName = gene.getName();
        String oldSymbol = gene.getSymbol();

        gene.setNomenReviewDate(nextNomenclatureReview);
        gene.setSymbol(symbol);
        gene.setName(name);
        gene.setNomenSource("RGD");
        geneDAO.updateGene(gene);

        List<Gene> alleleList = geneDAO.getVariantFromGene(rgdId);
        for (Gene variant : alleleList) {
            String variantName = variant.getName();
            String variantSymbol = variant.getSymbol();
            if (variant.getType().equals("allele")) {
                String patternStr = "<i>";
                Pattern pattern = Pattern.compile(patternStr);
                Matcher matcher = pattern.matcher(variantSymbol);
                boolean matchFound = matcher.find();
                if (matchFound) {
                    String oldAlleleSymbola[] = variantSymbol.split("<i>");
                    variantSymbol = symbol + "<i>" + oldAlleleSymbola[1];
                } else {
                    String oldAlleleSymbola[] = variantSymbol.split("<sup>");
                    variantSymbol = symbol + "<sup>" + oldAlleleSymbola[1];
                }
                String oldAlleleNamea[] = variantName.split("mutation");
                variantName = name + "; mutation" + oldAlleleNamea[1];
            } else if (variant.getType().equals("splice")) {
                String oldSpliceSymbola[] = variantSymbol.split("_v");
                variantSymbol = symbol + "_v" + oldSpliceSymbola[1];
                String oldSpliceNamea[] = variantName.split("variant");
                variantName = name + ", variant" + oldSpliceNamea[1];
            }
            variant.setSymbol(variantSymbol);
            variant.setName(variantName);
            geneDAO.updateGene(variant);
        }

        List l = new ArrayList();
        l.add(name);
        l.add(symbol);
        aliasDAO.deleteAlias(rgdId, l);

        if (!oldName.equalsIgnoreCase(name)) {
            Alias alias = new Alias();
            alias.setTypeName("old_gene_name");
            alias.setValue(oldName);
            alias.setNotes("added by nomenclature interface");
            alias.setRgdId(rgdId);
            aliasDAO.insertAlias(alias);
        }

        if (!oldSymbol.equalsIgnoreCase(symbol)) {
            Alias alias = new Alias();
            alias.setTypeName("old_gene_symbol");
            alias.setValue(oldSymbol);
            alias.setNotes("added by nomenclature interface");
            alias.setRgdId(rgdId);
            aliasDAO.insertAlias(alias);
        }

        NomenclatureEvent event = new NomenclatureEvent();
        event.setEventDate(new Date());
        event.setRefKey("10779");
        event.setDesc("Nomenclature updated to reflect human and mouse nomenclature");
        event.setName(name);
        event.setSymbol(symbol);
        event.setPreviousName(oldName);
        event.setPreviousSymbol(oldSymbol);
        event.setNomenStatusType("APPROVED");
        event.setRgdId(rgdId);
        event.setOriginalRGDId(rgdId);
        nomenDAO.createNomenEvent(event);
        
    }

    /**
     * Rejects a nomenclature change, but updates the nomenclature review date with a
     * new date.
     *
     * @param rgdId
     * @param nextNomenclatureReview
     * @throws Exception
     */
    public void rejectChange(int rgdId, Date nextNomenclatureReview) throws Exception{
            Gene gene = geneDAO.getGene(rgdId);
            gene.setNomenReviewDate(nextNomenclatureReview);
            geneDAO.updateGene(gene);
    }

    /**
     * Sets nomenclature of a gene as untouchable.
     * @param gene
     * @throws Exception
     */
    private void setUntouchable(Gene gene) throws Exception{
        gene.setNomenReviewDate(NomenclatureDAO.NOMENDATE_UNTOUCHABLE);
        geneDAO.updateGene(gene);
    }

    /**
     * Sets the genes nomenclature as reviewable.  It will be checked each time findGenesUpForReview() is run
     *
     * @param gene
     * @throws Exception
     */
    private void setReviewable(Gene gene) throws Exception{
        if (gene.getNomenReviewDate() == null ||(gene.getNomenReviewDate().getTime() != new GregorianCalendar(2100,9,1).getTime().getTime())) {
            gene.setNomenReviewDate(NomenclatureDAO.NOMENDATE_REVIEWABLE);
            geneDAO.updateGene(gene);
        }
    }

    /**
     * Maps the returned gene list into a SearchResult.  This includes retrieval of orthologs
     * and proposed nomenclature.
     * @param genes
     * @param page
     * @param pageSize
     * @return
     * @throws Exception
     */
    private SearchResult mapToSearchResult(List<Gene> genes, int page, int pageSize) throws Exception{
        SearchResult result = new SearchResult();
        int startIndex = (page -1) * 10;

        if (genes!=null && genes.size() >0) {
            //if the start location is greater than the number of records returned, exit
            if (genes.size() < startIndex) {
                return result;
            }

            int pos = startIndex - 1;
            while((pos < genes.size() - 1) && (result.getNomenclatureResultBeans().size() < pageSize)) {
                pos++;
                Gene gene = genes.get(pos);

                List<Gene> orthologs = getActiveOrthologs(gene.getRgdId());
                NomenclatureResultBean bean = new NomenclatureResultBean();
                bean.setGene(gene);
                bean.setOrthologList(orthologs);

                Gene goodOrtholog = selectGoodOrtholog(orthologs);
                if (proposeNewNomenClature(gene, goodOrtholog) != null) {
                    bean.setPropoesedGene(goodOrtholog);
                }
                result.getNomenclatureResultBeans().add(bean);

            }
            result.setTotalCount(genes.size());
            result.setPage(page);
            result.setPageSize(pageSize);
        }
        return result;
    }

    /**
     * Returns gene list based on symbol, name, or rgdId
     * @param keyword
     * @param page
     * @param pageSize
     * @return
     * @throws Exception
     */
    public SearchResult findGenesByKeyword(String keyword, int page, int pageSize) throws Exception {
        return mapToSearchResult(geneDAO.getActiveGenes(keyword, 3), page, pageSize);
    }

    /**
     * Returns gene list based on nomenclature review window
     * @param from
     * @param to
     * @param page
     * @param pageSize
     * @return
     * @throws Exception
     */
    public SearchResult findGenesByNomenclatureReviewDate(Date from, Date to, int page, int pageSize) throws Exception {
        return mapToSearchResult(geneDAO.getActiveGenes(3, from, to), page, pageSize);
    }

    /**
     * Returns count of genes based on nomenclature review window
     * @param from
     * @param to
     * @return
     * @throws Exception
     */
    public int countGenesByNomenclatureReviewDate(Date from, Date to) throws Exception {
        int count=-1;
        try {
            count = geneDAO.getActiveGeneCount(3, from, to);
        }catch(Exception e) {
            e.printStackTrace();
        }

        return count;
    }

    /**
     * Checks all genes in Reviewable bucket and runs the proposed nomenclature algorithm.
     * If a gene is found that now has a proposed nomenclature the nomenclature review
     * date is changed to today
     *
     *
     * @throws Exception
     */
    public void findGenesUpForReview() throws Exception {

        List<Gene> activeGenes = geneDAO.getActiveGenes(3, NomenclatureDAO.NOMENDATE_START, NomenclatureDAO.NOMENDATE_REVIEWABLE);

        int noGoodOrtholog = 0;
        int noChange = 0;
        int newNomen = 0;
        int untouchable = 0;

        for (Gene gene : activeGenes) {
            if (informaticPrescreener.isUntouchable(gene)) {
                setUntouchable(gene);
                untouchable++;
                continue;
            }

            List<Gene> orthologs = getActiveOrthologs(gene.getRgdId());
            if (orthologs == null || orthologs.size() == 0) {
                setReviewable(gene);
                noGoodOrtholog++;
                continue;
            }

            Gene proposedNomen = selectGoodOrtholog(orthologs);
            if (proposedNomen == null) {
                setReviewable(gene);
                noGoodOrtholog++;
            } else {
                // the name pass the informatic prescreening
                Gene newGeneNomen = proposeNewNomenClature(gene, proposedNomen);
                if (newGeneNomen == null) {
                    setReviewable(gene);
                    noChange++;
                } else {
                    if (newGeneNomen.getSymbol() == null || newGeneNomen.getSymbol().length() == 0) {
                        setReviewable(gene);
                        //noChangeC++;
                    } else {

                        // Added by WLiu on 4/12/2010
                        // Skip the rest if the gene is not reviewable by the pipeline.
                        if( gene.getNomenReviewDate()!=null && gene.getNomenReviewDate().getTime() != NomenclatureDAO.NOMENDATE_REVIEWABLE.getTime() ) {
                            noChange++;
                            continue;
                        }
                        // WLiu

                        gene.setNomenReviewDate(new Date());
                        geneDAO.updateGene(gene);
                        newNomen++;
                    }
                }
            }
        }

        System.out.println("Pipeline finished at: " + new Date());
        System.out.println("No Good Ortholog: " + noGoodOrtholog); 
        System.out.println("No Change: " + noChange);
        System.out.println("New Nomenclature: " + newNomen);
        System.out.println("Untouchable: " + untouchable);
        System.out.println(" ");
    }

    /**
     * Runs the proposal algorithm.  Returns a Gene object containing the proposed nomenclature.
     * @param ratGene rat Gene object
     * @param orthologGene ortholog Gene object
     * @return Gene object containing the proposed nomenclature
     */
    public  Gene proposeNewNomenClature (Gene ratGene, Gene orthologGene) {

        if (orthologGene == null) return null;

        Gene newGeneNomen=null;
        String ratGeneSymbol=ratGene.getSymbol();
        String orthologGeneSymbol=orthologGene.getSymbol();
        if( ratGeneSymbol==null || orthologGeneSymbol==null ) {
            return newGeneNomen;
        }

        //comparing gene symbol, the gene symbol equals, check the gene name
        if (ratGeneSymbol.equalsIgnoreCase(orthologGeneSymbol)) {
            String ratGeneName=ratGene.getName();
            String orthologGeneName=orthologGene.getName();
            if( ratGeneName==null || orthologGeneName==null ) {
                return newGeneNomen;
            }

            ratGeneName=ratGeneName.replaceAll("[ !@#\\$%\\^&\\*\\(\\)_\\+\\-={}\\|:\"<>\\?\\-=\\[\\];',\\./`~']","").toLowerCase();
            orthologGeneName=orthologGeneName.replaceAll("[ !@#\\$%\\^&\\*\\(\\)_\\+\\-={}\\|:\"<>\\?\\-=\\[\\];',\\./`~']","").toLowerCase();
            
            // the gene symbol equals, name not equal
            if (!ratGeneName.equals(orthologGeneName)) {
                // get the proposed new gene symbol
                String proposedGeneSymbol=orthologGene.getSymbol();
                proposedGeneSymbol=proposedGeneSymbol.substring(0,1).toUpperCase() + proposedGeneSymbol.substring(1).toLowerCase();
                // get the proposed new gene name
                String proposedGeneName=orthologGene.getName();

                //process.info("GeneName: "+ ratGeneName+"\t"+orthologGeneName);
                newGeneNomen=new Gene();
                newGeneNomen.setName(proposedGeneName);
                newGeneNomen.setSymbol(proposedGeneSymbol);
                newGeneNomen.setKey(orthologGene.getKey());
                newGeneNomen.setRgdId(orthologGene.getRgdId());
            }
            return newGeneNomen;
        }

        if (!ratGeneSymbol.equalsIgnoreCase(orthologGeneSymbol)) {
            // get the proposed new gene symbol
            String proposedGeneSymbol = orthologGene.getSymbol();
            proposedGeneSymbol=proposedGeneSymbol.substring(0,1).toUpperCase() + proposedGeneSymbol.substring(1).toLowerCase();

            // get the proposed new gene name
            String proposedGeneName = orthologGene.getName();

            newGeneNomen=new Gene();
            newGeneNomen.setName(proposedGeneName);
            newGeneNomen.setSymbol(proposedGeneSymbol);
            newGeneNomen.setKey(orthologGene.getKey());
            newGeneNomen.setRgdId(orthologGene.getRgdId());
        }
        return newGeneNomen;
    }

    public Gene selectGoodOrtholog(List<Gene> orthologs) {
        List<Gene> mouseOrthologs=getOrthologNomenclatureBySpecies(orthologs, SpeciesType.HUMAN);

        // looking for new nomen from mouse nomen
        if (mouseOrthologs !=null && mouseOrthologs.size() >0) {
            // use mouse orthologs
            for (Gene gene : mouseOrthologs) {
                if (informaticPrescreener.validSymbol(gene.getSymbol()) &&
                        informaticPrescreener.validName(gene.getName())) {
                    // the symbol and name pass the informatic prescreening
                    return gene;
                }
            }                        
        } 
        
        // looking for new nomenclature from human
        
        List<Gene> humanOrthologs=getOrthologNomenclatureBySpecies(orthologs, SpeciesType.MOUSE);
        //process.info("Checking gene name and gene symbol: " + humanOrthologs.size());
        for (Gene gene : humanOrthologs) {

            if (informaticPrescreener.validSymbol(gene.getSymbol()) &&
                    informaticPrescreener.validName(gene.getName())) {
                // the symbol and name is valid
                return gene;
            }
        }                     
        return null;
    }

    public List<Gene> getOrthologNomenclatureBySpecies(List<Gene> orthologs, int speciesKey) {
        List<Gene> matchingOrthologs=new ArrayList<Gene>();
        if (orthologs==null)
            return matchingOrthologs;
        for (Gene gene : orthologs) {
            if (gene.getSpeciesTypeKey() == speciesKey) {
                matchingOrthologs.add(gene);
            }
        }
        return matchingOrthologs;
    }
    
    public InformaticPrescreener getInformaticPrescreener() {
        return informaticPrescreener;
    }
    public void setInformaticPrescreener(
            InformaticPrescreener informaticPrescreener) {
        this.informaticPrescreener = informaticPrescreener;
    }

    // get active orthologs for rat/mouse/human only
    public List<Gene> getActiveOrthologs(int rgdId) throws Exception {

        List<Gene> orthologs = geneDAO.getActiveOrthologs(rgdId);
        Iterator<Gene> it = orthologs.iterator();
        while( it.hasNext() ) {
            Gene g = it.next();
            if( g.getSpeciesTypeKey()<1 || g.getSpeciesTypeKey()>3 ) {
                it.remove();
            }
        }
        return orthologs;
    }
}
