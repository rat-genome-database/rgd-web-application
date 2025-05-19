package edu.mcw.rgd.webservice;

import dev.langchain4j.model.ollama.OllamaChatModel;
import edu.mcw.rgd.dao.impl.ReferenceDAO;
import edu.mcw.rgd.datamodel.Reference;
import edu.mcw.rgd.web.OntologyTermMatcher;
import edu.mcw.rgd.web.PubmedFetcher;
import edu.mcw.rgd.web.XMLBodyExtractor;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class EntityService implements Controller {
    HttpServletRequest request = null;
    HttpServletResponse response = null;

    public ModelAndView handleRequest(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse) throws Exception {

        this.request = httpServletRequest;
        this.response = httpServletResponse;
        String pmid= request.getParameter("pmid");
        String entity=request.getParameter("entity");


        String paper = PubmedFetcher.fetchPMCFullTextXML(request.getParameter("pmid"));
        System.out.println(paper);

        String paperText="";

        if (paper.startsWith("Full text not available")) {
            System.out.println("in here");
            paperText = PubmedFetcher.fetchAbstract(pmid);
            System.out.println("abstract = " + paperText);
        }else {
            paperText = XMLBodyExtractor.extractBodyText(paper);
        }

        OllamaChatModel model = OllamaChatModel.builder()
                .baseUrl("http://grudge.rgd.mcw.edu:11434") // Ollama's default port
                .modelName("rgddeepseek70") // Replace with your downloaded model
                .build();

        String prompt="How Tall is mount everest";
       if (entity.equals("gene")) {
           prompt = "Extract the gene symbol for any gene discussed in the " +
                   "following paper. Each genes should only show up once in the return list." +
                   "  The maximum number of symbols returned should be 100.  " +
                   "If you fine more than 100, please return the first 100 found." +
                   " <paper>" + paperText + "</paper> " +
                   "Respond with a pipe delimited list of gene symbols and no other output";
       }else if (entity.equals("do")) {
           prompt = "Extract all disease ontology terms mentioned in the " +
                   "following paper. Each disease term should only show up once in the return list." +
                   "  The maximum number of disease terms returned should be 100.  " +
                   "If you fine more than 100, please return the first 100 found." +
                   " <paper>" + paperText + "</paper> " +
                   "Respond with a pipe delimited list of disease terms and no other output";

       }else if (entity.equals("bp")) {
           prompt = "Extract all GO Biological Process terms mentioned in the " +
                   "following paper. Each biological process term should only show up once in the return list." +
                   "  The maximum number of biological process terms returned should be 100.  " +
                   "If you fine more than 100, please return the first 100 found." +
                   " <paper>" + paperText + "</paper> " +
                   "Respond with a pipe delimited list of GO biological process terms and no other output";

       }else if (entity.equals("pw")) {
           prompt = "Extract all Pathway Ontology terms mentioned in the " +
                   "following paper. Each biological pathway term should only show up once in the return list." +
                   "  The maximum number of biological pathway terms returned should be 100.  " +
                   "If you fine more than 100, please return the first 100 found." +
                   " <paper>" + paperText + "</paper> " +
                   "Respond with a pipe delimited list of pathway ontology terms and no other output";

       }else if (entity.equals("so")) {
           prompt = "Extract all Sequence Ontology terms mentioned in the " +
                   "following paper. Each Sequence Ontology term should only show up once in the return list." +
                   "  The maximum number of Sequence Ontology terms returned should be 100.  " +
                   "If you fine more than 100, please return the first 100 found." +
                   " <paper>" + paperText + "</paper> " +
                   "Respond with a pipe delimited list of Sequence Ontology terms and no other output";

       }else if (entity.equals("chebi")) {
           prompt = "Extract all CHEBI Ontology terms mentioned in the " +
                   "following paper. Each CHEBI Ontology term should only show up once in the return list." +
                   "  The maximum number of CHEBI Ontology terms returned should be 100.  " +
                   "If you fine more than 100, please return the first 100 found." +
                   " <paper>" + paperText + "</paper> " +
                   "Respond with a pipe delimited list of CHEBI Ontology terms and no other output";

       }else if (entity.equals("ma")) {
           prompt = "Extract all Mouse Anatomy Ontology terms mentioned in the " +
                   "following paper. Each Mouse Anatomy Ontology term should only show up once in the return list." +
                   "  The maximum number of Mouse Anatomy Ontology terms returned should be 100.  " +
                   "If you fine more than 100, please return the first 100 found." +
                   " <paper>" + paperText + "</paper> " +
                   "Respond with a pipe delimited list of Mouse Anatomy Ontology terms and no other output";

       }else if (entity.equals("mp")) {
           prompt = "Extract all Mouse Phenotype Ontology terms mentioned in the " +
                   "following paper. Each Mouse Phenotype Ontology term should only show up once in the return list." +
                   "  The maximum number of Mouse Phenotype Ontology terms returned should be 100.  " +
                   "If you fine more than 100, please return the first 100 found." +
                   " <paper>" + paperText + "</paper> " +
                   "Respond with a pipe delimited list of Mouse Phenotype Ontology terms and no other output";

       }


        String genes = model.generate(prompt);

       if (entity.equals("gene")) {
           response.getWriter().print(genes);
           return null;
       }

        // Match the <think>...</think> block
        Pattern thinkPattern = Pattern.compile("<think>([\\s\\S]*?)</think>", Pattern.DOTALL);
        Matcher matcher = thinkPattern.matcher(genes);

        String thinkText = "";
        if (matcher.find()) {
            thinkText = matcher.group(1).trim();
        }

        // Remove the <think>...</think> block from the original string
        String afterThink = genes.replaceFirst("<think>[\\s\\S]*?</think>", "").trim();

        System.out.println("thinkText: " + thinkText);
        System.out.println("afterThink: " + afterThink);

        String[] termList = afterThink.split("\\|");

        OntologyTermMatcher otm = new OntologyTermMatcher();
        String returnList="";
        for (int i=0; i<termList.length; i++) {
            String acc = otm.getAcc(termList[i].trim(),entity);

            if (acc.equals("DOID:4")) {
                returnList = returnList + termList[i].trim() + "&nbsp;&nbsp;";

            }else {
                returnList = returnList + "<a href='https://rgd.mcw.edu/rgdweb/ontology/annot.html?acc_id=" + acc + "'>" + termList[i].trim() + "</a>&nbsp;&nbsp;";

            }

        }


        response.getWriter().print("<think>" + thinkText + "</think>" + returnList );
        return null;
    }

}
