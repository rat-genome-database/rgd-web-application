<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%
    AliasDAO aliasDAO = new AliasDAO();
    AnnotationDAO annotationDAO = new AnnotationDAO();
    AssociationDAO associationDAO = new AssociationDAO();
    GeneDAO geneDAO = associationDAO.getGeneDAO();
    GenomicElementDAO geDAO = new GenomicElementDAO();
    MapDAO mapDAO = new MapDAO();
    NomenclatureDAO nomenclatureDAO = new NomenclatureDAO();
    NotesDAO noteDAO = new NotesDAO();
    OntologyXDAO ontologyDAO = new OntologyXDAO();
    PhenominerDAO phenominerDAO = new PhenominerDAO();
    QTLDAO qtlDAO = new QTLDAO();
    ReferenceDAO referenceDAO = associationDAO.getReferenceDAO();
    RGDManagementDAO managementDAO = new RGDManagementDAO();
    SequenceDAO sequenceDAO = new SequenceDAO();
    SSLPDAO sslpDAO = associationDAO.getSslpDAO();
    SslpsAlleleDAO sslpAlleleDAO = new SslpsAlleleDAO();
    StrainDAO strainDAO = associationDAO.getStrainDAO();
    TranscriptDAO transcriptDAO = new TranscriptDAO();
    XdbIdDAO xdbDAO = new XdbIdDAO();
    GeneticModelsDAO geneticModelsDAO= new GeneticModelsDAO();
    HgncDAO hgncDAO = new HgncDAO();
%>