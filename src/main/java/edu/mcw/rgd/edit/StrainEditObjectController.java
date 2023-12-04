package edu.mcw.rgd.edit;

import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.dao.impl.StrainDAO;
import edu.mcw.rgd.dao.impl.RGDManagementDAO;
import edu.mcw.rgd.dao.impl.SubmittedStrainDao;
import edu.mcw.rgd.datamodel.models.SubmittedStrain;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;

import jakarta.servlet.http.HttpServletRequest;
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;

/**
 * @author jdepons
 * @since Jun 2, 2008
 */
public class StrainEditObjectController extends EditObjectController {

    StrainDAO dao = new StrainDAO();
    RGDManagementDAO rdao = new RGDManagementDAO();
    SubmittedStrainDao sdao= new SubmittedStrainDao();
    private SubmittedStrain submittedStrain= new SubmittedStrain();

    public SubmittedStrain getSubmittedStrain() {
        return submittedStrain;
    }

    public void setSubmittedStrain(SubmittedStrain submittedStrain) {
        this.submittedStrain = submittedStrain;
    }

    public String getViewUrl() throws Exception {
       return "editStrain.jsp";
    }

    public int getObjectTypeKey() {
        return RgdId.OBJECT_KEY_STRAINS;
    }

    public Object getObject(int rgdId) throws Exception{
        return new StrainDAO().getStrain(rgdId);
    }

    public Object getSubmittedObject(int submissionKey) throws Exception {
        SubmittedStrain s= sdao.getSubmittedStrainBySubmissionKey(submissionKey);
        this.setSubmittedStrain(s);

        Strain strain= new Strain();
        strain.setRgdId(-1);
        strain.setKey(-1);
        strain.setSource(s.getSource());
        strain.setImageUrl(s.getImageUrl());
        strain.setSpeciesTypeKey(3);
        strain.setGeneticStatus(s.getGeneticStatus());
        strain.setSymbol(s.getStrainSymbol());
        strain.setStrainTypeName(s.getStrainType());
        strain.setGeneticStatus(s.getGeneticStatus());
        strain.setModificationMethod(s.getMethod());
        strain.setDescription(s.getOrigin());
        strain.setSource(s.getSource());
        strain.setResearchUse(s.getResearchUse());
        return strain;
    }
    public Object newObject() throws Exception{
        Strain strain = new Strain();
        strain.setRgdId(-1);
        strain.setKey(-1);
        return strain;
    }
    
    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        if (req.getParameter("key").equals("")) {
            return null;
        }

        Strain st;
        List<NomenclatureEvent> nomenEvents = new ArrayList<>();
        List<Alias> aliases = new ArrayList<>();

        boolean isNew = false;

        String symbol = req.getParameter("symbol");
        this.checkSet("Symbol", symbol);

        String name = req.getParameter("name");

        int rgdId = Integer.parseInt(req.getParameter("rgdId"));
        String newImageUrl= null;
        if (rgdId == -1 ) {
            RgdId id = rdao.createRgdId(this.getObjectTypeKey() ,req.getParameter("objectStatus"),SpeciesType.parse(req.getParameter("speciesType")));
            rgdId = id.getRgdId();
            isNew = true;
            st = new Strain();
            st.setRgdId(rgdId);
            int submissionKey= this.getSubmittedStrain().getSubmittedStrainKey();


            /************************UPDATE SUBMITTED STRAIN IMAGE NAME TO RGDID ASSIGNED TO THE STRAIN********************/

            if(submissionKey!=0){
                sdao.updateStrainRgdId(submissionKey,rgdId);
                try{
                    newImageUrl= this.updateImageFileName(submissionKey, rgdId) ;
                }catch (Exception e){
                    e.printStackTrace();
                    throw e;
                }
            }
            /*************************************END UPDATE************************************************/

        }else {
            st = dao.getStrain(Integer.parseInt(req.getParameter("rgdId")));
        }

        if (!isNew) {
            if( !Utils.stringsAreEqual(st.getSymbol(), symbol) || !Utils.stringsAreEqual(st.getName(), name) ) {
                NomenclatureEvent ne = new NomenclatureEvent();
                ne.setDesc("Symbol and/or name change");
                ne.setEventDate(new Date());
                ne.setName(name);
                ne.setSymbol(symbol);
                ne.setNomenStatusType("APPROVED");
                ne.setOriginalRGDId(st.getRgdId());
                ne.setPreviousName(st.getName());
                ne.setPreviousSymbol(st.getSymbol());
                ne.setRefKey("853");
                ne.setRgdId(rgdId);
                nomenEvents.add(ne);

                if( !Utils.stringsAreEqual(st.getSymbol(), symbol) ) {
                    Alias alias = new Alias();
                    alias.setRgdId(rgdId);
                    alias.setTypeName("old_strain_symbol");
                    alias.setValue(st.getSymbol());
                    alias.setNotes("created by Strain Edit on "+new Date());
                    aliases.add(alias);
                }

                if( !Utils.stringsAreEqual(st.getName(), name) ) {
                    Alias alias = new Alias();
                    alias.setRgdId(rgdId);
                    alias.setTypeName("old_strain_name");
                    alias.setValue(st.getName());
                    alias.setNotes("created by Strain Edit on "+new Date());
                    aliases.add(alias);
                }
            }
        }
        st.setSymbol(symbol);
        st.setName(name);

