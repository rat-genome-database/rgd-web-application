package edu.mcw.rgd.entityTagger.service;

import edu.mcw.rgd.entityTagger.util.CurationLogger;
import java.io.*;
import java.net.URL;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Pattern;

/**
 * Service for loading and managing rat strain ontology from RGD
 */
public class RatStrainOntologyService {
    
    private static final String RAT_STRAIN_ONTOLOGY_URL = "https://download.rgd.mcw.edu/ontology/rat_strain/rat_strain.obo";
    private static final Map<String, RatStrain> strainMap = new ConcurrentHashMap<>();
    private static final Map<String, String> synonymMap = new ConcurrentHashMap<>();
    private static volatile boolean loaded = false;
    private static final Object loadLock = new Object();
    
    /**
     * Rat strain data structure
     */
    public static class RatStrain {
        private String id;
        private String name;
        private List<String> synonyms;
        private String definition;
        private String strainType;
        
        public RatStrain(String id, String name) {
            this.id = id;
            this.name = name;
            this.synonyms = new ArrayList<>();
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
        
        public String getStrainType() { return strainType; }
        public void setStrainType(String strainType) { this.strainType = strainType; }
        
        public void addSynonym(String synonym) {
            if (synonym != null && !synonym.trim().isEmpty()) {
                this.synonyms.add(synonym.trim());
            }
        }
    }
    
    /**
     * Load rat strain ontology from RGD
     */
    public static void loadOntology() {
        if (loaded) return;
        
        synchronized (loadLock) {
            if (loaded) return;
            
            CurationLogger.info("Loading rat strain ontology from RGD...");
            
            try {
                URL url = new URL(RAT_STRAIN_ONTOLOGY_URL);
                try (BufferedReader reader = new BufferedReader(
                    new InputStreamReader(url.openStream(), "UTF-8"))) {
                    
                    parseOboFile(reader);
                    buildSynonymMap();
                    loaded = true;
                    
                    CurationLogger.info("Successfully loaded {} rat strains with {} synonyms", 
                        strainMap.size(), synonymMap.size());
                    
                } catch (IOException e) {
                    CurationLogger.error("Failed to load rat strain ontology from URL", e);
                    // Try to load from local fallback if available
                    loadFallbackData();
                }
                
            } catch (Exception e) {
                CurationLogger.error("Error loading rat strain ontology", e);
                loadFallbackData();
            }
        }
    }
    
    /**
     * Parse OBO format file
     */
    private static void parseOboFile(BufferedReader reader) throws IOException {
        String line;
        RatStrain currentStrain = null;
        boolean inTermSection = false;
        
        while ((line = reader.readLine()) != null) {
            line = line.trim();
            
            if (line.equals("[Term]")) {
                inTermSection = true;
                currentStrain = null;
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
                if (id.startsWith("RS:")) {
                    currentStrain = new RatStrain(id, "");
                }
            } else if (currentStrain != null && line.startsWith("name: ")) {
                String name = line.substring(6).trim();
                currentStrain.setName(name);
                strainMap.put(currentStrain.getId(), currentStrain);
            } else if (currentStrain != null && line.startsWith("synonym: ")) {
                String synonymLine = line.substring(9).trim();
                // Parse synonym line: "synonym: "SYNONYM_NAME" EXACT []"
                if (synonymLine.startsWith("\"")) {
                    int endQuote = synonymLine.indexOf("\"", 1);
                    if (endQuote > 1) {
                        String synonym = synonymLine.substring(1, endQuote);
                        currentStrain.addSynonym(synonym);
                    }
                }
            } else if (currentStrain != null && line.startsWith("def: ")) {
                String definition = line.substring(5).trim();
                if (definition.startsWith("\"")) {
                    int endQuote = definition.indexOf("\"", 1);
                    if (endQuote > 1) {
                        currentStrain.setDefinition(definition.substring(1, endQuote));
                    }
                }
            }
        }
    }
    
    /**
     * Build synonym to strain ID mapping for fast lookup
     */
    private static void buildSynonymMap() {
        for (RatStrain strain : strainMap.values()) {
            // Add main name
            if (strain.getName() != null) {
                synonymMap.put(strain.getName().toLowerCase(), strain.getId());
            }
            
            // Add all synonyms
            for (String synonym : strain.getSynonyms()) {
                synonymMap.put(synonym.toLowerCase(), strain.getId());
            }
        }
    }
    
