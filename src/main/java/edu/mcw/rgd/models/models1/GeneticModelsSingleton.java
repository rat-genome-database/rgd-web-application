package edu.mcw.rgd.models.models1;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.Alias;
import edu.mcw.rgd.datamodel.Reference;
import edu.mcw.rgd.datamodel.Strain;
import edu.mcw.rgd.datamodel.models.GeneticModel;
import edu.mcw.rgd.datamodel.ontology.Annotation;
import edu.mcw.rgd.datamodel.ontologyx.TermDagEdge;
import edu.mcw.rgd.models.ModelProcesses;

import java.util.*;

/**
 * Created by jthota on 9/28/2017.
 */
public class GeneticModelsSingleton {
    private static GeneticModelsSingleton instance=null;

    private List<GeneticModel> allModels=new ArrayList<>();
    private List<GeneticModel> gerrcModels= new ArrayList<>();
    private List<Strain> rgdStrains;
    private AssociationDAO associationDAO=new AssociationDAO();
    private GeneticModelsDAO modelDao= new GeneticModelsDAO();
    private AliasDAO aliasDAO= new AliasDAO();
    private ModelProcesses process= new ModelProcesses();
    private AnnotationDAO annotationDAO = new AnnotationDAO();
    private OntologyXDAO ontologyXDAO= new OntologyXDAO();
    private StrainDAO strainDAO= new StrainDAO();

    public GeneticModelsSingleton(){}

    public void init(){
        List<GeneticModel> strains=new ArrayList<>();
        try {

            strains = modelDao.getAllModels();
            List<GeneticModel> strainsWithAliases= this.getStrainWithAliases(strains);
             this.setAllModels(strainsWithAliases);

            List<GeneticModel> gerrcModels= new ArrayList<>();
            for(GeneticModel m:strainsWithAliases){
                String source=m.getSource();
                String origination = m.getOrigination();
                if(source!=null){
                    if((source.contains("PhysGen") || source.contains("PGA") || source.contains("PhysGen Knockouts") || source.contains("MCW Gene Editing Rat Resource Center") ) ){
                        gerrcModels.add(m);

                    }
                }
                if(origination!=null){
                    if((origination.contains("PhysGen") || origination.contains("PGA") || origination.contains("PhysGen Knockouts") || origination.contains("MCW Gene Editing Rat Resource Center") ) ){
                        gerrcModels.add(m);

                    }
                }
            }
            this.setGerrcModels(gerrcModels);
           // this.setGerrcModels(gerrcModels);
        }catch(Exception e){
            e.printStackTrace();
        }

    }
    public static synchronized GeneticModelsSingleton getInstance(){
        if(instance==null){
            instance=new GeneticModelsSingleton();
            instance.init();

        }else {
            //System.out.println("Instance exists");
        }
        return instance;
    }


    public static void main(String[] args){
        new GeneticModelsSingleton();
        GeneticModelsSingleton instance= getInstance();
        System.out.println("All Models Size: "+instance.getAllModels().size()+"\nDONE");
    }

