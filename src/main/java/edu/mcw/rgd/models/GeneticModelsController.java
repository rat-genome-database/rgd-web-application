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
import java.util.stream.Collectors;

/**
 * Controller for managing genetic models display and processing.
 * Created by jthota on 9/2/2016.
 */
public class GeneticModelsController implements Controller {

    private static final String ASPECT_STRAIN = "S";
    private static final String REFERENCE_TYPE_JOURNAL = "journal article";
    private static final String STATUS_EXTINCT = "extinct";
    private static final String PHENOMINER_URL_TEMPLATE = "http://rgd.mcw.edu/rgdweb/phenominer/ontChoices.html?terms=%s&sex=both";
    private static final String PHYSGEN_LINK = "<a href=\"http://pga.mcw.edu/\" target=\"_blank\">PhysGen</a>";

    private final AliasDAO aliasDAO = new AliasDAO();
    private final ModelProcesses process = new ModelProcesses();
    private final AnnotationDAO annotationDAO = new AnnotationDAO();
    private final OntologyXDAO ontologyXDAO = new OntologyXDAO();
    private final StrainDAO strainDAO = new StrainDAO();
    private final AssociationDAO associationDAO = new AssociationDAO();

    private List<Strain> rgdStrains;
    private Set<String> genes;

    @Override
    public ModelAndView handleRequest(HttpServletRequest request, HttpServletResponse response) throws Exception {
        ModelMap model = new ModelMap();

        GeneticModelsSingleton instance = GeneticModelsSingleton.getInstance();
        List<GeneticModel> strainsWithAliases = instance.getGerrcModels();

        Set<String> genes = strainsWithAliases.stream()
            .map(GeneticModel::getGeneSymbol)
            .collect(Collectors.toSet());
        this.setGenes(genes);

        Map<String, List<GeneticModel>> gsMap = this.getGeneStrainMap(strainsWithAliases);
        Map<ModelsHeaderRecord, List<GeneticModel>> hcMap = this.getHeaderRecords(strainsWithAliases);

        request.setAttribute("strains", strainsWithAliases);
        request.setAttribute("geneStrainMap", gsMap);
        request.setAttribute("headerChildMap", hcMap);

        model.put("strains", strainsWithAliases);
        model.put("geneStrainMap", gsMap);
        model.put("headerChildMap", hcMap);

        return new ModelAndView("/WEB-INF/jsp/models/gerrc.jsp", "model", model);
    }

    public Map<String, List<GeneticModel>> getGeneStrainMap(List<GeneticModel> strains) {
        return strains.stream()
            .collect(Collectors.groupingBy(GeneticModel::getGeneSymbol));
    }

    public Map<ModelsHeaderRecord, List<GeneticModel>> getHeaderRecords(List<GeneticModel> strains) throws Exception {
        Set<String> genes = this.getGenes();
        Map<ModelsHeaderRecord, List<GeneticModel>> gsMap = new HashMap<>();

        for (String g : genes) {
            List<GeneticModel> childRecords = strains.stream()
                .filter(s -> g.equals(s.getGeneSymbol()))
                .filter(s -> !isExtinct(s.getLastStatus()))
                .collect(Collectors.toList());

            if (!childRecords.isEmpty()) {
                GeneticModel oneChildRecord = childRecords.get(0);
                ModelsHeaderRecord hRecord = new ModelsHeaderRecord();
                hRecord.setGene(oneChildRecord.getGene());
                hRecord.setGeneSymbol(oneChildRecord.getGeneSymbol());
                hRecord.setCount(childRecords.size());
                gsMap.put(hRecord, childRecords);
            }
        }
        return gsMap;
    }

    private boolean isExtinct(String status) {
        return status != null && status.toLowerCase().contains(STATUS_EXTINCT);
    }

    private String sanitizeString(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("<i>", "")
                   .replace("<sup>", "")
                   .replace("</i>", "")
                   .replace("</sup>", "")
                   .replace("/", "")
                   .replace("(", "")
                   .replace(")", "")
                   .replace("-", "")
                   .replace(" ", "")
                   .replace(".", "")
                   .replace("+", "");
    }

