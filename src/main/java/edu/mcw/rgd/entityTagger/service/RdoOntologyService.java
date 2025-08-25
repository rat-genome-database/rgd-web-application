package edu.mcw.rgd.entityTagger.service;

import edu.mcw.rgd.entityTagger.util.CurationLogger;
import java.io.*;
import java.net.URL;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Pattern;

/**
 * Service for loading and managing RGD Disease Ontology (RDO) from RGD
 */
public class RdoOntologyService {
    
    private static final String RDO_ONTOLOGY_URL = "https://download.rgd.mcw.edu/ontology/disease/RDO.obo";
    private static final Map<String, DiseaseEntity> diseaseMap = new ConcurrentHashMap<>();
    private static final Map<String, String> synonymMap = new ConcurrentHashMap<>();
    private static volatile boolean loaded = false;
    private static final Object loadLock = new Object();
    
    /**
     * Disease entity data structure
     */
    public static class DiseaseEntity {
        private String id;
        private String name;
        private List<String> synonyms;
        private String definition;
        private String namespace;
        private List<String> dbXrefs;
        
        public DiseaseEntity(String id, String name) {
            this.id = id;
            this.name = name;
            this.synonyms = new ArrayList<>();
            this.dbXrefs = new ArrayList<>();
        }
        
        // Getters and setters
        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        
        public List<String> getSynonyms() { return synonyms; }
        public void setSynonyms(List<String> synonyms) { this.synonyms = synonyms; }
        
        public String getDefinition() { return definition; }
        public void setDefinition(String definition) { this.definition = definition; }
        
        public String getNamespace() { return namespace; }
        public void setNamespace(String namespace) { this.namespace = namespace; }
        
        public List<String> getDbXrefs() { return dbXrefs; }
        public void setDbXrefs(List<String> dbXrefs) { this.dbXrefs = dbXrefs; }
        
        public void addSynonym(String synonym) {
            if (synonym != null && !synonym.trim().isEmpty()) {
                this.synonyms.add(synonym.trim());
            }
        }
        
        public void addDbXref(String dbXref) {
            if (dbXref != null && !dbXref.trim().isEmpty()) {
                this.dbXrefs.add(dbXref.trim());
            }
        }
    }
    
