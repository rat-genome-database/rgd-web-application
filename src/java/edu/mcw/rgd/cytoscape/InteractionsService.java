package edu.mcw.rgd.cytoscape;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;

import java.util.*;
import java.util.Map;

/**
 * Created by jthota on 3/21/2019.
 */
public class InteractionsService {
    ProteinDAO pdao= new ProteinDAO();
    InteractionsDAO idao= new InteractionsDAO();
    OntologyXDAO xdao=new OntologyXDAO();
    AssociationDAO assocDao= new AssociationDAO();
    Map<String, String> intTypes=new HashMap<>();
    Map<Integer, Protein> proteins=new HashMap<>();
    Map<Integer, List<Gene>> geneProteinMap=new HashMap<>();
     public List<InteractionReportRecord> getInteractionsBySpecies(String species) throws Exception {
        int speciesTypeKey= SpeciesType.parse(species);
        List<Integer> rgdIds= getProteinRgdIds(speciesTypeKey);
        System.out.println(species +" PROTEINS SIZE:"+rgdIds.size());
        List<Interaction> interactions= new ArrayList<>();
        Collection[] colletions = this.split(rgdIds, 1000);

        for(int i=0; i<colletions.length;i++){
            List c= (List) colletions[i];
            interactions.addAll(idao.getInteractionsByRgdIdsList(c));
        }


         List<InteractionReportRecord> interactionReportRecords =new ArrayList<>();
        for(Interaction i:interactions){
            Protein interactor1=getProtein(i.getRgdId1());
            Protein interactor2=getProtein(i.getRgdId2());
            List<Gene> genes1=getGeneByProteinRgdId(i.getRgdId1());
            List<Gene> genes2=getGeneByProteinRgdId(i.getRgdId2());
            String geneSymbol1=getGeneSymbol(genes1);
            String geneSymbol2=getGeneSymbol(genes2);
            String geneRgdId1=getGeneRgdId(genes1);
            String geneRgdId2=getGeneRgdId(genes2);
            String interactionType=getInteractionType(i.getInteractionType());

            String species1=SpeciesType.getCommonName(interactor1.getSpeciesTypeKey());
            String species2=SpeciesType.getCommonName(interactor2.getSpeciesTypeKey());
            String attributes= getAttributes(i.getInteractionKey());

            InteractionReportRecord rec=new InteractionReportRecord();
            rec.setRgdId1(i.getRgdId1());
            rec.setRgdId2(i.getRgdId2());
            rec.setProteinUniprotId1(interactor1.getUniprotId());
            rec.setProteinUniprotId2(interactor2.getUniprotId());
            rec.setSpecies1(species1);
            rec.setSpecies2(species2);
            rec.setInteractionType(interactionType);

            rec.setGeneSymbol1(geneSymbol1);
            rec.setGeneRgdId1(geneRgdId1);
            rec.setGeneSymbol2(geneSymbol2);
            rec.setGeneRgdId2(geneRgdId2);

            rec.setAttributes(attributes);
            interactionReportRecords.add(rec);
         }


     /* Collections.sort(interactionReportRecords, new Comparator<InteractionReportRecord>() {
          @Override
          public int compare(InteractionReportRecord o1, InteractionReportRecord o2) {
              return Utils.stringsCompareToIgnoreCase(o1.getGeneSymbol1(),o2.getGeneSymbol1());
          }
      });
        System.out.println("Interactions: "+ interactions.size());*/

         return interactionReportRecords;
    }
    public List<Integer> getProteinRgdIds(int speciesTypeKey) throws Exception {
        List<Protein> proteins=pdao.getProteins(speciesTypeKey);
        List<Integer> rgdIds= new ArrayList<>();

        for(Protein p: proteins){
            rgdIds.add(p.getRgdId());
        }
        return rgdIds;
    }
    public String getInteractionType(String accId) {
        String interactionType = new String();
        if (intTypes.get(accId) != null) {
            interactionType = intTypes.get(accId);
        } else {
            try {
                interactionType = xdao.getTermByAccId(accId).getTerm();
                intTypes.put(accId, interactionType);
            } catch (Exception e) {
                System.out.println("interaction TYpe: " + accId);
                e.printStackTrace();
            }

        }
        return interactionType;
    }
    public String getGeneRgdId(List<Gene> genes){
        StringBuilder sb= new StringBuilder();
        boolean first=true;
        for(Gene g:genes){
            if(first) {
                sb.append(g.getRgdId());
                first=false;
            }else{
                sb.append("; ").append(g.getRgdId());
            }

        }
        return sb.toString();
    }
    public String getGeneSymbol(List<Gene> genes){
        StringBuilder sb= new StringBuilder();
        boolean first=true;
        for(Gene g:genes){
            if(first) {
                sb.append(g.getSymbol());
                first=false;
            }else{
                sb.append("; ").append(g.getSymbol());
            }

        }
        return sb.toString();
    }
    public Protein getProtein(int rgdId) throws Exception {
        Protein p= new Protein();
        if(proteins.get(rgdId)!=null){
            p=proteins.get(rgdId);
        }else{
            p=pdao.getProtein(rgdId);
            proteins.put(rgdId, p);
        }
        return p;
    }


    public String getAttributes(int interactionKey) throws Exception {
        InteractionAttributesDAO adao= new InteractionAttributesDAO();
        List<InteractionAttribute> attributes=adao.getAttributes(interactionKey);
        StringBuilder sb=new StringBuilder();
        boolean first=true;
        for(InteractionAttribute a: attributes){
            if(first){
                first=false;
                sb.append(a.getAttributeName()).append(":").append(a.getAttributeValue());
            }else{
                sb.append("; ").append(a.getAttributeName()).append(":").append(a.getAttributeValue());
            }
        }
        return sb.toString();
    }

    public Collection[] split(List<Integer> rgdids, int size) throws Exception {
        int numOfBatches = rgdids.size() / size + 1;
        Collection[] batches = new Collection[numOfBatches];

        for(int index = 0; index < numOfBatches; ++index) {
            int count = index + 1;
            int fromIndex = Math.max((count - 1) * size, 0);
            int toIndex = Math.min(count * size, rgdids.size());
            batches[index] = rgdids.subList(fromIndex, toIndex);
        }

        return batches;
    }
    public List<Gene> getGeneByProteinRgdId(int proteinRgdId) throws Exception {
        proteinRgdId=pdao.getRgdId("Q91Y79");
        System.out.println("PROTEIN RGDID: "+ proteinRgdId);
        List<Gene> genes= new ArrayList<>();
        if(geneProteinMap.get(proteinRgdId)!=null){
            genes=geneProteinMap.get(proteinRgdId);
        }else{
            genes=assocDao.getAssociatedGenesForMasterRgdId(proteinRgdId, "protein_to_gene");
            geneProteinMap.put(proteinRgdId, genes);
        }
        System.out.println("GENES SIZE:"+genes.size());
        return genes;
    }
    public static void main(String[] args) throws Exception {
        InteractionsService service= new InteractionsService();
        service.getGeneByProteinRgdId(0);

        System.out.println("DONE!!");
    }
}