        st.setStrain(req.getParameter("strain"));
        st.setSubstrain(req.getParameter("subStrain"));
        st.setGenetics(req.getParameter("genetics"));
        st.setGeneticStatus(req.getParameter("geneticStatus"));
        st.setInbredGen(req.getParameter("inbredGen"));
        st.setDescription(req.getParameter("origin"));
        st.setColor(req.getParameter("color"));
        st.setChrAltered(req.getParameter("chrAltered"));
        st.setSource(req.getParameter("source"));
        st.setNotes(req.getParameter("notes"));
        if(newImageUrl!=null){
            st.setImageUrl(newImageUrl);
        }else{
            st.setImageUrl(req.getParameter("imageUrl"));
        }

        st.setResearchUse(req.getParameter("researchUse"));
        st.setStrainTypeName(req.getParameter("strainTypeName"));

        String modificationMethod = req.getParameter("modificationMethod");
        if( modificationMethod.equals("N/A") ) {
            modificationMethod = null;
        }
        st.setModificationMethod(modificationMethod);

        String backgroundStrainRgdId = req.getParameter("backgroundStrainRgdId");
        if( !Utils.isStringEmpty(backgroundStrainRgdId) ) {
            st.setBackgroundStrainRgdId(Integer.parseInt(backgroundStrainRgdId));
        }

        if (persist) {
            if (isNew) {
                try {
                    dao.insertStrain(st);
                }catch (Exception e) {
                    rdao.deleteRgdId(st.getRgdId());
                    throw e;
                }
            } else {
                dao.updateStrain(st);
                this.addNomenEvents(nomenEvents);
                insertAliases(aliases);
            }

            updateStrainStatus(st, req);
        }

        return st;
    }

    void updateStrainStatus(Strain st, HttpRequestFacade req) throws Exception {

        // compare last strain status: incoming vs database
        Strain.Status statusInRgd = st.getLastStatusObject();
        if( statusInRgd==null ) {
            statusInRgd = st.createStatus();
            statusInRgd.strainRgdId = st.getRgdId();
        }
        Strain.Status statusIncoming = st.createStatus();
        statusIncoming.strainRgdId = st.getRgdId();

        String yesNo = req.getParameter("live_animals");
        if( yesNo.equals("Yes") ) {
            statusIncoming.liveAnimals = true;
        } else if( yesNo.equals("No") ) {
            statusIncoming.liveAnimals = false;
        }
        yesNo = req.getParameter("embryo");
        if( yesNo.equals("Yes") ) {
            statusIncoming.cryopreservedEmbryo = true;
        } else if( yesNo.equals("No") ) {
            statusIncoming.cryopreservedEmbryo = false;
        }
        yesNo = req.getParameter("sperm");
        if( yesNo.equals("Yes") ) {
            statusIncoming.cryopreservedSperm = true;
        } else if( yesNo.equals("No") ) {
            statusIncoming.cryopreservedSperm = false;
        }
        yesNo = req.getParameter("cryorecovery");
        if( yesNo.equals("Yes") ) {
            statusIncoming.cryorecovery = true;
        } else if( yesNo.equals("No") ) {
            statusIncoming.cryorecovery = false;
        }
        statusIncoming.statusDate = new Date();

        if( !statusInRgd.equals(statusIncoming) ) {
            dao.insertStatusLog(statusIncoming);
        }
    }


    public String updateImageFileName(int key, int rgdId) throws Exception{
        SubmittedStrain s= this.getSubmittedStrain();
        String newImageUrl= null;
        String imageUrl= s.getImageUrl();
        if(imageUrl!=null && imageUrl.length()>0) {

            File oldFile = new File(imageUrl);
            String path = oldFile.getPath();
            int lastIndex= path.lastIndexOf(File.separator);
            String location = path.substring(0, lastIndex);
            File newFileName = new File(location + File.separator + "strain_" + rgdId + ".png");
            if (oldFile.renameTo(newFileName)) {
                newImageUrl=newFileName.getPath();
                //System.out.println(newImageUrl);
                sdao.updateImageUrl(key, newFileName.getPath());

            }
        }
        return newImageUrl;
    }

}