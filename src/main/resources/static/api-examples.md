# RGD Curation Tool API - Usage Examples

This document provides comprehensive examples for using the RGD Curation Tool API for biological entity recognition and ontology matching.

## Base URL

```
Production: https://rgd.mcw.edu/curation/api/curation/entity-recognition
Development: http://localhost:8080/api/curation/entity-recognition
```

## Authentication

Currently, the API uses IP-based access control. Contact the RGD team for access.

## Quick Start

### 1. Basic Entity Recognition

Recognize biological entities in a simple text:

```bash
curl -X POST "${BASE_URL}/recognize" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "The patient was diagnosed with diabetes mellitus and prescribed metformin.",
    "sessionId": "example_001"
  }'
```

**Response:**
```json
{
  "success": true,
  "sessionId": "example_001",
  "timestamp": "2024-01-15T10:30:00",
  "processingTimeMs": 1200,
  "entityCount": 2,
  "entities": [
    {
      "entityName": "diabetes mellitus",
      "entityType": "disease",
      "confidenceScore": 0.95,
      "startPosition": 28,
      "endPosition": 44,
      "context": "...diagnosed with diabetes mellitus and prescribed...",
      "ontologyMatches": [
        {
          "termId": "DOID:9351",
          "termName": "diabetes mellitus",
          "namespace": "disease_ontology",
          "matchType": "EXACT",
          "confidence": 1.0
        }
      ]
    },
    {
      "entityName": "metformin",
      "entityType": "drug",
      "confidenceScore": 0.92,
      "startPosition": 59,
      "endPosition": 68,
      "context": "...and prescribed metformin.",
      "ontologyMatches": [
        {
          "termId": "CHEBI:6801",
          "termName": "metformin",
          "namespace": "chemical_entities",
          "matchType": "EXACT",
          "confidence": 1.0
        }
      ]
    }
  ],
  "summary": {
    "totalEntities": 2,
    "averageConfidence": 0.935,
    "ontologyMatchCount": 2
  }
}
```

### 2. Advanced Entity Recognition

Recognize specific entity types with custom confidence threshold:

```bash
curl -X POST "${BASE_URL}/recognize" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "The p53 gene mutation was associated with increased risk of colorectal cancer in BRCA1 carriers.",
    "entityTypes": "gene,disease",
    "confidenceThreshold": 0.8,
    "enableOntologyMatching": true,
    "domain": "oncology",
    "sessionId": "oncology_analysis_001"
  }'
```

### 3. Batch Processing (Synchronous)

Process multiple texts in parallel:

```bash
curl -X POST "${BASE_URL}/batch" \
  -H "Content-Type: application/json" \
  -d '{
    "texts": [
      "Hypertension is a major risk factor for cardiovascular disease.",
      "The ACE inhibitor lisinopril effectively reduces blood pressure.",
      "Type 2 diabetes mellitus affects insulin sensitivity."
    ],
    "entityTypes": "disease,drug",
    "confidenceThreshold": 0.7,
    "enableOntologyMatching": true,
    "sessionId": "batch_cardio_001"
  }'
```

**Response:**
```json
{
  "success": true,
  "sessionId": "batch_cardio_001",
  "timestamp": "2024-01-15T10:35:00",
  "processingTimeMs": 3500,
  "processedCount": 3,
  "successfulCount": 3,
  "failedCount": 0,
  "results": [
    {
      "success": true,
      "entities": [
        {
          "entityName": "hypertension",
          "entityType": "disease",
          "confidenceScore": 0.94
        },
        {
          "entityName": "cardiovascular disease",
          "entityType": "disease",
          "confidenceScore": 0.91
        }
      ]
    }
  ],
  "batchSummary": {
    "totalEntitiesFound": 8,
    "totalOntologyMatches": 6,
    "averageConfidenceAcrossBatch": 0.87,
    "mostCommonEntityType": "disease"
  }
}
```

### 4. Asynchronous Batch Processing

For large datasets, use asynchronous processing:

```bash
# Start async batch
curl -X POST "${BASE_URL}/batch/async" \
  -H "Content-Type: application/json" \
  -d '{
    "texts": ["text1", "text2", "...many more texts..."],
    "entityTypes": "gene,protein,disease",
    "sessionId": "large_batch_001"
  }'
```

