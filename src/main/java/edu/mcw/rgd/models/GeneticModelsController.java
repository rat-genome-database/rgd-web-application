package edu.mcw.rgd.models;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.Alias;
import edu.mcw.rgd.datamodel.Reference;
import edu.mcw.rgd.datamodel.Strain;

import edu.mcw.rgd.datamodel.models.GeneticModel;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.datamodel.ontologyx.TermDagEdge;

import edu.mcw.rgd.models.models1.GeneticModelsSingleton;

import org.springframework.ui.ModelMap;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.*;

/**
 * Created by jthota on 9/2/2016.
 */
public class GeneticModelsController implements Controller{


   private AliasDAO aliasDAO= new AliasDAO();
    private ModelProcesses process= new ModelProcesses();
    private AnnotationDAO annotationDAO = new AnnotationDAO();
    private OntologyXDAO ontologyXDAO= new OntologyXDAO();
    private StrainDAO strainDAO= new StrainDAO();
    private AssociationDAO associationDAO=new AssociationDAO();
    private List<Strain> rgdStrains;
    private Set<String> genes;


    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ModelMap model = new ModelMap();
      //  List<GeneticModel> strains = geneticModelsDAO.getGerrcModels();
      //  List<GeneticModel> strainsWithAliases= this.getStrainWithAliases(strains);
    //    models.serializeGeneticModel();
    //    List<GeneticModel> strainsWithAliases=models.deserializeGeneticModel("gerrcModels");

        GeneticModelsSingleton instance= GeneticModelsSingleton.getInstance();
        List<GeneticModel> strainsWithAliases= instance.getGerrcModels();

        Set<String> genes= new HashSet<>();
        for(GeneticModel s:strainsWithAliases){
            String geneSymbol= s.getGeneSymbol();
            genes.add(geneSymbol);
        }
        this.setGenes(genes);

        Map<String, List<GeneticModel>> gsMap = new HashMap<String, List<GeneticModel>>();
        Map<ModelsHeaderRecord, List<GeneticModel>> hcMap=new HashMap<>();

        gsMap= this.getGeneStrainMap(strainsWithAliases);
        hcMap= this.getHeaderRecords(strainsWithAliases);


        model.put("strains",strainsWithAliases );
        model.put("geneStrainMap", gsMap);
        model.put("headerChildMap",hcMap );
        // In Controller
        request.getSession().setAttribute("strains", strainsWithAliases);
        request.getSession().setAttribute("headerChildMap", hcMap);