    public List<GeneticModel> getStrainWithAliases(List<GeneticModel> strains) throws Exception {
        List<Integer> rgdIds = strains.stream()
            .map(GeneticModel::getStrainRgdId)
            .collect(Collectors.toList());

        List<Strain> rgdStrains = strainDAO.getStrains(rgdIds);
        this.setRgdStrains(rgdStrains);

        List<Alias> aliasList = aliasDAO.getAliases(rgdIds);
        List<Annotation> annotations = annotationDAO.getAnnotationsByRgdIdsListAndAspect(rgdIds, ASPECT_STRAIN);

        List<String> termAccList = annotations.stream()
            .map(Annotation::getTermAcc)
            .collect(Collectors.toList());

        List<TermDagEdge> childTermsList = ontologyXDAO.getAllChildEdges(termAccList);
        Map<String, Integer> expRecordCountMap = process.getExperimentRecordCounts(termAccList);

        List<GeneticModel> result = new ArrayList<>();
        for (GeneticModel strain : strains) {
            int rgdId = strain.getStrainRgdId();

            // Set references
            List<Reference> refs = associationDAO.getReferenceAssociations(rgdId);
            List<Reference> journalRefs = refs.stream()
                .filter(ref -> REFERENCE_TYPE_JOURNAL.equalsIgnoreCase(ref.getReferenceType()))
                .collect(Collectors.toList());
            strain.setReferences(journalRefs);

            // Set strain status
            String lastStatus = null;
            for (Strain s : rgdStrains) {
                if (s.getRgdId() == rgdId) {
                    lastStatus = s.getLastStatus();
                    break;
                }
            }

            if (isExtinct(lastStatus)) {
                continue;
            }

            strain.setLastStatus(lastStatus);
            strain.setAvailability(lastStatus);

            // Set strain source
            String source = strain.getSource();
            if (source != null) {
                StringTokenizer tokenizer = new StringTokenizer(source, ",");
                while (tokenizer.hasMoreTokens()) {
                    String src = tokenizer.nextToken();
                    if (src.contains("PhysGen") || src.contains("PGA")) {
                        strain.setSource(PHYSGEN_LINK);
                        break;
                    }
                }
            }

            // Set strain aliases
            String strainSymbol = strain.getStrainSymbol();
            String sanitizedSymbol = sanitizeString(strainSymbol);

            List<String> aliases = aliasList.stream()
                .filter(a -> a.getRgdId() == rgdId)
                .map(Alias::getValue)
                .filter(alias -> !sanitizedSymbol.equalsIgnoreCase(sanitizeString(alias)))
                .collect(Collectors.toList());
            strain.setAliases(aliases);

            // Set Phenominer URL
            StringJoiner childTermsJoiner = new StringJoiner(",");
            int experimentRecordCount = 0;

            for (Annotation annotation : annotations) {
                if (annotation.getAnnotatedObjectRgdId() == rgdId) {
                    String parentTermAcc = annotation.getTermAcc();
                    strain.setParentTermAcc(parentTermAcc);

                    List<String> childTermAccs = new ArrayList<>();
                    if (childTermsList != null && !childTermsList.isEmpty()) {
                        for (TermDagEdge childTerm : childTermsList) {
                            if (childTerm != null && parentTermAcc.equals(childTerm.getParentTermAcc())) {
                                childTermAccs.add(childTerm.getChildTermAcc());
                            }
                        }
                    }

                    if (childTermAccs.isEmpty()) {
                        childTermsJoiner.add(parentTermAcc);
                    } else {
                        childTermAccs.forEach(childTermsJoiner::add);
                    }

                    experimentRecordCount = expRecordCountMap.getOrDefault(parentTermAcc, 0);
                }
            }

            String phenominerUrl = String.format(PHENOMINER_URL_TEMPLATE, childTermsJoiner.toString());
            strain.setPhenominerUrl(phenominerUrl);
            strain.setExperimentRecordCount(experimentRecordCount);
            result.add(strain);
        }

        return result;
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