**Response:**
```json
{
  "success": true,
  "batchId": "batch_456789",
  "totalItems": 150,
  "startTime": "2024-01-15T10:40:00",
  "message": "Batch processing started successfully",
  "statusUrl": "/api/curation/entity-recognition/batch/status/batch_456789"
}
```

```bash
# Check status
curl -X GET "${BASE_URL}/batch/status/batch_456789"
```

**Status Response:**
```json
{
  "batchId": "batch_456789",
  "status": "PROCESSING",
  "totalItems": 150,
  "processedItems": 75,
  "successfulItems": 73,
  "startTime": "2024-01-15T10:40:00",
  "progressPercentage": 50.0
}
```

```bash
# Cancel if needed
curl -X POST "${BASE_URL}/batch/cancel/batch_456789"
```

### 5. Ontology Matching Only

Match pre-identified entities to ontology terms:

```bash
curl -X POST "${BASE_URL}/match-ontology" \
  -H "Content-Type: application/json" \
  -d '{
    "entityNames": ["diabetes", "insulin resistance", "hypertension"],
    "namespace": "disease_ontology",
    "enableExactMatch": true,
    "enableFuzzyMatch": true,
    "fuzzyThreshold": 0.8,
    "maxResults": 3,
    "sessionId": "ontology_match_001"
  }'
```

**Response:**
```json
{
  "success": true,
  "sessionId": "ontology_match_001",
  "timestamp": "2024-01-15T10:45:00",
  "processingTimeMs": 150,
  "totalMatches": 7,
  "matches": {
    "diabetes": [
      {
        "termId": "DOID:9351",
        "termName": "diabetes mellitus",
        "namespace": "disease_ontology",
        "matchType": "FUZZY",
        "confidence": 0.95,
        "explanation": "High similarity match"
      }
    ],
    "insulin resistance": [
      {
        "termId": "DOID:1193",
        "termName": "insulin resistance",
        "namespace": "disease_ontology",
        "matchType": "EXACT",
        "confidence": 1.0,
        "explanation": "Exact term match"
      }
    ]
  }
}
```

### 6. Service Health Check

Monitor service status:

```bash
curl -X GET "${BASE_URL}/status"
```

**Response:**
```json
{
  "success": true,
  "timestamp": "2024-01-15T10:50:00",
  "overallHealthy": true,
  "aiServiceHealthy": true,
  "aiServiceStatus": "Connected to Ollama at grudge.rgd.mcw.edu:11434",
  "ontologyLoaded": true,
  "ontologyTermCount": 45362,
  "ontologyNamespaces": ["disease_ontology", "gene_ontology"],
  "cacheEnabled": true,
  "cacheHitRate": 0.87,
  "updateInProgress": false,
  "lastUpdateCheck": "2024-01-15T08:00:00"
}
```

## Domain-Specific Examples

### Cardiovascular Research

```bash
curl -X POST "${BASE_URL}/recognize" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "The patient presented with acute myocardial infarction. Echocardiography revealed reduced ejection fraction. Treatment included atorvastatin and metoprolol.",
    "entityTypes": "disease,drug,procedure",
    "domain": "cardiology",
    "confidenceThreshold": 0.8,
    "enableOntologyMatching": true,
    "sessionId": "cardio_case_001"
  }'
```

### Cancer Research

```bash
curl -X POST "${BASE_URL}/recognize" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "The tumor showed EGFR overexpression and KRAS mutation. Targeted therapy with erlotinib was initiated.",
    "entityTypes": "gene,protein,drug,phenotype",
    "domain": "oncology",
    "confidenceThreshold": 0.85,
    "enableOntologyMatching": true,
    "maxOntologyMatches": 3,
    "sessionId": "oncology_case_001"
  }'
```

### Neurological Studies

