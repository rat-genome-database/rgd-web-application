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
import java.util.stream.Collectors;

/**
 * Singleton class for managing genetic models and related data.
 * Created by jthota on 9/28/2017.
 */
public class GeneticModelsSingleton {
    private static final int CHUNK_SIZE = 1000;
    private static final String ASPECT_STRAIN = "S";
    private static final String REFERENCE_TYPE_JOURNAL = "journal article";
    private static final String STATUS_EXTINCT = "extinct";
    private static final String PHENOMINER_URL_TEMPLATE = "http://rgd.mcw.edu/rgdweb/phenominer/ontChoices.html?terms=%s&sex=both";

    private static final Set<String> GERRC_SOURCES = new HashSet<>(Arrays.asList(
        "PhysGen", "PGA", "PhysGen Knockouts", "MCW Gene Editing Rat Resource Center"
    ));

    private static volatile GeneticModelsSingleton instance;

    private List<GeneticModel> allModels = new ArrayList<>();
    private List<GeneticModel> gerrcModels = new ArrayList<>();
    private List<Strain> rgdStrains;

    private final AssociationDAO associationDAO = new AssociationDAO();
    private final GeneticModelsDAO modelDao = new GeneticModelsDAO();
    private final AliasDAO aliasDAO = new AliasDAO();
    private final ModelProcesses process = new ModelProcesses();
    private final AnnotationDAO annotationDAO = new AnnotationDAO();
    private final OntologyXDAO ontologyXDAO = new OntologyXDAO();
    private final StrainDAO strainDAO = new StrainDAO();

    private GeneticModelsSingleton() {}

    private void init() {
        try {
            List<GeneticModel> strains = modelDao.getAllModels();
            List<GeneticModel> strainsWithAliases = this.getStrainWithAliases(strains);
            this.setAllModels(strainsWithAliases);

            List<GeneticModel> filteredGerrcModels = strainsWithAliases.stream()
                .filter(this::isGerrcModel)
                .collect(Collectors.toList());
            this.setGerrcModels(filteredGerrcModels);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static GeneticModelsSingleton getInstance() {
        if (instance == null) {
            synchronized (GeneticModelsSingleton.class) {
                if (instance == null) {
                    instance = new GeneticModelsSingleton();
                    instance.init();
                }
            }
        }
        return instance;
    }

    public static void main(String[] args) {
        GeneticModelsSingleton instance = getInstance();
        System.out.println("All Models Size: " + instance.getAllModels().size() + "\nDONE");
    }

    private boolean isGerrcModel(GeneticModel model) {
        return containsAnyGerrcSource(model.getSource()) || containsAnyGerrcSource(model.getOrigination());
    }

    private boolean containsAnyGerrcSource(String text) {
        if (text == null) {
            return false;
        }
        return GERRC_SOURCES.stream().anyMatch(text::contains);
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

    private String extractPhysGenSource(String sourceOrOrigination) {
        if (sourceOrOrigination == null) {
            return null;
        }
        StringTokenizer tokenizer = new StringTokenizer(sourceOrOrigination, ",");
        while (tokenizer.hasMoreTokens()) {
            String token = tokenizer.nextToken();
            if (token.contains("PhysGen")) {
                return token;
            }
        }
        return null;
    }

    public List<GeneticModel> getStrainWithAliases(List<GeneticModel> strains) throws Exception {
        List<Integer> rgdIds = strains.stream()
            .map(GeneticModel::getStrainRgdId)
            .collect(Collectors.toList());

        List<Strain> rgdStrains = getStrainsWithLimit(rgdIds);
        this.setRgdStrains(rgdStrains);

        List<Alias> aliasList = getAliases(rgdIds);
        List<Annotation> annotations = getAnnotationsByRgdIdsListAndAspect(rgdIds, ASPECT_STRAIN);

        List<String> termAccList = annotations.stream()
            .map(Annotation::getTermAcc)
            .collect(Collectors.toList());

        List<TermDagEdge> childTermsList = new ArrayList<>();
        Map<String, Integer> expRecordCountMap = new HashMap<>();
        Collection[] collections = this.split(termAccList, CHUNK_SIZE);
        for (Collection collection : collections) {
            List<String> termsSubList = (List<String>) collection;
            childTermsList.addAll(ontologyXDAO.getAllChildEdges(termsSubList));
            expRecordCountMap.putAll(process.getExperimentRecordCounts(termsSubList));
        }

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

            if (lastStatus != null && lastStatus.toLowerCase().contains(STATUS_EXTINCT)) {
                continue;
            }

            strain.setLastStatus(lastStatus);
            strain.setAvailability(lastStatus);

            // Set strain source and origination
            String physGenSource = extractPhysGenSource(strain.getSource());
            if (physGenSource != null) {
                strain.setSource(physGenSource);
            }

            String physGenOrigination = extractPhysGenSource(strain.getOrigination());
            if (physGenOrigination != null) {
                strain.setOrigination(physGenOrigination);
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

                    List<String> childTermAccs = childTermsList.stream()
                        .filter(edge -> parentTermAcc.equals(edge.getParentTermAcc()))
                        .map(TermDagEdge::getChildTermAcc)
                        .collect(Collectors.toList());

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

    public List<Strain> getStrainsWithLimit(List<Integer> rgdIds) throws Exception {
        List<Strain> result = new ArrayList<>();
        for (int i = 0; i < rgdIds.size(); i += CHUNK_SIZE) {
            List<Integer> subList = rgdIds.subList(i, Math.min(i + CHUNK_SIZE, rgdIds.size()));
            result.addAll(strainDAO.getStrains(subList));
        }
        return result;
    }

    public List<Alias> getAliases(List<Integer> rgdIds) throws Exception {
        List<Alias> result = new ArrayList<>();
        for (int i = 0; i < rgdIds.size(); i += CHUNK_SIZE) {
            List<Integer> subList = rgdIds.subList(i, Math.min(i + CHUNK_SIZE, rgdIds.size()));
            result.addAll(aliasDAO.getAliases(subList));
        }
        return result;
    }

    public Collection[] split(List<String> objects, int size) throws Exception {
        int numOfBatches = (objects.size() / size) + 1;
        Collection[] batches = new Collection[numOfBatches];
        for (int index = 0; index < numOfBatches; index++) {
            int count = index + 1;
            int fromIndex = Math.max(((count - 1) * size), 0);
            int toIndex = Math.min((count * size), objects.size());
            batches[index] = objects.subList(fromIndex, toIndex);
        }
        return batches;
    }

    public List<Annotation> getAnnotationsByRgdIdsListAndAspect(List<Integer> rgdIds, String aspect) throws Exception {
        List<Annotation> result = new ArrayList<>();
        for (int i = 0; i < rgdIds.size(); i += CHUNK_SIZE) {
            List<Integer> subList = rgdIds.subList(i, Math.min(i + CHUNK_SIZE, rgdIds.size()));
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