    public List<GeneticModel> getStrainWithAliases(List<GeneticModel> strains) throws Exception {

        List<Integer> rgdIds= new ArrayList<>();
        List<GeneticModel> strains1= new ArrayList<>();
        // Collections.sort(strains, GeneSymbolComparator);
        for(GeneticModel s: strains){
            rgdIds.add(s.getStrainRgdId());  //Listing all strain RGD IDs
        }
        List<Strain> rgdStrains=getStrainsWithLimit(rgdIds);
        this.setRgdStrains(rgdStrains);
        int experimentRecordCount=0;
        List<String> childTermAccIds;
        List<Alias> aliasList= getAliases(rgdIds);  //get the aliases of the list of strain RGD IDs
        List<Annotation> annotations= getAnnotationsByRgdIdsListAndAspect(rgdIds, "S"); //get the annotations of list of strain RGD IDs

        List<String> termAccList= new ArrayList<>();
        for(Annotation a: annotations){
            String parent_term_acc= a.getTermAcc();
            termAccList.add(parent_term_acc);   //Listing parent_term_acc ids of above list of annotations
        }
        List<TermDagEdge> childtermsList= ontologyXDAO.getAllChildEdges(termAccList); //get all the childterms of parent_term_acc list
        Map<String, Integer> expRecordCountMap = process.getExperimentRecordCounts(termAccList); //get experiment record count of parent_term_acc list

        for(GeneticModel strain: strains){
            int rgdid= strain.getStrainRgdId();

            /**************************Publication URL***************************************************************/
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
                // System.out.println(rgdid +"|| " + strain.getStrainSymbol() + "||" + lastStatus );
                continue ;
            }
            strain.setLastStatus(lastStatus);
            strain.setAvailability(lastStatus);

            /*******************************SET STRAIN SOURCE**********************/
            String source=strain.getSource();
            if(source!=null){
                StringTokenizer tokenizer= new StringTokenizer(source, ",");
                while (tokenizer.hasMoreTokens()){

                    String src= tokenizer.nextToken();
                    if(src.contains("PhysGen")){
                        strain.setSource(src);
                    }
                }}
            String origination = strain.getOrigination();
            if(origination!=null){
                StringTokenizer tokenizer= new StringTokenizer(origination, ",");
                while (tokenizer.hasMoreTokens()){

                    String src= tokenizer.nextToken();
                    if(src.contains("PhysGen")){
                        strain.setOrigination(src);
                    }
                }}
            /***************************SET STRAIN ALIAS NAME ***********************/
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


            /****************************SET Phenominer URL************************************/

            StringBuilder sb= new StringBuilder();
            for(Annotation a :annotations){

                boolean flag=true;
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
                                            //  sb.append(parent_term_acc);
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
            String phenominerUrl= "http://rgd.mcw.edu/rgdweb/phenominer/ontChoices.html?terms=" +sb +"&sex=both";
            /*****************************************************************************************************/
            strain.setPhenominerUrl(phenominerUrl);
            strain.setExperimentRecordCount(experimentRecordCount);

            strains1.add(strain);
        }

        return strains1;

    }
    public List<Strain> getStrainsWithLimit(List<Integer> rgdIds) throws Exception {
        List<Strain> result = new ArrayList<>();
        int chunkSize = 1000;
        for (int i = 0; i < rgdIds.size(); i += chunkSize) {
            List<Integer> subList = rgdIds.subList(i, Math.min(i + chunkSize, rgdIds.size()));
            result.addAll(strainDAO.getStrains(subList));
        }
        return result;
    }
    public List<Alias> getAliases(List<Integer> rgdIds) throws Exception {
        List<Alias> result = new ArrayList<>();
        int chunkSize = 1000;
        for (int i = 0; i < rgdIds.size(); i += chunkSize) {
            List<Integer> subList = rgdIds.subList(i, Math.min(i + chunkSize, rgdIds.size()));
            result.addAll(aliasDAO.getAliases(subList));
        }
        return result;
    }
    public List<Annotation> getAnnotationsByRgdIdsListAndAspect(List<Integer> rgdIds, String aspect) throws Exception {
        List<Annotation> result = new ArrayList<>();
        int chunkSize = 1000;
        for (int i = 0; i < rgdIds.size(); i += chunkSize) {
            List<Integer> subList = rgdIds.subList(i, Math.min(i + chunkSize, rgdIds.size()));
            result.addAll(annotationDAO.getAnnotationsByRgdIdsListAndAspect(subList, aspect));
        }
        return result;
    }


    public List<Strain> getRgdStrains() {
        return rgdStrains;
    }

    public void setRgdStrains(List<Strain> rgdStrains) {
        this.rgdStrains = rgdStrains;
    }


    public List<GeneticModel> getAllModels() {
        return allModels;
    }

    public void setAllModels(List<GeneticModel> allModels) {
        this.allModels = allModels;
    }

    public List<GeneticModel> getGerrcModels() {
        return gerrcModels;
    }

    public void setGerrcModels(List<GeneticModel> gerrcModels) {
        this.gerrcModels = gerrcModels;
    }
}
