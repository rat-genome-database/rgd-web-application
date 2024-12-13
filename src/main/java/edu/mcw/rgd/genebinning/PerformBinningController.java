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
import edu.mcw.rgd.security.User;
import edu.mcw.rgd.security.UserManager;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.text.WordUtils;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;


public class PerformBinningController implements Controller {
//    private static final String[] binCategories = {"GO:0008233","GO:0009975","GO:0016874","GO:0016491",
//            "GO:0016740","GO:0032451","GO:0140223","GO:0140110","GO:0140104","GO:0140299","GO:0005198",
//            "GO:0005215","GO:0003774"};
    private static final String[] binCategories = {"GO:0016209", "GO:0140657", "GO:0005488", "GO:0038024", "GO:0003824", "GO:0102910",
        "GO:0009055", "GO:0140522", "GO:0180020", "GO:0060090", "GO:0140912", "GO:0180024",
        "GO:0098772", "GO:0140313", "GO:0141047", "GO:0140489", "GO:0060089", "GO:0045735",
        "GO:0140911", "GO:0044183", "GO:0140776", "GO:0140777", "GO:0140691", "GO:0090729",
        "GO:0045182", "GO:0008233", "GO:0009975", "GO:0016874", "GO:0016491", "GO:0016740",
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
    }

    private HashMap<String, List<GeneBinAssignee>> getBinChildren() throws Exception {
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
        }
        return parentChildTermsAcc;
    }
//    private HashMap<String, List<GeneBinAssignee>> getBinChildren() throws Exception {
//        HashMap<String, List<GeneBinAssignee>> parentChildTermsAcc = new HashMap<>();
//        // Keep track of processed terms to avoid duplicate insertions
//        Set<String> processedTerms = new HashSet<>();
//
//        for (String binCategory : binCategories) {
//            Map<String, Relation> childTermAccs = ontologyXDAO.getTermDescendants(binCategory);
//            List<GeneBinAssignee> allChildterms = new ArrayList<>();
//            Set<String> keys = childTermAccs.keySet();
//
//            for (String key : keys) {
//                if (!processedTerms.contains(key)) {  // Only process if we haven't seen this term before
//                    Term term = ontologyXDAO.getTermByAccId(key);
//                    GeneBinChild child = new GeneBinChild(term.getAccId(), term.getTerm());
//                    List<GeneBinAssignee> assigneeObjChild = geneBinAssigneeDAO.getAssigneeName(term.getAccId());
//
//                    if (assigneeObjChild.isEmpty()) {
//                        // Only insert if the term doesn't exist in database
//                        geneBinAssigneeDAO.insertAssignee(term.getAccId(), term.getTerm(), 0);
//                    }
//                    processedTerms.add(key);  // Mark this term as processed
//                }
//
//                // Always add to allChildterms for this parent category
//                List<GeneBinAssignee> assigneeObjChild = geneBinAssigneeDAO.getAssigneeName(key);
//                if (!assigneeObjChild.isEmpty()) {
//                    allChildterms.add(assigneeObjChild.get(0));
//                }
//            }
//
//            List<GeneBinAssignee> selfChild = geneBinAssigneeDAO.getTerm(binCategory);
//            if (!selfChild.isEmpty()) {
//                allChildterms.add(selfChild.get(0));
//            }
//            parentChildTermsAcc.put(binCategory, allChildterms);
//        }
//        return parentChildTermsAcc;
//    }

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
            //Set the total gene count to 0
            List<GeneBinAssignee>allAssignees = geneBinAssigneeDAO.getAllAssignees();
            for(GeneBinAssignee assignee:allAssignees){
                geneBinAssigneeDAO.updateTotalGenes(assignee.getTermAcc(),0);
            }
            return new ModelAndView("redirect:/curation/geneBinning/bins.html?accessToken="+accessToken+
                    "&termAcc=GO:0008233&term=peptidase%20activity&parent=1&username="+username);
        }
//      Fetch all the child termAcc for bin category
        parentChildTermsAcc = getBinChildren();

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
        HashMap<String, String> childBinCountMap = new HashMap<>();
        List<GeneBinCountGenes> childBinCounts = geneBinDAO.getGeneChildCounts();
        for(int i=0;i<childBinCounts.size();i++){
            childBinCountMap.put(childBinCounts.get(i).getTermAcc(), Integer.toString(childBinCounts.get(i).getTotalGenes()));
        }

//      Fetch all the values from the bin where term_acc is inputTermAcc
        List<GeneBin> genes = new ArrayList<>();
        genes = geneBinDAO.getGenes(inputTermAcc);

        if(inputChildTermAcc != null){
            genes = geneBinDAO.getGenesOfDecendents(inputChildTermAcc);
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

        model.put("assignees", allAssignees);
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