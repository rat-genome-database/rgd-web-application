package edu.mcw.rgd.genebinning;
import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.Alias;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.GeneBin.GeneBin;
import edu.mcw.rgd.datamodel.GeneBin.GeneBinAssignee;
import edu.mcw.rgd.datamodel.GeneBin.GeneBinChild;
import edu.mcw.rgd.datamodel.GeneBin.GeneBinCountGenes;
import edu.mcw.rgd.datamodel.ontologyx.Relation;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.ontologyx.TermWithStats;
import edu.mcw.rgd.security.User;
import edu.mcw.rgd.security.UserManager;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.WordUtils;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.FileWriter;
import java.util.*;


public class PerformBinningController implements Controller {
//    private static final String[] binCategories = {"GO:0008233","GO:0009975","GO:0016874","GO:0016491",
//            "GO:0016740","GO:0032451","GO:0140223","GO:0140110","GO:0140104","GO:0140299","GO:0005198",
//            "GO:0005215","GO:0003774"};
    private static final String[] binCategories = {"GO:0008233","GO:0016209", "GO:0140657", "GO:0005488", "GO:0038024", "GO:0003824", "GO:0102910",
        "GO:0009055", "GO:0140522", "GO:0180020", "GO:0060090", "GO:0140912", "GO:0180024",
        "GO:0098772", "GO:0140313", "GO:0141047", "GO:0140489", "GO:0060089", "GO:0045735",
        "GO:0140911", "GO:0044183", "GO:0140776", "GO:0140777", "GO:0140691", "GO:0090729",
        "GO:0045182", "GO:0009975", "GO:0016874", "GO:0016491", "GO:0016740",
        "GO:0032451", "GO:0140223", "GO:0140110", "GO:0140104", "GO:0140299", "GO:0005198",
        "GO:0005215", "GO:0003774"};
    private GeneDAO gdao;
    private GeneBinDAO geneBinDAO;
    private OntologyXDAO ontologyXDAO;
    private AliasDAO aliasDAO;
    private GeneBinAssigneeDAO geneBinAssigneeDAO;
    private List<Gene> genesList;
    private List<Alias> genesAliasList;
    private List<String> incorrectGenesList;
    private HashMap<String, List<GeneBinAssignee>> parentChildTermsAcc;
    private String username;
    private HashMap<String, String> childBinCountMap;

    public PerformBinningController() {
        gdao = new GeneDAO();
        geneBinDAO = new GeneBinDAO();
        ontologyXDAO = new OntologyXDAO();
        aliasDAO = new AliasDAO();
        geneBinAssigneeDAO = new GeneBinAssigneeDAO();
        genesList = new ArrayList<>();
        genesAliasList = new ArrayList<>();
        incorrectGenesList = new ArrayList<>();
        parentChildTermsAcc = new HashMap<>();
        childBinCountMap = new HashMap<>();
    }

// First call - only ontology terms
private HashMap<String, List<GeneBinAssignee>> getOntologyBinChildren() throws Exception {
        System.out.println("entered the first call of generating child bins");
    HashMap<String, List<GeneBinAssignee>> parentChildTermsAcc = new HashMap<>();
    for (String binCategory : binCategories) {
        Map<String, Relation> childTermAccs = ontologyXDAO.getTermDescendants(binCategory);
        List<GeneBinAssignee> allChildterms = new ArrayList<>();
        Set<String> keys = childTermAccs.keySet();
        for (String key : keys) {
            Term term = ontologyXDAO.getTermByAccId(key);
            GeneBinChild child = new GeneBinChild(term.getAccId(), term.getTerm());
            List<GeneBinAssignee> assigneeObjChild = geneBinAssigneeDAO.getAssigneeName(term.getAccId());
            if( !assigneeObjChild.isEmpty() ) {
                allChildterms.add(assigneeObjChild.get(0));
            }
            List<GeneBinAssignee> geneBinAssigneeCheck = geneBinAssigneeDAO.getAssigneeName(term.getAccId());
            if(geneBinAssigneeCheck.isEmpty()) {
                geneBinAssigneeDAO.insertAssignee(term.getAccId(), term.getTerm(), 0);
            }

/*              Use it for initialization of the database table
                Insert all the children into the bin assignee table
                geneBinAssigneeDAO.insertAssignee(term.getAccId(), term.getTerm(), 0);
*/
        }
        List<GeneBinAssignee> selfChild = geneBinAssigneeDAO.getTerm(binCategory);
        if( !selfChild.isEmpty() ) {
            allChildterms.add(selfChild.get(0));
        }
        parentChildTermsAcc.put(binCategory, allChildterms);
        System.out.println("leaving the first call of generating child bins");
    }
    return parentChildTermsAcc;
}

