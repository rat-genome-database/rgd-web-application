package edu.mcw.rgd.cytoscape;


import edu.mcw.rgd.dao.impl.ProteinDAO;
import edu.mcw.rgd.datamodel.Protein;
import edu.mcw.rgd.datamodel.SpeciesType;
import edu.mcw.rgd.process.Utils;

import edu.mcw.rgd.process.mapping.ObjectMapper;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by jthota on 1/29/2019.
 */
public class CytoscapeController implements Controller {

    private Set<Object> log = new HashSet<>();

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        List symbols=null;
        String identifers=request.getParameter("identifiers");
        HttpRequestFacade req=new HttpRequestFacade(request);
        String speciesTypeKey = (request.getParameter("species")!=null &&
                !request.getParameter("species").equals(""))
                ?req.getParameter("species"):"";
        if(identifers!=null && !identifers.equals("")){
           symbols= Utils.symbolSplit(identifers);
            Set<Object> resultSet=this.objectMapper(symbols,speciesTypeKey);
            System.out.println(resultSet.size());
        }
        return new ModelAndView("/WEB-INF/jsp/cytoscape/query.jsp");

    }

    public Set<Object> getLog() {
        return log;
    }

    public void setLog(Set<Object> log) {
        this.log = log;
    }

    public Set<Object> objectMapper(List<String> symbolList, String species) throws  Exception{
        Set<Object> log = new HashSet<>();
        ObjectMapper om = new ObjectMapper();
        List<Object> result = new ArrayList<>();

        Set<Object> resultSet= new HashSet<>();

        switch (species) {
            case "0":
                List<String> speciesList = new ArrayList<>(Arrays.asList("1", "2", "3", "6"));

                for (String s : speciesList) {
                    om.mapProteinSymbols(symbolList, SpeciesType.parse(s), "rgd");
                    result.addAll(om.getMapped());
                    log.addAll(om.getLog());
                }
                resultSet.addAll(result);

                break;
            default:

                om.mapProteinSymbols(symbolList, SpeciesType.parse(species), "rgd");
                resultSet.addAll(om.getMapped());
                log.addAll(om.getLog());

                break;
        }
        this.setLog(log);
        return resultSet;
    }
public Set<Object> mapper(List<String> symbols, int speciesTypeKey) throws Exception {

    ObjectMapper om =new ObjectMapper();
    ProteinDAO pdao = new ProteinDAO();

    List<Protein> proteins = pdao.getProteinListByUniProtIdOrSymbol(symbols,speciesTypeKey);
    List<String> hgncIds=new ArrayList<>();
    List<String> otherIdentifiers=new ArrayList<>();

    HashMap pMap = new HashMap();

    for (Protein p: proteins) {
        pMap.put(p.getUniprotId(), null);
        pMap.put(p.getSymbol(), null);

    }
    List<String> listMinusProteins = new ArrayList();

    for (String symbol: symbols) {
        if (!pMap.containsKey(symbol.toUpperCase())){
            listMinusProteins.add(symbol);
        }
    }

    for(String identifier:listMinusProteins){
        if(identifier.toLowerCase().contains("hgnc")){
            hgncIds.add(identifier);
        }else otherIdentifiers.add(identifier);
    }
    om.mapSymbols(hgncIds,speciesTypeKey,"hgnc");
    om.mapSymbols(otherIdentifiers,speciesTypeKey,"rgd");
    return null;
}

}



