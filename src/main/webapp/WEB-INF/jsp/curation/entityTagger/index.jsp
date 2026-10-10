<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RGD Entity Tagger - Biological Entity Recognition Tool</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Font Awesome -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link href="${pageContext.request.contextPath}/css/entityTagger/curation-main.css" rel="stylesheet">
</head>
<body>
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                <header class="mb-5 text-center">
                    <h1 class="display-3">
                        <i class="fas fa-dna text-primary"></i>
                        RGD Entity Tagger
                    </h1>
                    <p class="lead text-muted">Automated Biological Entity Recognition and Curation Tool</p>
                    <hr class="w-50 mx-auto">
                </header>
            </div>
        </div>

        <div class="row">
            <div class="col-lg-8 mx-auto">
                <!-- Main Features -->
                <div class="row g-4 mb-5">
                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body text-center">
                                <i class="fas fa-file-pdf fa-3x text-danger mb-3"></i>
                                <h5 class="card-title">PDF Upload</h5>
                                <p class="card-text">Upload scientific papers and documents for automated entity extraction</p>
                                <a href="${pageContext.request.contextPath}/curation/pdf/upload.html" class="btn btn-primary">
                                    <i class="fas fa-upload"></i> Upload Document
                                </a>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body text-center">
                                <i class="fas fa-microscope fa-3x text-success mb-3"></i>
                                <h5 class="card-title">Entity Recognition</h5>
                                <p class="card-text">AI-powered identification of genes, diseases, strains, chemicals, and more</p>
                                <button class="btn btn-success" disabled>
                                    <i class="fas fa-play"></i> Start Recognition
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card h-100 shadow-sm">
                            <div class="card-body text-center">
                                <i class="fas fa-tags fa-3x text-info mb-3"></i>
                                <h5 class="card-title">Curation</h5>
                                <p class="card-text">Review, validate, and curate identified biological entities</p>
                                <button class="btn btn-info" disabled>
                                    <i class="fas fa-edit"></i> Start Curation
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Supported Entity Types -->
                <div class="card shadow">
                    <div class="card-header bg-light">
                        <h4 class="mb-0">
                            <i class="fas fa-list"></i>
                            Supported Entity Types
                        </h4>
                    </div>
                    <div class="card-body">
                        <div class="row g-3">
                            <div class="col-md-6">
                                <ul class="list-unstyled">
                                    <li><i class="fas fa-dna text-primary"></i> <strong>Genes</strong> - Gene symbols and names</li>
                                    <li><i class="fas fa-virus text-danger"></i> <strong>Diseases</strong> - Disease names and conditions (RDO)</li>
                                    <li><i class="fas fa-mouse text-warning"></i> <strong>Rat Strains</strong> - Laboratory rat strains (RGD)</li>
                                    <li><i class="fas fa-flask text-info"></i> <strong>Chemicals</strong> - Compounds and drugs</li>
                                </ul>
                            </div>
                            <div class="col-md-6">
                                <ul class="list-unstyled">
                                    <li><i class="fas fa-paw text-success"></i> <strong>Species</strong> - Organism species names</li>
                                    <li><i class="fas fa-eye text-secondary"></i> <strong>Phenotypes</strong> - Observable traits</li>
                                    <li><i class="fas fa-cell text-primary"></i> <strong>Cellular Components</strong> - GO terms</li>
                                    <li><i class="fas fa-plus text-muted"></i> <strong>More...</strong> - Additional entity types</li>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Getting Started -->
                <div class="card mt-4">
                    <div class="card-header bg-primary text-white">
                        <h5 class="mb-0">
                            <i class="fas fa-rocket"></i>
                            Getting Started
                        </h5>
                    </div>
                    <div class="card-body">
                        <ol class="mb-0">
                            <li><strong>Upload</strong> a PDF document containing scientific text</li>
                            <li><strong>Process</strong> the document for text extraction</li>
                            <li><strong>Recognize</strong> biological entities using AI and ontologies</li>
                            <li><strong>Review</strong> and validate the identified entities</li>
                            <li><strong>Export</strong> the curated results</li>
                        </ol>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>