    // Final call - complete relationships
    private HashMap<String, List<GeneBinAssignee>> getBinChildren() throws Exception {
        HashMap<String, List<GeneBinAssignee>> parentChildTermsAcc = new HashMap<>();
        System.out.println("In the final tree");
        for (String binCategory : binCategories) {
            List<GeneBinAssignee> allChildterms = new ArrayList<>();
            Set<String> termsWithSubsets = new HashSet<>();

            // First identify terms that have subsets
            List<String> binChildTerms = geneBinDAO.getChildTermsForParent(binCategory);
            for (String childTerm : binChildTerms) {
                List<GeneBinAssignee> subsets = geneBinAssigneeDAO.getAssigneeRecordsWithSubsets(childTerm+" (%)");
                if (!subsets.isEmpty()) {
                    termsWithSubsets.add(childTerm);
                    for (GeneBinAssignee subset : subsets) {
                        if (subset.getSubsetNum() > 0) {
                            allChildterms.add(subset);
                        }
                    }
                }
            }

            // Get regular children from ontology
            Map<String, Relation> childTermAccs = ontologyXDAO.getTermDescendants(binCategory);
            Set<String> keys = childTermAccs.keySet();
            for (String key : keys) {
                if (!termsWithSubsets.contains(key)) {
                    Term term = ontologyXDAO.getTermByAccId(key);
                    List<GeneBinAssignee> assigneeObjChild = geneBinAssigneeDAO.getAssigneeName(term.getAccId());
                    if (!assigneeObjChild.isEmpty()&&childBinCountMap.containsKey(term.getAccId())) {
                        allChildterms.add(assigneeObjChild.get(0));
                    }
                }
            }

            // Add regular child terms that aren't from ontology and don't have subsets
            for (String childTerm : binChildTerms) {
                if (!termsWithSubsets.contains(childTerm) && !childTermAccs.containsKey(childTerm)) {
                    List<GeneBinAssignee> assigneeObj = geneBinAssigneeDAO.getAssigneeName(childTerm);
                    if (!assigneeObj.isEmpty()) {
                        allChildterms.add(assigneeObj.get(0));
                    }
                }
            }

            parentChildTermsAcc.put(binCategory, allChildterms);
        }
        return parentChildTermsAcc;
    }

    public void geneInsertionToBin(List<GeneBin> geneExists, int i, int rgdId, String geneSymbol) throws Exception{
        boolean binAcquiredFlag = false;

//      Check if the gene is already allocated to a bin category
        if(geneExists.size() == 0){
            for(int j = 0; j< binCategories.length && !binAcquiredFlag; j++){
                List<GeneBin> curGenes = geneBinDAO.getGeneBinPair(rgdId, binCategories[j]);
                if(curGenes.size() > 0){
                    GeneBin curGene = curGenes.get(0);
                    String childTermAcc = "";
                    boolean childTermFlag = false;

//                  curGene.getTermAcc() gives you the root bin.
//                  Find the descendent bin where the gene would fit
                    List<GeneBinAssignee> binChildren = parentChildTermsAcc.get(curGene.getTermAcc());
                    for(int k=0;k<binChildren.size() && !childTermFlag;k++){
                        String checkAcc = binChildren.get(k).getTermAcc();
                        List<GeneBin> checkGeneChild= geneBinDAO.getGeneBinPair(curGene.getRgdId(),checkAcc );
                        if(checkGeneChild.size() > 0){
                            childTermAcc = checkGeneChild.get(0).getTermAcc();
                            childTermFlag = true;
                        }
                    }

//                  Insert the Gene in the table
                    geneBinDAO.insertGeneInBin(curGene.getRgdId(), curGene.getGeneSymbol(), curGene.getTerm(), curGene.getTermAcc(), childTermAcc);
                    binAcquiredFlag = true;
                }
            }

//          Gene is not yet annotated and goes to the NA bin
            if(!binAcquiredFlag){
                geneBinDAO.insertGeneInBin(rgdId, geneSymbol, "not annotated", "NA", null);
            }
        }
    }
    private Set<String> unsubdividableBins = new HashSet<>();

