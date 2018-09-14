package edu.mcw.rgd.edit;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;

import javax.servlet.http.HttpServletRequest;
import java.util.Date;

/**
 * Created by IntelliJ IDEA.
 * User: jdepons
 * Date: Jun 2, 2008
 * Time: 8:59:47 AM
 */
public class CellLineEditObjectController extends EditObjectController {

    CellLineDAO dao = new CellLineDAO();
    RGDManagementDAO rdao = new RGDManagementDAO();

    public String getViewUrl() throws Exception {
       return "editCellLine.jsp";

    }
    public int getObjectTypeKey() {
        return RgdId.OBJECT_KEY_CELL_LINES;
    }

    public Object getObject(int rgdId) throws Exception{
        return dao.getCellLine(rgdId);
    }
    public Object getSubmittedObject(int submissionKey) throws Exception {
        return null;
    }
    public Object newObject() throws Exception{
        CellLine cellLine = new CellLine();
        cellLine.setRgdId(-1);
        return cellLine;
    }
    
    public Object update(HttpServletRequest request, boolean persist) throws Exception {
        HttpRequestFacade req = new HttpRequestFacade(request);
        int rgdId = Integer.parseInt(req.getParameter("rgdId"));
        CellLine obj;
        if( rgdId<=0 ) {
            obj = createNew(req);
        }
        else {
            obj = dao.getCellLine(rgdId);
            if (persist) {
                String newName = req.getParameter("name");
                String newSymbol = req.getParameter("symbol");
                String newType = req.getParameter("object_type");

                // generate nomenclature event if name or symbol or type is changed
                if( !Utils.stringsAreEqual(newName, obj.getName()) ||
                    !Utils.stringsAreEqual(newSymbol, obj.getSymbol()) ||
                    !Utils.stringsAreEqual(newType, obj.getObjectType())) {

                    // generate alias if name or symbol changed
                    Alias alias = null;

                    String whatChanged = "";
                    if( !Utils.stringsAreEqual(newName, obj.getName()) ) {
                        whatChanged = "Name ";

                        alias = new Alias();
                        alias.setRgdId(obj.getRgdId());
                        alias.setTypeName("alternate_id");
                        alias.setValue(obj.getName());
                        addAlias(alias);
                    }

                    if( !Utils.stringsAreEqual(newSymbol, obj.getSymbol()) ) {

                        if( whatChanged.isEmpty() )
                            whatChanged = "Symbol ";
                        else
                            whatChanged += "and Symbol ";

                        alias = new Alias();
                        alias.setRgdId(obj.getRgdId());
                        alias.setTypeName("alternate_id");
                        alias.setValue(obj.getSymbol());
                        addAlias(alias);
                    }

                    if( !Utils.stringsAreEqual(newType, obj.getObjectType()) ) {
                        if( whatChanged.isEmpty() )
                            whatChanged = "Type ";
                        else
                            whatChanged += "and Type ";
                    }
                    whatChanged += "changed";
                    if( whatChanged.contains("Type") )
                        whatChanged += " (type changed from ["+obj.getObjectType()+"] to ["+newType+"])";

                    NomenclatureEvent event = new NomenclatureEvent();
                    event.setDesc(whatChanged);
                    event.setEventDate(new Date());
                    event.setName(newName);
                    event.setNomenStatusType("APPROVED");
                    event.setOriginalRGDId(obj.getRgdId());
                    event.setPreviousName(obj.getName());
                    event.setPreviousSymbol(obj.getSymbol());
                    event.setRefKey("2600");
                    event.setRgdId(obj.getRgdId());
                    event.setSymbol(newSymbol);

                    NomenclatureDAO dao = new NomenclatureDAO();
                    dao.createNomenEvent(event);
                }

                obj.setName(newName);
                obj.setSymbol(newSymbol);
                obj.setObjectType(newType);
                update(req, obj);
            }
        }
        return obj;
    }

    CellLine createNew(HttpRequestFacade req) throws Exception {

        // create new rgd id
        RgdId id = rdao.createRgdId(this.getObjectTypeKey() ,req.getParameter("objectStatus"), SpeciesType.parse(req.getParameter("speciesType")));

        // now create a gene object
        CellLine obj = new CellLine();
        obj.setRgdId(id.getRgdId());
        obj.setObjectStatus(id.getObjectStatus());
        obj.setObjectKey(id.getObjectKey());
        obj.setSpeciesTypeKey(id.getSpeciesTypeKey());
        obj.setObjectType(req.getParameter("object_type"));
        obj.setSymbol(req.getParameter("symbol"));
        obj.setName(req.getParameter("name"));

        populateFields(req, obj);

        dao.insertCellLine(obj);
        return obj;
    }

    void update(HttpRequestFacade req, CellLine obj) throws Exception {

        populateFields(req, obj);
        dao.updateCellLine(obj);

        // update last modified date
        rdao.updateLastModifiedDate(obj.getRgdId());
    }

    void populateFields(HttpRequestFacade req, CellLine obj) throws Exception {

        obj.setDescription(req.getParameter("description"));
        obj.setSource(req.getParameter("source"));
        obj.setNotes(req.getParameter("notes"));
        obj.setSoAccId("CL:0000010");

        obj.setAvailability(req.getParameter("availability"));
        obj.setCharacteristics(req.getParameter("characteristics"));
        obj.setGender(req.getParameter("gender"));
        obj.setGermlineCompetent(req.getParameter("germline_competent"));
        obj.setOrigin(req.getParameter("origin"));
        obj.setPhenotype(req.getParameter("phenotype"));
        obj.setResearchUse(req.getParameter("research_use"));
    }

    void addAlias(Alias alias) throws Exception {

        AliasDAO aliasDAO = new AliasDAO();

        Alias aliasInRgd = aliasDAO.getAliasByValue(alias.getRgdId(), alias.getValue());
        if( aliasInRgd==null ) {
            alias.setNotes("created by ObjectEdit tool on "+new Date());
            aliasDAO.insertAlias(alias);
        }
    }
}