    /**
     * Load fallback rat strain data for common strains
     */
    private static void loadFallbackData() {
        CurationLogger.info("Loading fallback rat strain data...");
        
        // Add common rat strains manually
        String[][] commonStrains = {
            {"RS:0000012", "ACI", "ACI/N, ACI/SegHsd"},
            {"RS:0000013", "BBDP", "BBDP/Wor"},
            {"RS:0000014", "BN", "BN/SsNHsd"},
            {"RS:0000015", "SHR", "SHR/N, SHR/NCrl, Spontaneously Hypertensive Rat"},
            {"RS:0000016", "WKY", "WKY/N, WKY/NCrl, Wistar Kyoto"},
            {"RS:0000215", "F344", "F344/N, Fischer 344, Fischer"},
            {"RS:0000287", "LEW", "LEW/N, Lewis"},
            {"RS:0000352", "SD", "SD/N, Sprague Dawley, Sprague-Dawley"},
            {"RS:0000758", "Wistar", "Wistar/N"},
            {"RS:0001191", "DA", "DA/OlaHsd, Dark Agouti"},
            {"RS:0000681", "GH", "GH/OmrMcwi, Genetically Hypertensive"},
            {"RS:0000733", "Zucker", "Zucker fa/fa, Zucker fatty"}
        };
        
        for (String[] strainData : commonStrains) {
            RatStrain strain = new RatStrain(strainData[0], strainData[1]);
            if (strainData.length > 2) {
                String[] synonyms = strainData[2].split(",\\s*");
                for (String synonym : synonyms) {
                    strain.addSynonym(synonym);
                }
            }
            strainMap.put(strain.getId(), strain);
        }
        
        buildSynonymMap();
        loaded = true;
        
        CurationLogger.info("Loaded {} fallback rat strains", strainMap.size());
    }
    
    /**
     * Find rat strains in text
     */
    public static List<BiologicalEntity> findRatStrains(String text) {
        loadOntology();
        
        List<BiologicalEntity> foundStrains = new ArrayList<>();
        Set<String> foundIds = new HashSet<>();
        
        // Create patterns for rat strain detection
        List<String> candidates = findStrainCandidates(text);
        
        for (String candidate : candidates) {
            String strainId = synonymMap.get(candidate.toLowerCase());
            if (strainId != null && !foundIds.contains(strainId)) {
                RatStrain strain = strainMap.get(strainId);
                if (strain != null) {
                    BiologicalEntity entity = new BiologicalEntity();
                    entity.setName(strain.getName());
                    entity.setType("rat-strain");
                    entity.setDescription("Rat strain " + strain.getId() + (strain.getDefinition() != null ? ": " + strain.getDefinition() : ""));
                    entity.setConfidence(calculateConfidence(candidate, strain));
                    foundStrains.add(entity);
                    foundIds.add(strainId);
                }
            }
        }
        
        return foundStrains;
    }
    
    /**
     * Find potential rat strain mentions in text
     */
    private static List<String> findStrainCandidates(String text) {
        List<String> candidates = new ArrayList<>();
        
        // Common patterns for rat strain names
        Pattern[] patterns = {
            Pattern.compile("\\b([A-Z]{2,5})\\b"),  // 2-5 uppercase letters (SHR, WKY, etc.)
            Pattern.compile("\\b([A-Z][0-9]{2,3})\\b"),  // Letter + numbers (F344, etc.)
            Pattern.compile("\\b(Sprague[\\s-]?Dawley)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\b(Wistar\\s+Kyoto)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\b(Fischer\\s+344)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\b(Spontaneously\\s+Hypertensive\\s+Rat)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\b(Dark\\s+Agouti)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\b(Zucker\\s+fatty?)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\b([A-Z]{2,5}/[A-Z\\d]+)\\b")  // Strain/substrain notation
        };
        
        for (Pattern pattern : patterns) {
            java.util.regex.Matcher matcher = pattern.matcher(text);
            while (matcher.find()) {
                String candidate = matcher.group(1);
                if (candidate != null && candidate.length() > 1) {
                    candidates.add(candidate.trim());
                }
            }
        }
        
        return candidates;
    }
    
    /**
     * Calculate confidence score for strain match
     */
    private static double calculateConfidence(String candidate, RatStrain strain) {
        // Exact name match
        if (candidate.equalsIgnoreCase(strain.getName())) {
            return 0.95;
        }
        
        // Synonym match
        for (String synonym : strain.getSynonyms()) {
            if (candidate.equalsIgnoreCase(synonym)) {
                return 0.90;
            }
        }
        
        // Partial match
        String lowerCandidate = candidate.toLowerCase();
        String lowerName = strain.getName().toLowerCase();
        
        if (lowerName.contains(lowerCandidate) || lowerCandidate.contains(lowerName)) {
            return 0.80;
        }
        
        return 0.75;
    }
    
    /**
     * Get strain by ID
     */
    public static RatStrain getStrainById(String id) {
        loadOntology();
        return strainMap.get(id);
    }
    
    /**
     * Get all loaded strains
     */
    public static Collection<RatStrain> getAllStrains() {
        loadOntology();
        return strainMap.values();
    }
}