    /**
     * Load RDO ontology from RGD
     */
    public static void loadOntology() {
        if (loaded) return;
        
        synchronized (loadLock) {
            if (loaded) return;
            
            CurationLogger.info("Loading RGD Disease Ontology from RGD...");
            
            try {
                URL url = new URL(RDO_ONTOLOGY_URL);
                try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(url.openStream(), "UTF-8"))) {
                    
                    parseOboFile(reader);
                    buildSynonymMap();
                    loaded = true;
                    
                    CurationLogger.info("Successfully loaded {} diseases with {} synonyms", 
                        diseaseMap.size(), synonymMap.size());
                    
                } catch (IOException e) {
                    CurationLogger.error("Failed to load RDO ontology from URL", e);
                    // Try to load from local fallback if available
                    loadFallbackData();
                }
                
            } catch (Exception e) {
                CurationLogger.error("Error loading RDO ontology", e);
                loadFallbackData();
            }
        }
    }
    
    /**
     * Parse OBO format file
     */
    private static void parseOboFile(BufferedReader reader) throws IOException {
        String line;
        DiseaseEntity currentDisease = null;
        boolean inTermSection = false;
        
        while ((line = reader.readLine()) != null) {
            line = line.trim();
            
            if (line.equals("[Term]")) {
                inTermSection = true;
                currentDisease = null;
                continue;
            }
            
            if (line.startsWith("[") && !line.equals("[Term]")) {
                inTermSection = false;
                continue;
            }
            
            if (!inTermSection || line.isEmpty()) {
                continue;
            }
            
            if (line.startsWith("id: ")) {
                String id = line.substring(4).trim();
                if (id.startsWith("DOID:") || id.startsWith("RDO:")) {
                    currentDisease = new DiseaseEntity(id, "");
                }
            } else if (currentDisease != null && line.startsWith("name: ")) {
                String name = line.substring(6).trim();
                currentDisease.setName(name);
                diseaseMap.put(currentDisease.getId(), currentDisease);
            } else if (currentDisease != null && line.startsWith("synonym: ")) {
                String synonymLine = line.substring(9).trim();
                // Parse synonym line: "synonym: \"SYNONYM_NAME\" EXACT []"
                if (synonymLine.startsWith("\"")) {
                    int endQuote = synonymLine.indexOf("\"", 1);
                    if (endQuote > 1) {
                        String synonym = synonymLine.substring(1, endQuote);
                        currentDisease.addSynonym(synonym);
                    }
                }
            } else if (currentDisease != null && line.startsWith("def: ")) {
                String definition = line.substring(5).trim();
                if (definition.startsWith("\"")) {
                    int endQuote = definition.indexOf("\"", 1);
                    if (endQuote > 1) {
                        currentDisease.setDefinition(definition.substring(1, endQuote));
                    }
                }
            } else if (currentDisease != null && line.startsWith("namespace: ")) {
                String namespace = line.substring(11).trim();
                currentDisease.setNamespace(namespace);
            } else if (currentDisease != null && line.startsWith("xref: ")) {
                String xref = line.substring(6).trim();
                currentDisease.addDbXref(xref);
            }
        }
    }
    
    /**
     * Build synonym to disease ID mapping for fast lookup
     */
    private static void buildSynonymMap() {
        for (DiseaseEntity disease : diseaseMap.values()) {
            // Add main name
            if (disease.getName() != null) {
                synonymMap.put(disease.getName().toLowerCase(), disease.getId());
            }
            
            // Add all synonyms
            for (String synonym : disease.getSynonyms()) {
                synonymMap.put(synonym.toLowerCase(), disease.getId());
            }
        }
    }
    
    /**
     * Load fallback disease data for common diseases
     */
    private static void loadFallbackData() {
        CurationLogger.info("Loading fallback disease data...");
        
        // Add common diseases manually
        String[][] commonDiseases = {
            {"DOID:162", "cancer", "malignant tumor, malignant neoplasm, carcinoma"},
            {"DOID:14566", "disease", "disorder, condition, pathology"},
            {"DOID:9970", "obesity", "overweight, adiposity"},
            {"DOID:1287", "cardiovascular disease", "heart disease, cardiac disease"},
            {"DOID:2531", "hematologic cancer", "blood cancer, hematological malignancy"},
            {"DOID:10763", "hypertension", "high blood pressure, arterial hypertension"},
            {"DOID:9351", "diabetes mellitus", "diabetes, DM"},
            {"DOID:1612", "breast cancer", "breast carcinoma, mammary cancer"},
            {"DOID:1324", "lung cancer", "pulmonary cancer, lung carcinoma"},
            {"DOID:219", "colon cancer", "colorectal cancer, colon carcinoma"},
            {"DOID:2394", "ovarian cancer", "ovarian carcinoma"},
            {"DOID:10283", "prostate cancer", "prostate carcinoma"},
            {"DOID:4159", "skin cancer", "cutaneous cancer"},
            {"DOID:1909", "melanoma", "malignant melanoma"},
            {"DOID:263", "kidney cancer", "renal cancer, renal carcinoma"},
            {"DOID:3571", "liver cancer", "hepatic cancer, hepatocellular carcinoma"},
            {"DOID:850", "lung disease", "pulmonary disease, respiratory disease"},
            {"DOID:114", "heart disease", "cardiac disease, coronary disease"},
            {"DOID:417", "nephritis", "kidney inflammation, glomerulonephritis"},
            {"DOID:3312", "bipolar disorder", "manic depression, bipolar affective disorder"}
        };
        
        for (String[] diseaseData : commonDiseases) {
            DiseaseEntity disease = new DiseaseEntity(diseaseData[0], diseaseData[1]);
            if (diseaseData.length > 2) {
                String[] synonyms = diseaseData[2].split(",\\s*");
                for (String synonym : synonyms) {
                    disease.addSynonym(synonym);
                }
            }
            diseaseMap.put(disease.getId(), disease);
        }
        
        buildSynonymMap();
        loaded = true;
        
        CurationLogger.info("Loaded {} fallback diseases", diseaseMap.size());
    }
    
    /**
     * Find diseases in text
     */
    public static List<BiologicalEntity> findDiseases(String text) {
        loadOntology();
        
        List<BiologicalEntity> foundDiseases = new ArrayList<>();
        Set<String> foundIds = new HashSet<>();
        
        // Create patterns for disease detection
        List<String> candidates = findDiseaseCandidates(text);
        
        for (String candidate : candidates) {
            String diseaseId = synonymMap.get(candidate.toLowerCase());
            if (diseaseId != null && !foundIds.contains(diseaseId)) {
                DiseaseEntity disease = diseaseMap.get(diseaseId);
                if (disease != null) {
                    BiologicalEntity entity = new BiologicalEntity();
                    entity.setName(disease.getName());
                    entity.setType("disease");
                    entity.setDescription("Disease " + disease.getId() + (disease.getDefinition() != null ? ": " + disease.getDefinition() : ""));
                    entity.setConfidence(calculateConfidence(candidate, disease));
                    foundDiseases.add(entity);
                    foundIds.add(diseaseId);
                }
            }
        }
        
        return foundDiseases;
    }
    
    /**
     * Find potential disease mentions in text
     */
    private static List<String> findDiseaseCandidates(String text) {
        List<String> candidates = new ArrayList<>();
        
        // Common patterns for disease names
        Pattern[] patterns = {
            // Disease suffix patterns
            Pattern.compile("\\b(\\w+(?:itis|osis|emia|uria|pathy|trophy|plasia|genic|oma|carcinoma|sarcoma))\\b", Pattern.CASE_INSENSITIVE),
            // Cancer patterns
            Pattern.compile("\\b(\\w+\\s+(?:cancer|carcinoma|tumor|neoplasm|malignancy))\\b", Pattern.CASE_INSENSITIVE),
            // Disease patterns
            Pattern.compile("\\b(\\w+\\s+(?:disease|disorder|syndrome|condition))\\b", Pattern.CASE_INSENSITIVE),
            // Specific disease patterns
            Pattern.compile("\\b(diabetes|hypertension|obesity|asthma|arthritis)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\b(depression|anxiety|bipolar|schizophrenia)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\b(alzheimer|parkinson|huntington)\\b", Pattern.CASE_INSENSITIVE),
            // Cardiovascular patterns
            Pattern.compile("\\b(myocardial\\s+infarction|heart\\s+attack|stroke|atherosclerosis)\\b", Pattern.CASE_INSENSITIVE),
            // Inflammatory patterns
            Pattern.compile("\\b(inflammatory\\s+\\w+|chronic\\s+\\w+)\\b", Pattern.CASE_INSENSITIVE)
        };
        
        for (Pattern pattern : patterns) {
            java.util.regex.Matcher matcher = pattern.matcher(text);
            while (matcher.find()) {
                String candidate = matcher.group(1);
                if (candidate != null && candidate.length() > 2) {
                    candidates.add(candidate.trim());
                }
            }
        }
        
        return candidates;
    }
    
    /**
     * Calculate confidence score for disease match
     */
    private static double calculateConfidence(String candidate, DiseaseEntity disease) {
        // Exact name match
        if (candidate.equalsIgnoreCase(disease.getName())) {
            return 0.95;
        }
        
        // Synonym match
        for (String synonym : disease.getSynonyms()) {
            if (candidate.equalsIgnoreCase(synonym)) {
                return 0.90;
            }
        }
        
        // Partial match
        String lowerCandidate = candidate.toLowerCase();
        String lowerName = disease.getName().toLowerCase();
        
        if (lowerName.contains(lowerCandidate) || lowerCandidate.contains(lowerName)) {
            return 0.80;
        }
        
        return 0.75;
    }
    
    /**
     * Get disease by ID
     */
    public static DiseaseEntity getDiseaseById(String id) {
        loadOntology();
        return diseaseMap.get(id);
    }
    
    /**
     * Get all loaded diseases
     */
    public static Collection<DiseaseEntity> getAllDiseases() {
        loadOntology();
        return diseaseMap.values();
    }
}