```bash
curl -X POST "${BASE_URL}/recognize" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Patients with Alzheimer disease showed reduced hippocampal volume and elevated tau protein levels in cerebrospinal fluid.",
    "entityTypes": "disease,protein,anatomy",
    "domain": "neurology",
    "confidenceThreshold": 0.75,
    "enableOntologyMatching": true,
    "includeObsoleteTerms": false,
    "sessionId": "neuro_study_001"
  }'
```

## Error Handling

### Validation Errors

```bash
# Request with invalid confidence threshold
curl -X POST "${BASE_URL}/recognize" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "",
    "confidenceThreshold": 1.5
  }'
```

**Error Response:**
```json
{
  "success": false,
  "errorMessage": "Text cannot be empty or contain only whitespace",
  "timestamp": "2024-01-15T10:55:00",
  "validationErrors": [
    {
      "field": "text",
      "message": "Text cannot be empty"
    },
    {
      "field": "confidenceThreshold",
      "message": "Confidence threshold must be between 0.0 and 1.0"
    }
  ]
}
```

### Service Unavailable

```json
{
  "success": false,
  "errorMessage": "Entity recognition failed: AI service unavailable",
  "timestamp": "2024-01-15T10:55:00"
}
```

## Rate Limits

- **Single requests**: 30 per minute per IP
- **Batch requests**: 5 per minute per IP  
- **Large batches (>50 items)**: 2 per hour per IP

Rate limit headers are included in responses:

```
X-RateLimit-Limit: 30
X-RateLimit-Remaining: 25
X-RateLimit-Reset: 1642248600
```

## Best Practices

### 1. Text Preprocessing

- Remove excessive whitespace and formatting
- Ensure text is in English for best results
- Split very long documents into manageable chunks

### 2. Entity Type Selection

- Specify relevant entity types to improve accuracy
- Use domain-specific settings when available
- Start with broader types, then refine

### 3. Confidence Thresholds

- Start with default 0.5, adjust based on precision/recall needs
- Higher thresholds (0.8+) for high-precision requirements
- Lower thresholds (0.3-0.5) for exploratory analysis

### 4. Batch Processing

- Use synchronous batch for <50 texts
- Use asynchronous batch for 50+ texts
- Monitor progress for long-running batches

### 5. Ontology Matching

- Enable for standardized terminology
- Use appropriate namespaces for your domain
- Consider fuzzy matching for variant spellings

## Integration Examples

### Python

```python
import requests
import json

def recognize_entities(text, entity_types=None, confidence=0.5):
    url = "https://rgd.mcw.edu/curation/api/curation/entity-recognition/recognize"
    
    payload = {
        "text": text,
        "confidenceThreshold": confidence,
        "enableOntologyMatching": True,
        "sessionId": f"python_client_{int(time.time())}"
    }
    
    if entity_types:
        payload["entityTypes"] = ",".join(entity_types)
    
    response = requests.post(url, json=payload)
    return response.json()

# Example usage
result = recognize_entities(
    "The patient has diabetes and takes metformin.",
    entity_types=["disease", "drug"],
    confidence=0.7
)

print(f"Found {result['entityCount']} entities")
for entity in result['entities']:
    print(f"- {entity['entityName']} ({entity['entityType']})")
```

### JavaScript

```javascript
async function recognizeEntities(text, options = {}) {
    const url = 'https://rgd.mcw.edu/curation/api/curation/entity-recognition/recognize';
    
    const payload = {
        text: text,
        confidenceThreshold: options.confidence || 0.5,
        enableOntologyMatching: options.ontologyMatching !== false,
        sessionId: `js_client_${Date.now()}`,
        ...options
    };
    
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(payload)
    });
    
    return await response.json();
}

// Example usage
recognizeEntities(
    "The BRCA1 gene mutation increases breast cancer risk.",
    { 
        entityTypes: "gene,disease",
        confidence: 0.8,
        domain: "oncology"
    }
).then(result => {
    console.log(`Found ${result.entityCount} entities`);
    result.entities.forEach(entity => {
        console.log(`- ${entity.entityName} (${entity.entityType})`);
    });
});
```

## Support

For technical support or questions:
- Email: rgd.informatics@mcw.edu
- Documentation: https://rgd.mcw.edu/curation/docs
- API Status: https://rgd.mcw.edu/curation/api/curation/entity-recognition/status