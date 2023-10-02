package edu.mcw.rgd.pathway.controller;

import edu.mcw.rgd.dao.impl.*;
import edu.mcw.rgd.dao.spring.StringMapQuery;
import edu.mcw.rgd.datamodel.*;
import edu.mcw.rgd.ontology.OntAnnotBean;
import edu.mcw.rgd.ontology.OntAnnotController;
import edu.mcw.rgd.pathway.PathwayDiagramController;
import edu.mcw.rgd.process.Utils;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.mvc.Controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.File;
import java.util.*;
import java.util.Map;

/**
 * Created by IntelliJ IDEA.
 * User: pjayaraman
 * Date: Jun 7, 2011
 * Time: 5:58:09 PM
 */
public class PathwayNewRecordController implements Controller {

    PathwayDAO pwDAO = new PathwayDAO();
    AnnotationDAO annDao = new AnnotationDAO();
    OntologyXDAO ontxDao = new OntologyXDAO();
    ReferenceDAO refDao = new ReferenceDAO();
    private static String uploadingDir;
    private static String dataDir;

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        Pathway pw = null;
        HttpRequestFacade req = new HttpRequestFacade(request);

        // download pathway annotations
        if(req.getParameter("d").equals("1") ) {

            ModelAndView mv = new ModelAndView("/WEB-INF/jsp/ontology/downloadAnnotation.jsp");
            OntAnnotBean bean = new OntAnnotBean();
            bean.setShowAnnotsForAllSpecies(true);
            mv.addObject("bean", bean);

            // load annotations
            OntAnnotController.loadAnnotations(bean, ontxDao, request, OntAnnotBean.MAX_ANNOT_COUNT);
            return mv;
        }

        ArrayList error = new ArrayList();
        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        String accId = req.getParameter("acc_id");

        Pathway nuveauPathway = pwDAO.getPathwayInfo(accId);

        String mode;
        if(nuveauPathway!=null){
            mode = "pathwayStored";
        }else{
            mode = "pathwayNotStored";
        }
        //System.out.println("mode is:"+ mode);
        
        String typeOfView;
        if(req.getParameter("processType").isEmpty()){
            typeOfView = "view";
        }else{
            typeOfView =  req.getParameter("processType");
        }

