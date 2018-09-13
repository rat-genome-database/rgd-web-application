package edu.mcw.rgd.phenominer;


import edu.mcw.rgd.dao.impl.OntologyXDAO;
import edu.mcw.rgd.dao.impl.PhenominerDAO;
import edu.mcw.rgd.datamodel.ontologyx.Term;
import edu.mcw.rgd.datamodel.pheno.*;

import edu.mcw.rgd.datamodel.pheno.Condition;
import edu.mcw.rgd.reporting.Report;
import edu.mcw.rgd.web.HttpRequestFacade;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.text.DecimalFormat;
import java.util.*;

/**
 * Created by mtutaj in July 2011
 * <p>
 * Wizard for PGA LOAD. It is composed of several stages:
 * <ol>
 *     <li>Choose study name and data file</li>
 *     <li>Show the columns in the file</li>
 * </ol>
 */
public class PhenominerPgaLoadController extends PhenominerController {

    PhenominerPgaLoadBean loadBean;
    ArrayList error = new ArrayList();

    OntologyXDAO dao = new OntologyXDAO();
    PhenominerLoadMappings mappings = new PhenominerLoadMappings();

    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpRequestFacade req = new HttpRequestFacade(request);

        ArrayList warning = new ArrayList();
        ArrayList status = new ArrayList();
        error.clear();

        // access the loadBean
        loadBean = (PhenominerPgaLoadBean) request.getSession().getAttribute("pga_bean");
        if( loadBean ==null ) {
            loadBean = new PhenominerPgaLoadBean();
            request.getSession().setAttribute("pga_bean", loadBean);
        }

        // choose stage
        String stage = req.getParameter("stage");
        if( stage.isEmpty() || !stage.startsWith("stage") )
            stage = "stage1";
        // file upload is processed by stage two
        boolean isMultipartContent = ServletFileUpload.isMultipartContent(request);
        if( isMultipartContent )
            stage = "stage2";

        String viewPath = "/WEB-INF/jsp/curation/phenominer/pgaload_"+stage+".jsp";

        if( stage.equals("stage2") ) {
            if( isMultipartContent )
                handleDataFileUpload(req);
            else
                handleCustomStrainMappings(req);
        }
        else if( stage.equals("stage3") ) {
            handleAtmosphericConditions();
        }
        else if( stage.equals("stage4") ) {
            handleDietConditions();
        }
        else if( stage.equals("stage5") ) {
            handleGenders();
        }
        else if( stage.equals("stage6") ) {
            handleRatDiets();
        }
        else if( stage.equals("stage7") ) {
            handlePhenotypes(req);
        }
        else if( stage.equals("stage8") ) {
            handleExperiments();
        }
        else if( stage.equals("stage9") ) {
            handleExperimentRecords();
        }
        else if( stage.equals("stage10") ) {
            persistExperimentsAndRecords();
        }

        if (error.size() > 0) {
            viewPath = "/WEB-INF/jsp/curation/phenominer/pgaload_stage"+ (new Integer(stage.substring(5,stage.length()))-1) +".jsp";
        }

        request.setAttribute("error", error);
        request.setAttribute("status", status);
        request.setAttribute("warn", warning);