    public boolean subdivideOverflowBin(GeneBinCountGenes binToSubdivide) throws Exception {
        String parentTermAcc = binToSubdivide.getTermAcc();

        // Skip if we already know this bin can't be subdivided
        if(unsubdividableBins.contains(parentTermAcc)) {
            return false;
        }

            List<GeneBin> genesInBin = geneBinDAO.getGenesOfDecendents(parentTermAcc);

            List<TermWithStats> nextLevelTerms = ontologyXDAO.getActiveChildTerms(parentTermAcc, 0);
            if(nextLevelTerms.isEmpty()) {
                unsubdividableBins.add(parentTermAcc);
                return false;
            }

            boolean anyGenesRedistributed = false;

            // Insert new terms into GENEBIN_ASSIGNEE for tracking
            for(TermWithStats term : nextLevelTerms) {
                List<GeneBinAssignee> existingTerm = geneBinAssigneeDAO.getAssigneeName(term.getAccId());
                if(existingTerm.isEmpty()) {
                    geneBinAssigneeDAO.insertAssignee(term.getAccId(), term.getTerm(), 0);
                }
            }

            // For each gene in current bin, find most specific term
            for(GeneBin gene : genesInBin) {
                String foundTermAcc = findMostSpecificTerm(gene.getRgdId(), nextLevelTerms);
                if(foundTermAcc != null) {
                    geneBinDAO.updateGeneChildTerm(gene.getRgdId(), foundTermAcc);
                    anyGenesRedistributed = true;
                }
            }

            if(!anyGenesRedistributed) {
                unsubdividableBins.add(parentTermAcc);
            }

            return anyGenesRedistributed;

    }

    private String findMostSpecificTerm(int rgdId, List<TermWithStats> terms) throws Exception {

        for(TermWithStats term : terms) {

            // Check if gene has direct annotation to this term
            List<GeneBin> hasAnnotation = geneBinDAO.getGeneBinPair(rgdId, term.getAccId());
            if(hasAnnotation.size() > 0) {
                return hasAnnotation.get(0).getTermAcc();
            }

            // If not, get children and check recursively
            List<TermWithStats> childTerms = ontologyXDAO.getActiveChildTerms(term.getAccId(), 0);
            if(!childTerms.isEmpty()) {
                String foundTerm = findMostSpecificTerm(rgdId, childTerms);
                if(foundTerm != null) {
                    return foundTerm;
                }
            }
        }
        return null;
    }

private void createSubsetsForBin(String termAcc, int totalGenes) throws Exception {
    int numSubsets = (int) Math.ceil(totalGenes / 10.0);
    System.out.println("Entered subset method for term:"+ termAcc);
    List<GeneBinAssignee> termDetails = geneBinAssigneeDAO.getAssigneeName(termAcc);
    System.out.println("Subset count:"+termDetails.get(0).getTotalGenes());
    if (!termDetails.isEmpty()) {
        String term = termDetails.get(0).getTerm();

        for (int i = 1; i <= numSubsets; i++) {
            int startIdx = (i-1) * 10;
            int endIdx = Math.min(startIdx + 10, totalGenes);
            int genesInSubset = endIdx - startIdx;
            String subsetTermAcc = termAcc + " (" + i + ")";

            // Check if subset already exists
            List<GeneBinAssignee> existingSubset = geneBinAssigneeDAO.getAssigneeName(subsetTermAcc);
            if (existingSubset.isEmpty()) {
                // Insert new record
                geneBinAssigneeDAO.insertSubsetRecord(subsetTermAcc, term, i, genesInSubset, 0);
                System.out.println("Inserted subsetTerm"+subsetTermAcc+"count"+genesInSubset);
            } else {
                // Update entire record with latest values
                geneBinAssigneeDAO.updateSubsetRecord(subsetTermAcc, term, i, genesInSubset, 0);
                System.out.println("Updated subsetTerm"+subsetTermAcc+"count"+genesInSubset);
            }
            childBinCountMap.put(subsetTermAcc, Integer.toString(genesInSubset));
        }
    }
}

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

//      Initialize all the variables
        genesList = new ArrayList<>();
        genesAliasList = new ArrayList<>();
        incorrectGenesList = new ArrayList<>();
        parentChildTermsAcc = new HashMap<>();

//      Getting the request parameters
        String reqGenes = request.getParameter("inputdata");
        String inputTermAcc = request.getParameter("termAcc");
        String inputChildTermAcc = request.getParameter("childTermAcc");
        String inputChildTerm = request.getParameter("childTerm");
        String inputTerm = request.getParameter("term");
        String inputAssigneeName = request.getParameter("assigneeName");
        String inputCompleted = request.getParameter("completed");
        String isParent = request.getParameter("parent");
        String unassignFlag = request.getParameter("unassignFlag");
        String username = request.getParameter("username");
        String accessToken = request.getParameter("accessToken");
        String clearAll = request.getParameter("clearAll");
        ModelMap model = new ModelMap();

