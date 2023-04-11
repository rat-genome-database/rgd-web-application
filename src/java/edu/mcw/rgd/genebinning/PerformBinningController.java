package edu.mcw.rgd.genebinning;
import edu.mcw.rgd.dao.impl.GeneBinAssigneeDAO;
import edu.mcw.rgd.dao.impl.GeneBinDAO;
import edu.mcw.rgd.dao.impl.GeneDAO;
import edu.mcw.rgd.datamodel.Gene;
import edu.mcw.rgd.datamodel.GeneBin.GeneBin;
import edu.mcw.rgd.datamodel.GeneBin.GeneBinAssignee;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.lang.WordUtils;
import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.ArrayList;
import java.util.List;

public class PerformBinningController implements Controller {
    private static final String[] binCategories = {"GO:0008233","GO:0009975","GO:0016874","GO:0016491",
            "GO:0016740","GO:0032451","GO:0140223","GO:0140110","GO:0140104","GO:0140299","GO:0005198",
            "GO:0005215","GO:0003774"};

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String reqGenes = request.getParameter("inputdata");
        String inputTermAcc = request.getParameter("termAcc");
        String inputTerm = request.getParameter("term");
        String inputAssigneeName = request.getParameter("assigneeName");
        String inputCompleted = request.getParameter("completed");
        ModelMap model = new ModelMap();
        GeneDAO gdao = new GeneDAO();
        GeneBinDAO geneBinDAO = new GeneBinDAO();

//      Loading the bins page contents
        GeneBinAssigneeDAO geneBinAssigneeDAO = new GeneBinAssigneeDAO();
        List<GeneBinAssignee> allAssignees;
        List<GeneBinAssignee> assigneeName;

        if(inputTerm != null){
            inputTerm = inputTerm.toLowerCase();
        }
        else{
            inputTerm = "peptidase activity";
            inputTermAcc = binCategories[0];
        }

        if(reqGenes != null){

//          Processing the geneList data from the form-textarea split the entire text area based on enter | comma | space | tabs
            String[] genes = reqGenes.split( "[\\s,]+");
            genes = StringUtils.stripAll(genes);

//          Check if each of the genes are valid using the gene_symbol column in the database
            List<Gene> genesList = new ArrayList<>();
            for (String gene : genes) {
                List<Gene> curGenes = gdao.getGenes(gene.toLowerCase());
                if (curGenes.size() > 0) {
                    genesList.add(curGenes.get(0));
                }
            }

            for(int i=0;i< genesList.size();i++){
                boolean binAcquiredFlag = false;
                for(int j = 0; j< binCategories.length && !binAcquiredFlag; j++){

//                  Check if the gene is already allocated to a bin category
                    List<GeneBin> geneExists = geneBinDAO.getGenesByRgdId(genesList.get(i).getRgdId());
                    if(geneExists.size() == 0){
                        List<GeneBin> curGenes = geneBinDAO.getGeneBinPair(genesList.get(i).getRgdId(), binCategories[j]);
                        if(curGenes.size() > 0){

//                          Insert the Gene in the table
                            GeneBin curGene = curGenes.get(0);
                            geneBinDAO.insertGeneInBin(curGene.getRgdId(), curGene.getGeneSymbol(), curGene.getTerm(), curGene.getTermAcc());
                            binAcquiredFlag = true;
                        }
                    }
                }
            }
        }

//      Insert the new Assignee in the database
        if(inputAssigneeName != null && inputAssigneeName != ""){
            geneBinAssigneeDAO.updateAssigneeName(inputAssigneeName, inputTermAcc);
        }

//       If someone completed the bin curation, then update the bin completedFlag in the table
        if(inputCompleted != null && Integer.parseInt(inputCompleted) == 1){
            geneBinAssigneeDAO.updateCompletedStatus(inputTermAcc);
        }

//       Update the total genes an assignee/bin has.


//      Fetch all the bin details
        allAssignees = geneBinAssigneeDAO.getAllAssignees();

//      Fetch all the values from the bin where term_acc is inputTermAcc
        List<GeneBin> genes = geneBinDAO.getGenes(inputTermAcc);

        model.put("assignees", allAssignees);
        model.put("termAccString", inputTermAcc);
        model.put("termString", WordUtils.capitalize(inputTerm));
        assigneeName = geneBinAssigneeDAO.getAssigneeName(inputTermAcc, inputTerm);
        model.put("genes", genes);
        model.put("assignee", assigneeName.get(0));
        return new ModelAndView("/WEB-INF/jsp/gene_binning/bins.jsp","model",model);
    }
}