        return new ModelAndView(viewPath, "bean", loadBean);

    }

    private void handleDataFileUpload(HttpRequestFacade req) throws Exception {

        // retrieve study parameters
        Study study = new Study();
        loadBean.setStudy(study);

        // store contents of data file
        DiskFileItemFactory factory = new DiskFileItemFactory();
        ServletFileUpload upload = new ServletFileUpload(factory);
        for( FileItem item: (List<FileItem>) upload.parseRequest(req.getRequest()) ) {
            // process form fields
            if( item.isFormField() ) {
                String paramName = item.getFieldName();
                String paramValue = item.getString();
                if( paramName.equals("study_url") )
                    study.setRefRgdId(Integer.parseInt(paramValue));
                else if( paramName.equals("study_name") )
                    study.setName(paramValue);
                else if( paramName.equals("study_source") )
                    study.setSource(paramValue);
                else if( paramName.equals("study_type") )
                    study.setType(paramValue);
            }
            else {
                // not a form field -- the file content
                String fileName = item.getName();
                if (fileName == null || fileName.trim().length()==0) {
                    error.add("File name can't be empty!");
                    return;
                }
                if (! ".csv".equalsIgnoreCase(fileName.substring(fileName.length()-4, fileName.length()))) {
                    error.add("Only .csv files are supported. Please convert your file into CSV format.");
                    return;
                }
                loadBean.setDataFileName(item.getName());
                String[] lines = item.getString().split("\n");
                List<String[]> data = new ArrayList<String[]>(lines.length);
                for( String line: lines ) {
                    data.add(line.split(","));
                }
                loadBean.setData(data);
            }
        }

        // just after the loading, cleanup any intermediate data left in the bean
        loadBean.setMapAtmCond(null);
        loadBean.setMapDietCond(null);
        loadBean.setMapGender(null);
        loadBean.setMapRatDiet(null);
        loadBean.setPhenotypes(null);
        loadBean.setExperiments(null);
        loadBean.setReport(null);
        loadBean.setExperimentRecords(null);

        parseRatStrains();
    }

    private void handleCustomMappings(HttpRequestFacade req, String nameGroup, String valueGroup, String mappingGroup) throws Exception {

        // there could be a list of multivalue variables
        List<String> names = req.getParameterValues(nameGroup);
        List<String> values = req.getParameterValues(valueGroup);

        // save the mappings to database
        PhenominerLoadMapping map = new PhenominerLoadMapping();
        map.setType(mappingGroup);
        for( int i=0; i<names.size(); i++ ) {
            map.setName(names.get(i));
            map.setValue(values.get(i));
            mappings.saveMapping(map);
        }
    }

    private void handleCustomStrainMappings(HttpRequestFacade req) throws Exception {

        // there could be a list of multivalue variables map_acc_id/map_term
        handleCustomMappings(req, "map_term", "map_acc_id", "strain");

        // now load the strain mappings
        parseRatStrains();
    }

    // lookup for header column having a particular name (or optional alternate name)
    // if found, return the column index
    // if not found return -1
    private int getHeaderColumn(String colName, String altColName) {

        // there must be at least a header line
        if( loadBean.getData()==null || loadBean.getData().isEmpty() )
            return -1;
        String[] cols = loadBean.getData().get(0);

        // look for column headers names
        for( int i=0; i<cols.length; i++ ) {
            String col = cols[i].trim();
            if( col.equalsIgnoreCase(colName) ) {
                return i;
            }
            if( altColName!=null && col.equalsIgnoreCase(altColName) ) {
                return i;
            }
        }
        return -1; // not found
    }

    // first search for exact term name in given ontology
    // then search for exact term synonym in given ontology
    // then search for custom mapping in given category
    private Term searchForTerm(String name, String ontId, String mappingCategory) throws Exception {

        // new strain -- look for ontology id
        Term term = dao.getTermByTermName(name, ontId);
        if( term==null ) {
            // no match by name -- try to match by synonym
            List<Term> terms = dao.getTermsBySynonym(ontId, name, "exact");
            if( !terms.isEmpty() ) {
                term = terms.get(0);
                term.setComment("term synonym");
            }
            else {
                // try strain mappings in the end
                PhenominerLoadMapping mapping = mappings.getMapping(mappingCategory, name);
                if( mapping!=null ) {
                    // we have a mapping - strain acc id -- try it
                    term = dao.getTermByAccId(mapping.getValue());
                    if( term!=null )
                        term.setComment("custom mapping");
                }
            }
        }
        else {
            term.setComment("term name");
        }
        return term;
    }

    // examine the file contents and extract all strains
    private void parseRatStrains() throws Exception {

        // note: we are storing in term comments the the match method
        loadBean.setMapStrains(null);

        // look for column headers named "STRAIN" or "RAT STRAIN"
        int strainCol = getHeaderColumn("STRAIN", "RAT Strain");
        if( strainCol < 0 ) {
            error.add("Strain column not found in the input data");
            return;
        }
        loadBean.setStrainCol(strainCol);

        Term emptyTerm = new Term();
        emptyTerm.setTerm("(unknown)");
        emptyTerm.setAccId("");
        emptyTerm.setComment("no match");
        loadBean.setUnmappedStrainCount(0);

        // build a map of all available strains
        for( String[] cols2: loadBean.getData() ) {
            Map<String,Term> mapStrains = loadBean.getMapStrains();
            if( mapStrains==null ) {
                // first header line -- create hashmap
                loadBean.setMapStrains(new TreeMap<String, Term>());
            }
            else {
                // try to match the strain name to rat strain ont acc id
                String strainName = cols2[strainCol].trim();

                if( !mapStrains.containsKey(strainName) ) {

                    Term term = searchForTerm(strainName, "RS", "strain");
                    if( term!=null )
                        mapStrains.put(strainName, term);
                    else {
                        mapStrains.put(strainName, emptyTerm);
                        loadBean.setUnmappedStrainCount(1+ loadBean.getUnmappedStrainCount());
                    }
                }
            }
        }
    }

    // examine the file contents and extract all atmosperic conditions
    private void handleAtmosphericConditions() throws Exception {

        // note: we are storing in cond comments the suffix appended to experiment name
        loadBean.setMapAtmCond(null);

        // look for column headers named "ATM"
        int atmCondCol = getHeaderColumn("ATM", "rat ATM Condition");
        if( atmCondCol < 0 ) {
            error.add("Atmospheric condition column not found in the input data");
            return;
        }
        loadBean.setAtmCol(atmCondCol);

        // build a map of all available atm conditions
        for( String[] cols2: loadBean.getData() ) {
            Map<String,Condition> mapAtmConds = loadBean.getMapAtmCond();
            if( mapAtmConds==null ) {
                // first header line -- create hashmap
                loadBean.setMapAtmCond(new TreeMap<String, Condition>());
            }
            else {
                // try to match the condition name
                String condName = cols2[atmCondCol].trim();

                if( !mapAtmConds.containsKey(condName) ) {

                    Condition cond = new Condition();

                    // new atmospheric condition -- try built-in names
                    if( condName.equalsIgnoreCase("21% O2") ) {

                        cond.setNotes(" under normatic conditions");
                        cond.setOntologyId("XCO:0000010");
                        cond.setUnits("%");
                        cond.setValue("21");
                    }
                    else
                    if( condName.equalsIgnoreCase("12% O2") ) {

                        cond.setNotes(" under hypoxic conditions");
                        cond.setOntologyId("XCO:0000010");
                        cond.setUnits("%");
                        cond.setValue("12");
                    }
                    else {
                        cond.setNotes(" ???");
                        cond.setOntologyId("XCO:0000000");
                        cond.setUnits("???");
                        cond.setValue("???");
                    }

                    mapAtmConds.put(condName, cond);
                }
            }
        }
    }

    // examine the file contents and extract all diet conditions
    private void handleDietConditions() throws Exception {

        // note: we are storing in cond comments the suffix appended to experiment name
        loadBean.setMapDietCond(null);

        // look for column headers named "DIET"
        int dietCondCol = getHeaderColumn("DIET", "rat Diet Condition");
        if( dietCondCol < 0 ) {
            error.add("Diet condition column not found in the input data");
            return;
        }
        loadBean.setDietCondCol(dietCondCol);

        // build a map of all available atm conditions
        for( String[] cols2: loadBean.getData() ) {
            Map<String,Condition> mapDietConds = loadBean.getMapDietCond();
            if( mapDietConds==null ) {
                // first header line -- create hashmap
                loadBean.setMapDietCond(new TreeMap<String, Condition>());
            }
            else {
                // try to match the condition name
                String condName = cols2[dietCondCol].trim();

                if( !mapDietConds.containsKey(condName) ) {

                    Condition cond = new Condition();

                    // new diet condition -- try built-in names
                    if( condName.endsWith("% Salt") ) {

                        cond.setNotes("controlled sodium content diet");
                        cond.setOntologyId("XCO:0000022");
                        cond.setUnits("%");
                        cond.setValue(condName.substring(0, condName.indexOf("% Salt")));
                    }
                    else if( condName.endsWith("% NaCl") ) {

                        cond.setNotes("controlled sodium content diet");
                        cond.setOntologyId("XCO:0000022");
                        cond.setUnits("%");
                        cond.setValue(condName.substring(0, condName.indexOf("% NaCl")));
                    }
                    else {
                        cond.setNotes("diet");
                        cond.setOntologyId("XCO:0000013");
                        cond.setUnits(null);
                        cond.setValue(null);
                    }

                    mapDietConds.put(condName, cond);
                }
            }
        }
    }

    // examine the file contents and extract all genders
    private void handleGenders() throws Exception {

        loadBean.setMapGender(null);

        // look for column headers named "GENDER"
        int genderCol = getHeaderColumn("GENDER", "Rat Gender");
        if( genderCol < 0 ) {
            error.add("Gender column not found in the input data");
            return;
        }
        loadBean.setGenderCol(genderCol);

        // build a map of all available genders
        for( String[] cols2: loadBean.getData() ) {
            Map<String,String> mapGenders = loadBean.getMapGender();
            if( mapGenders==null ) {
                // first header line -- create hashmap
                loadBean.setMapGender(new TreeMap<String, String>());
            }
            else {
                // try to match the gender
                String gender = cols2[genderCol].trim();

                if( !mapGenders.containsKey(gender) ) {

                    // try built-in names
                    if( gender.equalsIgnoreCase("M") ) {
                        mapGenders.put(gender, "male");
                    }
                    else if( gender.equalsIgnoreCase("F") ) {
                        mapGenders.put(gender, "female");
                    }
                    else {
                        mapGenders.put(gender, "???");
                    }
                }
            }
        }
    }

    // examine the file contents and extract all rat diet codes
    private void handleRatDiets() throws Exception {

        loadBean.setMapRatDiet(null);

        // look for column headers named "RAT_DIET_CODE"
        int selCol = getHeaderColumn("RAT_DIET_CODE", null);
        if( selCol < 0 ) {
            error.add("Rat diet column not found in the input data");
            return;
        }
        loadBean.setRatDietCol(selCol);

        // build a map of all available rat diet codes
        for( String[] cols2: loadBean.getData() ) {
            Map<String,String> map = loadBean.getMapRatDiet();
            if( map==null ) {
                // first header line -- create hashmap
                loadBean.setMapRatDiet(new TreeMap<String, String>());
            }
            else {
                // try to match the gender
                String ratDietCode = cols2[selCol].trim();

                if( !map.containsKey(ratDietCode) ) {

                    // try built-in names
                    if( ratDietCode.equalsIgnoreCase("Cc") ) {
                        map.put(ratDietCode, "Conversion period. Moms had mixed diet, Dyets and Teklad, for 3-4 weeks. Whatever Mom was fed, so were pups. Whatever pups were fed in the barrier, they continued with through the study. Possible maternal influence on pups estimated at 10 weeks");
                    }
                    else if( ratDietCode.equalsIgnoreCase("Dd") ) {
                        map.put(ratDietCode, "Moms and pups used in studies were fed Dyets");
                    }
                    else if( ratDietCode.equalsIgnoreCase("Td") ) {
                        map.put(ratDietCode, "Moms were fed Teklad, pups used in studies were fed Dyets");
                    }
                    else if( ratDietCode.equalsIgnoreCase("Tt") ) {
                        map.put(ratDietCode, "Moms and pups used in studies were fed Teklad");
                    }
                    else if( ratDietCode.equalsIgnoreCase("Vd") ) {
                        map.put(ratDietCode, "Moms were fed vendors standard diet, pups were fed Dyets upon arrival at MCW. For rats received from Harlan");
                    }
                    else if( ratDietCode.equalsIgnoreCase("Vt") ) {
                        map.put(ratDietCode, "Moms were fed vendors standard diet, pups were fed Teklad upon arrival at MCW. For rats received from CRL and Harlan");
                    }
                    else {
                        map.put(ratDietCode, "???");
                    }
                }
            }
        }
    }

    // examine the file header and extract all phenotypes
    private void handlePhenotypes(HttpRequestFacade req) throws Exception {

        // look for column header named "RAT_ID"; the following columns are 'phenotype' columns
        int selCol = getHeaderColumn("Study Date", null);
        if( selCol < 0 ) {
            selCol = getHeaderColumn("RAT_ID", null);
            loadBean.setRatIdCol(selCol);
        }
        if( selCol < 0 ) {
            error.add("RAT_ID column not found in the input data -- cannot parse phenotypes");
            return;
        }
        loadBean.setDataFirstCol(selCol+1);

        // there could be a list of multivalue variables col_name/ont_acc_id
        handleCustomMappings(req, "cmo_phenotype", "cmo_acc_id", "cmo_phenotype");
        handleCustomMappings(req, "mmo_phenotype", "mmo_acc_id", "mmo_phenotype");


        // create a new list of phenotypes
        List<Map<String,Object>> phenotypes = new ArrayList<Map<String, Object>>(30);
        loadBean.setPhenotypes(phenotypes);
        loadBean.setMappedPhenotypeCount(0);

        // build list of phenotypes
        String[] cols = loadBean.getData().get(0);
        for( int col=selCol+1; col<cols.length; col++ ) {

            Map<String,Object> map = new HashMap<String, Object>();
            phenotypes.add(map);

            String colName = cols[col];
            map.put("col_name", colName);

            map.put("col_index", col);

            // parse for phenotype and unit -- unit should be in the parentheses
            int posEnd = colName.lastIndexOf(')');
            int posStart = colName.lastIndexOf('(');
            String unit, phenotype;
            if( posStart>0 && posEnd>0 && posStart<posEnd ) {
                // there is a text in parentheses: parentheses content is unit, text before parentheses - phenotype
                unit = colName.substring(posStart+1, posEnd).trim();
                phenotype = colName.substring(0, posStart).trim();
            }
            else {
                // no text in parentheses: unit is empty, everything is phenotype
                unit = "";
                phenotype = colName.trim();
            }
            map.put("unit", unit);
            map.put("phenotype", phenotype);

            boolean hasCmoAccId = false;
            boolean hasMmoAccId = false;

            // CMO ont acc id mappings
            Term term = searchForTerm(phenotype, "CMO", "cmo_phenotype");
            if( term!=null ) {
                // we have a mapping - ont acc id -- validate it
                map.put("cmo_acc_id", term.getAccId());
                map.put("cmo_acc_status", term.getComment());
// Changed to use header in the file, not the ontology term
                map.put("cmo_term_name", phenotype);


                hasCmoAccId = true;
            }
            else {
                map.put("cmo_acc_id", "");
                map.put("cmo_acc_status", "");
                map.put("cmo_term_name", "");
            }

            // MMO ont acc id mappings
            term = searchForTerm(phenotype, "MMO", "mmo_phenotype");
            if( term!=null ) {
                // we have a mapping - ont acc id -- validate it
                map.put("mmo_acc_id", term.getAccId());
                map.put("mmo_acc_status", term.getComment());
                map.put("mmo_term_name", term.getTerm());

                hasMmoAccId = true;
            }
            else {
                map.put("mmo_acc_id", "");
                map.put("mmo_acc_status", "");
                map.put("mmo_term_name", "");
            }

            if( hasCmoAccId && hasMmoAccId ) {
                loadBean.setMappedPhenotypeCount(1+loadBean.getMappedPhenotypeCount());
            }
        }
    }

    // build experiment list
    private void handleExperiments() throws Exception {

        List<Map<String,Object>> phenotypes = loadBean.getPhenotypes();
        if( phenotypes==null ) {
            error.add("No phenotypes found -- cannot proceed.");
            return;
        }

        // list of atmospheric conditions
        List<String> atmConditions = new ArrayList<String>();
        if( loadBean.getMapAtmCond()==null ) {
            atmConditions.add("");
        }
        else {
            for(Condition cond: loadBean.getMapAtmCond().values() ) {
                if( cond.getValue().equals("21") )
                    atmConditions.add(" under normoxic conditions");
                else if( cond.getValue().equals("12") )
                    atmConditions.add(" under hypoxic conditions");
                else
                    atmConditions.add("");
            }
        }

        // list of diets
        List<String> ratDiets = new ArrayList<String>();
        if( loadBean.getMapRatDiet()==null ) {
            ratDiets.add("");
        }
        else {
            for(Map.Entry<String,String> ratDiet: loadBean.getMapRatDiet().entrySet() ) {
                ratDiets.add("Rat Diet "+ratDiet.getKey()+" - "+ratDiet.getValue());
            }
        }

        List<Experiment> experiments = new ArrayList<Experiment>();
        loadBean.setExperiments(experiments);
        Study study = loadBean.getStudy();

        for( Map<String,Object> map: phenotypes ) {

            // skip phenotypes with not assigned ont acc id
            String cmoTermName = (String) map.get("cmo_term_name");
            if( cmoTermName.isEmpty() )
                continue;
            String mmoTermName = (String) map.get("mmo_term_name");
            if( mmoTermName.isEmpty() )
                continue;

            // experiment name is composed of study name, phenotype and atmospheric conditions
            for( String atmCond: atmConditions ) {
            // Remove " under normoxic conditions"
                String cmoTermName_low = cmoTermName.toLowerCase();
                if (atmCond.equals(" under normoxic conditions") &&
                        (cmoTermName_low.contains("hypoxic") || cmoTermName_low.contains("hypoxia") ||
                        cmoTermName_low.contains("hypercapnic") || cmoTermName_low.contains("hypercapnia"))) {
                    atmCond = "";
                }

                for( String expNotes: ratDiets ) {
                    Experiment exp = new Experiment();
                    exp.setStudyId(study.getId());
                    exp.setName(study.getName()+" "+cmoTermName + atmCond);
                    if( !expNotes.isEmpty() )
                        exp.setNotes(expNotes);

                    experiments.add(exp);
                }
            }
        }
    }


    // build experiment record list
    private void handleExperimentRecords() throws Exception {

        List<Map<String,Object>> phenotypes = loadBean.getPhenotypes();
        if( phenotypes==null ) {
            error.add("No phenotypes found -- cannot proceed.");
            return;
        }

        int ratDobCol = -1;
        int studyDateCol = -1;

        Study study = loadBean.getStudy();

        List<Experiment> experiments = new LinkedList<Experiment>();
        loadBean.setExperiments(experiments);

        List<Record> records = new LinkedList<Record>();
        loadBean.setExperimentRecords(records);


        // handle every row of data grouping the values by PHENOTYPE + ATM +  DIET + RAT DIET - the experiments
        // then we create subgroups by STRAIN + GENDER - the experiment records
        // then we attach a list of measurement data for every subgroup consisting of animal AGE + measurement VALUE
        Map<String, Map<String, List<String>>> groups = null;

        String phenotype, atm, diet, ratDiet, strain, gender, age, value, groupHash, subgroupHash, rat_id;
        for( String[] row: loadBean.getData() ) {

            // skip header line
            if( groups==null ) {
                groups = new HashMap<String, Map<String, List<String>>>();
                continue;
            }

            // load data from columns
            rat_id = loadBean.getRatIdCol()>=0 ? row[loadBean.getRatIdCol()] : "";
            atm = loadBean.getAtmCol()>=0 ? row[loadBean.getAtmCol()] : "";
            diet = loadBean.getDietCondCol()>=0 ? row[loadBean.getDietCondCol()] : "";
            ratDiet = loadBean.getRatDietCol()>=0 ? row[loadBean.getRatDietCol()] : "";

            strain = loadBean.getStrainCol()>=0 ? row[loadBean.getStrainCol()] : "";
            gender = loadBean.getGenderCol()>=0 ? row[loadBean.getGenderCol()] : "";
            age = "";

            // if there is no mapping for strain, ignore this line
            if( loadBean.getMapStrains()!=null ) {
                Term term = loadBean.getMapStrains().get(strain);
                if( term==null || term.getAccId()==null || term.getAccId().isEmpty() ) {
                    continue;
                }
            }

            for( Map<String,Object> pmap: phenotypes ) {

                // skip phenotypes with not assigned ont acc id
                String cmoTermName = (String) pmap.get("cmo_term_name");
                if( cmoTermName.isEmpty() )
                    continue;
                String mmoTermName = (String) pmap.get("mmo_term_name");
                if( mmoTermName.isEmpty() )
                    continue;

                // phenotype value
                int valCol = (Integer) pmap.get("col_index");
                value = row[valCol];
                if( value.startsWith("NA") )
                    continue; // no value for this phenotype
                phenotype = (String) pmap.get("phenotype");

                // access group PHENOTYPE + ATM + DIET + RAT_DIET === EXPERIMENT
                groupHash = phenotype+'|'+atm+'|'+diet+'|'+ratDiet;

                Map<String, List<String>> group = groups.get(groupHash);
                if( group==null ) {
                    // no such group yet, create a new group
                    group = new HashMap<String, List<String>>();
                    groups.put(groupHash, group);
                }

                // access subgroup STRAIN + GENDER === EXPERIMENT_RECORD
                subgroupHash = strain+'|'+gender;

                List<String> subgroup = group.get(subgroupHash);
                if( subgroup==null ) {
                    // no such subgroup yet, create a new subgroup
                    subgroup = new ArrayList<String>();
                    group.put(subgroupHash, subgroup);
                }

                // append measurement data for the subgroup consisting of animal AGE + measurement VALUE
                subgroup.add(age+'|'+value+'|'+rat_id);
            }
        }


        // all data rows has been parsed and broken into experiments and experiment records
        // create the experiments and records now
        for( Map.Entry<String, Map<String, List<String>>> group: groups.entrySet() ) {
            String groupVals[] = group.getKey().split("\\|", -1);
            phenotype = groupVals[0];
            atm = groupVals[1];
            diet = groupVals[2];
            ratDiet = groupVals[3];

            String phenotypeWithCond = phenotype;
            String phenotype_low = phenotype.toLowerCase();

            // lookup for valid atmospheric condition
            Condition atmCond = null;
            if( loadBean.getMapAtmCond()!=null ) {
                atmCond = loadBean.getMapAtmCond().get(atm);
                if( atmCond.getValue().contains("21") &&
                        !(phenotype_low.contains("hypoxic") || phenotype_low.contains("hypoxia") ||
                        phenotype_low.contains("hypercapnic") || phenotype_low.contains("hypercapnia")) )
                    phenotypeWithCond += " under normoxic conditions";
                else if( atmCond.getValue().contains("12") )
                    phenotypeWithCond += " under hypoxic conditions";
            }

            // lookup for valid diet condition
            Condition dietCond = null;
            if( loadBean.getMapDietCond()!=null ) {
                dietCond = loadBean.getMapDietCond().get(diet);
            }

            // lookup for valid rat diet condition
            String ratDietInfo = null;
            if( loadBean.getMapRatDiet()!=null ) {
                ratDietInfo = loadBean.getMapRatDiet().get(ratDiet);
            }

            Experiment exp = new Experiment();
            exp.setStudyId(study.getId());
            exp.setName(study.getName()+" "+phenotypeWithCond);
            exp.setNotes(ratDietInfo);

            experiments.add(exp);
            exp.setId(-experiments.size()); // pseudo-ids -- needed to associate experiment records with experiments

            // access experiment records
            for( Map.Entry<String, List<String>> subgroup: group.getValue().entrySet() ) {
                String subgroupVals[] = subgroup.getKey().split("\\|", -1);
                strain = subgroupVals[0];
                gender = subgroupVals[1];
                List<String> measurements = subgroup.getValue();

                Record rec = new Record();
                rec.setExperimentId(exp.getId());
                rec.setStudyId(study.getId());

                // step 1: create experiment record sample
                Sample sample = new Sample();

                if( loadBean.getMapGender()!=null ) {
                    sample.setSex(loadBean.getMapGender().get(gender));
                }
                if( loadBean.getMapStrains()!=null ) {
                    Term term = loadBean.getMapStrains().get(strain);
                    if( term!=null ) {
                        sample.setStrainAccId(term.getAccId());
                    }
                }
                sample.setNumberOfAnimals(measurements.size());
                // cannot proceed if strain accession id is not known
                if( sample.getStrainAccId()==null )
                    continue;
                rec.setSample(sample);


                // step 2: create experiment record conditions
                List<Condition> conditions = new ArrayList<Condition>();
                if( atmCond!=null ) {
                    Condition cond = new Condition();
                    cond.setOntologyId(atmCond.getOntologyId());
                    cond.setUnits(atmCond.getUnits());
                    cond.setValue(atmCond.getValue());
                    conditions.add(cond);
                    cond.setOrdinality(conditions.size());
                }
                if( dietCond!=null ) {
                    Condition cond = new Condition();
                    cond.setOntologyId(dietCond.getOntologyId());
                    cond.setUnits(dietCond.getUnits());
                    cond.setValue(dietCond.getValue());
                    conditions.add(cond);
                    cond.setOrdinality(conditions.size());
                }
                rec.setConditions(conditions);

                // step 3: create clinical measurement
                rec.setClinicalMeasurement(createClinicalMeasurement(phenotype, phenotypes));

                // step 4: create measurement method
                rec.setMeasurementMethod(createMeasurementMethod(phenotype, phenotypes));

                // step 5: compute averaged values and errors; and the animal age range for sample
                computeMeasurements(rec, subgroup.getValue());
                rec.setMeasurementUnits(getUnitsForPhenotype(phenotype, phenotypes));

                // experiment record is complete
                records.add(rec);
            }
        }

        // generate report -- borrow the code from other controller
        PhenominerDAO dao = new PhenominerDAO();
        Report report = PhenominerRecordController.buildReport(records, dao, false);
        loadBean.setReport(report);
    }

    private ClinicalMeasurement createClinicalMeasurement(String phenotype, List<Map<String,Object>> phenotypes) throws Exception {
        // sequentially search for phenotype
        for( Map<String,Object> map: phenotypes ) {
            if( map.get("phenotype").equals(phenotype) ) {
                // phenotype located
                ClinicalMeasurement cm = new ClinicalMeasurement();
                cm.setAccId(map.get("cmo_acc_id").toString());
                return cm;
            }
        }
        throw new Exception("createClinicalMeasurement");
    }

    private MeasurementMethod createMeasurementMethod(String phenotype, List<Map<String,Object>> phenotypes) throws Exception {
        // sequentially search for phenotype
        for( Map<String,Object> map: phenotypes ) {
            if( map.get("phenotype").equals(phenotype) ) {
                // phenotype located
                MeasurementMethod mm = new MeasurementMethod();
                mm.setAccId(map.get("mmo_acc_id").toString());
                return mm;
            }
        }
        throw new Exception("createMeasurementMethod");
    }

    private String getUnitsForPhenotype(String phenotype, List<Map<String,Object>> phenotypes) throws Exception {
        // sequentially search for phenotype
        for( Map<String,Object> map: phenotypes ) {
            if( map.get("phenotype").equals(phenotype) ) {
                // phenotype located
                return map.get("unit").toString();
            }
        }
        throw new Exception("getUnitsForPhenotype");
    }

    private void computeMeasurements(Record rec, List<String> measurements) {

        int N = measurements.size(); // count of measurements
        int minAnimalAge = 0;
        int maxAnimalAge = 0;
        double sumOfValues = 0.0;
        double[] values = new double[N];

        int i = 0;
        String ratIdValues = "";
        for( String dataHash: measurements ) {
            String[] dataVals = dataHash.split("\\|", -1);
            String animalAgeStr = dataVals[0]; // could be empty
            ratIdValues += (dataVals[2] + "|" + dataVals[1] + "|");

            int animalAge = animalAgeStr.isEmpty() ? 0 : Integer.parseInt(animalAgeStr);
            if( animalAge>0 ) {
                if( animalAge < minAnimalAge )
                    minAnimalAge = animalAge; // new minimum animal age
                if( animalAge > maxAnimalAge )
                    maxAnimalAge = animalAge; // new maximum animal age
            }

            double measurementValue = Double.valueOf(dataVals[1]);
            sumOfValues += measurementValue;
            values[i++] = measurementValue;
        }

        double mean = sumOfValues / N;
        double SD; // sample standard deviation
        double SEM; // standard error of the mean == SD / sqrt(N)

        DecimalFormat formatter = new DecimalFormat("######.####");

        if( measurements.size()>1 ) {

            // compute difference between the value and the mean
            double ssum = 0.0;
            for( double d: values ) {
                ssum += (d-mean)*(d-mean);
            }
            SD = Math.sqrt(ssum/(N-1));
            SEM = SD / Math.sqrt(N);

            rec.setMeasurementValue(formatter.format(mean));
            rec.setMeasurementSD(formatter.format(SD));
            rec.setMeasurementSem(formatter.format(SEM));
        }
        else {
            // one measurement only
            rec.setMeasurementValue(formatter.format(mean));
            rec.setMeasurementSD(null); // cannot be computed
            rec.setMeasurementSem(null); // cannot be computed
        }

        rec.getSample().setAgeDaysFromLowBound(minAnimalAge);
        rec.getSample().setAgeDaysFromHighBound(maxAnimalAge);
        rec.setRatIdValues(ratIdValues);
    }

    private void persistExperimentsAndRecords() throws Exception {

        PhenominerDAO dao = new PhenominerDAO();

        // first create the study
        int studyId = dao.insertStudy(loadBean.getStudy());

        // assign study id to experiments to be created
        // and create every single experiment
        // -- keep track of old and new exp ids
        Map<Integer,Integer> expIds = new HashMap<Integer, Integer>();
        for( Experiment exp: loadBean.getExperiments() ) {
            exp.setStudyId(studyId);
            int oldExpId = exp.getId();
            int newExpId = dao.insertExperiment(exp);
            expIds.put(oldExpId, newExpId);
        }

        // now insert all experiment records
        for( Record rec: loadBean.getExperimentRecords() ) {
            // replace old experiment id with new experiment id
            rec.setExperimentId(expIds.get(rec.getExperimentId()));
            String[] ratIdValues = rec.getRatIdValues().split("\\|", -1);
            if (ratIdValues.length > 0)
                rec.setHasIndividualRecord(true);
            // insert the exp record into db
            int recId = dao.insertRecord(rec);

            rec.setId(recId);
            rec.setStudyId(studyId);
            // Insert individual record values
            if (rec.getHasIndividualRecord()) {
                IndividualRecord iRec = new IndividualRecord();
                for (int i = 0; i < ratIdValues.length - 1; i += 2) {
                    iRec.setRecordId(recId);
                    iRec.setAnimalId(ratIdValues[i]);
                    iRec.setMeasurementValue(ratIdValues[i + 1]);
                    dao.insertIndividualRecord(iRec);
                }
            }
        }
        // regenerate report -- borrow the code from other controller
        Report report = PhenominerRecordController.buildReport(loadBean.getExperimentRecords(), dao, false);
        loadBean.setReport(report);
   }
}