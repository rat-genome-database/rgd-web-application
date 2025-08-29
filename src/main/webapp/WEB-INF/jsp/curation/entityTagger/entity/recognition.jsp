<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>RGD Entity Recognition - Upload ${uploadId}</title>
    
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
                <header class="mb-4">
                    <h1 class="display-6">
                        <i class="fas fa-microscope text-primary"></i>
                        Entity Recognition Results
                    </h1>
                    <p class="lead">Biological entities identified in uploaded document</p>
                </header>
            </div>
        </div>

        <!-- Entity Recognition content will be dynamically loaded here -->
        <div id="entityRecognitionContent">
            <div class="text-center py-5">
                <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Loading entity recognition results...</span>
                </div>
                <p class="mt-3">Processing document for biological entities...</p>
            </div>
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
    <!-- Custom JS -->
    <script>
        window.curationConfig = {
            uploadId: '${uploadId}',
            contextPath: '${pageContext.request.contextPath}'
        };
    </script>
    <script src="${pageContext.request.contextPath}/js/entityTagger/entity-recognition.js"></script>
    <script src="${pageContext.request.contextPath}/js/entityTagger/entity-highlighting.js"></script>
</body>
</html>