        if((typeOfView.equals("create"))||(typeOfView.equals("update"))){

            String pName = req.getParameter("pathwayName");
            String pDesc = req.getParameter("pathwayDesc");
            List<String> refIds = req.getParameterValues("RGDID");
            List<String> altPath = req.getParameterValues("AltPathAccID");
            List<String> assObj = req.getParameterValues("selectObject");
            List<String> extName = req.getParameterValues("obj_xdb_name");
            List<String> extDesc = req.getParameterValues("obj_xdb_desc");
            List<String> extAcc = req.getParameterValues("obj_xdb_accession");
            List<String> extKey = req.getParameterValues("obj_xdb_key");
            List<String> extUrl = req.getParameterValues("obj_xdb_url");

            //adding pathway objects
            List<PathwayObject> newAssObjList = new ArrayList<>();
            for(int i=0; i<extName.size(); i++){
                PathwayObject newAssObj = new PathwayObject();
                newAssObj.setObjName(extName.get(i));
                newAssObj.setObjDesc(extDesc.get(i));
                newAssObj.setId(accId);
                newAssObj.setAccId(extAcc.get(i));

                int objectID = Integer.parseInt(assObj.get(i));
                if(objectID!=0){
                    newAssObj.setTypeId(objectID);
                    List idList = pwDAO.getObjectTypeName(objectID);
                    if(idList.size()==0){
                        error.add("please check your object type - " + objectID);
                    }else{
                        newAssObj.setTypeName((String) idList.get(0));
                        //adding new pathwayObject to list
                        newAssObjList.add(newAssObj);
                    }

                    if(!(extUrl.get(i).equals(""))){
                        newAssObj.setUrl(extUrl.get(i));
                    }else{
                        newAssObj.setUrl(null);
                    }

                    if( !extKey.get(i).isEmpty() ) {
                        newAssObj.setXdb_key(Integer.parseInt(extKey.get(i)));
                    } else{
                        newAssObj.setXdb_key(null);
                    }
                }
            }

            //adding reference objects
            List<Reference> newRefList = new ArrayList<>();
            if(refIds.size()!=0){
                for(int i=0; i<refIds.size(); i++){

                    PathwayRef newrefObj = new PathwayRef();
                    //get reference object using dao
                    int refRGD=0;

                    try{
                       refRGD = Integer.parseInt(refIds.get(i));
                       Reference refObject = refDao.getReference(refRGD);
                        //set the two values that pathwayReference Obejct uses.
                        newrefObj.setPwId(accId);
                        newrefObj.setRefKey(String.valueOf(refObject.getKey()));
                        //adding new referenceObject to list
                        newRefList.add(refObject);
                    }catch (Exception e){
                        error.add("Reference Object not in Database - "+refRGD + "\nRef:"+e);
                    }
                }
            }else{
                error.add("check your values. there is no data in Pathway References");
            }

            String pathForDiagramHTML = uploadingDir+accId.replaceAll(":","")+"/"+pName.replace("/","-")+".html";
            String pathForDiagramFolder = uploadingDir+accId.replaceAll(":","")+"/"+pName.replace("/","-");

            if(mode.equals("pathwayNotStored")){
                File html = new File(pathForDiagramHTML);
                File folder = new File(pathForDiagramFolder);
                if(folder.exists()){
                    if(html.exists()){
                     //System.out.println("exists");
                    }
                }else{
                    error.add("something went wrong while processing Diagram image for Pathway: " +accId+
                            "with term Name: "+pName+"\nEither you have forgotten to upload the image or the wrong diagrams were updated." +
                            "Please upload the correct pathway Diagram");
                }
            }

            if(error.size()>0){
                ModelAndView mv = new ModelAndView("/WEB-INF/jsp/curation/pathway/pathwayCreate.jsp");
                mv.addObject("uploadingDir", uploadingDir);
                mv.addObject("dataDir", dataDir);
                mv.addObject("error", error);
                return mv;
            }else{
                //creating new pathway
                Pathway createdPwObject = new Pathway();
                createdPwObject.setId(accId);
                createdPwObject.setName(pName);
                createdPwObject.setDescription(pDesc);

                if((altPath.size()>0)&&(altPath.get(0).length()==10)){
                    createdPwObject.setHasAlteredPath("Y");
                }else{
                     createdPwObject.setHasAlteredPath("N");
                }
                if(newAssObjList.size()==0){
                    createdPwObject.setObjectList(null);
                }else{
                    createdPwObject.setObjectList(newAssObjList);
                }
                createdPwObject.setReferenceList(newRefList);




                if(mode.equals("pathwayNotStored")){
                    if(typeOfView.equals("create")){

                        try{
                            String acc_id = pwDAO.insertPathwayData(createdPwObject);
                            if((altPath.size()>0)&&(altPath.get(0).length()==10)){
                                pwDAO.insertAltPathwayIds(acc_id, altPath);
                            }

                            pw = pwDAO.getPathwayInfo(acc_id);

                            String htmlContent = new PathwayDiagramController().generateContent("map", pw.getId().replaceAll(":",""));
                            if(htmlContent.equals("")){
                                error.add("something went wrong with procesing your diagram image for this pathway. The diagram image didnt get created. " +
                                        "Please ensure you've uploaded all files needed for this pathway");
                            }

                        }catch(Exception insertPathwayError){
                            error.add("something went wrong while inserting data into the database. " + insertPathwayError+
                                    "Please Check your data:"+ accId);
                            pwDAO.deletePathwayData(createdPwObject);
                            ModelAndView mvErr = new ModelAndView("/WEB-INF/jsp/curation/pathway/pathwayCreate.jsp?");
                            mvErr.addObject("uploadingDir", uploadingDir);
                            mvErr.addObject("dataDir", dataDir);
                            mvErr.addObject("error", error);
                            return mvErr;
                        }

                    }else
                    if(typeOfView.equals("update")){

                        error.add("you cannot update a pathway if it isnt stored:" + accId);
                        //updatePathway
                        ModelAndView mvErr = new ModelAndView("/WEB-INF/jsp/curation/pathway/pathwayCreate.jsp?");
                        mvErr.addObject("uploadingDir", uploadingDir);
                        mvErr.addObject("dataDir", dataDir);
                        mvErr.addObject("error", error);
                        return mvErr;

                    }
                }else if(mode.equals("pathwayStored")){
                    if(typeOfView.equals("create")){
                        //update pathway
                        pw = pwDAO.getPathwayInfo(accId);
                        error.add("something is wrong with Pathway ID: "+accId+" having Pathway Name: "+pw.getName()+
                                ". You cannot 'Create' an already-stored pathway. I recommend you create this pathway from scratch.");
                        ModelAndView mvErr = new ModelAndView("/WEB-INF/jsp/curation/pathway/pathwayCreate.jsp?");
                        mvErr.addObject("uploadingDir", uploadingDir);
                        mvErr.addObject("dataDir", dataDir);
                        mvErr.addObject("error", error);
                        return mvErr;
                    }else
                    if(typeOfView.equals("update")){
                        //updatePathway
                        pathForDiagramHTML = uploadingDir+accId.replaceAll(":","")+"/"+pName.replace("/","-")+".html";
                        pathForDiagramFolder = uploadingDir+accId.replaceAll(":","")+"/"+pName.replace("/","-");
                        if((pathForDiagramFolder!=null)&&(pathForDiagramHTML!=null)){
                            File html = new File(pathForDiagramHTML);
                            File folder = new File(pathForDiagramFolder);
                            if(folder.exists()){
                                if(html.exists()){
                                    String htmlContent="";
                                    //System.out.println("exists");
                                    try{
                                    htmlContent = new PathwayDiagramController().generateContent("map", createdPwObject.getId().replaceAll(":",""));
                                    }catch (Exception htmlException){
                                        error.add("something went wrong with procesing your diagram image for this pathway: " +
                                                htmlException +
                                                "An exception occurred. ");
                                    }
                                    if(htmlContent.equals("")){
                                        error.add("something went wrong with procesing your diagram image for this pathway: " +
                                                "the diagram image didnt get created. " +
                                                "Please ensure you've uploaded all files needed for this pathway");
                                    }
                                }else{
                                    error.add("something went wrong while processing Diagram image for Pathway: " +createdPwObject.getId()+
                                        "with term Name: "+createdPwObject.getName()+"\nEither you have forgotten to upload the html file or the wrong html files were uploaded." +
                                        "Please upload the files for the correct pathway Diagram");
                                }
                            }else{
                                error.add("something went wrong while processing Diagram image for Pathway: " +createdPwObject.getId()+
                                        "with term Name: "+createdPwObject.getName()+"\nEither you have forgotten to upload the folder with the files or the wrong folders were uploaded." +
                                        "Please upload the correct pathway Diagram");
                            }
                            if(error.size()>0){
                                ModelAndView mvErrUp = new ModelAndView("/WEB-INF/jsp/curation/pathway/pathwayCreate.jsp?");
                                mvErrUp.addObject("uploadingDir", uploadingDir);
                                mvErrUp.addObject("dataDir", dataDir);
                                mvErrUp.addObject("error", error);
                                return mvErrUp;
                            }
                        }
                        else{
                            error.add("cannot find pathway uploaded. please upload Pathway. ");
                            pwDAO.deletePathwayData(createdPwObject);
                            ModelAndView mvErrUp = new ModelAndView("/WEB-INF/jsp/curation/pathway/pathwayCreate.jsp?");
                            mvErrUp.addObject("uploadingDir", uploadingDir);
                            mvErrUp.addObject("dataDir", dataDir);
                            mvErrUp.addObject("error", error);
                            return mvErrUp;
                        }


                        try{
                            String acc_id = pwDAO.updatePathwayData(createdPwObject);
                            if((altPath.size()>0)&&(altPath.get(0).length()==10)){
                                pwDAO.insertAltPathwayIds(acc_id, altPath);
                            }
                            pw = pwDAO.getPathwayInfo(accId);
                        }catch(Exception updatePathwayError){
                            error.add("something went wrong during update. " +updatePathwayError+
                                    "Please check your data:" + accId);
                            pwDAO.deletePathwayData(createdPwObject);
                            ModelAndView mvErrUp = new ModelAndView("/WEB-INF/jsp/curation/pathway/pathwayCreate.jsp?");
                            mvErrUp.addObject("uploadingDir", uploadingDir);
                            mvErrUp.addObject("dataDir", dataDir);
                            mvErrUp.addObject("error", error);
                            return mvErrUp;
                        }
                    }
                }
            }
        }
        if(typeOfView.equals("view")){
            //get pathwayID
            ArrayList errorNew = new ArrayList();
            request.setAttribute("error", errorNew);
            ModelAndView mv = new ModelAndView("/WEB-INF/jsp/pathway/error.jsp");


            if( !accId.isEmpty() ){
                pw = pwDAO.getPathwayInfo(accId);

                if(pw!=null){
                    String pathForDiagramHTML = uploadingDir+pw.getId().replaceAll(":","")+"/"+pw.getName().replace("/","-")+".html";
                    String pathForDiagramFolder = uploadingDir+pw.getId().replaceAll(":","")+"/"+pw.getName().replace("/","-");

                    if((pathForDiagramFolder!=null)&&(pathForDiagramHTML!=null)){
                        File html = new File(pathForDiagramHTML);
                        File folder = new File(pathForDiagramFolder);
                        if(folder.exists()){
                            if(html.exists()){
                                String htmlContent = new PathwayDiagramController().generateContent("map", pw.getId().replaceAll(":",""));
                                if(htmlContent.equals("")){
                                    errorNew.add("something went wrong with procesing your diagram image for this pathway. the diagram image didnt get created. " +
                                            "Please ensure you've uploaded all files needed for this pathway");
                                }
                            }
                        }else{
                            errorNew.add("Something went wrong while processing Diagram image for Pathway: " +accId+
                                    " with Term name: "+pw.getName()+"\nEither you have forgotten to upload the image or the wrong diagrams were updated." +
                                    "Please Edit the Pathway and upload the correct pathway Diagram");
                        }
                    }else{
                        errorNew.add("Cannot find path to the uploaded pathway. " +
                                "Please Edit the Pathway and upload the correct pathway Diagram");
                    }
                }
            }else if(accId.isEmpty()){

                errorNew.add("Pathway Accession id (acc_id) param is missing!\nPlease see list of available pathways");
            }

            if(errorNew.size()>0){
                mv.addObject("error", errorNew);
                Map<String, String> pwAccMap = new PathwayHomeController().makePathwayListsMap();
                mv.addObject("pwMap", pwAccMap);
                return mv;
            }

        }
        if(pw!=null){
            ModelAndView mv = new ModelAndView("/WEB-INF/jsp/pathway/pathwayRecord.jsp");
            mv.addObject("pathway", pw);

            //getting annotations
            Map<String, Set<Integer>> oneDisManyGenes = new TreeMap<String, Set<Integer>>();
            Map<String, Set<Integer>> onePheManyGenes = new TreeMap<String, Set<Integer>>();
            Map<String, Set<Integer>> onePathManyGenes = new TreeMap<String, Set<Integer>>();
            Map<Integer, List<String>> oneGeneManyTerms = new TreeMap<Integer, List<String>>();


            // populates ModelAndView attributes: 'speciesTypeKey', 'hasAnnotations', 'geneMap'
            Map<Integer,String> geneMap = loadAnnotatedGenes(req.getParameter("species"), pw.getId(), mv);

            Map<String,String> termMap = new HashMap<String, String>();
            mv.addObject("termMap", termMap);

            for( Integer rgdId: geneMap.keySet() ){

                List<StringMapQuery.MapPair> annotations = annDao.getAnnotationTermAccIds(rgdId);
                if( annotations.isEmpty() )
                    continue;

                List<String> disList = new ArrayList<String>();

                for( StringMapQuery.MapPair ann: annotations ){
                    String annAccId = ann.keyValue;
                    String annTerm = ann.stringValue;
                    termMap.put(annAccId, annTerm);

                    if( annAccId.startsWith("DOID:") ){
                        addRgdId(oneDisManyGenes, annAccId, rgdId);
                        disList.add(annAccId);
                    }else if( annAccId.startsWith("MP:") ){
                        addRgdId(onePheManyGenes, annAccId, rgdId);
                        disList.add(annAccId);
                    }else if( annAccId.startsWith("PW:") ){
                        addRgdId(onePathManyGenes, annAccId, rgdId);
                        disList.add(annAccId);
                    }
                }

                sortTerms(disList, termMap);
                oneGeneManyTerms.put(rgdId, disList);
            }

            Map<String, List<Integer>> oneDisManyGenesMap = sortRgdIds(oneDisManyGenes, geneMap);
            mv.addObject("OneDiseaseManyGenes", oneDisManyGenesMap);
            List<String> oneDisManyGenesKeys = new ArrayList<String>(oneDisManyGenes.keySet());
            sortTerms(oneDisManyGenesKeys, termMap);
            mv.addObject("OneDiseaseManyGenesKeys", oneDisManyGenesKeys);

            Map<String, List<Integer>> onePheManyGenesMap = sortRgdIds(onePheManyGenes, geneMap);
            mv.addObject("OnePheManyGenes", onePheManyGenesMap);
            List<String> onePheManyGenesKeys = new ArrayList<String>(onePheManyGenes.keySet());
            sortTerms(onePheManyGenesKeys, termMap);
            mv.addObject("OnePheManyGenesKeys", onePheManyGenesKeys);

            Map<String, List<Integer>> onePathManyGenesMap = sortRgdIds(onePathManyGenes, geneMap);
            mv.addObject("OnePathManyGenes", onePathManyGenesMap);
            List<String> onePathManyGenesKeys = new ArrayList<String>(onePathManyGenes.keySet());
            sortTerms(onePathManyGenesKeys, termMap);
            mv.addObject("OnePathManyGenesKeys", onePathManyGenesKeys);

            mv.addObject("OneGeneManyTerms", oneGeneManyTerms);
            List<Integer> oneGeneManyTermsKeys = new ArrayList<Integer>(oneGeneManyTerms.keySet());
            sortRgdIds(oneGeneManyTermsKeys, geneMap);
            mv.addObject("OneGeneManyTermsKeys", oneGeneManyTermsKeys);


            OntAnnotBean bean = new OntAnnotBean();
            bean.setShowAnnotsForAllSpecies(true);
            mv.addObject("bean", bean);

            // load annotations
            OntAnnotController.loadAnnotations(bean, ontxDao, request, OntAnnotBean.MAX_ANNOT_COUNT);

            return mv;
        }else{
            ArrayList errorNew = new ArrayList();
            request.setAttribute("error", errorNew);
            errorNew.add("This term isn't yet in the Pathway database:"+accId+" \nPlease see list of available pathways");
            ModelAndView mv = new ModelAndView("/WEB-INF/jsp/pathway/error.jsp");
            mv.addObject("error", errorNew);

            Map<String, String> pwAccMap = new PathwayHomeController().makePathwayListsMap();
            mv.addObject("pwMap", pwAccMap);
            mv.addObject("uploadingDir", uploadingDir);
            return mv;
        }
    }


     void sortTerms(List<String> termAccIds, final Map<String,String> termMap){
         Collections.sort(termAccIds, new Comparator<String>(){
            public int compare(String o1, String o2){
                String term1 = termMap.get(o1);
                String term2 = termMap.get(o2);
                return Utils.stringsCompareToIgnoreCase(term1, term2);
            }
         });
     }

    Map<String, List<Integer>> sortRgdIds(Map<String, Set<Integer>> mapTermToRgdIds, final Map<Integer,String> geneMap) {
        Map<String, List<Integer>> map = new HashMap<String, List<Integer>>(mapTermToRgdIds.size());
        for( Map.Entry<String, Set<Integer>> entry: mapTermToRgdIds.entrySet() ) {
            List<Integer> rgdIds = new ArrayList<Integer>(entry.getValue());
            sortRgdIds(rgdIds, geneMap);
            map.put(entry.getKey(), rgdIds);
        }
        return map;
    }

    void sortRgdIds(List<Integer> rgdIds, final Map<Integer,String> geneMap) {
        Collections.sort(rgdIds, new Comparator<Integer>(){
           public int compare(Integer o1, Integer o2){
               String symbol1 = geneMap.get(o1);
               String symbol2 = geneMap.get(o2);
               return Utils.stringsCompareToIgnoreCase(symbol1, symbol2);
           }
        });
    }

    void addRgdId(Map<String, Set<Integer>> oneTermManyGenes, String termAccId, Integer rgdId) {
        Set<Integer> rgdIds = oneTermManyGenes.get(termAccId);
        if( rgdIds==null ) {
            rgdIds = new HashSet<Integer>();
            oneTermManyGenes.put(termAccId, rgdIds);
        }
        rgdIds.add(rgdId);
    }

    Map<Integer,String> loadAnnotatedGenes(String speciesParam, String pwId, ModelAndView mv) throws Exception {
        List<StringMapQuery.MapPair> annGeneList = Collections.emptyList();

        int speciesTypeKey = SpeciesType.RAT;
        if(speciesParam.equals("") || speciesParam.equals("Rat")){
            speciesTypeKey = SpeciesType.RAT;
            annGeneList = annDao.getAnnotatedObjectIdsAndSymbols(pwId, false, speciesTypeKey, RgdId.OBJECT_KEY_GENES);
        }else if(speciesParam.equals("Mouse")){
            speciesTypeKey = SpeciesType.MOUSE;
            annGeneList = annDao.getAnnotatedObjectIdsAndSymbols(pwId, false, speciesTypeKey, RgdId.OBJECT_KEY_GENES);
        }else if(speciesParam.equals("Human")){
            speciesTypeKey = SpeciesType.HUMAN;
            annGeneList = annDao.getAnnotatedObjectIdsAndSymbols(pwId, false, speciesTypeKey, RgdId.OBJECT_KEY_GENES);
        }else if(speciesParam.equalsIgnoreCase("all")){
            speciesTypeKey = SpeciesType.ALL;
            annGeneList = annDao.getAnnotatedObjectIdsAndSymbols(pwId, false, SpeciesType.RAT, RgdId.OBJECT_KEY_GENES);
            annGeneList.addAll(annDao.getAnnotatedObjectIdsAndSymbols(pwId, false, SpeciesType.MOUSE, RgdId.OBJECT_KEY_GENES));
            annGeneList.addAll(annDao.getAnnotatedObjectIdsAndSymbols(pwId, false, SpeciesType.HUMAN, RgdId.OBJECT_KEY_GENES));
        }
        mv.addObject("speciesTypeKey", speciesTypeKey);
        mv.addObject("hasAnnotations", !annGeneList.isEmpty());

        Map<Integer,String> geneMap = new HashMap<Integer,String>();
        for( StringMapQuery.MapPair pair: annGeneList ) {
            geneMap.put(Integer.parseInt(pair.keyValue), pair.stringValue);
        }
        mv.addObject("geneMap", geneMap);

        return geneMap;
    }

    public static String getDataDir() {
        return dataDir;
    }

    public void setDataDir(String dataDir) {
        this.dataDir = dataDir;
    }

    public void setUploadingDir(String uploadingDir){
        this.uploadingDir = uploadingDir;
    }

    public String getUploadingDir() {
        return uploadingDir;
    }
}