        //clear All button logic
        if(clearAll!=null && clearAll.equals("delete")){
            // Clear all genes from bins
            geneBinDAO.deleteAllGeneBins();
            geneBinAssigneeDAO.deleteSubsetRecords();
            // Reset internal state variables
            parentChildTermsAcc = new HashMap<>();
            childBinCountMap = new HashMap<>();
            genesList = new ArrayList<>();
            genesAliasList = new ArrayList<>();
            incorrectGenesList = new ArrayList<>();

            //Set the total gene count to 0
            List<GeneBinAssignee>allAssignees = geneBinAssigneeDAO.getAllAssignees();
            for(GeneBinAssignee assignee:allAssignees){
                geneBinAssigneeDAO.resetBin(assignee.getTermAcc());
            }
            return new ModelAndView("redirect:/curation/geneBinning/bins.html?accessToken="+accessToken+
                    "&termAcc=GO:0008233&term=peptidase%20activity&parent=1&username="+username);
        }
//      Fetch all the child termAcc for bin category
        parentChildTermsAcc = getOntologyBinChildren();

        List<GeneBinAssignee> allAssignees;
        List<GeneBinAssignee> assigneeName;

        if(inputTerm != null){
            inputTerm = inputTerm.toLowerCase();
        }
        else{
            inputTerm = "peptidase activity";
            inputTermAcc = binCategories[0];
        }

//      Perform binning button Action
        if(reqGenes != null){
            incorrectGenesList.clear();

//          Process the geneList data from the form-textarea split the entire text area based on enter | comma | space | tabs
            String[] genes = reqGenes.split( "[\\s,]+");
            genes = StringUtils.stripAll(genes);

//          Check if each of the genes are valid using the gene_symbol column in the database
            for (String gene : genes) {

//              Check if gene present in the Gene table
                List<Gene> curGenes = gdao.getGenes(gene.toLowerCase());
                if (curGenes.size() > 0) {
                    boolean geneSelectedFlag = false;
                    for(int i=0;i<curGenes.size() && !geneSelectedFlag;i++){
                        if(curGenes.get(i).getName() != null){
                            genesList.add(curGenes.get(i));
                            geneSelectedFlag = true;
                        }
                    }
                }
                else{

//                  Check if gene present in the Alias table
                    Alias curGene = aliasDAO.getAliasByValue(gene);
                    if (curGene != null){
                        genesAliasList.add(curGene);
                    }
                    else{

//                      Incorrect Gene entered
                        if(!gene.equals("")){
                            incorrectGenesList.add(gene);
                        }
                    }
                }
            }

//          Process genes on the genesList
            for(int i=0;i< genesList.size();i++){
                List<GeneBin> geneExists = geneBinDAO.getGenesByRgdId(genesList.get(i).getRgdId());
                geneInsertionToBin(geneExists, i, genesList.get(i).getRgdId(), genesList.get(i).getSymbol());
            }

//          Process genes on the genesAliasList
            for(int i=0;i< genesAliasList.size();i++){
                List<GeneBin> geneExists = geneBinDAO.getGenesByRgdId(genesAliasList.get(i).getRgdId());
                geneInsertionToBin(geneExists, i, genesAliasList.get(i).getRgdId(), genesAliasList.get(i).getValue());
            }

            //recursive logic to check if genes in child bins>15
            boolean needsMoreSubdivision;
            do {
                needsMoreSubdivision = false;
                List<GeneBinCountGenes> childBinCounts = geneBinDAO.getGeneChildCounts();

                for(GeneBinCountGenes binCount : childBinCounts) {
                    if(binCount.getTotalGenes() > 15) {
                        // Only continue if we actually redistributed some genes
                        boolean redistributed = subdivideOverflowBin(binCount);
                        if(!redistributed) {
                            System.out.println("Could not redistribute genes for bin: " + binCount.getTermAcc());
                            continue;
                        }
                        needsMoreSubdivision = true;
                        break;
                    }
                }
            } while(needsMoreSubdivision);
            System.out.println("Finished subdividing");
            List<GeneBinCountGenes> finalCounts = geneBinDAO.getGeneChildCounts();
            for(GeneBinCountGenes binCount : finalCounts) {
                if(binCount.getTotalGenes() > 10) {
                    createSubsetsForBin(binCount.getTermAcc(), binCount.getTotalGenes());
                }
            }
        }


//      Completed button action
        if(inputCompleted != null && Integer.parseInt(inputCompleted) == 1){
            if(Objects.equals(isParent, "1")){
                int tempPepCount = geneBinAssigneeDAO.getAssigneeName(inputTermAcc).get(0).getTotalGenes();
                if(Objects.equals(inputTermAcc,"GO:0008233") && tempPepCount> 15){
                    geneBinAssigneeDAO.updateCompletedStatus("GO:0070001");
                } else{
                    geneBinAssigneeDAO.updateCompletedStatus(inputTermAcc);
                }
            }else{
                geneBinAssigneeDAO.updateCompletedStatus(inputChildTermAcc);
            }
        }

//      Update the total genes an assignee/bin has.
        List<GeneBinCountGenes> geneCounts = geneBinDAO.getGeneCounts();
        for (GeneBinCountGenes geneCount : geneCounts) {
            geneBinAssigneeDAO.updateTotalGenes(geneCount.getTermAcc(), geneCount.getTotalGenes());
        }

//      Fetch the count of all the child bins
//        HashMap<String, String> childBinCountMap = new HashMap<>();
        List<GeneBinCountGenes> childBinCounts = geneBinDAO.getGeneChildCounts();
        for(int i=0;i<childBinCounts.size();i++){
            if(childBinCounts.get(i).getTotalGenes()>0) {
                childBinCountMap.put(childBinCounts.get(i).getTermAcc(), Integer.toString(childBinCounts.get(i).getTotalGenes()));
            }
        }

