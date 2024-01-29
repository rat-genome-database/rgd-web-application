package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.datamodel.models.SubmittedStrain;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import jakarta.servlet.http.HttpServletRequest;
import org.apache.commons.lang3.StringUtils;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * @author jdepons
 * @since Jun 2, 2008
 */
public class GeneEditObjectController extends EditObjectController {

    GeneDAO geneDAO = new GeneDAO();
    SubmittedStrainDao sdao= new SubmittedStrainDao();
    private SubmittedStrain submittedStrain= new SubmittedStrain();
    private String subObjectType;

    public String getSubObjectType() {
        return subObjectType;
    }
    public void setSubObjectType(String subObjectType) {
        this.subObjectType = subObjectType;
    }
    public SubmittedStrain getSubmittedStrain() {
        return submittedStrain;
    }

    public void setSubmittedStrain(SubmittedStrain submittedStrain) {
        this.submittedStrain = submittedStrain;
    }

    public String getViewUrl() throws Exception {
       return "editGene.jsp";
    }

    public int getObjectTypeKey() {
        return RgdId.OBJECT_KEY_GENES;
    }

    public Object getObject(int rgdId) throws Exception{
        return geneDAO.getGene(rgdId);
    }

    public Object getSubmittedObject(int submissionKey) throws Exception {
        SubmittedStrainDao sdao= new SubmittedStrainDao();
        SubmittedStrain s= sdao.getSubmittedStrainBySubmissionKey(submissionKey);
        this.setSubmittedStrain(s);
        Gene gene = new Gene();
        this.setSubObjectType(this.getGeneType());


        if(this.getGeneType().equalsIgnoreCase("allele")){
            System.out.println("gene type:" + this.getGeneType());
            gene.setType("allele");
            gene.setSymbol(s.getAlleleSymbol());

        }
        else {
        gene.setType("gene");
            gene.setSymbol(s.getGeneSymbol());
        }

        return gene;
    }
    public Object newObject() throws Exception{
        Gene gene = new Gene();
        gene.setType("gene");
        return gene;
    }
    
    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);

        // new gene: both parameters 'key' and 'rgdId' are 0
        int geneRgdId = Integer.parseInt(req.getParameter("rgdId"));
        Gene gene;
        if( geneRgdId==0 ) {
            // create a new gene
            gene = createNewGene(req);
        }
        else {

            List<Alias> aliases = new ArrayList<>();

            gene = geneDAO.getGene(geneRgdId);
            if (persist) {
                String newName = req.getParameter("name");
                String newSymbol = req.getParameter("symbol");
                String newType = req.getParameter("type");

                // generate nomenclature event if gene name or symbol or type is changed
                String whatChanged = "";
                if( !Utils.stringsAreEqual(newName, gene.getName()) ||
                    !Utils.stringsAreEqual(newSymbol, gene.getSymbol()) ||
                    !Utils.stringsAreEqual(newType, gene.getType() )) {

                    if( !Utils.stringsAreEqual(newName, gene.getName()) ) {
                        whatChanged = "Name ";

                        // create alias for old gene name only if the previous name was not null
                        if( !Utils.isStringEmpty(gene.getName()) ) {
                            Alias alias = new Alias();
                            alias.setRgdId(gene.getRgdId());
                            alias.setTypeName("old_gene_name");
                            alias.setValue(gene.getName());
                            alias.setNotes("created by Gene Edit on "+new Date());
                            aliases.add(alias);
                        }
                    }

                    if( !Utils.stringsAreEqual(newSymbol, gene.getSymbol()) ) {

                        if( geneDAO.getGenesBySymbol(newSymbol, gene.getSpeciesTypeKey())!=null ) {
                            throw new Exception("symbol conflict - gene with symbol "+newSymbol+" already exists");
                        }

                        if( whatChanged.isEmpty() )
                            whatChanged = "Symbol ";
                        else
                            whatChanged += "and Symbol ";

                        Alias alias = new Alias();
                        alias.setRgdId(gene.getRgdId());
                        alias.setTypeName("old_gene_symbol");
                        alias.setValue(gene.getSymbol());
                        alias.setNotes("created by Gene Edit on "+new Date());
                        aliases.add(alias);
                    }

                    if( !Utils.stringsAreEqual(newType, gene.getType()) ) {
                        if( whatChanged.isEmpty() )
                            whatChanged = "Type ";
                        else
                            whatChanged += "and Type ";
                    }
                    whatChanged += "changed";
                    if( whatChanged.contains("Type") )
                        whatChanged += " (type changed from ["+gene.getType()+"] to ["+newType+"])";

                    NomenclatureEvent event = new NomenclatureEvent();
                    event.setDesc(whatChanged);
                    event.setEventDate(new Date());
                    event.setName(newName);
                    event.setNomenStatusType("APPROVED");
                    event.setOriginalRGDId(gene.getRgdId());
                    event.setPreviousName(gene.getName());
                    event.setPreviousSymbol(gene.getSymbol());
                    event.setRefKey("2600");
                    event.setRgdId(gene.getRgdId());
                    event.setSymbol(newSymbol);

                    NomenclatureDAO dao = new NomenclatureDAO();
                    dao.createNomenEvent(event);
                }

                gene.setNotes(req.getParameter("notes"));
                gene.setName(newName);
                gene.setSymbol(newSymbol);
                gene.setDescription(StringUtils.normalizeSpace(req.getParameter("description")));
                gene.setType(newType);
                gene.setRefSeqStatus(req.getParameter("refseq_status"));

                if( gene.getSpeciesTypeKey()==SpeciesType.RAT && (whatChanged.contains("Name") || whatChanged.contains("Symbol")) ) {
                    gene.setNomenSource("RGD");
                }

                geneDAO.updateGene(gene);

                insertAliases(aliases);
            }
        }
        return gene;
    }

    Gene createNewGene(HttpRequestFacade req) throws Exception {

        // create new rgd id
        RGDManagementDAO rdao = new RGDManagementDAO();
        RgdId id = rdao.createRgdId(this.getObjectTypeKey() ,req.getParameter("objectStatus"), SpeciesType.parse(req.getParameter("speciesType")));

        // now create a gene object

        if( this.getSubObjectType()!=null && !this.getSubObjectType().equals("")){
            if(this.getSubObjectType().equalsIgnoreCase("allele")){
                sdao.updateAlleleRgdId(this.getSubmittedStrain().getSubmittedStrainKey(), id.getRgdId());
            }
            else if(this.getSubObjectType().equalsIgnoreCase("gene")){
                sdao.updateGeneRgdId(this.getSubmittedStrain().getSubmittedStrainKey(), id.getRgdId());
            }
        }
        Gene gene = new Gene();
        gene.setRgdId(id.getRgdId());
        gene.setSpeciesTypeKey(id.getSpeciesTypeKey());
        gene.setType(req.getParameter("type"));
        gene.setDescription(StringUtils.normalizeSpace(req.getParameter("description")));
        gene.setName(req.getParameter("name"));
        gene.setNotes(req.getParameter("notes"));
        gene.setSymbol(req.getParameter("symbol"));
        geneDAO.insertGene(gene);
        return gene;
    }
}
