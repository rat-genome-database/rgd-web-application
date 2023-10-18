package edu.mcw.rgd.nomenclatureinterface;
/*
 * Created on May 30, 2007
 */
import java.util.List;
import java.util.ListIterator;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import edu.mcw.rgd.datamodel.Gene;

/**
 * @author dli
 */
public class InformaticPrescreener {
    List<String> untouchableNames;
    List<String> excludeSymbolStart;
    List<String> excludeSymbolEnd;
    List<String> excludeSymbolContain;
    List<String> excludeGeneNames;  
    List<String> excludeGeneNameStart;  
    List<String> excludeGeneNameEnd;   
    //List<Integer> untouchableRgdIds;
    
    //protected final Log logger = LogFactory.getLog("process");
    //protected final Log loggerUntouch = LogFactory.getLog("untouch");
    

    // check if the rat nomenclature is untouchable
    public boolean isUntouchable(Gene gene) {
        String geneSymbol=gene.getSymbol();

        for (String screenName : untouchableNames) {
            if (geneSymbol != null && geneSymbol.toLowerCase().matches(screenName.toLowerCase())) {
                return true;
            }
        }
        return false;
    }

    // check if the rat nomenclature is untouchable
    public void screenChangable(List<Gene> activeGenes) {
        int untouchable=0;
        for (Gene gene : activeGenes) {
            String geneSymbol = gene.getSymbol();
            ListIterator si = untouchableNames.listIterator();

            boolean match = false;
            while (si.hasNext()) {
                String screenName = (String) si.next();
                if (geneSymbol != null && geneSymbol.toLowerCase().matches(screenName.toLowerCase())) {
                    match = true;
                    break;
                }
            }
            if (match) {
                untouchable++;
                //geneNomen.setChangeable(false);
                //loggerUntouch.info(geneNomen.toString());
            }
        } 
    }
    
    // prescreening by gene symbol
    public boolean validSymbol(String geneSymbol) {
        if (geneSymbol==null)
            return false;
        for (String symbolStart : excludeSymbolStart) {
            if (geneSymbol.toLowerCase().startsWith(symbolStart.toLowerCase())) {
                return false;
            }
        }
        for (String symbolEnd : excludeSymbolEnd) {
            if (geneSymbol.toLowerCase().endsWith(symbolEnd.toLowerCase())) {
                return false;
            }
        }
        for (String symbolPattern : excludeSymbolContain) {
            if (geneSymbol.toLowerCase().matches(symbolPattern)) {
                return false;
            }
        }
        return true;
    }
    
    // prescreening by gene name
    public boolean validName(String geneName) {
        if (geneName==null)
            return true;
        for (String exNames:excludeGeneNames){
            if (geneName.toLowerCase().contains(exNames.toLowerCase())) {                
                return false;
            }
        }
        for (String exNameEnd:excludeGeneNameEnd){
            if (geneName.toLowerCase().endsWith(exNameEnd.toLowerCase())) {                
                return false;
            }
        }
        for (String exNameStart:excludeGeneNameStart){
            if (geneName.toLowerCase().startsWith(exNameStart.toLowerCase())) {                
                return false;
            }
        }
        return true;
    }
    

    public List getExcludeGeneNames() {
        return excludeGeneNames;
    }
    public void setExcludeGeneNames(List<String> excludeGeneNames) {
        this.excludeGeneNames = excludeGeneNames;
    }
    public List getExcludeSymbolContain() {
        return excludeSymbolContain;
    }
    public void setExcludeSymbolContain(List<String> excludeSymbolContain) {
        this.excludeSymbolContain = excludeSymbolContain;
    }
    public List getExcludeSymbolEnd() {
        return excludeSymbolEnd;
    }
    public void setExcludeSymbolEnd(List<String> excludeSymbolEnd) {
        this.excludeSymbolEnd = excludeSymbolEnd;
    }
    public List getExcludeSymbolStart() {
        return excludeSymbolStart;
    }
    public void setExcludeSymbolStart(List<String> excludeSymbolStart) {
        this.excludeSymbolStart = excludeSymbolStart;
    }
    public List getUntouchableNames() {
        return untouchableNames;
    }
    public void setUntouchableNames(List<String> untouchableNames) {
        this.untouchableNames = untouchableNames;
    }
    public List getExcludeGeneNameEnd() {
        return excludeGeneNameEnd;
    }
    public void setExcludeGeneNameEnd(List<String> excludeGeneNameEnd) {
        this.excludeGeneNameEnd = excludeGeneNameEnd;
    }
    
    public List<String> getExcludeGeneNameStart() {
        return excludeGeneNameStart;
    }
    public void setExcludeGeneNameStart(List<String> excludeGeneNameStart) {
        this.excludeGeneNameStart = excludeGeneNameStart;
    }
}