        List<GeneBinCountGenes> subsetBinCounts = geneBinAssigneeDAO.getGeneChildCounts();
        if(subsetBinCounts!=null) {
            for (GeneBinCountGenes count : subsetBinCounts) {
                childBinCountMap.put(count.getTermAcc(), Integer.toString(count.getTotalGenes()));
            }
        }

//      Fetch all the values from the bin where term_acc is inputTermAcc
        List<GeneBin> genes = new ArrayList<>();
        genes = geneBinDAO.getGenes(inputTermAcc);

//        if(inputChildTermAcc != null){
//            genes = geneBinDAO.getGenesOfDecendents(inputChildTermAcc);
//            model.put("childTermAccString", inputChildTermAcc);
//            model.put("childTermString", WordUtils.capitalize(inputChildTerm));
//        } else if (genes.size() > 15 && !Objects.equals(inputTermAcc, "NA")){
//            genes = geneBinDAO.getGenesOfDecendents("GO:0070001");
//            model.put("childTermAccString", "GO:0070001");
//            model.put("childTermString", WordUtils.capitalize("aspartic-type peptidase activity"));
//        }
        if (inputChildTermAcc != null) {
            if (inputChildTermAcc.contains("(")) {  // This is a subset
                // Get the original termAcc and subset number
                String[] parts = inputChildTermAcc.split(" \\(");
                String originalTermAcc = parts[0];
                int subsetNum = Integer.parseInt(parts[1].replace(")", ""));

                // Get all genes for original termAcc
                List<GeneBin> allGenes = geneBinDAO.getGenesOfDecendents(originalTermAcc);

                // Get the subset of genes
                int startIdx = (subsetNum-1) * 10;
                int endIdx = Math.min(startIdx + 10, allGenes.size());
                genes = allGenes.subList(startIdx, endIdx);
            } else {
                genes = geneBinDAO.getGenesOfDecendents(inputChildTermAcc);
            }
            model.put("childTermAccString", inputChildTermAcc);
            model.put("childTermString", WordUtils.capitalize(inputChildTerm));
        } else if (genes.size() > 15 && !Objects.equals(inputTermAcc, "NA")){
            genes = geneBinDAO.getGenesOfDecendents("GO:0070001");
            model.put("childTermAccString", "GO:0070001");
            model.put("childTermString", WordUtils.capitalize("aspartic-type peptidase activity"));
        }

//      Insert the new Assignee
        if(inputAssigneeName != null && !inputAssigneeName.equals("")){
            if(Objects.equals(isParent, "1")){
                int tempPepCount = geneBinAssigneeDAO.getAssigneeName(inputTermAcc).get(0).getTotalGenes();
                if(Objects.equals(inputTermAcc,"GO:0008233") && tempPepCount> 15){
                    geneBinAssigneeDAO.updateAssigneeName(inputAssigneeName, "GO:0070001");
                    model.put("childTermAccString", "GO:0070001");
                    model.put("childTermString", WordUtils.capitalize("aspartic-type peptidase activity"));
                } else{
                    geneBinAssigneeDAO.updateAssigneeName(inputAssigneeName, inputTermAcc);
                }
            } else {
                geneBinAssigneeDAO.updateAssigneeName(inputAssigneeName, inputChildTermAcc);
            }
        }

//      Unassign the Bin
        if(unassignFlag != null){
            if(Objects.equals(isParent, "1")){
                int tempPepCount = geneBinAssigneeDAO.getAssigneeName(inputTermAcc).get(0).getTotalGenes();
                if(Objects.equals(inputTermAcc,"GO:0008233") && tempPepCount> 15){
                    geneBinAssigneeDAO.updateAssigneeName(null, "GO:0070001");
                    model.put("childTermAccString", "GO:0070001");
                    model.put("childTermString", WordUtils.capitalize("aspartic-type peptidase activity"));
                } else{
                    geneBinAssigneeDAO.updateAssigneeName(null, inputTermAcc);
                }
            } else {
                geneBinAssigneeDAO.updateAssigneeName(null, inputChildTermAcc);
            }
        }
        
//      Fetch the assignee details of the current bin
        if(Objects.equals(isParent, "1")){
            int tempPepCount = geneBinAssigneeDAO.getAssigneeName(inputTermAcc).get(0).getTotalGenes();
            if(Objects.equals(inputTermAcc,"GO:0008233") && tempPepCount> 15){
                assigneeName = geneBinAssigneeDAO.getAssigneeName("GO:0070001");
                model.put("assignee", assigneeName.get(0));
            }else{
                assigneeName = geneBinAssigneeDAO.getAssigneeName(inputTermAcc);
                model.put("assignee", assigneeName.get(0));
            }
        }
        else{
            assigneeName = geneBinAssigneeDAO.getAssigneeName(inputChildTermAcc);
            model.put("assignee", assigneeName.get(0));
        }

//      Fetch all the bin details
        allAssignees = geneBinAssigneeDAO.getAllAssignees();
//      Fetch updated children of each bin
        parentChildTermsAcc = getBinChildren();

//        // Filter out parent bins with zero genes
        List<GeneBinAssignee> filteredAssignees = new ArrayList<>();
        for (GeneBinAssignee assignee : allAssignees) {
            if (assignee.getIsParent() == 0 || assignee.getTotalGenes() > 0) {
                filteredAssignees.add(assignee);
            }
        }
        model.put("assignees", filteredAssignees);

//        model.put("assignees", allAssignees);
        model.put("termAccString", inputTermAcc);
        model.put("termString", WordUtils.capitalize(inputTerm));
        model.put("genes", genes);
        model.put("binChildren", parentChildTermsAcc);
        model.put("incorrectGenesList", incorrectGenesList);
        model.put("parent", Integer.parseInt(isParent));
        model.put("childBinCountMap", childBinCountMap);
        model.put("username", username);
        model.put("accessToken", accessToken);

        return new ModelAndView("/WEB-INF/jsp/curation/gene_binning/bins.jsp","model", model);
    }
}