        return new ModelAndView("/WEB-INF/jsp/models/gerrc.jsp", "model", model);
    }

    
    public Map<String, List<GeneticModel>> getGeneStrainMap(List<GeneticModel> strains){

        Set<String> genes= this.getGenes();
     
        
        Map<String, List<GeneticModel>> gsMap=new HashMap<>();
        for(String g: genes){
            List<GeneticModel> strainGroup= new ArrayList<>();
            for(GeneticModel s: strains){

                if(g.equals(s.getGeneSymbol())){
                    strainGroup.add(s);
                }
            }
            gsMap.put(g, strainGroup);
        }
        return gsMap;
    }
    public Map<ModelsHeaderRecord, List<GeneticModel>> getHeaderRecords(List<GeneticModel> strains) throws Exception {

        Set<String> genes= this.getGenes();
     
       
        Map<ModelsHeaderRecord, List<GeneticModel>> gsMap=new HashMap<>();
        for(String g: genes){
            List<GeneticModel> childRecords= new ArrayList<>();
            ModelsHeaderRecord hRecord= new ModelsHeaderRecord();
            for(GeneticModel s: strains){
                if(!s.getLastStatus().equalsIgnoreCase("extinct")|| !s.getLastStatus().contains("Extinct")){
                    if(g.equals(s.getGeneSymbol())){
                        childRecords.add(s);
                    }
                }

            }
            if(childRecords.size()>0){
            GeneticModel oneChildRecord= childRecords.get(0);
            hRecord.setGene(oneChildRecord.getGene());
            hRecord.setGeneSymbol(oneChildRecord.getGeneSymbol());
            hRecord.setCount(childRecords.size());
            gsMap.put(hRecord, childRecords);
        }}
        return gsMap;
    }
    public List<GeneticModel> getStrainWithAliases(List<GeneticModel> strains) throws Exception {

        List<Integer> rgdIds= new ArrayList<>();
        List<GeneticModel> strains1= new ArrayList<>();
        for(GeneticModel s:strains){
           rgdIds.add(s.getStrainRgdId());  //Listing all strain RGD IDs
        }
        List<Strain> rgdStrains=strainDAO.getStrains(rgdIds);
        this.setRgdStrains(rgdStrains);
        int experimentRecordCount=0;
        List<String> childTermAccIds;
        List<Alias> aliasList= aliasDAO.getAliases(rgdIds);  //get the aliases of the list of strain RGD IDs
        List<Annotation> annotations= annotationDAO.getAnnotationsByRgdIdsListAndAspect(rgdIds, "S"); //get the annotations of list of strain RGD IDs

        List<String> termAccList= new ArrayList<>();
        for(Annotation a: annotations){
            String parent_term_acc= a.getTermAcc();
            termAccList.add(parent_term_acc);   //Listing parent_term_acc ids of above list of annotations
        }
        List<TermDagEdge> childtermsList= ontologyXDAO.getAllChildEdges(termAccList); //get all the childterms of parent_term_acc list
        Map<String, Integer> expRecordCountMap = process.getExperimentRecordCounts(termAccList); //get experiment record count of parent_term_acc list

        for(GeneticModel strain: strains){
            int rgdid= strain.getStrainRgdId();

            List<Reference> refs = associationDAO.getReferenceAssociations(rgdid);
            List<Reference> journalRefs= new ArrayList<>();
            for(Reference ref:refs){
                if(ref.getReferenceType().equalsIgnoreCase("journal article")){
                    journalRefs.add(ref);
                }
            }
            strain.setReferences(journalRefs);
          /*********************SET STRAIN_STATUS LOG***************************************************************/

            String lastStatus=null;
            for(Strain s:rgdStrains){
                if(s.getRgdId()==rgdid){
                    lastStatus=s.getLastStatus();
                }
            }

            assert lastStatus != null;
            if(lastStatus.equalsIgnoreCase("extinct")|| lastStatus.contains("Extinct")){
               continue;
            }
            strain.setLastStatus(lastStatus);
            strain.setAvailability(lastStatus);

            /*******************************SET STRAIN SOURCE**********************/
            String source=strain.getSource();
            if(source!=null){
            StringTokenizer tokenizer= new StringTokenizer(source, ",");
            while (tokenizer.hasMoreTokens()){
                String src= tokenizer.nextToken();
                 if(src.contains("PhysGen" )|| src.contains("PGA")){
                     String s="<a href=\"http://pga.mcw.edu/\" target=\"_blank\">PhysGen</a>";
                    // strain.setSource(src);
                     strain.setSource(s);
                }
             }}



            String strainSymbol= strain.getStrainSymbol();
            List<String> aliasName= new ArrayList<>();
            for(Alias a: aliasList){
               if(rgdid==a.getRgdId()){
                    aliasName.add(a.getValue());
                }
            }
            List<String> aliases= new ArrayList<>();
            String subSymbol= strainSymbol.replace("<i>", "").replace("<sup>", "").replace("</i>", "").replace("</sup>", "").replace("/", "")
                    .replace("(" ,"").replace(")", "").replace("-","").replace(" ", "").replace(".", "").replace("+" , "");

            for(String alias:aliasName){
              String  alias1=alias.replace("<i>", "").replace("<sup>", "").replace("</i>", "").replace("</sup>", "").replace("/", "")
                        .replace("(" ,"").replace(")", "").replace("-","").replace(" ", "").replace(".", "").replace("+" , "");
                if(!subSymbol.equalsIgnoreCase(alias1)){

                    aliases.add(alias);

                }
            }
            strain.setAliases(aliases);

          StringBuilder sb= new StringBuilder();
            for(Annotation a :annotations){

                String parent_term_acc=a.getTermAcc();
                int rgd_id= a.getAnnotatedObjectRgdId();
                if(rgdid==rgd_id){

                    strain.setParentTermAcc(parent_term_acc);
                    boolean first= true;
                    int count=0;
                    if(childtermsList!=null ) {
                        if (childtermsList.size() > 0) {
                            for (TermDagEdge childTerm : childtermsList) {
                                if (childTerm != null) {
                                    if (parent_term_acc.equals(childTerm.getParentTermAcc())) {

                                        if (first) {
                                            sb.append(childTerm.getChildTermAcc());
                                            first = false;
                                        } else {
                                            sb.append(",");
                                            sb.append(childTerm.getChildTermAcc());
                                          }
                                        count++;

                                    }

                                }

                            }
                            if(count==0){
                                sb.append(parent_term_acc);
                            }
                        }
                    }

                  //  experimentRecordCount=process.getExperimentRecordCount(parent_term_acc);

                    for(Map.Entry entry:expRecordCountMap.entrySet()){
                        String accId= (String) entry.getKey();
                        if(parent_term_acc.equals(accId)){
                            experimentRecordCount= (int) entry.getValue();
                        }
                    }
                }
            }
            String phenominerUrl= "http://rgd.mcw.edu/rgdweb/phenominer/ontChoices.html?terms=" +sb+"&sex=both";
            strain.setPhenominerUrl(phenominerUrl);
            strain.setExperimentRecordCount(experimentRecordCount);
            strains1.add(strain);
        }

       return strains1;

    }

    public Set<String> getGenes() {
        return genes;
    }

    public void setGenes(Set<String> genes) {
        this.genes = genes;
    }

    public List<Strain> getRgdStrains() {
        return rgdStrains;
    }

    public void setRgdStrains(List<Strain> rgdStrains) {
        this.rgdStrains = rgdStrains;
    }
}
